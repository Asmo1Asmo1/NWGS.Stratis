#include "..\..\globalDefines.h"
/*
    Connector between escapeBillboard and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_ESCB_MMC_Settings = createHashMapFromArray [
    ["BILLBOARD_CLASSNAME","Land_Billboard_02_blank_F"],//Classname of the object that will be used as a billboard

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_ESCB_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_ESCB_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    switch (_newState) do {
        /*Base building economy state - Initialize billboard module*/
        case MSTATE_BASE_ECONOMY: {
            //Get player base
            (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
            if !(_baseDecor isEqualType []) exitWith {
                "NWG_ESCB_MMC_OnMissionStateChanged: Invalid base decor" call NWG_fnc_logError;
            };

            //Get billboard classname
            private _billboardClassname = NWG_ESCB_MMC_Settings getOrDefault ["BILLBOARD_CLASSNAME",""];
            if (_billboardClassname isEqualTo "") exitWith {
                "NWG_ESCB_MMC_OnMissionStateChanged: Billboard classname not set" call NWG_fnc_logError;
            };

            //Find billboard object in base decor
            private _billboard = objNull;
            private _i = -1;
            //forEach category of objects
            {
                _i = _x findIf {(typeOf _x) isEqualTo _billboardClassname};
                if (_i != -1) exitWith {_billboard = _x select _i};
            } forEach _baseDecor;
            if (isNull _billboard) exitWith {
                "NWG_ESCB_MMC_OnMissionStateChanged: Billboard not found in base decor" call NWG_fnc_logError;
            };

            //Set billboard object
            _billboard call NWG_fnc_escbSetBillboardObject;

            //Download winners names from DB
            private _winners = if (!isNil "NWG_fnc_dbLoadEscapeWinners")
                then {call NWG_fnc_dbLoadEscapeWinners}
                else {false};
            if (isNil "_winners" || {_winners isEqualTo false}) then {
                "NWG_ESCB_MMC_OnMissionStateChanged: Failed to load winners names" call NWG_fnc_logError;
                _winners = [];
            };

            //Set winners names
            _winners call NWG_fnc_escbSetWinners;
        };

        /*Escape completed state - Add new winners names to billboard and save them to DB*/
        case MSTATE_ESCAPE_COMPLETED: {
            private _winners = ((call NWG_fnc_getPlayersAll) select {_x call NWG_fnc_mmIsPlayerInEscapeVehicle}) apply {name _x};
            _winners = _winners call NWG_fnc_escbAddWinners;//Add winners names to billboard (applies limits and other stuff)
            private _ok = if (!isNil "NWG_fnc_dbSaveEscapeWinners")
                then {_winners call NWG_fnc_dbSaveEscapeWinners}
                else {false};
            if !(_ok) then {
                "NWG_ESCB_MMC_OnMissionStateChanged: Failed to save winners names" call NWG_fnc_logError;
            };
        };

        default {};
    };
};

//================================================================================================================
call _Init;