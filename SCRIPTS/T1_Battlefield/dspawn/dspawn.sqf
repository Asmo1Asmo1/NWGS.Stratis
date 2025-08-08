#include "..\..\globalDefines.h"
#include "dspawnDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DSPAWN_Settings = createHashMapFromArray [
    ["CATALOGUE_ADDRESS","DATASETS\Server\Dspawn"],
    ["CATALOGUE_MAX_TIER",4],//Max tier of groups that can be spawned

    ["WAYPOINT_RADIUS_PLACE",10],//Radius for waypoint random placement (use '0' for almost exact placement and '-1' for exact)
    ["WAYPOINT_RADIUS_COMPL",30],//Radius for waypoint to count as 'completed', the more - the easier for big vehicles and complicated terrains

    ["TRIGGER_POPULATION_DISTRIBUTION",[5,3,1,1,1]],//Default population as INF/VEH/ARM/AIR/BOAT
    ["TRIGGER_MAX_BUILDINGS_TO_OCCUPY",5],//Max number of buildings that dspawn will try to occupy with 'ambush' infantry forces
    ["TRIGGER_INF_BUILDINGS_DYNAMIC_SIMULATION",false],//If true - infantry spawned in buildings will act only when players are nearby
    ["TRIGGER_INF_BUILDINGS_DISABLE_PATH",false],//If true - infantry spawned in buildings will not leave their positions, becoming static enemies

    ["PARADROP_RADIUS",3000],//Radius for paradrop vehicle to spawn, fly by and despawn
    ["PARADROP_HEIGHT",200],//Height of paradropping
    ["PARADROP_TIMEOUT",90],//Timeout to auto-cancel paradrop in case of an error

    ["ATTACK_INF_ATTACK_RADIUS",250],//Radius for INF group to 'attack' the position
    ["ATTACK_VEH_UNLOAD_RADIUS",350],//Radius for VEH group to unload passengers
    ["ATTACK_VEH_ATTACK_RADIUS",250],//Radius for VEH group to 'attack' the position
    ["ATTACK_AIR_UNLOAD_RADIUS",350],//Radius for AIR group to unload passengers
    ["ATTACK_AIR_ATTACK_RADIUS",450],//Radius for AIR group to 'attack' the position
    ["ATTACK_AIR_DESPAWN_RADIUS",5000],//Radius for AIR vehicle to despawn after unload
    ["ATTACK_BOAT_UNLOAD_RADIUS",300],//Radius for BOAT group to unload passengers
    ["ATTACK_BOAT_ATTACK_RADIUS",250],//Radius for BOAT group to 'attack' the position
    ["ATTACK_PARADROPS_MAX",1],//Max number of vehicle paradrops per reinforcement
    ["ATTACK_PARADROPS_CHANCE",0.5],//Chance of vehicle group being paradropped (keep 0-1)
    ["ATTACK_SPAWN_PLAYERS_MIN_DISTANCE",300],//Min distance between spawn point and players

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
/*Dspawn configs*/
NWG_DSPAWN_CFG_Side = west;
NWG_DSPAWN_CFG_Faction = "NATO";
NWG_DSPAWN_CFG_Tiers = [1,2,3,4];
NWG_DSPAWN_CFG_ReinfMap = [nil,nil,nil,nil];

/*Dspawn last populated trigger (for reinforcements to patrol after duty)*/
NWG_DSPAWN_TRIGGER_lastPopulatedTrigger = [];

//================================================================================================================
//================================================================================================================
//Config
NWG_DSPAWN_Configure = {
    params ["_side","_faction","_tiers","_reinfMap"];
    if (isNil "_side" || {!(_side in [west,east,independent])}) exitWith {
        (format ["NWG_DSPAWN_Configure: Invalid side '%1'",_side]) call NWG_fnc_logError;
        false
    };
    if (isNil "_faction" || {!(_faction isEqualType "")}) exitWith {
        (format ["NWG_DSPAWN_Configure: Invalid faction '%1'",_faction]) call NWG_fnc_logError;
        false
    };
    if (isNil "_tiers") exitWith {
        (format ["NWG_DSPAWN_Configure: Invalid tiers '%1'",_tiers]) call NWG_fnc_logError;
        false
    };
    if (isNil "_reinfMap" || {!(_reinfMap isEqualTypeArray [[],[],[],[]])}) exitWith {
        (format ["NWG_DSPAWN_Configure: Invalid reinfMap '%1'",_reinfMap]) call NWG_fnc_logError;
        false
    };

    NWG_DSPAWN_CFG_Side = _side;
    NWG_DSPAWN_CFG_Faction = _faction;
    NWG_DSPAWN_CFG_Tiers = _tiers;
    NWG_DSPAWN_CFG_ReinfMap = _reinfMap;
    true
};

//================================================================================================================
//================================================================================================================
//Populate trigger
#define SP_INDEX_GROUND 0
#define SP_INDEX_WATER 1
#define SP_INDEX_ROADS_AWAY 2
#define SP_INDEX_LOCATIONS 3
#define SP_INDEX_AIR 4

#define G_INDEX_INF 0
#define G_INDEX_VEH 1
#define G_INDEX_ARM 2
#define G_INDEX_AIR 3
#define G_INDEX_BOAT 4

