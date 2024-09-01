//=============================================================================
// Init
private _Init = {
    //Add handlers to catch mission events
    addMissionEventHandler ["EntityRespawned",{_this call NWG_LS_SER_OnPlayerRespawn}];
    addMissionEventHandler ["HandleDisconnect",{_this call NWG_LS_SER_OnPlayerDisconnect}];
};

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

//=============================================================================
// Handlers
NWG_LS_SER_OnPlayerRespawn = {
    // params ["_newEntity","_oldEntity"];
    params ["_player","_corpse"];
    if (!isPlayer _player && {!isPlayer _corpse}) exitWith {};//Ignore non-player entities

    private _loot = _corpse call NWG_fnc_lsGetPlayerLoot;
    if (_loot isEqualTo []) exitWith {};//No loot to transfer

    //Transfer loot to the new entity
    [_player,_loot] call NWG_fnc_lsSetPlayerLoot;
};

NWG_LS_SER_OnPlayerDisconnect = {
    // params ["_unit", "_id", "_uid", "_name"];
    //TODO: Handle player disconnect (send loot to DB)

    //Fix AI replacing player
    false
};

//=============================================================================
call _Init;