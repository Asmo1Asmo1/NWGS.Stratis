#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Fields
NWG_INV_currentLoadout = [];
NWG_INV_currentLoadoutFlattened = [];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    call NWG_INV_CheckLoadoutChange;//Initial check (will update the fields)

    player addEventHandler ["InventoryClosed",{call NWG_INV_CheckLoadoutChange}];
    player addEventHandler ["Take",{call NWG_INV_CheckLoadoutChange}];
    player addEventHandler ["Put",{call NWG_INV_CheckLoadoutChange}];
    // player addEventHandler ["SlotItemChanged",{call NWG_INV_CheckLoadoutChange}];//Too much events
    player addEventHandler ["WeaponAssembled",{call NWG_INV_CheckLoadoutChange}];//Also works for UAVs
    [missionNamespace,"arsenalClosed",{call NWG_INV_CheckLoadoutChange}] call BIS_fnc_addScriptedEventHandler;
};

//================================================================================================================
//================================================================================================================
//Loadout changes check
NWG_INV_CheckLoadoutChange = {
    private _newLoadout = (getUnitLoadout player);
    if (_newLoadout isEqualTo NWG_INV_currentLoadout) exitWith {false};//No changes

    private _flattened = [];
    /*Weapons*/_flattened append ((flatten (_newLoadout select [0,3])) select {_x isEqualType "" && {_x isNotEqualTo ""}});//Non-empty strings
    /*Clothes*/_flattened append  (flatten (_newLoadout select [3,3]));//Strings and numbers
    /* Items */_flattened append ((flatten (_newLoadout select [6])) select {_x isEqualType "" && {_x isNotEqualTo ""}});//Strings again

    NWG_INV_currentLoadout = _newLoadout;//Save
    NWG_INV_currentLoadoutFlattened = _flattened;//Save
    [EVENT_ON_LOADOUT_CHANGED,[_newLoadout,_flattened]] call NWG_fnc_raiseClientEvent;//Raise event

    //return
    true
};

//================================================================================================================
//================================================================================================================
//Items manipulation
NWG_INV_HasItem = {
    // private _itemClassname = _this;
    _this in NWG_INV_currentLoadoutFlattened
};

NWG_INV_GetItemCount = {
    // private _itemClassname = _this;
    private _i = -1;
    private _count = 0;
    private _totalCount = 0;
    private _temp = NWG_INV_currentLoadoutFlattened;
    while {_i = _temp find _this; _i != -1} do {
        _count = _temp param [(_i+1),false];
        if (_count isEqualType 1)
            then {_totalCount = _totalCount + _count}
            else {_totalCount = _totalCount + 1};
        _temp = _temp select [(_i+1)];//Select from next element to end of array (safe even if _i was last index)
    };

    _totalCount
};

NWG_INV_RemoveItem = {
    // private _itemClassname = _this;
    if !(_this in NWG_INV_currentLoadoutFlattened) exitWith {false};//Item not found
    player removeItem _this;
    call NWG_INV_CheckLoadoutChange
};

NWG_INV_RemoveItems = {
    params ["_items","_counts"];
    {
        if !(_x in NWG_INV_currentLoadoutFlattened) then {continue};//Item not found
        for "_i" from 1 to (_counts param [_forEachIndex,0]) do {player removeItem _x};
    } forEach _items;
    call NWG_INV_CheckLoadoutChange
};

NWG_INV_AddItem = {
    // private _itemClassname = _this;
    player addItem _this;
    call NWG_INV_CheckLoadoutChange
};

NWG_INV_ExchangeItem = {
    params ["_oldItem","_newItem"];
    if !(_oldItem in NWG_INV_currentLoadoutFlattened) exitWith {false};//Item not found
    player removeItem _oldItem;
    player addItem _newItem;
    call NWG_INV_CheckLoadoutChange
};

//================================================================================================================
//================================================================================================================
//Loadout set for player
NWG_INV_SetPlayerLoadout = {
    private _loadout = _this;
    if (isNull player || {!local player}) exitWith {
        "NWG_INV_SetPlayerLoadout: Player is invalid" call NWG_fnc_logError;
    };

    player setVariable ["NWG_INV_loadoutSetInProgress",true];
    private _callback = {
        //Drop flag
        player setVariable ["NWG_INV_loadoutSetInProgress",false];
        //Fix inventory window
        if (!isNull (uiNamespace getVariable ["RscDisplayInventory", displayNull])) then {
            player addItem "Antibiotic";
            player removeItem "Antibiotic";
        };
        //Invoke loadout change check
        call NWG_INV_CheckLoadoutChange;
    };

    [player,_loadout,_callback] call NWG_fnc_setUnitLoadout;
};

NWG_INV_IsPlayerLoadoutSetInProgress = {
    player getVariable ["NWG_INV_loadoutSetInProgress",false]
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;