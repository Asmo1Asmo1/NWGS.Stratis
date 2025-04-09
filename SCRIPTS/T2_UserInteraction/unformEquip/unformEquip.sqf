/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability.
    Note: It requires inventory to be opened in order to work.

    Usage: Inside "InventoryOpened" event handler, add any handler that will call this function with the same arguments.
    ["_unit","_mainContainer","_secdContainer"] call NWG_fnc_uneqEquipSelected

    I did not find a way to grab actual containers solely from the inventory UI.
    So unfortunately this module requires the arguments of "InventoryOpened" handler to be sent
*/
/*
    Important notes:
    - Items placed inside the uniform/vest/backpack are not transferred
    - This is a feature - we can swap items without manually relocating items
    - And a bug - if we swap while not wearing anything - we'll equip empty uniform/vest/backpack and items inside will be lost
*/
//================================================================================================================
//Defines
#define CLOSE_INVENTORY_ON_UNIFORM_CHANGE false //Close inventory on uniform switch (hides the bug with inventory tabs)
#define INVENTORY_WINDOW_FIX true       //Fix the issue with inventory tabs disappearing (suggestion by HOPA_EHOTA)

//UI IDDs
#define MAIN_CONTAINER_LIST 640
#define SECN_CONTAINER_LIST 632

//Swap types
#define SWAP_NONE -1
#define SWAP_UNIF 3
#define SWAP_VEST 4
#define SWAP_BACK 5

