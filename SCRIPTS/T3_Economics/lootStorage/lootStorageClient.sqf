#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings (this time as defines - can not be changed in runtime anyway)
#define OPEN_STORAGE_ACTION_PRIORITY 6
#define OPEN_STORAGE_ACTION_RADIUS 3
#define INVISIBLE_BOX_TYPE "B_supplyCrate_F"

//================================================================================================================
//================================================================================================================
//Fields
NWG_LS_CLI_invisibleBox = objNull;
NWG_LS_CLI_isInvisibleBoxModified = false;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Wait for server to broadcast the loot storage object
    waitUntil {
        sleep 0.1;
        !(isNil "NWG_LS_LootStorageObject") && {!(isNull NWG_LS_LootStorageObject)}
    };

    //Initialize the object on client side with proper localization and 'Le' addAction command
    private _lootStorage = NWG_LS_LootStorageObject;
    private _title = "#LS_STORAGE_ACTION_TITLE#" call NWG_fnc_localize;
    _lootStorage lockInventory true;
    _lootStorage addAction [
        _title,//Title
        {call NWG_LS_CLI_OpenMyStorage},//Script
        nil,//Arguments
        OPEN_STORAGE_ACTION_PRIORITY,//Priority
        true,//ShowWindow
        true,//HideOnUse
        "",//Shortcut
        "true",//Condition
        OPEN_STORAGE_ACTION_RADIUS//Radius
    ];

    //Add event handlers
    player addEventHandler ["InventoryClosed",{call NWG_LS_CLI_OnInventoryClose}];
    player addEventHandler ["Take",{call NWG_LS_CLI_OnTakeOrPut}];
    player addEventHandler ["Put",{call NWG_LS_CLI_OnTakeOrPut}];
};

//================================================================================================================
//================================================================================================================
//Storage access
NWG_LS_CLI_OpenMyStorage = {
    //Create new invisible box
    if (!isNull NWG_LS_CLI_invisibleBox)
        then {deleteVehicle NWG_LS_CLI_invisibleBox};
    private _invisibleBox = createVehicleLocal [INVISIBLE_BOX_TYPE,player,[],0,"CAN_COLLIDE"];
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
    {
        //Read count if any
        if (_x isEqualType 1)
            then {_count = _x; continue};
        //Put item into the box
        if (isClass (configFile >> "CfgVehicles" >> _x))
            then {_invisibleBox addBackpackCargo [_x,_count]}/*Backpacks require different approach*/
            else {_invisibleBox addItemCargo [_x,_count]};//Items (any, except for backpacks, see: https://community.bistudio.com/wiki/addItemCargo)
        //Reset count
        _count = 1;
    } forEach _loot;

    //Open the box
    player action ["Gear",_invisibleBox];
};

//================================================================================================================
//================================================================================================================
//Storage update via vanilla inventory actions
NWG_LS_CLI_OnTakeOrPut = {
    //Mark storage dirty if it exists
    //note: we *assume* it is the storage that has been changed if we take/put when storage object exists
    if (!isNull NWG_LS_CLI_invisibleBox)
        then {NWG_LS_CLI_isInvisibleBoxModified = true};
};

NWG_LS_CLI_OnInventoryClose = {
    if (isNull NWG_LS_CLI_invisibleBox)
        exitWith {};//Ignore if storage object does not exist
    if (!NWG_LS_CLI_isInvisibleBoxModified)
        exitWith {deleteVehicle NWG_LS_CLI_invisibleBox};//Ignore if storage was not modified
    NWG_LS_CLI_isInvisibleBoxModified = false;//Reset flag

    //Re-write the player loot based on what is left in the box
    private _loot = NWG_LS_CLI_invisibleBox call NWG_LS_CLI_LootTheContainer;
    {_x call NWG_fnc_compactStringArray} forEach _loot;//Compact the loot records
    [player,_loot] call NWG_fnc_lsSetPlayerLoot;

    //Close the box
    deleteVehicle NWG_LS_CLI_invisibleBox;
};

//================================================================================================================
//================================================================================================================
//Looting (low level)
//This function does a low-level looting and categorization
//Clears the container (any kind) and returns uncompressed loot records
//returns: [[CLTH_array],[WEPN_array],[ITEM_array],[AMMO_array]]
NWG_LS_CLI_LootTheContainer = {
    private _container = _this;

    private _allContainerItems = [];
    {
        private _arr = switch (_x) do {
            case 0: {getBackpackCargo _container};
            case 1: {getItemCargo _container};
            case 2: {getMagazineCargo _container};
            case 3: {getWeaponCargo _container};
        };

        _arr params ["_classNames","_counts"];
        for "_i" from 0 to ((count _classNames)-1) do {
            _allContainerItems pushBack (_counts#_i);
            _allContainerItems pushBack (_classNames#_i);
        };

        switch (_x) do {
            case 0: {clearBackpackCargoGlobal _container};
            case 1: {clearItemCargoGlobal _container};
            case 2: {clearMagazineCargoGlobal _container};
            case 3: {clearWeaponCargoGlobal _container};
        };
    } forEach [0,1,2,3];
    _allContainerItems = _allContainerItems call NWG_fnc_unCompactStringArray;

    private _loot = [[],[],[],[]];
    {
        switch (_x call NWG_fnc_icGetItemType) do {
            case ITEM_TYPE_CLTH: {(_loot#0) pushBack _x};
            case ITEM_TYPE_WEPN: {(_loot#1) pushBack _x};
            case ITEM_TYPE_ITEM: {(_loot#2) pushBack _x};
            case ITEM_TYPE_AMMO: {(_loot#3) pushBack _x};
        };
    } forEach _allContainerItems;
    _allContainerItems resize 0;//Clear

    //return
    _loot
};

//================================================================================================================
//================================================================================================================
//Looting (public, high level)
NWG_LS_CLI_LootByInventoryUI = {
    //TODO: Implement looting
};

NWG_LS_CLI_LootByAction = {
    private _container = _this;
    //TODO: Implement looting
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;