#include "dspawnDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DSPAWN_Settings = createHashMapFromArray [
    ["CATALOGUE_ADDRESS","DATASETS\Server\Dspawn"],
    ["TRIGGER_POPULATION_DISTRIBUTION",[5,3,1,1,1]],//Default population as INF/VEH/ARM/AIR/BOAT
    ["TRIGGER_MAX_BUILDINGS_TO_OCCUPY",5],//Max number of buildings that dspawn will try to occupy with 'ambush' infantry forces
    ["TRIGGER_INF_BUILDINGS_DYNAMIC_SIMULATION",false],//If true - infantry spawned in buildings will act only when players are nearby
    ["TRIGGER_INF_BUILDINGS_DISABLE_PATH",false],//If true - infantry spawned in buildings will not leave their positions, becoming static enemies
    ["WAYPOINT_RADIUS",25],//Default radius for any waypoint-related logic, the more - the easier for big vehicles and complicated terrains

    ["PARADROP_RADIUS",3000],//Radius for paradrop vehicle to spawn, fly by and despawn
    ["PARADROP_HEIGHT",200],//Height of paradropping
    ["PARADROP_TIMEOUT",90],//Timeout to auto-cancel paradrop in case of an error

    ["ATTACK_INF_ATTACK_RADIUS",100],//Radius for INF group to 'attack' the position
    ["ATTACK_VEH_UNLOAD_RADIUS",150],//Radius for VEH group to unload passengers
    ["ATTACK_VEH_ATTACK_RADIUS",100],//Radius for VEH group to 'attack' the position
    ["ATTACK_AIR_UNLOAD_RADIUS",150],//Radius for AIR group to unload passengers
    ["ATTACK_AIR_ATTACK_RADIUS",200],//Radius for AIR group to 'attack' the position
    ["ATTACK_AIR_DESPAWN_RADIUS",3000],//Radius for AIR vehicle to despawn after unload
    ["ATTACK_BOAT_UNLOAD_RADIUS",150],//Radius for BOAT group to unload passengers
    ["ATTACK_BOAT_ATTACK_RADIUS",100],//Radius for BOAT group to 'attack' the position

    ["",0]
];

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

