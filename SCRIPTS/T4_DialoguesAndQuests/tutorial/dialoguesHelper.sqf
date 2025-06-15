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
//Dialogue UI
#define IDC_QLISTBOX 1500
// #define IDC_ALISTBOX 1501
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_TEXT_NPC 1002

//================================================================================================================
//================================================================================================================
//STEP_02_TRDR
NWG_TUTDLG_TRDR_DisplayTutorial = {
	disableSerialization;
	private _npcName = NPC_TRDR;
	private _onError = "[NO TUTORIAL DATA]";

	//Display NPC name
	private _gui = uiNamespace getVariable ["NWG_DLG_gui",displayNull];
	if (isNull _gui) exitWith {
		"NWG_TUTDLG_TRDR_DisplayTutorial: GUI is null" call NWG_fnc_logError;
		_onError
	};
	private _qListbox = _gui displayCtrl IDC_QLISTBOX;
	if (isNull _qListbox) exitWith {
		"NWG_TUTDLG_TRDR_DisplayTutorial: Quest list box is null" call NWG_fnc_logError;
		_onError
	};
	private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOC_NPC_NAME") getOrDefault [_npcName,""]) call NWG_fnc_localize;
	_qListbox lbAdd "";//Add empty line to separate records
	_qListbox lbAdd (format [(NWG_DLG_CLI_Settings get "TEMPLATE_SPEAKER_NAME"),_npcNameLoc]);//Add speaker name

	//Prepare variables
	private _row = "";
	private _picture = "";
	private _addRow = {
		params ["_row","_picture"];
		_row = _row call NWG_fnc_localize;
		private _pictureIndex = -1;
		private _i = -1;
		{
			_i = _qListbox lbAdd _x;
			if (_pictureIndex < 0) then {_pictureIndex = _i};
		} forEach (_row splitString "|");
		if (_pictureIndex > 0 && {_picture isNotEqualTo ""}) then {
			_qListbox lbSetPicture [_pictureIndex,_picture];
		};
	};

	//Inventory actions
	["#TRDR_TUTOR02_INVACT#",""] call _addRow;
	//'Loot' button
	["#INV_BUTTON_LOOT_TOOLTIP#","\A3\ui_f\data\igui\cfg\simpleTasks\types\upload_ca.paa"] call _addRow;
	["#TRDR_TUTOR02_INVACT_LOOT#",""] call _addRow;
	//Equip
	["#INV_BUTTON_UNIF_TOOLTIP#","\A3\ui_f\data\igui\cfg\simpleTasks\types\armor_ca.paa"] call _addRow;
	//Repack
	["#INV_BUTTON_MAGR_TOOLTIP#","\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa"] call _addRow;
	//Switch weapon
	["#INV_BUTTON_WEAP_TOOLTIP#","\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa"] call _addRow;

	//Buy items advice
	["#TRDR_TUTOR02_BUY_ADVICE#",""] call _addRow;
	//First aid kit
	private _cfg = configFile >> "CfgWeapons" >> "FirstAidKit";
	private _name = getText (_cfg >> "displayName");
	private _image = getText (_cfg >> "picture");
	private _text = format ["%1 - %2",_name,("#TRDR_TUTOR02_BUY_ADVICE_FAK#" call NWG_fnc_localize)];
	[_text,_image] call _addRow;
	//Sleeping bag
	_cfg = configFile >> "CfgMagazines" >> "Sleeping_bag_folded_01";
	_name = getText (_cfg >> "displayName");
	_image = getText (_cfg >> "picture");
	_text = format ["%1 - %2",_name,("#TRDR_TUTOR02_BUY_ADVICE_BAG#" call NWG_fnc_localize)];
	[_text,_image] call _addRow;

	//return to display normally
	"#TRDR_TUTOR02_02v1_Q#"
};

