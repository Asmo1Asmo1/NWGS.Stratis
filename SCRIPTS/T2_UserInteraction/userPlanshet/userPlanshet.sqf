//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetBackground
#define IDC_PLANSHET_BACKGROUND 7102
#define BACKGROUND_DIALOGUE_NAME "planshetBackground"


//================================================================================================================
//================================================================================================================
//Settings
NWG_UP_Settings = createHashMapFromArray [
	["BUTTON_MOBLSHOP_ICON","\A3\ui_f_orange\data\cfgTaskTypes\airdrop_ca.paa"],
	["BUTTON_MTRANSFR_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa"],
	["BUTTON_GROUPMNG_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"],
	["BUTTON_DOCUMNTS_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa"],
	["BUTTON_PLR_INFO_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa"],
	["BUTTON_SETTINGS_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Background
NWG_UP_OpenBackground = {
	disableSerialization;

	private _backgroundGUI = createDialog [BACKGROUND_DIALOGUE_NAME,true];
	if (isNull _backgroundGUI) exitWith {
		"NWG_UP_OpenBackground: Failed to create dialog" call NWG_fnc_logError;
		false
	};

	//return
	_backgroundGUI
};

//================================================================================================================
//================================================================================================================
//Top panel utils
NWG_UP_GetPlayerMoneyString = {
	(player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney
};

NWG_UP_GetPlayerInfoString = {
	name player
};

//================================================================================================================
//================================================================================================================
//Main menu
NWG_UP_OpenMainMenu = {
	disableSerialization;

	//Open background
	private _backgroundGUI = call NWG_UP_OpenBackground;
	if (_backgroundGUI isEqualTo false) exitWith {
		"NWG_UP_OpenMainMenu: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add controls
	private _playerMoneyText = _backgroundGUI ctrlCreate ["UPMM_PlayerMoneyText",-1];
	private _playerInfoText = _backgroundGUI ctrlCreate ["UPMM_PlayerInfoText",-1];

	private _buttonMobileShop      = _backgroundGUI ctrlCreate ["UPMM_MobileShopButton",-1];
	private _buttonMoneyTransfer   = _backgroundGUI ctrlCreate ["UPMM_MoneyTransferButton",-1];
	private _buttonGroupManagement = _backgroundGUI ctrlCreate ["UPMM_GroupManagementButton",-1];
	private _buttonDocuments       = _backgroundGUI ctrlCreate ["UPMM_DocumentsButton",-1];
	private _buttonPlayerInfo      = _backgroundGUI ctrlCreate ["UPMM_InfoButton",-1];
	private _buttonSettings        = _backgroundGUI ctrlCreate ["UPMM_SettingsButton",-1];

	//Top panel: Add text
	_playerMoneyText ctrlSetText (call NWG_UP_GetPlayerMoneyString);
	_playerInfoText ctrlSetText (call NWG_UP_GetPlayerInfoString);

	//Buttons: Add pictures
	_buttonMobileShop      ctrlSetText (NWG_UP_Settings get "BUTTON_MOBLSHOP_ICON");
	_buttonMoneyTransfer   ctrlSetText (NWG_UP_Settings get "BUTTON_MTRANSFR_ICON");
	_buttonGroupManagement ctrlSetText (NWG_UP_Settings get "BUTTON_GROUPMNG_ICON");
	_buttonDocuments       ctrlSetText (NWG_UP_Settings get "BUTTON_DOCUMNTS_ICON");
	_buttonPlayerInfo      ctrlSetText (NWG_UP_Settings get "BUTTON_PLR_INFO_ICON");
	_buttonSettings        ctrlSetText (NWG_UP_Settings get "BUTTON_SETTINGS_ICON");

	//Buttons: Add tooltips
	_buttonMobileShop      ctrlSetTooltip ("#UP_BUTTON_MOBLSHOP_TOOLTIP#" call NWG_fnc_localize);
	_buttonMoneyTransfer   ctrlSetTooltip ("#UP_BUTTON_MTRANSFR_TOOLTIP#" call NWG_fnc_localize);
	_buttonGroupManagement ctrlSetTooltip ("#UP_BUTTON_GROUPMNG_TOOLTIP#" call NWG_fnc_localize);
	_buttonDocuments       ctrlSetTooltip ("#UP_BUTTON_DOCUMNTS_TOOLTIP#" call NWG_fnc_localize);
	_buttonPlayerInfo      ctrlSetTooltip ("#UP_BUTTON_PLR_INFO_TOOLTIP#" call NWG_fnc_localize);
	_buttonSettings        ctrlSetTooltip ("#UP_BUTTON_SETTINGS_TOOLTIP#" call NWG_fnc_localize);

	//Buttons: Add click handlers
	_buttonMobileShop ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Mobile shop: Will be added later...";
	}];
	_buttonMoneyTransfer ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Money transfer: Will be added later...";
	}];
	_buttonGroupManagement ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Group management: Will be added later...";
	}];
	_buttonDocuments ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Documents: Will be added later...";
	}];
	_buttonPlayerInfo ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Player info: Will be added later...";
	}];
	_buttonSettings ctrlAddEventHandler ["ButtonClick",{
		//TODO
		systemChat "Settings: Will be added later...";
	}];

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Secondary menu
NWG_UP_OpenSecondaryMenu = {
	disableSerialization;

	private _backgroundGUI = call NWG_UP_OpenBackground;
	if (_backgroundGUI isEqualTo false) exitWith {
		"NWG_UP_OpenSecondaryMenu: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add controls
	private _playerMoneyText = _backgroundGUI ctrlCreate ["UPSM_PlayerMoneyText",-1];
	private _playerInfoText = _backgroundGUI ctrlCreate ["UPSM_PlayerInfoText",-1];
	private _listBox = _backgroundGUI ctrlCreate ["UPSM_ListBox",-1];

	//Top panel: Add text
	_playerMoneyText ctrlSetText (call NWG_UP_GetPlayerMoneyString);
	_playerInfoText  ctrlSetText (call NWG_UP_GetPlayerInfoString);

	//return
	[_backgroundGUI,_listBox]
};

//================================================================================================================
//================================================================================================================
//Vehicles shop
NWG_UP_OpenVehiclesShop = {
	disableSerialization;

	//Open background
	private _backgroundGUI = call NWG_UP_OpenBackground;
	if (_backgroundGUI isEqualTo false) exitWith {
		"NWG_UP_OpenVehiclesShop: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add controls
	private _playerMoneyText = _backgroundGUI ctrlCreate ["UPVS_PlayerMoneyText",-1];
	private _shopDropdown = _backgroundGUI ctrlCreate ["UPVS_ShopDropdown",-1];
	private _shopList = _backgroundGUI ctrlCreate ["UPVS_ShopList",-1];

	//return
	[_backgroundGUI,_shopList]
};