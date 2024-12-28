/*
	Actions to be called when entering a vehicle
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_AV_Settings = createHashMapFromArray [
	["JUMP_OUT_ACTION_ASSIGN",true],
	["JUMP_OUT_ACTION_TITLE","#AV_JUMP_OUT_TITLE#"],
	["JUMP_OUT_ACTION_PRIORITY",0],

	["SEAT_SWITCH_ACTION_ASSIGN",true],
	["SEAT_SWITCH_ACTION_NEXT_TITLE","#AV_SEAT_SWITCH_NEXT_TITLE#"],
	["SEAT_SWITCH_ACTION_PREV_TITLE","#AV_SEAT_SWITCH_PREV_TITLE#"],
	["SEAT_SWITCH_ACTION_PRIORITY",0],
	["SEAT_SWITCH_SEATS_ORDER",["driver","gunner","commander","turret","cargo"]],

	["ALL_WHEEL_ACTION_ASSIGN",true],
	["ALL_WHEEL_ACTION_SIGNATURE_REQUIRED",true],//If true, only signed vehicles will get this action
	["ALL_WHEEL_ACTION_TITLE_ON","#AV_ALL_WHEEL_TITLE_ON#"],
	["ALL_WHEEL_ACTION_TITLE_OFF","#AV_ALL_WHEEL_TITLE_OFF#"],
	["ALL_WHEEL_ACTION_PRIORITY",0],
	["ALL_WHEEL_SUPPORTED_VEH_TYPES",["Car","Tank","Wheeled_APC_F"]],
	["ALL_WHEEL_MIN_MASS",1000],
	["ALL_WHEEL_MASS_MULTIPLIER",0.25],
	["ALL_WHEEL_MASS_CENTER_ADD",-1],
	["ALL_WHEEL_FUEL_MULTIPLIER",4],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	player addEventHandler ["GetInMan", {_this call NWG_AV_OnGetIn}];
	player addEventHandler ["GetOutMan",{_this call NWG_AV_OnGetOut}];
};

//================================================================================================================
//================================================================================================================
//General condition (condition for actions to be assigned or called via keybinding)
NWG_AV_GeneralCondition = {
	if (isNull player || {!alive player || {isNull (objectParent player)}}) exitWith {false};//Check if player is not alive or not in vehicle
	if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {false};//Check if player is wounded
	if ((["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {(objectParent player) isKindOf _x}) <= 0) exitWith {false};//Check if player's vehicle is valid
	//All checks passed
	true
};

//================================================================================================================
//================================================================================================================
//Actions assign/unassign
NWG_AV_OnGetIn = {
	// params ["_unit","_role","_vehicle","_turret"];
	private _vehicle = _this select 2;

	//Global check
	if !(call NWG_AV_GeneralCondition) exitWith {};

	//Prepare assignment
	private _actionIDs = [];
	private _assignAction = {
		params ["_title","_code","_priority","_condition"];
		private _actionID = player addAction [
			(_title call NWG_fnc_localize),// title
			_code,      // script
			nil,        // arguments
			_priority,  // priority
			false,      // showWindow
			true,       // hideOnUse
			"",         // shortcut
			_condition, // condition
			-1,         // radius
			false       // unconscious
		];
		_actionIDs pushBack _actionID;
	};

	//Assign actions
	private ["_title","_code","_priority","_condition"];

	/*Jump Out*/
	if (NWG_AV_Settings get "JUMP_OUT_ACTION_ASSIGN" && {_vehicle isKindOf "Air"}) then {
		_title = NWG_AV_Settings get "JUMP_OUT_ACTION_TITLE";
		_code = {call NWG_AV_JumpOut_Action};
		_priority = NWG_AV_Settings get "JUMP_OUT_ACTION_PRIORITY";
		_condition = "true";
		[_title,_code,_priority,_condition] call _assignAction;
	};

	/*Seat switch*/
	if (NWG_AV_Settings get "SEAT_SWITCH_ACTION_ASSIGN" && {(count (fullCrew [_vehicle,"",true])) > 1}) then {
		_title = NWG_AV_Settings get "SEAT_SWITCH_ACTION_NEXT_TITLE";
		_code = {true call NWG_AV_SeatSwitch_Action};
		_priority = NWG_AV_Settings get "SEAT_SWITCH_ACTION_PRIORITY";
		_condition = "true";
		[_title,_code,_priority,_condition] call _assignAction;

		_title = NWG_AV_Settings get "SEAT_SWITCH_ACTION_PREV_TITLE";
		_code = {false call NWG_AV_SeatSwitch_Action};
		[_title,_code,_priority,_condition] call _assignAction;
	};

	/*All wheel*/
	if (NWG_AV_Settings get "ALL_WHEEL_ACTION_ASSIGN" && {call NWG_AV_AllWheel_ConditionAssign}) then {
		_title = NWG_AV_Settings get "ALL_WHEEL_ACTION_TITLE_ON";
		_code = {call NWG_AV_AllWheel_ToggleAction};
		_priority = NWG_AV_Settings get "ALL_WHEEL_ACTION_PRIORITY";
		_condition = "false call NWG_AV_AllWheel_ConditionToggle";
		[_title,_code,_priority,_condition] call _assignAction;

		_title = NWG_AV_Settings get "ALL_WHEEL_ACTION_TITLE_OFF";
		_condition = "true call NWG_AV_AllWheel_ConditionToggle";
		[_title,_code,_priority,_condition] call _assignAction;
	};

	//Save action IDs for later removal
	player setVariable ["NWG_AV_actionIDs", _actionIDs];
};

