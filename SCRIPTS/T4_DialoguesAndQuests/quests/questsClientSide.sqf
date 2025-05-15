#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
/*Moved to questsSettings.sqf*/

//================================================================================================================
//================================================================================================================
//Fields
/*Global Variables - Will be provided by server*/
// NWG_QST_State = QST_STATE_UNASSIGNED;
// NWG_QST_Data = [];
// NWG_QST_WinnerName = "";

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Auto-run OnQuestCreated if data is available (support JIP players)
	if (call NWG_QST_CLI_IsQuestActive) then {NWG_QST_Data call NWG_QST_CLI_OnQuestCreated};
};

//================================================================================================================
//================================================================================================================
//Quest creation
NWG_QST_CLI_OnQuestCreated = {
    // private _questData = _this;

	//Unpack quest data
	private _npc = _this param [QST_DATA_NPC,""];
	if (_npc isEqualTo "") exitWith {
		"NWG_QST_CLI_OnQuestCreated: No NPC in quest data" call NWG_fnc_logError;
	};
	private _marker = _this param [QST_DATA_MARKER,""];
	if (_marker isEqualTo "") exitWith {
		"NWG_QST_CLI_OnQuestCreated: No marker in quest data" call NWG_fnc_logError;
	};

	//Localize quest marker text
	private _localization = NWG_QST_Settings get "LOC_NPC_TO_MARKER_TEXT";
	if !(_npc in _localization) exitWith {
		(format ["NWG_QST_CLI_OnQuestCreated: No localization for NPC: '%1'",_npc]) call NWG_fnc_logError;
	};
	_marker setMarkerTextLocal ((_localization get _npc) call NWG_fnc_localize);
};

//================================================================================================================
//================================================================================================================
//Quest state
NWG_QST_CLI_IsQuestActive = {
	if (isNil "NWG_QST_State") exitWith {false};
	if !(NWG_QST_State in [QST_STATE_IN_PROGRESS,QST_STATE_FAILED,QST_STATE_DONE]) exitWith {false};
	if (isNil "NWG_QST_Data") exitWith {false};
	//return
	true
};

NWG_QST_CLI_IsQuestActiveForNpc = {
	// private _npcName = _this;
	if !(call NWG_QST_CLI_IsQuestActive) exitWith {false};
	//return
	_this isEqualTo (NWG_QST_Data param [QST_DATA_NPC,""])
};

NWG_QST_CLI_GetQuestData = {
	if (isNil "NWG_QST_State" || {NWG_QST_State == QST_STATE_UNASSIGNED}) exitWith {false};
	//return (shallow copy to prevent data corruption)
	NWG_QST_Data + []
};