NWG_DSPAWN_TRIGGER_PopulateTriggerCfg = {
    params ["_trigger","_groupsCount",["_filter",[]]];
    _filter = [(_filter param [0,[]]),(_filter param [1,[]]),NWG_DSPAWN_CFG_Tiers];

    [
        _trigger,
        _groupsCount,
        NWG_DSPAWN_CFG_Faction,
        _filter,
        NWG_DSPAWN_CFG_Side
    ] call NWG_DSPAWN_TRIGGER_PopulateTrigger;
};
NWG_DSPAWN_TRIGGER_PopulateTrigger = {
    params ["_trigger","_groupsCount","_faction",["_filter",[]],["_side",west]];
    NWG_DSPAWN_TRIGGER_lastPopulatedTrigger = [];

    //Generate trigger map
    private _spawnMap = _trigger call NWG_fnc_dtsMarkupTrigger;//[_plains,_roads,_water,_roadsAway,_locations,_air]
    if (_spawnMap isEqualTo false) exitWith {
        (format ["NWG_DSPAWN_TRIGGER_PopulateTrigger: Could not generate trigger map for trigger '%1'",_trigger]) call NWG_fnc_logError;
        false
    };
    {_x call NWG_fnc_arrayShuffle} forEach _spawnMap;
    private _spawnPoints = [
        /*SP_INDEX_GROUND:*/((_spawnMap#0)+(_spawnMap#1)),//_plains + _roads
        /*SP_INDEX_WATER:*/(_spawnMap#2),//_water
        /*SP_INDEX_ROADS_AWAY:*/(_spawnMap#3),//_roadsAway
        /*SP_INDEX_LOCATIONS:*/(_spawnMap#4),//_locations
        /*SP_INDEX_AIR:*/(_spawnMap#5)//_air
    ];
    private _spawnPointsPointers = [0,0,0,0,0];

    //Calculate trigger population distribution
    private _popFilter = call {
        _filter params [["_whiteList",[]],["_blackList",[]]];
        _blackList = _blackList + [];//Shallow copy

        if ((count (_spawnPoints#SP_INDEX_GROUND)) == 0) then {_blackList pushBackUnique "INF"};
        if ((count (_spawnPoints#SP_INDEX_WATER)) == 0) then {_blackList pushBackUnique "BOAT"};
        if ((count (_spawnPoints#SP_INDEX_AIR)) == 0) then {_blackList pushBackUnique "AIR"};
        if ((count (_spawnPoints#SP_INDEX_GROUND)) == 0 && {(count (_spawnPoints#SP_INDEX_ROADS_AWAY)) == 0}) then {_blackList pushBackUnique "VEH"};

        //return
        [_whiteList,_blackList]
    };
    private _population = [_groupsCount,_popFilter] call NWG_DSPAWN_TRIGGER_CalculatePopulationDistribution;
    if ((count _population) != 5 || {(_population findIf {_x > 0}) == -1}) exitWith {
        (format ["NWG_DSPAWN_TRIGGER_PopulateTrigger: Trigger population distribution '%1' is invalid",_population]) call NWG_fnc_logError;
        false
    };

    //Get catalogue values for spawn
    private _page = _faction call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {
        (format ["NWG_DSPAWN_TRIGGER_PopulateTrigger: Could not load catalogue page for faction '%1'",_faction]) call NWG_fnc_logError;
        false
    };
    private _passengersContainer = _page#PASSENGERS_CONTAINER;
    private _groupsContainer = [(_page#GROUPS_CONTAINER),_filter] call NWG_DSPAWN_FilterGroups;
    if ((count _groupsContainer) == 0) then {
        (format ["NWG_DSPAWN_TRIGGER_PopulateTrigger: Filter '%1' for faction '%2' resulted in ZERO groups. Fallback to original container",_filter,_faction]) call NWG_fnc_logError;
        _groupsContainer = (_page#GROUPS_CONTAINER);
    };
    private _groups = [
        ((_groupsContainer select {"INF" in (_x#DESCR_TAGS)}) call NWG_fnc_arrayShuffle),
        ((_groupsContainer select {"VEH" in (_x#DESCR_TAGS)}) call NWG_fnc_arrayShuffle),
        ((_groupsContainer select {"ARM" in (_x#DESCR_TAGS)}) call NWG_fnc_arrayShuffle),
        ((_groupsContainer select {"AIR" in (_x#DESCR_TAGS)}) call NWG_fnc_arrayShuffle),
        ((_groupsContainer select {"BOAT" in (_x#DESCR_TAGS)}) call NWG_fnc_arrayShuffle)
    ];
    private _groupsPointers = [0,0,0,0,0];

    //Prepare scripts
    private _getNext = {
        params ["_index","_array","_pointers"];
        private _pointer = _pointers#_index;
        private _result = (_array#_index)#_pointer;
        _pointer = _pointer + 1;
        if (_pointer >= (count (_array#_index))) then {_pointer = 0};
        _pointers set [_index,_pointer];
        //return
        _result
    };
    private _spawnPatrols = {
        params ["_groupsIndex","_spawnPointsIndex","_targetCount","_patrolLength"];

        //Check
        if ((count (_groups#_groupsIndex)) == 0) exitWith {0};//No groups to spawn
        if ((count (_spawnPoints#_spawnPointsIndex)) == 0) exitWith {0};//Nowhere to spawn
        if (_targetCount <= 0) exitWith {0};//No groups to spawn

        //Prepare sub-scripts and variables
        private _patrolPoints = _spawnPoints#_spawnPointsIndex;
        private _patrolRoute = [];
        private _groupToSpawn = [];
        private _generatePatrolRoute = switch (true) do {
            case (_patrolLength == 1 || {(count _patrolPoints) == 1}): {{
                [([_spawnPointsIndex,_spawnPoints,_spawnPointsPointers] call _getNext)]
            }};
            case (_patrolLength == 2 || {(count _patrolPoints) == 2}): {{
                private _p1 = [_spawnPointsIndex,_spawnPoints,_spawnPointsPointers] call _getNext;
                private _p2 = _patrolPoints select ([_patrolPoints,_p1] call NWG_fnc_dtsFindIndexOfFarthest);
                [_p1,_p2]
            }};
            default /*_patrolLength == 3 && (count _spawnPoints) >= 3*/ {{
                private _p1 = [_spawnPointsIndex,_spawnPoints,_spawnPointsPointers] call _getNext;
                private _p2 = _patrolPoints select ([_patrolPoints,_p1] call NWG_fnc_dtsFindIndexOfFarthest);
                private _p3 = selectRandom (_patrolPoints - [_p1,_p2]);
                [_p1,_p2,_p3]
            }};
        };
        private _spawnSelected = switch (true) do {
            case (_groupsIndex == G_INDEX_INF): {{
                [_groupToSpawn,(_patrolRoute#0),_side,_faction] call NWG_DSPAWN_SpawnInfantryGroup
            }};
            case (_patrolLength == 1): {{
                [_groupToSpawn,(_patrolRoute#0),(random 360),false,_side,_faction] call NWG_DSPAWN_SpawnVehicledGroup
            }};
            default /*!INF && _patrolLength > 1*/ {{
                private _dir = if ((count _patrolRoute)>1) then {(_patrolRoute#0) getDir (_patrolRoute#1)} else {random 360};
                [_groupToSpawn,(_patrolRoute#0),_dir,false,_side,_faction] call NWG_DSPAWN_SpawnVehicledGroup
            }};
        };

        //Start spawning
        private _resultCount = 0;
        private "_spawnResult";
        for "_i" from 1 to _targetCount do {
            _patrolRoute = call _generatePatrolRoute;
            _groupToSpawn = [_groupsIndex,_groups,_groupsPointers] call _getNext;
            _groupToSpawn = [_groupToSpawn,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
            _spawnResult = call _spawnSelected;
            if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) then {continue};
            [(_spawnResult#SPAWN_RESULT_GROUP),_patrolRoute] call NWG_DSPAWN_SendToPatrol;
            _resultCount = _resultCount + 1;
        };

        //return
        _resultCount
    };

    //Populate trigger in order BOAT->AIR->ARM->VEH->INF to utilize the spawning positions
    //Each time the population is unable to be fulfilled (e.g. there is no water to spawn BOATs) the remainder is fallbacked to INF category
    private _targetCount = 0;
    private _resultCount = 0;
    private _totalResultCount = 0;

    //Spawn BOATs
    _targetCount = _population#G_INDEX_BOAT;
    _resultCount = [G_INDEX_BOAT,SP_INDEX_WATER,_targetCount,3] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_BOAT,0];
    _population set [G_INDEX_INF,((_population#G_INDEX_INF)+(_targetCount-_resultCount))];//Fallback to INF

    //Spawn AIRs
    _targetCount = _population#G_INDEX_AIR;
    _resultCount = [G_INDEX_AIR,SP_INDEX_AIR,_targetCount,3] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_AIR,0];
    _population set [G_INDEX_INF,((_population#G_INDEX_INF)+(_targetCount-_resultCount))];//Fallback to INF

    //Spawn ARM
    _targetCount = _population#G_INDEX_ARM;
    _resultCount = [G_INDEX_ARM,SP_INDEX_GROUND,_targetCount,1] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_ARM,0];
    _population set [G_INDEX_INF,((_population#G_INDEX_INF)+(_targetCount-_resultCount))];//Fallback to INF

    //Spawn VEH
    //Spawn VEH on roads away to roll throughout trigger
    _targetCount = (count (_spawnPoints#SP_INDEX_ROADS_AWAY)) min (_population#G_INDEX_VEH);
    _resultCount = [G_INDEX_VEH,SP_INDEX_ROADS_AWAY,_targetCount,2] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_VEH,((_population#G_INDEX_VEH)-_resultCount)];
    //Spawn remaining VEH on the ground just standing
    _targetCount = _population#G_INDEX_VEH;
    _resultCount = [G_INDEX_VEH,SP_INDEX_GROUND,_targetCount,1] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_VEH,0];
    _population set [G_INDEX_INF,((_population#G_INDEX_INF)+(_targetCount-_resultCount))];//Fallback to INF

    //Spawn INF
    //Spawn INF patrols locations<->ground to go in and out of the trigger
    //This logic mixes spawn points from different categories, so it is not possible to use _spawnPatrols script
    if (((count (_spawnPoints#SP_INDEX_LOCATIONS)) > 0) && {(count (_spawnPoints#SP_INDEX_GROUND)) > 0}) then {
        private _locations = _spawnPoints#SP_INDEX_LOCATIONS;
        private _ground = _spawnPoints#SP_INDEX_GROUND;
        _targetCount = (count _locations) min (_population#G_INDEX_INF);
        _resultCount = 0;
        for "_i" from 1 to _targetCount do {
            private _p1 = [SP_INDEX_LOCATIONS,_spawnPoints,_spawnPointsPointers] call _getNext;
            private _p2 = _ground select ([_ground,_p1] call NWG_fnc_dtsFindIndexOfFarthest);
            private _patrolRoute = [_p1,_p2];
            if ((count _ground) > 1) then {
                private _p3 = selectRandom (_ground - [_p1,_p2]);
                _patrolRoute pushBack _p3;
            };
            _patrolRoute = _patrolRoute call NWG_fnc_arrayShuffle;
            private _groupToSpawn = [G_INDEX_INF,_groups,_groupsPointers] call _getNext;
            _groupToSpawn = [_groupToSpawn,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
            private _spawnResult = [_groupToSpawn,(_patrolRoute#0),_side,_faction] call NWG_DSPAWN_SpawnInfantryGroup;
            if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) then {continue};
            [(_spawnResult#SPAWN_RESULT_GROUP),_patrolRoute] call NWG_DSPAWN_SendToPatrol;
            _resultCount = _resultCount + 1;
        };
        _totalResultCount = _totalResultCount + _resultCount;
        _population set [G_INDEX_INF,((_population#G_INDEX_INF)-_resultCount)];
    };
    //Spawn INF patrols as ambushes in buildings
    private _buildings = _trigger call NWG_DSPAWN_TRIGGER_FindOccupiableBuildings;
    if ((count _buildings) > 0) then {
        _targetCount = ((NWG_DSPAWN_Settings get "TRIGGER_MAX_BUILDINGS_TO_OCCUPY") min (_population#G_INDEX_INF)) min (count _buildings);
        _resultCount = 0;
        if ((count _buildings) > _targetCount) then {
            _buildings = _buildings call NWG_fnc_arrayShuffle;
            _buildings resize _targetCount;
        };

        private _dynamicIfNeeded = if ((NWG_DSPAWN_Settings get "TRIGGER_INF_BUILDINGS_DYNAMIC_SIMULATION"))
            then {{_this enableDynamicSimulation true}}
            else {{}};
        private _disablePathIfNeeded = if ((NWG_DSPAWN_Settings get "TRIGGER_INF_BUILDINGS_DISABLE_PATH"))
            then {{{_x disableAI "PATH"} forEach (units _this)}}
            else {{}};
        //do
        {
            private _groupToSpawn = [G_INDEX_INF,_groups,_groupsPointers] call _getNext;
            _groupToSpawn = [_groupToSpawn,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
            private _spawnResult = [_groupToSpawn,_x,_side,_faction] call NWG_DSPAWN_SpawnInfantryGroupInBuilding;
            if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) then {continue};
            _resultCount = _resultCount + 1;
            (_spawnResult#SPAWN_RESULT_GROUP) call _dynamicIfNeeded;
            (_spawnResult#SPAWN_RESULT_GROUP) call _disablePathIfNeeded;
        } forEach _buildings;
        _totalResultCount = _totalResultCount + _resultCount;
        _population set [G_INDEX_INF,((_population#G_INDEX_INF)-_resultCount)];
    };
    //Spawn INF patrols roaming the trigger
    _targetCount = _population#G_INDEX_INF;
    _resultCount = [G_INDEX_INF,SP_INDEX_GROUND,_targetCount,3] call _spawnPatrols;
    _totalResultCount = _totalResultCount + _resultCount;
    _population set [G_INDEX_INF,0];

    //Cache last populated trigger
    NWG_DSPAWN_TRIGGER_lastPopulatedTrigger = _trigger;

    //return
    _totalResultCount
};

NWG_DSPAWN_TRIGGER_CalculatePopulationDistribution = {
    params ["_targetCount","_filter"];
    private _result = (NWG_DSPAWN_Settings get "TRIGGER_POPULATION_DISTRIBUTION") + [];//Shallow copy of default distribution

    //Prepare variables
    private _curCount = 0;
    private _updateCurCount = {
        _curCount = 0;
        {_curCount = _curCount + _x} forEach _result;
        _curCount
    };

    //Check default distribution
    call _updateCurCount;
    if (_curCount <= 0 || {(_result findIf {_x < 0}) != -1}) exitWith {
        (format ["NWG_DSPAWN_TRIGGER_CalculatePopulation: Trigger population setting '%1' is invalid",_result]) call NWG_fnc_logError;
        _result
    };

    //Apply filter
    if (_filter isNotEqualTo []) then {
        _filter params [["_whiteList",[]],["_blackList",[]]];
        private _set = ["INF","VEH","ARM","AIR","BOAT"];
        _whiteList = _whiteList arrayIntersect _set;
        _blackList = _blackList arrayIntersect _set;
        if (_whiteList isEqualTo [] && {_blackList isEqualTo []}) exitWith {};

        if (_whiteList isNotEqualTo []) then {_set = _set select {_x in _whiteList}};
        if (_blackList isNotEqualTo []) then {_set = _set select {!(_x in _blackList)}};

        if !("INF" in _set)  then {_result set [G_INDEX_INF,0]};
        if !("VEH" in _set)  then {_result set [G_INDEX_VEH,0]};
        if !("ARM" in _set)  then {_result set [G_INDEX_ARM,0]};
        if !("AIR" in _set)  then {_result set [G_INDEX_AIR,0]};
        if !("BOAT" in _set) then {_result set [G_INDEX_BOAT,0]};

        if ((call _updateCurCount) <= 0) then {
            (format ["NWG_DSPAWN_TRIGGER_CalculatePopulation: Trigger filter '%1' resulted in ZERO population",_filter]) call NWG_fnc_logError;
        };
    };
    if (_curCount <= 0 || {_curCount == _targetCount}) exitWith {_result};//No need to modify population further

    //Roughly apply multiplier
    private _multiplier = (round (_targetCount / _curCount)) max 1;
    if (_multiplier != 1) then {
        _result = _result apply {_x * _multiplier};
        call _updateCurCount;
    };
    if (_curCount == _targetCount) exitWith {_result};//No need to modify population further

    //Precisely modify population
    private _diff = abs (_targetCount - _curCount);
    private _change = if (_targetCount > _curCount) then {1} else {-1};
    private _indexes = [];
    private _j = -1;
    for "_i" from 1 to _diff do {
        {if (_x > 0) then {_indexes pushBack _forEachIndex}} forEach _result;
        _j = selectRandom _indexes;
        _result set [_j,((_result#_j)+_change)];
        _indexes resize 0;
    };

    //return
    _result
};

NWG_DSPAWN_TRIGGER_FindOccupiableBuildings = {
    // private _trigger = _this;
    params ["_triggerPos","_triggerRad"];
    private _occupiedBuildings = call NWG_fnc_shGetOccupiedBuildings;

    //return
    (_triggerPos nearObjects _triggerRad) select {
        (_x call NWG_fnc_ocIsBuilding) && {
        ((count (_x buildingPos -1)) >= 4) && {
        !(_x in _occupiedBuildings)}}
    };
};

//================================================================================================================
//================================================================================================================
//Send reinforcements
NWG_DSPAWN_REINF_SendReinforcementsCfg = {
    params ["_attackPos","_groupsCount",["_filter",[]]];
    _filter = [(_filter param [0,[]]),(_filter param [1,[]]),NWG_DSPAWN_CFG_Tiers];

    [
        _attackPos,
        _groupsCount,
        NWG_DSPAWN_CFG_Faction,
        _filter,
        NWG_DSPAWN_CFG_Side,
        NWG_DSPAWN_CFG_ReinfMap
    ] call NWG_DSPAWN_REINF_SendReinforcements;
};
NWG_DSPAWN_REINF_SendReinforcements = {
    params ["_attackPos","_groupsCount","_faction",["_filter",[]],["_side",west],["_spawnMap",[nil,nil,nil,nil]]];

    //Prepare spawn point picking (with lazy evaluation)
    private _players = call NWG_fnc_getPlayersOrOccupiedVehicles;
    private _minDist = NWG_DSPAWN_Settings get "ATTACK_SPAWN_PLAYERS_MIN_DISTANCE";
    private _getSpawnPoint = {
        private _pointType = _this;
        private _index = switch (_pointType) do {
            case "INF":  {0};
            case "VEH":  {1};
            case "BOAT": {2};
            case "AIR":  {3};
        };

        private _spawnArray = _spawnMap param [_index,nil];
        if (isNil "_spawnArray") then {
            private _markupArgs = switch (_pointType) do {
                case "INF":  {[_attackPos,true ,false,false,false]};
                case "VEH":  {[_attackPos,false,true, false,false]};
                case "BOAT": {[_attackPos,false,false,true, false]};
                case "AIR":  {[_attackPos,false,false,false,true ]};
            };
            _spawnArray = (_markupArgs call NWG_fnc_dtsMarkupReinforcement) select _index;//[_inf,_veh,_boats,_air]
            _spawnMap set [_index,_spawnArray];
        };
        if ((count _spawnArray) == 0) exitWith {false};//No points to spawn

        private _spawnPoint = [];
        private _attempts = 0;
        while {_attempts = _attempts + 1; _attempts <= (count _spawnArray)} do {
            _spawnPoint = _spawnArray deleteAt 0;
            _spawnArray pushBack _spawnPoint;
            if ((_players findIf {(_x distance2D _spawnPoint) < _minDist}) == -1) exitWith {};
        };

        //return
        _spawnPoint
    };

    //Get catalogue values for spawn
    private _page = _faction call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {
        (format ["NWG_DSPAWN_REINF_SendReinforcements: Could not load catalogue page for faction '%1'",_faction]) call NWG_fnc_logError;
        false
    };
    private _passengersContainer = _page#PASSENGERS_CONTAINER;
    private _paradropContainer = _page#PARADROP_CONTAINER;
    private _groupsContainer = [(_page#GROUPS_CONTAINER),_filter] call NWG_DSPAWN_FilterGroups;
    if ((count _groupsContainer) == 0) then {
        (format ["NWG_DSPAWN_REINF_SendReinforcements: Filter '%1' for faction '%2' resulted in ZERO groups. Fallback to original container",_filter,_faction]) call NWG_fnc_logError;
        _groupsContainer = (_page#GROUPS_CONTAINER);
    };

    //Prepare scripts
    private _trySpawnInfGroup = {
        private _groupDescr = _this;
        private _spawnPoint = "INF" call _getSpawnPoint;
        if (_spawnPoint isEqualTo false) exitWith {false};
        private _groupToSpawn = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
        private _spawnResult = [_groupToSpawn,_spawnPoint,_side,_faction] call NWG_DSPAWN_SpawnInfantryGroup;
        if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {false};
        [(_spawnResult#SPAWN_RESULT_GROUP),_attackPos] call NWG_DSPAWN_SendToAttack;
        true
    };
    private _tryParadropVehGroup = {
        params ["_groupDescr","_spawnPointType"];
        private _spawnPoint = _spawnPointType call _getSpawnPoint;
        if (_spawnPoint isEqualTo false) exitWith {false};
        private _groupToSpawn = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
        private _spawnResult = [_groupToSpawn,_spawnPoint,(_spawnPoint getDir _attackPos),true,_side,_faction] call NWG_DSPAWN_SpawnVehicledGroup;
        if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {false};
        [(_spawnResult#SPAWN_RESULT_VEHICLE),(selectRandom _paradropContainer)] call NWG_DSPAWN_ImitateParadrop;
        [(_spawnResult#SPAWN_RESULT_GROUP),_attackPos] call NWG_DSPAWN_SendToAttack;
        true
    };
    private _trySpawnVehGroup = {
        params ["_groupDescr","_spawnPointType"];
        private _spawnPoint = _spawnPointType call _getSpawnPoint;
        if (_spawnPoint isEqualTo false) exitWith {false};
        private _groupToSpawn = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
        private _spawnResult = [_groupToSpawn,_spawnPoint,(_spawnPoint getDir _attackPos),false,_side,_faction] call NWG_DSPAWN_SpawnVehicledGroup;
        if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {false};
        [(_spawnResult#SPAWN_RESULT_GROUP),_attackPos] call NWG_DSPAWN_SendToAttack;
        true
    };

    //Start spawning
    private _resultCount = 0;
    private _attemptsCount = 0;
    private _paradropsLeft = NWG_DSPAWN_Settings get "ATTACK_PARADROPS_MAX";
    private _isParadropAllowed = {
        // _groupDescr = _this;
        _paradropsLeft > 0 &&
        {_paradropContainer isNotEqualTo [] &&
        {"PARADROPPABLE+" in (_this#DESCR_TAGS) &&
        {(random 1) <= (NWG_DSPAWN_Settings get "ATTACK_PARADROPS_CHANCE")}}}
    };

    while {_resultCount < _groupsCount && {_attemptsCount < 100}} do {
        _attemptsCount = _attemptsCount + 1;
        if (_attemptsCount in [50,75,90]) then {(format ["NWG_DSPAWN_REINF_SendReinforcements: Too many attempts for '%1':'%2' at '%3'",_faction,_filter,_attackPos]) call NWG_fnc_logError};

        private _groupDescr = [_groupsContainer,"NWG_DSPAWN_REINF_SendReinforcements"] call NWG_fnc_selectRandomGuaranteed;
        switch (true) do {
            case ("INF" in (_groupDescr#DESCR_TAGS)): {
                if (_groupDescr call _trySpawnInfGroup) then {_resultCount = _resultCount + 1};
            };
            case ("ARM" in (_groupDescr#DESCR_TAGS)): {
                if ([_groupDescr,"VEH"] call _trySpawnVehGroup) then {_resultCount = _resultCount + 1};
            };
            case ("AIR" in (_groupDescr#DESCR_TAGS)): {
                if ([_groupDescr,"AIR"] call _trySpawnVehGroup) then {_resultCount = _resultCount + 1};
            };
            case ("VEH" in (_groupDescr#DESCR_TAGS)): {
                if ((_groupDescr call _isParadropAllowed) && {[_groupDescr,"INF"] call _tryParadropVehGroup}) exitWith {_resultCount = _resultCount + 1; _paradropsLeft = _paradropsLeft - 1};
                if ([_groupDescr,"VEH"] call _trySpawnVehGroup) then {_resultCount = _resultCount + 1};
            };
            case ("BOAT" in (_groupDescr#DESCR_TAGS)): {
                if ((_groupDescr call _isParadropAllowed) && {[_groupDescr,"BOAT"] call _tryParadropVehGroup}) exitWith {_resultCount = _resultCount + 1; _paradropsLeft = _paradropsLeft - 1};
                if ([_groupDescr,"BOAT"] call _trySpawnVehGroup) then {_resultCount = _resultCount + 1};
            };
            default {
                (format ["NWG_DSPAWN_REINF_SendReinforcements: Invalid group tags '%1':'%2'",_faction,_groupDescr]) call NWG_fnc_logError;
            };
        };
    };

    //return
    _resultCount
};

//================================================================================================================
//================================================================================================================
//Single group spawn
NWG_DSPAWN_SpawnSingleGroup = {
    params ["_pos","_radius","_faction",["_filter",[]],["_membership",west],["_skipFinalize",false]];

    //Get catalogue values for spawn
    private _page = _faction call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {
        (format ["NWG_DSPAWN_SpawnSingleGroup: Could not load catalogue page for faction '%1'",_faction]) call NWG_fnc_logError;
        false
    };
    private _passengersContainer = _page#PASSENGERS_CONTAINER;
    private _groupsContainer = [(_page#GROUPS_CONTAINER),_filter] call NWG_DSPAWN_FilterGroups;
    if ((count _groupsContainer) == 0) exitWith {
        (format ["NWG_DSPAWN_SpawnSingleGroup: Filter '%1' for faction '%2' resulted in ZERO groups",_filter,_faction]) call NWG_fnc_logError;
        false
    };

    //Select group
    private _groupDescr = [_groupsContainer,"NWG_DSPAWN_SpawnSingleGroup"] call NWG_fnc_selectRandomGuaranteed;
    _groupDescr = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;

    //Get possible spawn points
    private _spawnPoints = [_pos,_radius,10] call NWG_fnc_dtsGenerateDotsCircle;
    _spawnPoints = switch (true) do {
        case ("AIR" in (_groupDescr#DESCR_TAGS)): {_spawnPoints};
        case ("BOAT" in (_groupDescr#DESCR_TAGS)): {_spawnPoints select {surfaceIsWater _x}};
        default {_spawnPoints select {!(surfaceIsWater _x)}};
    };
    if ((count _spawnPoints) == 0) exitWith {
        (format ["NWG_DSPAWN_SpawnSingleGroup: Could not find any spawn points for '%1':'%2'",_faction,_groupDescr]) call NWG_fnc_logError;
        false
    };

    //Select spawn point
    _spawnPoints = _spawnPoints call NWG_fnc_arrayShuffle;
    private _spawnPoint = selectRandom _spawnPoints;
    if ("AIR" in (_groupDescr#DESCR_TAGS)) then {
        _spawnPoint set [2,(call NWG_fnc_dtsGetAirHeight)];
    };

    //Spawn group
    private _spawnResult = if ("INF" in (_groupDescr#DESCR_TAGS))
        then {[_groupDescr,_spawnPoint,_membership,_faction,_skipFinalize] call NWG_DSPAWN_SpawnInfantryGroup}
        else {[_groupDescr,_spawnPoint,(_spawnPoint getDir _pos),false,_membership,_faction,_skipFinalize] call NWG_DSPAWN_SpawnVehicledGroup};
    if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {
        (format ["NWG_DSPAWN_SpawnSingleGroup: Failed to spawn group '%1':'%2'",_faction,_groupDescr]) call NWG_fnc_logError;
        false
    };

    //return
    _spawnResult
};

//================================================================================================================
//================================================================================================================
//Catalogue read
NWG_DSPAWN_catalogue = createHashMap;
NWG_DSPAWN_GetCataloguePage = {
    // private _pageName = _this;

    //Try load from cache
    private _page = NWG_DSPAWN_catalogue get _this;
    if (!isNil "_page") exitWith {_page};

    //Prepare variables
    private _pageName = _this;
    private _catalogueAddress = NWG_DSPAWN_Settings get "CATALOGUE_ADDRESS";
    private _valid = true;
    private _abort = {
        // private _errorMessage = _this;
        (format [_this,_pageName]) call NWG_fnc_logError;
        NWG_DSPAWN_catalogue set [_pageName,false];
        //return
        false
    };

    //Try load from file
    _page = call ((format["%1\%2.sqf",_catalogueAddress,_pageName]) call NWG_fnc_compile);
    if (isNil "_page") exitWith {"NWG_DSPAWN_GetCataloguePage: Could not load the catalogue page '%1'" call _abort};

    //Validate general format
    _valid = _page isEqualTypeArray [[],[],[]];
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid catalogue page format '%1', must be [[_passengersContainer],[_paradropContainer],[_groupsContainer]]" call _abort};

    //Validate each sub-container
    _page params ["_passengersContainer","_paradropContainer","_groupsContainer"];

    //Passengers
    _valid = _passengersContainer isEqualTypeArray [[],[],[]];
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid passengers container format '%1', must be [[_category1],[_category2],[_category3]]" call _abort};
    {if (!(_x isEqualTypeAll "")) exitWith {_valid = false}} forEach _passengersContainer;
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid passengers container format '%1', each passenger must be a classname" call _abort};

    //Paradrop
    _valid = _paradropContainer isEqualType [];
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid paradrop container format '%1', must be []" call _abort};
    _valid = _paradropContainer isEqualTo [] || {_paradropContainer isEqualTypeAll ""};
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid paradrop container format '%1', each paradrop vehicle must be a classname" call _abort};

    //Groups
    _valid = _groupsContainer isEqualTypeAll [];
    if (!_valid) exitWith {"NWG_DSPAWN_GetCataloguePage: Invalid groups container format '%1', must be [[_group1],[_group2],[_group3],...]" call _abort};

    //Expand groups (multiply by spawn chance (tier))
    private _expanded = [];
    private _maxCount = (NWG_DSPAWN_Settings get "CATALOGUE_MAX_TIER") + 1;
    //do
    {
        for "_i" from 1 to ((_maxCount - (_x#DESCR_TIER)) max 1) do {_expanded pushBack _x};
    } forEach _groupsContainer;/*foreach groupDescr in _groupsContainer*/
    _groupsContainer resize 0;
    _groupsContainer append _expanded;

    //Save and return
    NWG_DSPAWN_catalogue set [_this,_page];
    _page
};

NWG_DSPAWN_FilterGroups = {
    params ["_groupsContainer",["_filter",[]]];
    if (_filter isEqualTo []) exitWith {_groupsContainer};

    _filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];
    if (_tagsWhiteList isEqualTo [] && {_tagsBlackList isEqualTo [] && {_tierWhiteList isEqualTo []}}) exitWith {_groupsContainer};

    //Prepare filtering functions
    private _tagsfilterW = switch (count _tagsWhiteList) do {
        case (0): {{true}};
        case (1): {{(_tagsWhiteList#0) in (_this#DESCR_TAGS)}};
        default {{(count ((_this#DESCR_TAGS) arrayIntersect _tagsWhiteList)) > 0}};
    };
    private _tagsFilterB = switch (count _tagsBlackList) do {
        case (0): {{true}};
        case (1): {{!((_tagsBlackList#0) in (_this#DESCR_TAGS))}};
        default {{(count ((_this#DESCR_TAGS) arrayIntersect _tagsBlackList)) == 0}};
    };
    private _tierFilter = switch (count _tierWhiteList) do {
        case (0): {{true}};
        case (1): {{(_this#DESCR_TIER) == (_tierWhiteList#0)}};
        default {{(_this#DESCR_TIER) in _tierWhiteList}};
    };

    //return
    _groupsContainer select {(_x call _tagsfilterW) && {(_x call _tagsFilterB) && {(_x call _tierFilter)}}}
};

//================================================================================================================
//================================================================================================================
//Group description pre-spawn processing
NWG_DSPAWN_PrepareGroupForSpawn = {
    params ["_groupDescr","_passengersContainer"];
    _groupDescr = _groupDescr + [];//Shallow copy to avoid modifying the original
    private _unitsDescr = _groupDescr#DESCR_UNITS;
    _unitsDescr = _unitsDescr + [];//Shallow copy to avoid modifying the original
    _unitsDescr = _unitsDescr call NWG_fnc_unCompactStringArray;
    _unitsDescr = [_unitsDescr,_passengersContainer] call NWG_DSPAWN_FillWithPassengers;
    _groupDescr set [DESCR_UNITS,_unitsDescr];
    //return
    _groupDescr
};

NWG_DSPAWN_FillWithPassengers = {
    params ["_unitsDescr","_passengersContainer"];

    private _maxCount = {_x isEqualTo "RANDOM"} count _unitsDescr;
    if (_maxCount == 0) exitWith {_unitsDescr};
    private _result = _unitsDescr - ["RANDOM"];

    private _count = if (_maxCount < (count _unitsDescr))
        then {([(round (_maxCount / 2)),(_maxCount + 2)] call NWG_fnc_randomRangeInt) min _maxCount}
        else {_maxCount};//The entire group is random units
    if (_count > 0) then {
        _result append ([_passengersContainer,_count] call NWG_DSPAWN_GeneratePassengers);
    };

    _unitsDescr resize 0;
    _unitsDescr append _result;
    _unitsDescr
};

NWG_DSPAWN_GeneratePassengers = {
    params ["_passengersContainer","_count"];

    private _categoryChances = switch (true) do {
        case (_count <= 2): {
            (_passengersContainer#0) call NWG_fnc_arrayShuffle;
            [0]
        };
        case (_count <= 5): {
            (_passengersContainer#0) call NWG_fnc_arrayShuffle;
            (_passengersContainer#1) call NWG_fnc_arrayShuffle;
            ([0,0,0,1] call NWG_fnc_arrayShuffle)
        };
        default {
            (_passengersContainer#0) call NWG_fnc_arrayShuffle;
            (_passengersContainer#1) call NWG_fnc_arrayShuffle;
            (_passengersContainer#2) call NWG_fnc_arrayShuffle;
            ([0,0,0,0,0,0,1,1,1,2] call NWG_fnc_arrayShuffle)
        };
    };

    private _result = [];
    private ["_category","_array","_passenger"];
    for "_i" from 1 to _count do {
        _category = _categoryChances deleteAt 0;
        _categoryChances pushBack _category;

        _array = (_passengersContainer#_category);
        _passenger = _array deleteAt 0;
        _array pushBack _passenger;
        _result pushBack _passenger;
    };

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Spawn
NWG_DSPAWN_SpawnVehicledGroup = {
    params ["_groupDescr","_pos","_dir",["_deferReveal",false],["_side",west],["_faction",""],["_skipFinalize",false]];

    private _vehicleDescr = _groupDescr#DESCR_VEHICLE;
    _vehicleDescr params ["_vehicleClassname",["_vehicleAppearance",false],["_vehiclePylons",false]];
    private _vehicle = [_vehicleClassname,_pos,_dir,_vehicleAppearance,_vehiclePylons,_deferReveal] call NWG_fnc_spwnSpawnVehicleAround;

    private _unitsDescr = _groupDescr#DESCR_UNITS;
    private _units = [_unitsDescr,_vehicle,_side] call NWG_fnc_spwnSpawnUnitsIntoVehicle;
    private _group = group (_units#0);

    //Fix air vehicles falling down
    if ("AIR" in (_groupDescr#DESCR_TAGS)) then {
        private _curPos = getPosATL _vehicle;
        _vehicle setVehiclePosition [_vehicle,[],0,"FLY"];
        _vehicle setPosATL _curPos;
        _vehicle flyInHeight (_curPos#2);
        if ("PLANE" in (_groupDescr#DESCR_TAGS)) then {
            _vehicle setVelocity [(100*(sin _dir)),(100*(cos _dir)),0];
        } else {
            _vehicle setVelocity [(50*(sin _dir)),(50*(cos _dir)),0];
        };
    };

    //return
    if (_skipFinalize) exitWith {[_group,_vehicle,_units]};
    ([_groupDescr,[_group,_vehicle,_units],_faction] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnInfantryGroup = {
    params ["_groupDescr","_pos",["_side",west],["_faction",""],["_skipFinalize",false]];

    private _unitsDescr = _groupDescr#DESCR_UNITS;
    private _units = [_unitsDescr,_pos,_side] call NWG_fnc_spwnSpawnUnitsAround;
    private _group = group (_units#0);

    //return
    if (_skipFinalize) exitWith {[_group,false,_units]};
    ([_groupDescr,[_group,false,_units],_faction] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnInfantryGroupInBuilding = {
    params ["_groupDescr","_building",["_side",west],["_faction",""],["_skipFinalize",false]];

    private _unitsDescr = _groupDescr#DESCR_UNITS;
    private _units = [_unitsDescr,_building,_side] call NWG_fnc_spwnSpawnUnitsIntoBuilding;
    private _group = group (_units#0);

    //Mark building as occupied
    _building call NWG_fnc_shAddOccupiedBuilding;

    //return
    if (_skipFinalize) exitWith {[_group,false,_units]};
    ([_groupDescr,[_group,false,_units],_faction] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnGroupFinalize = {
    params ["_groupDescr","_spawnResult","_faction"];

    //Run additional code
    private _additionalCode = _groupDescr param [DESCR_ADDITIONAL_CODE,{}];
    _spawnResult call _additionalCode;

    //Save tags
    private _tags = _groupDescr#DESCR_TAGS;
    private _group = _spawnResult#SPAWN_RESULT_GROUP;
    [_group,_tags] call NWG_DSPAWN_TAGs_SetTags;

    //Mark group as spawned by this script
    _group setVariable ["NWG_DSPAWN_ownership",true];

    //Set initial behaviour
    _group setCombatMode "RED";
    _group setFormation (selectRandom ["STAG COLUMN","WEDGE","VEE","DIAMOND"]);

    //Raise event
    private _tier = _groupDescr#DESCR_TIER;
    [EVENT_ON_DSPAWN_GROUP_SPAWNED,(_spawnResult + [_tags,_tier,_faction])] call NWG_fnc_raiseServerEvent;

    //return
    _spawnResult
};

//================================================================================================================
//================================================================================================================
//Additional code post-spawn helpers
NWG_DSPAWN_AC_AttachTurret = {
    params ["_spawnResult","_turretClassname","_attachToValues",["_gunnerClassname","DEFAULT"]];
    _spawnResult params ["_group","_vehicle"/*,"_units"*/];
    _attachToValues params ["_offset","_dirAndUp"];

    //Fix vehicle stucking at place for unknown reason (arma moment)
    if (canSuspend) then {sleep 5};

    //Spawn and attach turret
    private _turret = [_turretClassname,0,0] call NWG_fnc_spwnPrespawnVehicle;
    _turret call NWG_fnc_spwnRevealObject;
    _turret disableCollisionWith _vehicle;
    _turret attachTo [_vehicle,_offset];
    _turret setVectorDirAndUp _dirAndUp;

    //Add gunner
    if (_gunnerClassname isEqualTo "DEFAULT") then {
        _group createVehicleCrew _turret;
        private _gunner = gunner _turret;
        if ((side _gunner) isNotEqualTo (side _group)) then {[_gunner] joinSilent _group};
    } else {
        private _gunner = ([[_gunnerClassname],nil,_group] call NWG_fnc_spwnPrespawnUnits) param [0,objNull];
        _gunner moveInAny _turret;
    };
};

NWG_DSPAWN_AC_DressUnits = {
    params ["_spawnResult","_loadouts"];
    // _spawnResult params ["_group","_vehicle","_units"];
    {[_x,([_loadouts,"DSPAWN_AC_DressUnits"] call NWG_fnc_selectRandomGuaranteed)] call NWG_fnc_setUnitLoadout} forEach (_spawnResult#SPAWN_RESULT_UNITS);
};

//================================================================================================================
//================================================================================================================
//TAGs system
NWG_DSPAWN_TAGs_GetTags = {
    // private _group = _this;
    private _tags = _this getVariable "NWG_DSPAWN_tags";
    if (isNil "_tags") exitWith {[]};//No tags were ever defined for this group - probably spawned by other script

    private _curFingerprint = _this getVariable ["NWG_DSPAWN_fingerprint",""];
    private _newFingerprint = [_this] call NWG_DSPAWN_TAGs_GenerateFingerprint;
    if (_curFingerprint isEqualTo _newFingerprint) exitWith {_tags};//Tags are up to date

    //Tags are outdated - regenerate
    _tags = [_this] call NWG_DSPAWN_TAGs_GenerateTags;
    [_this,_tags,_newFingerprint] call NWG_DSPAWN_TAGs_SetTags;

    //return
    _tags
};

NWG_DSPAWN_TAGs_SetTags = {
    params ["_group","_tags",["_fingerPrint","AUTO"]];
    if (_fingerPrint isEqualTo "AUTO") then {_fingerPrint = [_group] call NWG_DSPAWN_TAGs_GenerateFingerprint};

    _group setVariable ["NWG_DSPAWN_tags",_tags];
    _group setVariable ["NWG_DSPAWN_fingerprint",_fingerPrint];
};

NWG_DSPAWN_TAGs_GenerateFingerprint = {
    params ["_group",["_grpVehicle","AUTO"]];
    if (_grpVehicle isEqualTo "AUTO") then {_grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle};

    //return
    format ["%1_%2",(typeOf _grpVehicle),({alive _x} count (units _group))]
};

NWG_DSPAWN_TAGs_GenerateTags = {
    params ["_group",["_grpVehicle","AUTO"]];
    if (_grpVehicle isEqualTo "AUTO") then {_grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle};
    private _tags = [];
    private _vehicleSimulationType = "";

    //Prime tags -
    private _primeTag = if (!isNull _grpVehicle && {alive _grpVehicle && {_grpVehicle call NWG_fnc_ocIsVehicle}}) then {
        _vehicleSimulationType = tolower (getText(configFile >> "CfgVehicles" >> (typeOf _grpVehicle) >> "simulation"));
        switch (_vehicleSimulationType) do {
            case "carx":    {"VEH"};
            case "tankx":   {"ARM"};
            case "airplanex";
            case "helicopterrtd";
            case "helicopterx": {"AIR"};
            case "shipx":   {"BOAT"};
            case "soldier": {"INF"};//Just in case
            default         {"VEH"};
        }
    } else {"INF"};//Fallback to infantry if no vehicle/destructed/invalid/etc
    _tags pushBack _primeTag;

    //Vehicle tags -
    if (_primeTag isNotEqualTo "INF") then {
        if (_grpVehicle call NWG_fnc_ocIsArmedVehicle)
            then {_tags pushBack "MEC"}
            else {_tags pushBack "MOT"};
    };

    //Air tags -
    if (_primeTag isEqualTo "AIR") then {
        switch (_vehicleSimulationType) do {
            case "airplanex": {_tags pushBack "PLANE"};
            case "helicopterrtd";
            case "helicopterx": {_tags pushBack "HELI"};
        };
    };

    //UAV tags -
    if (_primeTag isNotEqualTo "INF" && {unitIsUAV _grpVehicle}) then {
        _tags pushBack "UAV";
    };

    //Weapon tags -
    if (_primeTag isEqualTo "INF") then {
        _tags append ([_group] call NWG_DSPAWN_TAGs_DefineWeaponTagForGroup);
    } else {
        _tags append ([_group,_grpVehicle] call NWG_DSPAWN_TAGs_DefineWeaponTagForGroup);
    };

    //Vehicle logic -
    if (_primeTag isEqualTo "VEH") then {
        //If vehicle is light enough - it can be paradropped
        if ((getMass _grpVehicle) < 10000) then {_tags pushBack "PARADROPPABLE+"};
    };

    //Air logic -
    if (_primeTag isEqualTo "AIR") then {
        //If there can be passengers - vehicle can disembark them
        if ((count (fullCrew [_grpVehicle,"cargo",true])) > 0) then {
            if ("HELI" in _tags) then {_tags pushBack "LAND+"};//Helicopters can do landing
            _tags pushBack "PARA+";//And all aircrafts can at least do paradrop
        };

        //If there are pylons - vehicle can do airstrike
        if ((count (getPylonMagazines _grpVehicle)) > 0) then {_tags pushBack "AIRSTRIKE+"};
    };

    //return
    _tags
};

NWG_DSPAWN_TAGs_notWeapon = ["Horn","Laserdesignator","CMFlareLauncher","SmokeLauncher"];
NWG_DSPAWN_TAGs_GetVehicleWeapons = {
    // private _vehicle = _this;

    private _result = (fullCrew [_this,"",true]) apply {_x#3};//Get all turrets
    _result = _result apply {_this weaponsTurret _x};//Get all weapons of all turrets
    _result = flatten _result;//Unwrap subarrays
    _result = _result arrayIntersect _result;//Remove duplicates
    private _cur = "";
    _result = _result select {_cur = _x; (NWG_DSPAWN_TAGs_notWeapon findIf {_x in _cur}) == -1};//Filter

    //return
    _result
};

NWG_DSPAWN_TAGs_DefineWeaponTagForGroup = {
    params ["_group",["_grpVehicle",objNull]];

    //Check vehicle for weapon tag (1st priority)
    private _vehTag = if (alive _grpVehicle)
        then {_grpVehicle call NWG_DSPAWN_TAGs_DefineWeaponTagForObject}
        else {"REG"};
    //return if vehicle tag is not REG - group entire tag is defined by its vehicle then
    if (_vehTag isNotEqualTo "REG") exitWith {_vehTag splitString "|"};//"AA|AT" => ["AA","AT"] and "AA" => ["AA"]

    //Check every unit for weapon tag (2nd priority)
    private _unitTags = ((units _group) select {alive _x}) apply {_x call NWG_DSPAWN_TAGs_DefineWeaponTagForObject};
    private _thresholdCount = round ((count _unitTags)*0.5);//50% of units must have the same tag
    //return
    switch (true) do {
        case ((count _unitTags) == 0): {["REG"]};//No units alive, fallback to REG
        case (({_x isEqualTo "AA"} count _unitTags) >= _thresholdCount): {["AA"]};
        case (({_x isEqualTo "AT"} count _unitTags) >= _thresholdCount): {["AT"]};
        default {["REG"]};
    }
};

NWG_DSPAWN_TAGs_aaSigns = [" AA","AA ","air-to-air","surface-to-air"];
NWG_DSPAWN_TAGs_atSigns = [" AT","AT ","air-to-surface","HEAT","APFSDS"];
NWG_DSPAWN_TAGs_magToWeaponTagCache = createHashMap;//Config manipulations are EXTREMELY slow, cache needed (4638/10k VS 10k/10k in tests)
NWG_DSPAWN_TAGs_DefineWeaponTagForObject = {
    // private _object = _this;

    //Check cache
    private _cached = _this getVariable "NWG_DSPAWN_TAGs_cached";
    if (!isNil "_cached") exitWith {_cached};

    //Check artillery
    if (_this call NWG_fnc_ocIsVehicle && {(getArtilleryAmmo [_this]) isNotEqualTo []}) exitWith {
        _this setVariable ["NWG_DSPAWN_TAGs_cached","ARTA"];
        "ARTA"
    };

    //Get all the magazines
    private _mags = if (_this isKindOf "Man")
        then {magazines _this}
        else {(magazinesAllTurrets _this) apply {_x#0}};
    _mags = _mags arrayIntersect _mags;//Remove duplicates

    //Check for AT/AA signs in magazine descriptions
    private ["_cached","_config","_fullDescription"];
    _mags = _mags apply {
        _cached = NWG_DSPAWN_TAGs_magToWeaponTagCache get _x;
        if (!isNil "_cached") then {continueWith _cached};

        _config = configFile >> "CfgMagazines" >> _x;
        if (!isClass _config) then {
            NWG_DSPAWN_TAGs_magToWeaponTagCache set [_x,"REG"];
            continueWith "REG";
        };

        _fullDescription = [
            (getText (_config >> "description")),
            (getText (_config >> "descriptionShort")),
            (getText (_config >> "displayName")),
            (getText (_config >> "displayNameShort"))
        ] joinString " ";

        _cached = switch (true) do {
            case ((NWG_DSPAWN_TAGs_aaSigns findIf {_x in _fullDescription}) != -1): {"AA"};
            case ((NWG_DSPAWN_TAGs_atSigns findIf {_x in _fullDescription}) != -1): {"AT"};
            default {"REG"};
        };

        NWG_DSPAWN_TAGs_magToWeaponTagCache set [_x,_cached];
        _cached
    };

    //Define result
    private _result = if ("AA" in _mags)
        then {if ("AT" in _mags) then {"AA|AT"} else {"AA"}}
        else {if ("AT" in _mags) then {"AT"} else {"REG"}};

    //Cache and return
    _this setVariable ["NWG_DSPAWN_TAGs_cached",_result];
    _result
};

//================================================================================================================
//================================================================================================================
//Waypoints
NWG_DSPAWN_AddWaypoint = {
    params ["_group","_pos",["_type","MOVE"]];

    private _wp = _group addWaypoint [_pos,(NWG_DSPAWN_Settings get "WAYPOINT_RADIUS_PLACE")];
    _wp setWaypointType _type;
    _wp setWaypointCompletionRadius (NWG_DSPAWN_Settings get "WAYPOINT_RADIUS_COMPL");
    //return
    _wp
};

NWG_DSPAWN_ClearWaypoints = {
    // private _group = _this;
    {deleteWaypoint _x} forEachReversed (waypoints _this);
};

//================================================================================================================
//================================================================================================================
//Patrol logic
NWG_DSPAWN_SendToPatrol = {
    params ["_group","_patrolRoute",["_allowSafePatrol",true]];

    //Add new patrol route
    _group call NWG_DSPAWN_ClearWaypoints;
    {[_group,_x] call NWG_DSPAWN_AddWaypoint} forEach _patrolRoute;

    //If not a 'standing patrol'
    if ((count _patrolRoute) > 1) then {
        //Add cycle (repeat)
        [_group,(_patrolRoute#0),"CYCLE"] call NWG_DSPAWN_AddWaypoint;
        //Set 'slow patrolling' behaviour
        if (_allowSafePatrol) then {
            _group setSpeedMode "LIMITED";
            _group setBehaviourStrong "SAFE";
        };
    };

    //Save patrol route for future logic
    _group setVariable ["NWG_DSPAWN_patrolRoute",_patrolRoute];
};

//================================================================================================================
//================================================================================================================
//Position attack logic
NWG_DSPAWN_SendToAttack = {
    params ["_group","_attackPos"];

    //Check if anyone is alive
    if (({alive _x} count (units _group)) == 0) exitWith {};

    //Set combat behaviour
    _group setCombatMode "RED";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Clear waypoints
    _group call NWG_DSPAWN_ClearWaypoints;

    //Get tags
    private _tags = _group call NWG_DSPAWN_TAGs_GetTags;
    if (_tags isEqualTo []) then {_tags = ["INF"]};//Default to INF

    //Logic selection
    private _attackLogic = switch (true) do {
        case ("INF" in _tags): {NWG_DSPAWN_InfAttackLogic};
        case (!alive (_group call NWG_DSPAWN_GetGroupVehicle)): {NWG_DSPAWN_InfAttackLogic};//Fallback to INF (also checks for NULL)
        case ("VEH" in _tags): {NWG_DSPAWN_VehAttackLogic};
        case ("ARM" in _tags): {NWG_DSPAWN_VehAttackLogic};//Just reuse VEH logic
        case ("AIR" in _tags): {NWG_DSPAWN_AirAttackLogic};
        case ("BOAT" in _tags): {NWG_DSPAWN_BoatAttackLogic};
        default {
            (format ["NWG_DSPAWN_SendToAttack: Tags '%1' invalid, fallback to INF",_tags]) call NWG_fnc_logError;
            NWG_DSPAWN_InfAttackLogic
        };
    };

    //Run attack logic
    [_group,_attackPos,_tags] call _attackLogic;
};

/*- Attack logic for INF*/
NWG_DSPAWN_InfAttackLogic = {
    params ["_group","_attackPos"/*,"_tags"*/];
    private _attackRadius = NWG_DSPAWN_Settings get "ATTACK_INF_ATTACK_RADIUS";
    [_group,_attackPos,_attackRadius] call NWG_DSPAWN_CheckThePosition;
};

/*- Attack logic for VEH & ARM*/
NWG_DSPAWN_VehAttackLogic = {
    params ["_group","_attackPos","_tags"];

    //Stand your ground for artillery
    if ("ARTA" in _tags) exitWith {
        doStop (units _group);
        {_x disableAI "PATH"} forEach (units _group);
    };

    //Prepare variables
    private _unloadRadius = NWG_DSPAWN_Settings get "ATTACK_VEH_UNLOAD_RADIUS";
    private _attackRadius = NWG_DSPAWN_Settings get "ATTACK_VEH_ATTACK_RADIUS";

    //Attack with vehicle support
    if ("MEC" in _tags) exitWith {
        private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
        private _grpPassengers = [_group,_grpVehicle] call NWG_DSPAWN_GetGroupPassengers;
        if ((count _grpPassengers) > 0) then {
            private _unloadWp = [_attackPos,_unloadRadius,"ground"] call NWG_fnc_dtsFindDotForWaypoint;
            if (_unloadWp isEqualTo false) exitWith {};
            _unloadWp = [_group,_unloadWp] call NWG_DSPAWN_AddWaypoint;
            _unloadWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_UnloadPassengers}"];
        };

        [_group,_attackPos,_attackRadius] call NWG_DSPAWN_CheckThePosition;
    };

    //Abandon vehicle and attack on foot
    if ("MOT" in _tags) exitWith {
        private _abandonWp = [_attackPos,_unloadRadius,"ground"] call NWG_fnc_dtsFindDotForWaypoint;
        if (_abandonWp isNotEqualTo false) then {
            _abandonWp = [_group,_abandonWp] call NWG_DSPAWN_AddWaypoint;
            _abandonWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_AbandonVehicle}"];
        };

        [_group,_attackPos,_attackRadius] call NWG_DSPAWN_CheckThePosition;
    };

    //Fallback to INF
    (format ["NWG_DSPAWN_VehAttackLogic: Tags '%1' invalid, fallback to INF",_tags]) call NWG_fnc_logError;
    _this call NWG_DSPAWN_InfAttackLogic;
};

/*- Attack logic for AIR*/
NWG_DSPAWN_AirAttackLogic = {
    params ["_group","_attackPos","_tags"];
    private _unloadRadius = NWG_DSPAWN_Settings get "ATTACK_AIR_UNLOAD_RADIUS";
    private _attackRadius = NWG_DSPAWN_Settings get "ATTACK_AIR_ATTACK_RADIUS";
    private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    private _grpPassengers = [_group,_grpVehicle] call NWG_DSPAWN_GetGroupPassengers;

    //Unload passengers if any
    if ((count _grpPassengers) > 0) then {
        private _unloadMethod = switch (true) do {
            case ("LAND+" in _tags && {"PARA+" in _tags}): {selectRandom ["LAND","PARA"]};
            case ("LAND+" in _tags): {"LAND"};
            case ("PARA+" in _tags): {"PARA"};
            default {""};
        };
        if (_unloadMethod isEqualTo "") exitWith {};

        private _unloadWp = [_attackPos,_unloadRadius,"ground"] call NWG_fnc_dtsFindDotForWaypoint;
        if (_unloadWp isEqualTo false) exitWith {};

        _group setVariable ["NWG_DSPAWN_attackPos",_attackPos];//Save for later use in NWG_DSPAWN_UnloadAirPassengers
        _unloadWp = [_group,_unloadWp] call NWG_DSPAWN_AddWaypoint;
        _unloadWp setWaypointStatements ["true", (format ["if (local this) then {[this,'%1'] call NWG_DSPAWN_UnloadAirPassengers}",_unloadMethod])];
    };

    //Attack the given position
    if ("MEC" in _tags) exitWith {
        [_group,_attackPos,_attackRadius,"air"] call NWG_DSPAWN_CheckThePosition;
    };

    //Flee from combat after passengers are unloaded
    if ("MOT" in _tags) exitWith {
        {_x setCombatBehaviour "CARELESS"} forEach ((units _group) - _grpPassengers);
        private _despawnRadius = NWG_DSPAWN_Settings get "ATTACK_AIR_DESPAWN_RADIUS";
        private _fleeWp = [_attackPos,_despawnRadius,"air"] call NWG_fnc_dtsFindDotForWaypoint;
        if (_fleeWp isEqualTo false) exitWith {};
        _fleeWp = [_group,_fleeWp] call NWG_DSPAWN_AddWaypoint;
        _fleeWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_DeleteAirMotGroup}"];
    };

    //Fallback to INF
    (format ["NWG_DSPAWN_AirAttackLogic: Tags '%1' invalid, fallback to INF",_tags]) call NWG_fnc_logError;
    _this call NWG_DSPAWN_InfAttackLogic;
};

/*- Attack logic for BOAT*/
NWG_DSPAWN_BoatAttackLogic = {
    params ["_group","_attackPos","_tags"];
    private _unloadRadius = NWG_DSPAWN_Settings get "ATTACK_BOAT_UNLOAD_RADIUS";
    private _attackRadius = NWG_DSPAWN_Settings get "ATTACK_BOAT_ATTACK_RADIUS";

    //Gunboat attack from water
    if ("MEC" in _tags) exitWith {
        [_group,_attackPos,_attackRadius,"water"] call NWG_DSPAWN_CheckThePosition;
    };

    //Abandon the boat ashore and attack on foot
    if ("MOT" in _tags) exitWith {
        private _abandonWp = [_attackPos,_unloadRadius,"shore"] call NWG_fnc_dtsFindDotForWaypoint;
        if (_abandonWp isNotEqualTo false) then {
            _abandonWp = [_group,_abandonWp] call NWG_DSPAWN_AddWaypoint;
            _abandonWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_AbandonVehicle}"];
        };

        [_group,_attackPos,_attackRadius,"ground"] call NWG_DSPAWN_CheckThePosition;
    };

    //Fallback to INF
    (format ["NWG_DSPAWN_BoatAttackLogic: Tags '%1' invalid, fallback to INF",_tags]) call NWG_fnc_logError;
    _this call NWG_DSPAWN_InfAttackLogic;
};

/*Utils*/
NWG_DSPAWN_CheckThePosition = {
    params ["_group","_attackPos","_radius",["_type","ground"]];

    private _checkRoute = [
        ([_attackPos,_radius,_type] call NWG_fnc_dtsFindDotForWaypoint),
        ([_attackPos,(round (_radius * 0.33)),_type] call NWG_fnc_dtsFindDotForWaypoint)
    ] select {_x isNotEqualTo false};

    if ((count _checkRoute) >= 2) then {
        [_group,(_checkRoute deleteAt 0)] call NWG_DSPAWN_AddWaypoint;
    };
    if ((count _checkRoute) >= 1) then {
        private _finalWp = [_group,(_checkRoute deleteAt 0),"SAD"] call NWG_DSPAWN_AddWaypoint;
        _finalWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_ReturnToPatrol}"];
    };
};

NWG_DSPAWN_ReturnToPatrol = {
    // private _groupLeader = _this;
    private _group = group _this;

    //Clear current waypoints
    _group call NWG_DSPAWN_ClearWaypoints;

    //Get or generate the patrol route
    private _patrolRoute = _group getVariable ["NWG_DSPAWN_patrolRoute",[]];
    if (_patrolRoute isEqualTo []) then {
        private _trigger = NWG_DSPAWN_TRIGGER_lastPopulatedTrigger;
        if (_trigger isEqualTo []) exitWith {};
        private _tags = _group call NWG_DSPAWN_TAGs_GetTags;
        if (_tags isEqualTo []) then {_tags = ["INF"]};//Default to INF
        private _type = switch (true) do {
            case ("AIR" in _tags): {"air"};
            case ("BOAT" in _tags): {"water"};
            default {"ground"};
        };
        _patrolRoute = [_trigger,_type,3] call NWG_fnc_dtsGenerateSimplePatrol;
        if (_patrolRoute isEqualTo false) exitWith {
            (format ["NWG_DSPAWN_ReturnToPatrol: Could not generate patrol route for group '%1'",_group]) call NWG_fnc_logError;
            _patrolRoute = [];
        };
        _group setVariable ["NWG_DSPAWN_patrolRoute",_patrolRoute];
    };
    if (_patrolRoute isEqualTo []) exitWith {};//No patrol route found/generated

    //Get back into abandoned vehicle if any
    private _abandonedVeh = _group getVariable ["NWG_DSPAWN_abandonedVehicle",objNull];
    if (!isNull _abandonedVeh && {alive _abandonedVeh}) then {
        private _units = (units _group) select {alive _x};
        private _crew = (crew _abandonedVeh) select {alive _x};
        //Check that there is someone to board
        private _toBoard = _units - _crew;
        if ((count _toBoard) == 0) exitWith {};//No one to board
        //Check that vehicle is not occupied by someone else
        if (_crew isNotEqualTo [] && {(_crew findIf {_x in _units}) == -1}) exitWith {};//Vehicle is occupied by someone else

        _group addVehicle _abandonedVeh;
        _toBoard allowGetIn true;
        _toBoard orderGetIn true;
    };

    //Send group to patrol
    [_group,_patrolRoute,false] call NWG_DSPAWN_SendToPatrol;
};

NWG_DSPAWN_GetGroupVehicle = {
    // private _group = _this;
    if (isNull _this) exitWith {objNull};
    private _array = [(leader _this)] + (units _this);//Start with the leader, always
    _array = _array apply {vehicle _x};//Get vehicles
    _array = _array arrayIntersect _array;//Remove duplicates
    private _i = _array findIf {(alive _x && {(_x call NWG_fnc_ocIsVehicle)})};
    //return
    _array param [_i,objNull]
};

NWG_DSPAWN_GetGroupPassengers = {
    params ["_group","_grpVehicle"];

    if (isNull _grpVehicle || {!alive _grpVehicle}) exitWith {[]};

    //return
    ((((fullCrew [_grpVehicle,"",false])
        select {(_x#2) >= 0})
        apply {_x#0})
        select {alive _x && {(group _x) isEqualTo _group}})
};

NWG_DSPAWN_AbandonVehicle = {
    // private _groupLeader = _this;
    private _group = group _this;
    private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    if (isNull _grpVehicle) exitWith {};

    _group leaveVehicle _grpVehicle;

    private _toDisembark = ((crew _grpVehicle) arrayIntersect (units _group)) select {alive _x};
    if ((count _toDisembark) > 5) then {
        //Leave with a delay to decrease stupidness (fix large groups getting stuck in the air)
        [_toDisembark,_grpVehicle] spawn {
            params ["_toDisembark","_grpVehicle"];
            {_x moveOut _grpVehicle; unassignVehicle _x; sleep ((random 0.3)+0.1)} forEach _toDisembark;
        };
    } else {
        //Leave immediately
        {_x moveOut _grpVehicle; unassignVehicle _x} forEach _toDisembark;
    };

    _grpVehicle engineOn false;
    _group setVariable ["NWG_DSPAWN_abandonedVehicle",_grpVehicle];
};

NWG_DSPAWN_UnloadPassengers = {
    // private _groupLeader = _this;
    private _group = group _this;
    private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    if (isNull _grpVehicle) exitWith {};

    private _passengers = [_group,_grpVehicle] call NWG_DSPAWN_GetGroupPassengers;
    if ((count _passengers) == 0) exitWith {};

    _passengers orderGetIn false;
    {_x moveOut _grpVehicle; unassignVehicle _x} forEach _passengers;
    _passengers allowGetIn false;
};

NWG_DSPAWN_UnloadAirPassengers = {
    params ["_groupLeader","_unloadMethod"];
    private _group = group _groupLeader;
    private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    if (isNull _grpVehicle) exitWith {};//Is the vehicle destroyed?
    private _grpPassengers = [_group,_grpVehicle] call NWG_DSPAWN_GetGroupPassengers;
    if ((count _grpPassengers) == 0) exitWith {};//Did they die along the way?
    private _attackPos = _group getVariable "NWG_DSPAWN_attackPos";//Load previously saved attack position
    if (isNil "_attackPos") exitWith {
        (format ["NWG_DSPAWN_UnloadAirPassengers: Group '%1' has no attack position",_group]) call NWG_fnc_logError;
    };

    private _secondaryGroup = createGroup [(side _group),/*delete when empty:*/true];
    _grpPassengers joinSilent _secondaryGroup;

    //Add tags to secondary group manually
    [_secondaryGroup,
        ([_secondaryGroup,objNull] call NWG_DSPAWN_TAGs_GenerateTags),
        ([_secondaryGroup,objNull] call NWG_DSPAWN_TAGs_GenerateFingerprint)
    ] call NWG_DSPAWN_TAGs_SetTags;

    [_group,_secondaryGroup,_grpVehicle,_unloadMethod,_attackPos] spawn {
        params ["_group","_secondaryGroup","_grpVehicle","_unloadMethod","_attackPos"];
        private _abortCondition = {isNull _group || {isNull _secondaryGroup || {!alive _grpVehicle}}};
        if (call _abortCondition) exitWith {};

        switch (_unloadMethod) do {
            case "LAND": {
                //Land
                _grpVehicle land "LAND";
                waitUntil {
                    sleep 1;
                    if (call _abortCondition) exitWith {true};
                    ((getPos _grpVehicle)#2) < 1
                };
                if (call _abortCondition) exitWith {};

                //Unload passengers
                {_x moveOut _grpVehicle; unassignVehicle _x} forEach ((units _secondaryGroup) select {alive _x});
                _secondaryGroup leaveVehicle _grpVehicle;
            };
            case "PARA": {
                //Paradrop
                {
                    sleep ((random 1) + 0.25);
                    if (call _abortCondition) exitWith {};
                    if (!alive _x) then {continue};
                    removeBackpack _x;
                    _x addBackpack "B_parachute";
                    _x disableCollisionWith _grpVehicle;
                    _x moveOut _grpVehicle;
                    unassignVehicle _x;
                    _x setVelocity [-20,-15,-15];
                } forEach ((units _secondaryGroup) select {alive _x});
                if (call _abortCondition) exitWith {};
                _secondaryGroup leaveVehicle _grpVehicle;
            };
            default {
                (format ["NWG_DSPAWN_UnloadAirPassengers: Invalid unload method '%1'",_unloadMethod]) call NWG_fnc_logError;
            };
        };
        if (call _abortCondition) exitWith {};

        //Fix pilots stucking in one place
        _group leaveVehicle _grpVehicle;
        {_x disableCollisionWith _grpVehicle; _x moveOut _grpVehicle} forEach ((units _group) select {alive _x});
        _grpVehicle engineOn true;
        _group addVehicle _grpVehicle;
        {_x moveInAny _grpVehicle} forEach ((units _group) select {alive _x});

        //Send secondary group to attack
        [_secondaryGroup,_attackPos] call NWG_DSPAWN_SendToAttack;
    };
};

NWG_DSPAWN_DeleteAirMotGroup = {
    // private _groupLeader = _this;
    private _group = group _this;
    private _vehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    _group call NWG_DSPAWN_ClearWaypoints;

    //Delete units
    {
        if ((vehicle _x) isNotEqualTo _x)
            then {(vehicle _x) deleteVehicleCrew _x}
            else {deleteVehicle _x};
    } forEach (units _group);

    //Delete vehicle
    if (!isNull _vehicle && {alive _vehicle}) then {
        deleteVehicle _vehicle;
    };

    //Delete group
    deleteGroup _group;
};

//================================================================================================================
//================================================================================================================
//Target destruction logic
NWG_DSPAWN_SendToDestroy = {
    params ["_group","_target"];

    //Check if anyone is alive
    if (({alive _x} count (units _group)) == 0) exitWith {};

    //Set combat behaviour
    _group setCombatMode "RED";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Clear waypoints
    _group call NWG_DSPAWN_ClearWaypoints;

    //Reveal target
    _group reveal _target;

    //Add 'DESTROY' waypoint
    private _wp1 = _group addWaypoint [_target,-1];
    _wp1 waypointAttachObject _target;
    _wp1 setWaypointType "DESTROY";

    //Add returning waypoint
    private _groupPos = getPosASL (vehicle (leader _group));
    _groupPos = ASLToAGL _groupPos;
    private _wp2 = [_group,_groupPos] call NWG_DSPAWN_AddWaypoint;
    _wp2 setWaypointStatements ["true","if (local this) then {this call NWG_DSPAWN_ReturnToPatrol}"];
};

//================================================================================================================
//================================================================================================================
//Paradrop
NWG_DSPAWN_currentlyParadropping = [];
NWG_DSPAWN_ImitateParadrop = {
    params ["_object","_paradropBy"];

    //Get points to spawn paradropping vehicle
    private _paradropRadius = NWG_DSPAWN_Settings get "PARADROP_RADIUS";
    private _paradropHeight = NWG_DSPAWN_Settings get "PARADROP_HEIGHT";
    private _paradropPoints = [(getPosATL _object),_paradropRadius,2] call NWG_fnc_dtsGenerateDotsCircle;
    _paradropPoints = _paradropPoints call NWG_fnc_arrayShuffle;
    {_x set [2,_paradropHeight]} forEach _paradropPoints;
    _paradropPoints params ["_paraFrom","_paraTo"];

    //Spawn paradrop group
    private _groupDescr = [["AIR","MOT","PLANE"],1,[_paradropBy],(_paradropBy call NWG_fnc_spwnGetOriginalCrew)];
    private _spawnResult = [_groupDescr,_paraFrom,(_paraFrom getDir _paraTo),false,civilian,"CIV",true] call NWG_DSPAWN_SpawnVehicledGroup;
    if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {
        (format ["NWG_DSPAWN_ImitateParadrop: Could not spawn paradrop group '%1'",_groupDescr]) call NWG_fnc_logError;
        _object call NWG_fnc_spwnRevealObject;
    };
    _spawnResult params ["_paradropGroup","_paradropVehicle"];

    //Set paradrop group behaviour
    _paradropGroup setBehaviourStrong "CARELESS";
    _paradropGroup setCombatBehaviour "CARELESS";
    _paradropVehicle allowDamage false;
    _paradropVehicle flyInHeight _paradropHeight;
    {_x allowDamage false} forEach (units _paradropGroup);

    //Set paradrop group destination
    private _objectPos = getPosATL _object;
    private _wp1 = _paradropGroup addWaypoint [[(_objectPos#0),(_objectPos#1),_paradropHeight],-1];
    _wp1 setWaypointType "MOVE";
    _wp1 setWaypointCompletionRadius 25;
    private _wp2 = _paradropGroup addWaypoint [_paraTo,-1];
    _wp2 setWaypointType "MOVE";
    _wp2 setWaypointCompletionRadius 50;
    _wp2 setWaypointStatements ["true","if (local this) then {this call NWG_DSPAWN_DeleteParadropGroup}"];

    //Disable collisions to prevent accidental damage
    _paradropVehicle disableCollisionWith _object;
    NWG_DSPAWN_currentlyParadropping = NWG_DSPAWN_currentlyParadropping select {alive _x};
    {_paradropVehicle disableCollisionWith _x} forEach NWG_DSPAWN_currentlyParadropping;
    NWG_DSPAWN_currentlyParadropping pushBackUnique _paradropVehicle;

    //Start paradrop
    [_object,_paradropVehicle,_paradropGroup] spawn {
        params ["_object","_paradropVehicle","_paradropGroup"];

        private _timeOut = time + (NWG_DSPAWN_Settings get "PARADROP_TIMEOUT");
        private _cancel = {
            _object call NWG_fnc_spwnRevealObject;
            if (!isNull _paradropGroup) then {(leader _paradropGroup) call NWG_DSPAWN_DeleteParadropGroup};
        };

        //Wait for paradrop vehicle to get close
        waitUntil {
            sleep 0.1;
            ((_paradropVehicle distance2D _object) < 30) || {!(alive _paradropVehicle) || {time > _timeOut}}
        };
        if (!(alive _paradropVehicle) || {time > _timeOut}) exitWith _cancel;

        //Wait for paradrop vehicle to leave the area
        waitUntil {
            sleep 0.1;
            ((_paradropVehicle distance2D _object) > 35) || {!(alive _paradropVehicle) || {time > _timeOut}}
        };
        if (!(alive _paradropVehicle) || {time > _timeOut}) exitWith _cancel;

        //Move vehicle to the sky
        private _pos = getPosATL _object;
        _pos set [2,(NWG_DSPAWN_Settings get "PARADROP_HEIGHT")];
        _object setPosATL _pos;

        //Deploy the parachute
        private _para = createVehicle ["B_parachute_02_F",_object,[],0,"FLY"];
        _para setDir (getDir _object);
        _para setPosATL (getPosATL _object);
        _object attachTo [_para,[0,2,0]];
        _object call NWG_fnc_spwnRevealObject;
        _para setVelocity [0,0,-100];

        //Wait for landing
        private _paraVel = velocity _para;
        waitUntil {
            sleep 0.1;
            if (!(alive _object) || {!(alive _para) || {((getPos _object)#2) < 3}}) exitWith {true};

            //Fix parachute drifting
            _paraVel = velocity _para;
            if ((_paraVel#0) != 0 || {(_paraVel#1) != 0}) then {_para setVelocity [0,0,((_paraVel#2)*1.2)]};

            //Go to next iteration
            false
        };

        //Check if eliminated mid-air
        if (!(alive _object)) exitWith {
            if (!isNull _object) then {detach _object};
            deleteVehicle _para;
        };

        //Land
        private _vel = velocity _object;
        detach _object;
        _object disableCollisionWith _para;
        _object setVelocity _vel;

        //Repair vehicle
        sleep 1;
        _object setDamage 0;//Fix for paradropping planes and helicopters - too fragile

        //Delete parachute
        sleep 2;
        deleteVehicle _para;
    };
};

NWG_DSPAWN_DeleteParadropGroup = {
    // private _groupLeader = _this;
    private _group = group _this;
    _group call NWG_DSPAWN_ClearWaypoints;

    private _vehicle = vehicle _this;
    NWG_DSPAWN_currentlyParadropping deleteAt (NWG_DSPAWN_currentlyParadropping find _vehicle);
    {_vehicle deleteVehicleCrew _x} forEach (crew _vehicle);
    deleteVehicle _vehicle;
    deleteGroup _group;
};