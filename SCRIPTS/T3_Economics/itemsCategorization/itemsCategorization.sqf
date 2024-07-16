#include "..\..\globalDefines.h"

// //Items types
// #define ITEM_TYPE_CLTH "CLTH" // Clothing
// #define ITEM_TYPE_WEPN "WEPN"  // Weapon
// #define ITEM_TYPE_ITEM "ITEM"  // Item
// #define ITEM_TYPE_AMMO "AMMO"  // Ammo

NWG_ICAT_itemTypeCache = createHashMap;
NWG_ICAT_GetItemType = {
    private _item = _this;
    if (_item isEqualType objNull) then {_item = typeOf _item};

    //Check cache
    private _cached = NWG_ICAT_itemTypeCache get _item;
    if (!isNil "_cached") exitWith {_cached};

    //Try getting config
    private _cfg = configNull;
    {
        _cfg = configFile >> _x >> _item;
        if (isClass _cfg) exitWith {};
    } forEach ["CfgWeapons","CfgMagazines","CfgVehicles"];

    //Determine item type based on config properties
    private _itemType = switch (true) do {
        case (!isClass _cfg) : {ITEM_TYPE_ITEM};//Default to ITEM if not found in configs
        case (isClass (_cfg >> "ItemInfo")) : {
            switch (getNumber (_cfg >> "ItemInfo" >> "type")) do {
                case 801: {ITEM_TYPE_CLTH}; // Uniform
                case 701: {ITEM_TYPE_CLTH}; // Vest
                case 605: {ITEM_TYPE_CLTH}; // Headgear
                default   {ITEM_TYPE_ITEM};
            }
        };
        case (isClass (_cfg >> "WeaponSlotsInfo")) : {ITEM_TYPE_WEPN};
        case (isNumber (_cfg >> "type")) : {ITEM_TYPE_AMMO};
        default {ITEM_TYPE_ITEM};//Default to ITEM
    };

    //Cache and return
    NWG_ICAT_itemTypeCache set [_item,_itemType];
    _itemType
};