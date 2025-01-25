//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_LISTBOX	1501

//================================================================================================================
//================================================================================================================
//Settings
NWG_MT_Settings = createHashMapFromArray [
	/*Localization keys*/
	["LOC_ACTION_TITLE","#MT_ACTION_TITLE#"],
	["LOC_PLAYER_NOT_FOUND","#MT_PLAYER_NOT_FOUND#"],

	/*External functions*/
	["FUNC_OPEN_INTERFACE", {_this call NWG_fnc_upOpenSecondaryMenuPrefilled}], //params ["_windowName",["_items",[]],["_data",[]],["_callback",{}]]; | returns: _interface
	["FUNC_GET_ALL_INTERFACES", {call NWG_fnc_upGetAllMenus}], //returns: array of opened menus

	/*Money transfer*/
	["TRANSFER_MONEY_AMOUNTS",[1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000]],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MT_selectedPlayer = "";

//================================================================================================================
//================================================================================================================
//Money transfer
NWG_MT_OpenTransferUI = {
	disableSerialization;

	//Prepare items, data and callback
	private _windowName = NWG_MT_Settings get "LOC_ACTION_TITLE";
	private _playerNames = call {
		private _players = call NWG_fnc_getPlayersAll;
		private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
		if (!_isDevBuild) then {_players = _players - [player]};
		_players apply {name _x}
	};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _name = _listBox lbData _selectedIndex;
		private _gui = ctrlParent _listBox;
		[_name,_gui] call NWG_MT_OnPlayerSelected;
	};

	//Open interface
	private _interface = [_windowName,_playerNames,_playerNames,_callback] call (NWG_MT_Settings get "FUNC_OPEN_INTERFACE");
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

	//return
	true
};

NWG_MT_OnPlayerSelected = {
	disableSerialization;
	params ["_name","_gui"];

	//Check if target player is online
	private _players = call NWG_fnc_getPlayersAll;
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

	//Prepare items, data and callback
	private _windowName = _name;
	private _amounts = (NWG_MT_Settings get "TRANSFER_MONEY_AMOUNTS");
	private _items = _amounts apply {_x call NWG_fnc_wltFormatMoney};
	private _data = _amounts apply {str _x};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _amount = _listBox lbData _selectedIndex;
		private _gui = ctrlParent _listBox;
		[_amount,_gui] call NWG_MT_OnAmountSelected;
	};

	//Open interface
	private _interface = [_windowName,_items,_data,_callback] call (NWG_MT_Settings get "FUNC_OPEN_INTERFACE");
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
	private _players = call NWG_fnc_getPlayersAll;
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
	private _allWindows = call (NWG_MT_Settings get "FUNC_GET_ALL_INTERFACES");
	{
		[_x,IDC_TEXT_LEFT] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
	} forEach _allWindows;

	//return
	true
};
