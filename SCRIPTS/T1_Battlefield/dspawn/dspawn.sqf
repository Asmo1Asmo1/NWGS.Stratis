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

NWG_DSPAWN_TRIGGER_PopulateTrigger = {
    params ["_trigger","_groupsCount","_faction",["_filter",[]],["_side",west]];

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
    private _catalogueValues = [_faction,_filter] call NWG_DSPAWN_GetCatalogueValues;
    if (_catalogueValues isEqualTo false) exitWith {
        (format ["NWG_DSPAWN_TRIGGER_PopulateTrigger: Could not load catalogue values for faction '%1' and filter '%2'",_faction,_filter]) call NWG_fnc_logError;
        false
    };
    private _passengersContainer = _catalogueValues#0;
    private _groupsContainer = _catalogueValues#2;
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
        params ["_index","_array","_pointersArray"];
        private _pointer = _pointersArray#_index;
        private _result = (_array#_index)#_pointer;
        _pointer = _pointer + 1;
        if (_pointer >= (count (_array#_index))) then {_pointer = 0};
        _pointersArray set [_index,_pointer];
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

    //Save and return
    NWG_DSPAWN_catalogue set [_this,_page];
    _page
};

NWG_DSPAWN_gcv_previousRequest = [];
NWG_DSPAWN_gcv_previousResult = [];
NWG_DSPAWN_GetCatalogueValues = {
    params ["_pageName",["_filter",[]]];

    //Check cache
    if (_this isEqualTo NWG_DSPAWN_gcv_previousRequest) exitWith {NWG_DSPAWN_gcv_previousResult};

    //Get the page
    private _page = _pageName call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {false};//Could not load the page for whatever reason (logged internally)
    _page params ["_passengersContainer","_paradropContainer","_groupsContainer"];

    //While passengers and paradrop are provided AS IS, groups are filtered and processed with spawn chance based on their tier
    //Unpack filter
    _filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];

    //Check if filter is empty
    private _filteredGroups = if (_tagsWhiteList isEqualTo [] && {_tagsBlackList isEqualTo [] && {_tierWhiteList isEqualTo []}}) then {
        _groupsContainer
    } else {
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

        //Filter groups
        _groupsContainer select {(_x call _tagsfilterW) && {(_x call _tagsFilterB) && {(_x call _tierFilter)}}}
    };

    if ((count _filteredGroups) == 0) exitWith {
        (format ["NWG_DSPAWN_GetCatalogueValues: Could not find any group at page '%1' that matches filter '%2'",_pageName,_filter]) call NWG_fnc_logError;
        NWG_DSPAWN_gcv_previousRequest = _this;
        NWG_DSPAWN_gcv_previousResult = [];
        false
    };

    //Multiply by spawn chance (tier)
    private _resultGroups = [];
    //do
    {
        switch (_x#DESCR_TIER) do {
            case (1): {
                _resultGroups pushBack _x;
                _resultGroups pushBack _x;
                _resultGroups pushBack _x;
            };
            case (2): {
                _resultGroups pushBack _x;
                _resultGroups pushBack _x;
            };
            case (3): {
                _resultGroups pushBack _x;
            };
            default {
                (format ["NWG_DSPAWN_GetCatalogueValues: Invalid group tier '%1':'%2'",_pageName,_x]) call NWG_fnc_logError;
            };
        };
    } forEach _filteredGroups;

    //Cache and return
    private _result = [_passengersContainer,_paradropContainer,_resultGroups];
    NWG_DSPAWN_gcv_previousRequest = _this;
    NWG_DSPAWN_gcv_previousResult = _result;
    _result
};

//================================================================================================================
//================================================================================================================
//String array
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

//================================================================================================================
//================================================================================================================
//Passengers
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

//================================================================================================================
//================================================================================================================
//Group description processing
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
//Additional code helpers
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

//================================================================================================================
//================================================================================================================
//Patrol logic
NWG_DSPAWN_SendToPatrol = {
    params ["_group","_patrolRoute"];

    //Delete current waypoints (if any)
    for "_i" from ((count (waypoints _group)) - 1) to 0 step -1 do {
        deleteWaypoint [_group, _i];
    };

    //Add new patrol route
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
    private _vehicle = vehicle _this;

    NWG_DSPAWN_currentlyParadropping deleteAt (NWG_DSPAWN_currentlyParadropping find _vehicle);
    for "_i" from ((count (waypoints _group)) - 1) to 0 step -1 do {deleteWaypoint [_group, _i]};
    {_vehicle deleteVehicleCrew _x} forEach (crew _vehicle);
    deleteVehicle _vehicle;
    deleteGroup _group;
};