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
// Place a mission on the map
// ["LZConnor","NATO"] spawn NWG_MIS_SER_PlaceMissionOnMap
NWG_MIS_SER_PlaceMissionOnMap = {
    params [["_missionNameFilter",""],["_faction",""]];
    private _pageName = "Abs" + (call NWG_fnc_wcGetWorldName);
    private _blueprints = [_pageName,_missionNameFilter] call NWG_fnc_ukrpGetBlueprintsABS;
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    if (count _blueprints == 0) exitWith {"No missions available for this map"};

    // NWG_fnc_ukrpBuildFractalABS
    // params ["_fractalSteps",["_faction",""],["_groupRules",[]],["_mapObjectsLimit",10]];
    // _fractalStep params [["_pageName",""],["_blueprintName",""],["_chances",[]],["_blueprintPos",[]]];

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
        /*root:*/[/*pageName:*/_pageName,/*blueprintName:*/_missionNameFilter,_rootChances],
        /*bldg:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",_bldgChances],
        /*furn:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",_furnChances]
    ];
    private _result = [_fractalSteps,_faction] call NWG_fnc_ukrpBuildFractalABS;
    _result
};