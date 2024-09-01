/*Other systems->Server*/
//Setup loot storage object (object that gives access to loot storage via action)
//params: _storageObject - object
NWG_fnc_lsSetLootStorageObject = {
    // private _storageObject = _this;
    _this call NWG_LS_SER_SetStorageObject;
};

/*UI->Client*/
//Loot the container opened in inventory
//params: "InventoryOpened" event args: ["_unit","_mainContainer","_secdContainer"];
//note: this function must be called from within the inventory UI
//returns: boolean - true if looting was successful, false if not
NWG_fnc_lsLootOpenedContainer = {
    // params ["_unit","_mainContainer","_secdContainer"];
    _this call NWG_LS_CLI_LootByInventoryUI
};

//Notifies loot storage that storage may have changed during UI interaction
NWG_fnc_lsNotifyStorageChanged = {
    call NWG_LS_CLI_OnTakeOrPut;
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