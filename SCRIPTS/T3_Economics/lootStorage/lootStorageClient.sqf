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
    private _loot = player call NWG_fnc_lsGetPlayerLoot;
    _loot = flatten _loot;//Flatten and shallow copy

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
[] spawn _Init;