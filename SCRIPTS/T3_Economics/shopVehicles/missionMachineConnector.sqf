#include "..\..\globalDefines.h"
/*
    Connector between shopVehicles and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_VSHOP_MMC_Settings = createHashMapFromArray [
    ["SPAWN_PLATFORM","Land_JumpTarget_F"],//Classname of the object that will be used as a spawn platform
    ["CHECK_PERSISTENT_ITEMS",true],//Check validity of persistent items on economy state
    ["ADD_ITEMS_MIN_MAX",[1,2]],//Number of items to add on mission completion

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

            //Download prices from DB
            private _pricesChart = call NWG_fnc_dbLoadVehiclePrices;
            if (_pricesChart isEqualTo false) exitWith {
                "NWG_VSHOP_MMC_OnMissionStateChanged: Failed to load vehicles prices" call NWG_fnc_logError;
            };
            private _ok = _pricesChart call NWG_fnc_vshopUploadPrices;
            if !(_ok) then {
                "NWG_VSHOP_MMC_OnMissionStateChanged: Failed to upload vehicles prices" call NWG_fnc_logError;
            };
        };

        /*Mission completed state - Add vehicles to dynamic shop items*/
        case MSTATE_COMPLETED: {
            //Add vehicles to dynamic shop items
            private _itemsCount = NWG_VSHOP_MMC_Settings get "ADD_ITEMS_MIN_MAX";
            _itemsCount = _itemsCount call NWG_fnc_mmInterpolateByLevelInt;
            _itemsCount call NWG_fnc_vshopAddDynamicItems;
        };

        /*Server reset/restart - save prices to DB before shutting down*/
        case MSTATE_RESET;
        case MSTATE_SERVER_RESTART: {
            //Upload prices to DB
            private _pricesChart = call NWG_fnc_vshopDownloadPrices;
            if (_pricesChart isEqualTo false) exitWith {
                "NWG_VSHOP_MMC_OnMissionStateChanged: Failed to get vehicles prices" call NWG_fnc_logError;
            };
            private _ok = _pricesChart call NWG_fnc_dbSaveVehiclePrices;
            if !(_ok) then {
                "NWG_VSHOP_MMC_OnMissionStateChanged: Failed to save vehicles prices" call NWG_fnc_logError;
            };
        };

        default {};
    };
};

//================================================================================================================
call _Init;