#include "..\..\globalDefines.h"
/*
    Connector between shopVehicles and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_VSHOP_MMC_Settings = createHashMapFromArray [
    ["SPAWN_PLATFORM","Land_JumpTarget_F"],//Classname of the object that will be used as a spawn platform
    ["CHECK_PERSISTENT_ITEMS",true],//Check validity of persistent items on economy state

    ["ADD_ITEMS_EASY",[2,3]],//Number of items to add on easy missions
    ["ADD_ITEMS_NORM",[3,4]],//Number of items to add on normal missions
    ["ADD_ITEMS_DFLT",[2,3]],//Number of items to add if mission difficulty is unknown

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

	switch (_newState) do {
		/*Base building economy state - Initialize vehicle shop module*/
		case MSTATE_BASE_ECONOMY: {
            //Check persistent items
            if (NWG_VSHOP_MMC_Settings get "CHECK_PERSISTENT_ITEMS") then {
                private _ok = call NWG_VSHOP_SER_ValidatePersistentItems;
                if !(_ok) then {
                    "NWG_VSHOP_MMC_OnMissionStateChanged: Persistent items are invalid" call NWG_fnc_logError;
                };
            };

            //Get player base
            (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
            if !(_baseDecor isEqualType []) exitWith {
                "NWG_VSHOP_MMC_OnMissionStateChanged: Invalid base decor" call NWG_fnc_logError;
            };

            //Get spawn platform classname
            private _spawnPlatformClassname = NWG_VSHOP_MMC_Settings get "SPAWN_PLATFORM";
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

		/*Mission building economy state - Add vehicles to dynamic shop items*/
		case MSTATE_BUILD_ECONOMY: {
            //Add vehicles to dynamic shop items
            private _mDiffclt = call NWG_fnc_mmGetMissionDifficulty;
            private _addItems = switch (_mDiffclt) do {
                case MISSION_DIFFICULTY_EASY: {NWG_VSHOP_MMC_Settings get "ADD_ITEMS_EASY"};
                case MISSION_DIFFICULTY_NORM: {NWG_VSHOP_MMC_Settings get "ADD_ITEMS_NORM"};
                default {
                    (format ["NWG_VSHOP_MMC_OnMissionStateChanged: Unknown mission difficulty: %1",_mDiffclt]) call NWG_fnc_logError;
                    NWG_VSHOP_MMC_Settings get "ADD_ITEMS_DFLT";
                };
            };
            _addItems = _addItems call NWG_fnc_randomRangeInt;
            _addItems call NWG_fnc_vshopAddDynamicItems;
		};

		default {};
	};
};

//================================================================================================================
call _Init;