//================================================================================================================
//================================================================================================================
//Quest completion and rewards
NWG_QST_CLI_TryCloseQuest = {
	// private _npcName = _this;
	if !(_this call NWG_QST_CLI_IsQuestActiveForNpc) exitWith {
		(format ["NWG_QST_CLI_TryCloseQuest: Quest is not active for NPC: '%1'",_this]) call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};

	//Get quest data
	private _questData = call NWG_QST_CLI_GetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_QST_CLI_TryCloseQuest: Failed to get quest data" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};
	private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
	if (_questType isEqualTo -1) exitWith {
		"NWG_QST_CLI_TryCloseQuest: Invalid quest type" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};

	//Define quest result
	private _questResult = switch (_questType) do {
		/*Winner defined by having target vehicle or its total analogue in owned vehicles*/
		case QST_TYPE_VEH_STEAL: {
			if !(isNull ([player,_questData] call NWG_QST_CLI_GetTargetVehicle))
				then {QST_RESULT_GD_END}
				else {QST_RESULT_UNDONE}
		};

		/*Winner is set server side and is defined by NWG_QST_WinnerName*/
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY;
		case QST_TYPE_WOUNDED;
		case QST_TYPE_BURNDOWN: {
			if (isNil "NWG_QST_State") exitWith {
				"NWG_QST_CLI_TryCloseQuest: Quest state is nil" call NWG_fnc_logError;
				false
			};
			if (NWG_QST_State isEqualTo QST_STATE_FAILED) exitWith {
				QST_RESULT_BD_END
			};
			if (NWG_QST_State isNotEqualTo QST_STATE_DONE) exitWith {
				QST_RESULT_UNDONE
			};
			if (player call NWG_QST_CLI_IsWinnerByName)
				then {QST_RESULT_GD_END}
				else {QST_RESULT_UNDONE}
		};

		/*Winner is defined by wether or not they have at least one item from the price map*/
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS;
		case QST_TYPE_TOOLS: {
			private _priceMap = (_questData param [QST_DATA_REWARD,[]]) param [QST_REWARD_PER_ITEM_PRICE_MAP,createHashMap];
			private _hasItem = false;
			private _hasItemFunc = NWG_QST_Settings get "FUNC_HAS_ITEM";
			{if (_x call _hasItemFunc) exitWith {_hasItem = true}} forEach _priceMap;
			if (_hasItem)
				then {QST_RESULT_GD_END}
				else {QST_RESULT_UNDONE}
		};

		/*Winner is defined by custom logic*/
		case QST_TYPE_INFECTION: {
			(call NWG_QST_CLI_CalcInfectionOutcome)
		};
		case QST_TYPE_WEAPON: {
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			if (_targetClassname call (NWG_QST_Settings get "FUNC_HAS_ITEM"))
				then {QST_RESULT_GD_END}
				else {QST_RESULT_UNDONE}
		};

		default {
			(format ["NWG_QST_CLI_TryCloseQuest: Invalid quest type: '%1'",_questType]) call NWG_fnc_logError;
			false
		};
	};
	if (_questResult isEqualTo false) exitWith {
		"NWG_QST_CLI_TryCloseQuest: Failed to define quest result" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};
	if (_questResult isEqualTo QST_RESULT_UNDONE) exitWith {QST_RESULT_UNDONE};//Quest is not done yet
	if !(_questResult in [QST_RESULT_GD_END,QST_RESULT_BD_END]) exitWith {
		"NWG_QST_CLI_TryCloseQuest: Invalid quest result: '%1'" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};

	//(Re)calculate reward
	private _reward = _questData param [QST_DATA_REWARD,false];
	_reward = switch (_questType) do {
		/*Reward pre-calculated by server side*/
		case QST_TYPE_VEH_STEAL;
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY;
		case QST_TYPE_WOUNDED;
		case QST_TYPE_WEAPON;
		case QST_TYPE_BURNDOWN: {
			if (_questResult isEqualTo QST_RESULT_BD_END) exitWith {false};//Quest failed
			_reward
		};

		/*Reward calculated on client side per item*/
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS;
		case QST_TYPE_TOOLS: {
			if (_questResult isEqualTo QST_RESULT_BD_END) exitWith {false};//Quest failed

			private _priceMap = (_questData param [QST_DATA_REWARD,[]]) param [QST_REWARD_PER_ITEM_PRICE_MAP,createHashMap];
			private _getCountFunc = NWG_QST_Settings get "FUNC_GET_ITEM_COUNT";
			private _count = 0;
			private _totalReward = 0;
			{
				_count = _x call _getCountFunc;
				if (_count > 0) then {_totalReward = _totalReward + (_count * _y)};
			} forEach _priceMap;
			//return
			round _totalReward
		};

		/*Reward calculated on client side per condition*/
		case QST_TYPE_INFECTION: {
			if (_questResult isEqualTo QST_RESULT_GD_END)
				then {_reward}
				else {round (_reward * 0.5)}
		};
	};

	//Run quest-specific logic
	switch (_questType) do {
		/*Delete target vehicle*/
		case QST_TYPE_VEH_STEAL: {
			private _targetVehicle = [player,_questData] call NWG_QST_CLI_GetTargetVehicle;
			if (isNull _targetVehicle) exitWith {"NWG_QST_CLI_TryCloseQuest: Target vehicle is null" call NWG_fnc_logError};
			_targetVehicle call (NWG_QST_Settings get "FUNC_DELETE_VEHICLE");
		};

		/*Delete items from player*/
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS;
		case QST_TYPE_TOOLS: {
			private _priceMap = (_questData param [QST_DATA_REWARD,[]]) param [QST_REWARD_PER_ITEM_PRICE_MAP,createHashMap];
			private _getCountFunc = NWG_QST_Settings get "FUNC_GET_ITEM_COUNT";
			private _items = [];
			private _counts = [];
			private _count = 0;
			{
				_count = _x call _getCountFunc;
				if (_count > 0) then {
					_items pushBack _x;
					_counts pushBack _count;
				};
			} forEach _priceMap;
			[_items,_counts] call (NWG_QST_Settings get "FUNC_REMOVE_ITEMS");
		};

		/*Delete target weapon from player*/
		case QST_TYPE_WEAPON: {
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			if !(_targetClassname call (NWG_QST_Settings get "FUNC_HAS_ITEM")) exitWith {
				"NWG_QST_CLI_TryCloseQuest: Target weapon not found" call NWG_fnc_logError;
			};
			//Delete from loadout
			private _loadout = getUnitLoadout player;
			private _deleted = false;
			{
				if (_targetClassname in (flatten (_loadout select _x))) exitWith {
					_loadout set [_x,[]];
					player setUnitLoadout _loadout;
					_deleted = true;
				};
			} forEach [0,1,2,8];//Primary,Secondary,Handgun,Binoculars
			if (_deleted) exitWith {
				player call (NWG_QST_Settings get "FUNC_ON_INVENTORY_CHANGE");
			};
			//Delete from inventory (uniform, vest, backpack)
			[[_targetClassname],[1]] call (NWG_QST_Settings get "FUNC_REMOVE_ITEMS");
		};
		default {};//Do nothing
	};

	//Close quest
	[player,_reward] remoteExec ["NWG_fnc_qstOnQuestClose",2];

	//return
	_questResult
};

