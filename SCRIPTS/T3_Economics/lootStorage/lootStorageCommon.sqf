#include "..\..\globalDefines.h"

/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

//=============================================================================
// Get/Set functions for player's loot
NWG_LS_COM_GetPlayerLoot = {
    //private _unit = _this;
    _this getVariable ["NWG_LS_LootStorage",LOOT_ITEM_DEFAULT_CHART];
};

NWG_LS_COM_SetPlayerLoot = {
    params ["_unit","_lootArray"];
    if !(_lootArray isEqualTypeArray LOOT_ITEM_DEFAULT_CHART) exitWith {
        (format["NWG_LS_COM_SetPlayerLoot: Invalid loot array '%1' for unit '%2'",_lootArray,_unit]) call NWG_fnc_logError;
        false
    };

    //Set new loot
    private _publicFlag = if (isServer) then {[(owner _unit),2]} else {[clientOwner,2]};
    _unit setVariable ["NWG_LS_LootStorage",_lootArray,_publicFlag];

    //Raise event
    if (local _unit && {_unit isEqualTo player}) then {
        [EVENT_ON_LOOT_CHANGED,_lootArray] call NWG_fnc_raiseClientEvent;
    };
};