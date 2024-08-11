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