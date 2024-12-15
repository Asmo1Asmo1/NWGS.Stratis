//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
#define IDC_LISTBOX	1501

//================================================================================================================
//================================================================================================================
//Settings
NWG_MT_Settings = createHashMapFromArray [
	/*Localization keys*/
	["LOC_ACTION_TITLE","#MT_ACTION_TITLE#"],
	["LOC_PLAYER_NOT_FOUND","#MT_PLAYER_NOT_FOUND#"],

	/*List settings*/
	["TITLE_ROW_EXPECTED",true],

	/*External functions*/
	["FUNC_OPEN_INTERFACE", {_this call NWG_fnc_upOpenSecondaryMenu}], //params: _windowName, returns: _interface
	["FUNC_GET_ALL_INTERFACES", {call NWG_fnc_upGetAllMenus}], //returns: array of opened menus

	/*Money transfer*/
	["TRANSFER_MONEY_AMOUNTS",[1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000]],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Money transfer
NWG_MT_selectedPlayer = "";

NWG_MT_OpenTransferUI = {
	disableSerialization;

	//Open interface
	private _windowName = NWG_MT_Settings get "LOC_ACTION_TITLE";
	private _interface = _windowName call (NWG_MT_Settings get "FUNC_OPEN_INTERFACE");
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_MT_OpenTransferUI: Failed to open interface" call NWG_fnc_logError;
		false
	};

	//Fill player money
	private _ok = [_interface,IDC_TEXT_LEFT] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
	if (!_ok) exitWith {
		"NWG_MT_OpenTransferUI: Failed to fill player money text" call NWG_fnc_logError;
		false
	};

	//Get listbox
	private _listBox = _interface displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {
		"NWG_MT_OpenTransferUI: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Fill listbox
	private _players = (call NWG_fnc_getPlayersAll) select {alive _x};
	private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
	if (!_isDevBuild) then {
		_players = _players - [player];
	};

	private ["_name","_index"];
	{
		_name = name _x;
		_index = _listBox lbAdd _name;
		_listBox lbSetData [_index,_name];
	} forEach _players;

	//Setup event handlers
	_listBox ctrlAddEventHandler ["LBDblClick",{
		params ["_listBox","_selectedIndex"];
		private _withTitleRow = NWG_MT_Settings get "TITLE_ROW_EXPECTED";
		private _expected = if (_withTitleRow) then {1} else {0};
		if (_selectedIndex >= _expected) then {
			private _name = _listBox lbData _selectedIndex;
			private _gui = ctrlParent _listBox;
			[_name,_gui] call NWG_MT_OnPlayerSelected;
		};
	}];

	//return
	true
};

NWG_MT_OnPlayerSelected = {
	disableSerialization;
	params ["_name","_gui"];

	//Check target player online
	private _players = (call NWG_fnc_getPlayersAll) select {alive _x};
	private _index = _players findIf {(name _x) isEqualTo _name};
	if (_index == -1) exitWith {
		[_gui,IDC_TEXT_LEFT] call NWG_fnc_uiHelperBlinkOnError;
		private _message = (NWG_MT_Settings get "LOC_PLAYER_NOT_FOUND") call NWG_fnc_localize;
		systemChat _message;
		hint _message;
		false
	};

	//Save for later use
	NWG_MT_selectedPlayer = _name;

	//Open interface
	private _interface = _name call (NWG_MT_Settings get "FUNC_OPEN_INTERFACE");
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_MT_OnPlayerSelected: Failed to open interface" call NWG_fnc_logError;
		false
	};

	//Fill player money
	private _ok = [_interface,IDC_TEXT_LEFT] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
	if (!_ok) exitWith {
		"NWG_MT_OnPlayerSelected: Failed to fill target player money text" call NWG_fnc_logError;
		false
	};

	//Get listbox
	private _listBox = _interface displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {
		"NWG_MT_OnPlayerSelected: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Fill listbox
	private _amounts = NWG_MT_Settings get "TRANSFER_MONEY_AMOUNTS";
	{
		private _index = _listBox lbAdd (_x call NWG_fnc_wltFormatMoney);
		_listBox lbSetData [_index,(str _x)];
	} forEach _amounts;

	//Setup event handlers
	_listBox ctrlAddEventHandler ["LBDblClick",{
		params ["_listBox","_selectedIndex"];
		private _withTitleRow = NWG_MT_Settings get "TITLE_ROW_EXPECTED";
		private _expected = if (_withTitleRow) then {1} else {0};
		if (_selectedIndex >= _expected) then {
			private _amount = _listBox lbData _selectedIndex;
			private _gui = ctrlParent _listBox;
			[_amount,_gui] call NWG_MT_OnAmountSelected;
		};
	}];

	//return
	true
};

NWG_MT_OnAmountSelected = {
	disableSerialization;
	params ["_amount","_gui"];
	_amount = parseNumber _amount;

	//Load selected player
	private _targetName = NWG_MT_selectedPlayer;
	if (_targetName isEqualTo "") exitWith {
		"NWG_MT_OnAmountSelected: Target player is not selected" call NWG_fnc_logError;
		false
	};

	//Check target player online
	private _players = (call NWG_fnc_getPlayersAll) select {alive _x};
	private _index = _players findIf {(name _x) isEqualTo _targetName};
	if (_index == -1) exitWith {
		[_gui,IDC_TEXT_LEFT] call NWG_fnc_uiHelperBlinkOnError;
		private _message = (NWG_MT_Settings get "LOC_PLAYER_NOT_FOUND") call NWG_fnc_localize;
		systemChat _message;
		hint _message;
		false
	};
	private _targetPlayer = _players#_index;

	//Check has enough money
	private _playerMoney = player call NWG_fnc_wltGetPlayerMoney;
	if (_playerMoney < _amount) exitWith {
		[_gui,IDC_TEXT_LEFT] call NWG_fnc_uiHelperBlinkOnError;
		false
	};

	//Transfer money
	[player,-_amount] call NWG_fnc_wltAddPlayerMoney;
	[_targetPlayer,_amount] call NWG_fnc_wltAddPlayerMoney;

	//Update UI
	[_gui,IDC_TEXT_LEFT] call NWG_fnc_uiHelperBlinkOnSuccess;
	private _allWindows = call NWG_fnc_upGetAllMenus;
	{
		[_x,IDC_TEXT_LEFT] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
	} forEach _allWindows;

	//return
	true
};
