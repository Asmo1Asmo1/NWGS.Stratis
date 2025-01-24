#include "yellowKingDefines.h"
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
NWG_fnc_ykConfigure = {
    // params ["_kingSide"];
    _this call NWG_YK_Configure;
};

//Returns a total killcount recorded by YK for that session (between enable and disable)
//returns: total killcount
NWG_fnc_ykGetTotalKillcount = {
    NWG_YK_killCountTotal
};

//=============================================================================
/*Debug*/
/*
    Example: add to 'watch' field:
    [call NWG_fnc_ykGetStatus, call NWG_fnc_ykGetTimeToNextReaction]
*/
//Returns the current state of the Yellow King system
//returns: string
NWG_fnc_ykGetStatus = {
    NWG_YK_Status
};

//Returns the time before the next reaction
//returns: time in seconds OR -1 if no reaction is scheduled at the moment
NWG_fnc_ykGetTimeToNextReaction = {
    if (NWG_YK_Status isEqualTo STATUS_PREPARING)
        then {NWG_YK_reactTime - time}
        else {-1}
};