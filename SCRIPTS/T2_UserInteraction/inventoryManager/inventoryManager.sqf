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
    (getUnitLoadout player) call NWG_INV_UpdateFields;//Save initial loadout

    player addEventHandler ["InventoryClosed",{call NWG_INV_CheckLoadoutChange}];
    player addEventHandler ["Take",{call NWG_INV_CheckLoadoutChange}];
    player addEventHandler ["Put",{call NWG_INV_CheckLoadoutChange}];
    player addEventHandler ["WeaponAssembled",{call NWG_INV_CheckLoadoutChange}];//Also works for UAVs
    [missionNamespace,"arsenalClosed",{call NWG_INV_CheckLoadoutChange}] call BIS_fnc_addScriptedEventHandler;
};

//================================================================================================================
//================================================================================================================
//Loadout changes check
NWG_INV_UpdateFields = {
    // private _loadout = _this;
    NWG_INV_currentLoadout = _this;
    NWG_INV_currentLoadoutFlattened = (flatten _this) select {_x isEqualType "" && {_x isNotEqualTo ""}};
};

NWG_INV_CheckLoadoutChange = {
    private _newLoadout = (getUnitLoadout player);
    if (_newLoadout isEqualTo NWG_INV_currentLoadout) exitWith {};//No changes

    _newLoadout call NWG_INV_UpdateFields;//Update fields
    [EVENT_ON_LOADOUT_CHANGED,[]] call NWG_fnc_raiseClientEvent;//Raise event
};

//================================================================================================================
//================================================================================================================
//Items manipulation
NWG_INV_HasItem = {
    // private _itemClassname = _this;
    _this in NWG_INV_currentLoadoutFlattened
};

NWG_INV_RemoveItem = {
    // private _itemClassname = _this;
    if !(_this call NWG_INV_HasItem) exitWith {false};//Item not found
    player removeItem _this;
    call NWG_INV_CheckLoadoutChange;
    true
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;