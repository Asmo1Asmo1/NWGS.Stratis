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
	if !(NWG_QST_State in [QST_STATE_IN_PROGRESS,QST_STATE_DONE]) exitWith {false};
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
	if !(call NWG_QST_CLI_IsQuestActive) exitWith {false};
	//return (shallow copy to prevent data corruption)
	NWG_QST_Data + []
};

//================================================================================================================
//================================================================================================================
//Quest completion
NWG_QST_CLI_CanCloseQuest = {
	// private _npcName = _this;
	if !(_this call NWG_QST_CLI_IsQuestActiveForNpc) exitWith {false};
	private _questData = call NWG_QST_CLI_GetQuestData;
	if (_questData isEqualTo false) exitWith {false};

	private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
	if (_questType isEqualTo -1) exitWith {false};

	private _canClose = switch (_questType) do {
		/*Winner defined by having target vehicle or its total analogue in owned vehicles*/
		case QST_TYPE_VEH_STEAL: {
			!(isNull ([player,_questData] call NWG_QST_CLI_GetTargetVehicle))
		};

		/*Winner is set server side and is defined by NWG_QST_WinnerName*/
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY: {
			!isNil "NWG_QST_State" && {
			NWG_QST_State == QST_STATE_DONE && {
			player call NWG_QST_CLI_IsWinnerByName}}
		};

		/*Winner is defined by wether or not they have at least one item from the price map*/
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS: {
			private _priceMap = (_questData param [QST_DATA_REWARD,[]]) param [QST_REWARD_PER_ITEM_PRICE_MAP,createHashMap];
			private _hasItem = false;
			private _hasItemFunc = NWG_QST_Settings get "FUNC_HAS_ITEM";
			{if (_x call _hasItemFunc) exitWith {_hasItem = true}} forEach _priceMap;
			_hasItem
		};

		/*Winner is defined by custom logic*/
		case QST_TYPE_INFECTION: {true};//TODO
		case QST_TYPE_WOUNDED: {true};//TODO
		case QST_TYPE_WEAPON: {
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			_targetClassname call (NWG_QST_Settings get "FUNC_HAS_ITEM")
		};
		default {false};
	};

	//return
	_canClose
};

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

//================================================================================================================
//================================================================================================================
//Quest closure and rewards
NWG_QST_CLI_CloseQuest = {
	// private _npcName = _this;
	if !(_this call NWG_QST_CLI_IsQuestActiveForNpc) exitWith {
		(format ["NWG_QST_CLI_CloseQuest: Quest is not active for NPC: '%1'",_this]) call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};
	if !(call NWG_QST_CLI_CanCloseQuest) exitWith {
		"NWG_QST_CLI_CloseQuest: Quest cannot be closed by player" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};

	//Get quest data
	private _questData = call NWG_QST_CLI_GetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_QST_CLI_CloseQuest: Failed to get quest data" call NWG_fnc_logError;
		"#QST_CLOSE_ERROR#" call NWG_fnc_systemChatMe;
		false
	};

	//(Re)calculate reward
	private _questType = _questData param [QST_DATA_TYPE,-1];
	private _reward = _questData param [QST_DATA_REWARD,false];
	_reward = switch (_questType) do {
		/*Reward pre-calculated by server side*/
		case QST_TYPE_VEH_STEAL;
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY;
		case QST_TYPE_WOUNDED;
		case QST_TYPE_WEAPON: {_reward};

		/*Reward calculated on client side per item*/
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS: {
			private _priceMap = (_questData param [QST_DATA_REWARD,[]]) param [QST_REWARD_PER_ITEM_PRICE_MAP,createHashMap];
			private _getCountFunc = NWG_QST_Settings get "FUNC_GET_ITEM_COUNT";
			private _items = [];
			private _counts = [];
			private _count = 0;
			private _totalReward = 0;
			{
				_count = _x call _getCountFunc;
				if (_count <= 0) then {continue};
				_totalReward = _totalReward + (_count * _y);
				_items pushBack _x;
				_counts pushBack _count;
			} forEach _priceMap;
			/*Inject removing items just not to re-calculate counts again*/
			[_items,_counts] call (NWG_QST_Settings get "FUNC_REMOVE_ITEMS");
			//return
			round _totalReward
		};

		/*Reward calculated on client side per condition*/
		case QST_TYPE_INFECTION: {0};//TODO

		/*Invalid quest type*/
		default {
			"NWG_QST_CLI_CloseQuest: Invalid quest type" call NWG_fnc_logError;
			0
		};
	};

	//Run quest-specific logic
	switch (_questType) do {
		case QST_TYPE_VEH_STEAL: {
			//Delete target vehicle
			private _targetVehicle = [player,_questData] call NWG_QST_CLI_GetTargetVehicle;
			if (isNull _targetVehicle) exitWith {"NWG_QST_CLI_CloseQuest: Target vehicle is null" call NWG_fnc_logError};
			_targetVehicle call (NWG_QST_Settings get "FUNC_DELETE_VEHICLE");
		};
		case QST_TYPE_WEAPON: {
			//Delete target weapon from player
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			if !(_targetClassname call (NWG_QST_Settings get "FUNC_HAS_ITEM")) exitWith {
				"NWG_QST_CLI_CloseQuest: Target weapon not found" call NWG_fnc_logError;
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
	[player,_reward] remoteExec ["NWG_fnc_qstOnQuestClosed",2];
};

//================================================================================================================
//================================================================================================================
//Utils
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

NWG_QST_CLI_OnInterrogateStart = {
	//Play animation
	player playMoveNow (selectRandom ["Acts_Executioner_Backhand","Acts_Executioner_Forehand"]);
	player playMove "Acts_Executioner_Kill_End";//Exit animation loop
};
NWG_QST_CLI_OnInterrogateDone = {
	params ["_targetObj","_player"];

	//Get values
	private _targetName = name _targetObj;
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

	//Send system chat message
	[
		"[%1] %2",
		_targetName,
		_message
	] call NWG_fnc_systemChatAll;
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
//================================================================================================================
//================================================================================================================
call _Init;