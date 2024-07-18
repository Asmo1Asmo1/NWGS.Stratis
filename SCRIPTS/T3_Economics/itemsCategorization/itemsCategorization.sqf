#include "..\..\globalDefines.h"

NWG_ICAT_itemTypeCache = createHashMap;
NWG_ICAT_GetItemType = {
    private _item = _this;
    if (_item isEqualType objNull) then {_item = typeOf _item};

    //Check cache
    private _cached = NWG_ICAT_itemTypeCache get _item;
    if (!isNil "_cached") exitWith {_cached};

    //Try getting config
    private _cfg = configNull;
    private _cfgName = "";
    {
        _cfg = configFile >> _x >> _item;
        if (isClass _cfg) exitWith {_cfgName = _x};//Found
    } forEach ["CfgWeapons","CfgMagazines","CfgGlasses","CfgVehicles"];

    //Determine item type based on config properties
    private _itemType = switch (_cfgName) do {
        case "CfgWeapons": {
            //Most items fall into this category (that's why it's first)
            switch (true) do {
                case (isClass (_cfg >> "WeaponSlotsInfo")) : {
                    if ((getNumber (_cfg >> "type")) == 4096)
                        then {ITEM_TYPE_ITEM}/*Binoculars and such*/
                        else {ITEM_TYPE_WEPN}
                };
                case (isClass (_cfg >> "ItemInfo")) : {
                    if ((getNumber (_cfg >> "ItemInfo" >> "type")) in [801,701,605])/*Magic numbers by Claude AI*/
                        then {ITEM_TYPE_CLTH}
                        else {ITEM_TYPE_ITEM}
                };
                default {ITEM_TYPE_ITEM};//Default to ITEM
            }
        };
        case "CfgMagazines": {
            //Ammo mostly, but also some of the loot items from Oldman (those that can be 'used')
            if ((getText (_cfg >> "ammo")) isEqualTo "")
                then {ITEM_TYPE_ITEM}/*Loot items*/
                else {ITEM_TYPE_AMMO}/*Ammo*/
        };
        case "CfgGlasses": {
            //Glasses and goggles
            ITEM_TYPE_ITEM
        };
        case "CfgVehicles": {
            //Backpacks
            if ((getText (_cfg >> "assembleInfo" >> "assembleTo")) isNotEqualTo "")
                then {ITEM_TYPE_WEPN}/*UAV/UGV and weapon backpacks*/
                else {ITEM_TYPE_CLTH}/*Regular backpacks*/
        };
        default {
            //Default to ITEM if not found in configs
            ITEM_TYPE_ITEM
        };
    };

    //Cache and return
    NWG_ICAT_itemTypeCache set [_item,_itemType];
    _itemType
};