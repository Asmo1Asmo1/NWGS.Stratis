#include "..\..\globalDefines.h"
#include "ukrepDefines.h"

// call NWG_UKREP_VectorMathTest
NWG_UKREP_VectorMathTest = {
    //Determine if previous algorithm and new one give exact same results
    private _rootPos = [0.3428,0.1775,0.1693];
    private _curPos  = [0.8342,0.1346,0.7526];

    private _oldOffset = [
        ((_curPos#0)-(_rootPos#0)),
        ((_curPos#1)-(_rootPos#1)),
        ((_curPos#2)-(_rootPos#2))
    ];
    private _newOffset = _curPos vectorDiff _rootPos;

    private _oldPos = [
        ((_rootPos#0)+(_oldOffset#0)),
        ((_rootPos#1)+(_oldOffset#1)),
        ((_rootPos#2)+(_oldOffset#2))
    ];
    private _newPos = _rootPos vectorAdd _newOffset;

    //return
    [(_oldOffset isEqualTo _newOffset),(_oldPos isEqualTo _newPos)]
};

//================================================================================================================
//================================================================================================================
//Test utils
NWG_UKREP_TEST_placedObjects = [];
NWG_UKREP_TEST_Clear = {
    if (NWG_UKREP_TEST_placedObjects isNotEqualTo [])
        then {[] call NWG_fnc_gcDeleteMission};
    NWG_UKREP_TEST_placedObjects resize 0;
};

//================================================================================================================
//================================================================================================================
//FRACTAL placement
// call NWG_UKREP_FRACTAL_PlaceFractalABS_Test
NWG_UKREP_FRACTAL_PlaceFractalABS_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_FRACTAL_PlaceFractalABS = {
    // params ["_fractalSteps",["_faction",""],["_groupRules",[]],["_mapObjectsLimit",-1]];
    private _fractalSteps = [
        ["testUkrep","FRACTAL_ROOT"],
        ["testUkrep","FRACTAL_SUB"]
    ];
    private _result = [_fractalSteps,"NATO"] call NWG_UKREP_FRACTAL_PlaceFractalABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_FRACTAL_PlaceFractalREL_Test
NWG_UKREP_FRACTAL_PlaceFractalREL_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_FRACTAL_PlaceFractalREL = {
    // params ["_pos","_dir","_fractalSteps",["_faction",""],["_groupRules",[]],["_clearTheArea",true]];
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _fractalSteps = [
        ["testUkrep","FRACTAL_ROOT"],
        ["testUkrep","FRACTAL_SUB"]
    ];
    private _result = [_pos,_dir,_fractalSteps,"NATO"] call NWG_UKREP_FRACTAL_PlaceFractalREL;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

//================================================================================================================
//================================================================================================================
//Public placement
// call NWG_UKREP_PUBLIC_PlaceABS_Test
NWG_UKREP_PUBLIC_PlaceABS_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceABS = {
    // params ["_cataloguePage",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction",""],["_groupRules",[]]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_blueprintName] call NWG_UKREP_PUBLIC_PlaceABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_PUBLIC_PlaceABS_TestChances
NWG_UKREP_PUBLIC_PlaceABS_TestChances = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceABS = {
    // params ["_cataloguePage",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction",""],["_groupRules",[]]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_blueprintName,[],[0.5,0.5,0.5,0.5,0.5,0.5,0.5]] call NWG_UKREP_PUBLIC_PlaceABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_PUBLIC_PlaceABS_TestFaction
NWG_UKREP_PUBLIC_PlaceABS_TestFaction = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceABS = {
    // params ["_cataloguePage",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction",""],["_groupRules",[]]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_blueprintName,[],[],"NATO"] call NWG_UKREP_PUBLIC_PlaceABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_PUBLIC_PlaceREL_Position_Test
NWG_UKREP_PUBLIC_PlaceREL_Position_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceREL_Position = {
    // params ["_cataloguePage","_pos","_dir",["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _result = [_cataloguePage,_pos,_dir,_blueprintName] call NWG_UKREP_PUBLIC_PlaceREL_Position;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// test1 call NWG_UKREP_PUBLIC_PlaceREL_Object_Test
NWG_UKREP_PUBLIC_PlaceREL_Object_Test = {
    private _object = _this;
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceREL_Object = {
    // params ["_cataloguePage","_object",["_objectType",""],["_blueprintName",""],["_chances",[]],["_faction",""],["_groupRules",[]],["_adaptToGround",true]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_object,"",_blueprintName] call NWG_UKREP_PUBLIC_PlaceREL_Object;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

//================================================================================================================
//================================================================================================================
//Zaselenie test

// [300,""] call NWG_UKREP_ZASELENIE_Test
// [300,"NATO"] call NWG_UKREP_ZASELENIE_Test
NWG_UKREP_ZASELENIE_Test = {
    params ["_radius","_faction"];
    call NWG_UKREP_TEST_Clear;
    NWG_UKREP_TEST_placedObjects = [[],[],[],[],[],[],[]];
    private _mapObjects = (player nearObjects _radius) select {_x call NWG_fnc_ocIsBuilding || {_x call NWG_fnc_ocIsFurniture}};

    //forEach map objects
    {
        private _objectType = if (_x call NWG_fnc_ocIsBuilding) then {OBJ_TYPE_BLDG} else {OBJ_TYPE_FURN};
        private _pageName = ["AUTO",_x,_objectType] call NWG_UKREP_FRACTAL_AutoGetPageName;
        if !([_x,_objectType,_pageName,""] call NWG_UKREP_FRACTAL_HasRelSetup) then {continue};
        private _result = [_pageName,_x,_objectType,"",[],_faction] call NWG_UKREP_PUBLIC_PlaceREL_Object;
        if (_result isEqualTo false) then {continue};
        {(NWG_UKREP_TEST_placedObjects#_forEachIndex) append _x} forEach _result;
    } forEach _mapObjects;

    NWG_UKREP_TEST_placedObjects
};