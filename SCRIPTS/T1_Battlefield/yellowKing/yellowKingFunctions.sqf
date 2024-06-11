//=============================================================================
/*Server->Server*/

//Enables the YK system
//returns: true on success, false if already enabled
NWG_fnc_ykEnable = {
    call NWG_YK_Enable
};

//Disables the YK system
//returns: true on success, false if already disabled
NWG_fnc_ykDisable = {
    call NWG_YK_Disable
};

//Configures the YK system
//params:
//  _kingSide: which kills to react to (east, west, guer) (default: west)
//  _reinfSide: side of reinforcements (east, west, guer) (default: same as _kingSide)
//  _reinfFaction: faction of reinforcements (default: "NATO")
//  _reinfMap: map of reinforcement spawn points (default: generate on each reinforcement)
NWG_fnc_ykConfigure = {
    // params ["_kingSide","_reinfSide","_reinfFaction","_reinfMap"];
    _this call NWG_YK_Configure;
};

//Returns a total killcount recorded by YK for that session (between enable and disable)
//returns: total killcount
NWG_fnc_ykGetTotalKillcount = {
    NWG_YK_killCountTotal
};