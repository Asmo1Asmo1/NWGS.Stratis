#include "..\..\globalDefines.h"
/*
    Connector between shopVehicles and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_VSHOP_MMC_Settings = createHashMapFromArray [
    ["VSHOP_SPAWN_PLATFORM","Land_JumpTarget_F"],//Classname of the object that will be used as a spawn platform
    ["VSHOP_CHECK_PERSISTENT_ITEMS",true],//Check validity of persistent items on economy state

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_VSHOP_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_VSHOP_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    //Check state
    if (_newState != MSTATE_BASE_ECONOMY) exitWith {/*Do nothing*/};

    //Check persistent items
    if (NWG_VSHOP_MMC_Settings get "VSHOP_CHECK_PERSISTENT_ITEMS") then {
        call NWG_VSHOP_SER_ValidatePersistentItems;
    };

    //Get player base
    (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
    if !(_baseDecor isEqualType []) exitWith {
        "NWG_VSHOP_MMC_OnMissionStateChanged: Invalid base decor" call NWG_fnc_logError;
    };

    //Get spawn platform classname
    private _spawnPlatformClassname = NWG_VSHOP_MMC_Settings get "VSHOP_SPAWN_PLATFORM";
    if (_spawnPlatformClassname isEqualTo "") exitWith {
        "NWG_VSHOP_MMC_OnMissionStateChanged: Spawn platform classname not set" call NWG_fnc_logError;
    };

    //Find spawn platform object in base decor
    private _spawnPlatform = objNull;
    private _i = -1;
    //forEach category of objects
    {
        _i = _x findIf {(typeOf _x) isEqualTo _spawnPlatformClassname};
        if (_i != -1) exitWith {_spawnPlatform = _x select _i};
    } forEach _baseDecor;

    if (isNull _spawnPlatform) exitWith {
        "NWG_VSHOP_MMC_OnMissionStateChanged: Spawn platform not found in base decor" call NWG_fnc_logError;
    };

    //Set spawn platform object
    _spawnPlatform call NWG_fnc_vshopSetSpawnPlatformObject;
};

//================================================================================================================
call _Init;