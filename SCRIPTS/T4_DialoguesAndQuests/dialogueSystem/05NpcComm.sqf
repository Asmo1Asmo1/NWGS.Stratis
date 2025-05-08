#include "..\..\globalDefines.h"
/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
*/

//================================================================================================================
//================================================================================================================
//Defines
// #define IDC_QLISTBOX 1500
// #define IDC_ALISTBOX 1501
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_TEXT_NPC 1002

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLG_COMM_Settings = createHashMapFromArray [
	/*Player level requirements for mission level selection*/
	["MISSION_TO_PLAYER_LEVEL",[
		/*Level 01*/ 0,
		/*Level 02*/ 2,
		/*Level 03*/ 4,
		/*Level 04*/ 8,
		/*Level 05*/ 12,
		/*Level 06*/ 16,
		/*Level 07*/ 20,
		/*Level 08*/ 28,
		/*Level 09*/ 36,
		/*Level 10*/ 44,
		/*Level 11*/ 52,
		/*Level 12*/ 60,
		/*Level 13*/ 70,
		/*Level 14*/ 80,
		/*Level 15*/ 90,
		/*Level 16*/ 100,
		/*Level 17 - ESCAPE*/ 100
	]],

	/*Level unlock prices*/
	["UNLOCK_PRICES",[
		/*Level 01*/ 1000,
		/*Level 02*/ 15000,
		/*Level 03*/ 50000,
		/*Level 04*/ 80000,
		/*Level 05*/ 110000,
		/*Level 06*/ 200000,
		/*Level 07*/ 300000,
		/*Level 08*/ 500000,
		/*Level 09*/ 800000,
		/*Level 10*/ 1100000,
		/*Level 11*/ 2000000,
		/*Level 12*/ 3000000,
		/*Level 13*/ 5000000,
		/*Level 14*/ 8000000,
		/*Level 15*/ 11000000,
		/*Level 16*/ 15000000,
		/*Level 17 - ESCAPE*/ 1000000
	]],

	/*Level unlock notification template*/
	["NOTIFICATION_TEMPLATE","#COMM_LVLNLCK_NOTIFICATION#"],

	["COLOR_REQ_LOCKED",[1,1,1,0.5]],
	["COLOR_LOCKED",[0,1,0,0.5]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Mission state
NWG_DLG_COMM_IsMissionStarted = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState > MSTATE_VOTING
};
NWG_DLG_COMM_IsMissionReady = {
	/*inject show player money to reverse displaying group money*/
	if (call NWG_DLG_COMM_IsGroupLeader) then {
		call NWG_DLGHLP_UI_UpdatePlayerMoney;
	};

	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState == MSTATE_READY
};

//================================================================================================================
//================================================================================================================
//Is alone
NWG_DLG_COMM_IsAlone = {
	(count (call NWG_fnc_getPlayersAll)) == 1
};

//================================================================================================================
//================================================================================================================
//Is group leader for level unlock
NWG_DLG_COMM_IsGroupLeader = {
	(({isPlayer _x} count (units (group player))) > 1) && {player isEqualTo (leader (group player))}
};

//================================================================================================================
//================================================================================================================
//Level select and unlock
NWG_DLG_COMM_selectedLevel = -1;
NWG_DLG_COMM_SetSelectedLevel = {
	NWG_DLG_COMM_selectedLevel = _this;
};

NWG_DLG_COMM_GenerateLevelSelect = {
	//Get list of available levels (array of booleans, where false means that the level is locked)
	private _availableLevels = call NWG_fnc_mmGetUnlockedLevels;
	private _playerLevel = player call NWG_fnc_pGetMyLvl;
	private _playerLevelReqs = NWG_DLG_COMM_Settings get "MISSION_TO_PLAYER_LEVEL";
	private _unlockPrices = NWG_DLG_COMM_Settings get "UNLOCK_PRICES";

	private _result = [];
	private ["_lvl","_req","_price"];
	{
		_lvl = _forEachIndex;
		_req = _playerLevelReqs param [_forEachIndex,0];
		_price = _unlockPrices  param [_forEachIndex,0];

		//Check if player is of lower level than required
		if (_playerLevel < _req) exitWith {
			_result pushBack [
				/*A_STR:*/["#COMM_LVLSEL_LVLREQ#",_req],
				/*A_NEXT_NODE:*/"COMM_LVL_REQ_LOCKED",
				/*A_CODE:*/NWG_DLG_COMM_SetSelectedLevel,
				/*A_CODE_ARGS:*/_lvl,
				/*A_COLOR:*/(NWG_DLG_COMM_Settings get "COLOR_REQ_LOCKED")
			];
		};

		//Check if level is locked
		if (!_x) exitWith {
			_result pushBack [
				/*A_STR:*/["#COMM_LVLSEL_LOCKED#",(_price call NWG_fnc_wltFormatMoney)],
				/*A_NEXT_NODE:*/"COMM_LVL_UNLOCK_PAY",
				/*A_CODE:*/NWG_DLG_COMM_SetSelectedLevel,
				/*A_CODE_ARGS:*/_lvl,
				/*A_COLOR:*/(NWG_DLG_COMM_Settings get "COLOR_LOCKED")
			];
		};

		_result pushBack [
			/*A_STR:*/["#COMM_LVLSEL#",(_lvl + 1)],//For logic levels are 0-N, for UI they are 1-N+1
			/*A_NEXT_NODE:*/"COMM_LVL_MISSION",
			/*A_CODE:*/NWG_DLG_COMM_SetSelectedLevel,
			/*A_CODE_ARGS:*/_lvl
		];
	} forEach _availableLevels;

	//Return the result
	_result
};

NWG_DLG_COMM_GetLevelReq = {
	(NWG_DLG_COMM_Settings get "MISSION_TO_PLAYER_LEVEL") param [NWG_DLG_COMM_selectedLevel,0]
};

NWG_DLG_COMM_GetLevelUnlockPrice = {
	/*inject show group money in dialogue UI*/
	if (call NWG_DLG_COMM_IsGroupLeader) then {
		private _gui = uiNamespace getVariable ["NWG_DLG_gui",displayNull];
		if (isNull _gui) exitWith {};
		(_gui displayCtrl IDC_TEXT_LEFT) ctrlSetText (((group player) call NWG_fnc_wltGetGroupMoney) call NWG_fnc_wltFormatMoney);
	};

	//return
	(NWG_DLG_COMM_Settings get "UNLOCK_PRICES") param [NWG_DLG_COMM_selectedLevel,0]
};

NWG_DLG_COMM_HasEnoughMoneyGroup = {
	// private _moneyReq = _this;
	if (call NWG_DLG_COMM_IsGroupLeader)
		then {((group player) call NWG_fnc_wltGetGroupMoney) >= _this}
		else {(player call NWG_fnc_wltGetPlayerMoney) >= _this};
};
NWG_DLG_COMM_HasLessMoneyGroup = {
	// private _moneyReq = _this;
	if (call NWG_DLG_COMM_IsGroupLeader)
		then {((group player) call NWG_fnc_wltGetGroupMoney) < _this}
		else {(player call NWG_fnc_wltGetPlayerMoney) < _this};
};

NWG_DLG_COMM_UnlockLevel = {
	//Check selected level validity
	private _selectedLevel = NWG_DLG_COMM_selectedLevel;
	private _availableLevels = call NWG_fnc_mmGetUnlockedLevels;
	if (_selectedLevel < 0 || {_selectedLevel >= (count _availableLevels)}) exitWith {
		(format ["NWG_DLG_COMM_UnlockLevel: Invalid level selected: %1",_selectedLevel]) call NWG_fnc_logError;
		false
	};
	if (_availableLevels param [_selectedLevel,false]) exitWith {
		(format ["NWG_DLG_COMM_UnlockLevel: Level is already unlocked: %1",_selectedLevel]) call NWG_fnc_logError;
		false
	};

	//Check player level
	private _playerLevel = player call NWG_fnc_pGetMyLvl;
	private _playerLevelReqs = NWG_DLG_COMM_Settings get "MISSION_TO_PLAYER_LEVEL";
	if (_playerLevel < (_playerLevelReqs param [_selectedLevel,0])) exitWith {
		(format ["NWG_DLG_COMM_UnlockLevel: Player level is too low. Level: %1, Player level: %2, Required level: %3",_selectedLevel,_playerLevel,(_playerLevelReqs param [_selectedLevel,0])]) call NWG_fnc_logError;
		false
	};

	//Check if player has enough money
	private _price = (NWG_DLG_COMM_Settings get "UNLOCK_PRICES") param [_selectedLevel,0];
	private _playerMoney =  if (call NWG_DLG_COMM_IsGroupLeader)
		then {(group player) call NWG_fnc_wltGetGroupMoney}
		else {player call NWG_fnc_wltGetPlayerMoney};
	if (_price > _playerMoney) exitWith {
		(format ["NWG_DLG_COMM_UnlockLevel: Player has insufficient funds. Level: %1, Price: %2, Player money: %3",_selectedLevel,_price,_playerMoney]) call NWG_fnc_logError;
		false
	};

	//Unlock level
	private _ok = _selectedLevel call NWG_fnc_mmUnlockLevel;
	if (!_ok) exitWith {
		(format ["NWG_DLG_COMM_UnlockLevel: Failed to send unlock level request. Level: %1",_selectedLevel]) call NWG_fnc_logError;
		false
	};

	//Pay for unlock
	if (call NWG_DLG_COMM_IsGroupLeader)
		then {[(group player),-_price] call NWG_fnc_wltSplitMoneyToGroup}
		else {[player,-_price] call NWG_fnc_wltAddPlayerMoney};

	//Update UI
	call NWG_DLGHLP_UI_UpdatePlayerMoney;

	//Notify everyone
	private _template = NWG_DLG_COMM_Settings get "NOTIFICATION_TEMPLATE";
	[_template,(name player),(_selectedLevel + 1)] call NWG_fnc_sideChatAll;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Mission selection for level
NWG_DLG_COMM_ShowMissionSelection = {
	//Check selected level validity
	private _selectedLevel = NWG_DLG_COMM_selectedLevel;
	private _availableLevels = call NWG_fnc_mmGetUnlockedLevels;
	if (_selectedLevel < 0 || {_selectedLevel >= (count _availableLevels)}) exitWith {
		(format ["NWG_DLG_COMM_ShowMissionSelection: Invalid level selected: %1",_selectedLevel]) call NWG_fnc_logError;
		false
	};
	if !(_availableLevels param [_selectedLevel,false]) exitWith {
		(format ["NWG_DLG_COMM_ShowMissionSelection: Level is not unlocked: %1",_selectedLevel]) call NWG_fnc_logError;
		false
	};

	//Show mission selection
	_selectedLevel call NWG_fnc_mmOpenMissionSelection;
	true
};
