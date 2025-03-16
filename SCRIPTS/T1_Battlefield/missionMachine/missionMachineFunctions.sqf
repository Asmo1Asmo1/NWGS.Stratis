#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//=============================================================================
/*Any->Client*/
//Returns array of unlocked levels (lenght of array shows levels count)
//returns: [bool,bool,bool...]
NWG_fnc_mmGetUnlockedLevels = {
    call NWG_MIS_CLI_GetUnlockedLevels
};

//Unlocks a level
//params:
// - _level - int
//returns: boolean (note: true means that checks passed and the request was sent, false - checks failed)
NWG_fnc_mmUnlockLevel = {
    // private _level = _this;
    _this call NWG_MIS_CLI_UnlockLevel;
};

//Requests the server to send the mission selection options for that level
//note: will open the selection UI on values returned by the server
//params: _level - int
//returns: boolean (note: true means that checks passed and the request was sent, false - checks failed)
NWG_fnc_mmOpenMissionSelection = {
    // private _level = _this;
    _this call NWG_MIS_CLI_RequestMissionSelection;
};

//=============================================================================
/*Client->Server*/
//Requests the server to unlock a level
//params: _level - int
NWG_fnc_mmUnlockLevelRequest = {
    // private _level = _this;
    if (!isServer) exitWith {_this remoteExec ["NWG_fnc_mmUnlockLevelRequest",2]};
    _this call NWG_MIS_SER_OnUnlockLevelRequest;
};

//Requests the server to send the mission selection options
//params: _level - int
NWG_fnc_mmSelectionRequest = {
    // private _level = _this;
    if (!isServer) exitWith {_this remoteExec ["NWG_fnc_mmSelectionRequest",2]};
    _this call NWG_MIS_SER_OnSelectionRequest;
};

//Response from the server with the mission selection options
//params: _selectionList - array
NWG_fnc_mmSelectionResponse = {
    // private _selectionList = _this;
    _this call NWG_MIS_CLI_OnSelectionOptionsReceived;
};

//Selection made by the client
//params: _selection - array - item from the selection list
NWG_fnc_mmSelectionMade = {
    // private _selection = _this;
    _this call NWG_MIS_SER_OnSelectionMade;
};

//=============================================================================
/*Server->Client*/
//Displays the mission briefing
//params: _selection - array - item from the selection list
NWG_fnc_mmMissionBriefing = {
    // private _selection = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_ShowMissionBriefing;
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

//Notifies the client that escape has been started
//params: _secondsLeft - number
NWG_fnc_mmEscapeStarted = {
    // private _secondsLeft = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_OnEscapeStarted;
};

//Notifies the client that escape has been completed
//params: _success - boolean
NWG_fnc_mmEscapeCompleted = {
    // private _success = _this;
    if (!hasInterface) exitWith {};//Prevent HC from executing this
    _this call NWG_MIS_CLI_OnEscapeCompleted;
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
/*=== Objects ===*/
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

/*=== Mission Info ===*/
//Returns mission name
//returns: string
NWG_fnc_mmGetMissionName = {
    NWG_MIS_SER_missionInfo getOrDefault [MINFO_NAME,""]
};

//Returns mission level
//returns: number
NWG_fnc_mmGetMissionLevel = {
    NWG_MIS_SER_missionInfo getOrDefault [MINFO_LEVEL,0]
};

//Interpolates min-max according to selected level
//note: this command is reliable only starting from MSTATE_BUILD_UKREP mission state, otherwise it will return default values or values from previous mission
//note: use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//params: _min - number, _max - number
//returns: number
NWG_fnc_mmInterpolateByLevelInt = {
    // params ["_min","_max"];
    private _level = NWG_MIS_SER_missionInfo getOrDefault [MINFO_LEVEL,0];
    [_this,_level] call NWG_MIS_SER_InterpolateInt
};

//Returns if this is a last 'Escape' level
//returns: boolean
NWG_fnc_mmIsEscapeLevel = {
    private _level = NWG_MIS_SER_missionInfo getOrDefault [MINFO_LEVEL,0];
    _level call NWG_MIS_SER_IsEscapeLvl
};

//Returns tiers of this mission
//returns: array of numbers OR empty array if tiers are not set yet
NWG_fnc_mmGetMissionTiers = {
    NWG_MIS_SER_missionInfo getOrDefault [MINFO_TIERS,[]]
};

//Returns mission pos
//returns: [pos,rad]
NWG_fnc_mmGetMissionPos = {
    [(NWG_MIS_SER_missionInfo getOrDefault [MINFO_POSITION,[0,0,0]]),(NWG_MIS_SER_missionInfo getOrDefault [MINFO_RADIUS,0])]
};

//Returns mission side
//note: this command is reliable only starting from MSTATE_BUILD_UKREP mission state, otherwise it will either return empty string or previous mission faction
//note: use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: WEST, EAST, GUER
NWG_fnc_mmGetMissionSide = {
    NWG_MIS_SER_missionInfo getOrDefault [MINFO_ENEMY_SIDE,west]
};

//Returns mission faction (defined in globalDefines.h)
//note: this command is reliable only starting from MSTATE_BUILD_UKREP mission state, otherwise it will either return empty string or previous mission faction
//note: use in EVENT_ON_MISSION_STATE_CHANGED subscriber(s)
//returns: string (e.g.: MISSION_FACTION_NATO )
NWG_fnc_mmGetMissionFaction = {
    NWG_MIS_SER_missionInfo getOrDefault [MINFO_ENEMY_FACTION,""]
};

/*=== Player Checks ===*/
//Returns if this unit is currently in the base area
//params: _player - object
//returns: boolean
NWG_fnc_mmIsPlayerOnBase = {
    // private _player = _this;
    if (isNil "NWG_MIS_SER_playerBase" || {isNull NWG_MIS_SER_playerBase}) exitWith {true};//Fallback to true if base is not set yet
    private _baseRad = NWG_MIS_SER_Settings get "PLAYER_BASE_RADIUS";
    (_this distance NWG_MIS_SER_playerBase) <= _baseRad
};

//Returns if this player was on mission
//note: Is safe to use on both client and server sides
//params: _player - object
//returns: boolean
NWG_fnc_mmWasPlayerOnMission = {
    // private _player = _this;
    _this getVariable ["NWG_MIS_WasOnMission",false]
};

//Returns if this player is inside escape vehicle
//params: _player - object
//returns: boolean
NWG_fnc_mmIsPlayerInEscapeVehicle = {
    // private _player = _this;
    private _escapeVehicle = NWG_MIS_SER_missionInfo getOrDefault [MINFO_ESCAPE_VEHICLE,objNull];
    if (isNull _escapeVehicle) exitWith {false};
    //return
    (vehicle _this) isEqualTo _escapeVehicle
};