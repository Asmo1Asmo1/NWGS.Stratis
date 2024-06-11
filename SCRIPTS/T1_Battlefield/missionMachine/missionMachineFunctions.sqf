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

//=============================================================================
/*Debug*/
//Shows the current state of the mission machine
//returns: string
NWG_fnc_mmShowStatus = {
    NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName
};