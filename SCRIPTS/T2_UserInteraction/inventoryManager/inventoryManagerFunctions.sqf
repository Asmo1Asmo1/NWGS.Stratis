//Checks if the player has a specific item in his inventory
//params:
//_itemClassname: String - the classname of the item to check
//returns:
// Boolean - true if the player has the item, false otherwise
NWG_fnc_invHasItem = {
    // private _itemClassname = _this;
    _this call NWG_INV_HasItem
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