NWG_TUTDLG_TRDR_OpenItemsShop = {
	//Open items shop
	call NWG_fnc_ishopOpenShop;
	//Wait for shop to be opened, then closed, then go to the next step
	//note: uses inner kitchen of 'shopItemsClientSide.sqf'
	[] spawn {
		disableSerialization;
		//Wait for shop to open
		private _timeoutAt = time + 10;
		private _shopGUI = displayNull;
		waitUntil {
			sleep 0.1;
			_shopGUI = uiNamespace getVariable ["NWG_ISHOP_CLI_shopGUI",displayNull];
			if !(isNull _shopGUI) exitWith {true};
			if (time > _timeoutAt) exitWith {true};
			false
		};
		if (time > _timeoutAt) exitWith {
			"NWG_TUTDLG_TRDR_OpenItemsShop: timeout" call NWG_fnc_logError;
			false
		};
		//Show shop hint
		hint ("#TRDR_TUTOR02_SHOP_HINT#" call NWG_fnc_localize);
		//Wait for shop to close
		_shopGUI displayAddEventHandler ["Unload",{
			hintSilent "";//Clear hint
			call NWG_TUT_NextStep;
		}];
	};
};

//================================================================================================================
//================================================================================================================
//STEP_04_COMM
NWG_TUTDLG_COMM_IsReadyState = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState == MSTATE_READY
};
NWG_TUTDLG_COMM_IsFightState = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState > MSTATE_VOTING
};
NWG_TUTDLG_COMM_IsInvalidState = {
	if (isNil "NWG_MIS_CurrentState") exitWith {true};
	if (NWG_MIS_CurrentState < MSTATE_READY) exitWith {true};
	if (NWG_MIS_CurrentState == MSTATE_VOTING) exitWith {true};
	false
};
NWG_TUTDLG_COMM_WarnDeveloper = {
	(format ["NWG_TUTDLG_COMM_WarnDeveloper: Invalid mission state: '%1'",NWG_MIS_CurrentState]) call NWG_fnc_logError;
};

NWG_TUTDLG_COMM_LevelUnlocked = {
	(call NWG_fnc_mmGetUnlockedLevels) param [0,false];
};
NWG_TUTDLG_COMM_GetLevelUnlockPrice = {
	private _unlockPrices = NWG_DLG_COMM_Settings get "UNLOCK_PRICES";
	private _price = _unlockPrices param [0,0];
	(_price call NWG_fnc_wltFormatMoney)
};

NWG_TUTDLG_COMM_OpenMissionSelect = {
	[] spawn {
		//Unlock level if needed (using dialogue module helper)
		if !(call NWG_TUTDLG_COMM_LevelUnlocked) then {
			NWG_DLG_COMM_selectedLevel = 0;
			call NWG_DLG_COMM_UnlockLevel;
		};

		//Wait until level is unlocked (client->server->client(s) communication)
		private _timeoutAt = time + 10;
		waitUntil {
			sleep 0.1;
			if (call NWG_TUTDLG_COMM_LevelUnlocked) exitWith {true};
			if (time > _timeoutAt) exitWith {true};
			false
		};
		if (time > _timeoutAt) exitWith {
			"NWG_TUTDLG_COMM_OpenMissionSelect: timeout" call NWG_fnc_logError;
			false
		};

		//Open mission selection
		0 call NWG_fnc_mmOpenMissionSelection;

		//Show hint
		hint ("#COMM_TUTOR04_MAP_HINT#" call NWG_fnc_localize);

		//Wait for map to be closed
		addMissionEventHandler ["Map", {
			params ["_mapIsOpened", "_mapIsForced"];
			if (!_mapIsOpened) then {
				hintSilent "";//Clear hint
				call NWG_TUT_NextStep;
				removeMissionEventHandler ["Map",_thisEventHandler];
			};
		}];
	};
};

//================================================================================================================
//================================================================================================================
//STEP_05 Taxi. Discord and Paradrop
#define MAX_PARADROP_SAFENET 4

NWG_TUTDLG_TAXI_OpenDiscord = {
	hint ("#TAXI_DISCORD_HINT#" call NWG_fnc_localize);
	call NWG_UP_03Group_Discord_Open;//Use of inner method from 'userPlanshet' subsystem
};

NWG_TUTDLG_TAXI_HasMoneyForPara = {
	(player call NWG_fnc_wltGetPlayerMoney) >= (NWG_DLG_TAXI_Settings get "PRICE_AIR_RAW")//Use of inner method from 'dialogueSystem' subsystem
};
NWG_TUTDLG_TAXI_GetParaPriceStr = {
	(NWG_DLG_TAXI_Settings get "PRICE_AIR_RAW") call NWG_fnc_wltFormatMoney
};
NWG_TUTDLG_TAXI_PayForPara = {
	private _price = NWG_DLG_TAXI_Settings get "PRICE_AIR_RAW";
	[player,-_price] call NWG_fnc_wltAddPlayerMoney;
};

