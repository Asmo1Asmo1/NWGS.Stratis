//=============================================================================
// Setup storage object
NWG_LS_SER_SetStorageObject = {
    // private _storageObject = _this;
    if (isNull _this) exitWith {
        "NWG_LS_SER_SetStorageObject: Invalid loot storage object" call NWG_fnc_logError;
    };

    [_this,true] remoteExecCall ["lockInventory",0,_this];//Lock its vanilla inventory
    [_this,"#LS_STORAGE_ACTION_TITLE#",{call NWG_LS_CLI_OpenMyStorage}] call NWG_fnc_addActionGlobal;//Add action
};
