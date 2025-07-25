#include "..\..\globalDefines.h"

//Get item type
NWG_ICAT_GetItemType_cache = createHashMap;
NWG_ICAT_GetItemType = {
    private _item = _this;
    if (_item isEqualType objNull) then {_item = typeOf _item};

    //Check strange error with looting underwater corpse
    if !(_item isEqualType "") exitWith {
        (format ["NWG_ICAT_GetItemType: Invalid item type for item '%1'",_item]) call NWG_fnc_logError;
        ""
    };

    //Check cache
    private _cached = NWG_ICAT_GetItemType_cache get _item;
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
                        then {LOOT_ITEM_TYPE_ITEM}/*Binoculars and such*/
                        else {LOOT_ITEM_TYPE_WEAP}
                };
                case (isClass (_cfg >> "ItemInfo")) : {
                    if ((getNumber (_cfg >> "ItemInfo" >> "type")) in [801,701,605])/*Magic numbers by Claude AI*/
                        then {LOOT_ITEM_TYPE_CLTH}
                        else {LOOT_ITEM_TYPE_ITEM}
                };
                default {LOOT_ITEM_TYPE_ITEM};//Default to ITEM
            }
        };
        case "CfgMagazines": {
            //Ammo mostly, but also some of the loot items from Oldman (those that can be 'used')
            if ((getText (_cfg >> "ammo")) isEqualTo "")
                then {LOOT_ITEM_TYPE_ITEM}/*Loot items*/
                else {LOOT_ITEM_TYPE_AMMO}/*Ammo*/
        };
        case "CfgGlasses": {
            //Glasses and goggles
            LOOT_ITEM_TYPE_ITEM
        };
        case "CfgVehicles": {
            //Backpacks
            if ((getText (_cfg >> "assembleInfo" >> "assembleTo")) isNotEqualTo "" || {
                (getText (_cfg >> "editorSubcategory")) isEqualTo "EdSubcat_DismantledWeapons"})
                then {LOOT_ITEM_TYPE_WEAP}/*UAV/UGV and weapon backpacks*/
                else {LOOT_ITEM_TYPE_CLTH}/*Regular backpacks*/
        };
        default {
            //Return empty string if not found in configs (how is that even possible?)
            (format["NWG_ICAT_GetItemType: Not found in configs: %1",_item]) call NWG_fnc_logError;
            ""
        };
    };

    //Cache and return
    NWG_ICAT_GetItemType_cache set [_item,_itemType];
    _itemType
};

//BIS_fnc_basicBackpack (reworked)
NWG_ICAT_GetBaseBackpack_cache = createHashMap;
NWG_ICAT_GetBaseBackpack = {
    private _input = _this;

    //Check cache
    private _cached = NWG_ICAT_GetBaseBackpack_cache get _input;
    if (!isNil "_cached") exitWith {_cached};

    //Check if it's a backpack
    if !(isClass (configFile >> "CfgVehicles" >> _input)) exitWith {
        NWG_ICAT_GetBaseBackpack_cache set [_input,_input];
        _input
    };//Not a backpack

    //Check if it is already basic (has no cargo predefined)
    private _fn_hasCargo = {
        // private _input = _this;
        private _hasCargo = false;
        {
            if (count (_x call Bis_fnc_getCfgSubClasses) > 0)
                exitWith {_hasCargo = true};
        }
        forEach [
            (configFile >> "CfgVehicles" >> _this >> "TransportItems"),
            (configFile >> "CfgVehicles" >> _this >> "TransportMagazines"),
            (configFile >> "CfgVehicles" >> _this >> "TransportWeapons")
        ];

        _hasCargo
    };
    if !(_input call _fn_hasCargo) exitWith {
        NWG_ICAT_GetBaseBackpack_cache set [_input,_input];
        _input
    };//Backpack has no cargo - already basic

    //Find 'parent' without cargo
    private _output = "";
    private _parents = [configFile >> "CfgVehicles" >> _input, true] call BIS_fnc_returnParents;
    private _i = _parents findIf {!(_x call _fn_hasCargo) && {(getNumber (configFile >> "CfgVehicles" >> _x >> "scope")) == 2}};
    if (_i != -1) then {_output = _parents select _i};//Can it return ""? Let's be extra cautious and assume it can

    //Special case
    if (_output isEqualTo "") then {
        _output = if (_input == "b_kitbag_rgr_exp")/*'==' for case-insensitive comparison*/
            then {"b_kitbag_rgr"}/*Some unnamed border case, taken from original 'as is'*/
            else {_input};
    };

    //Cache and return
    NWG_ICAT_GetBaseBackpack_cache set [_input,_output];
    _output
};

//BIS_fnc_baseWeapon (reworked)
NWG_ICAT_GetBaseWeapon_cache = createHashMap;
NWG_ICAT_GetBaseWeapon = {
    private _input = _this;

    //Check cache
    private _cached = NWG_ICAT_GetBaseWeapon_cache get _input;
    if (!isNil "_cached") exitWith {_cached};

    //Check if it's a weapon
    private _cfg = configFile >> "CfgWeapons" >> _input;
    if !(isClass _cfg) exitWith {
        NWG_ICAT_GetBaseWeapon_cache set [_input,_input];
        _input
    };//Not a weapon

    //Get manual base weapon
    private _base = getText (_cfg >> "baseWeapon");
    if (isClass (configFile >> "CfgWeapons" >> _base)) exitWith {
        NWG_ICAT_GetBaseWeapon_cache set [_input,_base];
        _base
    };//Base weapon found

    //Get first parent without any attachments
    private _return = _input;
    {
        if (count (_x >> "linkeditems") == 0) exitWith {_return = configname _x};
    } foreach (_cfg call BIS_fnc_returnParents);

    //Cache and return
    NWG_ICAT_GetBaseWeapon_cache set [_input,_return];
    _return
};