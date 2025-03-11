#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_QST_CL_Settings = createHashMapFromArray [
	/*Localization*/
	["LOC_NPC_TO_MARKER_TEXT",createHashMapFromArray [
		[NPC_TAXI,"#NPC_TAXI_NAME#"],
		[NPC_MECH,"#NPC_MECH_NAME#"],
		[NPC_TRDR,"#NPC_TRDR_NAME#"],
		[NPC_MEDC,"#NPC_MEDC_NAME#"],
		[NPC_COMM,"#NPC_COMM_NAME#"],
		[NPC_ROOF,"#NPC_ROOF_NAME#"]
	]],

    ["",0]
];

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
	private _localization = NWG_QST_CL_Settings get "LOC_NPC_TO_MARKER_TEXT";
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
		/*Winner is set server side and is defined by NWG_QST_WinnerName*/
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY: {
			!isNil "NWG_QST_State" && {
			NWG_QST_State == QST_STATE_DONE && {
			player call NWG_QST_CLI_IsWinnerByName}}
		};

		case QST_TYPE_VEH_STEAL: {true};//TODO
		case QST_TYPE_INFECTION: {true};//TODO
		case QST_TYPE_WOUNDED: {true};//TODO
		case QST_TYPE_INTEL: {true};//TODO
		case QST_TYPE_MED_SUPPLY: {true};//TODO
		case QST_TYPE_TERMINAL: {true};//TODO
		case QST_TYPE_WEAPON: {true};//TODO
		case QST_TYPE_ELECTRONICS: {true};//TODO
		case QST_TYPE_TOOLS: {true};//TODO
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
		false
	};
	if !(call NWG_QST_CLI_CanCloseQuest) exitWith {
		"NWG_QST_CLI_CloseQuest: Quest cannot be closed by player" call NWG_fnc_logError;
		false
	};

	//Get quest data
	private _questData = call NWG_QST_CLI_GetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_QST_CLI_CloseQuest: Failed to get quest data" call NWG_fnc_logError;
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
		case QST_TYPE_INTEL;
		case QST_TYPE_WOUNDED: {_reward};

		/*Reward calculated on client side*/
		case QST_TYPE_INFECTION: {0};//TODO
		case QST_TYPE_MED_SUPPLY: {0};//TODO
		case QST_TYPE_TERMINAL: {0};//TODO
		case QST_TYPE_WEAPON: {0};//TODO
		case QST_TYPE_ELECTRONICS: {0};//TODO
		case QST_TYPE_TOOLS: {0};//TODO

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
call _Init;