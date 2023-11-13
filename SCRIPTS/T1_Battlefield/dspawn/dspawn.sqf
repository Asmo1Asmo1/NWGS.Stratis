#include "dspawnDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DSPAWN_Settings = createHashMapFromArray [
    ["CatalogueAddress","DATASETS\Server\Dspawn"],
    ["TriggerPopulationDistribution",[5,3,1,1,1]],//Default population as INF/VEH/ARM/AIR/BOAT
    ["",0]
];

//================================================================================================================
//================================================================================================================
//Populate trigger
NWG_DSPAWN_TRIGGER_CalculatePopulation = {
    params ["_targetCount","_filter"];
    private _result = (NWG_DSPAWN_Settings get "TriggerPopulationDistribution") + [];//Shallow copy of default distribution

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
            _result
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
    private _catalogueAddress = NWG_DSPAWN_Settings get "CatalogueAddress";
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

    //return
    ([_groupDescr,[_group,false,_units]] call NWG_DSPAWN_SpawnGroupFinalize)
};

NWG_DSPAWN_SpawnGroupFinalize = {
    params ["_groupDescr","_spawnResult"];

    //Run additional code
    private _additionalCode = _groupDescr param [DESCR_ADDITIONAL_CODE,{}];
    _spawnResult call _additionalCode;

    //Set tags
    private _tags = _groupDescr#DESCR_TAGS;
    private _group = _spawnResult#0;
    _group setVariable ["NWG_DSPAWN_tags",_tags];

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

//================================================================================================================
//================================================================================================================
//Patrol logic

//================================================================================================================
//================================================================================================================
//Attack logic

//================================================================================================================
//================================================================================================================
//Paradrop