#include "..\..\globalDefines.h"
/*
    Connector between lootStorage and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_LS_MMC_Settings = createHashMapFromArray [
    ["LOOT_STORAGE_OBJECT","B_supplyCrate_F"],//Classname of the object that will be used as a loot storage

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_LS_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_LS_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    //Check state
    if (_newState != MSTATE_BASE_ECONOMY) exitWith {/*Do nothing*/};

    //Get player base
    (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
    if !(_baseDecor isEqualType []) exitWith {
        "NWG_LS_MMC_OnMissionStateChanged: Invalid base decor" call NWG_fnc_logError;
    };

    //Get loot storage classname
    private _lootStorageClassname = NWG_LS_MMC_Settings get "LOOT_STORAGE_OBJECT";
    if (_lootStorageClassname isEqualTo "") exitWith {
        "NWG_LS_MMC_OnMissionStateChanged: Loot storage classname not set" call NWG_fnc_logError;
    };

    //Find loot storage object in base decor
    private _lootStorage = objNull;
    private _i = -1;
    //forEach category of objects
    {
        _i = _x findIf {(typeOf _x) isEqualTo _lootStorageClassname};
        if (_i != -1) exitWith {_lootStorage = _x select _i};
    } forEach _baseDecor;

    if (isNull _lootStorage) exitWith {
        "NWG_LS_MMC_OnMissionStateChanged: Loot storage not found in base decor" call NWG_fnc_logError;
    };

    //Set loot storage object
    _lootStorage call NWG_fnc_lsSetLootStorageObject;
};

//================================================================================================================
call _Init;