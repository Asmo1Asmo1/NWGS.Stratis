#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_LS_CLI_Settings = createHashMapFromArray [
    ["INVISIBLE_BOX_TYPE","Box_NATO_Uniforms_F"],//Classname of the object that will be used as a loot storage
    ["CLOSE_INVENTORY_ON_LOOT",true],//Should the inventory be closed automatically when loot is taken

    ["AUTO_SELL_LOOT",true],//Should the loot defined in the pricemap be automatically sold on moving to storage (+ on closing the storage just in case)
    ["AUTO_SELL_ON_TAKE",true],//Should the loot be automatically sold when it is taken (uses 'Take' event handler)
    ["AUTO_SELL_PRICE_MAP",createHashMapFromArray [
        ["Money",7000],     /*Big pile of money*/
        ["Money_bunch",150],/*Three $50 notes*/
        ["Money_roll",1000],/*Money roll of $50 notes*/
        ["Money_stack",2500]/*Money stack of $50 notes*/
    ]],//Price map for the loot immediate sell without putting it into storage
    ["AUTO_SELL_ADD_MONEY_FUNCTION",{_this call NWG_fnc_wltAddPlayerMoney}],//Function that adds money to the player params: [_player,_amount]

    ["TRANSFER_LOOT_ON_RESPAWN",false],//Should the loot be transferred to the new player instance on respawn
    ["DEPLETE_LOOT_ON_RESPAWN",false],//Should the loot be deplete on respawn
    ["DEPLETE_MULTIPLIER",0.5],//Multiplier for the loot deplete on respawn
    ["DEPLETE_NOTIFICATION",true],//Should we notify player about the loot depletion

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_LS_CLI_invisibleBox = objNull;
NWG_LS_CLI_storageChanged = false;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Loot storage changes
    player addEventHandler ["InventoryClosed",{call NWG_LS_CLI_OnInventoryClose}];
    player addEventHandler ["InventoryOpened",{_this call NWG_LS_CLI_OnInventoryOpen}];
    player addEventHandler ["Take",{call NWG_LS_CLI_OnInventoryChange}];
    player addEventHandler ["Put",{call NWG_LS_CLI_OnInventoryChange}];
    player addEventHandler ["SlotItemChanged",{call NWG_LS_CLI_OnInventoryChange}];

    //Auto sell on take
    player addEventHandler ["Take",{call NWG_LS_CLI_AutoSellOnTake}];

    //On respawn
    if (NWG_LS_CLI_Settings get "TRANSFER_LOOT_ON_RESPAWN" || {NWG_LS_CLI_Settings get "DEPLETE_LOOT_ON_RESPAWN"}) then {
        player addEventHandler ["Respawn",{_this call NWG_LS_CLI_OnRespawn}];
    };
};

//================================================================================================================
//================================================================================================================
//Storage access
NWG_LS_CLI_OpenMyStorage = {
    //Create new invisible box
    if (!isNull NWG_LS_CLI_invisibleBox)
        then {deleteVehicle NWG_LS_CLI_invisibleBox};
    private _invisibleBox = createVehicleLocal [(NWG_LS_CLI_Settings get "INVISIBLE_BOX_TYPE"),[0,0,0],[],0,"CAN_COLLIDE"];
    _invisibleBox hideObject true;
    _invisibleBox allowDamage false;//Fix for Au who keeps burning it somehow
    _invisibleBox setPosASL (getPosASL player);
    NWG_LS_CLI_invisibleBox = _invisibleBox;

    //Clear the box
    clearWeaponCargo _invisibleBox;
    clearMagazineCargo _invisibleBox;
    clearItemCargo _invisibleBox;
    clearBackpackCargo _invisibleBox;

    //Get player loot
    private _loot = player call NWG_fnc_lsGetPlayerLoot;//=> [["clth1",2,"clth2"],[3,"wepn1"],...]
    _loot = flatten _loot;//Flatten and shallow copy      => ["clth1",2,"clth2",3,"wepn1",...]

    //Put loot into the box
    private _count = 1;
    //forEach ["clth1",2,"clth2",3,"wepn1",...]
    {
        if (_x isEqualType 1) then {_count = _x} else {
            if (isClass (configFile >> "CfgVehicles" >> _x))
                then {_invisibleBox addBackpackCargo [_x,_count]}
                else {_invisibleBox addItemCargo [_x,_count]};
            _count = 1;
        };
    } forEach _loot;

    //Open the box
    NWG_LS_CLI_storageChanged = false;
    player action ["Gear",_invisibleBox];
};

