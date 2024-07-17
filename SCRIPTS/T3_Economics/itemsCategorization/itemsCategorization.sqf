#include "..\..\globalDefines.h"

// //Items types
// #define ITEM_TYPE_CLTH "CLTH" // Clothing
// #define ITEM_TYPE_WEPN "WEPN"  // Weapon
// #define ITEM_TYPE_ITEM "ITEM"  // Item
// #define ITEM_TYPE_AMMO "AMMO"  // Ammo

//This is an updated code, please refer to this from now on, I liked your magic numbers and I'm keeping them
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
            if ((getNumber (_cfg >> "ItemInfo" >> "type")) in [801,701,605])/*Magic numbers by Claude AI*/
                then {ITEM_TYPE_CLTH}
                else {ITEM_TYPE_ITEM}
        };
        case (isClass (_cfg >> "WeaponSlotsInfo")) : {
            if ((getNumber (_cfg >> "type")) == 4096)
                then {ITEM_TYPE_ITEM}/*Binoculars and such*/
                else {ITEM_TYPE_WEPN}
        };
        case ((getText (_cfg >> "vehicleClass")) == "Backpacks"): {/*'==' to keep it case-insensitive*/
            if ((getText (_cfg >> "assembleInfo" >> "assembleTo")) isNotEqualTo "")
                then {ITEM_TYPE_WEPN}/*UAV/UGV and weapon backpacks*/
                else {ITEM_TYPE_CLTH}/*Regular backpacks*/
        };
        case (isNumber (_cfg >> "type")) : {ITEM_TYPE_AMMO};
        case (isNumber (_cfg >> "count")): {ITEM_TYPE_AMMO}; // Additional check for ammo
        default {ITEM_TYPE_ITEM};//Default to ITEM
    };

    //Cache and return
    NWG_ICAT_itemTypeCache set [_item,_itemType];
    _itemType
};