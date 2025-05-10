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
};

//================================================================================================================
//================================================================================================================
//Event handlers
NWG_VEHOWN_OnGetIn = {
	// params ["_unit", "_role", "_vehicle", "_turret"];
	params ["_player","","_vehicle"];

	//Check settings
	if !(NWG_VEHOWN_Settings get "ASSIGN_OWNERSHIP_ON_GETIN") exitWith {};

	//Check if _vehicle is a legit vehicle
	private _i = ["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {_vehicle isKindOf _x};
	if (_i <= 0) exitWith {};//Not a vehicle

	//Try claiming vehicle
	private _ownerName = _vehicle call NWG_VEHOWN_GetVehicleOwnerName;
	private _claimVehicle = switch (true) do {
		case (_ownerName isEqualTo ""): {true};//No one's vehicle
		case (_ownerName isEqualTo (name _player)): {false};//Player's vehicle
		default {((call NWG_fnc_getPlayersAll) findIf {(name _x) isEqualTo _ownerName}) == -1};//Is owner online?
	};
	if (_claimVehicle) then {
		[_vehicle,_player] call NWG_fnc_vownSetOwner;
		_ownerName = name _player;
	};

	//Show message
	if (NWG_VEHOWN_Settings get "SHOW_OWNERSHIP_ON_GETIN") then {
		if (!_claimVehicle && {_vehicle isEqualTo (player getVariable ["NWG_VEHOWN_lastVehicle",objNull])}) exitWith {};//Fix repeating messages
		player setVariable ["NWG_VEHOWN_lastVehicle",_vehicle];

		private _displayName = getText (configOf _vehicle >> "displayName");
		["#VEHOWN_MESSAGE_OWNER#",_displayName,_ownerName] call NWG_fnc_systemChatMe;
	};
};

//================================================================================================================
//================================================================================================================
call _Init;