//================================================================================================================
//================================================================================================================
//Storage update via vanilla inventory actions
NWG_LS_CLI_OnInventoryOpen = {
    params ["_unit","_mainContainer","_secdContainer"];
    if (isNull NWG_LS_CLI_invisibleBox) exitWith {};

    //Get containers
    private _containers = [_mainContainer,_secdContainer];
    private _i = _containers findIf {_x isEqualTo NWG_LS_CLI_invisibleBox};
    if (_i == -1) exitWith {};
    private _storage = _containers#_i;
    private _grounds = _containers#(1 - _i);

    //Setup event-based storage change detection
    _storage addEventHandler ["Take",{call NWG_LS_CLI_OnInventoryChange}];
    _storage addEventHandler ["Put", {call NWG_LS_CLI_OnInventoryChange}];
    _grounds addEventHandler ["Take",{call NWG_LS_CLI_OnInventoryChange}];
    _grounds addEventHandler ["Put", {call NWG_LS_CLI_OnInventoryChange}];

    //Setup polling-based storage change detection
    _grounds spawn {
        private _grounds = _this;
        private _timeoutAt = time + 300;//300 seconds = 5 minutes
        private _getFingerprint = {
            [
                (count ((getWeaponCargo _this)   param [0,[]])),
                (count ((getMagazineCargo _this) param [0,[]])),
                (count ((getItemCargo _this)     param [0,[]])),
                (count ((getBackpackCargo _this) param [0,[]]))
            ]
        };
        private _startFingerprint = _grounds call _getFingerprint;

        waitUntil {
            sleep 0.1;
            if (time > _timeoutAt) exitWith {true};
            if (isNull _grounds) exitWith {true};
            if (isNull NWG_LS_CLI_invisibleBox) exitWith {true};
            if (NWG_LS_CLI_storageChanged) exitWith {true};
            if ((_grounds call _getFingerprint) isNotEqualTo _startFingerprint) exitWith {NWG_LS_CLI_storageChanged = true; true};
            false
        };
    };
};

NWG_LS_CLI_OnInventoryChange = {
    if (!isNull NWG_LS_CLI_invisibleBox && {!NWG_LS_CLI_storageChanged})
        then {NWG_LS_CLI_storageChanged = true};
};

NWG_LS_CLI_OnInventoryClose = {
    //Check if we closing the storage object
    if (isNull NWG_LS_CLI_invisibleBox) exitWith {};//Ignore if storage object does not exist

    //Check if storage was modified
    if (NWG_LS_CLI_storageChanged) then {
        //Get storage loot
        private _storageLoot = NWG_LS_CLI_invisibleBox call NWG_LS_CLI_GetAllContainerItems;
        _storageLoot = _storageLoot call NWG_LS_CLI_AutoSell;//Auto sell (just in case something got there)
        _storageLoot = _storageLoot call NWG_LS_CLI_ConvertToLoot;//Convert to loot structure

        //Re-write player loot based on what is left in the box
        [player,_storageLoot] call NWG_fnc_lsSetPlayerLoot;
    };

    //Close the box (will also delete all the items inside)
    deleteVehicle NWG_LS_CLI_invisibleBox;
    NWG_LS_CLI_invisibleBox = objNull;//Reset the variable
    NWG_LS_CLI_storageChanged = false;//Reset the flag
};

