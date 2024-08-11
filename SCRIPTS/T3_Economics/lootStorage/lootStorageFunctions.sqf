/*Other systems->Server*/
//Setup loot storage object
//params: _storageObject - object
NWG_fnc_lsSetLootStorageObject = {
    // private _storageObject = _this;
    _this call NWG_LS_SER_Set;
};