//================================================================================================================
//================================================================================================================
//Utils
NWG_QST_CLI_IsWinnerByName = {
	// private _player = _this;
	private _playerName = name _this;
	if (isNil "NWG_QST_WinnerName") exitWith {
		"NWG_QST_CLI_IsWinnerByName: No winner set" call NWG_fnc_logError;
		false
	};

	//If winner is unknown - winner place is vacant
	private _curWinnerName = NWG_QST_WinnerName;
	if (_curWinnerName isEqualTo "") exitWith {true};
	if (_curWinnerName isEqualTo QST_UNKNOWN_WINNER) exitWith {true};

	//If winner is known, but not online - winner place is vacant
	private _isOnline = ((call NWG_fnc_getPlayersAll) findIf {(name _x) isEqualTo _curWinnerName}) != -1;
	if (!_isOnline) exitWith {true};

	//Check if this player is the winner
	//return
	_playerName isEqualTo _curWinnerName
};

NWG_QST_CLI_GetTargetVehicle = {
	params ["_player","_questData"];
	private _questTarget = _questData param [QST_DATA_TARGET_OBJECT,objNull];
	private _questTargetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
	private _ownedVehicles = _player call (NWG_QST_Settings get "FUNC_GET_PLAYER_VEHICLES");
	if !(_ownedVehicles isEqualType []) exitWith {
		(format ["NWG_QST_CLI_GetTargetVehicle: Invalid owned vehicles: '%1'",_ownedVehicles]) call NWG_fnc_logError;
		false
	};

	_ownedVehicles = _ownedVehicles select {(_x distance _player) < 100};
	private _i = _ownedVehicles findIf {
		_x isEqualTo _questTarget || {
		(typeOf _x) isEqualTo _questTargetClassname}
	};
	if (_i != -1) then {_ownedVehicles select _i} else {objNull}
};

