#include "..\..\globalDefines.h"
#include "ukrepDefines.h"

/*
    Annotation:
    This module places object compositions (ukreps) according to blueprints and rules.
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_UKREP_Settings = createHashMapFromArray [
    ["BLUEPRINTS_CATALOGUE_ADDRESS","DATASETS\Server\Ukrep\Blueprints"],//Address of the catalogue for blueprints
    ["FACTIONS_CATALOGUE_ADDRESS","DATASETS\Server\Ukrep\Factions"],//Address of the catalogue for factions

    ["DEFAULT_GROUP_SIDE",west],//If group rules not provided - place under this side
    ["DEFAULT_GROUP_DYNASIM",true],//If group rules not provided - place with this dynamic simulation setting
    ["DEFAULT_GROUP_DISABLEPATH",true],//If group rules not provided - place with this pathfinding setting
    ["DEFAULT_GROUP_SEPARATE_VEHS",true],//If group rules not provided - place with this vehicles separation setting (wether or not put vehicles into separate groups)

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Blueprint catalog get
NWG_UKREP_blueprints = createHashMap;
NWG_UKREP_factions = createHashMap;
NWG_UKREP_GetCataloguePage = {
    params ["_pageName","_cache","_catalogueAddress"];
    if (_pageName in _cache) exitWith {_cache get _pageName};//Already loaded

    private _page = call ((format["%1\%2.sqf",_catalogueAddress,_pageName]) call NWG_fnc_compile);
    if (isNil "_page") then {
        (format ["NWG_UKREP_GetCataloguePage: Could not load the catalogue page '%1'",_pageName]) call NWG_fnc_logError;
        _page = false;
    };

    _cache set [_pageName,_page];
    _page
};

NWG_UKREP_GetBlueprintsPage = {
    // private _pageName = _this;
    [_this,NWG_UKREP_blueprints,(NWG_UKREP_Settings get "BLUEPRINTS_CATALOGUE_ADDRESS")] call NWG_UKREP_GetCataloguePage
};

NWG_UKREP_GetFactionsPage = {
    // private _pageName = _this;
    [_this,NWG_UKREP_factions,(NWG_UKREP_Settings get "FACTIONS_CATALOGUE_ADDRESS")] call NWG_UKREP_GetCataloguePage
};

NWG_UKREP_GetBlueprintsABS = {
    params ["_pageName",["_blueprintName",""],["_blueprintPos",[]]];
    private _page = _pageName call NWG_UKREP_GetBlueprintsPage;
    if (_page isEqualTo false) exitWith {[]};

    private _nameFilter = if (_blueprintName isNotEqualTo "")
        then {{_blueprintName in (_this#BPCONTAINER_NAME)}}
        else {{true}};
    private _posFilter = if (_blueprintPos isNotEqualTo [])
        then {{((_blueprintPos#0) distance2D (_this#BPCONTAINER_POS)) <= (_blueprintPos#1)}}
        else {{true}};

    //return
    _page select {(_x#BPCONTAINER_TYPE) isEqualTo "ABS" && {_x call _nameFilter && {_x call _posFilter}}}
};

NWG_UKREP_GetBlueprintsREL = {
    params ["_pageName",["_blueprintName",""],["_blueprintRoot",[]]];
    private _page = _pageName call NWG_UKREP_GetBlueprintsPage;
    if (_page isEqualTo false) exitWith {[]};

    private _nameFilter = if (_blueprintName isNotEqualTo "")
        then {{_blueprintName in (_this#BPCONTAINER_NAME)}}
        else {{true}};
    private _rootFilter = if (_blueprintRoot isNotEqualTo [])
        then {{(((_this#BPCONTAINER_BLUEPRINT)#0)#BP_CLASSNAME) in _blueprintRoot}}
        else {{true}};

    //return
    _page select {(_x#BPCONTAINER_TYPE) isEqualTo "REL" && {_x call _nameFilter && {_x call _rootFilter}}}
};

//================================================================================================================
//================================================================================================================
//FRACTAL placement
NWG_UKREP_FRACTAL_PlaceFractalABS = {
    params ["_fractalSteps",["_faction",""],["_overrides",[]]];

    //1. Get root blueprint
    private _fractalStep1 = _fractalSteps param [FRACTAL_STEP_ROOT,[]];
    _fractalStep1 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""],["_blueprintPosFilter",[]]];
    private _blueprint = if ("RootBlueprint" in _overrides) then {
        _overrides get "RootBlueprint"
    } else {
        private _blueprints = [_pageName,_blueprintNameFilter,_blueprintPosFilter] call NWG_UKREP_GetBlueprintsABS;
        private _bp = if ((count _blueprints) > 0)
            then {[_blueprints,"NWG_UKREP_FRACTAL_PlaceFractalABS"] call NWG_fnc_selectRandomGuaranteed}
            else {(format ["NWG_UKREP_FRACTAL_PlaceFractalABS: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintNameFilter,_blueprintPosFilter]) call NWG_fnc_logError; []};
        _bp param [BPCONTAINER_BLUEPRINT,[]]
    };
    if (_blueprint isEqualTo []) exitWith {false};//Error

    //2. Prepare group rules override
    private _groupRulesOverride = {
        // private _groupRules = _this;
        if ("GroupsMembership" in _overrides)  then {_this set [GRP_RULES_MEMBERSHIP,(_overrides get "GroupsMembership")]};//Override group membership
        if ("GroupsDynasim" in _overrides)     then {_this set [GRP_RULES_DYNASIM,(_overrides get "GroupsDynasim")]};//Override group dynamic simulation
        if ("GroupsDisablePath" in _overrides) then {_this set [GRP_RULES_DISABLEPATH,(_overrides get "GroupsDisablePath")]};//Override group pathfinding
        _this
    };

    //3. Place root blueprint (fractal step 1)
    _blueprint = +_blueprint;//Clone
    _groupRules = _groupRules call _groupRulesOverride;//Apply overrides if any
    private _result = [_blueprint,_chances,_faction,_groupRules] call NWG_UKREP_PlaceABS;
    if (_result isEqualTo false) exitWith {false};//Error
    //result is: [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]

    //4. Decorate buildings (fractal step 2)
    private _fractalStep2 = _fractalSteps param [FRACTAL_STEP_BLDG,_fractalStep1];//Unpack or re-use upper step
    _fractalStep2 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    _groupRules = _groupRules call _groupRulesOverride;//Apply overrides if any
    private _placedBldgs = (_result#OBJ_CAT_BLDG) select {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup};
    //forEach building
    {
        private _bldgPage = [_pageName,_x,OBJ_TYPE_BLDG] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _bldgResult = [_bldgPage,_x,OBJ_TYPE_BLDG,_blueprintNameFilter,_chances,_faction,_groupRules,/*_adaptToGround:*/true] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_bldgResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _bldgResult;
        if ((count (_bldgResult#OBJ_CAT_UNIT)) > 0)
            then {_x call NWG_fnc_shAddOccupiedBuilding};//Mark building as occupied for other subsystems
    } forEach _placedBldgs;

    //5. Decorate furniture (fractal step 3)
    private _fractalStep3 = _fractalSteps param [FRACTAL_STEP_FURN,_fractalStep2];//Unpack or re-use upper step
    _fractalStep3 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    _groupRules = _groupRules call _groupRulesOverride;//Apply overrides if any
    private _placedFurns = (_result#OBJ_CAT_FURN) select {[_x,OBJ_TYPE_FURN,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup};
    //forEach furniture
    {
        private _furnPage = [_pageName,_x,OBJ_TYPE_FURN] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _adaptToGround = _x call NWG_UKREP_FRACTAL_IsFurnitureOutside;//Adapt chairs around table only if table itself is not inside a building
        private _furnResult = [_furnPage,_x,OBJ_TYPE_FURN,_blueprintNameFilter,_chances,_faction,_groupRules,_adaptToGround] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_furnResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _furnResult;
    } forEach _placedFurns;

    //return
    _result
};

NWG_UKREP_FRACTAL_DecorateFractalBuildings = {
    params ["_buildings","_fractalSteps",["_faction",""],["_overrides",[]]];

    //1. Prepare group rules override
    private _groupRulesOverride = {
        // private _groupRules = _this;
        if ("GroupsMembership" in _overrides)  then {_this set [GRP_RULES_MEMBERSHIP,(_overrides get "GroupsMembership")]};//Override group membership
        if ("GroupsDynasim" in _overrides)     then {_this set [GRP_RULES_DYNASIM,(_overrides get "GroupsDynasim")]};//Override group dynamic simulation
        if ("GroupsDisablePath" in _overrides) then {_this set [GRP_RULES_DISABLEPATH,(_overrides get "GroupsDisablePath")]};//Override group pathfinding
        _this
    };

    //2. Decorate buildings (fractal step 2)
    private _result = OBJ_DEFAULT_CHART;
    private _fractalStep1 = _fractalSteps param [0,[]];
    private _fractalStep2 = _fractalSteps param [1,_fractalStep1];//Unpack or re-use upper step
    _fractalStep2 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    _groupRules = _groupRules call _groupRulesOverride;//Apply overrides if any
    _buildings = _buildings select {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup};
    //forEach building
    {
        private _bldgPage = [_pageName,_x,OBJ_TYPE_BLDG] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _bldgResult = [_bldgPage,_x,OBJ_TYPE_BLDG,_blueprintNameFilter,_chances,_faction,_groupRules,/*_adaptToGround:*/true] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_bldgResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _bldgResult;
        if ((count (_bldgResult#OBJ_CAT_UNIT)) > 0)
            then {_x call NWG_fnc_shAddOccupiedBuilding};//Mark building as occupied for other subsystems
    } forEach _buildings;

    //6. Decorate furniture (fractal step 3)
    private _fractalStep3 = _fractalSteps param [2,_fractalStep2];//Unpack or re-use upper step
    _fractalStep3 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    _groupRules = _groupRules call _groupRulesOverride;//Apply overrides if any
    private _placedFurns = (_result#OBJ_CAT_FURN) select {[_x,OBJ_TYPE_FURN,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup};
    //forEach furniture
    {
        private _furnPage = [_pageName,_x,OBJ_TYPE_FURN] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _adaptToGround = _x call NWG_UKREP_FRACTAL_IsFurnitureOutside;//Adapt chairs around table only if table itself is not inside a building
        private _furnResult = [_furnPage,_x,OBJ_TYPE_FURN,_blueprintNameFilter,_chances,_faction,_groupRules,_adaptToGround] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_furnResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _furnResult;
    } forEach _placedFurns;

    //return
    _result
};

NWG_UKREP_FRACTAL_PlaceFractalREL = {
    params ["_pos","_dir","_fractalSteps",["_faction",""],["_clearTheArea",true]];

    //1. Get root blueprint
    private _fractalStep1 = _fractalSteps param [0,[]];
    _fractalStep1 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""],["_blueprintRoot",[]]];
    private _blueprints = [_pageName,_blueprintNameFilter,_blueprintRoot] call NWG_UKREP_GetBlueprintsREL;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_FRACTAL_PlaceFractalREL: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintNameFilter,_blueprintRoot]) call NWG_fnc_logError;
        false//Error
    };
    private _blueprint = [_blueprints,"NWG_UKREP_FRACTAL_PlaceFractalREL"] call NWG_fnc_selectRandomGuaranteed;

    //2. Add 'clear the area' helper if defined
    private _helper = if (_clearTheArea) then {
        private _bpRad = _blueprint#BPCONTAINER_RADIUS;
        ["HELP","ModuleHideTerrainObjects_F",0,[0,0,0],0,0,[
            	["objectArea",[_bpRad,_bpRad,0,false,-1]],
	            ["#filter",15],
	            ["#hideLocally",false],
	            ["BIS_fnc_initModules_disableAutoActivation",false]
        ]]
    } else {[]};

    //3. Place root blueprint (fractal step 1)
    //We do not use PUBLIC method because we need to add helper to blueprint manually
    _blueprint = _blueprint#BPCONTAINER_BLUEPRINT;
    _blueprint = +_blueprint;//Clone
    if (_clearTheArea) then {_blueprint pushBack _helper};
    private _result = [_blueprint,_pos,_dir,_chances,_faction,_groupRules,/*_adaptToGround:*/true] call NWG_UKREP_PlaceREL_Position;
    if (_result isEqualTo false) exitWith {false};//Error
    //result is: [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]

    //4. Decorate buildings (fractal step 2)
    private _fractalStep2 = _fractalSteps param [1,_fractalStep1];//Unpack or re-use upper step
    _fractalStep2 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    //forEach placed building
    {
        private _bldgPage = [_pageName,_x,OBJ_TYPE_BLDG] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _bldgResult = [_bldgPage,_x,OBJ_TYPE_BLDG,_blueprintNameFilter,_chances,_faction,_groupRules,/*_adaptToGround:*/true] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_bldgResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _bldgResult;
        if ((count (_bldgResult#OBJ_CAT_UNIT)) > 0)
            then {_x call NWG_fnc_shAddOccupiedBuilding};//Mark building as occupied for other subsystems
    } forEach ((_result#OBJ_CAT_BLDG) select {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup});

    //5. Decorate furniture (fractal step 3)
    private _fractalStep3 = _fractalSteps param [2,_fractalStep2];//Unpack or re-use upper step
    _fractalStep3 params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""]];
    //forEach placed furniture
    {
        private _furnPage = [_pageName,_x,OBJ_TYPE_FURN] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _adaptToGround = _x call NWG_UKREP_FRACTAL_IsFurnitureOutside;//Adapt chairs around table only if table itself is not inside a building
        private _furnResult = [_furnPage,_x,OBJ_TYPE_FURN,_blueprintNameFilter,_chances,_faction,_groupRules,_adaptToGround] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_furnResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _furnResult;
    } forEach ((_result#OBJ_CAT_FURN) select {[_x,OBJ_TYPE_FURN,_pageName,_blueprintNameFilter] call NWG_UKREP_FRACTAL_HasRelSetup});

    //return
    _result
};

/*Utils*/
NWG_UKREP_FRACTAL_AutoGetPageName = {
    params ["_pageName","_object","_objectType"];
    if (_pageName isNotEqualTo "AUTO") exitWith {_pageName};//Use provided
    //return
    switch (_objectType) do {
        case OBJ_TYPE_BLDG: {"Bldg" + (_object call NWG_fnc_ocGetBuildingCategory)};
        case OBJ_TYPE_FURN: {"Furn" + (_object call NWG_fnc_ocGetFurnitureCategory)};
        default {""};
    }
};

NWG_UKREP_FRACTAL_HasRelSetup = {
    params ["_object","_objectType","_pageName",["_nameFilter",""]];

    private _rootFilter = switch (_objectType) do {
        case OBJ_TYPE_BLDG: {_object call NWG_fnc_ocGetSameBuildings};
        case OBJ_TYPE_FURN: {_object call NWG_fnc_ocGetSameFurniture};
        default {[(typeOf _object)]};//Shouldn't be used, but okay
    };
    if ((count _rootFilter) == 0) exitWith {false};//Error

    _pageName = [_pageName,_object,_objectType] call NWG_UKREP_FRACTAL_AutoGetPageName;
    private _page = _pageName call NWG_UKREP_GetBlueprintsPage;
    if (_page isEqualTo false) exitWith {false};//Error

    private _nameCheck = if (_nameFilter isNotEqualTo "")
        then {{_nameFilter in (_this#BPCONTAINER_NAME)}}
        else {{true}};

    //return
    ((_page findIf {
        (_x#BPCONTAINER_TYPE) isEqualTo "REL" && {
        _x call _nameCheck && {
        (((_x#BPCONTAINER_BLUEPRINT)#0)#BP_CLASSNAME) in _rootFilter}}
    }) != -1)
};

NWG_UKREP_FRACTAL_IsFurnitureOutside = {
    private _furn = _this;

    private _raycastFrom = getPosWorld _furn;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _raycast = (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_furn,objNull,true,-1,"FIRE","VIEW",true]));

    //Find if there is at least one object beneath - if there is, then the furniture is inside something
    (_raycast findIf {_x isEqualType objNull && {!isNull _x && {!(_x isEqualTo _furn)}}}) == -1
};

//================================================================================================================
//================================================================================================================
//Public placement
NWG_UKREP_PUBLIC_PlaceABS = {
    params ["_pageName",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction",""],["_groupRules",[]]];
    private _blueprints = [_pageName,_blueprintName,_blueprintPos] call NWG_UKREP_GetBlueprintsABS;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_PUBLIC_PlaceABS: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintName,_blueprintPos]) call NWG_fnc_logError;
        false//Error
    };
    private _blueprint = [_blueprints,"NWG_UKREP_PUBLIC_PlaceABS"] call NWG_fnc_selectRandomGuaranteed;
    _blueprint = _blueprint#BPCONTAINER_BLUEPRINT;
    _blueprint = +_blueprint;//Clone

    private _result = [_blueprint,_chances,_faction,_groupRules] call NWG_UKREP_PlaceABS;
    if (_result isEqualTo false) exitWith {false};//Error

    //return
    _result
};

NWG_UKREP_PUBLIC_PlaceREL_Position = {
    params ["_pageName","_pos","_dir",["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    private _blueprints = [_pageName,_blueprintName] call NWG_UKREP_GetBlueprintsREL;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_PUBLIC_PlaceREL_Position: Could not find the blueprint matching the %1:%2",_pageName,_blueprintName]) call NWG_fnc_logError;
        false//Error
    };
    private _blueprint = [_blueprints,"NWG_UKREP_PUBLIC_PlaceREL_Position"] call NWG_fnc_selectRandomGuaranteed;
    _blueprint = _blueprint#BPCONTAINER_BLUEPRINT;
    _blueprint = +_blueprint;//Clone

    private _result = [_blueprint,_pos,_dir,_chances,_faction,_groupRules,_adaptToGround] call NWG_UKREP_PlaceREL_Position;
    if (_result isEqualTo false) exitWith {false};//Error

    //return
    _result
};

NWG_UKREP_PUBLIC_PlaceREL_Object = {
    params ["_pageName","_object",["_objectType",""],["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true],["_suppressEvent",false]];
    if (_objectType isEqualTo "") then {_objectType = _object call NWG_fnc_ocGetObjectType};
    private _rootObjFilter = switch (_objectType) do {
        case OBJ_TYPE_BLDG: {_object call NWG_fnc_ocGetSameBuildings};
        case OBJ_TYPE_FURN: {_object call NWG_fnc_ocGetSameFurniture};
        default {[(typeOf _object),""]};//Support this object type and 'any'
    };
    if (_rootObjFilter isEqualTo []) exitWith {
        (format ["NWG_UKREP_PUBLIC_PlaceREL_Object: Could not find the root object filter for the object %1:%2:%3",_objectType,_object,(typeOf _object)]) call NWG_fnc_logError;
        false//Error
    };

    private _blueprints = [_pageName,_blueprintName,_rootObjFilter] call NWG_UKREP_GetBlueprintsREL;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_PUBLIC_PlaceREL_Object: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintName,_rootObjFilter]) call NWG_fnc_logError;
        false//Error
    };
    private _blueprint = [_blueprints,(str _rootObjFilter)] call NWG_fnc_selectRandomGuaranteed;
    _blueprint = _blueprint#BPCONTAINER_BLUEPRINT;
    _blueprint = +_blueprint;//Clone

    private _result = [_blueprint,_object,_chances,_faction,_groupRules,_adaptToGround] call NWG_UKREP_PlaceREL_Object;
    if (_result isEqualTo false) exitWith {false};//Error

    //Raise event (object decorated)
    if !(_suppressEvent) then {
        [EVENT_ON_UKREP_OBJECT_DECORATED,[_object,_objectType,_result]] call NWG_fnc_raiseServerEvent;
    };

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Placement (mid-level)
NWG_UKREP_PlaceABS = {
    params ["_blueprint",["_chances",[]],["_faction",""],["_groupRules",[]]];
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    //return
    [_blueprint,_groupRules] call NWG_UKREP_PlacementCore
};

NWG_UKREP_PlaceREL_Position = {
    params ["_blueprint","_pos","_dir",["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    _blueprint = [_blueprint,_pos,_dir,_adaptToGround,/*_rootExists:*/false] call NWG_UKREP_BP_RELtoABS;
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    //return
    [_blueprint,_groupRules] call NWG_UKREP_PlacementCore
};

NWG_UKREP_PlaceREL_Object = {
    params ["_blueprint","_object",["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    _blueprint = [_blueprint,(getPosASL _object),(getDir _object),_adaptToGround,/*_rootExists:*/true] call NWG_UKREP_BP_RELtoABS;
    _blueprint deleteAt 0;//Remove root from blueprint (already placed)
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    //return
    [_blueprint,_groupRules] call NWG_UKREP_PlacementCore
};

//================================================================================================================
//================================================================================================================
//Blueprint manipulation
NWG_UKREP_BP_RELtoABS = {
    params ["_blueprint","_placementPos","_placementDir","_adaptToGround","_rootExists"];
    private _rootOrigDir = (_blueprint#0)#BP_DIR;

    private _result = [];
    private _recursiveRELtoABS = {
        params ["_rootPos","_rootOrigDir","_rootCurDir","_records","_adapt"];

        //Prepare variables
        private _a = if (_rootCurDir >= _rootOrigDir)
            then {((360-_rootCurDir)+_rootOrigDir)}
            else {(360-((360-_rootOrigDir)+_rootCurDir))};
        private _sin = if (_a == 180 || {_a == 360}) then {0} else {sin _a};//Fix SQF sin/cos bug
        private _cos = if (_a == 90  || {_a == 270}) then {0} else {cos _a};//Fix SQF sin/cos bug

        //Process records
        {
            //Calculate ABS position
            private _posOffset = _x#BP_POSOFFSET;
            private _dX = ((_posOffset#0)*_cos)-((_posOffset#1)*_sin);
            private _dY = ((_posOffset#1)*_cos)+((_posOffset#0)*_sin);
            private _absPos = _rootPos vectorAdd [_dX,_dY,(_posOffset#2)];
            if (_adapt) then {
                _absPos set [2,0];
                _absPos = ATLToASL _absPos;
            };
            _x set [BP_POS,_absPos];

            //Calculate ABS direction
            private _origDir   = _x#BP_DIR;//Save for later
            private _dirOffset = _x#BP_DIROFFSET;
            private _absDir = (_rootCurDir + _dirOffset);
            _x set [BP_DIR,_absDir];

            //Save and continue
            private _inside = _x param [BP_INSIDE,[]];
            if ((count _inside) > 0) then {
                //We need to go deeper - process objects inside this one
                _x set [BP_INSIDE,[]];
                _result pushBack _x;
                [_absPos,_origDir,_absDir,_inside,/*adaptToGround:*/false] call _recursiveRELtoABS;
            } else {
                //We're done
                _result pushBack _x;
            };
        } forEach _records;
    };

    if (_rootExists) then {
        //Root object already exists
        private _rootChunk = [(_blueprint deleteAt 0)];
        [_placementPos,_rootOrigDir,_placementDir,_rootChunk,/*_adaptToGround:*/false] call _recursiveRELtoABS;
        [_placementPos,_rootOrigDir,_placementDir,_blueprint,_adaptToGround] call _recursiveRELtoABS;
        _rootChunk resize 0;//Clear
    } else {
        //Root object does not exist
        [_placementPos,_rootOrigDir,_placementDir,_blueprint,_adaptToGround] call _recursiveRELtoABS;
    };
    _blueprint resize 0;
    _blueprint append _result;

    //return
    _blueprint
};

NWG_UKREP_BP_ApplyChances = {
    params ["_blueprint",["_chances",[]]];
    if (_chances isEqualTo []) exitWith {_blueprint};//Nothing to do

    private _toRemove = [];
    {
        private _chance = _chances param [_forEachIndex,1];
        if (_chance isEqualTo 1) then {continue};//Skip 100% chance

        private _curType = _x;
        private _affectedObjects = _blueprint select {(_x#BP_OBJTYPE) isEqualTo _curType};
        if ((count _affectedObjects) == 0) then {continue};//Skip if no objects to remove

        private _targetCount = switch (true) do {
            case (_chance isEqualType 0.5): {
                //Fixed percentage
                //return
                round ((count _affectedObjects) * _chance)
            };
            case (_chance isEqualType []): {
                //Min-max range
                private _minPerc = _chance param [0,0.0];
                private _maxPerc = _chance param [1,1.0];
                private _targetPercentage = (_minPerc + (random (_maxPerc - _minPerc)));
                //return
                round ((count _affectedObjects) * _targetPercentage)
            };
            case (_chance isEqualType createHashMap): {
                //Custom chance rules
                /*Check if ignore rules are defined*/
                if ("IgnoreList" in _chance) then {
                    private _ignoreList = _chance get "IgnoreList";
                    _affectedObjects = _affectedObjects select {!((_x#BP_CLASSNAME) in _ignoreList)};//Modify affected objects array
                };

                /*Proceed with target count calculation*/
                private _minPerc  = _chance getOrDefault ["MinPercentage",0.0];
                private _maxPerc  = _chance getOrDefault ["MaxPercentage",1.0];
                private _minCount = _chance getOrDefault ["MinCount",0];
                private _maxCount = _chance getOrDefault ["MaxCount",(count _affectedObjects)];

                private _targetPercentage = (_minPerc + (random (_maxPerc - _minPerc)));
                private _result = round ((count _affectedObjects) * _targetPercentage);
                _result = (_result max _minCount) min _maxCount;//Clamp
                //return
                _result
            };
            default {
                //Log error
                (format ["NWG_UKREP_BP_ApplyChances: Unexpected chance type for '%1': %2",_curType,_chance]) call NWG_fnc_logError;
                (count _affectedObjects)//Fallback to 100%
            };
        };
        if ((count _affectedObjects) <= _targetCount) then {continue};//Skip if no objects to remove

        _affectedObjects = _affectedObjects call NWG_fnc_arrayShuffle;
        _toRemove append (_affectedObjects select [_targetCount]);//Append everything in excess (from targetCount to the end of the array)
    } forEach [
        OBJ_TYPE_BLDG,
        OBJ_TYPE_FURN,
        OBJ_TYPE_DECO,
        OBJ_TYPE_UNIT,
        OBJ_TYPE_VEHC,
        OBJ_TYPE_TRRT,
        OBJ_TYPE_MINE
    ];

    if ((count _toRemove) > 0) then {
        private _temp = _blueprint - _toRemove;
        _blueprint resize 0;
        _blueprint append _temp;
    };

    //return
    _blueprint
};

NWG_UKREP_BP_ApplyFaction = {
    params ["_blueprint",["_faction",""]];
    if (_faction isEqualTo "") exitWith {_blueprint};//Nothing to do

    private _factionPage = _faction call NWG_UKREP_GetFactionsPage;
    if (_factionPage isEqualTo false) exitWith {_blueprint};//Error loading faction page. Error logged internally

    private ["_classname","_replacement","_crew"];
    //forEach record in blueprint
    {
        _classname = _x#BP_CLASSNAME;

        //Replace classname and payload
        if (_classname in _factionPage) then {
            _replacement = _factionPage get _classname;

            /*Single classname*/
            if (_replacement isEqualType "") exitWith {_x set [BP_CLASSNAME,_replacement]};

            /*Array of classnames*/
            _replacement = [_replacement,(format ["NWG_UKREP_BP_ApplyFaction_%1",_classname])] call NWG_fnc_selectRandomGuaranteed;
            if (_replacement isEqualType "") exitWith {_x set [BP_CLASSNAME,_replacement]};

            /*As array of [classname,payload]*/
            _x set [BP_CLASSNAME,(_replacement param [0,""])];
            _x set [BP_PAYLOAD,  (_replacement param [1,[]])];
        };

        //Replace crew of the vehicle or turret
        if ((_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_VEHC || {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_TRRT}) then {
            _crew = if ((_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_VEHC)
                then {(_x param [BP_PAYLOAD,[]]) param [0,[]]}/*VEHC payload: [crew,appearance,pylons]*/
                else {(_x param [BP_PAYLOAD,[]])};            /*TRRT payload: crew*/
            //do
            {
                if !(_x isEqualType "")  then {continue};
                if !(_x in _factionPage) then {continue};
                _replacement = _factionPage get _x;
                if (_replacement isEqualType "") then {_crew set [_forEachIndex,_replacement]; continue};
                _replacement = [_replacement,(format ["NWG_UKREP_BP_ApplyFaction_%1",_x])] call NWG_fnc_selectRandomGuaranteed;
                _replacement = if (_replacement isEqualType []) then {_replacement param [0,""]} else {_replacement};
                _crew set [_forEachIndex,_replacement];//Yes, this is legal
            } forEach _crew;
        };
    } forEach _blueprint;

    //return
    _blueprint
};

//================================================================================================================
//================================================================================================================
//Placement CORE
//Note: at this point we expect the blueprint to be in absolute coordinates ASL, insides unpacked into single-dimension array and protected from modification of the original blueprint
#define GET_GROUP_UNIT 0
#define GET_GROUP_VEHC 1
#define GET_GROUP_TRRT 2
NWG_UKREP_PlacementCore = {
    params ["_blueprint",["_groupRules",[]]];

    /*Sort into groups*/
    private _hlprs = []; private _bldgs = []; private _furns = []; private _decos = [];
    private _units = []; private _vehcs = []; private _trrts = []; private _mines = [];
    private _unitsCiv = [];
    {
        switch (_x#BP_OBJTYPE) do {
            case "HELP": {_hlprs pushBack _x};
            case OBJ_TYPE_BLDG: {_bldgs pushBack _x};
            case OBJ_TYPE_FURN: {_furns pushBack _x};
            case OBJ_TYPE_DECO: {_decos pushBack _x};
            case OBJ_TYPE_UNIT: {_units pushBack _x};
            case "UNIT_CIV": {_unitsCiv pushBack _x};
            case OBJ_TYPE_VEHC: {_vehcs pushBack _x};
            case OBJ_TYPE_TRRT: {_trrts pushBack _x};
            case OBJ_TYPE_MINE: {_mines pushBack _x};
        };
    } forEach _blueprint;
    _blueprint resize 0;//Clear

    /*Place HELP - helper modules*/
    if ((count _hlprs) > 0) then {
        private _hlprsGroup = group (missionNamespace getvariable ["BIS_functions_mainscope",objnull]);
        if (isNull _hlprsGroup) exitWith {
            "NWG_UKREP_PlacementCore: Failed to obtain helper group" call NWG_fnc_logError;
            _hlprs resize 0;//Clear
        };
        _hlprs = _hlprs apply {
            private _helper = _hlprsGroup createUnit [(_x#BP_CLASSNAME),(ASLToAGL (_x#BP_POS)),[],0,"CAN_COLLIDE"];
            {_helper setVariable _x} forEach (_x#BP_PAYLOAD);
            _helper setVariable ["BIS_fnc_initModules_disableAutoActivation",true];
            _helper
        };
    };

    /*Place regular objects (BLDG,FURN,DECO) - buildings, furniture, decor*/
    _bldgs = _bldgs apply {_x call NWG_UKREP_CreateObject};
    _furns = _furns apply {_x call NWG_UKREP_CreateObject};
    _decos = _decos apply {_x call NWG_UKREP_CreateObject};

    /*Prepare the group(s) to include units into with lazy evaluation*/
    private _rootGroup = grpNull;
    private _addGroups = [];
    private _getGroup = {
        private _flag = _this;

        //Check special "AGENT" case
        private _membership = _groupRules param [GRP_RULES_MEMBERSHIP,(NWG_UKREP_Settings get "DEFAULT_GROUP_SIDE")];
        if (_membership isEqualTo "AGENT") exitWith {"AGENT"};//Special case

        //Check vehicle separation case
        if (_flag == GET_GROUP_VEHC && {
            _groupRules param [GRP_RULES_SEPARATE_VEHS,(NWG_UKREP_Settings get "DEFAULT_GROUP_SEPARATE_VEHS")]}
        ) exitWith {
            private _group = createGroup [_membership,/*delete when empty:*/true];
            _addGroups pushBack _group;
            _group
        };

        //Default
        if (!isNull _rootGroup) exitWith {_rootGroup};
        _rootGroup = createGroup [_membership,/*delete when empty:*/true];
        _rootGroup
    };

    /*Place UNIT - units*/
    if ((count _units) > 0) then {
        _units = _units apply {[(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),(_x#BP_PAYLOAD)]};//Repack into func argument
        _units = [_units,(GET_GROUP_UNIT call _getGroup)] call NWG_fnc_spwnSpawnUnitsExact;
    };

    /*Place UNIT_CIV - civilians units (not a part of any logic, just for entourage)*/
    if ((count _unitsCiv) > 0) then {
        _unitsCiv = _unitsCiv apply {[(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),(_x#BP_PAYLOAD)]};//Repack into func argument
        _unitsCiv = [_unitsCiv,civilian] call NWG_fnc_spwnSpawnUnitsExact;
    };

    /*Place VEHC - vehicles*/
    _vehcs = _vehcs apply {
        (_x#BP_PAYLOAD) params [["_crew",[]],["_appearance",false],["_pylons",false]];
        private _vehicle = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),_appearance,_pylons] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_vehicle,(GET_GROUP_VEHC call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _vehicle
    };

    /*Place TRRT - turrets*/
    _trrts = _trrts apply {
        private _crew = _x param [BP_PAYLOAD,[]];
        private _turret = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR)] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_turret,(GET_GROUP_TRRT call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _turret
    };

    /*Place MINE - mines*/
    if ((count _mines) > 0) then {
        private _minesDirs = [];//Fix for mines direction in MP
        private ["_mine","_pos"];
        _mines = _mines apply {
            _pos = switch (_x#BP_CLASSNAME) do {
                case "APERSTripMine": {(_x#BP_POS) vectorAdd [0,0,0.1]};//Fix for APERSTripMine going a bit underground
                case "UnderwaterMine": {(_x#BP_POS) vectorAdd [0,0,44]};//Fix for UnderwaterMine going WAY underground
                default {(_x#BP_POS)};
            };

            _mine = createMine [(_x#BP_CLASSNAME),(ASLToAGL _pos),[],0];
            _mine enableDynamicSimulation true;//Doesn't work now but left just in case it would in the future, see: https://community.bistudio.com/wiki/enableDynamicSimulation
            _mine setDir (_x#BP_DIR);

            _minesDirs pushBack (_x#BP_DIR);
            _mine
        };
        [_mines,_minesDirs] call NWG_fnc_ukrpMinesRotateAndAdapt;
        [_mines,_minesDirs] remoteExec ["NWG_fnc_ukrpMinesRotateAndAdapt",-2];//Fix for mines direction in MP
    };

    /*Finalize groups*/
    {
        if (_groupRules param [GRP_RULES_DYNASIM,(NWG_UKREP_Settings get "DEFAULT_GROUP_DYNASIM")])
            then {_x enableDynamicSimulation true};//Enable dynamic simulation
        if (_groupRules param [GRP_RULES_DISABLEPATH,(NWG_UKREP_Settings get "DEFAULT_GROUP_DISABLEPATH")])
            then {{_x disableAI "PATH"} forEach (units _x)};//Disable pathfinding for all units

        _x setVariable ["NWG_UKREP_ownership",true];//Mark as UKREP group
    } forEach (([_rootGroup] + _addGroups) select {!isNull _x});

    /*Finalize helpers*/
    if ((count _hlprs) > 0) then {
        {_x setvariable ["BIS_fnc_initModules_activate",true]} forEach _hlprs;
    };

    //return
    [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
};

NWG_UKREP_CreateObject = {
    // params ["_objType","_classname","_pos","_posOffset","_dir","_dirOffset","_payload","_inside"];
    private _classname = _this#BP_CLASSNAME;
    private _pos = _this#BP_POS;
    private _dir = _this#BP_DIR;

    //Create
    private _object = switch (_this#BP_PAYLOAD) do {
        /*Simple*/
        case OBJ_SIMPLE: {
            private _obj = createSimpleObject [_classname,_pos];
            _obj setDir _dir;
            _obj setPosASL _pos;//Fix postion distortion after setDir
            _obj
        };
        /*Static*/
        case OBJ_STATIC: {
            private _obj = createVehicle [_classname,(ASLToATL _pos),[],0,"CAN_COLLIDE"];
            _obj setDir _dir;
            _obj setPosASL _pos;
            _obj enableSimulationGlobal false;
            _obj allowDamage false;
            _obj
        };
        /*Interactable*/
        case OBJ_INTERACTABLE: {
            private _obj = createVehicle [_classname,(ASLToATL _pos),[],0,"CAN_COLLIDE"];
            _obj setDir _dir;
            _obj setPosASL _pos;
            _obj enableDynamicSimulation true;
            _obj
        };
        /*Error*/
        default {
            (format ["NWG_UKREP_CreateObject: Unknown object payload %1",_this]) call NWG_fnc_logError;
            private _obj = createVehicle [_classname,(ASLToATL _pos),[],0,"CAN_COLLIDE"];
            _obj setDir _dir;
            _obj setPosASL _pos;
            _obj
        };
    };

    //return
    _object
};