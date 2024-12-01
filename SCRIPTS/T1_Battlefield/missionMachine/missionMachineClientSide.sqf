#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_CLI_Settings = createHashMapFromArray [
    ["SELECTION_MARKER_TEXT_TEMPLATE","  %1 : %2"],//Template for Name:Difficulty of a mission
    ["SELECTION_MAPCLICK_MIN_DISTANCE",500],//Map distance to count map click as selection

    ["MISSION_COMPLETED_RELOAD_SELF_HEAL",true],//Call medicine system to reload self-heal chance on mission completion
    ["MISSION_COMPLETED_CELEBRATE",true],//Play sound and show visuals on mission completion
    ["MISSION_COMPLETED_CELEBRATE_MUSIC",[
        "EventTrack01a_F_EPA",
        "EventTrack02a_F_EPA",
        "AmbientTrack02a_F_EXP"
    ]],//Music to play on mission completion

    ["",0]
];

// EventTrack04a_F_EPB - spooky stuff, can we use it?

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

NWG_MIS_CLI_OnSelectionOptionsReceived = {
    private _selections = _this;

    //Check state
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY})
        exitWith {"NWG_MIS_CLI_OnSelectionOptionsReceived: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError};
    if (NWG_MIS_CLI_selectionInProgress)
        exitWith {"NWG_MIS_CLI_OnSelectionOptionsReceived: selection is already in progress" call NWG_fnc_logError};

    //Set state
    NWG_MIS_CLI_selectionInProgress = true;

    //Create markers on the map
    private ["_markerName","_marker"];
    private _markers = [];
    {
        _x params ["_name","_pos","_radius","_difficulty","_markerType","_markerColor","_markerSize","_outlineAlpha"];

        //Localize variables
        _name = _name call NWG_fnc_localize;
        _difficulty = _difficulty call NWG_fnc_localize;

        //Create background outline marker
        _markerName = format ["selection_outline_%1",_forEachIndex];
        _marker = createMarkerLocal [_markerName,_pos];
        _marker setMarkerSizeLocal [_radius,_radius];
        _marker setMarkerShapeLocal "ELLIPSE";
        _marker setMarkerColorLocal _markerColor;
        _marker setMarkerAlpha _outlineAlpha;
        _markers pushBack _marker;

        //Create main marker
        _markerName = format ["selection_%1",_forEachIndex];
        _marker = createMarkerLocal [_markerName,_pos];
        _marker setMarkerTypeLocal _markerType;
        _marker setMarkerSizeLocal [_markerSize,_markerSize];
        _marker setMarkerTextLocal (format [(NWG_MIS_CLI_Settings get "SELECTION_MARKER_TEXT_TEMPLATE"),_name,_difficulty]);
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

//Just a nice visuals to show the progress
NWG_MIS_CLI_OnSelectionConfirmed = {
    // private _missionName = _this;

    //Show mission info
    private _missionName = _this call NWG_fnc_localize;
    private _subtitle = "#MIS_CLI_CONFIRMED_SUBTITLE#" call NWG_fnc_localize;
    private _missionInfo = parseText (format ["<t font='RobotoCondensedBold' size='2'>%1</t><br/>%2", _missionName, _subtitle]);
    [_missionInfo, true, nil, 7, 2, 0] spawn BIS_fnc_textTiles;

    //Delay
    sleep 3;

    //Show player info
    private _line1 = format [("#MIS_CLI_CONFIRMED_PLAYER_TEMPLATE#" call NWG_fnc_localize),(name player)];
    private _line2 = format ["%1: %2",((call NWG_fnc_wcGetWorldNameLocKey) call NWG_fnc_localize),(dayTime call BIS_fnc_timeToString)];
    [
        [
            [_line1, "<t align = 'right' shadow = '1' size = '1'>%1</t><br/>"],
            [_line2, "<t align = 'right' shadow = '1' size = '1'>%1</t><br/>", 25]
        ],0.57,0.85
    ] spawn BIS_fnc_typeText;
};

//================================================================================================================
//================================================================================================================
//Mission completion
//Just a nice visuals to show the progress
NWG_MIS_CLI_OnMissionCompleted = {
    // private _missionName = _this;
    //Reload self-healing success chance
    if (NWG_MIS_CLI_Settings get "MISSION_COMPLETED_RELOAD_SELF_HEAL") then {
        player call NWG_fnc_medReloadSelfHealChance;
    };

    //Celebrate?
    if !(NWG_MIS_CLI_Settings get "MISSION_COMPLETED_CELEBRATE") exitWith {};//No party. No fun =_=

    //Play sound
    private _allSounds = NWG_MIS_CLI_Settings get "MISSION_COMPLETED_CELEBRATE_MUSIC";
    playMusic ([_allSounds,"NWG_MIS_CLI_OnMissionCompleted"] call NWG_fnc_selectRandomGuaranteed);

    sleep 4;

    //Show effects
    [] spawn {
        sleep 1;
        ("NWG_celebrationV" call BIS_fnc_rscLayer) cutRsc ["RscInterlacing","PLAIN",2];
        sleep 5;
        ("NWG_celebrationV" call BIS_fnc_rscLayer) cutRsc ["RscNoise","PLAIN"];
        sleep 0.25;
        ("NWG_celebrationV" call BIS_fnc_rscLayer) cutRsc ["RscStatic","PLAIN"];
        sleep 2;
        ("NWG_celebrationV" call BIS_fnc_rscLayer) cutFadeOut 0;
    };

    //Show message
    call {
        //Option 3: Formatted text in left upper corner (and we have a winner!)
        private _line1 = format ["%1, ",(call NWG_fnc_wcGetWorldNameLocKey) call NWG_fnc_localize];
        private _line2 = _this;//mission name
        private _line3 = format ["%1...",("#MIS_COMPLETED_MESSAGE#" call NWG_fnc_localize)];
        [
            [[_line1, "align = 'left' shadow = '1' size = '0.7' font='PuristaBold'"],
            [ _line2, "align = 'left' shadow = '1' size = '0.7'", "#aaaaaa"],
            ["", "<br/>"],
            [ _line3, "align = 'left' shadow = '1' size = '2.0'"]],
        /*posX:*/-0.5,/*posY:*/nil,nil,nil,nil,nil,/*sound:*/false] spawn BIS_fnc_typeText2;
    }
};

//================================================================================================================
//================================================================================================================
//Escape sequence
NWG_MIS_CLI_OnPlayMusic = {
    // private _music = _this;
    playMusic _this
};

NWG_MIS_CLI_OnEscapeCompleted = {
    ["end2",true,true,false,true] call BIS_fnc_endMission;
};

//================================================================================================================
//================================================================================================================
call _Init;