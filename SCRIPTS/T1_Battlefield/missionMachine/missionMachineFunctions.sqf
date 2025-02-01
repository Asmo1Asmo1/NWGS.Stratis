#include "..\..\globalDefines.h"

//=============================================================================
/*Any->Client*/
//Open mission selection UI
NWG_fnc_mmOpenSelectionUI = {
    call NWG_MIS_CLI_RequestMissionSelection
};

//=============================================================================
/*Client->Server*/
//Requests the server to send the mission selection options
NWG_fnc_mmRequestSelectionOptions = {
    call NWG_MIS_SER_OnSelectionOptionsRequest;
};

//Selection made by the client
//params: _selection - int - index of the selected mission
NWG_fnc_mmSelectionMade = {
    // private _selection = _this;
    _this call NWG_MIS_SER_OnSelectionMade;
};

//=============================================================================
/*Server->Client*/
//Sends the mission selection options to the client
//params: _options - array
NWG_fnc_mmSendSelectionOptions = {
    // private _options = _this;
    _this call NWG_MIS_CLI_OnSelectionOptionsReceived;
};

//Confirms the selection made
//params: _missionName - string
NWG_fnc_mmSelectionConfirmed = {
    // private _missionName = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_OnSelectionConfirmed;
};

//Notifies the client that the mission is completed
//params: _missionName - string
NWG_fnc_mmMissionCompleted = {
    // private _missionName = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_OnMissionCompleted;
};

//Plays the music on the client
//params: _music - string
NWG_fnc_mmPlayMusic = {
    // private _music = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_OnPlayMusic;
};

//Notifies the client that escape has been completed
NWG_fnc_mmEscapeCompleted = {
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    call NWG_MIS_CLI_OnEscapeCompleted;
};

//=============================================================================
/*Debug*/
/*
    Example: add to 'watch' field:
    call NWG_fnc_mmGetStatus
*/
//Returns the current state of the mission machine
//returns: string
NWG_fnc_mmGetStatus = {
    NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName
};

//=============================================================================
/*Other systems->Mission machine*/
//Returns player base and its decorations
//note: these exist only on MSTATE_BASE_ECONOMY and MSTATE_BASE_QUESTS mission states, use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: [obj,[array]]
// - obj - persistent player base or objNull if there are none
// - array - decorations in format ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"] or
NWG_fnc_mmGetPlayerBase = {
    [NWG_MIS_SER_playerBase,NWG_MIS_SER_playerBaseDecoration]
};

//Returns mission objects
//note: these exist only on MSTATE_BUILD_ECONOMY, MSTATE_BUILD_DSPAWN and MSTATE_BUILD_QUESTS mission states, use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: [array]
// - array - mission objects in format ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"]
NWG_fnc_mmGetMissionObjects = {
    NWG_MIS_SER_missionObjects
};

//Returns mission faction (defined in globalDefines.h)
//note: this command is reliable only starting from MSTATE_BUILD_UKREP mission state, otherwise it will either return empty string or previous mission faction
//note: use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: string (MISSION_FACTION_NATO, MISSION_FACTION_CSAT, MISSION_FACTION_AAF, ...)
NWG_fnc_mmGetMissionFaction = {
    NWG_MIS_SER_missionInfo getOrDefault ["EnemyFaction",""]
};

//Returns mission side
//note: this command is reliable only starting from MSTATE_BUILD_UKREP mission state, otherwise it will either return empty string or previous mission faction
//note: use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: WEST, EAST, GUER
NWG_fnc_mmGetMissionSide = {
    NWG_MIS_SER_missionInfo getOrDefault ["EnemySide",west]
};

//Returns mission difficulty
//returns: string (MISSION_DIFFICULTY_EASY, MISSION_DIFFICULTY_NORM, ...)
NWG_fnc_mmGetMissionDifficulty = {
    NWG_MIS_SER_missionInfo getOrDefault ["Difficulty",MISSION_DIFFICULTY_NORM]
};

//Returns mission pos
//returns: [pos,rad]
NWG_fnc_mmGetMissionPos = {
    [(NWG_MIS_SER_missionInfo getOrDefault ["Position",[0,0,0]]),(NWG_MIS_SER_missionInfo getOrDefault ["Radius",0])]
};

//Returns if this unit is currently in the base area
//params: _unit - object
//returns: boolean
NWG_fnc_mmIsUnitInBase = {
    // private _unit = _this;
    private _basePos = NWG_MIS_SER_playerBasePos;
    if (_basePos isEqualTo []) exitWith {true};//Fallback to true if base position is not set yet
    private _baseRad = NWG_MIS_SER_Settings get "PLAYER_BASE_RADIUS";
    (_this distance _basePos) <= _baseRad
};

//Returns if this player was on mission
//note: Is safe to use on both client and server sides
//params: _unit - object
//returns: boolean
NWG_fnc_mmWasPlayerOnMission = {
    // private _player = _this;
    _this call NWG_MIS_SER_GetWasOnMission
};
