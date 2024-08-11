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
    switch (_newState) do {
        /* Base Loot Storage Init */
        case MSTATE_BASE_ECONOMY: {
            //Initialize loot storage at player base
            (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
            if !(_baseDecor isEqualType []) exitWith {
                (format ["NWG_LS_MMC_OnMissionStateChanged: Invalid base decor '%1'",(typeOf _baseDecor)]) call NWG_fnc_logError;
            };
            _baseDecor = flatten _baseDecor;
            if (_baseDecor isEqualTo []) exitWith {
                "NWG_LS_MMC_OnMissionStateChanged: Base decor not found" call NWG_fnc_logError;
            };

            private _lootStorageClassname = NWG_LS_MMC_Settings get "LOOT_STORAGE_OBJECT";
            if (_lootStorageClassname isEqualTo "") exitWith {
                "NWG_LS_MMC_OnMissionStateChanged: Loot storage classname not set" call NWG_fnc_logError;
            };

            private _i = _baseDecor findIf {(typeOf _x) isEqualTo _lootStorageClassname};
            if (_i isEqualTo -1) exitWith {
                "NWG_LS_MMC_OnMissionStateChanged: Loot storage not found in base decor" call NWG_fnc_logError;
            };

            private _lootStorage = _baseDecor select _i;
            if (isNull _lootStorage) exitWith {
                "NWG_LS_MMC_OnMissionStateChanged: Loot storage object is null" call NWG_fnc_logError;//Should not happen
            };

            _lootStorage call NWG_fnc_lsSetLootStorageObject;
        };

        default {/*Do nothing*/};
    };
};

//================================================================================================================
call _Init;