NWG_QST_CLI_OnInterrogateCreated = {
	params ["_targetObj"];

	//Prepare 'add action' script
	private _addAction = {
		params ["_title","_icon","_condition","_onStarted","_onCompleted"];
		[
			_targetObj,                      // Object the action is attached to
			(_title call NWG_fnc_localize),  // Title of the action
			_icon,                           // Idle icon shown on screen
			_icon,                           // Progress icon shown on screen
			(format ["(_this distance _target) < 3 && {%1}",_condition]),  // Condition for the action to start
			(format ["(_caller distance _target) < 3 && {%1}",_condition]),// Condition for the action to progress
			_onStarted,                      // Code executed when action starts
			{},                              // Code executed on every progress tick
			_onCompleted,                    // Code executed on completion
			{},                              // Code executed on interrupted
			[],                              // Arguments passed to the scripts as _this select 3
			3,                               // Action duration in seconds
			15,                              // Priority
			false,                           // Remove on completion
			false,                           // Show in unconscious state
			true                             // Auto show on screen
    	] call BIS_fnc_holdActionAdd
	};

	//Add 'Tie Up' action
	[
		NWG_QST_Settings get "INTERROGATE_TIE_TITLE",
		NWG_QST_Settings get "INTERROGATE_TIE_ICON",
		"[_target,false] call NWG_QST_CLI_InterrogateCondition",
		{},
		{_this call NWG_QST_CLI_OnInterrogateTieAction}
	] call _addAction;

	//Add 'Interrogate' action
	[
		NWG_QST_Settings get "INTERROGATE_TITLE",
		NWG_QST_Settings get "INTERROGATE_ICON",
		"[_target,true] call NWG_QST_CLI_InterrogateCondition",
		{_this call NWG_QST_CLI_OnInterrogateStart},
		{_this call NWG_QST_CLI_OnInterrogateAction}
	] call _addAction;
};
NWG_QST_CLI_InterrogateCondition = {
	params ["_targetObj","_expectedTied"];
	if (isNull _targetObj || {!alive _targetObj}) exitWith {false};
	(_targetObj getVariable ["QST_isTied",false]) isEqualTo _expectedTied
};
NWG_QST_CLI_OnInterrogateTieAction = {
	params ["_targetObj","_player"];
	if (_targetObj getVariable ["QST_isTied",false]) exitWith {};
	_targetObj setVariable ["QST_isTied",true,true];
	[_targetObj,player] remoteExec ["NWG_fnc_qstOnInterrogateTied",2];
};
NWG_QST_CLI_OnInterrogateStart = {
	// params ["_targetObj","_player"];
	_this spawn {
		params ["_targetObj","_player"];
		if ((currentWeapon player) isNotEqualTo "") then {
			player action ["SwitchWeapon",player,player,-1];
			sleep 2.5;
			player switchMove [""];
		};

		//Play animation
		private _animFlag = selectRandom [0,1];
		private _anim = ["Acts_Executioner_Backhand","Acts_Executioner_Forehand"] select _animFlag;
		player playMoveNow _anim;//Immediate animation
		player playMove "Acts_Executioner_Kill_End";//Exit animation loop
		//Send to server so that target could play corresponding animation
		if (_animFlag == 0) then {sleep 0.25} else {sleep 0.4};
		[_targetObj,_animFlag] remoteExec ["NWG_fnc_qstOnInterrogateAction",2];
	};
};
NWG_QST_CLI_OnInterrogateAction = {
	params ["_targetObj","_player"];
	if (!alive _targetObj) exitWith {};//Dead men tell no tales

	//Get values
	private _toBreak = _targetObj getVariable ["QST_toBreak",0];
	private _isSuccess = _toBreak <= 0;
	private _isQuestDone = !isNil "NWG_QST_State" && {NWG_QST_State >= QST_STATE_DONE};

	//Define outcome
	private _message = switch (true) do {
		case (_isQuestDone): {
			/*Already done - just a message, nothing else to do*/
			selectRandom (NWG_QST_Settings get "INTERROGATE_DONE")
		};
		case (_isSuccess): {
			/*Success - report quest done and send a message*/
			_player remoteExec ["NWG_fnc_qstOnQuestDone",2];
			selectRandom (NWG_QST_Settings get "INTERROGATE_SUCCESS")
		};
		default {
			/*Failed - deplete break counter and send a message*/
			_targetObj setVariable ["QST_toBreak",_toBreak - 1,true];
			selectRandom (NWG_QST_Settings get "INTERROGATE_FAILED")
		};
	};

	//Output message
	[(name _targetObj),(_message call NWG_fnc_localize)] call BIS_fnc_showSubtitle;
};

