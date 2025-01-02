#include "..\..\globalDefines.h"
/*
	Actions to be called via mouse wheel when player has certain items in their inventory
*/

//================================================================================================================
//================================================================================================================
//Defines
#define SAVEID_CAMP "ItemAction_CampDeploy"
#define SAVEID_SMOKE "ItemAction_SmokeOut"

//================================================================================================================
//================================================================================================================
//Settings
NWG_AI_Settings = createHashMapFromArray [
	["CAMP_ITEM","Sleeping_bag_folded_01"],
	["CAMP_TITLE","#AI_CAMP_TITLE#"],
	["CAMP_ICON","a3\ui_f_oldman\data\igui\cfg\holdactions\holdaction_sleep2_ca.paa"],
	["CAMP_PRIORITY",0],
	["CAMP_DURATION",8],
	["CAMP_ANIMATION","Acts_carFixingWheel"],
	["CAMP_PLAYER_BASE_GLOBAL_NAME","PlayerBase"],
	["CAMP_PLAYER_BASE_RADIUS",100],

	["SMOKE_ITEMS_INV",["SmokeShellBlue","SmokeShellGreen","SmokeShellOrange","SmokeShellPurple","SmokeShellRed","SmokeShellYellow","SmokeShell","MiniGrenade","HandGrenade"]],
	["SMOKE_ITEMS_OBJ",["SmokeShellBlue","SmokeShellGreen","SmokeShellOrange","SmokeShellPurple","SmokeShellRed","SmokeShellYellow","SmokeShell","Grenade","Grenade"]],
	["SMOKE_TITLE","#AI_SMOKE_TITLE#"],
	["SMOKE_ICON","a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"],
	["SMOKE_PRIORITY",0],
	["SMOKE_DURATION",5],
	["SMOKE_ANIMATION","Act_Alien_Gesture"],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Global fields
NWG_AI_MissionPos = nil;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	[EVENT_ON_LOADOUT_CHANGED,{_this call NWG_AI_ReloadActions}] call NWG_fnc_subscribeToClientEvent;
};

