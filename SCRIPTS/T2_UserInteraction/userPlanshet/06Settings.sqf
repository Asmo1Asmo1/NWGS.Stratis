//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
#define IDC_LISTBOX	1501
// #define IDC_DROPDOWN 2101

#define KEY_ESC 1
#define KEY_DELETE 211
#define KEY_BACKSPACE 14
#define KEY_TAB 15

/*enum*/
#define SETTINGS_KEYBINDINGS "KEYBINDINGS"

//================================================================================================================
//================================================================================================================
//Settings
NWG_UP_06Settings_Settings = createHashMapFromArray [
	["WINDOW_NAME","#UP_SETTINGS_TITLE#"],
	["PLANSHET_ROWS",[
		["#UP_SETTINGS_KEYBINDINGS#",SETTINGS_KEYBINDINGS]
	]],

	["KB_EXPR_TEMPLATE",'"%1"    %2'],//where %1 is the expression, %2 is ON/OFF bypass indicator
	["KB_BYPASS_OFF","[-X]"],
	["KB_BYPASS_ON", "[->]"],
	["KB_HINTS",[
		"#UP_SETTINGS_KEYBINDINGS_HINT_1#",
		"#UP_SETTINGS_KEYBINDINGS_HINT_2#",
		"#UP_SETTINGS_KEYBINDINGS_HINT_3#",
		"#UP_SETTINGS_KEYBINDINGS_HINT_4#"
	]],
	["KB_KEY_DELETE",KEY_DELETE],
	["KB_KEY_DELETE_ALT",KEY_BACKSPACE],
	["KB_KEY_TOGGLE_BYPASS",KEY_TAB],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Category
NWG_UP_06Settings_Open = {
	disableSerialization;

	//Prepare items, data and callback
	private _windowName = NWG_UP_06Settings_Settings get "WINDOW_NAME";
	private _planshetRows = NWG_UP_06Settings_Settings get "PLANSHET_ROWS";
	private _items = _planshetRows apply {(_x select 0) call NWG_fnc_localize};
	private _data =  _planshetRows apply {_x select 1};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _settingName = _listBox lbData _selectedIndex;
		switch (_settingName) do {
			case SETTINGS_KEYBINDINGS: {call NWG_UP_06Settings_Keybindings_Open};
			default {(format ["NWG_UP_06Settings_OnRowSelected: Unknown setting: '%1'",_settingName]) call NWG_fnc_logError};
		};
	};

	//Open interface
	private _interface = [_windowName,_items,_data,_callback] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_06Settings_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	true
};

