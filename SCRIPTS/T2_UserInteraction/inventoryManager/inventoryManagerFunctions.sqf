//Checks if the player has a specific item in his inventory
//params:
//_itemClassname: String - the classname of the item to check
//returns:
// Boolean - true if the player has the item, false otherwise
NWG_fnc_invHasItem = {
    // private _itemClassname = _this;
    _this call NWG_INV_HasItem
};

//Gets count of an item in the player's inventory
//params:
//_itemClassname: String - the classname of the item to check
//returns:
// Number - the count of the item in the player's inventory
NWG_fnc_invGetItemCount = {
    // private _itemClassname = _this;
    _this call NWG_INV_GetItemCount
};

//Removes an item from the player's inventory
//params:
//_itemClassname: String - the classname of the item to remove
//returns:
// Boolean - true if the item was removed, false otherwise
NWG_fnc_invRemoveItem = {
    // private _itemClassname = _this;
    _this call NWG_INV_RemoveItem
};

//Adds an item to the player's inventory
//params:
//_itemClassname: String - the classname of the item to add
//returns:
// Boolean - true if the item was added, false otherwise
NWG_fnc_invAddItem = {
    // private _itemClassname = _this;
    _this call NWG_INV_AddItem
};

//Exchanges an item in the player's inventory
//params:
//_oldItem: String - the classname of the item to remove
//_newItem: String - the classname of the item to add
//returns:
// Boolean - true if the item was exchanged, false otherwise
NWG_fnc_invExchangeItem = {
    // params ["_oldItem","_newItem"];
    _this call NWG_INV_ExchangeItem
};

//Invoke inventory change check
//note: use it when doing 'setUnitLoadout' on player
NWG_fnc_invInvokeChangeCheck = {
    call NWG_INV_CheckLoadoutChange;
};