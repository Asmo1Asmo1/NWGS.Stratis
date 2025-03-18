#include "..\..\globalDefines.h"
/*
    Connector between shopItems and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_ISHOP_MMC_Settings = createHashMapFromArray [
    ["CHECK_PERSISTENT_ITEMS",true],//Check validity of persistent items on economy state
    ["ADD_ITEMS_MIN_MAX",[1,2]],//Number of items to add on mission completion

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_ISHOP_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_ISHOP_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    switch (_newState) do {
        /*Base building economy state - Initialize items shop module*/
        case MSTATE_BASE_ECONOMY: {
            //Check persistent items
            if (NWG_ISHOP_MMC_Settings get "CHECK_PERSISTENT_ITEMS") then {
                private _ok = call NWG_ISHOP_SER_ValidatePersistentItems;
                if !(_ok) then {
                    "NWG_ISHOP_MMC_OnMissionStateChanged: Persistent items are invalid" call NWG_fnc_logError;
                };
            };

            //Download prices from DB
            private _pricesChart = call NWG_fnc_dbLoadItemPrices;
            if (_pricesChart isEqualTo false) exitWith {
                "NWG_ISHOP_MMC_OnMissionStateChanged: Failed to load items prices" call NWG_fnc_logError;
            };
            private _ok = _pricesChart call NWG_fnc_ishopUploadPrices;
            if !(_ok) then {
                "NWG_ISHOP_MMC_OnMissionStateChanged: Failed to upload items prices" call NWG_fnc_logError;
            };
        };

        /*Mission completed state - Add items to dynamic shop items*/
        case MSTATE_COMPLETED: {
            //Add items to dynamic shop items
            private _setsCount = NWG_ISHOP_MMC_Settings get "ADD_ITEMS_MIN_MAX";
            _setsCount = _setsCount call NWG_fnc_mmInterpolateByLevelInt;
            private _sets = ["SHOP","",_setsCount] call NWG_fnc_lmGenerateLootSet;
            if (_sets isEqualTo false) exitWith {
                "NWG_ISHOP_MMC_OnMissionStateChanged: Failed to generate loot set" call NWG_fnc_logError;
            };
            (flatten _sets) call NWG_fnc_ishopAddDynamicItems;
        };

        /*Server reset/restart - save prices to DB before shutting down*/
        case MSTATE_RESET;
        case MSTATE_SERVER_RESTART: {
            //Upload prices to DB
            private _pricesChart = call NWG_fnc_ishopDownloadPrices;
            if (_pricesChart isEqualTo false) exitWith {
                "NWG_ISHOP_MMC_OnMissionStateChanged: Failed to get items prices" call NWG_fnc_logError;
            };
            private _ok = _pricesChart call NWG_fnc_dbSaveItemPrices;
            if !(_ok) then {
                "NWG_ISHOP_MMC_OnMissionStateChanged: Failed to save items prices" call NWG_fnc_logError;
            };
        };

        default {};
    };
};

//================================================================================================================
call _Init;