/*Other systems->Client AND Client<->Server*/
//Sets the owner of a vehicle
//params:
//_vehicle: Object - The vehicle to set the owner of
//_player: Object - The player to set as the owner of the vehicle
NWG_fnc_vownSetOwner = {
	params ["_vehicle","_player"];
	if (isNull _vehicle || !alive _vehicle) exitWith {
		"NWG_fnc_vownSetOwner: Vehicle is null or dead" call NWG_fnc_logError;
	};
	if (isNull _player || !alive _player) exitWith {
		"NWG_fnc_vownSetOwner: Player is null or dead" call NWG_fnc_logError;
	};

	if (local _vehicle)
		then {_this call NWG_VEHOWN_SetVehicleOwner}
		else {_this remoteExec ["NWG_fnc_vownSetOwner",_vehicle]};//Call where the vehicle is local
};

//Gets the owner of a vehicle
//params:
//_vehicle: Object - The vehicle to get the owner of
//returns: Object - The owner of the vehicle
NWG_fnc_vownGetOwner = {
	// private _vehicle = _this;
	_this call NWG_VEHOWN_GetVehicleOwner;
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