//================================================================================================================
//================================================================================================================
//Subcategories : Keybindings
NWG_UP_06Settings_Keybindings_selectedKB = -1;
NWG_UP_06Settings_Keybindings_hintsDisplayed = false;
NWG_UP_06Settings_Keybindings_Open = {
	disableSerialization;

	//Prepare interface open
	NWG_UP_06Settings_Keybindings_selectedKB = -1;
	NWG_UP_06Settings_Keybindings_hintsDisplayed = false;
	private _planshetRows = NWG_UP_06Settings_Settings get "PLANSHET_ROWS";
	private _windowName = (_planshetRows param [(_planshetRows findIf {(_x#1) isEqualTo SETTINGS_KEYBINDINGS}),[]]) param [0,""];
	private _callback = {
		params ["_listBox","_selectedIndex","_withTitleRow"];
		NWG_UP_06Settings_Keybindings_selectedKB = if (_withTitleRow)
			then {_selectedIndex - 1}
			else {_selectedIndex};
		if (!NWG_UP_06Settings_Keybindings_hintsDisplayed) then {
			private _hints = NWG_UP_06Settings_Settings get "KB_HINTS";
			{_x call NWG_fnc_systemChatMe} forEach _hints;
			_hints = _hints apply {_x call NWG_fnc_localize};
			hint (_hints joinString "\n");
			NWG_UP_06Settings_Keybindings_hintsDisplayed = true;
		};
	};

	//Open interface
	private _interface = [_windowName,nil,nil,_callback] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_06Settings_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	//Get listbox
	private _listBox = _interface displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {
		"NWG_UP_06Settings_Open: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Fill listbox
	for "_i" from 1 to (count (call NWG_fnc_kbGetAllKeybindings)) do {_listBox lbAdd ""};
	_listBox call NWG_UP_06Settings_Keybindings_FillKeybindings;

	//Setup key handler for changing keybindings
	(ctrlParent _listBox) displayAddEventHandler ["KeyDown", {
		// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
		_this call NWG_UP_06Settings_Keybindings_OnKeyDown;
		(_this#1) != KEY_ESC//Always intercept any key except ESC
	}];

	true
};

NWG_UP_06Settings_Keybindings_FillKeybindings = {
	private _listBox = _this;
	private _withTitleRow = NWG_UP_Settings get "SM_ADD_CLOSING_TITLE_ROW_TO_LIST";
	private _keybindings = call NWG_fnc_kbGetAllKeybindings;
	private _exprTemplate = NWG_UP_06Settings_Settings get "KB_EXPR_TEMPLATE";
	{
		// params ["_key","_expression","_locDescr","_code","_blockKeyDown"];
		_x params ["","_expression","_name","","_blockKeyDown"];
		private _index = if (_withTitleRow) then {_forEachIndex + 1} else {_forEachIndex};

		//Fill left half of the row
		_name = _name call NWG_fnc_localize;
		_listBox lbSetText [_index,_name];

		//Fill right half of the row
		if (_expression isEqualTo "") then {
			_listBox lbSetTextRight [_index,""];
			continue;
		};
		private _blockIndicator = if (_blockKeyDown)
			then {NWG_UP_06Settings_Settings get "KB_BYPASS_OFF"}
			else {NWG_UP_06Settings_Settings get "KB_BYPASS_ON"};
		private _rightText = format [_exprTemplate,_expression,_blockIndicator];
		_listBox lbSetTextRight [_index,_rightText];
	} forEach _keybindings;
};

NWG_UP_06Settings_Keybindings_OnKeyDown = {
	params ["_display","_key","_shift","_ctrl","_alt"];

	//Get listbox
	private _listBox = _display displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {};

	/*Fix for 'space' key*/
	/*Arma seems to have hardcoded 'space' key handler 'jump to the start of the list' that works BEFORE this handler*/
	if (_key == 57) then {
		private _selected = NWG_UP_06Settings_Keybindings_selectedKB;
		if (NWG_UP_Settings get "SM_ADD_CLOSING_TITLE_ROW_TO_LIST") then {_selected = _selected + 1};
		_listBox lbSetCurSel _selected;
	};

	//Get selected keybinding index
	if (NWG_UP_06Settings_Keybindings_selectedKB == -1) exitWith {};//No row selected
	private _curSel = lbCurSel _listBox;
	if (NWG_UP_Settings get "SM_ADD_CLOSING_TITLE_ROW_TO_LIST") then {_curSel = _curSel - 1};
	if (NWG_UP_06Settings_Keybindings_selectedKB != _curSel) exitWith {};//Player changed row but did not double click on it
	private _kbIndex = NWG_UP_06Settings_Keybindings_selectedKB;

	//Update keybinding
	private _update = switch (true) do {
		case (_key == (NWG_UP_06Settings_Settings get "KB_KEY_DELETE")): {
			_kbIndex call NWG_fnc_kbDropKeybinding
		};
		case (_key == (NWG_UP_06Settings_Settings get "KB_KEY_DELETE_ALT")): {
			_kbIndex call NWG_fnc_kbDropKeybinding
		};
		case (_key == (NWG_UP_06Settings_Settings get "KB_KEY_TOGGLE_BYPASS")): {
			_kbIndex call NWG_fnc_kbToggleKeybindingKeyDownBlock
		};
		case (_key call NWG_fnc_kbIsKeySupported): {
			[_kbIndex,_key,_shift,_ctrl,_alt] call NWG_fnc_kbUpdateKeybinding
		};
		default {false};
	};
	if (!_update) exitWith {};

	//Update UI
	_listBox call NWG_UP_06Settings_Keybindings_FillKeybindings;
};
