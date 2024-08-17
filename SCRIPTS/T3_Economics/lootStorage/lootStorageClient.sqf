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
        if (!isClass (configFile >> "CfgVehicles" >> _x)) then {
            //Items (any, except for backpacks, see: https://community.bistudio.com/wiki/addItemCargo)
            _invisibleBox addItemCargo [_x,_count];
        } else {
            //Backpacks require different approach
            _x = _x call BIS_fnc_basicBackpack;//Fix items getting inside backpacks
            _invisibleBox addBackpackCargo [_x,_count];
        };
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
    private _loot = NWG_LS_CLI_invisibleBox call NWG_LS_CLI_ContainerItemsToLoot;
    {_x call NWG_fnc_compactStringArray} forEach _loot;//Compact the loot records
    [player,_loot] call NWG_fnc_lsSetPlayerLoot;

    //Close the box (will also delete all the items inside)
    deleteVehicle NWG_LS_CLI_invisibleBox;
};

//================================================================================================================
//================================================================================================================
//Looting utils
//Converts container items into loot
//returns: [[CLTH_array],[WEPN_array],[ITEM_array],[AMMO_array]]
NWG_LS_CLI_ContainerItemsToLoot = {
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

        //Loot weapons
        private _cargo = (getWeaponCargo _container)#0;
        private _wepns = weaponsItems _container;
        _wepns = _wepns select {(_x#0) in _cargo};//Remove non-contained weapons (horn, etc.)
        _wepns = (flatten _wepns) select {_x isEqualType "" && {_x isNotEqualTo ""}};//Flatten and filter
        _allContainerItems append _wepns;
    };

    //Get all items from the container
    if (_container isKindOf "Man") then {

        /*--- Looting the body of a unit ---*/
        private _loadout = getUnitLoadout _container;
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
        //Extract everything else that is left in loadout (can be imagied as just a flat list of items)
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

    //Convert to loot
    private _loot = [[],[],[],[]];
    {
        switch (_x call NWG_fnc_icGetItemType) do {
            case ITEM_TYPE_CLTH: {(_loot#0) pushBack (_x call NWG_LS_CLI_GetBasicBackpack)};
            case ITEM_TYPE_WEPN: {(_loot#1) pushBack (_x call NWG_LS_CLI_GetBasicWeapon)};
            case ITEM_TYPE_ITEM: {(_loot#2) pushBack _x};
            case ITEM_TYPE_AMMO: {(_loot#3) pushBack _x};
        };
    } forEach _allContainerItems;
    _allContainerItems resize 0;//Clear

    //return
    _loot
};

//BIS_fnc_basicBackpack (reworked)
NWG_LS_CLI_GetBasicBackpack = {
    private _input = _this;
    if !(isClass (configFile >> "CfgVehicles" >> _input)) exitWith {_input};//Not a backpack

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
    if !(_input call _fn_hasCargo) exitWith {_input};//Backpack has no cargo

    private _output = "";
    private _parents = [configFile >> "CfgVehicles" >> _input, true] call BIS_fnc_returnParents;
    private _i = _parents findIf {!(_x call _fn_hasCargo) && {(getNumber (configFile >> "CfgVehicles" >> _x >> "scope")) == 2}};
    if (_i != -1) then {_output = _parents select _i};//Can it return ""? Let's be extra cautious and assume it can

    if (_output isEqualTo "") then {
        _output = if (_input == "b_kitbag_rgr_exp")
            then {"b_kitbag_rgr"}/*Some unnamed border case, taken from original 'as is'*/
            else {_input};
    };

    //return
    _output
};

//BIS_fnc_baseWeapon (reworked)
NWG_LS_CLI_GetBasicWeapon = {
    _input = _this;
    private _cfg = configFile >> "CfgWeapons" >> _input;
    if !(isClass _cfg) exitWith {_input};//Not a weapon

    //--- Get manual base weapon
    private _base = getText (_cfg >> "baseWeapon");
    if (isclass (configFile >> "CfgWeapons" >> _base)) exitWith {_base};

    //--- Get first parent without any attachments
    private _return = _input;
    {
        if (count (_x >> "linkeditems") == 0) exitWith {_return = configname _x};
    } foreach (_cfg call BIS_fnc_returnParents);

    //return
    _return
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
NWG_LS_CLI_LootByInventoryUI = {
    disableSerialization;
    //params ["_unit","_mainContainer","_secdContainer"];
    params ["",["_mainContainer",objNull],["_secdContainer",objNull]];

    //TODO: Implement
    systemChat "Loot button pressed!";
};

NWG_LS_CLI_LootByAction = {
    //Get container loot
    private _container = _this;
    private _loot = _container call NWG_LS_CLI_ContainerItemsToLoot;
    private _flattenedLoot = flatten _loot;
    if (_flattenedLoot isEqualTo []) exitWith {};//Nothing to take

    //Clear the container
    if (_container isKindOf "Man") then {
        //We were looting the body of a unit
        private _uniform = uniform _container;//Get current uniform
        if (_uniform isNotEqualTo "" && {_flattenedLoot isNotEqualTo [_uniform]}) then {
            //If there was a uniform and it is not the only thing left
            _container setUnitLoadout [[],[],[],[_uniform,[]],[],[],"","",[],["","","","","",""]];//Leave only the uniform
            (_loot#0) deleteAt ((_loot#0) find _uniform);//Remove uniform from loot (we're not taking it)
        } else {
            _container setUnitLoadout (configFile >> "EmptyLoadout");//Clear the inventory completely
        };
        //Delete weapons from weapon holders
        {deleteVehicle _x} forEach (_container call NWG_LS_CLI_GetDeadUnitWeaponHolders);
    } else {
        //We were looting regular container (box/vehicle)
        clearBackpackCargoGlobal _container;
        clearItemCargoGlobal _container;
        clearMagazineCargoGlobal _container;
        clearWeaponCargoGlobal _container;
    };

    //Append to player loot storage
    private _playerLoot = player call NWG_fnc_lsGetPlayerLoot;
    {
        _x call NWG_fnc_unCompactStringArray;//Uncompact
        _x append (_loot#_forEachIndex);//Append
        _x call NWG_fnc_compactStringArray;//Compact
    } forEach _playerLoot;
    [player,_playerLoot] call NWG_fnc_lsSetPlayerLoot;//Save
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;