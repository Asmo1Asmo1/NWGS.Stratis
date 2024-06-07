#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_CLI_Settings = createHashMapFromArray [
    ["SELECTION_MARKER_TEXT_TEMPLATE","  %1 : %2"],//Template for Name:Difficulty of a mission
    ["SELECTION_MARKER_OUTLINE_ALPHA",0.5],//Alpha of the selection markers outline
    ["SELECTION_MARKER_SIZE",1.5],//Size of the selection markers
    ["SELECTION_MAPCLICK_MIN_DISTANCE",500],//Map distance to count map click as selection

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["MapSingleClick",{_this call NWG_MIS_CLI_OnMapClick}];
};

//================================================================================================================
//================================================================================================================
//Missions selection process
NWG_MIS_CLI_selections = [];
NWG_MIS_CLI_selectionMarkers = [];
NWG_MIS_CLI_selectionInProgress = false;

NWG_MIS_CLI_RequestMissionSelection = {
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY})
        exitWith {"NWG_MIS_CLI_RequestMissionSelection: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError};

    [] remoteExec ["NWG_fnc_mmRequestSelectionOptions",2];
};

NWG_MIS_CLI_OnMissionSelectionReceived = {
    private _selections = _this;

    //Check state
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY})
        exitWith {"NWG_MIS_CLI_OnMissionSelectionReceived: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError};
    if (NWG_MIS_CLI_selectionInProgress)
        exitWith {"NWG_MIS_CLI_OnMissionSelectionReceived: selection is already in progress" call NWG_fnc_logError};

    //Set state
    NWG_MIS_CLI_selectionInProgress = true;

    //Create markers on the map
    private ["_markerName","_marker"];
    private _size = NWG_MIS_CLI_Settings get "SELECTION_MARKER_SIZE";
    private _markers = [];
    {
        _x params ["_name","_pos","_rad","_difficulty","_markerType","_markerColor"];

        //Localize variables
        _name = _name call NWG_fnc_localize;
        _difficulty = _difficulty call NWG_fnc_localize;

        //Create background outline marker
        _markerName = format ["selection_outline_%1",_forEachIndex];
        _marker = createMarker [_markerName,_pos];
        _marker setMarkerSize [_rad,_rad];
        _marker setMarkerShape "ELLIPSE";
        _marker setMarkerColor _markerColor;
        _marker setMarkerAlpha (NWG_MIS_CLI_Settings get "SELECTION_MARKER_OUTLINE_ALPHA");
        _markers pushBack _marker;

        //Create main marker
        _markerName = format ["selection_%1",_forEachIndex];
        _marker = createMarker [_markerName,_pos];
        _marker setMarkerType _markerType;
        _marker setMarkerSize [_size,_size];
        _marker setMarkerText (format [(NWG_MIS_CLI_Settings get "SELECTION_MARKER_TEXT_TEMPLATE"),_name,_difficulty]);
        _marker setMarkerColor _markerColor;
        _markers pushBack _marker;
    } forEach _selections;

    //Save
    NWG_MIS_CLI_selectionMarkers = _markers;
    NWG_MIS_CLI_selections = _selections;

    //Force open map
    openMap [true, true];

    //... to be continued in map click handler 'NWG_MIS_CLI_OnMapClick'
};

NWG_MIS_CLI_OnMapClick = {
    // params ["_units","_pos","_alt","_shift"];
    if (!NWG_MIS_CLI_selectionInProgress) exitWith {};
    if ((count NWG_MIS_CLI_selections) == 0) exitWith {};

    //Process the click
    private _clickPos = _this select 1;
    private _minDistance = NWG_MIS_CLI_Settings get "SELECTION_MAPCLICK_MIN_DISTANCE";
    private _i = -1;
    private _dist = 0;
    {
        _dist = _clickPos distance2D (_x#SELECTION_POS);
        if (_dist <= _minDistance)
            then {_minDistance = _dist; _i = _forEachIndex};
    } forEach NWG_MIS_CLI_selections;
    if (_i == -1) exitWith {};

    //Cleanup
    {deleteMarker _x} forEach NWG_MIS_CLI_selectionMarkers;
    NWG_MIS_CLI_selections resize 0;
    NWG_MIS_CLI_selectionMarkers resize 0;
    NWG_MIS_CLI_selectionInProgress = false;

    //Close map
    openMap [true,false];
    openMap false;

    //Send selection
    _i remoteExec ["NWG_fnc_mmSelectionMade",2];
};

//================================================================================================================
//================================================================================================================
call _Init;