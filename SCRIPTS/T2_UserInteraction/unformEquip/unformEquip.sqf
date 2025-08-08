/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability.
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
#define INVENTORY_WINDOW_FIX false       //Fix the issue with inventory tabs disappearing (suggestion by HOPA_EHOTA)

//UI IDDs
#define MAIN_CONTAINER_LIST 640
#define SECN_CONTAINER_LIST 632

//Swap types
#define SWAP_NONE -1
#define SWAP_UNIF 3
#define SWAP_VEST 4
#define SWAP_BACK 5

//================================================================================================================
//Settings
NWG_UNEQ_Settings = createHashMapFromArray [
    /*External functions*/
    ["FUNC_IS_LOCAL_CONTAINER",{
        private _lootStorage = call NWG_fnc_lsGetLootStorage;
        !isNull _lootStorage && {_this isEqualTo _lootStorage}
    }],
    ["FUNC_GET_ALL_CONTAINER_ITEMS",{
        _this call NWG_fnc_lsGetAllItemsFromContainer
    }],

    ["",0]
];

//================================================================================================================
//Script
NWG_UNEQ_EquipSelectedUniform = {
    disableSerialization;
    params [["_container",objNull],["_listboxIDC",-1]];
    if (isNull _container) exitWith {false};
    if (_listboxIDC == -1) exitWith {false};

    //Get opened listbox
    private _inventoryDisplay = findDisplay 602;
    if (isNull _inventoryDisplay) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Inventory must be opened to equip uniform." call NWG_fnc_logError;
        false
    };
    private _uiContainer = _inventoryDisplay displayCtrl _listboxIDC;
    if (isNull _uiContainer) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Listbox is not available." call NWG_fnc_logError;
        false
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
        [_container,_selectedItem,_playerItem] call NWG_UNEQ_ReplaceInContainer;//Replace item in the container
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

    if (_unit isEqualTo player && {!isNil "NWG_fnc_invSetPlayerLoadout"})
        then {_newLoadout call NWG_fnc_invSetPlayerLoadout}
        else {[_unit,_newLoadout] call NWG_fnc_setUnitLoadout};
};

NWG_UNEQ_ReplaceInContainer = {
    params ["_container","_itemToRemove","_itemToAdd"];

    //Replace item in the container data
    private _allItems = _container call (NWG_UNEQ_Settings get "FUNC_GET_ALL_CONTAINER_ITEMS");
    private _i = _allItems findIf {_x isEqualType 1};
    if (_i != -1) then {_allItems = _allItems call NWG_fnc_unCompactStringArray};
    _allItems deleteAt (_allItems find _itemToRemove);
    if (_itemToAdd isNotEqualTo "") then {_allItems pushBack _itemToAdd};
    _allItems = _allItems call NWG_fnc_compactStringArray;

    //Refill the container
    private _isLocal = _container call (NWG_UNEQ_Settings get "FUNC_IS_LOCAL_CONTAINER");
    if (_isLocal) then {
        _container call NWG_fnc_clearContainerCargoLocal;
        [_container,_allItems] call NWG_fnc_fillContainerCargoLocal;
    } else {
        _container call NWG_fnc_clearContainerCargoGlobal;
        [_container,_allItems] call NWG_fnc_fillContainerCargoGlobal;
    };
};