NWG_QST_CLI_OnHackCreated = {
	params ["_targetObj"];
	//Check for JIP players
	if (_targetObj getVariable ["QST_isHacked",false]) exitWith {_targetObj call NWG_QST_CLI_OnHackDone};

	//Set 'hackable' textures
	[_targetObj,false] call NWG_QST_CLI_SetHackTextures;

	//Add action
	private _title = NWG_QST_Settings get "HACK_DATA_TITLE";
	private _icon = NWG_QST_Settings get "HACK_DATA_ICON";
	private _actionId = [_targetObj,_title,_icon,{_this call NWG_QST_CLI_OnHackDo},{call NWG_QST_CLI_OnHackStart}] call NWG_fnc_addHoldAction;
	if (isNil "_actionId") exitWith {
		"NWG_QST_CLI_OnHackCreated: Failed to add action" call NWG_fnc_logError;
		false
	};

	//Save action ID for later removal
	_targetObj setVariable ["QST_hackActionId",_actionId];//Set locally
};
NWG_QST_CLI_OnHackStart = {
	//Play animation
	player playMoveNow "Acts_Accessing_Computer_in";
	player playMove "Acts_Accessing_Computer_Loop";
	player playMove "Acts_Accessing_Computer_Out_Short";
};
NWG_QST_CLI_OnHackDo = {
	params ["_targetObj","_player"];
	//Check again just in case
	if (_targetObj getVariable ["QST_isHacked",false]) exitWith {};

	//Mark hacked for everyone
	_targetObj setVariable ["QST_isHacked",true,true];
	_targetObj remoteExec ["NWG_fnc_qstOnHackDone",0];

	//Report to server
	_player remoteExec ["NWG_fnc_qstOnQuestDone",2];
};
NWG_QST_CLI_OnHackDone = {
	private _targetObj = _this;

	//Set 'hacked' textures
	[_targetObj,true] call NWG_QST_CLI_SetHackTextures;

	//Remove action
	private _actionId = _targetObj getVariable ["QST_hackActionId",-1];
	if (_actionId != -1) then {_targetObj removeAction _actionId};
};
NWG_QST_CLI_SetHackTextures = {
	params ["_targetObj","_isHacked"];
	private _textures = if (_isHacked)
		then {NWG_QST_Settings get "HACK_TEXTURES_HACKED"}
		else {NWG_QST_Settings get "HACK_TEXTURES_UNHACKED"};

	private _texturePositions = [];
	{
		if ("#" in _x) then {_texturePositions pushBack _forEachIndex; continue};//Color as texture - valid
		if ("military" in _x) then {continue};//Case for rugged military objects - skip
		_texturePositions pushBack _forEachIndex;
	} forEach (getObjectTextures _targetObj);

	{
		_targetObj setObjectTexture [_x,(selectRandom _textures)];
	} forEach _texturePositions;
};

