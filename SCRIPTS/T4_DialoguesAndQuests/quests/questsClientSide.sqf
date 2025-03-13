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

		case QST_TYPE_INFECTION: {true};//TODO
		case QST_TYPE_WOUNDED: {true};//TODO
		case QST_TYPE_INTEL: {true};//TODO
		case QST_TYPE_MED_SUPPLY: {true};//TODO
		case QST_TYPE_WEAPON: {true};//TODO
		case QST_TYPE_ELECTRONICS: {true};//TODO
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

	//Run quest-specific logic
	private _questType = _questData param [QST_DATA_TYPE,-1];
	switch (_questType) do {
		case QST_TYPE_VEH_STEAL: {
			private _targetVehicle = [player,_questData] call NWG_QST_CLI_GetTargetVehicle;
			if (isNull _targetVehicle) exitWith {"NWG_QST_CLI_CloseQuest: Target vehicle is null" call NWG_fnc_logError};
			_targetVehicle call (NWG_QST_Settings get "FUNC_DELETE_VEHICLE");
		};
		default {};//Do nothing
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
		case QST_TYPE_INTEL;
		case QST_TYPE_WOUNDED: {_reward};

		/*Reward calculated on client side*/
		case QST_TYPE_INFECTION: {0};//TODO
		case QST_TYPE_MED_SUPPLY: {0};//TODO
		case QST_TYPE_WEAPON: {0};//TODO
		case QST_TYPE_ELECTRONICS: {0};//TODO

		/*Invalid quest type*/
		default {
			"NWG_QST_CLI_CloseQuest: Invalid quest type" call NWG_fnc_logError;
			0
		};
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

NWG_QST_CLI_OnInterrogateDone = {
	params ["_targetObj","_player"];
	//Get values
	private _targetName = name _targetObj;
	private _isSuccess = (_targetObj getVariable ["QST_toBreak",0]) <= 0;
	private _isQuestDone = !isNil "NWG_QST_State" && {NWG_QST_State >= QST_STATE_DONE};

	//Send system chat message
	private _message = switch (true) do {
		case (_isQuestDone): {selectRandom (NWG_QST_Settings get "INTERROGATE_DONE")};
		case (_isSuccess): {selectRandom (NWG_QST_Settings get "INTERROGATE_SUCCESS")};
		default {selectRandom (NWG_QST_Settings get "INTERROGATE_FAILED")};
	};
	[
		"[%1] %2",
		_targetName,
		_message
	] call NWG_fnc_systemChatAll;

	//If failed or quest is already done - exit
	if (!_isSuccess || _isQuestDone) exitWith {};

	//If succeed - report quest done
	_player remoteExec ["NWG_fnc_qstOnQuestDone",2];
};

//================================================================================================================
//================================================================================================================
call _Init;