#define TIP_PRICE 500
NWG_TUTDLG_TAXI_GetTipPriceStr = {
	(TIP_PRICE) call NWG_fnc_wltFormatMoney
};
NWG_TUTDLG_TAXI_PayTip = {
	[player,-TIP_PRICE] call NWG_fnc_wltAddPlayerMoney;
};

NWG_TUTDLG_TAXI_Paradrop = {
	//Force open map
	if ( (((getUnitLoadout player) param [9,[]]) param [0,""]) isEqualTo "")
		then {player addItem "ItemMap"; player assignItem "ItemMap"};
	openMap [true,true];

	//Show map hint
	hint ("#TAXI_PARA_MAP_HINT#" call NWG_fnc_localize);

	//Handle map click (wrap checking for map click to be in mission area around normal paradrop)
	localNamespace setVariable ["NWG_TUTDLG_TAXI_Paradrop_safenet",MAX_PARADROP_SAFENET];
	addMissionEventHandler ["MapSingleClick",{
		// params ["_units","_pos","_alt","_shift"];
		private _pos = _this select 1;
		private _safenet = localNamespace getVariable ["NWG_TUTDLG_TAXI_Paradrop_safenet",MAX_PARADROP_SAFENET];
		_safenet = _safenet - 1;
		localNamespace setVariable ["NWG_TUTDLG_TAXI_Paradrop_safenet",_safenet];
		switch (true) do {
			case (_safenet <= 0): {
				/*Safenet limit reached - let them jump wherever if they want it so much (Also serves as a fix for any unexpected cases)*/
				/*Show 'whatever' hint*/
				private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOC_NPC_NAME") getOrDefault [NPC_TAXI,""]) call NWG_fnc_localize;
				private _messageLoc = ("#TAXI_PARA_MAP_HINT_MAX_ATTEMPTS#" call NWG_fnc_localize);
				[_npcNameLoc,_messageLoc] call BIS_fnc_showSubtitle;
				/*Jump as usual*/
				hint ("#TAXI_PARA_AIR_HINT#" call NWG_fnc_localize);//Show air hint
				NWG_DLG_TAXI_mapClickExpected = true;//Raise expected flag
				_this call NWG_DLG_TAXI_OnMapClick;//Use of inner method from 'dialogueSystem' subsystem
				call NWG_TUT_NextStep;//Finish the tutorial
				removeMissionEventHandler ["MapSingleClick",_thisEventHandler];//Remove this event handler
			};
			case (isNil "NWG_AI_MissionPos" || {!(NWG_AI_MissionPos isEqualType [])}): {
				/*Mission pos is not set - show hint*/
				private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOC_NPC_NAME") getOrDefault [NPC_TAXI,""]) call NWG_fnc_localize;
				private _messageLoc = ("#TAXI_PARA_MAP_HINT_MIS_NOT_SET#" call NWG_fnc_localize);
				hint _messageLoc;
				[_npcNameLoc,_messageLoc] call BIS_fnc_showSubtitle;
			};
			case ((_pos distance2D (NWG_AI_MissionPos param [0,[0,0,0]])) > 750): {
				/*Too far from mission pos - show hint*/
				private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOC_NPC_NAME") getOrDefault [NPC_TAXI,""]) call NWG_fnc_localize;
				private _messageLoc = ("#TAXI_PARA_MAP_HINT_TOO_FAR#" call NWG_fnc_localize);
				hint _messageLoc;
				[_npcNameLoc,_messageLoc] call BIS_fnc_showSubtitle;
			};
			default {
				/*Mission pos is set and click is close enough - jump*/
				["",""] call BIS_fnc_showSubtitle;//Clear subtitle
				hint ("#TAXI_PARA_AIR_HINT#" call NWG_fnc_localize);//Show air hint
				NWG_DLG_TAXI_mapClickExpected = true;//Raise expected flag
				_this call NWG_DLG_TAXI_OnMapClick;//Use of inner method from 'dialogueSystem' subsystem
				call NWG_TUT_NextStep;//Finish the tutorial
				removeMissionEventHandler ["MapSingleClick",_thisEventHandler];//Remove this event handler
			};
		};
	}];
};
