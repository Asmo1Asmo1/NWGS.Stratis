#include "..\..\globalDefines.h"
/*
	Actions to be called via mouse wheel when player has certain items in their inventory
*/

//================================================================================================================
//================================================================================================================
//Defines
#define SAVEID_CAMP "ItemAction_CampDeploy"
#define SAVEID_SMOK "ItemAction_SmokeOut"
#define SAVEID_REPR "ItemAction_Repair"
#define SAVEID_FLIP "ItemAction_VehFlip"

//================================================================================================================
//================================================================================================================
//Settings
NWG_AI_Settings = createHashMapFromArray [
	["CAMP_ITEM","Sleeping_bag_folded_01"],
	["CAMP_TITLE","#AI_CAMP_TITLE#"],
	["CAMP_ICON","a3\ui_f_oldman\data\igui\cfg\holdactions\holdaction_sleep2_ca.paa"],
	["CAMP_PRIORITY",0],
	["CAMP_DURATION",8],
	["CAMP_AUTOSHOW",false],
	["CAMP_ANIMATION","Acts_carFixingWheel"],
	["CAMP_PLAYER_BASE_GLOBAL_NAME","PlayerBase"],
	["CAMP_PLAYER_BASE_RADIUS",100],

	["SMOKE_ITEMS_INV",["SmokeShellBlue","SmokeShellGreen","SmokeShellOrange","SmokeShellPurple","SmokeShellRed","SmokeShellYellow","SmokeShell","MiniGrenade","HandGrenade"]],
	["SMOKE_ITEMS_OBJ",["SmokeShellBlue","SmokeShellGreen","SmokeShellOrange","SmokeShellPurple","SmokeShellRed","SmokeShellYellow","SmokeShell","Grenade","Grenade"]],
	["SMOKE_TITLE","#AI_SMOKE_TITLE#"],
	["SMOKE_ICON","a3\ui_f_oldman\data\igui\cfg\holdactions\destroy_ca.paa"],
	["SMOKE_PRIORITY",0],
	["SMOKE_DURATION",5],
	["SMOKE_AUTOSHOW",false],
	["SMOKE_ANIMATION","Act_Alien_Gesture"],

	["REPAIR_ITEM","ToolKit"],
    ["REPAIR_TITLE","#AI_REPAIR_TITLE#"],
    ["REPAIR_ICON","a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["REPAIR_PRIORITY",20],
    ["REPAIR_DURATION",12],
	["REPAIR_AUTOSHOW",true],
	["REPAIR_ANIMATION","Acts_carFixingWheel"],
    ["REPAIR_MATRIX",[
        ["hull","body","hitera","glass","light", "" ],/*"" - all parts, must be last as it gives 'true' to any part*/
        [0.50,  0.50,  0.97,    0.97,   0.97,   0.33]
    ]],

    ["UNFLIP_ITEM","ToolKit"],
    ["UNFLIP_TITLE","#AI_UNFLIP_TITLE#"],
    ["UNFLIP_ICON","a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["UNFLIP_PRIORITY",20],
    ["UNFLIP_DURATION",12],
	["UNFLIP_AUTOSHOW",true],

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
				/*_onCompleted:*/{call NWG_AI_CampDeploy_OnCompleted},
				/*_autoShow:*/(NWG_AI_Settings get "CAMP_AUTOSHOW")
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_CAMP call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};

	//Smoke out
	_hasItem = ((NWG_AI_Settings get "SMOKE_ITEMS_INV") findIf {_x in _flattenLoadOut}) != -1;
	_isActionAssigned = SAVEID_SMOK call NWG_AI_IsActionAssigned;
	switch (true) do {
		case (_hasItem && !_isActionAssigned): {
			//Assign action
			[
				/*_saveID:*/SAVEID_SMOK,
				/*_title:*/(NWG_AI_Settings get "SMOKE_TITLE"),
				/*_icon:*/(NWG_AI_Settings get "SMOKE_ICON"),
				/*_priority:*/(NWG_AI_Settings get "SMOKE_PRIORITY"),
				/*_duration:*/(NWG_AI_Settings get "SMOKE_DURATION"),
				/*_condition:*/"call NWG_AI_SmokeOut_Condition",
				/*_onStarted:*/{call NWG_AI_SmokeOut_OnStarted},
				/*_onInterrupted:*/{call NWG_AI_SmokeOut_OnInterrupted},
				/*_onCompleted:*/{call NWG_AI_SmokeOut_OnCompleted},
				/*_autoShow:*/(NWG_AI_Settings get "SMOKE_AUTOSHOW")
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_SMOK call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};

	//Repair
	_hasItem = (NWG_AI_Settings get "REPAIR_ITEM") in _flattenLoadOut;
	_isActionAssigned = SAVEID_REPR call NWG_AI_IsActionAssigned;
	switch (true) do {
		case (_hasItem && !_isActionAssigned): {
			//Hack-in short-circuit condition check for lowest down-to value (save some resources)
			(NWG_AI_Settings get "REPAIR_MATRIX") params ["","_downToRules"];
			private _lowest = 1;
			{if (_x < _lowest) then {_lowest = _x}} forEach _downToRules;
			NWG_AI_VehicleFix_lowestDownTo = _lowest;

			//Assign action
			[
				/*_saveID:*/SAVEID_REPR,
				/*_title:*/(NWG_AI_Settings get "REPAIR_TITLE"),
				/*_icon:*/(NWG_AI_Settings get "REPAIR_ICON"),
				/*_priority:*/(NWG_AI_Settings get "REPAIR_PRIORITY"),
				/*_duration:*/(NWG_AI_Settings get "REPAIR_DURATION"),
				/*_condition:*/"call NWG_AI_VehicleFix_Condition",
				/*_onStarted:*/{call NWG_AI_VehicleFix_OnStarted},
				/*_onInterrupted:*/{call NWG_AI_VehicleFix_OnInterrupted},
				/*_onCompleted:*/{call NWG_AI_VehicleFix_OnCompleted},
				/*_autoShow:*/(NWG_AI_Settings get "REPAIR_AUTOSHOW")
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_REPR call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};

	//Unflip
	_hasItem = (NWG_AI_Settings get "UNFLIP_ITEM") in _flattenLoadOut;
	_isActionAssigned = SAVEID_FLIP call NWG_AI_IsActionAssigned;
	switch (true) do {
		case (_hasItem && !_isActionAssigned): {
			//Assign action
			[
				/*_saveID:*/SAVEID_FLIP,
				/*_title:*/(NWG_AI_Settings get "UNFLIP_TITLE"),
				/*_icon:*/(NWG_AI_Settings get "UNFLIP_ICON"),
				/*_priority:*/(NWG_AI_Settings get "UNFLIP_PRIORITY"),
				/*_duration:*/(NWG_AI_Settings get "UNFLIP_DURATION"),
				/*_condition:*/"call NWG_AI_VehicleUnflip_Condition",
				/*_onStarted:*/{call NWG_AI_VehicleFix_OnStarted},//Reuse the same animation
				/*_onInterrupted:*/{call NWG_AI_VehicleFix_OnInterrupted},//Reuse the same interruption
				/*_onCompleted:*/{call NWG_AI_VehicleUnflip_OnCompleted},
				/*_autoShow:*/(NWG_AI_Settings get "UNFLIP_AUTOSHOW")
			] call NWG_AI_AssignAction;
		};
		case (!_hasItem && _isActionAssigned): {SAVEID_FLIP call NWG_AI_RemoveAction};//Remove action
		default {};//Do nothing
	};
};

NWG_AI_IsActionAssigned = {
	// private _saveID = _this;
	(player getVariable [_this,-1]) in (actionIDs player)
};

NWG_AI_AssignAction = {
	params ["_saveID","_title","_icon","_priority","_duration","_condition","_onStarted","_onInterrupted","_onCompleted","_autoShow"];
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
		_autoShow                       // Auto show on screen
	] call BIS_fnc_holdActionAdd;
	player setVariable [_saveID,_actionID];
};

NWG_AI_RemoveAction = {
	// private _saveID = _this;
	player removeAction (player getVariable [_this,-1]);
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
//Vehicle fix (Repair action)
NWG_AI_VehicleFix_lowestDownTo = -1;
NWG_AI_VehicleFix_Condition = {
    //Simple checks
    if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};

    //Short-circuit check for undamaged vehicles
    (getAllHitPointsDamage (call NWG_fnc_radarGetVehInFront)) params ["_vehParts","","_vehDamages"];
    if ((_vehDamages findIf {_x > NWG_AI_VehicleFix_lowestDownTo}) == -1) exitWith {false};

    //Complex check for vehicle parts
    (NWG_AI_Settings get "REPAIR_MATRIX") params ["_partsRules","_downToRules"];
    private _result = false;
    {
        if (_x > (_downToRules param [(_partsRules findIf {_x in (_vehParts#_forEachIndex)}),0])) exitWith {_result = true};
    } forEach _vehDamages;
    _result
};
NWG_AI_VehicleFix_OnStarted = {
    player playMoveNow (NWG_AI_Settings get "REPAIR_ANIMATION");
};
NWG_AI_VehicleFix_OnInterrupted = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Game logic will handle this
    call NWG_AI_ResetAnimation;
};
NWG_AI_VehicleFix_OnCompleted = {
    call NWG_AI_ResetAnimation;
    private _vehicle = call NWG_fnc_radarGetVehInFront;
    if (isNull _vehicle) exitWith {};

    (getAllHitPointsDamage (call NWG_fnc_radarGetVehInFront)) params ["_vehParts","","_vehDamages"];
    (NWG_AI_Settings get "REPAIR_MATRIX") params ["_partsRules","_downToRules"];
    private _fixDownTo = 0;
	private _hitIndexArray = [];
    {
        _fixDownTo = _downToRules param [(_partsRules findIf {_x in (_vehParts#_forEachIndex)}),0];
        if (_x > _fixDownTo) then {
			_hitIndexArray pushBack _forEachIndex;
			_hitIndexArray pushBack _fixDownTo;
		};
    } forEach _vehDamages;

	[_vehicle,_hitIndexArray] call NWG_fnc_setHitIndex;
};

//================================================================================================================
//================================================================================================================
//Vehicle unflip
NWG_AI_VehicleUnflip_Condition = {
    if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};
    ((vectorUp (call NWG_fnc_radarGetVehInFront)) select 2) < 0.5
};
NWG_AI_VehicleUnflip_OnCompleted = {
    call NWG_AI_ResetAnimation;
    private _vehicle = call NWG_fnc_radarGetVehInFront;
    if (isNull _vehicle) exitWith {};
    [player,_vehicle] call BIS_fnc_unflipThing;
};

//================================================================================================================
//================================================================================================================
call _Init;