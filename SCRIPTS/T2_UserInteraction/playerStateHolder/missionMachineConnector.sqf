#include "..\..\globalDefines.h"
/*
    Connector between playerStateHolder and missionMachine module
*/

//================================================================================================================
//Settings
NWG_PSH_MMC_Settings = createHashMapFromArray [
    ["SYNC_ON_STATES",[MSTATE_RESET,MSTATE_SERVER_RESTART]],//States on which player state will be synced with database

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_PSH_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_PSH_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
	if (_newState in (NWG_PSH_MMC_Settings get "SYNC_ON_STATES")) then {
		call NWG_fnc_pshInvokeSync;
	};
};
