#include "..\..\globalDefines.h"
/*
    Connector between actionsItems and missionMachine modules
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_AI_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_AI_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

    switch (_newState) do {
        case MSTATE_BUILD_ECONOMY: {
			private _missionPos = call NWG_fnc_mmGetMissionPos;
			if (_missionPos isEqualTo []) exitWith {};
			_missionPos call NWG_fnc_aiSetMissionPos;
        };
        case MSTATE_CLEANUP: {
			call NWG_fnc_aiDropMissionPos;
        };
        default {};
    };
};

//================================================================================================================
call _Init;