#include "..\..\globalDefines.h"
/*
    Addon-Connector between missionMachine and database to store unlocked levels
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_MM_DBC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_MM_DBC_ignoreSave = false;
NWG_MM_DBC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    switch (_newState) do {
        /*Base building economy state - Initialize unlocked levels*/
        case MSTATE_BASE_ECONOMY: {
            //Load unlocked levels from DB
			if (isNil "NWG_fnc_dbLoadUnlockedLevels") exitWith {
				"NWG_MM_DBC_OnMissionStateChanged: db function is not defined" call NWG_fnc_logError;
			};
            private _unlockedLevels = call NWG_fnc_dbLoadUnlockedLevels;
            if (_unlockedLevels isEqualTo false) exitWith {
                "NWG_MM_DBC_OnMissionStateChanged: Failed to load unlocked levels" call NWG_fnc_logError;
            };
			private _isEmpty = _unlockedLevels isEqualTo [];
			private _isValid = _unlockedLevels isEqualType [] && {_unlockedLevels isEqualTypeAll false};
			if !(_isEmpty || _isValid) exitWith {
				(format ["NWG_MM_DBC_OnMissionStateChanged: Invalid unlocked levels format: '%1'",_unlockedLevels]) call NWG_fnc_logError;
            };
			private _levelCount = count (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS");
			if ((count _unlockedLevels) >= _levelCount) then {
				_unlockedLevels resize (_levelCount-1);//Exclude last level on load
			};
            NWG_MIS_UnlockedLevels = _unlockedLevels;//Assign to global variable
			private _updated = call NWG_MIS_SER_UpdateUnlockedLevels;//Update for server and clients
			if !(_updated) exitWith {
				publicVariable "NWG_MIS_UnlockedLevels";//Force update for clients if levels are "same as before" because they are not
			};
        };

		/*Escape completed state - save unlocked levels to DB as empty array (we're dropping unlocked levels after escape mission)*/
		case MSTATE_ESCAPE_COMPLETED: {
			//Save empty array to DB
			if (isNil "NWG_fnc_dbSaveUnlockedLevels") exitWith {
				"NWG_MM_DBC_OnMissionStateChanged: db function is not defined" call NWG_fnc_logError;
			};
			private _ok = [] call NWG_fnc_dbSaveUnlockedLevels;
			if !(_ok) exitWith {
				"NWG_MM_DBC_OnMissionStateChanged: Failed to save unlocked levels" call NWG_fnc_logError;
			};
			"NWG_MM_DBC_OnMissionStateChanged: Unlocked levels saved on ESCAPE COMPLETED" call NWG_fnc_logInfo;
			//Ignore next save
			NWG_MM_DBC_ignoreSave = true;
		};

        /*Server reset/restart - save unlocked levels to DB before shutting down*/
        case MSTATE_RESET;
        case MSTATE_SERVER_RESTART: {
			//Check if should ignore save
			if (NWG_MM_DBC_ignoreSave) exitWith {
				"NWG_MM_DBC_OnMissionStateChanged: Ignoring save on RESET/RESTART due to escape completed state" call NWG_fnc_logInfo;
				NWG_MM_DBC_ignoreSave = false;//Reset ignore save flag (shouldn't be needed, but just in case)
			};
            //Save unlocked levels to DB
			if (isNil "NWG_fnc_dbSaveUnlockedLevels") exitWith {
				"NWG_MM_DBC_OnMissionStateChanged: db function is not defined" call NWG_fnc_logError;
			};
            private _unlockedLevels = NWG_MIS_UnlockedLevels + [];//Shallow copy
            private _ok = _unlockedLevels call NWG_fnc_dbSaveUnlockedLevels;
            if !(_ok) exitWith {
                "NWG_MM_DBC_OnMissionStateChanged: Failed to save unlocked levels" call NWG_fnc_logError;
            };
        };

        default {};
    };
};

//================================================================================================================
call _Init;