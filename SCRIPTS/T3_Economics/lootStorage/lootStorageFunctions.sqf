/*Other systems->Server*/
//Setup loot storage object (object that gives access to loot storage via action)
//params: _storageObject - object
NWG_fnc_lsSetLootStorageObject = {
    // private _storageObject = _this;
    _this call NWG_LS_SER_SetStorageObject;
};

/*Any->Any*/
//Get loot storage of a player
//params: _player - object
NWG_fnc_lsGetPlayerLoot = {
    // private _player = _this;
    _this call NWG_LS_COM_GetPlayerLoot;
};

//Set loot storage for a player
//params: _player - object
//params: _loot - array
NWG_fnc_lsSetPlayerLoot = {
    // params ["_player","_loot"];
    _this call NWG_LS_COM_SetPlayerLoot;
};