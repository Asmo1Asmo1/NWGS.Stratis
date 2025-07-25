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

	//Separate crews of artillery-capable vehicles into separate groups
	{
		if !(alive _x) then {continue};//Not alive
		if !(alive (gunner _x)) then {continue};//No gunner
		if ((getArtilleryAmmo [_x]) isEqualTo []) then {continue};//No artillery capabilities

		private _veh = _x;
		private _crew = (crew _veh) select {alive _x};
		if ((count _crew) == 0) then {continue};//Empty vehicle
		if ((side _veh) != _mSide) then {continue};//Not of mission side
		if ((count (units (group (_crew#0)))) == (count _crew)) then {continue};//All crew is already in the separate group

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
				"NWG_YK_MMC_OnMissionStateChanged: Failed to separate crew" call NWG_fnc_logError;
			};
		};
	} forEach ((_mObjects#OBJ_CAT_VEHC) + (_mObjects#OBJ_CAT_TRRT));
};

//================================================================================================================
call _Init;
