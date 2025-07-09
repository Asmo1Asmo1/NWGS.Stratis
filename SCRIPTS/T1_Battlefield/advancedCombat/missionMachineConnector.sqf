#include "..\..\globalDefines.h"
/*
    Connector between advancedCombat and missionMachine to apply passive logic to mission units
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_AC_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_AC_MMC_OnMissionStateChanged = {
    params ["_oldState",""];
    if (_oldState != MSTATE_BUILD_UKREP) exitWith {};//Work after mission ukrep is finished

	//Get mission objects and side
	private _mObjects = call NWG_fnc_mmGetMissionObjects;

	//Allow wounded
	if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_WOUNDED") then {
		(_mObjects#OBJ_CAT_UNIT) call NWG_ACP_AllowWounded;
	};

	//Allow stay in vehicles
	if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_STAY_IN_VEHICLE") then {
		{_x call NWG_ACP_AllowStayInVehicle} forEach (_mObjects#OBJ_CAT_VEHC);
	};
};

//================================================================================================================
call _Init;
