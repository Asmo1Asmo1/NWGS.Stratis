/*Other systems->Client AND Client<->Server*/
//Sets the owner of a vehicle
//params:
//_vehicle: Object - The vehicle to set the owner of
//_playerName: String - The name of the player to set as the owner of the vehicle
NWG_fnc_vownSetOwner = {
	params ["_vehicle","_playerName"];
	if (_playerName isEqualType objNull) then {_playerName = name _playerName};

	if (local _vehicle)
		then {[_vehicle,_playerName] call NWG_VEHOWN_SetVehicleOwner}
		else {[_vehicle,_playerName] remoteExec ["NWG_fnc_vownSetOwner",_vehicle]};
};

//Returns if a player is the owner of a vehicle
//params:
//_vehicle: Object - The vehicle to check the owner of
//_player: Object - The player to check if they are the owner of the vehicle
//returns: Boolean - True if the player is the owner of the vehicle, false otherwise
NWG_fnc_vownIsPlayerOwner = {
	// params ["_vehicle","_player"];
	_this call NWG_VEHOWN_IsPlayerOwner;
};

//Returns the list of owned vehicles of a player
//params:
//_player: Object - The player to get the owned vehicles of
NWG_fnc_vownGetOwnedVehicles = {
	// private _player = _this;
	if (isNull _this) exitWith {
		"NWG_fnc_vownGetOwnedVehicles: Player obj is null" call NWG_fnc_logError;
		[]
	};

	_this call NWG_VEHOWN_GetOwnedVehicles;
};

//Returns the list of owned vehicles of a group of players
//params:
//_group: Group - The group to get the owned vehicles of
//returns: Array - The list of owned vehicles
NWG_fnc_vownGetOwnedVehiclesGroup = {
	// private _group = _this;
	if (isNull _this) exitWith {
		"NWG_fnc_vownGetOwnedVehiclesGroup: Group is null" call NWG_fnc_logError;
		[]
	};
	_this call NWG_VEHOWN_GetOwnedVehiclesGroup;
};
