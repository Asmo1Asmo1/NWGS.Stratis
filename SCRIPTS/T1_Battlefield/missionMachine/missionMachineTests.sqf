#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
// Display all the missions available for that map
// call NWG_MIS_SER_ShowAllMissionsOnMap
NWG_MIS_SER_ShowAllMissionsOnMap = {
    call NWG_fnc_testClearMap;

    private _pageName = "Abs" + (call NWG_fnc_wcGetWorldName);
    private _blueprints = [_pageName] call NWG_fnc_ukrpGetBlueprintsABS;
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    if (count _blueprints == 0) exitWith {"No missions available for this map"};

    private ["_pos","_rad","_markerName","_marker"];
    //forEach blueprint container:
    {
        _pos = _x select 2;
        _rad = _x select 4;
        _markerName = format ["%1_%2",_pageName,_forEachIndex];
        _marker = createMarker [_markerName,_pos];
        _marker setMarkerSize [_rad,_rad];
        _marker setMarkerShape "ELLIPSE";
    } forEach _blueprints;
};

//================================================================================================================
//================================================================================================================
// Mark all the buildings that were decorated
//Keep it disabled - getting map objects into array long-term may lead to issues, so enable it ONLY when needed
#define BLDG_MARK_DECORATION_TEST true
NWG_MIS_SER_decoratedBuildings = [];
if (BLDG_MARK_DECORATION_TEST) then {
    [EVENT_ON_UKREP_OBJECT_DECORATED,{
        params ["_obj","_objType"/*,"_ukrepResult"*/];
        if (_objType isEqualTo OBJ_TYPE_BLDG) then {NWG_MIS_SER_decoratedBuildings pushBack _obj};
    }] call NWG_fnc_subscribeToServerEvent;
};

// call NWG_MIS_SER_ShowDecoratedBuildings
NWG_MIS_SER_ShowDecoratedBuildings = {
    //There are 2 arrays of buildings and 3 possible combinations of them:
    private _decoratedBuildings = NWG_MIS_SER_decoratedBuildings;
    private _occupiedBuildings = call NWG_fnc_shGetOccupiedBuildings;

    //1. Decorated AND occupied
    private _decAndOcc = _decoratedBuildings arrayIntersect _occupiedBuildings;
    //2. Decorated but not occupied
    private _decNotOcc = _decoratedBuildings - _decAndOcc;
    //3. Occupied but not decorated
    private _occNotDec = _occupiedBuildings  - _decAndOcc;

    //Prepare script
    private _counter = 0;
    private _markBuilding = {
        params ["_bldg","_color"];
        private _markerName = format ["bldg_mrk_%1",_counter];
        _counter = _counter + 1;
        _marker = createMarker [_markerName,_bldg];
        _marker setMarkerShape "icon";
        _marker setMarkerSize [1.25,1.25];
        _marker setMarkerType "loc_Tourism";
        _marker setMarkerColor _color;
    };

    //Mark buildings
    {[_x,"ColorBlack"] call _markBuilding} forEach _decAndOcc;
    {[_x,"ColorRed"] call _markBuilding} forEach _decNotOcc;
    {[_x,"ColorGreen"] call _markBuilding} forEach _occNotDec;
};

//================================================================================================================
//================================================================================================================
// Place a mission on the map
// ["LZConnor","NATO"] spawn NWG_MIS_SER_PlaceMissionOnMap
NWG_MIS_SER_PlaceMissionOnMap = {
    params [["_missionNameFilter",""],["_faction",""]];
    private _pageName = "Abs" + (call NWG_fnc_wcGetWorldName);
    private _blueprints = [_pageName,_missionNameFilter] call NWG_fnc_ukrpGetBlueprintsABS;
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    if (count _blueprints == 0) exitWith {"No missions available for this map"};

    // NWG_fnc_ukrpBuildFractalABS
    // params ["_fractalSteps",["_faction",""],["_mapBldgsLimit",10],["_overrides",createHashMap]];
    // _fractalStep params [["_pageName",""],["_chances",[]],["_groupRules",[]],["_blueprintNameFilter",""],["_blueprintPosFilter",[]]];

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
        /*root:*/[/*pageName:*/_pageName,_rootChances,[],_missionNameFilter],
        /*bldg:*/[/*pageName:*/"AUTO",_bldgChances],
        /*furn:*/[/*pageName:*/"AUTO",_furnChances]
    ];
    private _result = [_fractalSteps,_faction] call NWG_fnc_ukrpBuildFractalABS;
    _result
};