//================================================================================================================
//================================================================================================================
//Looting utils
//Returns all container items uncompacted(works with both, the usual containers and units)
//returns: array of strings
NWG_LS_CLI_GetAllContainerItems = {
    private _container = _this;
    private _allContainerItems = [];

    private _scanContainer = {
        private _container = _this;

        //Loot backpacks, clothes, items and ammo
        {
            private _arr = switch (_x) do {
                case 0: {getBackpackCargo _container};
                case 1: {getItemCargo _container};
                case 2: {getMagazineCargo _container};
            };

            _arr params ["_classNames","_counts"];
            for "_i" from 0 to ((count _classNames)-1) do {
                _allContainerItems pushBack (_counts#_i);
                _allContainerItems pushBack (_classNames#_i);
            };
        } forEach [0,1,2];

        //Loot weapons with their attachments and magazines
        private _weapons = weaponsItemsCargo _container;//[["weapon","silencer","flashlight","optics",["mag",30],[],"bipod"],...]
        _weapons = (flatten _weapons) select {_x isEqualType "" && {_x isNotEqualTo ""}};//Flatten and filter
        _allContainerItems append _weapons;
    };

    //Get all items from the container
    if (_container isKindOf "Man") then {

        /*--- Looting the body of a unit ---*/
        private _loadout = getUnitLoadout _container;
        if (_loadout isEqualTo []) exitWith {
            (format ["NWG_LS_CLI_GetAllContainerItems: getUnitLoadout returned [] for unit '%1'",_container]) call NWG_fnc_logError;
        };

        //Extract items from uniform,vest and backpack (they have structure: [class,count])
        for "_i" from 3 to 5 do {
            if ((_loadout#_i) isEqualTo []) then {continue};//Skip empty
            private ["_class","_count"];
            {
                _class = _x param [0,""];
                if (_class isEqualTo "") then {continue};//Skip empty

                //Handle weapons inside uniforms/vests/backpacks
                if (_class isEqualType []) then {
                    {
                        _allContainerItems pushBack 1;
                        _allContainerItems pushBack _x;
                    } forEach ((flatten _class) select {_x isEqualType "" && {_x isNotEqualTo ""}});
                    continue;
                };

                //Handle normal items
                //note: we ignore ammo count inside magazines - not interested (think of it as a free refill)
                _count = _x param [1,1];
                if !(_count isEqualType 1) then {_count = 1};//Fix for backpacks (true/false)
                _allContainerItems pushBack _count;
                _allContainerItems pushBack _class;
            } forEach ((_loadout#_i) deleteAt 1);//Extract what is stored inside
        };

        //Extract everything else that is left in loadout (can be imagined as just a flat list of items)
        _loadout = (flatten _loadout) select {_x isEqualType "" && {_x isNotEqualTo ""}};//Flatten and filter
        _allContainerItems append _loadout;

        //Extract weapons from weapon holders
        {_x call _scanContainer} forEach (call NWG_LS_CLI_GetDeadUnitWeaponHolders);

    } else {

        /*--- Looting regular container (box/vehicle) ---*/
        //Loot every sub-container
        private _subContainers = (everyContainer _container) apply {_x#1};
        {_x call _scanContainer} forEach _subContainers;
        //Loot the container itself
        _container call _scanContainer;

    };

    //Uncompact to array of strings
    _allContainerItems = _allContainerItems call NWG_fnc_unCompactStringArray;

    //return
    _allContainerItems
};

//Returns loot structure from array of strings (still uncompacted)
NWG_LS_CLI_ConvertToLoot = {
    // private _allContainerItems = _this;

    private _loot = LOOT_ITEM_DEFAULT_CHART;
    {
        switch (_x call NWG_fnc_icatGetItemType) do {
            case LOOT_ITEM_TYPE_CLTH: {(_loot#LOOT_ITEM_CAT_CLTH) pushBack (_x call NWG_fnc_icatGetBaseBackpack)};
            case LOOT_ITEM_TYPE_WEAP: {(_loot#LOOT_ITEM_CAT_WEAP) pushBack (_x call NWG_fnc_icatGetBaseWeapon)};
            case LOOT_ITEM_TYPE_ITEM: {(_loot#LOOT_ITEM_CAT_ITEM) pushBack _x};
            case LOOT_ITEM_TYPE_AMMO: {(_loot#LOOT_ITEM_CAT_AMMO) pushBack _x};
            default {
                (format ["NWG_LS_CLI_ConvertToLoot: Item: '%1', Unknown item type: '%2'",_x,(_x call NWG_fnc_icatGetItemType)]) call NWG_fnc_logError;
            };
        };
    } forEach _this;

    {_x call NWG_fnc_compactStringArray} forEach _loot;

    //return
    _loot
};

NWG_LS_CLI_GetDeadUnitWeaponHolders = {
    if (!alive _this)
        then {(getCorpseWeaponholders _this) select {!isNull _x}}
        else {[]}
};

//Rarely bodies are stuck in limbo where their loadout does not change and thus they can be looted indefinitely
//We only support 2 loots - one for all the items, second for the uniform
NWG_LS_CLI_lootedBodies = [];
NWG_LS_CLI_CheckOverlooting = {
    private _body = _this;

    //Clear invalid entries
    {if (isNil "_x" || {isNull _x}) then {NWG_LS_CLI_lootedBodies deleteAt _forEachIndex}} forEachReversed NWG_LS_CLI_lootedBodies;

    //Check limit
    private _count = {_x isEqualTo _body} count NWG_LS_CLI_lootedBodies;
    if (_count >= 2) exitWith {
        "NWG_LS_CLI_CheckOverlooting: Body looting limit reached" call NWG_fnc_logError;
        {if (_x isEqualTo _body) then {NWG_LS_CLI_lootedBodies deleteAt _forEachIndex}} forEachReversed NWG_LS_CLI_lootedBodies;//Remove the body from the list
        deleteVehicle _body;//Delete the body
        false
    };

    //Add to list
    NWG_LS_CLI_lootedBodies pushBack _body;
    true
};

//================================================================================================================
//================================================================================================================
//Looting (public, high level)
NWG_LS_CLI_LootByInventoryUI = {
    disableSerialization;
    params [["_container",objNull],["_listboxIDC",-1]];
    if (isNull _container) exitWith {false};
    if (_listboxIDC == -1) exitWith {false};

    //Loot the container by using existing code
    private _ok = _container call NWG_LS_CLI_LootContainer_Core;
    if (!_ok) exitWith {false};

    //Close the window
    if (NWG_LS_CLI_Settings get "CLOSE_INVENTORY_ON_LOOT") then {
        (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
    };

    //return
    true
};

NWG_LS_CLI_LootByAction = {
    // private _container = _this;
    private _ok = _this call NWG_LS_CLI_LootContainer_Core;
    if (_ok)
        then {"#LS_ACTION_LOOT_SUCCESS#" call NWG_fnc_systemChatMe}
        else {"#LS_ACTION_LOOT_FAILURE#" call NWG_fnc_systemChatMe};
    //return
    _ok
};

NWG_LS_CLI_LootContainer_Core = {
    private _container = _this;

    //Null check
    if (isNull _container) exitWith {false};

    //Check that we not trying to loot the storage itself (obviously forbidden)
    if (!isNull NWG_LS_CLI_invisibleBox && {_container isEqualTo NWG_LS_CLI_invisibleBox}) exitWith {false};

    //Get container loot
    private _allContainerItems = _container call NWG_LS_CLI_GetAllContainerItems;
    if (_allContainerItems isEqualTo []) exitWith {false};//Nothing to take

    //Check overlooting
    if (_container isKindOf "Man" && {!(_container call NWG_LS_CLI_CheckOverlooting)}) exitWith {false};

    //Auto sell (will remove sold items from the loot)
    private _initialCount = count _allContainerItems;
    _allContainerItems = _allContainerItems call NWG_LS_CLI_AutoSell;

    //Define conditions for proceeding
    private _mustClear = (count _allContainerItems) > 0 || {(count _allContainerItems) != _initialCount};
    private _mustMerge = (count _allContainerItems) > 0;
    if (!_mustClear && !_mustMerge) exitWith {false};//Nothing do here

    //Clear the container
    if (_mustClear) then {
        if (_container isKindOf "Man") then {
            //We were looting the body of a unit
            private _uniform = uniform _container;//Get current uniform
            if (_uniform isNotEqualTo "" && {_allContainerItems isNotEqualTo [_uniform]}) then {
                //If there was a uniform and it is not the only thing left
                private _newLoadout = [[],[],[],[_uniform,[]],[],[],"","",[],["","","","","",""]];//Leave only the uniform
                [_container,_newLoadout] call NWG_fnc_setUnitLoadout;
                _allContainerItems deleteAt (_allContainerItems find _uniform);//Remove uniform from loot (we're not taking it)
            } else {
                private _newLoadout = (configFile >> "EmptyLoadout");//Clear the inventory completely
                [_container,_newLoadout] call NWG_fnc_setUnitLoadout;
            };
            //Delete weapons from weapon holders
            {deleteVehicle _x} forEach (_container call NWG_LS_CLI_GetDeadUnitWeaponHolders);
        } else {
            //We were looting regular container (box/vehicle)
            _container call NWG_fnc_clearContainerCargo;
        };
    };

    //Add to player loot storage
    if (_mustMerge) then {
        private _loot = _allContainerItems call NWG_LS_CLI_ConvertToLoot;
        [player,_loot] call NWG_fnc_lsAddToLocalPlayerLoot;//Save locally
        if (!isServer) then {
            [player,_loot] remoteExec ["NWG_fnc_lsAddToLocalPlayerLoot",2];//Save on server
        };
    };

    //return
    true
};

//================================================================================================================
//================================================================================================================
//Auto sell logic
NWG_LS_CLI_AutoSell = {
    // private _allLootItems = _this;

    //Check settings
    if !(NWG_LS_CLI_Settings get "AUTO_SELL_LOOT") exitWith {_this};

    //Prepare variables
    private _priceMap = NWG_LS_CLI_Settings get "AUTO_SELL_PRICE_MAP";
    private _price = 0;
    private _sum = 0;

    //Iterate over all loot items
    {
        _price = _priceMap getOrDefault [_x,0];
        if (_price != 0) then {
            _sum = _sum + _price;//Add to sum
            _this deleteAt _forEachIndex;//Remove from loot
        };
    } forEachReversed _this;

    //Add money to player
    if (_sum != 0) then {
        [player,_sum] call (NWG_LS_CLI_Settings get "AUTO_SELL_ADD_MONEY_FUNCTION");
    };

    //return
    _this
};

NWG_LS_CLI_AutoSellOnTake = {
    // params ["_player","_container","_item"];
    private _item = _this param [2,""];

    //Check settings
    if !(NWG_LS_CLI_Settings get "AUTO_SELL_LOOT") exitWith {};
    if !(NWG_LS_CLI_Settings get "AUTO_SELL_ON_TAKE") exitWith {};

    //Get price
    private _price = (NWG_LS_CLI_Settings get "AUTO_SELL_PRICE_MAP") getOrDefault [_item,0];
    if (_price == 0) exitWith {};//No price found

    //Remove item and add money
    player removeItem _item;
    [player,_price] call (NWG_LS_CLI_Settings get "AUTO_SELL_ADD_MONEY_FUNCTION");
};

//================================================================================================================
//================================================================================================================
//On respawn
NWG_LS_CLI_OnRespawn = {
    params ["_player","_corpse"];

    //Get player loot from an old instance
    private _loot = _corpse call NWG_fnc_lsGetPlayerLoot;
    if (_loot isEqualTo LOOT_ITEM_DEFAULT_CHART) exitWith {};//No loot to transfer or deplete

    //Deplete the loot
    if (NWG_LS_CLI_Settings get "DEPLETE_LOOT_ON_RESPAWN") then {
        private _multiplier = NWG_LS_CLI_Settings get "DEPLETE_MULTIPLIER";
        private _notify = NWG_LS_CLI_Settings get "DEPLETE_NOTIFICATION";
        _loot = [_loot,_multiplier,_notify] call NWG_fnc_lsDepleteLoot;
    };

    //Transfer loot to the new entity
    if (NWG_LS_CLI_Settings get "TRANSFER_LOOT_ON_RESPAWN") then {
        [_player,_loot] call NWG_fnc_lsSetPlayerLoot;
    };
};

//================================================================================================================
//================================================================================================================
call _Init;