//================================================================================================================
//================================================================================================================
//Reload actions
NWG_AI_ReloadActions = {
	// params ["_loadOut","_flattenLoadOut"];
	params ["","_flattenLoadOut"];
	private ["_hasItem","_isActionAssigned"];

	//Camp deploy
	_hasItem = (NWG_AI_Settings get "CAMP_ITEM") in _flattenLoadOut;
	_isActionAssigned = SAVEID_CAMP call NWG_AI_IsActionAssigned;
	switch (true) do {
		case (_hasItem && !_isActionAssigned): {
			//Assign action
			[
				/*_saveID:*/SAVEID_CAMP,
				/*_title:*/(NWG_AI_Settings get "CAMP_TITLE"),
				/*_icon:*/(NWG_AI_Settings get "CAMP_ICON"),
				/*_priority:*/(NWG_AI_Settings get "CAMP_PRIORITY"),
				/*_duration:*/(NWG_AI_Settings get "CAMP_DURATION"),
				/*_condition:*/"call NWG_AI_CampDeploy_Condition",
				/*_onStarted:*/{call NWG_AI_CampDeploy_OnStarted},
				/*_onInterrupted:*/{call NWG_AI_CampDeploy_OnInterrupted},
				/*_onCompleted:*/{call NWG_AI_CampDeploy_OnCompleted}
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_CAMP call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};

	//Smoke out
	_hasItem = ((NWG_AI_Settings get "SMOKE_ITEMS_INV") findIf {_x in _flattenLoadOut}) != -1;
	_isActionAssigned = SAVEID_SMOKE call NWG_AI_IsActionAssigned;
	switch (true) do {
		case (_hasItem && !_isActionAssigned): {
			//Assign action
			[
				/*_saveID:*/SAVEID_SMOKE,
				/*_title:*/(NWG_AI_Settings get "SMOKE_TITLE"),
				/*_icon:*/(NWG_AI_Settings get "SMOKE_ICON"),
				/*_priority:*/(NWG_AI_Settings get "SMOKE_PRIORITY"),
				/*_duration:*/(NWG_AI_Settings get "SMOKE_DURATION"),
				/*_condition:*/"call NWG_AI_SmokeOut_Condition",
				/*_onStarted:*/{call NWG_AI_SmokeOut_OnStarted},
				/*_onInterrupted:*/{call NWG_AI_SmokeOut_OnInterrupted},
				/*_onCompleted:*/{call NWG_AI_SmokeOut_OnCompleted}
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_SMOKE call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};
};

NWG_AI_IsActionAssigned = {
	// private _saveID = _this;
	private _actionID = player getVariable [_this,-1];
	_actionID != -1;
};

NWG_AI_AssignAction = {
	params ["_saveID","_title","_icon","_priority","_duration","_condition","_onStarted","_onInterrupted","_onCompleted"];
	private _actionID = [
		player,                         // Object the action is attached to
		(_title call NWG_fnc_localize), // Title of the action
		_icon,                          // Idle icon shown on screen
		_icon,                          // Progress icon shown on screen
		_condition,                     // Condition for the action to start
		_condition,                     // Condition for the action to progress
		_onStarted,                     // Code executed when action starts
		{},                             // Code executed on every progress tick
		_onCompleted,                   // Code executed on completion
		_onInterrupted,                 // Code executed on interrupted
		[],                             // Arguments passed to the scripts as _this select 3
		_duration,                      // Action duration in seconds
		_priority,                      // Priority
		false,                          // Remove on completion
		false,                          // Show in unconscious state
		false                           // Auto show on screen
	] call BIS_fnc_holdActionAdd;
	player setVariable [_saveID,_actionID];
};

NWG_AI_RemoveAction = {
	// private _saveID = _this;
	private _actionID = player getVariable [_this,-1];
	if (_actionID == -1) exitWith {};
	player removeAction _actionID;
	player setVariable [_this,-1];
};

NWG_AI_ResetAnimation = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if ((vehicle player) isNotEqualTo player) exitWith {};//Don't do animation reset in vehicles
    player switchMove "";
};

//================================================================================================================
//================================================================================================================
//Camp deploy
NWG_AI_CampDeploy_Condition = {
	if (isNull player || {!alive player}) exitWith {false};//Prevent errors
    if (!isNull (objectParent player)) exitWith {false};//Don't do in vehicles
	if (((getPos player)#2) > 1) exitWith {false};//Don't do if player is not on the ground
	if (((getPosASL player)#2) < 0) exitWith {false};//Don't do underwater either
	private _playerBase = missionNamespace getVariable (NWG_AI_Settings get "CAMP_PLAYER_BASE_GLOBAL_NAME");
	if (!isNil "_playerBase" && {!isNull _playerBase && {(player distance _playerBase) < (NWG_AI_Settings get "CAMP_PLAYER_BASE_RADIUS")}}) exitWith {false};//Don't do on player base
	if (!isNil "NWG_AI_MissionPos" && {NWG_AI_MissionPos isNotEqualTo false && {(player distance (NWG_AI_MissionPos#0)) < (NWG_AI_MissionPos#1)}}) exitWith {false};//Don't do in mission area
	//All checks passed
	true
};
NWG_AI_CampDeploy_OnStarted = {
    player playMoveNow (NWG_AI_Settings get "CAMP_ANIMATION");
};
NWG_AI_CampDeploy_OnInterrupted = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Game logic will handle this
    call NWG_AI_ResetAnimation;
};
NWG_AI_CampDeploy_OnCompleted = {
    call NWG_AI_ResetAnimation;
	if !((NWG_AI_Settings get "CAMP_ITEM") call NWG_fnc_invRemoveItem)
		exitWith {"NWG_AI_CampDeploy_OnCompleted: Failed to remove item" call NWG_fnc_logError};
    player remoteExec ["NWG_fnc_aiRequestCamp",2];
};

//================================================================================================================
//================================================================================================================
//Smoke out
NWG_AI_SmokeOut_Condition = {
	if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};//Also checks if player is valid and if it is in vehicle
	private _veh = call NWG_fnc_radarGetVehInFront;
	if ((count (crew _veh)) == 0) exitWith {false};//Don't do on empty vehicles
	if ((side _veh) isEqualTo (side (group player))) exitWith {false};//Don't do on friendly vehicles
	if (unitIsUAV _veh) exitWith {false};//Don't do on UAVs
	//All checks passed
	true
};
NWG_AI_SmokeOut_OnStarted = {
    player playMoveNow (NWG_AI_Settings get "SMOKE_ANIMATION");
};
NWG_AI_SmokeOut_OnInterrupted = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Game logic will handle this
    call NWG_AI_ResetAnimation;
};
NWG_AI_SmokeOut_OnCompleted = {
    // call NWG_AI_ResetAnimation;//not needed, the animation is quite short

	//Get targeted vehicle
	private _veh = call NWG_fnc_radarGetVehInFront;
	if (isNull _veh) exitWith {"NWG_AI_SmokeOut_OnCompleted: Vehicle is null" call NWG_fnc_logError};

	//Get object type to be created
	private _i = (NWG_AI_Settings get "SMOKE_ITEMS_INV") findIf {_x call NWG_fnc_invHasItem};
	if (_i == -1) exitWith {"NWG_AI_SmokeOut_OnCompleted: No smoke item found in inventory" call NWG_fnc_logError};
	private _smokeInvType = (NWG_AI_Settings get "SMOKE_ITEMS_INV") select _i;
	private _smokeObjType = (NWG_AI_Settings get "SMOKE_ITEMS_OBJ") param [_i,""];
	if (_smokeObjType isEqualTo "") exitWith {
		(format ["NWG_AI_SmokeOut_OnCompleted: No obj type for inv type '%1'",((NWG_AI_Settings get "SMOKE_ITEMS_INV")#_i)]) call NWG_fnc_logError;
	};

	//Remove item
	_smokeInvType call NWG_fnc_invRemoveItem;

	//Create object
	private _smokeObj = createVehicle [_smokeObjType,_veh,[],0,"CAN_COLLIDE"];
	if (isNull _smokeObj) exitWith {format ["NWG_AI_SmokeOut_OnCompleted: Failed to create object for type '%1'",_smokeObjType] call NWG_fnc_logError};
	_smokeObj setPosASL (getPosASL _veh);

	//Wait for detonation
	[_smokeObj,_smokeObjType,_veh] spawn {
		params ["_smokeObj","_smokeObjType","_veh"];
		private _lastPos = getPosASL _smokeObj;
		private _timeout = time + ((round (random 7)) + 5);
		waitUntil {
			sleep 0.25;
			if (!alive _smokeObj) exitWith {true};
			if (time > _timeout) exitWith {true};
			_lastPos = getPosASL _smokeObj;
			false//go to next iteration
		};
		if (!alive _veh) exitWith {};//Vehicle have been destroyed
		if ((_lastPos distance (getPosASL _veh)) > 5) exitWith {};//Vehicle moved too far
		if ((count (crew _veh)) == 0) exitWith {};//Vehicle is empty now
		_veh remoteExec ["NWG_fnc_aiSmokeOut",_veh];
	};
};

//================================================================================================================
//================================================================================================================
call _Init;