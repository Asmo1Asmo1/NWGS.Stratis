//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetBackground
// #define IDC_PLANSHET_BACKGROUND 7102
#define BACKGROUND_DIALOGUE_NAME "planshetBackground"

//--- userPlanshetMainMenu
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001

// #define IDC_BUTTON_01 1200
// #define IDC_BUTTON_02 1201
// #define IDC_BUTTON_03 1202
// #define IDC_BUTTON_04 1203
// #define IDC_BUTTON_05 1204
// #define IDC_BUTTON_06 1205

//--- userPlanshetUIBase
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_LISTBOX	1501


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
	["SM_ADD_CLOSING_TITLE_TO_LIST",true],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Background and window management
#define WINDOW_OBJ 0
#define WINDOW_NAME 1
#define EMPTY_NAME false

NWG_UP_OpenWindow = {
	private _windowName = _this;
	disableSerialization;

	private _planshetGUI = createDialog [BACKGROUND_DIALOGUE_NAME,true];
	if (isNull _planshetGUI) exitWith {
		"NWG_UP_OpenWindow: Failed to create dialog" call NWG_fnc_logError;
		false
	};

	private _curWindows = uiNamespace getVariable ["NWG_UP_Windows",[]];
	_curWindows pushBack [_planshetGUI,_windowName];
	uiNamespace setVariable ["NWG_UP_Windows",_curWindows];

	_planshetGUI addEventHandler ["Unload",{
		private _curWindows = uiNamespace getVariable ["NWG_UP_Windows",[]];
		if ((count _curWindows) > 0) then {
			_curWindows deleteAt ((count _curWindows) - 1);
			uiNamespace setVariable ["NWG_UP_Windows",_curWindows];
		};
	}];

	//return
	_planshetGUI
};

NWG_UP_GetAllWindowNames = {
	disableSerialization;
	((uiNamespace getVariable ["NWG_UP_Windows",[]]) apply {_x select WINDOW_NAME}) select {_x isEqualType ""}
};

NWG_UP_CloseAllWindows = {
	disableSerialization;
	private _curWindows = uiNamespace getVariable ["NWG_UP_Windows",[]];
	uiNamespace setVariable ["NWG_UP_Windows",[]];
	{(_x select WINDOW_OBJ) closeDisplay 2} forEachReversed _curWindows;
	_curWindows resize 0;
};

//================================================================================================================
//================================================================================================================
//Main menu
NWG_UP_OpenMainMenu = {
	disableSerialization;

	//Open background
	private _planshetGUI = EMPTY_NAME call NWG_UP_OpenWindow;
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
	private _windowName = _this;
	disableSerialization;

	private _planshetGUI = _windowName call NWG_UP_OpenWindow;
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

	//Add 'Window title'+'Close window' at the same time in form of the first line of the listbox
	if (NWG_UP_Settings get "SM_ADD_CLOSING_TITLE_TO_LIST") then {
		private _windowNames = (call NWG_UP_GetAllWindowNames) apply {_x call NWG_fnc_localize};
		_windowNames = [""] + _windowNames + [""];//Add empty entries at the beginning and at the end for the looks
		private _topLine = _windowNames joinString " > ";
		_listBox lbAdd _topLine;
		_listBox ctrlAddEventHandler ["LBDblClick",{
			params ["_listBox","_selectedIndex"];
			if (_selectedIndex == 0)
				then {(ctrlParent  _listBox) closeDisplay 2};
		}];
	};

	//return
	_planshetGUI
};

//================================================================================================================
//================================================================================================================
//Secondary with dropdown (combination of planshet UI and shopUI so does not support window names)
NWG_UP_OpenSecondaryWithDropdown = {
	disableSerialization;

	//Open background
	private _planshetGUI = EMPTY_NAME call NWG_UP_OpenWindow;
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