NWG_DSPAWN_TRIGGER_lastPopulatedTrigger = [];
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
        ((_spawnMap#0)+(_spawnMap#1)),//_plains + _roads
        (_spawnMap#2),//_water
        (_spawnMap#3),//_roadsAway
        (_spawnMap#4),//_locations
        (_spawnMap#5)//_air
    ];
    private _spawnPointsPointers = [0,0,0,0,0];

    //Calculate trigger population distribution
    private _population = [_groupsCount,_filter] call NWG_DSPAWN_TRIGGER_CalculatePopulationDistribution;
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
                private _p3 = selectRandom _patrolPoints;
                while {_p3 isEqualTo _p1 || {_p3 isEqualTo _p2}} do {_p3 = selectRandom _patrolPoints};
                [_p1,_p2,_p3]
            }};
        };
        private _spawnSelected = switch (true) do {
            case (_groupsIndex == G_INDEX_INF): {{
                [_groupToSpawn,(_patrolRoute#0)] call NWG_DSPAWN_SpawnInfantryGroup
            }};
            case (_patrolLength == 1): {{
                [_groupToSpawn,(_patrolRoute#0),(random 360)] call NWG_DSPAWN_SpawnVehicledGroup
            }};
            default /*!INF && _patrolLength > 1*/ {{
                private _dir = if ((count _patrolRoute)>1) then {(_patrolRoute#0) getDir (_patrolRoute#1)} else {random 360};
                [_groupToSpawn,(_patrolRoute#0),_dir] call NWG_DSPAWN_SpawnVehicledGroup
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
            [(_spawnResult#0),_patrolRoute] call NWG_DSPAWN_SendToPatrol;
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
                private _p3 = selectRandom _ground;
                while {_p3 isEqualTo _p2} do {_p3 = selectRandom _ground};
                _patrolRoute pushBack _p3;
            };
            _patrolRoute = _patrolRoute call NWG_fnc_arrayShuffle;
            private _groupToSpawn = [G_INDEX_INF,_groups,_groupsPointers] call _getNext;
            _groupToSpawn = [_groupToSpawn,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
            private _spawnResult = [_groupToSpawn,(_patrolRoute#0)] call NWG_DSPAWN_SpawnInfantryGroup;
            if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) then {continue};
            [(_spawnResult#0),_patrolRoute] call NWG_DSPAWN_SendToPatrol;
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
            private _spawnResult = [_groupToSpawn,_x] call NWG_DSPAWN_SpawnInfantryGroupInBuilding;
            if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) then {continue};
            _resultCount = _resultCount + 1;
            (_spawnResult#0) call _dynamicIfNeeded;
            (_spawnResult#0) call _disablePathIfNeeded;
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

        if (!("INF" in _set)) then {_result set [0,0]};
        if (!("VEH" in _set)) then {_result set [1,0]};
        if (!("ARM" in _set)) then {_result set [2,0]};
        if (!("AIR" in _set)) then {_result set [3,0]};
        if (!("BOAT" in _set)) then {_result set [4,0]};

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

    //return
    (_triggerPos nearObjects _triggerRad) select {
        switch (true) do {
            case (!(_x call NWG_fnc_ocIsBuilding)): {false};
            case ((count (_x buildingPos -1)) < 4): {false};
            case (_x call NWG_STHLD_IsBuildingOccupied): {false};
            default {true};
        };
    };
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
    //do
    {
        switch (_x#DESCR_TIER) do {
            case (1): {
                _expanded pushBack _x;
                _expanded pushBack _x;
                _expanded pushBack _x;
            };
            case (2): {
                _expanded pushBack _x;
                _expanded pushBack _x;
            };
            case (3): {
                _expanded pushBack _x;
            };
            default {
                (format ["NWG_DSPAWN_GetCataloguePage: Invalid group tier '%1':'%2'",_pageName,_x]) call NWG_fnc_logError;
            };
        };
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
    private _tagsfilterW = if (_tagsWhiteList isNotEqualTo [])
        then {{(count ((_this#DESCR_TAGS) arrayIntersect _tagsWhiteList)) > 0}}
        else {{true}};
    private _tagsFilterB = if (_tagsBlackList isNotEqualTo [])
        then {{(count ((_this#DESCR_TAGS) arrayIntersect _tagsBlackList)) == 0}}
        else {{true}};
    private _tierFilter = if (_tierWhiteList isNotEqualTo [])
        then {{(_this#DESCR_TIER) in _tierWhiteList}}
        else {{true}};

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
    _unitsDescr = _unitsDescr call NWG_DSPAWN_UnCompactStringArray;
    _unitsDescr = [_unitsDescr,_passengersContainer] call NWG_DSPAWN_FillWithPassengers;
    _groupDescr set [DESCR_UNITS,_unitsDescr];
    //return
    _groupDescr
};

NWG_DSPAWN_UnCompactStringArray = {
    // private _array = _this;
    private _result = [];
    private _count = 1;

    //do
    {
        if (_x isEqualType 0) then {
            _count = _x;
        } else {
            for "_i" from 1 to _count do {_result pushBack _x};
            _count = 1;
        };
    } forEach _this;

    //return
    _this resize 0;
    _this append _result;
    _this
};

NWG_DSPAWN_FillWithPassengers = {
    params ["_unitsDescr","_passengersContainer"];

    private _maxCount = {_x isEqualTo "RANDOM"} count _unitsDescr;
    if (_maxCount == 0) exitWith {_unitsDescr};
    private _result = _unitsDescr - ["RANDOM"];

    private _count = if (_maxCount < 3)
        then {round (random _maxCount)}//0-2
        else {_maxCount - (round (random (_maxCount*0.33)))};//66%-100%
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
    params ["_groupDescr","_pos","_dir",["_deferReveal",false],["_side", west]];

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
    ([_groupDescr,[_group,_vehicle,_units]] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnInfantryGroup = {
    params ["_groupDescr","_pos",["_side", west]];

    private _unitsDescr = _groupDescr#DESCR_UNITS;
    private _units = [_unitsDescr,_pos,_side] call NWG_fnc_spwnSpawnUnitsAround;
    private _group = group (_units#0);

    //return
    ([_groupDescr,[_group,false,_units]] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnInfantryGroupInBuilding = {
    params ["_groupDescr","_building",["_side", west]];

    private _unitsDescr = _groupDescr#DESCR_UNITS;
    private _units = [_unitsDescr,_building,_side] call NWG_fnc_spwnSpawnUnitsIntoBuilding;
    private _group = group (_units#0);

    //Mark building as occupied
    _building call NWG_fnc_shMarkBuildingOccupied;

    //return
    ([_groupDescr,[_group,false,_units]] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnGroupFinalize = {
    params ["_groupDescr","_spawnResult"];

    //Run additional code
    private _additionalCode = _groupDescr param [DESCR_ADDITIONAL_CODE,{}];
    _spawnResult call _additionalCode;

    //Save tags
    private _tags = _groupDescr#DESCR_TAGS;
    private _group = _spawnResult#0;
    _group setVariable ["NWG_DSPAWN_tags",_tags];

    //Set initial behaviour
    _group setCombatMode "RED";
    _group setFormation (selectRandom ["STAG COLUMN","WEDGE","VEE","DIAMOND"]);

    //return
    _spawnResult
};

//================================================================================================================
//================================================================================================================
//Additional code post-spawn helpers
NWG_DSPAWN_AC_AttachTurret = {
    params ["_group","_vehicle","_NaN","_turretClassname","_attachToValues",["_gunnerClassname","DEFAULT"]];
    _attachToValues params ["_offset","_dirAndUp"];

    //Spawn and attach turret
    private _turret = [_turretClassname,0,0] call NWG_fnc_spwnPrespawnVehicle;
    _turret call NWG_fnc_spwnRevealObject;
    _turret disableCollisionWith _vehicle;
    _turret attachTo [_vehicle,_offset];
    _turret setVectorDirAndUp _dirAndUp;

    //Add gunner
    private _gunner = objNull;
    if (_gunner isEqualTo "DEFAULT") then {
        _group createVehicleCrew _turret;
        _gunner = gunner _turret;
        if ((side _gunner) isNotEqualTo (side _group)) then {[_gunner] joinSilent _group};
    } else {
        _gunner = ([[_gunnerClassname],"_NaN",(side _group)] call NWG_fnc_spwnPrespawnUnits)#0;
        _gunner call NWG_fnc_spwnRevealObject;
        _gunner moveInAny _turret;
    };
};

//================================================================================================================
//================================================================================================================
//TAGs system
NWG_DSPAWN_GetTags = {
    // private _group = _this;
    //return
    _this getVariable ["NWG_DSPAWN_tags",[]]
};

NWG_DSPAWN_SetTags = {
    params ["_group","_tags"];
    _group setVariable ["NWG_DSPAWN_tags",_tags];
};

//================================================================================================================
//================================================================================================================
//Waypoints
NWG_DSPAWN_AddWaypoint = {
    params ["_group","_pos",["_type","MOVE"]];

    if (!surfaceIsWater _pos) then {_pos = ATLToASL _pos};
    private _wp = _group addWaypoint [_pos,-1];
    _wp setWaypointType _type;
    _wp setWaypointCompletionRadius (NWG_DSPAWN_Settings get "WAYPOINT_RADIUS");
    //return
    _wp
};

NWG_DSPAWN_ClearWaypoints = {
    // private _group = _this;
    for "_i" from ((count (waypoints _this)) - 1) to 0 step -1 do {
        deleteWaypoint [_this, _i];
    };
};

//================================================================================================================
//================================================================================================================
//Patrol logic
NWG_DSPAWN_SendToPatrol = {
    params ["_group","_patrolRoute"];

    //Add new patrol route
    _group call NWG_DSPAWN_ClearWaypoints;
    {[_group,_x] call NWG_DSPAWN_AddWaypoint} forEach _patrolRoute;

    //If not a 'standing patrol'
    if ((count _patrolRoute) > 1) then {
        //Add cycle (repeat)
        [_group,(_patrolRoute#0),"CYCLE"] call NWG_DSPAWN_AddWaypoint;
        //Set 'slow patrolling' behaviour
        _group setSpeedMode "LIMITED";
        _group setBehaviourStrong "SAFE";
    };

    //Save patrol route for future logic
    _group setVariable ["NWG_DSPAWN_patrolRoute",_patrolRoute];
};

//================================================================================================================
//================================================================================================================
//Attack logic
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
    private _tags = _group call NWG_DSPAWN_GetTags;
    if (_tags isEqualTo []) then {_tags = ["INF"]};//Default to INF

    //Logic selection
    private _attackLogic = switch (true) do {
        case ("INF" in _tags): {NWG_DSPAWN_InfAttackLogic};
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

    private _grpVehicle = _group call NWG_DSPAWN_GetGroupVehicle;
    if (isNull _grpVehicle) exitWith {_this call NWG_DSPAWN_InfAttackLogic};//Fallback to INF

    private _subType = if ("MEC" in _tags) then {"MEC"} else {"MOT"};
    private _unloadRadius = NWG_DSPAWN_Settings get "ATTACK_VEH_UNLOAD_RADIUS";
    private _attackRadius = NWG_DSPAWN_Settings get "ATTACK_VEH_ATTACK_RADIUS";

    //Attack with vehicle support
    if (_subType isEqualTo "MEC") exitWith {
        //Separate passengers from vehicle if any
        private _grpPassengers = [_group,_grpVehicle] call NWG_DSPAWN_GetGroupPassengers;
        if ((count _grpPassengers) > 0) then {
            private _unloadWp = [_attackPos,_unloadRadius,"ground"] call NWG_fnc_dtsFindDotForWaypoint;
            if (_unloadWp isEqualTo false) exitWith {};
            _unloadWp = [_group,_unloadWp] call NWG_DSPAWN_AddWaypoint;
            _unloadWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_UnloadPassengers}"];
        };

        //Send to attack
        [_group,_attackPos,_attackRadius] call NWG_DSPAWN_CheckThePosition;
    };

    //Abandon vehicle and attack on foot
    if (_subType isEqualTo "MOT") exitWith {
        //Abandon vehicle
        private _abandonWp = [_attackPos,_unloadRadius,"ground"] call NWG_fnc_dtsFindDotForWaypoint;
        if (_abandonWp isNotEqualTo false) then {
            _abandonWp = [_group,_abandonWp] call NWG_DSPAWN_AddWaypoint;
            _abandonWp setWaypointStatements ["true", "if (local this) then {this call NWG_DSPAWN_AbandonVehicle}"];
        };

        //Send to attack
        [_group,_attackPos,_attackRadius] call NWG_DSPAWN_CheckThePosition;
    };
};

/*- Attack logic for AIR*/
NWG_DSPAWN_AirAttackLogic = {
    //TODO
    systemChat "Air attack logic not implemented yet";
};

/*- Attack logic for BOAT*/
NWG_DSPAWN_BoatAttackLogic = {
    //TODO
    systemChat "Boat attack logic not implemented yet";
};

/*Utils*/
NWG_DSPAWN_CheckThePosition = {
    params ["_group","_attackPos","_radius",["_type","ground"]];

    private _checkRoute = [
        ([_attackPos,_radius,_type] call NWG_fnc_dtsFindDotForWaypoint),
        ([_attackPos,(_radius/2),_type] call NWG_fnc_dtsFindDotForWaypoint)
    ] select {_x isNotEqualTo false};

    if ((count _checkRoute) == 2) then {
        [_group,(_checkRoute deleteAt 0)] call NWG_DSPAWN_AddWaypoint;
    };
    if ((count _checkRoute) == 1) then {
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
        private _tags = _group call NWG_DSPAWN_GetTags;
        if (_tags isEqualTo []) then {_tags = ["INF"]};//Default to INF
        private _type = switch (true) do {
            case ("AIR" in _tags): {"air"};
            case ("BOAT" in _tags): {"water"};
            default {"ground"};
        };
        _patrolRoute = [_trigger,_type,3] call NWG_fnc_dtsGenerateSimplePatrol;
        _group setVariable ["NWG_DSPAWN_patrolRoute",_patrolRoute];
    };
    if (_patrolRoute isEqualTo []) exitWith {};//No patrol route found/generated

    //Get group vehicle to return to
    private _grpVehicle = _group getVariable ["NWG_DSPAWN_abandonedVehicle",(_group call NWG_DSPAWN_GetGroupVehicle)];
    if (!isNull _grpVehicle && {alive _grpVehicle}) then {
        private _units = (units _group) select {alive _x};
        private _crew = (crew _grpVehicle) select {alive _x};
        //Check that there is someone to board
        private _toBoard = _units - _crew;
        if ((count _toBoard) == 0) exitWith {};//No one to board
        //Check that vehicle is not occupied by someone else
        if ((_crew findIf {!(_x in _units)}) != -1) exitWith {};//Vehicle is occupied by someone else

        _group addVehicle _grpVehicle;
        _toBoard allowGetIn true;
        _toBoard orderGetIn true;
    };

    //Send group to patrol
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;
};

NWG_DSPAWN_GetGroupVehicle = {
    // private _group = _this;

    //Try the vehicle of the group leader
    private _result = vehicle (leader _this);
    if (alive _result && {_result call NWG_fnc_ocIsVehicle}) exitWith {_result};

    //Try the vehicle of any other group member
    _result = ((units _this) apply {vehicle _x}) select {alive _x && {_x call NWG_fnc_ocIsVehicle}};
    if ((count _result) > 0) exitWith {(_result select 0)};

    //Else return null
    objNull
};

NWG_DSPAWN_GetGroupPassengers = {
    params ["_group","_grpVehicle"];

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
    private _spawnResult = [_groupDescr,_paraFrom,(_paraFrom getDir _paraTo),false,civilian] call NWG_DSPAWN_SpawnVehicledGroup;
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

        //Delete parachute
        sleep 3;
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