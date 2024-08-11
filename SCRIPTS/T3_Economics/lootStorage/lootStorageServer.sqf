//=============================================================================
// Global object
NWG_LS_LootStorageObject = objNull;

//=============================================================================
// Init
NWG_LS_SER_Set = {
    // private _storageObject = _this;
    if (isNull _this) exitWith {
        "NWG_LS_SER_Set: Invalid loot storage object" call NWG_fnc_logError;
    };

    //Broadcast the loot storage object to all clients (and add to JIP)
    //Going with 'publicVariable' instead of function calls is more reliable in MP environment
    //...because we can not ensure the execution order of the scripts, JIPs and etc.
    NWG_LS_LootStorageObject = _this;
    publicVariable "NWG_LS_LootStorageObject";
};