#include "..\..\globalDefines.h"

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
//params:
// - _container - object
// - _listboxIDC - number
//returns: boolean - true if looting was successful, false if not
NWG_fnc_lsLootContainerByUI = {
    // params [["_container",objNull],["_listboxIDC",-1]];
    _this call NWG_LS_CLI_LootByInventoryUI
};

/*Other systems->Client*/
//Open loot storage
NWG_fnc_lsOpenStorage = {
    call NWG_LS_CLI_OpenMyStorage;
};

//Returns true if loot storage is open currently
//note: use with event handler "InventoryOpened"
NWG_fnc_lsIsStorageOpen = {
    !isNil "NWG_LS_CLI_invisibleBox" && {!isNull NWG_LS_CLI_invisibleBox}
};

//Loot the container
//params: _container - object
//returns: boolean - true if looting was successful, false if not
NWG_fnc_lsLootContainer = {
    _this call NWG_LS_CLI_LootByAction
};

/*Any->Any*/
//Get loot storage of a player
//params: _player - object
//returns: array - player loot in format: [[clothes],[weapons],[items],[ammunition]]
// each element is an array of items and optional counts: ["item1",countOfItem2,"item2",...]
NWG_fnc_lsGetPlayerLoot = {
    // private _player = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_lsGetPlayerLoot: Invalid player" call NWG_fnc_logError;
        LOOT_ITEM_DEFAULT_CHART
    };
    if (isNull _this) exitWith {
        "NWG_fnc_lsGetPlayerLoot: Player is null" call NWG_fnc_logError;
        LOOT_ITEM_DEFAULT_CHART
    };

    _this call NWG_LS_COM_GetPlayerLoot
};

//Add to player loot storage
//note: this function adds to local copy of player loot storage, if you want to add to server side as well, use remoteExec
//params: _player - object
//params: _loot - array of arrays (loot structure)
NWG_fnc_lsAddToLocalPlayerLoot = {
    params ["_player","_loot"];
    if !(_player isEqualType objNull) exitWith {
        "NWG_fnc_lsAddToLocalPlayerLoot: Invalid player" call NWG_fnc_logError;
    };
    if (isNull _player) exitWith {
        "NWG_fnc_lsAddToLocalPlayerLoot: Player is null" call NWG_fnc_logError;
    };
    if !(_loot isEqualType []) exitWith {
        "NWG_fnc_lsAddToLocalPlayerLoot: Invalid loot" call NWG_fnc_logError;
    };

    _this call NWG_LS_COM_AddToLocalPlayerLoot;
};

//Set loot storage for a player
//params: _player - object
//params: _loot - array of arrays (loot structure)
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

//Deplete loot
//params:
//  _loot - array
//  _multiplier - number (0..1)
//  _notify - [optional] boolean, send system chat notification where method was called from (so prefer to use 'true' only for client side) (default: true)
//returns:
//  array - modified loot array
NWG_fnc_lsDepleteLoot = {
    // params ["_loot","_multiplier",["_notify",true]];
    _this call NWG_LS_COM_DepleteLoot
};
