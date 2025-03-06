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
        _marker = createMarkerLocal [_markerName,_pos];
        _marker setMarkerSizeLocal [_rad,_rad];
        _marker setMarkerShape "ELLIPSE";
    } forEach _blueprints;
};

//================================================================================================================
//================================================================================================================
// Force select mission
//note: Will work only in READY state
// call NWG_MIS_SER_ForceSelectMission
NWG_MIS_SER_ForceSelectMission = {
    params ["_missionName",["_level",1],["_faction","NATO"]];
    if (NWG_MIS_CurrentState != MSTATE_READY) exitWith {
        "Not a READY state"
    };

    //Find mission in missions list
    private _missionIndex = NWG_MIS_SER_missionsList findIf {(_x#MLIST_NAME) isEqualTo _missionName};
    if (_missionIndex isEqualTo -1) exitWith {
        format ["Mission '%1' not found in missions list",_missionName]
    };
    private _mission = NWG_MIS_SER_missionsList#_missionIndex;

    //Generate selection
    private _mRad = [(NWG_MIS_SER_Settings get "MISSION_RADIUS_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;
    private _color = (NWG_MIS_SER_Settings get "ENEMY_COLORS") getOrDefault [_faction,"ColorBlack"];
    (call NWG_fnc_wcGetRndDaytime) params ["_time","_timeStr"];
    (call NWG_fnc_wcGetRndWeather) params ["_weather","_weatherStr"];
    private _selection = [
        /*SELECTION_NAME:*/_mission#MLIST_NAME,
        /*SELECTION_LEVEL:*/_level,
        /*SELECTION_INDEX:*/_missionIndex,
        /*SELECTION_POS:*/_mission#MLIST_POS,
        /*SELECTION_RAD:*/_mRad,
        /*SELECTION_FACTION:*/_faction,
        /*SELECTION_COLOR:*/_color,
        /*SELECTION_TIME:*/_time,
        /*SELECTION_TIME_STR:*/_timeStr,
        /*SELECTION_WEATHER:*/_weather,
        /*SELECTION_WEATHER_STR:*/_weatherStr
    ];

    //Emulate selection made
    NWG_MIS_SER_selected = _selection;//Write into global variable
    //The rest will be handled by heartbeat cycle...

    //return to console
    format ["Forced selection made: '%1'",_missionName]
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
        _marker = createMarkerLocal [_markerName,_bldg];
        _marker setMarkerShapeLocal "icon";
        _marker setMarkerSizeLocal [1.25,1.25];
        _marker setMarkerTypeLocal "loc_Tourism";
        _marker setMarkerColor _color;
    };

    //Mark buildings
    {[_x,"ColorBlack"] call _markBuilding} forEach _decAndOcc;
    {[_x,"ColorRed"] call _markBuilding} forEach _decNotOcc;
    {[_x,"ColorGreen"] call _markBuilding} forEach _occNotDec;
};