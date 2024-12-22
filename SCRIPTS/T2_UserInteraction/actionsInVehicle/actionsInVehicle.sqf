/*
	Actions to be called when entering a vehicle
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_AV_Settings = createHashMapFromArray [
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
	if !(call NWG_AV_GeneralCondition) exitWith {};
	private _actionIDs = [];

	//TODO: Implement

	player setVariable ["NWG_AV_actionIDs", _actionIDs];
};

NWG_AV_OnGetOut = {
	// params ["_unit","_role","_vehicle","_turret","_isEject"];
	private _actionIDs = player getVariable ["NWG_AV_actionIDs", []];
	{removeAction _x} forEach _actionIDs;
	player setVariable ["NWG_AV_actionIDs", []];
};

//================================================================================================================
//================================================================================================================
call _Init;
