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

    ["OPTIMIZE_OBJECTS_ON_CREATE",true],//If set to true, script will validate and modify the original object payload for buildings/furniture/decor

    ["DEFAULT_GROUP_SIDE",west],//If group rules not provided - place under this side
    ["DEFAULT_GROUP_DYNASIM",true],//If group rules not provided - place with this dynamic simulation setting

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
    params ["_fractalSteps",["_faction",""],["_groupRules",[]],["_mapObjectsLimit",10]];

    //1. Get root blueprint
    private _fractalStep1 = _fractalSteps param [0,[]];
    _fractalStep1 params [["_pageName",""],["_blueprintName",""],["_chances",[]],["_blueprintPos",[]]];
    private _blueprints = [_pageName,_blueprintName,_blueprintPos] call NWG_UKREP_GetBlueprintsABS;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_FRACTAL_PlaceFractalABS: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintName,_blueprintPos]) call NWG_fnc_logError;
        false//Error
    };
    private _blueprint = [_blueprints,"NWG_UKREP_FRACTAL_PlaceFractalABS"] call NWG_fnc_selectRandomGuaranteed;

    //2. Scan and save objects on the map for steps 2 and 3
    private _mapObjects = if (_mapObjectsLimit > 0) then {
        private _bpPos = _blueprint#BPCONTAINER_POS;
        private _bpRad = _blueprint#BPCONTAINER_RADIUS;
        _bpPos nearObjects _bpRad
    } else {[]};

    //3. Place root blueprint (fractal step 1)
    //We do not use PUBLIC method because we needed bpPos and bpRad from blueprint to get mapObjects
    _blueprint = _blueprint#BPCONTAINER_BLUEPRINT;
    _blueprint = +_blueprint;//Clone
    private _result = [_blueprint,_chances,_faction,_groupRules] call NWG_UKREP_PlaceABS;
    if (_result isEqualTo false) exitWith {false};//Error
    //result is: [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]

    //4. Decorate buildings (fractal step 2)
    private _fractalStep2 = _fractalSteps param [1,_fractalStep1];//Unpack or re-use upper step
    _fractalStep2 params [["_pageName",""],["_blueprintName",""],["_chances",[]]];
    private _placedBldgs = (_result#UKREP_RESULT_BLDGS) select {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup};
    private _mapBldgs = _mapObjects select {_x call NWG_fnc_ocIsBuilding && {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup}};
    if ((count _mapBldgs) > _mapObjectsLimit) then {
        _mapBldgs = _mapBldgs call NWG_fnc_arrayShuffle;//Shuffle
        _mapBldgs resize _mapObjectsLimit;//Limit
    };
    //forEach building
    {
        private _bldgPage = [_pageName,_x,OBJ_TYPE_BLDG] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _bldgResult = [_bldgPage,_x,OBJ_TYPE_BLDG,_blueprintName,_chances,_faction,_groupRules,/*_adaptToGround:*/true,/*_raiseEvent:*/false] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_bldgResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _bldgResult;
        _x call NWG_fnc_shAddOccupiedBuilding;//Mark building as occupied for other subsystems
    } forEach (_placedBldgs + _mapBldgs);

    //5. Decorate furniture (fractal step 3)
    private _fractalStep3 = _fractalSteps param [2,_fractalStep2];//Unpack or re-use upper step
    _fractalStep3 params [["_pageName",""],["_blueprintName",""],["_chances",[]]];
    private _placedFurns = (_result#UKREP_RESULT_FURNS) select {[_x,OBJ_TYPE_FURN,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup};
    private _mapFurns = _mapObjects select {_x call NWG_fnc_ocIsFurniture && {[_x,OBJ_TYPE_FURN,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup}};
    if ((count _mapFurns) > _mapObjectsLimit) then {
        _mapFurns = _mapFurns call NWG_fnc_arrayShuffle;//Shuffle
        _mapFurns resize _mapObjectsLimit;//Limit
    };
    //forEach furniture
    {
        private _furnPage = [_pageName,_x,OBJ_TYPE_FURN] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _adaptToGround = _x call NWG_UKREP_FRACTAL_IsFurnitureOutside;//Adapt chairs around table only if table itself is not inside a building
        private _furnResult = [_furnPage,_x,OBJ_TYPE_FURN,_blueprintName,_chances,_faction,_groupRules,_adaptToGround,/*_raiseEvent:*/false] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_furnResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _furnResult;
    } forEach (_placedFurns + _mapFurns);

    //Raise event
    [EVENT_ON_UKREP_PLACED,_result] call NWG_fnc_raiseServerEvent;

    //return
    _result
};

NWG_UKREP_FRACTAL_PlaceFractalREL = {
    params ["_pos","_dir","_fractalSteps",["_faction",""],["_groupRules",[]],["_clearTheArea",true]];

    //1. Get root blueprint
    private _fractalStep1 = _fractalSteps param [0,[]];
    _fractalStep1 params [["_pageName",""],["_blueprintName",""],["_chances",[]],["_blueprintRoot",[]]];
    private _blueprints = [_pageName,_blueprintName,_blueprintRoot] call NWG_UKREP_GetBlueprintsREL;
    if ((count _blueprints) == 0) exitWith {
        (format ["NWG_UKREP_FRACTAL_PlaceFractalREL: Could not find the blueprint matching the %1:%2:%3",_pageName,_blueprintName,_blueprintRoot]) call NWG_fnc_logError;
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
    _fractalStep2 params [["_pageName",""],["_blueprintName",""],["_chances",[]]];
    //forEach placed building
    {
        private _bldgPage = [_pageName,_x,OBJ_TYPE_BLDG] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _bldgResult = [_bldgPage,_x,OBJ_TYPE_BLDG,_blueprintName,_chances,_faction,_groupRules,/*_adaptToGround:*/true,/*_raiseEvent:*/false] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_bldgResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _bldgResult;
        _x call NWG_fnc_shAddOccupiedBuilding;//Mark building as occupied for other subsystems
    } forEach ((_result#UKREP_RESULT_BLDGS) select {[_x,OBJ_TYPE_BLDG,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup});

    //5. Decorate furniture (fractal step 3)
    private _fractalStep3 = _fractalSteps param [2,_fractalStep2];//Unpack or re-use upper step
    _fractalStep3 params [["_pageName",""],["_blueprintName",""],["_chances",[]]];
    //forEach placed furniture
    {
        private _furnPage = [_pageName,_x,OBJ_TYPE_FURN] call NWG_UKREP_FRACTAL_AutoGetPageName;
        private _adaptToGround = _x call NWG_UKREP_FRACTAL_IsFurnitureOutside;//Adapt chairs around table only if table itself is not inside a building
        private _furnResult = [_furnPage,_x,OBJ_TYPE_FURN,_blueprintName,_chances,_faction,_groupRules,_adaptToGround,/*_raiseEvent:*/false] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_furnResult isEqualTo false) then {continue};//Error
        {(_result#_forEachIndex) append _x} forEach _furnResult;
    } forEach ((_result#UKREP_RESULT_FURNS) select {[_x,OBJ_TYPE_FURN,_pageName,_blueprintName] call NWG_UKREP_FRACTAL_HasRelSetup});

    //Raise event
    [EVENT_ON_UKREP_PLACED,_result] call NWG_fnc_raiseServerEvent;

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
    params ["_object","_objectType","_pageName","_nameFilter"];

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
    if ((_furn call NWG_UKREP_BID_GetID) isNotEqualTo false) exitWith {false};//Is inside a building (has its ID)

    private _raycastFrom = getPosWorld _furn;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _result = (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_furn,objNull,true,-1,"FIRE","VIEW",true]));//Get raycast result
    _result = _result select {_x isEqualType objNull && {!isNull _x && {!(_x isEqualTo _furn)}}};//Filter objects only
    //return
    (count _result) == 0
};

//================================================================================================================
//================================================================================================================
//Public placement
NWG_UKREP_PUBLIC_PlaceABS = {
    params ["_pageName",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction",""],["_groupRules",[]],["_raiseEvent",true]];
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
    if (_raiseEvent) then {[EVENT_ON_UKREP_PLACED,_result] call NWG_fnc_raiseServerEvent};

    //return
    _result
};

NWG_UKREP_PUBLIC_PlaceREL_Position = {
    params ["_pageName","_pos","_dir",["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true],["_raiseEvent",true]];
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
    if (_raiseEvent) then {[EVENT_ON_UKREP_PLACED,_result] call NWG_fnc_raiseServerEvent};

    //return
    _result
};

NWG_UKREP_PUBLIC_PlaceREL_Object = {
    params ["_pageName","_object",["_objectType",""],["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true],["_raiseEvent",true]];
    if (_objectType isEqualTo "") then {_objectType = _object call NWG_fnc_getObjectType};
    private _rootObjFilter = switch (_objectType) do {
        case OBJ_TYPE_BLDG: {_object call NWG_fnc_ocGetSameBuildings};
        case OBJ_TYPE_FURN: {_object call NWG_fnc_ocGetSameFurniture};
        default {[(typeOf _object)]};
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
    if (_raiseEvent) then {[EVENT_ON_UKREP_PLACED,_result] call NWG_fnc_raiseServerEvent};

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
    _blueprint = [_blueprint,_pos,_dir,_adaptToGround,/*_rootExists:*/false,/*_rootBuildingId:*/false] call NWG_UKREP_BP_RELtoABS;
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    //return
    [_blueprint,_groupRules] call NWG_UKREP_PlacementCore
};

NWG_UKREP_PlaceREL_Object = {
    params ["_blueprint","_object",["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    private _rootBuildingId = switch (true) do {
        case ((_object call NWG_UKREP_BID_GetID) isNotEqualTo false): {_object call NWG_UKREP_BID_GetID};//Get existing ID (case: furniture)
        case (_object call NWG_fnc_ocIsBuilding): {_object call NWG_UKREP_BID_GenerateIDFor};//Generate new ID for building (case: building)
        default {false};//No ID needed
    };
    _blueprint = [_blueprint,(getPosASL _object),(getDir _object),_adaptToGround,/*_rootExists:*/true,_rootBuildingId] call NWG_UKREP_BP_RELtoABS;
    _blueprint deleteAt 0;//Remove root from blueprint (already placed)
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    //return
    [_blueprint,_groupRules] call NWG_UKREP_PlacementCore
};

//================================================================================================================
//================================================================================================================
//Building ID
NWG_UKREP_BID_counter = 0;
NWG_UKREP_BID_GenerateID = {
    NWG_UKREP_BID_counter = NWG_UKREP_BID_counter + 1;
    format ["b%1",NWG_UKREP_BID_counter]
};
NWG_UKREP_BID_GenerateIDFor = {
    // private _building = _this;
    private _id = (call NWG_UKREP_BID_GenerateID);
    [_this,_id] call NWG_UKREP_BID_SetID;
    _id
};
NWG_UKREP_BID_GetID = {
    // private _object = _this;
    _this getVariable ["NWG_UKREP_BID",false]
};
NWG_UKREP_BID_SetID = {
    params ["_object","_buildingId"];
    _object setVariable ["NWG_UKREP_BID",_buildingId];
};

//================================================================================================================
//================================================================================================================
//Blueprint manipulation
NWG_UKREP_BP_RELtoABS = {
    params ["_blueprint","_placementPos","_placementDir","_adaptToGround","_rootExists","_rootBuildingId"];
    private _rootOrigDir = (_blueprint#0)#BP_DIR;

    private _result = [];
    private _recursiveRELtoABS = {
        params ["_rootPos","_rootOrigDir","_rootCurDir","_records","_adapt","_buildingId"];

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

            //Apply building ID
            private _bid = _buildingId;
            switch (_x#BP_OBJTYPE) do {
                case OBJ_TYPE_BLDG: {
                    if (_bid isEqualTo false) then {_bid = (call NWG_UKREP_BID_GenerateID)};//Generate new ID
                    _x set [BP_BUILDINGID,_bid]
                };
                case OBJ_TYPE_FURN;
                case OBJ_TYPE_DECO: {
                    if (_bid isNotEqualTo false) then {_x set [BP_BUILDINGID,_bid]};//Apply existing
                };
                default {/*Do nothing*/};
            };

            //Save and continue
            private _inside = _x param [BP_INSIDE,[]];
            if ((count _inside) > 0) then {
                //We need to go deeper
                _x set [BP_INSIDE,[]];
                _result pushBack _x;
                [_absPos,_origDir,_absDir,_inside,false,_bid] call _recursiveRELtoABS;
            } else {
                //We're done
                _result pushBack _x;
            };
        } forEach _records;
    };

    if (_rootExists) then {
        //Root object already exists
        private _rootChunk = [(_blueprint deleteAt 0)];
        [_placementPos,_rootOrigDir,_placementDir,_rootChunk,/*_adaptToGround:*/false,_rootBuildingId] call _recursiveRELtoABS;
        [_placementPos,_rootOrigDir,_placementDir,_blueprint,_adaptToGround,/*_rootBuildingId:*/false] call _recursiveRELtoABS;
        _rootChunk resize 0;//Clear
    } else {
        //Root object does not exist
        [_placementPos,_rootOrigDir,_placementDir,_blueprint,_adaptToGround,/*_rootBuildingId:*/false] call _recursiveRELtoABS;
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
        if ((count _affectedObjects) == 0) then {continue};//Skip if no objects of this type

        private _targetCount = if (_chance isEqualType []) then {
            //Min, max and scale count
            _chance params ["_min","_max",["_scale",100]];
            private _delta = (count _affectedObjects) - _scale;
            if (_delta > 0) then {
                _min = _min + _delta;
                _max = _max + _delta;
            };
            (floor (random (_max-_min+1))) + _min
        } else {
            //Percentage
            round ((count _affectedObjects) * _chance)
        };
        if ((count _affectedObjects) <= _targetCount) then {continue};//Skip if no objects to remove

        _affectedObjects = _affectedObjects call NWG_fnc_arrayShuffle;
        _toRemove append (_affectedObjects select [_targetCount]);
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
    if (_factionPage isEqualTo false) exitWith {_blueprint};//Error

    private ["_classname","_crew","_replacement"];
    {
        _classname = _x#BP_CLASSNAME;

        //Replace classname and payload
        if (_classname in _factionPage) then {
            _replacement = _factionPage get _classname;
            _replacement = if ((count _replacement) > 1)
                then {[_replacement,(format ["NWG_UKREP_BP_ApplyFaction_%1",_classname])] call NWG_fnc_selectRandomGuaranteed}
                else {_replacement param [0,_classname]};
            if (_replacement isEqualType []) then {
                _x set [BP_CLASSNAME,(_replacement#0)];
                _x set [BP_PAYLOAD,(_replacement#1)];
            } else {
                _x set [BP_CLASSNAME,_replacement];
            };
        };

        //Replace crew of the vehicle or turret
        if ((_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_VEHC || {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_TRRT}) then {
            _crew = if ((_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_VEHC)
                then {(_x param [BP_PAYLOAD,[]]) param [0,[]]}
                else {(_x param [BP_PAYLOAD,[]])};
            //do
            {
                if !(_x isEqualType "")  then {continue};
                if !(_x in _factionPage) then {continue};
                _replacement = _factionPage get _x;
                _replacement = if ((count _replacement) > 1)
                    then {[_replacement,(format ["NWG_UKREP_BP_ApplyFaction_%1",_x])] call NWG_fnc_selectRandomGuaranteed}
                    else {_replacement param [0,_x]};
                _replacement = if (_replacement isEqualType []) then {_replacement#0} else {_replacement};
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
NWG_UKREP_PlacementCore = {
    params ["_blueprint",["_groupRules",[]]];

    /*Sort into groups*/
    private _hlprs = []; private _bldgs = []; private _furns = []; private _decos = [];
    private _units = []; private _vehcs = []; private _trrts = []; private _mines = [];
    {
        switch (_x#BP_OBJTYPE) do {
            case "HELP": {_hlprs pushBack _x};
            case OBJ_TYPE_BLDG: {_bldgs pushBack _x};
            case OBJ_TYPE_FURN: {_furns pushBack _x};
            case OBJ_TYPE_DECO: {_decos pushBack _x};
            case OBJ_TYPE_UNIT: {_units pushBack _x};
            case OBJ_TYPE_VEHC: {_vehcs pushBack _x};
            case OBJ_TYPE_TRRT: {_trrts pushBack _x};
            case OBJ_TYPE_MINE: {_mines pushBack _x};
        };
    } forEach _blueprint;
    _blueprint resize 0;//Clear

    /*Place HELP - helper modules*/
    if ((count _hlprs) > 0) then {
        private _hlprsGroup = group (missionNamespace getvariable ["BIS_functions_mainscope",objnull]);
        if (isNull _hlprsGroup) exitWith {};//Failed to obtain
        {
            private _helper = _hlprsGroup createUnit [(_x#BP_CLASSNAME),(_x#BP_POS),[],0,"CAN_COLLIDE"];
            _helper setDir (_x#BP_DIR);
            _helper setPosASL (_x#BP_POS);
            {_helper setVariable _x} forEach (_x#BP_PAYLOAD);
        } forEach _hlprs;
        _hlprs resize 0;//Clear
    };

    /*Place regular objects (BLDG,FURN,DECO) - buildings, furniture, decor*/
    _bldgs = _bldgs apply {_x call NWG_UKREP_CreateObject};
    _furns = _furns apply {_x call NWG_UKREP_CreateObject};
    _decos = _decos apply {_x call NWG_UKREP_CreateObject};

    /*Prepare the group to include units into with lazy evaluation*/
    private _placementGroup = grpNull;
    private _getGroup = {
        if (!isNull _placementGroup) exitWith {_placementGroup};
        _placementGroup = createGroup [
            (_groupRules param [GRP_RULES_SIDE,(NWG_UKREP_Settings get "DEFAULT_GROUP_SIDE")]),
            /*delete when empty:*/true
        ];
        _placementGroup
    };

    /*Place UNIT - units*/
    if ((count _units) > 0) then {
        _units = _units apply {[(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),(_x#BP_PAYLOAD)]};//Repack into func argument
        _units = [_units,(call _getGroup)] call NWG_fnc_spwnSpawnUnitsExact;
    };

    /*Place VEHC - vehicles*/
    _vehcs = _vehcs apply {
        (_x#BP_PAYLOAD) params [["_crew",[]],["_appearance",false],["_pylons",false]];
        private _vehicle = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),_appearance,_pylons] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_vehicle,(call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _vehicle
    };

    /*Place TRRT - turrets*/
    _trrts = _trrts apply {
        private _crew = _x param [BP_PAYLOAD,[]];
        private _turret = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR)] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_turret,(call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _turret
    };

    /*Finalize group*/
    if (!isNull _placementGroup) then {
        _placementGroup enableDynamicSimulation (_groupRules param [GRP_RULES_DYNASIM,(NWG_UKREP_Settings get "DEFAULT_GROUP_DYNASIM")]);
        {_x disableAI "PATH"} forEach (units _placementGroup);//Disable pathfinding for all units
        _placementGroup setVariable ["NWG_UKREP_ownership",true];//Mark as UKREP group
    };

    /*Place MINE - mines*/
    if ((count _mines) > 0) then {
        private _minesDirs = [];//Fix for mines direction in MP
        _mines = _mines apply {
            private _pos = if ((_x#BP_CLASSNAME) isEqualTo "APERSTripMine")
                then {(_x#BP_POS) vectorAdd [0,0,0.1]}
                else {(_x#BP_POS)};//Fix for APERSTripMine

            private _mine = createMine [(_x#BP_CLASSNAME),(ASLToAGL _pos),[],0];
            _mine enableDynamicSimulation true;//Always true
            _mine setDir (_x#BP_DIR);

            _minesDirs pushBack (_x#BP_DIR);
            _mine
        };
        [_mines,_minesDirs] call NWG_fnc_ukrpMinesRotateAndAdapt;
        [_mines,_minesDirs] remoteExec ["NWG_fnc_ukrpMinesRotateAndAdapt",-2];//Fix for mines direction in MP
    };

    //return
    [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
};

NWG_UKREP_CreateObject = {
    // params ["_objType","_classname","_pos","_posOffset","_dir","_dirOffset","_payload","_inside","_buildingId"];
    private _classname = _this#BP_CLASSNAME;
    private _pos = _this#BP_POS;
    private _dir = _this#BP_DIR;
    private _buildingId = _this param [BP_BUILDINGID,false];
    (_this#BP_PAYLOAD) params [["_canSimple",false],["_isSimple",false],["_isSimOn",false],["_isDynaSimOn",false],["_isDmgAllowed",false],["_isInteractable",false]];

    //Optimize settings
    if (NWG_UKREP_Settings get "OPTIMIZE_OBJECTS_ON_CREATE") then {
        if (_canSimple && !_isInteractable) exitWith {_isSimple = true};//Simple object - no interaction or simulation
        if (!_isInteractable) then {_isSimOn = false; _isDynaSimOn = false};
        if (_isSimOn && !_isDynaSimOn) then {_isDynaSimOn = true};
    };

    //Create
    private _obj = if (_isSimple)
        then {createSimpleObject [_classname,_pos]}
        else {createVehicle [_classname,(ASLToATL _pos),[],0,"CAN_COLLIDE"]};
    _obj setDir _dir;
    _obj setPosASL _pos;//Fix postion distortion after setDir for certain objects (buildings especially)

    //Apply settings
    if (!_isSimple) then {
        if (!_isSimOn) then {_obj enableSimulationGlobal false};
        if (_isDynaSimOn) then {_obj enableDynamicSimulation true};
        if (!_isDmgAllowed) then {_obj allowDamage false};
    };

    //Sign
    if (_buildingId isNotEqualTo false) then {[_obj,_buildingId] call NWG_UKREP_BID_SetID};

    //return
    _obj
};