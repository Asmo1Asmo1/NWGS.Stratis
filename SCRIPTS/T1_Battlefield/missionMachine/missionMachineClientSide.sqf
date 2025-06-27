#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_CLI_Settings = createHashMapFromArray [
	["MAP_MIS_MARKER_TYPE","mil_objective"],//Marker type for missions
	["MAP_MIS_MARKER_SIZE",1.25],//Marker size for missions
	["MAP_MIS_OUTLINE_ALPHA",0.6],//Alpha value of outline for missions
    ["MAP_MIS_MARKER_TEXT_TEMPLATE","  %1 : %2 : %3 : %4"],//Template for Name:Faction:Time:Weather of a mission
    ["MAP_MIS_MAPCLICK_MIN_DISTANCE",500],//Map distance to count map click as selection

    ["BRIEFING_INFO_TEMPLATE","%1 - %2 - %3"],//Template for Island:Time:Weather of a mission

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
//Levels and level unlocking
NWG_MIS_CLI_GetUnlockedLevels = {
    if (isNil "NWG_MIS_UnlockedLevels") exitWith {[]};
    //return shallow copy
    (NWG_MIS_UnlockedLevels + [])
};

NWG_MIS_CLI_UnlockLevel = {
    private _level = _this;

    //Check state
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY}) exitWith {
        "NWG_MIS_CLI_UnlockLevel: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError;
        false
    };

    //Check level argument
    private _unlockedLevels = call NWG_MIS_CLI_GetUnlockedLevels;
    if (_level < 0 || _level >= (count _unlockedLevels)) exitWith {
        (format ["NWG_MIS_CLI_UnlockLevel: Invalid level. level:'%1' levels count:'%2'",_level,(count _unlockedLevels)]) call NWG_fnc_logError;
        false
    };
    if (_unlockedLevels param [_level,false]) exitWith {
        (format ["NWG_MIS_CLI_UnlockLevel: Level '%1' is already unlocked",_level]) call NWG_fnc_logError;
        false
    };

    //Send request
    _level remoteExec ["NWG_fnc_mmUnlockLevelRequest",2];

    //return
    true
};

//================================================================================================================
//================================================================================================================
//Missions selection process
NWG_MIS_CLI_RequestMissionSelection = {
    private _level = _this;

    //Check state
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY}) exitWith {
        "NWG_MIS_CLI_RequestMissionSelection: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError;
        false
    };

    //Check level argument
    private _unlockedLevels = call NWG_MIS_CLI_GetUnlockedLevels;
    if (_level < 0 || _level >= (count _unlockedLevels)) exitWith {
        (format ["NWG_MIS_CLI_RequestMissionSelection: Invalid level. level:'%1' levels count:'%2'",_level,(count _unlockedLevels)]) call NWG_fnc_logError;
        false
    };
    if !(_unlockedLevels param [_level,false]) exitWith {
        (format ["NWG_MIS_CLI_RequestMissionSelection: Level '%1' is not unlocked",_level]) call NWG_fnc_logError;
        false
    };

    //Send request
    _level remoteExec ["NWG_fnc_mmSelectionRequest",2];

    //return
    true
};