//================================================================================================================
//Script
NWG_UNEQ_EquipSelectedUniform = {
    disableSerialization;
    //params ["_unit","_mainContainer","_secdContainer"];
    params ["",["_mainContainer",objNull],["_secdContainer",objNull]];
    if (isNull _mainContainer && {isNull _secdContainer}) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Inventory containers are not available." call NWG_fnc_logError;
        false
    };

    private _inventoryDisplay = findDisplay 602;
    if (isNull _inventoryDisplay) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Inventory must be opened to equip uniform." call NWG_fnc_logError;
        false
    };

    //Get UI container with selected item
    private _uiContainerID = -1;
    {
        if ((lbCurSel (_inventoryDisplay displayCtrl _x)) > -1) exitWith {_uiContainerID = _x};
    } forEach [MAIN_CONTAINER_LIST,SECN_CONTAINER_LIST];
    if (_uiContainerID == -1) exitWith {false};//Nothing is selected anywhere
    private _uiContainer = _inventoryDisplay displayCtrl _uiContainerID;

    //Get physical container (with a shit ton of fixes)
    private _containers = switch (true) do {
        case (_uiContainerID == MAIN_CONTAINER_LIST): {[_mainContainer,_secdContainer]};
        case (_uiContainerID == SECN_CONTAINER_LIST && {!isNull _mainContainer && {_mainContainer isKindOf "Man"}}): {[_mainContainer,_secdContainer]};
        default {[_secdContainer,_mainContainer]};
    };
    if (isNull (_containers#0)) then {
        _containers pushBack (_containers deleteAt 0);//Swap (old fix for looting corpses)
    };
    private _container = _containers#0;
    if (isNull _container) exitWith {
        "NWG_LS_CLI_LootByInventoryUI: Inventory containers are not available." call NWG_fnc_logError;
        false
    };
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

    //Get selected item
    private _selectedIndex = lbCurSel _uiContainer;
    private _selectedItem = _uiContainer lbData _selectedIndex;
    /*Fix for backpacks in boxes (seriously, Arma?)*/
    if (_selectedIndex > 0 && {_selectedItem isEqualTo ""}) then {
        private _selectedItemDisplayName = _uiContainer lbText _selectedIndex;
        private _backpacks = (getBackpackCargo _container) param [0,[]];
        private _i = _backpacks findIf {(getText (configFile >> "CfgVehicles" >> _x >> "displayName")) isEqualTo _selectedItemDisplayName};
        if (_i == -1) exitWith {};
        _selectedItem = _backpacks#_i;
    };
    if (_selectedItem isEqualTo "") exitWith {false};

    //Define swap type (and check selected item along the way)
    private _itemType = getNumber (configFile >> "CfgWeapons" >> _selectedItem >> "ItemInfo" >> "type");
    private _isBackpack = if (_itemType == 0) then {isClass (configFile >> "CfgVehicles" >> _selectedItem)} else {false};
    private _swapType = switch (true) do {
        case (_itemType == 801): {SWAP_UNIF};/*Uniform*/
        case (_itemType == 701): {SWAP_VEST};/*Vest*/
        case (_isBackpack): {SWAP_BACK};/*Backpack*/
        default {SWAP_NONE};/*Not a supported item*/
    };
    if (_swapType == SWAP_NONE) exitWith {false};

    //Get player's uniform/vest/backpack to swap
    private _playerItem = ((getUnitLoadout player) select _swapType) param [0,""];
    if (_playerItem isEqualTo _selectedItem) exitWith {false};//Already wearing this item

    //Update the container based on what it is
    if (_container isKindOf "Man") then {
        //Fix uniform duplication abuse (by just ignoring uniform that was put into dead unit's inventory)
        if (((getUnitLoadout _container) select _swapType) param [0,""] isNotEqualTo _selectedItem) exitWith {};//Not the same item
        //Swap items
        [_container,_playerItem,_swapType] call NWG_UNEQ_ReplaceOnUnit;//Replace item for the (apparently dead) unit
        [player,_selectedItem,_swapType] call NWG_UNEQ_ReplaceOnUnit;//Update player's loadout
    } else {
        //Swap items
        [_container,_selectedItem,_playerItem,_swapType] call NWG_UNEQ_ReplaceInContainer;//Replace item in the container
        [player,_selectedItem,_swapType] call NWG_UNEQ_ReplaceOnUnit;//Update player's loadout
    };

    //Apply fixes
    switch (true) do {
        case (CLOSE_INVENTORY_ON_SWITCH): {
            //Close inventory window
            (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
        };
        case (INVENTORY_WINDOW_FIX): {
            //Fix the issue with inventory tabs disappearing
            player addItem "Antibiotic";
            player removeItem "Antibiotic";
        };
        default {/*Do nothing*/};
    };

    //return
    true
};

//================================================================================================================
//Utils
NWG_UNEQ_ReplaceInContainer = {
    params ["_container","_itemToRemove","_itemToAdd","_swapType"];

    if (_swapType == SWAP_UNIF || _swapType == SWAP_VEST) exitWith {
        //Remove old item from the container
        //In a most inconvenient Arma way possible - remove all items, then add them back except for the one to remove
        (getItemCargo _container) params ["_items","_counts"];
        clearItemCargoGlobal _container;
        private _i = _items find _itemToRemove;
        if (_i != -1) then {
            //Modify target count or remove item completely
            if ((_counts#_i) > 1)
                then {_counts set [_i,((_counts#_i) - 1)]}
                else {_counts deleteAt _i; _items deleteAt _i};
            //Add all back
            {_container addItemCargoGlobal [_x,(_counts#_forEachIndex)]} forEach _items;
        };

        //Add new item to the container
        if (_itemToAdd isNotEqualTo "") then {_container addItemCargoGlobal [_itemToAdd,1]};
    };

    if (_swapType == SWAP_BACK) exitWith {
        //Remove old item from the container
        //In a most inconvenient Arma way possible - remove all items, then add them back except for the one to remove
        (getBackpackCargo _container) params ["_backpacks","_counts"];
        clearBackpackCargoGlobal _container;
        private _i = _backpacks find _itemToRemove;
        if (_i != -1) then {
            //Modify target count or remove item completely
            if ((_counts#_i) > 1)
                then {_counts set [_i,((_counts#_i) - 1)]}
                else {_counts deleteAt _i; _backpacks deleteAt _i};
            //Add all back
            {_container addBackpackCargoGlobal [_x,(_counts#_forEachIndex)]} forEach _backpacks;
        };

        //Add new item to the container
        _itemToAdd = _itemToAdd call BIS_fnc_basicBackpack;//Prevent adding backpacks with pre-defined cargo (ammo dup fix)
        if (_itemToAdd isNotEqualTo "") then {_container addBackpackCargoGlobal [_itemToAdd,1]};
    };
};

NWG_UNEQ_ReplaceOnUnit = {
    params ["_unit","_itemToAdd","_swapType"];
    if (_swapType == SWAP_BACK) then {
        _itemToAdd = _itemToAdd call BIS_fnc_basicBackpack;//Prevent adding backpacks with pre-defined cargo (ammo dup fix)
    };

    private _itemLoadout = (getUnitLoadout _unit) select _swapType;
    if (_itemLoadout isEqualTo [])
        then {_itemLoadout = [_itemToAdd,nil]}/*Dress up naked units*/
        else {_itemLoadout set [0,_itemToAdd]};/*Replace root item*/

    private _newLoadout = [];
    _newLoadout resize 10;//Get array with 10 'nil' elements
    _newLoadout set [_swapType,_itemLoadout];

    _unit setUnitLoadout _newLoadout;
};