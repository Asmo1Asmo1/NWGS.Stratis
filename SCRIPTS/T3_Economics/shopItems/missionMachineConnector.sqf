#include "..\..\globalDefines.h"
/*
    Connector between shopItems and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_ISHOP_MMC_Settings = createHashMapFromArray [
    ["ISHOP_CHECK_PERSISTENT_ITEMS",true],//Check validity of persistent items on economy state

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

    //Check state
    if (_newState != MSTATE_BASE_ECONOMY) exitWith {/*Do nothing*/};

    //Check persistent items
    if (NWG_ISHOP_MMC_Settings get "ISHOP_CHECK_PERSISTENT_ITEMS") then {
        private _ok = call NWG_ISHOP_SER_ValidatePersistentItems;
        if !(_ok) then {
            "NWG_ISHOP_MMC_OnMissionStateChanged: Persistent items are invalid" call NWG_fnc_logError;
        };
    };
};

//================================================================================================================
call _Init;