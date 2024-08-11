/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

//=============================================================================
// Global object
NWG_LS_LootStorageObject = objNull;

//=============================================================================
// Get/Set functions for player's loot
NWG_LS_COM_GetPlayerLoot = {
    //private _unit = _this;
    _this getVariable ["NWG_LS_LootStorage",[]];
};

NWG_LS_COM_SetPlayerLoot = {
    params ["_unit","_lootArray"];

    if (isServer) then {
        _unit setVariable ["NWG_LS_LootStorage",_lootArray];//Set for server
        _unit setVariable ["NWG_LS_LootStorage",_lootArray,(owner _unit)];//Set for client
    } else {
        _unit setVariable ["NWG_LS_LootStorage",_lootArray];//Set for client
        _unit setVariable ["NWG_LS_LootStorage",2];//Set for server
    };
};