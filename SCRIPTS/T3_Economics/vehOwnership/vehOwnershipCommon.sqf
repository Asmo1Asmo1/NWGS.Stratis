//================================================================================================================
//================================================================================================================
//Assign ownership
NWG_VEHOWN_SetVehicleOwner = {
	params ["_veh","_player"];
	_veh setVariable ["NWG_VEHOWN_Owner",_player,true];
};

NWG_VEHOWN_SetOwnedVehicles = {
	params ["_player","_ownedVehicles"];
	_ownedVehicles = _ownedVehicles select {!isNil "_x" && {!isNull _x && {alive _x}}};//Filter dead|sold vehicles
	_ownedVehicles = _ownedVehicles arrayIntersect _ownedVehicles;//Remove duplicates
	_player setVariable ["NWG_VEHOWN_OwnedVehicles",_ownedVehicles,true];
};

NWG_VEHOWN_AddOwnedVehicle = {
	params ["_player","_veh"];
	private _ownedVehicles = _player getVariable ["NWG_VEHOWN_OwnedVehicles",[]];
	_ownedVehicles pushBack _veh;
	[_player,_ownedVehicles] call NWG_VEHOWN_SetOwnedVehicles;
};

//================================================================================================================
//================================================================================================================
//Get ownership
NWG_VEHOWN_GetVehicleOwner = {
	// private _veh = _this;
	_this getVariable ["NWG_VEHOWN_Owner",objNull];
};

NWG_VEHOWN_GetOwnedVehicles = {
	//private _player = _this;
	private _ownedVehicles = _this getVariable ["NWG_VEHOWN_OwnedVehicles",[]];
	private _countBefore = count _ownedVehicles;
	if (_countBefore == 0) exitWith {_ownedVehicles};//<= Exit if no vehicles owned

	_ownedVehicles = _ownedVehicles select {!isNil "_x" && {!isNull _x && {alive _x}}};//Filter dead|sold vehicles
	_ownedVehicles = _ownedVehicles arrayIntersect _ownedVehicles;//Remove duplicates
	if ((count _ownedVehicles) != _countBefore) then {
		[_this,_ownedVehicles] call NWG_fnc_vownSetOwnedVehicles;//Update the list
	};

	_ownedVehicles
};