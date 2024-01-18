/*
Check globalDefines for a list of known states
*/

//Returns the saved state of the mission
// params: state - string key
// returns: anything set before or nil if not set
NWG_fnc_shGetState = {
    // private _sate = _this;
    _this call NWG_STHLD_GetState
};

//Saves the state for the mission
// params:
//  state - string key
//  value - anything
NWG_fnc_shSetState = {
    params ["_state","_value"];
    _this call NWG_STHLD_SetState;
};