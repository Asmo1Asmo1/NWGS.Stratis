/*
	Annotation:
		Adds action to owned vehicles spawned from garage to return them to garage from anywhere.
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_GRG_RET_Settings = createHashMapFromArray [
	/*Price*/
	["PRICE",2500],

	/*Action*/
	["ASSIGN_ACTION",true],
	["ACTION_TITLE","#GRG_RETURN_TO_GARAGE_ACTION_TITLE#"],
	["ACTION_PRIORITY",0],
	["ACTION_SHOW_WINDOW",true],

	/*Messages*/
	["MSG_FAILED_TO_RETURN","#GRG_MSG_FAILED_TO_RETURN#"],
	["MSG_GARAGE_FULL","#GRG_MSG_GARAGE_FULL#"],
	["MSG_NO_MONEY","#GRG_MSG_NO_MONEY#"],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	waitUntil {sleep 0.1; !isNil "NWG_WLT_MoneyToString"};//Fix compilation timing issue

	player addEventHandler ["Respawn",{call NWG_GRG_RET_AssignAction}];
	call NWG_GRG_RET_AssignAction;
};

//================================================================================================================
//================================================================================================================
//Assign action
NWG_GRG_RET_AssignAction = {
	if !(NWG_GRG_RET_Settings get "ASSIGN_ACTION") exitWith {};//Disabled
	private _title = [(NWG_GRG_RET_Settings get "ACTION_TITLE"),((NWG_GRG_RET_Settings get "PRICE") call NWG_fnc_wltFormatMoney)];
	private _priority = NWG_GRG_RET_Settings get "ACTION_PRIORITY";
	private _showWindow = NWG_GRG_RET_Settings get "ACTION_SHOW_WINDOW";

	player addAction [
		(_title call NWG_fnc_translateMessage),// title
		{call NWG_GRG_RET_Action},// script
		nil,        // arguments
		_priority,  // priority
		_showWindow,      // showWindow
		true,       // hideOnUse
		"",         // shortcut
		"call NWG_GRG_RET_ActionCondition",// condition
		-1,         // radius
		false       // unconscious
	];
};

NWG_GRG_RET_ActionCondition = {
	if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};
	private _veh = call NWG_fnc_radarGetVehInFront;
	if !([_veh,player] call NWG_fnc_vownIsPlayerOwner) exitWith {false};
	if !(_veh call NWG_fnc_grgIsSpawnedFromGarage) exitWith {false};
	true
};

//================================================================================================================
//================================================================================================================
//Action
NWG_GRG_RET_Action = {
	//Check condition again
	if !(call NWG_GRG_RET_ActionCondition) exitWith {};

	//Get target vehicle
	private _veh = call NWG_fnc_radarGetVehInFront;
	if (isNil "_veh" || {!alive _veh}) exitWith {
		(NWG_GRG_RET_Settings get "MSG_FAILED_TO_RETURN") call NWG_fnc_systemChatMe;
	};

	//Check if garage is full
	private _garageArray = player call NWG_GRG_GetGarageArray;
	if ((count _garageArray) >= (NWG_GRG_CLI_Settings get "MAX_CAPACITY")) exitWith { /*Here we use Client Side settings*/
		(NWG_GRG_RET_Settings get "MSG_GARAGE_FULL") call NWG_fnc_systemChatMe;
	};

	//Check if player has enough money
	private _price = NWG_GRG_RET_Settings get "PRICE";
	if ((player call NWG_fnc_wltGetPlayerMoney) < _price) exitWith {
		(NWG_GRG_RET_Settings get "MSG_NO_MONEY") call NWG_fnc_systemChatMe;
	};

	//Subtract price from player money
	[player,-_price] call NWG_fnc_wltAddPlayerMoney;

	//Prevent double action
	_veh setVariable ["NWG_GRG_SpawnedFromGarage",false,true];

	//Add vehicle back to garage array
	_garageArray pushBack (_veh call NWG_GRG_VehicleToGarageArray);
	[player,_garageArray] call NWG_GRG_SetGarageArray;

	//Fly up and delete vehicle
	_veh remoteExec ["NWG_GRG_RET_ImitateFlyToSky",2];
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;