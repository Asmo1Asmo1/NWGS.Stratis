#include "dspawnDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DSPAWN_Settings = createHashMapFromArray [
    ["CatalogueAddress","DATASETS\Server\Dspawn"],
    ["",0]
];

//================================================================================================================
//================================================================================================================
//Public methods

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
    private _catalogueAddress = NWG_DSPAWN_Settings get ["CatalogueAddress",""];
    private _valid = true;
    private _abort = {
        // private _errorMessage = _this;
        (format [_this,_pageName]) call NWG_fnc_logError;
        NWG_DSPAWN_catalogue set [_pageName,false];
        //return
        false
    };

    //Try load from file
    if (_catalogueAddress isEqualTo "") exitWith {"NWG_DSPAWN_GetCataloguePage: Catalogue address not set, can not load '%1'" call _abort};
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

NWG_DSPAWN_GetCataloguePagePassengers = {
    // private _pageName = _this;
    private _page = _this call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {false};
    //return
    (_page#PASSENGERS_CONTAINER)
};

NWG_DSPAWN_GetCataloguePageParadrop = {
    // private _pageName = _this;
    private _page = _this call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {false};
    //return
    (_page#PARADROP_CONTAINER)
};

NWG_DSPAWN_GetCataloguePageGroups = {
    // private _pageName = _this;
    private _page = _this call NWG_DSPAWN_GetCataloguePage;
    if (_page isEqualTo false) exitWith {false};
    //return
    (_page#GROUPS_CONTAINER)
};

//Not sure if caching is required
// NWG_DSPAWN_gcpgf_previousRequest = [];
// NWG_DSPAWN_gcpgf_previousResult = [];
NWG_DSPAWN_GetCataloguePageGroupsFiltered = {
    params ["_pageName","_filter"];

    //Check cache
    // if (_this isEqualTo NWG_DSPAWN_gcpgf_previousRequest) exitWith {NWG_DSPAWN_gcpgf_previousResult};

    //Get groups
    private _groups = _pageName call NWG_DSPAWN_GetCataloguePageGroups;
    if (_groups isEqualTo false) exitWith {false};

    //Unpack filter
    _filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];

    //Check if filter is empty
    if (_tagsWhiteList isEqualTo [] && {_tagsBlackList isEqualTo [] && {_tierWhiteList isEqualTo []}}) exitWith {
        // NWG_DSPAWN_gcpgf_previousRequest = _this;
        // NWG_DSPAWN_gcpgf_previousResult = _groups;
        _groups
    };

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
    private _filteredGroups = _groups select {(_x call _tagsfilterW) && {(_x call _tagsFilterB) && {(_x call _tierFilter)}}};
    if ((count _filteredGroups) == 0) exitWith {
        (format ["NWG_DSPAWN_GetFilledCatalogueGroup: Could not find any group at page '%1' that match filter '%2'",_pageName,_filter]) call NWG_fnc_logError;
        // NWG_DSPAWN_gcpgf_previousRequest = _this;
        // NWG_DSPAWN_gcpgf_previousResult = false;
        false
    };

    //Cache
    // NWG_DSPAWN_gcpgf_previousRequest = _this;
    // NWG_DSPAWN_gcpgf_previousResult = _filteredGroups;

    //return
    _filteredGroups
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
//Spawn
NWG_DSPAWN_SpawnVehicledGroup = {
    params  ["_vehicleClassname","_unitClassnames","_pos","_dir",
            ["_vehicleAppearance", false],["_vehiclePylons", false],["_deferReveal", false],["_side", west]];

    private _vehicle = [_vehicleClassname,_pos,_dir,_vehicleAppearance,_vehiclePylons,_deferReveal] call NWG_fnc_spwnSpawnVehicleAround;
    private _units = [_unitClassnames,_vehicle,_side] call NWG_fnc_spwnSpawnUnitsIntoVehicle;
    private _group = group (_units#0);

    //return
    [_group,_vehicle,_units]
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