NWG_QST_CLI_OnWoundedCreated = {
	params ["_targetObj"];
	//Check for JIP players
	if (_targetObj getVariable ["QST_isUntied",false]) exitWith {_targetObj call NWG_QST_CLI_OnUntieWoundedDone};

	//Add action
	private _title = NWG_QST_Settings get "WOUNDED_TITLE";
	private _icon = NWG_QST_Settings get "WOUNDED_ICON";
	private _actionId = [_targetObj,_title,_icon,{_this call NWG_QST_CLI_OnUntieWounded}] call NWG_fnc_addHoldAction;
	if (isNil "_actionId") exitWith {
		"NWG_QST_CLI_OnWoundedCreated: Failed to add action" call NWG_fnc_logError;
		false
	};

	//Save action ID for later removal
	_targetObj setVariable ["QST_untieActionId",_actionId];//Set locally
};
NWG_QST_CLI_OnUntieWounded = {
	params ["_targetObj","_player"];
	//Check again just in case
	if (_targetObj getVariable ["QST_isUntied",false]) exitWith {};

	//Mark untied for everyone
	_targetObj setVariable ["QST_isUntied",true,true];
	_targetObj remoteExec ["NWG_fnc_qstOnUntieWoundedDone",0];

	//Finalize
	if (alive _targetObj) then {
		_targetObj call (NWG_QST_Settings get "FUNC_ON_WOUNDED_UNTIED");
	};
};
NWG_QST_CLI_OnUntieWoundedDone = {
	private _targetObj = _this;

	//Remove action
	private _actionId = _targetObj getVariable ["QST_untieActionId",-1];
	if (_actionId != -1) then {_targetObj removeAction _actionId};
};

NWG_QST_CLI_CalcInfectionOutcome = {
	if (isNil "NWG_QST_InfectionData") exitWith {
		"NWG_QST_CLI_CalcInfectionOutcome: Infection data is nil" call NWG_fnc_logError;
		0
	};

	NWG_QST_InfectionData params [["_infectedCount",0],["_healedCount",0],["_killedCount",0]];
	if ((_healedCount + _killedCount) < (_infectedCount * 0.66)) exitWith {QST_RESULT_UNDONE};//It's not over yet
	if (_healedCount > _killedCount) then {QST_RESULT_GD_END} else {QST_RESULT_BD_END}
};

NWG_QST_CLI_OnBurnCreated = {
	params ["_targetObj"];
	_targetObj lockInventory true;//Prevent looting
	//Check for JIP players
	if (_targetObj getVariable ["QST_isBurned",false]) exitWith {_targetObj call NWG_QST_CLI_OnBurnDone};

	//Add action
	private _title = NWG_QST_Settings get "BURNDOWN_TITLE";
	private _icon = NWG_QST_Settings get "BURNDOWN_ICON";
	private _actionId = [_targetObj,_title,_icon,{_this call NWG_QST_CLI_OnBurnDo}] call NWG_fnc_addHoldAction;
	if (isNil "_actionId") exitWith {
		"NWG_QST_CLI_OnBurnCreated: Failed to add action" call NWG_fnc_logError;
		false
	};

	//Save action ID for later removal
	_targetObj setVariable ["QST_burnActionId",_actionId];//Set locally
};
NWG_QST_CLI_OnBurnDo = {
	params ["_targetObj","_player"];
	//Check again just in case
	if (_targetObj getVariable ["QST_isBurned",false]) exitWith {};

	//Mark burned for everyone
	_targetObj setVariable ["QST_isBurned",true,true];
	_targetObj remoteExec ["NWG_fnc_qstOnBurnDone",0];//Also creates fire

	//Report to server
	_player remoteExec ["NWG_fnc_qstOnQuestDone",2];
};
NWG_QST_CLI_OnBurnDone = {
	private _targetObj = _this;

	//Remove action
	private _actionId = _targetObj getVariable ["QST_burnActionId",-1];
	if (_actionId != -1) then {_targetObj removeAction _actionId};
};

//================================================================================================================
//================================================================================================================
call _Init;