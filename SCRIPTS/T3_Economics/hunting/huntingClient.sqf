//================================================================================================================
//================================================================================================================
//Settings
NWG_HUNT_Settings = createHashMapFromArray [
	/*Action settings*/
	["ACTION_TITLE","#A_HUNT_TITLE#"],
	["ACTION_ICON","a3\ui_f\data\igui\cfg\actions\obsolete\ui_action_manualfire_ca.paa"],
	["ACTION_PRIORITY",20],
	["ACTION_DURATION",3],
	["ACTION_AUTOSHOW",true],
	["ACTION_ANIMATION","Acts_Pointing_Down"],
	["ACTION_ANIMATION_NEEDS_RESET",false],

	/*Hunting prices*/
	["PRICE_DEFAULT",100],
	["PRICES",createHashMapFromArray [
		["Rabbit_F",100],
		["Snake_random_F",50],
		["Fin_random_F",-1000],/*Dog*/
		["Alsatian_Random_F",-1000],/*Dog*/
		["Sheep_random_F",300],
		["Goat_random_F",300],
		["Hen_random_F",100]
	]],

	/*Anti-hunting*/
	["FORBIDDEN_ANIMALS",["Fin_random_F","Alsatian_Random_F"]],
	["FORBIDDEN_MESSAGE","#A_HUNT_FORBIDDEN_MESSAGE#"],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	player addEventHandler ["Respawn",{call NWG_HUNT_AssignAction}];
    call NWG_HUNT_AssignAction;
};

//================================================================================================================
//================================================================================================================
//Action assign
NWG_HUNT_AssignAction = {
	[
		player,// Object the action is attached to
		((NWG_HUNT_Settings get "ACTION_TITLE") call NWG_fnc_localize),// Title of the action
		(NWG_HUNT_Settings get "ACTION_ICON"),// Idle icon shown on screen
		(NWG_HUNT_Settings get "ACTION_ICON"),// Progress icon shown on screen
		"call NWG_HUNT_Condition",// Condition for the action to start
		"call NWG_HUNT_Condition",// Condition for the action to progress
		{call NWG_HUNT_OnStarted},// Code executed when action starts
		{},// Code executed on every progress tick
		{call NWG_HUNT_OnCompleted},  // Code executed on completion
		{call NWG_HUNT_OnInterrupted},// Code executed on interrupted
		[],// Arguments passed to the scripts as _this select 3
		(NWG_HUNT_Settings get "ACTION_DURATION"),// Action duration in seconds
		(NWG_HUNT_Settings get "ACTION_PRIORITY"),// Priority
		false,// Remove on completion
		false,// Show in unconscious state
		(NWG_HUNT_Settings get "ACTION_AUTOSHOW")// Auto show on screen
	] call BIS_fnc_holdActionAdd;
};

NWG_HUNT_ResetAnimation = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if ((vehicle player) isNotEqualTo player) exitWith {};//Don't do animation reset in vehicles
    player switchMove "";
};

//================================================================================================================
//================================================================================================================
//Action
NWG_HUNT_Condition = {
	if (isNull player || {!alive player}) exitWith {false};//Prevent errors
	if (isNull (call NWG_fnc_radarGetAnimalInFront)) exitWith {false};//Don't do if no animal in front
	if (alive (call NWG_fnc_radarGetAnimalInFront)) exitWith {false};//Don't do if animal is alive
	//All checks passed
	true
};
NWG_HUNT_OnStarted = {
	player playMoveNow (NWG_HUNT_Settings get "ACTION_ANIMATION");
};
NWG_HUNT_OnInterrupted = {
	if (isNull player || {!alive player}) exitWith {};//Prevent errors
	if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Game logic will handle this
	if (NWG_HUNT_Settings get "ACTION_ANIMATION_NEEDS_RESET")
		then {call NWG_HUNT_ResetAnimation};
};
NWG_HUNT_OnCompleted = {
	if (NWG_HUNT_Settings get "ACTION_ANIMATION_NEEDS_RESET")
		then {call NWG_HUNT_ResetAnimation};

	private _prey = call NWG_fnc_radarGetAnimalInFront;
	if (isNull _prey) exitWith {};

	private _preyType = typeOf _prey;
	private _price = (NWG_HUNT_Settings get "PRICES") getOrDefault [_preyType,(NWG_HUNT_Settings get "PRICE_DEFAULT")];
	if (_price != 0) then {
		[player,_price] call NWG_fnc_wltAddPlayerMoney;
	};

	if (_preyType in (NWG_HUNT_Settings get "FORBIDDEN_ANIMALS")) then {
		["#A_HUNT_FORBIDDEN_MESSAGE#",(name player)] call NWG_fnc_sideChatAll;
	};

	deleteVehicle _prey;
};


//================================================================================================================
//================================================================================================================
call _Init;