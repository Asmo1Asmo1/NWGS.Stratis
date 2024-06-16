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

// call NWG_UKREP_NeedForArrayIntersectTest
NWG_UKREP_NeedForArrayIntersectTest = {
    private _mapObjects = (getPosATL player) nearObjects 300;//Get all objects in the area
    private _origCount = count _mapObjects;
    _mapObjects = _mapObjects arrayIntersect _mapObjects;//Remove duplicates
    private _newCount = count _mapObjects;
    [_origCount,_newCount]
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
//Gather - Place Test
NWG_UKREP_TEST_gatheredBlueprint = [];

// 19 call NWG_UKREP_TEST_GPT_Gather
NWG_UKREP_TEST_GPT_Gather = {
    private _radius = _this;
    private _result = _radius call NWG_UKREP_GatherUkrepREL;
    NWG_UKREP_TEST_gatheredBlueprint = _result;
    _result
};

// "NATO" call NWG_UKREP_TEST_GPT_Place
NWG_UKREP_TEST_GPT_Place = {
    private _faction = _this;
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _blueprint = NWG_UKREP_TEST_gatheredBlueprint;

    call NWG_UKREP_TEST_Clear;
    private _result = [(_blueprint#BPCONTAINER_BLUEPRINT),_pos,_dir,[],_faction] call NWG_UKREP_PlaceREL_Position;
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
//FRACTAL placement (simplified, more debug than actual test)
// call NWG_UKREP_FRACTAL_PlaceFractalABS_Test
NWG_UKREP_FRACTAL_PlaceFractalABS_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_FRACTAL_PlaceFractalABS = {
    // params ["_fractalSteps",["_faction",""],["_mapObjectsLimit",10],["_overrides",[]]];
    private _fractalSteps = [
        ["testUkrep",[],[],"FRACTAL_ROOT"],
        ["testUkrep",[],[],"FRACTAL_SUB"]
    ];
    private _result = [_fractalSteps,"NATO"] call NWG_UKREP_FRACTAL_PlaceFractalABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_FRACTAL_PlaceFractalREL_Test
NWG_UKREP_FRACTAL_PlaceFractalREL_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_FRACTAL_PlaceFractalREL = {
    // params ["_pos","_dir","_fractalSteps",["_faction",""],["_clearTheArea",true]];
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _fractalSteps = [
        ["testUkrep",[],[],"FRACTAL_ROOT"],
        ["testUkrep",[],[],"FRACTAL_SUB"]
    ];
    private _result = [_pos,_dir,_fractalSteps,"NATO"] call NWG_UKREP_FRACTAL_PlaceFractalREL;
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

//================================================================================================================
//================================================================================================================
//Fractal+Zaselenie test (closest to actual use)
//! WARNING ! It seems like the engine postpones deletion to the next frame and so the objects are still there when the second test starts
//That is why we use 'spawn' here. Also this is how ukrep is recommended to be run anyway - in a separate thread

// [] spawn NWG_UKREP_FRACTAL_ZASELENIE_REL_Test
NWG_UKREP_FRACTAL_ZASELENIE_REL_Test = {
    call NWG_UKREP_TEST_Clear;
    if (canSuspend) then {sleep 0.1};
    // NWG_UKREP_FRACTAL_PlaceFractalREL = {
    // params ["_pos","_dir","_fractalSteps",["_faction",""],["_clearTheArea",true]];
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _fractalSteps = [
        /*root:*/[/*pageName:*/"testFractal"],
        /*bldg:*/[/*pageName:*/"AUTO"],
        /*furn:*/[/*pageName:*/"AUTO"]
    ];
    _faction = "NATO";
    private _result = [_pos,_dir,_fractalSteps,_faction] call NWG_UKREP_FRACTAL_PlaceFractalREL;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// [] spawn NWG_UKREP_FRACTAL_ZASELENIE_ABS_Test
NWG_UKREP_FRACTAL_ZASELENIE_ABS_Test = {
    call NWG_UKREP_TEST_Clear;
    if (canSuspend) then {sleep 0.1};
    // NWG_UKREP_FRACTAL_PlaceFractalABS = {
    // params ["_fractalSteps",["_faction",""],["_mapObjectsLimit",10],["_overrides",[]]];
    private _fractalSteps = [
        /*root:*/[/*pageName:*/"testFractal"],
        /*bldg:*/[/*pageName:*/"AUTO"],
        /*furn:*/[/*pageName:*/"AUTO"]
    ];
    _faction = "NATO";
    private _result = [_fractalSteps,_faction] call NWG_UKREP_FRACTAL_PlaceFractalABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// [] spawn NWG_UKREP_FRACTAL_ZASELENIE_Chance_Test
NWG_UKREP_FRACTAL_ZASELENIE_Chance_Test = {
    call NWG_UKREP_TEST_Clear;
    if (canSuspend) then {sleep 0.1};

    // NWG_UKREP_FRACTAL_PlaceFractalABS = {
    // params ["_fractalSteps",["_faction",""],["_mapObjectsLimit",10],["_overrides",[]]];
    // _fractalStep params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""],["_blueprintPosFilter",[]]];

    /*
        if ("IgnoreList" in _chance) then {
            private _ignoreList = _chance get "IgnoreList";
            _affectedObjects = _affectedObjects select {!((_x#BP_CLASSNAME) in _ignoreList)};//Modify affected objects array
        };

        private _minPerc  = _chance getOrDefault ["MinPercentage",0.0];
        private _maxPerc  = _chance getOrDefault ["MaxPercentage",1.0];
        private _minCount = _chance getOrDefault ["MinCount",0];
        private _maxCount = _chance getOrDefault ["MaxCount",(count _affectedObjects)];
    */

    private _rootChances = [];//100% all
    private _bldgChances = [
        /*OBJ_TYPE_BLDG:*/1,
        /*OBJ_TYPE_FURN:*/1,
        /*OBJ_TYPE_DECO:*/1,
        /*OBJ_TYPE_UNIT:*/(
            createHashMapFromArray [
                ["MinPercentage",0.5],
                ["MaxPercentage",1.0],
                ["MinCount",1],
                ["MaxCount",20]
            ]
        ),
        /*OBJ_TYPE_VEHC:*/1,
        /*OBJ_TYPE_TRRT:*/(
            createHashMapFromArray [
                ["MinPercentage",0.5],
                ["MaxPercentage",1.0],
                ["MinCount",1],
                ["MaxCount",3]
            ]
        ),
        /*OBJ_TYPE_MINE:*/1
    ];
    private _furnChances = [
        /*OBJ_TYPE_BLDG:*/1,
        /*OBJ_TYPE_FURN:*/1,
        /*OBJ_TYPE_DECO:*/(
            createHashMapFromArray [
                ["IgnoreList",[
                    "Land_PCSet_01_case_F",
                    "Land_PCSet_01_keyboard_F",
                    "Land_PCSet_01_screen_F",
                    "Land_PCSet_Intel_01_F",
                    "Land_PCSet_Intel_02_F",
                    "Land_FlatTV_01_F"
                ]],
                ["MinPercentage",0.45],
                ["MaxPercentage",0.75],
                ["MinCount",2]
            ]
        ),
        /*OBJ_TYPE_UNIT:*/1,
        /*OBJ_TYPE_VEHC:*/1,
        /*OBJ_TYPE_TRRT:*/1,
        /*OBJ_TYPE_MINE:*/1
    ];

    private _fractalSteps = [
        /*root:*/[/*pageName:*/"testFractal",_rootChances],
        /*bldg:*/[/*pageName:*/"AUTO",_bldgChances],
        /*furn:*/[/*pageName:*/"AUTO",_furnChances]
    ];
    _faction = "NATO";
    private _result = [_fractalSteps,_faction] call NWG_UKREP_FRACTAL_PlaceFractalABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};