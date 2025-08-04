//================================================================================================================
//================================================================================================================
//Defines
/*ownership enum*/
#define OWNERSHIP_VACANT 0
#define OWNERSHIP_PLAYER 1
#define OWNERSHIP_PLAYER_GROUP 2
#define OWNERSHIP_OTHER_GROUP 3

//================================================================================================================
//================================================================================================================
//Settings
NWG_VEHOWN_Settings = createHashMapFromArray [
	["ASSIGN_OWNERSHIP_ON_GETIN",true],//Assign ownership on 'GetIn' if not already owned
	["SHOW_OWNERSHIP_ON_GETIN",true],//Show system chat message when getting in the vehicle
	["KICK_ON_GETIN_OTHER_GROUP",true],//Kick player from vehicle if they are in another group from actual owner

	/*Kick additional functions*/
	//Additional check predicate to run before kicking when all other checks passed (set to {true} to always kick)
	//params ["_player","_vehicle"]
	["FUNC_KICK_ADDITIONAL_CHECK",{
		params ["_player"];
		_player call NWG_fnc_mmIsPlayerOnBase
	}],
	//Additional code to run after kicking (set to {} to do nothing)
	//params ["_player","_owner","_vehicle"]
	["FUNC_KICK_ADDITIONAL_CODE",{
		params ["_player","_owner","_vehicle"];
		private _npcName = "#NPC_MECH_NAME#" call NWG_fnc_localize;
		private _message = selectRandom [
			"#VEHOWN_MESSAGE_KICK_01#",
			"#VEHOWN_MESSAGE_KICK_02#",
			"#VEHOWN_MESSAGE_KICK_03#"
		];
		_message = _message call NWG_fnc_localize;
		_message = format [_message,(groupId (group _owner))];
		[_npcName,_message] call BIS_fnc_showSubtitle;
	}],

	/*Localization*/
	["LOC_ON_GETIN_MESSAGE_TEMPLATE","#VEHOWN_MESSAGE_OWNER#"],

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
	// params ["_unit","_role","_vehicle","_turret"];
	private _vehicle = _this#2;

	//Validate
	if (!alive _vehicle) exitWith {};//Not alive
	private _i = ["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {_vehicle isKindOf _x};
	if (_i <= 0) exitWith {};//Not a valid vehicle

	//Get ownership info
	(_vehicle call NWG_VEHOWN_GetVehicleOwnership) params ["_ownership","_owner"];

	//Try claiming the vehicle
	private _isClaimed = false;
	if (NWG_VEHOWN_Settings get "ASSIGN_OWNERSHIP_ON_GETIN" && {_ownership == OWNERSHIP_VACANT}) then {
		[_vehicle,player] call NWG_fnc_vownSetOwner;
		_ownership = OWNERSHIP_PLAYER;
		_owner = player;
		_isClaimed = true;
	};

	//Show message
	if (NWG_VEHOWN_Settings get "SHOW_OWNERSHIP_ON_GETIN" && {_ownership != OWNERSHIP_VACANT}) then {
		private _show = _isClaimed || {_vehicle isNotEqualTo (player getVariable ["NWG_VEHOWN_lastVehicle",objNull])};//Show only when claimed or jumping into a new vehicle
		player setVariable ["NWG_VEHOWN_lastVehicle",_vehicle];
		if !(_show) exitWith {};

		private _template = NWG_VEHOWN_Settings get "LOC_ON_GETIN_MESSAGE_TEMPLATE";
		private _displayName = getText (configOf _vehicle >> "displayName");
		[_template,_displayName,(name _owner)] call NWG_fnc_systemChatMe;
	};

	//Kick player from vehicle if they are in another group from actual owner
	if (NWG_VEHOWN_Settings get "KICK_ON_GETIN_OTHER_GROUP" && {_ownership == OWNERSHIP_OTHER_GROUP}) then {
		//Run additional check
		private _additionalCheck = NWG_VEHOWN_Settings get "FUNC_KICK_ADDITIONAL_CHECK";
		if !([player,_vehicle] call _additionalCheck) exitWith {};

		//Kick player out
		player moveOut _vehicle;

		//Run additional code
		private _additionalCode = NWG_VEHOWN_Settings get "FUNC_KICK_ADDITIONAL_CODE";
		[player,_owner,_vehicle] call _additionalCode;
	};
};

//================================================================================================================
//================================================================================================================
//Get current ownership
NWG_VEHOWN_GetVehicleOwnership = {
	private _vehicle = _this;
	private _ownerName = _vehicle call NWG_VEHOWN_GetVehicleOwnerName;

	//Check if vehicle is vacant
	if (_ownerName isEqualTo "") exitWith {[OWNERSHIP_VACANT,objNull]};

	//Check if player is the current owner
	if (_ownerName isEqualTo (name player)) exitWith {[OWNERSHIP_PLAYER,player]};

	//Try to find owner by their name
	private _allPlayers = call NWG_fnc_getPlayersAll;
	private _i = _allPlayers findIf {(name _x) isEqualTo _ownerName};
	if (_i == -1) exitWith {[OWNERSHIP_VACANT,objNull]};//Player is no longer online - vehicle is vacant

	//Check if owner is in player's group
	private _owner = _allPlayers#_i;
	if (_owner in (units (group player))) exitWith {[OWNERSHIP_PLAYER_GROUP,_owner]};

	//Else - owner is in another group
	[OWNERSHIP_OTHER_GROUP,_owner]
};

//================================================================================================================
//================================================================================================================
call _Init;
