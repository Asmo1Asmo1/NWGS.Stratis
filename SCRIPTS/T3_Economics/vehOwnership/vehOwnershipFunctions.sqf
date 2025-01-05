/*Other systems->Client AND Client<->Server*/
//Pairs player and vehicle as 'owner-owned'
//params:
//_veh: Object - The vehicle to pair with the player
//_player: Object - The player to pair with the vehicle
NWG_fnc_vownPairVehAndPlayer = {
	params ["_veh","_player"];

	//Use functions because they take care of locality
	[_veh,_player] call NWG_fnc_vownSetOwner;
	[_player,_veh] call NWG_fnc_vownAddOwnedVehicle;
};

//Sets the owner of a vehicle
//params:
//_veh: Object - The vehicle to set the owner of
//_player: Object - The player to set as the owner of the vehicle
NWG_fnc_vownSetOwner = {
	params ["_veh","_player"];
	if (isNull _veh || !alive _veh) exitWith {
		"NWG_fnc_vownSetOwner: Vehicle is null or dead" call NWG_fnc_logError;
	};
	if (isNull _player || !alive _player) exitWith {
		"NWG_fnc_vownSetOwner: Player is null or dead" call NWG_fnc_logError;
	};

	if (local _veh)
		then {_this call NWG_VEHOWN_SetVehicleOwner}
		else {_this remoteExec ["NWG_fnc_vownSetOwner",_veh]};//Call where the vehicle is local
};

//Sets list of owned vehicles of a player
//params:
//_player: Object - The player to set the owned vehicles of
//_ownedVehicles: Array - The list of vehicles to set as owned by the player
NWG_fnc_vownSetOwnedVehicles = {
	params ["_player","_ownedVehicles"];
	if (isNull _player || !alive _player) exitWith {
		"NWG_fnc_vownSetOwnedVehicles: Player is null or dead" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_VEHOWN_SetOwnedVehicles}
		else {_this remoteExec ["NWG_fnc_vownSetOwnedVehicles",_player]};//Call where the player is local
};

//Adds a vehicle to the owned vehicles of a player
//params:
//_player: Object - The player to add the vehicle to
//_veh: Object - The vehicle to add to the player's owned vehicles
NWG_fnc_vownAddOwnedVehicle = {
	params ["_player","_veh"];
	if (isNull _player || !alive _player) exitWith {
		"NWG_fnc_vownAddOwnedVehicle: Player is null or dead" call NWG_fnc_logError;
	};
	if (isNull _veh || !alive _veh) exitWith {
		"NWG_fnc_vownAddOwnedVehicle: Vehicle is null or dead" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_VEHOWN_AddOwnedVehicle}
		else {_this remoteExec ["NWG_fnc_vownAddOwnedVehicle",_player]};//Call where the player is local
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
