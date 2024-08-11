//================================================================================================================
//================================================================================================================
//Settings (this time as defines - can not be changed in runtime anyway)
#define OPEN_STORAGE_ACTION_PRIORITY 6
#define OPEN_STORAGE_ACTION_RADIUS 3

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
    //TODO: Implement
    systemChat "NWG_LS_CLI_OpenMyStorage: Storage opened";
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;