NWG_AV_OnGetOut = {
	// params ["_unit","_role","_vehicle","_turret","_isEject"];
	private _actionIDs = player getVariable ["NWG_AV_actionIDs", []];
	{player removeAction _x} forEach _actionIDs;
	player setVariable ["NWG_AV_actionIDs", []];
};

//================================================================================================================
//================================================================================================================
//Jump out
NWG_AV_JumpOut_Action = {
	player action ["getOut",(vehicle player)];
};

//================================================================================================================
//================================================================================================================
//Seat switch
#define FULL_CREW_INCLUDE_EMPTY true
#define FULL_CREW_UNIT 0
#define FULL_CREW_ROLE 1
#define FULL_CREW_CARGO_INDEX 2
#define FULL_CREW_TURRET_PATH 3

NWG_AV_SeatSwitch_Action = {
	private _toNext = _this;

	//Get values
	private _vehicle = vehicle player;
	if (!alive _vehicle || {_vehicle isEqualTo player}) exitWith {};
	private _fullCrew = fullCrew [_vehicle,"",FULL_CREW_INCLUDE_EMPTY];
	if ((count _fullCrew) <= 1) exitWith {};

	//Sort crew by predefined order
	//(Fix Arma's fullCrew complete mess of an order driver->cargo->turret->gunner->commander, like wtf)
	private _order = NWG_AV_Settings get "SEAT_SWITCH_SEATS_ORDER";
	private _i = -1;//Fix inconsistent sorting
	_fullCrew = _fullCrew apply {_i = _i + 1; [(_order find (_x#FULL_CREW_ROLE)),_i,_x]};
	_fullCrew sort true;
	_fullCrew = _fullCrew apply {_x#2};

	//Find player's index
	private _playerIndex = _fullCrew findIf {(_x#FULL_CREW_UNIT) isEqualTo player};
	if (_playerIndex == -1) exitWith {};

	//Reorganize and find next available seat
	private _fullCrewPrev = _fullCrew select [0,_playerIndex];
	private _fullCrewNext = _fullCrew select [_playerIndex + 1];
	private _fullCrew = if (_toNext) then {
		//[0,1,PLAYER,3,4,5] => [3,4,5] + [0,1] => [3,4,5,0,1]
		_fullCrewNext + _fullCrewPrev
	} else {
		//[0,1,PLAYER,3,4,5] => [1,0] + [5,4,3] => [1,0,5,4,3]
		reverse _fullCrewPrev;
		reverse _fullCrewNext;
		_fullCrewPrev + _fullCrewNext
	};
	private _nextAvailableSeat = _fullCrew findIf {isNull (_x#FULL_CREW_UNIT)};
	if (_nextAvailableSeat == -1) exitWith {};

	//Place unit into the next available seat
	player moveOut _vehicle;//Mandatory, see: https://community.bistudio.com/wiki/moveInAny
	private _newSeat = _fullCrew select _nextAvailableSeat;
	switch (_newSeat#FULL_CREW_ROLE) do {
		case "driver": {
			player assignAsDriver _vehicle;
			player moveInDriver _vehicle
		};
		case "commander": {
			player assignAsCommander _vehicle;
			player moveInCommander _vehicle
		};
		case "gunner": {
			player assignAsGunner _vehicle;
			player moveInGunner _vehicle
		};
		case "turret": {
			player assignAsTurret [_vehicle,(_newSeat#FULL_CREW_TURRET_PATH)];
			player moveInTurret [_vehicle,(_newSeat#FULL_CREW_TURRET_PATH)]
		};
		case "cargo": {
			player assignAsCargo _vehicle;
			player moveInCargo [_vehicle,(_newSeat#FULL_CREW_CARGO_INDEX)];
		};
	};
};

//================================================================================================================
//================================================================================================================
//All wheel (Mass reduction)
NWG_AV_AllWheel_SignVehicle = {
	// private _vehicle = _this;
	if (isNull _this) exitWith {false};
	_this setVariable ["NWG_AV_AllWheel_Sign",true,true];
	true
};
NWG_AV_AllWheel_IsSigned = {
	// private _vehicle = _this;
	if (isNull _this) exitWith {false};
	_this getVariable ["NWG_AV_AllWheel_Sign",false]
};
NWG_AV_AllWheel_IsSupported = {
	private _vehicle = _this;
	if (!alive _vehicle || {isNull _vehicle}) exitWith {false};

	//Check vehicle type
	private _supportedVehicles = NWG_AV_Settings get "ALL_WHEEL_SUPPORTED_VEH_TYPES";
	if ((_supportedVehicles findIf {_vehicle isKindOf _x}) == -1) exitWith {false};

	//Check vehicle mass
	private _origMass = _vehicle getVariable "NWG_AV_AllWheel_origMass";
	if (isNil "_origMass") then {
		_origMass = getMass _vehicle;
		_vehicle setVariable ["NWG_AV_AllWheel_origMass",_origMass,true];
	};
	private _minMass = NWG_AV_Settings get "ALL_WHEEL_MIN_MASS";
	if (_origMass < _minMass) exitWith {false};

	//All checks passed
	true
};

NWG_AV_AllWheel_ConditionAssign = {
	if (!alive player || {isNull (objectParent player)}) exitWith {false};
	private _vehicle = objectParent player;
	if !(_vehicle call NWG_AV_AllWheel_IsSupported) exitWith {false};
	if (NWG_AV_Settings get "ALL_WHEEL_ACTION_SIGNATURE_REQUIRED" && {!(_vehicle call NWG_AV_AllWheel_IsSigned)}) exitWith {false};
	true
};

NWG_AV_AllWheel_ConditionToggle = {
	// private _expectedOn = _this;
	(driver (objectParent player)) isEqualTo player && {
	local (objectParent player) && {
	((objectParent player) getVariable ["NWG_AV_AllWheel_isOn",false]) == _this}}
};

NWG_AV_AllWheel_ToggleAction = {
	private _vehicle = objectParent player;
	if (isNull _vehicle) exitWith {};
	if !(local _vehicle) exitWith {};

	//Get values
	private _isOn = _vehicle getVariable ["NWG_AV_AllWheel_isOn",false];
	private _origMass = _vehicle getVariable "NWG_AV_AllWheel_origMass";
	if (isNil "_origMass") then {
		_origMass = getMass _vehicle;
		_vehicle setVariable ["NWG_AV_AllWheel_origMass",_origMass,true];
	};
	private _origMassCenter = _vehicle getVariable "NWG_AV_AllWheel_origMassCenter";
	if (isNil "_origMassCenter") then {
		_origMassCenter = (getCenterOfMass _vehicle)#2;
		_vehicle setVariable ["NWG_AV_AllWheel_origMassCenter",_origMassCenter,true];
	};

	//Calculate new values
	private _newMassCenter = getCenterOfMass _vehicle;
	private ["_newMass","_newFuel"];
	if (_isOn) then {
		//Revert to original
		_newMassCenter set [2,_origMassCenter];
		_newMass = _origMass;
		_newFuel = 1;
	} else {
		//Set new values
		_newMassCenter set [2,(_origMassCenter + (NWG_AV_Settings get "ALL_WHEEL_MASS_CENTER_ADD"))];

		private _minMass = NWG_AV_Settings get "ALL_WHEEL_MIN_MASS";
		_newMass = _origMass * (NWG_AV_Settings get "ALL_WHEEL_MASS_MULTIPLIER");
		if (_origMass > _minMass && {_newMass < _minMass})
			then {_newMass = _minMass};

		private _fuelMultBase = NWG_AV_Settings get "ALL_WHEEL_FUEL_MULTIPLIER";
		private _fuelMultByMass = round (_origMass / 10000);
		_newFuel = _fuelMultBase max _fuelMultByMass;
	};

	//Set new values
	_vehicle setMass _newMass;
	_vehicle setCenterOfMass _newMassCenter;
	_vehicle setFuelConsumptionCoef _newFuel;
	_vehicle setVariable ["NWG_AV_AllWheel_isOn",!_isOn,true];
};

//================================================================================================================
//================================================================================================================
call _Init;
