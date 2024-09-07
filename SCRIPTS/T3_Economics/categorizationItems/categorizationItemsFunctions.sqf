//Gets NWGS ITEM_TYPE (see SCRIPTS\globalDefines.h)
//note: should be applied to inventory items only
//params: _item - item to get type of (string for classname or object)
//returns: NWGS ITEM_TYPE (ITEM_TYPE_CLTH|ITEM_TYPE_WEPN|ITEM_TYPE_ITEM|ITEM_TYPE_AMMO)
NWG_fnc_icatGetItemType = {
    // private _item = _this;
    _this call NWG_ICAT_GetItemType
};