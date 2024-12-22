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
call _Init;