NWG_MIS_CLI_selectionList = [];
NWG_MIS_CLI_selectionMarkers = [];
NWG_MIS_CLI_OnSelectionOptionsReceived = {
    private _selections = _this;

    //Check state
    if (isNil "NWG_MIS_CurrentState" || {NWG_MIS_CurrentState != MSTATE_READY})
        exitWith {"NWG_MIS_CLI_OnSelectionOptionsReceived: NWG_MIS_CurrentState is not READY" call NWG_fnc_logError};

    //Create markers on the map
    private ["_selName","_selPos","_selRadius","_selFaction","_selColor","_selTime","_selWeather","_markerName","_marker"];
    private _markers = [];
    {
        _selName    = (_x select SELECTION_NAME) call NWG_fnc_localize;
        _selPos     = _x select SELECTION_POS;
        _selRadius  = _x select SELECTION_RAD;
        _selFaction = (_x select SELECTION_FACTION) call NWG_fnc_localize;
        _selColor   = _x select SELECTION_COLOR;
        _selTime    = (_x select SELECTION_TIME_STR) call NWG_fnc_localize;
        _selWeather = (_x select SELECTION_WEATHER_STR) call NWG_fnc_localize;

        //Create background outline marker
        _markerName = format ["selection_outline_%1",_forEachIndex];
        _marker = createMarkerLocal [_markerName,_selPos];
        _marker setMarkerSizeLocal [_selRadius,_selRadius];
        _marker setMarkerShapeLocal "ELLIPSE";
        _marker setMarkerColorLocal _selColor;
        _marker setMarkerAlphaLocal (NWG_MIS_CLI_Settings get "MAP_MIS_OUTLINE_ALPHA");
        _markers pushBack _marker;

        //Create main marker
        _markerName = format ["selection_%1",_forEachIndex];
        _marker = createMarkerLocal [_markerName,_selPos];
        _marker setMarkerTypeLocal (NWG_MIS_CLI_Settings get "MAP_MIS_MARKER_TYPE");
        _marker setMarkerSizeLocal [(NWG_MIS_CLI_Settings get "MAP_MIS_MARKER_SIZE"),(NWG_MIS_CLI_Settings get "MAP_MIS_MARKER_SIZE")];
        _marker setMarkerTextLocal (format [(NWG_MIS_CLI_Settings get "MAP_MIS_MARKER_TEXT_TEMPLATE"),_selName,_selFaction,_selTime,_selWeather]);
        _marker setMarkerColorLocal _selColor;
        _markers pushBack _marker;
    } forEach _selections;

    //Save
    NWG_MIS_CLI_selectionMarkers = _markers;
    NWG_MIS_CLI_selectionList = _selections;

    //Prepare callbacks
    private _onMapClick = {
        private _clickPos = _this;

        //Find the closest selection
        private _minDistance = NWG_MIS_CLI_Settings get "MAP_MIS_MAPCLICK_MIN_DISTANCE";
        private _i = -1;
        private _dist = 0;
        {
            _dist = _clickPos distance2D (_x#SELECTION_POS);
            if (_dist <= _minDistance)
                then {_minDistance = _dist; _i = _forEachIndex};
        } forEach NWG_MIS_CLI_selectionList;
        if (_i == -1) exitWith {};

        //Cache selected mission
        private _selected = NWG_MIS_CLI_selectionList param [_i,[]];
        if (count _selected == 0) exitWith {};

        //Cleanup
        {deleteMarker _x} forEach NWG_MIS_CLI_selectionMarkers;
        NWG_MIS_CLI_selectionList resize 0;
        NWG_MIS_CLI_selectionMarkers resize 0;
        call NWG_fnc_moClose;

        //Send selection
        _selected remoteExec ["NWG_fnc_mmSelectionMade",2];
    };
    private _onMapClose = {
        //Cleanup
        {deleteMarker _x} forEach NWG_MIS_CLI_selectionMarkers;
        NWG_MIS_CLI_selectionList resize 0;
        NWG_MIS_CLI_selectionMarkers resize 0;
    };

    //Open map
    [_onMapClick,_onMapClose] call NWG_fnc_moOpen;
};

//================================================================================================================
//================================================================================================================
//Mission briefing
NWG_MIS_CLI_ShowMissionBriefing = {
    // private _selection = _this;

    private _missionName    = (_this select SELECTION_NAME) call NWG_fnc_localize;
    private _missionFaction = (_this select SELECTION_FACTION) call NWG_fnc_localize;
    private _missionTime    = (_this select SELECTION_TIME_STR) call NWG_fnc_localize;
    private _missionWeather = (_this select SELECTION_WEATHER_STR) call NWG_fnc_localize;

    //Show mission name
    private _subtitle = "#MIS_CLI_BRIEFING_1#" call NWG_fnc_localize;
    private _missionInfo = parseText (format ["<t font='RobotoCondensedBold' size='2'>%1</t><br/>%2", _missionName, _subtitle]);
    [_missionInfo, true, nil, 7, 2, 0] spawn BIS_fnc_textTiles;

    //Delay
    sleep 3;

    //Show mission details
    private _line1 = format [("#MIS_CLI_BRIEFING_2#" call NWG_fnc_localize),_missionFaction];
    private _line2 = format [(NWG_MIS_CLI_Settings get "BRIEFING_INFO_TEMPLATE"),((call NWG_fnc_wcGetWorldNameLocKey) call NWG_fnc_localize),_missionTime,_missionWeather];
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

NWG_MIS_CLI_OnEscapeStarted = {
    private _secondsLeft = _this;
    waitUntil {
        sleep 1;
        _secondsLeft = _secondsLeft - 1;
        hintSilent ([_secondsLeft,"HH:MM:SS"] call BIS_fnc_secondsToString);
        _secondsLeft <= 0
    };
};

NWG_MIS_CLI_OnEscapeCompleted = {
    private _success = _this;
    [/*endName:*/"end2",/*isVictory:*/_success,/*fadeType:*/true,/*playMusic:*/true,/*cancelTasks:*/true] call BIS_fnc_endMission;
};
