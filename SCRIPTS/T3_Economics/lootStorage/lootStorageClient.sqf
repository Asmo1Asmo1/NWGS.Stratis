#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_LS_CLI_Settings = createHashMapFromArray [
    ["INVISIBLE_BOX_TYPE","B_supplyCrate_F"],//Classname of the object that will be used as a loot storage
    ["CLOSE_INVENTORY_ON_LOOT",true],//Should the inventory be closed automatically when loot is taken

    ["ALLOW_LOOTING_ALIVE_UNITS",false],//Should we allow looting of alive units

    ["AUTO_SELL_LOOT",true],//Should the loot defined in the pricemap be automatically sold on moving to storage (+ on closing the storage just in case)
    ["AUTO_SELL_ON_TAKE",true],//Should the loot be automatically sold when it is taken (uses 'Take' event handler)
    ["AUTO_SELL_PRICE_MAP",createHashMapFromArray [
        ["Money",7000],     /*Big pile of money*/
        ["Money_bunch",150],/*Three $50 notes*/
        ["Money_roll",1000],/*Money roll of $50 notes*/
        ["Money_stack",2500]/*Money stack of $50 notes*/
    ]],//Price map for the loot immediate sell without putting it into storage
    ["AUTO_SELL_ADD_MONEY_FUNCTION",{_this call NWG_fnc_wltAddPlayerMoney}],//Function that adds money to the player params: [_player,_amount]

    ["DEPLETE_LOOT_ON_RESPAWN",true],//Should the loot be deplete on respawn
    ["DEPLETE_MULTIPLIER",0.5],//Multiplier for the loot deplete on respawn
    ["DEPLETE_NOTIFICATION",true],//Should we notify player about the loot depletion

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_LS_CLI_invisibleBox = objNull;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["InventoryClosed",{call NWG_LS_CLI_OnInventoryClose}];
    player addEventHandler ["Take",{call NWG_LS_CLI_AutoSellOnTake}];
    player addEventHandler ["Respawn",{_this call NWG_LS_CLI_OnRespawn}];
};

//================================================================================================================
//================================================================================================================
//Storage access
NWG_LS_CLI_OpenMyStorage = {
    //Create new invisible box
    if (!isNull NWG_LS_CLI_invisibleBox)
        then {deleteVehicle NWG_LS_CLI_invisibleBox};
    private _invisibleBox = createVehicleLocal [(NWG_LS_CLI_Settings get "INVISIBLE_BOX_TYPE"),player,[],0,"CAN_COLLIDE"];
    _invisibleBox hideObject true;
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
        switch (true) do {
            case (_x isEqualType 1): {
                //Read count
                _count = _x;
            };
            case (isClass (configFile >> "CfgVehicles" >> _x)): {
                //Backpacks require different approach
                _invisibleBox addBackpackCargo [_x,_count];
                _count = 1;//Reset count
            };
            default {
                //Items (any, except for backpacks, see: https://community.bistudio.com/wiki/addItemCargo)
                _invisibleBox addItemCargo [_x,_count];
                _count = 1;//Reset count
            };
        };
    } forEach _loot;

    //Open the box
    player action ["Gear",_invisibleBox];
};

