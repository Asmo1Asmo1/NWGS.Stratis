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
	/*Main menu layout*/
	["MM_TextLeft_FILL_FUNC", {(player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney}],
	["MM_TextRight_FILL_FUNC",{name player}],

	["MM_BUTTON_01_ICON","\A3\ui_f_orange\data\cfgTaskTypes\airdrop_ca.paa"],
	["MM_BUTTON_02_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa"],
	["MM_BUTTON_03_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"],
	["MM_BUTTON_04_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa"],
	["MM_BUTTON_05_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa"],
	["MM_BUTTON_06_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"],

	["MM_BUTTON_01_TOOLTIP","#UP_BUTTON_MOBLSHOP_TOOLTIP#"],
	["MM_BUTTON_02_TOOLTIP","#UP_BUTTON_MTRANSFR_TOOLTIP#"],
	["MM_BUTTON_03_TOOLTIP","#UP_BUTTON_GROUPMNG_TOOLTIP#"],
	["MM_BUTTON_04_TOOLTIP","#UP_BUTTON_DOCUMNTS_TOOLTIP#"],
	["MM_BUTTON_05_TOOLTIP","#UP_BUTTON_PLR_INFO_TOOLTIP#"],
	["MM_BUTTON_06_TOOLTIP","#UP_BUTTON_SETTINGS_TOOLTIP#"],

	["MM_BUTTON_01_ONCLICK",{systemChat "Not implemented"}],
	["MM_BUTTON_02_ONCLICK",{systemChat "Not implemented"}],
	["MM_BUTTON_03_ONCLICK",{systemChat "Not implemented"}],
	["MM_BUTTON_04_ONCLICK",{systemChat "Not implemented"}],
	["MM_BUTTON_05_ONCLICK",{systemChat "Not implemented"}],
	["MM_BUTTON_06_ONCLICK",{systemChat "Not implemented"}],

	/*Secondary menu layout*/
	["SM_TextLeft_FILL_FUNC", {(player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney}],
	["SM_TextRight_FILL_FUNC",{name player}],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Background
NWG_UP_OpenBackground = {
	disableSerialization;

	private _planshetGUI = createDialog [BACKGROUND_DIALOGUE_NAME,true];
	if (isNull _planshetGUI) exitWith {
		"NWG_UP_OpenBackground: Failed to create dialog" call NWG_fnc_logError;
		false
	};

	//return
	_planshetGUI
};

//================================================================================================================
//================================================================================================================
//Main menu
NWG_UP_OpenMainMenu = {
	disableSerialization;

	//Open background
	private _planshetGUI = call NWG_UP_OpenBackground;
	if (_planshetGUI isEqualTo false) exitWith {
		"NWG_UP_OpenMainMenu: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add top panel texts
	{
		private _ctrlName = format ["UPMM_%1",_x];
		private _textFunc = format ["MM_%1_FILL_FUNC",_x];

		_textFunc = NWG_UP_Settings get _textFunc;

		private _textCtrl = _planshetGUI ctrlCreate [_ctrlName,-1];
		_textCtrl ctrlSetText (call _textFunc);
	} forEach ["TextLeft","TextRight"];

	//Add central buttons
	{
		private _ctrlName = format ["UPMM_Button0%1",_x];
		private _icon     = format ["MM_BUTTON_0%1_ICON",_x];
		private _tooltip  = format ["MM_BUTTON_0%1_TOOLTIP",_x];
		private _onClick  = format ["MM_BUTTON_0%1_ONCLICK",_x];

		_icon    = NWG_UP_Settings get _icon;
		_tooltip = NWG_UP_Settings get _tooltip;
		_onClick = NWG_UP_Settings get _onClick;

		private _buttonCtrl = _planshetGUI ctrlCreate [_ctrlName,-1];
		_buttonCtrl ctrlSetText _icon;
		_buttonCtrl ctrlSetTooltip (_tooltip call NWG_fnc_localize);
		_buttonCtrl ctrlAddEventHandler ["ButtonClick",_onClick];
	} forEach [1,2,3,4,5,6];

	//return
	_planshetGUI
};

//================================================================================================================
//================================================================================================================
//Secondary menu
NWG_UP_OpenSecondaryMenu = {
	disableSerialization;

	private _planshetGUI = call NWG_UP_OpenBackground;
	if (_planshetGUI isEqualTo false) exitWith {
		"NWG_UP_OpenSecondaryMenu: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add top panel texts
	{
		private _ctrlName = format ["UPSM_%1",_x];
		private _textFunc = format ["SM_%1_FILL_FUNC",_x];

		_textFunc = NWG_UP_Settings get _textFunc;

		private _textCtrl = _planshetGUI ctrlCreate [_ctrlName,-1];
		_textCtrl ctrlSetText (call _textFunc);
	} forEach ["TextLeft","TextRight"];

	//Add listbox in the middle
	private _listBox = _planshetGUI ctrlCreate ["UPSM_ListBox",-1];

	//return
	_planshetGUI
};

//================================================================================================================
//================================================================================================================
//Secondary with dropdown
NWG_UP_OpenSecondaryWithDropdown = {
	disableSerialization;

	//Open background
	private _planshetGUI = call NWG_UP_OpenBackground;
	if (_planshetGUI isEqualTo false) exitWith {
		"NWG_UP_OpenSecondaryWithDropdown: Failed to open background" call NWG_fnc_logError;
		false
	};

	//Add controls
	_planshetGUI ctrlCreate ["UPSWD_TextLeft",-1];
	_planshetGUI ctrlCreate ["UPSWD_Dropdown",-1];
	_planshetGUI ctrlCreate ["UPSWD_ListBox",-1];

	//return
	_planshetGUI
};