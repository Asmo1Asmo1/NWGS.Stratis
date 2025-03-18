#include "..\..\globalDefines.h"

[EVENT_ON_MISSION_STATE_CHANGED,{
	params ["","_newState"];
	if (_newState == MSTATE_ESCAPE_SETUP) then {
		NWG_DLG_TAXI_IsEscape = true;
		publicVariable "NWG_DLG_TAXI_IsEscape";
	};
}] call NWG_fnc_subscribeToServerEvent;