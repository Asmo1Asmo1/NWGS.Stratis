#include "..\..\globalDefines.h"
/*
    Connector between yellowKing and missionMachine to separate MORTAR and ARTA groups for ease of use by yellowKing
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_YK_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_YK_MMC_OnMissionStateChanged = {
    params ["_oldState",""];
    if (_oldState != MSTATE_BUILD_UKREP) exitWith {};//Work after mission ukrep is finished

	//Get mission objects and side
	private _mObjects = call NWG_fnc_mmGetMissionObjects;
	private _mSide = call NWG_fnc_mmGetMissionSide;

	//Prepare script
	private _separate = {
		// private _veh = _this;
		private _crew = (crew _this) select {alive _x};
		if ((count _crew) == 0) exitWith {};//Empty vehicle
		if ((side _this) != _mSide) exitWith {};//Not of mission side
		if ((count (units (group (_crew#0)))) == (count _crew)) exitWith {};//All crew is in the group

		private _newGroup = createGroup [_mSide,true];
		[_crew,_newGroup] spawn {
			params ["_crew","_newGroup"];
			private _attempts = 100;
			while {((count _crew) > 0) && {_attempts > 0}} do {
				_attempts = _attempts - 1;
				{
					if (_x in (units _newGroup))
						then {_crew deleteAt _forEachIndex}
						else {[_x] joinSilent _newGroup};
				} forEachReversed _crew;
				sleep 1;
			};
			if (_attempts <= 0) then {
				(format ["NWG_YK_MMC_OnMissionStateChanged: Failed to separate crew of %1",_this]) call NWG_fnc_logError;
			};
		};
	};

	//Process vehicles
	{
		_x call _separate;
	} forEach ((_mObjects#OBJ_CAT_VEHC) select {alive _x && {_x call NWG_fnc_ocIsVehicle && {((getArtilleryAmmo [_x]) isNotEqualTo []) && {alive (gunner _x)}}}});

	//Process turrets
	{
		_x call _separate;
	} forEach ((_mObjects#OBJ_CAT_TRRT) select {alive _x && {_x call NWG_fnc_ocIsTurret && {((getArtilleryAmmo [_x]) isNotEqualTo []) && {alive (gunner _x)}}}});
};

//================================================================================================================
call _Init;
