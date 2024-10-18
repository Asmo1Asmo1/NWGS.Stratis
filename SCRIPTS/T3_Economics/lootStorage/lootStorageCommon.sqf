/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

//=============================================================================
// Get/Set functions for player's loot
NWG_LS_COM_GetPlayerLoot = {
    //private _unit = _this;
    _this getVariable ["NWG_LS_LootStorage",[[],[],[],[]]];
};

NWG_LS_COM_SetPlayerLoot = {
    params ["_unit","_lootArray"];

    private _publicFlag = if (isServer)
        then {owner _unit}/*Send to affected client*/
        else {2};/*Send to server*/

    _unit setVariable ["NWG_LS_LootStorage",_lootArray,_publicFlag];
};