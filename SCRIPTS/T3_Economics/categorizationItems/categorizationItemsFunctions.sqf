//Gets NWGS LOOT_ITEM_TYPE (see SCRIPTS\globalDefines.h)
//note: should be applied to inventory items only
//params: _item - item to get type of (string for classname or object)
//returns: string - NWGS ITEM_TYPE (LOOT_ITEM_TYPE_CLTH|LOOT_ITEM_TYPE_WEAP|LOOT_ITEM_TYPE_ITEM|LOOT_ITEM_TYPE_AMMO)
NWG_fnc_icatGetItemType = {
    // private _item = _this;
    _this call NWG_ICAT_GetItemType
};

//Returns base backpack classname (if applicable) - backpack without cargo and specializations for which input is a variation (inheritor) of
//note: this function is a rework of BIS_fnc_basicBackpack
//params: _classname - classname of backpack to process
//returns: string - classname of base backpack or input itself if not a backpack or is already a base
NWG_fnc_icatGetBaseBackpack = {
    _this call NWG_ICAT_GetBaseBackpack
};

//Returns base weapon classname (if applicable) - weapon without attachments and ammo for which input is a variation (inheritor) of
//note: this function is a rework of BIS_fnc_baseWeapon
//params: _classname - classname of weapon to process
//returns: string - classname of base weapon or input itself if not a weapon or is already a base
NWG_fnc_icatGetBaseWeapon = {
    _this call NWG_ICAT_GetBaseWeapon
};
