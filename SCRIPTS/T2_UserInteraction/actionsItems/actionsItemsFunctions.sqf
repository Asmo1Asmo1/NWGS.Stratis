/*Client->Server*/
//Request to build camp where player is
//params: player - player object
NWG_fnc_aiRequestCamp = {
    // private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		"NWG_fnc_aiRequestCamp: Invalid player object" call NWG_fnc_logError;
	};
	if (isNull _this || {!alive _this}) exitWith {
		"NWG_fnc_aiRequestCamp: Player is null or dead" call NWG_fnc_logError;
	};

	if (isServer)
		then {_this call NWG_AI_SER_OnRequestCamp}
		else {_this remoteExec ["NWG_fnc_aiRequestCamp",2]};
};

/*Any->Server*/
//Set mission pos
//params: [pos,rad]
NWG_fnc_aiSetMissionPos = {
	_this call NWG_AI_SER_SetMissionPos;
};

//Drop mission pos
//params: none
NWG_fnc_aiDropMissionPos = {
	call NWG_AI_SER_DropMissionPos;
};

//Smoke the crew out of the vehicle
//params: vehicle
NWG_fnc_aiSmokeOut = {
	private _veh = _this;
	if (isNull _veh) exitWith {
		"NWG_fnc_aiSmokeOut: Vehicle is null" call NWG_fnc_logError;
	};
	if (!local _veh) exitWith {
		_veh remoteExec ["NWG_fnc_aiSmokeOut",_veh];
	};

	//You know what, we don't need a server method for that, who knows, maybe we will add HC, maybe multiplayer with opposite side of players
	private _crew = (crew _veh) select {alive _x};
	if ((count _crew) == 0) exitWith {};
	(group (_crew#0)) leaveVehicle _veh;
	{unassignVehicle _x; _x moveOut _veh} forEach _crew;
};