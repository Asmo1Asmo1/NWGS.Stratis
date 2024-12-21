//================================================================================================================
//================================================================================================================
//Settings
NWG_VEHOWN_Settings = createHashMapFromArray [
	["ASSIGN_OWNERSHIP_ON_GETIN",true],//Assign ownership on 'GetIn' if not already owned
	["SHOW_OWNERSHIP_ON_GETIN",true],//Show system chat message when getting in the vehicle

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	player addEventHandler ["GetInMan", {_this call NWG_VEHOWN_OnGetIn}];
	player addEventHandler ["Respawn",{_this call NWG_VEHOWN_OnRespawn}];
};

//================================================================================================================
//================================================================================================================
//Event handlers
NWG_VEHOWN_OnGetIn = {
	// params ["_unit", "_role", "_vehicle", "_turret"];
	params ["_player","","_veh"];

	//Check settings
	if !(NWG_VEHOWN_Settings get "ASSIGN_OWNERSHIP_ON_GETIN") exitWith {};

	//Check if _veh is a legit vehicle
	private _i = ["Car","Tank","Helicopter","Plane","Ship"] findIf {_veh isKindOf _x};
	if (_i == -1) exitWith {};//Not a vehicle
	if (_veh isKindOf "ParachuteBase") exitWith {};//Ignore parachutes

	//Try claiming vehicle
	private _owner = _veh call NWG_VEHOWN_GetVehicleOwner;
	if (isNull _owner || {!alive _owner}) then {
		[_veh,_player] call NWG_fnc_vownPairVehAndPlayer;
		_owner = _player;
	};

	//Show message
	if (NWG_VEHOWN_Settings get "SHOW_OWNERSHIP_ON_GETIN") then {
		private _displayName = getText (configOf _veh >> "displayName");
		private _ownerName = name _owner;
		["#VEHOWN_MESSAGE_OWNER#",_displayName,_ownerName] call NWG_fnc_systemChatMe;
	};
};

NWG_VEHOWN_OnRespawn = {
	params ["_player","_corpse"];
	private _ownedVehicles = _corpse call NWG_fnc_vownGetOwnedVehicles;
	{[_x,_player] call NWG_fnc_vownSetOwner} forEach _ownedVehicles;//Re-assign ownership
	[_player,_ownedVehicles] call NWG_fnc_vownSetOwnedVehicles;//Move list to new player instance
};

//================================================================================================================
//================================================================================================================
call _Init;
