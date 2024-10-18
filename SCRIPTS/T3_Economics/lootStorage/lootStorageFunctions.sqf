/*Other systems->Server*/
//Setup loot storage object (object that gives access to loot storage via action)
//params: _storageObject - object
NWG_fnc_lsSetLootStorageObject = {
    // private _storageObject = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_lsSetLootStorageObject: Invalid storage object" call NWG_fnc_logError;
    };
    if (isNull _this) exitWith {
        "NWG_fnc_lsSetLootStorageObject: Storage object is null" call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_LS_SER_SetStorageObject}
        else {_this remoteExec ["NWG_fnc_lsSetLootStorageObject",2]};
};

/*UI->Client*/
//Loot the container opened in inventory
//params: "InventoryOpened" event args: ["_unit","_mainContainer","_secdContainer"];
//note: this function must be called from within the inventory UI
//returns: boolean - true if looting was successful, false if not
NWG_fnc_lsLootContainerByUI = {
    // params ["_unit","_mainContainer","_secdContainer"];
    _this call NWG_LS_CLI_LootByInventoryUI
};

/*Any->Any*/
//Get loot storage of a player
//params: _player - object
//returns: array - player loot in format: [[clothes],[weapons],[items],[ammunition]]
// each element is an array of items and optionsl counts: ["item1",countOfItem2,"item2",...]
NWG_fnc_lsGetPlayerLoot = {
    // private _player = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_lsGetPlayerLoot: Invalid player" call NWG_fnc_logError;
        [[],[],[],[]]
    };
    if (isNull _this) exitWith {
        "NWG_fnc_lsGetPlayerLoot: Player is null" call NWG_fnc_logError;
        [[],[],[],[]]
    };

    _this call NWG_LS_COM_GetPlayerLoot;
};

//Set loot storage for a player
//params: _player - object
//params: _loot - array
NWG_fnc_lsSetPlayerLoot = {
    params ["_player","_loot"];
    if !(_player isEqualType objNull) exitWith {
        "NWG_fnc_lsSetPlayerLoot: Invalid player" call NWG_fnc_logError;
    };
    if (isNull _player) exitWith {
        "NWG_fnc_lsSetPlayerLoot: Player is null" call NWG_fnc_logError;
    };
    if !(_loot isEqualType []) exitWith {
        "NWG_fnc_lsSetPlayerLoot: Invalid loot" call NWG_fnc_logError;
    };

    _this call NWG_LS_COM_SetPlayerLoot;
};