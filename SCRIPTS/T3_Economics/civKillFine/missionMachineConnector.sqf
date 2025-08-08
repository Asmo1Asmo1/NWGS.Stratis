#include "..\..\globalDefines.h"
/*
    Connector between civKillFine and missionMachine to separate MORTAR and ARTA groups for ease of use by civKillFine
*/

[EVENT_ON_MISSION_STATE_CHANGED,{
	params ["","_newState"];
    if (_newState == MSTATE_READY) then {call NWG_CKF_Reset};//Reset fine on switch to ready state
}] call NWG_fnc_subscribeToServerEvent;