//================================================================================================================
//================================================================================================================
//Storage update via vanilla inventory actions
NWG_LS_CLI_OnInventoryClose = {
    //Check if we closing the storage object
    if (isNull NWG_LS_CLI_invisibleBox) exitWith {};//Ignore if storage object does not exist

    //Get storage loot
    private _storageLoot = NWG_LS_CLI_invisibleBox call NWG_LS_CLI_GetAllContainerItems;
    _storageLoot = _storageLoot call NWG_LS_CLI_AutoSell;//Auto sell (just in case something got there)
    _storageLoot = _storageLoot call NWG_LS_CLI_ConvertToLoot;//Convert to loot structure
    {_x call NWG_fnc_compactStringArray} forEach _storageLoot;//Compact storage loot structure

    //Check if was modified
    if (_storageLoot isNotEqualTo (player call NWG_fnc_lsGetPlayerLoot)) then {
        //Re-write the player loot based on what is left in the box
        [player,_storageLoot] call NWG_fnc_lsSetPlayerLoot;
    };

    //Close the box (will also delete all the items inside)
    deleteVehicle NWG_LS_CLI_invisibleBox;
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

        //Loot clothes, items and ammo
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
        private _weapCargoInfo = (getWeaponCargo _container)#0;//["weapon","weapon","weapon",...]
        private _weapFullInfo = weaponsItems _container;//[["weapon","silencer","flashlight","optics",["mag",30],[],"bipod"],...]
        _weapFullInfo = _weapFullInfo select {(_x#0) in _weapCargoInfo};//Remove non-containable weapons (horn, etc.)
        _weapFullInfo = (flatten _weapFullInfo) select {_x isEqualType "" && {_x isNotEqualTo ""}};//Flatten and filter
        _allContainerItems append _weapFullInfo;
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
                _count = _x param [1,1];
                if (_class isEqualTo "") then {continue};//Skip empty
                if !(_count isEqualType 1) then {_count = 1};//Fix for backpacks (true/false) and weapons ("")
                //Ignore ammo count inside magazines - not interested (think of it as a free refill)
                //Ignore 'weapon stored inside backpack' - rare usecase and AI units don't do that at all
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

    //return
    _loot
};

NWG_LS_CLI_GetDeadUnitWeaponHolders = {
    //replace with https://community.bistudio.com/wiki/getCorpseWeaponholders when available (arma 3 2.18)
    //note: checked looting with secondary weapon attached to player - seems all good
    // private _deadUnit = _this;
    if (!alive _this)
        then {_this nearObjects ["WeaponHolderSimulated",5]}
        else {[]}
};

//================================================================================================================
//================================================================================================================
//Looting (public, high level)
//UI IDDs
#define MAIN_CONTAINER_LIST 640
#define SECN_CONTAINER_LIST 632
NWG_LS_CLI_LootByInventoryUI = {
    disableSerialization;
    //params ["_unit","_mainContainer","_secdContainer"];
    params ["",["_mainContainer",objNull],["_secdContainer",objNull]];

    //Get inventory display
    private _inventoryDisplay = findDisplay 602;
    if (isNull _inventoryDisplay) exitWith {
        "NWG_LS_CLI_LootByInventoryUI: Inventory must be opened to equip uniform." call NWG_fnc_logError;
        false
    };

    //Find currently opened UI container
    private _uiContainerID = -1;
    {
        if (ctrlShown (_inventoryDisplay displayCtrl _x)) exitWith {_uiContainerID = _x};
    } forEach [MAIN_CONTAINER_LIST,SECN_CONTAINER_LIST];
    if (_uiContainerID == -1) exitWith {
        "NWG_LS_CLI_LootByInventoryUI: No container is opened." call NWG_fnc_logError;
        false
    };

    //Get physical container
    private _containers = if (_uiContainerID == MAIN_CONTAINER_LIST)
        then {[_mainContainer,_secdContainer]}
        else {[_secdContainer,_mainContainer]};
    if (isNull (_containers#0)) then {
        _containers pushBack (_containers deleteAt 0);//Swap (old fix for looting corpses)
    };
    private _container = _containers#0;
    if (isNull _container) exitWith {
        "NWG_LS_CLI_LootByInventoryUI: Inventory containers are not available." call NWG_fnc_logError;
        false
    };

    //Container fixes
    _secdContainer = _containers#1;
    switch (true) do {
        //Fix Arma 2.18 introducing weaponholders instead of actual units
        case (_container isKindOf "WeaponHolder");
        case (_container isKindOf "WeaponHolderSimulated"): {
            if (!isNull _secdContainer && {_secdContainer isNotEqualTo _container}) then {
                if (_secdContainer isKindOf "Man" || {(objectParent _secdContainer) isKindOf "Man"}) then {
                    _container = _secdContainer;
                    _secdContainer = objNull;
                };
            };
        };
        //Fix secondary weapon pseudo container getting in the way
        case (_container isKindOf "Library_WeaponHolder"): {
            if (!isNull (attachedTo _container) && {(attachedTo _container) isKindOf "Man"}) then {
                _container = _secdContainer;
                _secdContainer = objNull;
            };
        };
    };

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

    //Check that we not trying to loot alive unit (also frowned upon)
    private _allowed = true;
    if !(NWG_LS_CLI_Settings get "ALLOW_LOOTING_ALIVE_UNITS") then {
        private _i = [_container,(objectParent _container)] findIf {
            !isNull _x && {
            alive _x && {
            _x isKindOf "Man" && {
            _x isNotEqualTo player}}}
        };
        if (_i != -1) then {_allowed = false};
    };
    if (!_allowed) exitWith {false};

    //Get container loot
    private _allContainerItems = _container call NWG_LS_CLI_GetAllContainerItems;
    if (_allContainerItems isEqualTo []) exitWith {false};//Nothing to take

    //Auto sell (will remove sold items from the loot)
    private _initialCount = count _allContainerItems;
    _allContainerItems = _allContainerItems call NWG_LS_CLI_AutoSell;

    //Define conditions for proceeding
    private _mustClear = (count _allContainerItems) > 0 || {(count _allContainerItems) != _initialCount};
    private _mustMerge = (count _allContainerItems) > 0;
    if (!_mustClear && !_mustMerge) exitWith {false};//Nothing do here

    //Convert to loot structure
    private _loot = _allContainerItems call NWG_LS_CLI_ConvertToLoot;

    //Clear the container
    if (_mustClear) then {
        if (_container isKindOf "Man") then {
            //We were looting the body of a unit
            private _uniform = uniform _container;//Get current uniform
            if (_uniform isNotEqualTo "" && {_allContainerItems isNotEqualTo [_uniform]}) then {
                //If there was a uniform and it is not the only thing left
                _container setUnitLoadout [[],[],[],[_uniform,[]],[],[],"","",[],["","","","","",""]];//Leave only the uniform
                (_loot#LOOT_ITEM_CAT_CLTH) deleteAt ((_loot#LOOT_ITEM_CAT_CLTH) find _uniform);//Remove uniform from loot (we're not taking it)
            } else {
                _container setUnitLoadout (configFile >> "EmptyLoadout");//Clear the inventory completely
            };
            //Delete weapons from weapon holders
            {deleteVehicle _x} forEach (_container call NWG_LS_CLI_GetDeadUnitWeaponHolders);
        } else {
            //We were looting regular container (box/vehicle)
            _container call NWG_fnc_clearContainerCargo;
        };
    };

    //Append to player loot storage
    if (_mustMerge) then {
        private _playerLoot = player call NWG_fnc_lsGetPlayerLoot;
        {
            _x call NWG_fnc_unCompactStringArray;//Uncompact
            _x append (_loot#_forEachIndex);//Append
            _x call NWG_fnc_compactStringArray;//Compact
        } forEach _playerLoot;
        [player,_playerLoot] call NWG_fnc_lsSetPlayerLoot;//Save
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
    if (_loot isEqualTo LOOT_ITEM_DEFAULT_CHART) exitWith {};//No loot to transfer

    //Deplete the loot
    if (NWG_LS_CLI_Settings get "DEPLETE_LOOT_ON_RESPAWN") then {
        private _multiplier = NWG_LS_CLI_Settings get "DEPLETE_MULTIPLIER";
        private _notify = NWG_LS_CLI_Settings get "DEPLETE_NOTIFICATION";
        _loot = [_loot,_multiplier,_notify] call NWG_fnc_lsDepleteLoot;
    };

    //Transfer loot to the new entity
    [_player,_loot] call NWG_fnc_lsSetPlayerLoot;
};

//================================================================================================================
//================================================================================================================
call _Init;