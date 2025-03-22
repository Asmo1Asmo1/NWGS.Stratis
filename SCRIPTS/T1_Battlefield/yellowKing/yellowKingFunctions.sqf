#include "yellowKingDefines.h"
//=============================================================================
/*Server->Server*/

//Enables the YK system
//returns: true on success, false if already enabled
NWG_fnc_ykEnable = {
    call NWG_YK_Enable
};

//Enables berserk mode
//notes:
// 1. Berserk mode is disabled only when entire YK is disabled by 'NWG_fnc_ykDisable'
// 2. In berserk mode YK will attack over and over again without waiting for player actions
// 3. In berserk mode reinforcements are disabled but so are distance restrictions for attacking targets
//params:
//  _selectBy: (optional) predicate to select targets applied to 'NWG_fnc_getPlayersAll' (default: {true})
//returns: true on success, false in case of errors
NWG_fnc_ykGoBerserk = {
    // params [["_selectBy",{true}]];
    _this call NWG_YK_GoBerserk
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
    if (NWG_YK_Enabled) then {NWG_YK_killCountTotal} else {-1}
};