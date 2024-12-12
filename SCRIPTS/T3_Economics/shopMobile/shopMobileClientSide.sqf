/*
	Mobile shop
	This is the only shop where we know items roster at compile time
	And thus can minimize network traffic between server and client
	On client:
	- We have pre-defined number of categories and can display list of categories
	- We also know how to display list of items in each category and handle their purchase
*/

//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001 /*Not used*/
#define IDC_LISTBOX	1501

//================================================================================================================
//================================================================================================================
//Settings
NWG_MSHOP_CLI_Settings =  createHashMapFromArray [
	/*Shop localization keys*/
	["LOC_ROOT_TITLE","#MSHOP_ROOT_TITLE#"],
	["LOC_CAT_TEMPLATE","#MSHOP_CAT%1_TITLE#"],
	["LOC_ITEM_TEMPLATE","#MSHOP_C%1I%2#"],
	["LOC_MAP_ITEM_HINT","#MSHOP_MAP_ITEM_HINT#"],
	["LOC_MAP_VEHICLE_HINT","#MSHOP_MAP_VEHICLE_HINT#"],

	/*List settings*/
	["TITLE_ROW_EXPECTED",true],
	["ITEM_ROW_TEMPLATE","%1 (%2)"],

	/*External functions*/
	["FUNC_OPEN_ROOT_INTERFACE", {_this call NWG_fnc_upOpenSecondaryMenu}], //params: _windowName
	["FUNC_OPEN_CAT_INTERFACE",  {_this call NWG_fnc_upOpenSecondaryMenu}],  //params: _windowName
	["FUNC_OPEN_VEH_INTERFACE",  {call NWG_fnc_upOpenSecondaryWithDropdown}],//params: _windowName
	["FUNC_CLOSE_ALL_INTERFACES",{call NWG_fnc_upCloseAllMenus}],
	["FUNC_OPEN_CUSTOM_VEH_SHOP",{_this call NWG_fnc_vshopOpenCustomShop}],//params: ["_interface","_callback"]

	/*Internal functions*//*Also defines the number of categories in shop menu and their indices*/
	["FUNCS_ON_CATEGORY_SELECTED",[
		{_this call NWG_MSHOP_CLI_OpenShopTab},
		{_this call NWG_MSHOP_CLI_OpenShopTab},
		{_this call NWG_MSHOP_CLI_OpenShopTab},
		{_this call NWG_MSHOP_CLI_OpenVehiclesTab}
	]],

	/*Player money text*/
	["EXPECT_PLAYER_MONEY_TEXT_PREFILLED",true],//If true, we won't attempt to fill it

	/*Player money text blinking*/
	["PLAYER_MONEY_BLINK_COLOR_ON_ERROR",[1,0,0,1]],
	["PLAYER_MONEY_BLINK_TIMES",2],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON",0.3],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF",0.2],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MSHOP_CLI_priceMap = createHashMap;
NWG_MSHOP_CLI_selectedItem = "";
NWG_MSHOP_CLI_moneySpent = 0;
NWG_MSHOP_CLI_selectedVehicle = "";

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	addMissionEventHandler ["MapSingleClick",{_this call NWG_MSHOP_CLI_OnMapClick}];
};

//================================================================================================================
//================================================================================================================
//Player money text
NWG_MSHOP_CLI_FillPlayerMoneyText = {
	// private _gui = _this;
	if (NWG_MSHOP_CLI_Settings get "EXPECT_PLAYER_MONEY_TEXT_PREFILLED") exitWith {true};//Skip if should be prefilled
	if (isNull _this) exitWith {"NWG_MSHOP_CLI_FillPlayerMoneyText: GUI is null" call NWG_fnc_logError; false};
	private _playerMoneyText = _this displayCtrl IDC_TEXT_LEFT;
	if (isNull _playerMoneyText) exitWith {"NWG_MSHOP_CLI_FillPlayerMoneyText: Player money text is null" call NWG_fnc_logError; false};
	_playerMoneyText ctrlSetText ((player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney);
	true
};

NWG_MSHOP_CLI_blinkHandle = scriptNull;
NWG_MSHOP_CLI_BlinkPlayerMoneyTextOnError = {
	// private _gui = _this;
	if (isNull _this) exitWith {"NWG_MSHOP_CLI_BlinkPlayerMoneyTextOnError: GUI is null" call NWG_fnc_logError};
	private _playerMoneyText = _this displayCtrl IDC_TEXT_LEFT;
	if (isNull _playerMoneyText) exitWith {"NWG_MSHOP_CLI_BlinkPlayerMoneyTextOnError: Player money text is null" call NWG_fnc_logError};

	if (!isNull NWG_MSHOP_CLI_blinkHandle && {!scriptDone NWG_MSHOP_CLI_blinkHandle}) then {
		terminate NWG_MSHOP_CLI_blinkHandle;
	};

	NWG_MSHOP_CLI_blinkHandle = _playerMoneyText spawn {
		disableSerialization;
		private _playerMoneyText = _this;
		private _origColor = _playerMoneyText getVariable "origColor";
		if (isNil "_origColor") then {
			_origColor = ctrlBackgroundColor _playerMoneyText;
			_playerMoneyText setVariable ["origColor",_origColor];
		};
		private _color = NWG_MSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_ERROR";
		private _times = NWG_MSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_TIMES";

		private _isOn = false;
		private _blinkCount = 0;
		waitUntil {
			if (isNull _playerMoneyText) exitWith {true};//Could be closed at this point and that's ok
			if (!_isOn && {_blinkCount >= _times}) exitWith {true};//Exit loop when done
			if (!_isOn) then {
				//Turn on
				_playerMoneyText ctrlSetBackgroundColor _color;
				sleep (NWG_MSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON");
			} else {
				//Turn off
				_playerMoneyText ctrlSetBackgroundColor _origColor;
				sleep (NWG_MSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF");
			};
			_blinkCount = _blinkCount + 0.5;//Increment (each blink is two steps - ON and OFF, that is why we add 0.5)
			_isOn = !_isOn;//Toggle
			false//Get to the next iteration
		};
	};
};

//================================================================================================================
//================================================================================================================
//Shop root
NWG_MSHOP_CLI_OpenShop = {
	//Open interface
	private _windowName = NWG_MSHOP_CLI_Settings get "LOC_ROOT_TITLE";
	private _openFunc = NWG_MSHOP_CLI_Settings get "FUNC_OPEN_ROOT_INTERFACE";
	private _interface = _windowName call _openFunc;
	if (isNil "_interface" || {_interface isEqualTo false}) exitWith {
		"NWG_MSHOP_CLI_OpenShop: Failed to open interface" call NWG_fnc_logError;
		false
	};
	uiNamespace setVariable ["NWG_MSHOP_CLI_shopInterface",_interface];

	//Send request to server
	player remoteExec ["NWG_fnc_mshopShopValuesRequest",2];
	//The rest will be done once server responds
};

NWG_MSHOP_CLI_OnServerResponse = {
	disableSerialization;
	private _prices = _this;//["C0I0",price1,"C0I1",price2,...]

	//Get interface
	private _interface = uiNamespace getVariable ["NWG_MSHOP_CLI_shopInterface",displayNull];
	if (isNull _interface) exitWith {
		"NWG_MSHOP_CLI_OnServerResponse: Interface was closed during request" call NWG_fnc_logInfo;
		false
	};

	//Setup price map
	for "_i" from 0 to ((count _prices) - 1) step 2 do {
		NWG_MSHOP_CLI_priceMap set [(_prices#_i),(_prices#(_i + 1))];
	};

	//Fill player money text
	private _ok = _interface call NWG_MSHOP_CLI_FillPlayerMoneyText;
	if (!_ok) then {
		"NWG_MSHOP_CLI_OnServerResponse: Failed to fill player money text" call NWG_fnc_logError;
	};

	//Get listbox
	private _listBox = _interface displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {
		"NWG_MSHOP_CLI_OnServerResponse: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Fill listbox
	private _template = NWG_MSHOP_CLI_Settings get "LOC_CAT_TEMPLATE";
	{
		private _entryText = (format [_template,_forEachIndex]) call NWG_fnc_localize;
		_listBox lbAdd _entryText;
	} forEach (NWG_MSHOP_CLI_Settings get "FUNCS_ON_CATEGORY_SELECTED");

	//Setup event handlers
	_listBox ctrlAddEventHandler ["LBDblClick",{
		params ["_listBox","_selectedIndex"];
		private _withTitleRow = NWG_MSHOP_CLI_Settings get "TITLE_ROW_EXPECTED";
		private _expected = if (_withTitleRow) then {1} else {0};
		if (_selectedIndex >= _expected) then {
			if (_withTitleRow) then {_selectedIndex = _selectedIndex - 1};
			_selectedIndex call NWG_MSHOP_CLI_OnCategorySelected;
		};
	}];

	true
};

NWG_MSHOP_CLI_OnCategorySelected = {
	private _categoryIndex = _this;
	_categoryIndex call ((NWG_MSHOP_CLI_Settings get "FUNCS_ON_CATEGORY_SELECTED") select _categoryIndex);
};

//================================================================================================================
//================================================================================================================
//Shop tabs (regular)
NWG_MSHOP_CLI_OpenShopTab = {
	private _categoryIndex = _this;

	//Open new window
	private _template = NWG_MSHOP_CLI_Settings get "LOC_CAT_TEMPLATE";
	private _windowName = format [_template,_categoryIndex];
	private _openFunc = NWG_MSHOP_CLI_Settings get "FUNC_OPEN_CAT_INTERFACE";
	private _interface = _windowName call _openFunc;
	if (isNil "_interface" || {_interface isEqualTo false}) exitWith {
		"NWG_MSHOP_CLI_OpenShopTab: Failed to open interface" call NWG_fnc_logError;
		false;
	};

	//Fill player money text
	private _ok = _interface call NWG_MSHOP_CLI_FillPlayerMoneyText;
	if (!_ok) exitWith {false};

	//Get listbox
	private _listBox = _interface displayCtrl IDC_LISTBOX;
	if (isNull _listBox) exitWith {
		"NWG_MSHOP_CLI_OpenShopTab: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Fill listbox
	private _locTemplate = NWG_MSHOP_CLI_Settings get "LOC_ITEM_TEMPLATE";
	for "_i" from 0 to 100 do {
		private _itemName = format ["C%1I%2",_categoryIndex,_i];
		if !(_itemName in NWG_MSHOP_CLI_priceMap) exitWith {};//No more items in this category that we know of

		private _itemDisplayName = (format [_locTemplate,_categoryIndex,_i]) call NWG_fnc_localize;
		private _itemDisplayPrice = (NWG_MSHOP_CLI_priceMap get _itemName) call NWG_fnc_wltFormatMoney;
		private _itemRow = format [(NWG_MSHOP_CLI_Settings get "ITEM_ROW_TEMPLATE"),_itemDisplayName,_itemDisplayPrice];

		private _index = _listBox lbAdd _itemRow;
		_listBox lbSetData [_index,_itemName];
	};

	//Setup event handlers
	_listBox ctrlAddEventHandler ["LBDblClick",{
		params ["_listBox","_selectedIndex"];
		private _withTitleRow = NWG_MSHOP_CLI_Settings get "TITLE_ROW_EXPECTED";
		private _expected = if (_withTitleRow) then {1} else {0};
		if (_selectedIndex >= _expected) then {
			private _itemName = _listBox lbData _selectedIndex;
			[_listBox,_itemName] call NWG_MSHOP_CLI_OnItemSelected;
		};
	}];

	true
};

NWG_MSHOP_CLI_OnItemSelected = {
	params ["_listBox","_itemName"];

	//Get item price and player money
	private _playerMoney = player call NWG_fnc_wltGetPlayerMoney;
	private _itemPrice = NWG_MSHOP_CLI_priceMap getOrDefault [_itemName,false];
	if (_itemPrice isEqualTo false) exitWith {
		"NWG_MSHOP_CLI_OnItemSelected: Item price is not set" call NWG_fnc_logError;
		false
	};
	if (_playerMoney < _itemPrice) exitWith {
		(ctrlParent _listBox) call NWG_MSHOP_CLI_BlinkPlayerMoneyTextOnError;
	};

	//Decrease player money
	[player,-_itemPrice] call NWG_fnc_wltAddPlayerMoney;

	//Prepare item placement
	NWG_MSHOP_CLI_selectedItem = _itemName;//Save
	NWG_MSHOP_CLI_moneySpent = _itemPrice;//Save
	call (NWG_MSHOP_CLI_Settings get "FUNC_CLOSE_ALL_INTERFACES");//Close all open interfaces
	openMap [true,true];//Force open map
	hint ((NWG_MSHOP_CLI_Settings get "LOC_MAP_ITEM_HINT") call NWG_fnc_localize);//Show hint
	//... to be continued in map click handler 'NWG_MSHOP_CLI_OnMapClick'
};

//================================================================================================================
//================================================================================================================
//Shop vehicles
NWG_MSHOP_CLI_OpenVehiclesTab = {
	private _categoryIndex = _this;

	//Open new window
	private _template = NWG_MSHOP_CLI_Settings get "LOC_CAT_TEMPLATE";
	private _windowName = format [_template,_categoryIndex];
	private _openFunc = NWG_MSHOP_CLI_Settings get "FUNC_OPEN_VEH_INTERFACE";
	private _interface = _windowName call _openFunc;
	if (isNil "_interface" || {_interface isEqualTo false}) exitWith {
		"NWG_MSHOP_CLI_OpenShopTab: Failed to open interface" call NWG_fnc_logError;
		false;
	};

	//Check that it has all the expected controls
	if (isNull (_interface displayCtrl IDC_TEXT_LEFT)) exitWith {
		"NWG_MSHOP_CLI_OpenVehiclesTab: Text left is null" call NWG_fnc_logError;
		false
	};
	if (isNull (_interface displayCtrl IDC_LISTBOX)) exitWith {
		"NWG_MSHOP_CLI_OpenVehiclesTab: Listbox is null" call NWG_fnc_logError;
		false
	};

	//Define callback
	private _callback = {
		// private _vehicleClassname = _this;
		_this call NWG_MSHOP_CLI_OnVehicleBought;
	};

	//Open custom shop
	[_interface,_callback] call (NWG_MSHOP_CLI_Settings get "FUNC_OPEN_CUSTOM_VEH_SHOP");

	true
};

NWG_MSHOP_CLI_OnVehicleBought = {
	// private _vehicleClassname = _this;
	//note: we don't need vehicle price here, underlying vehicle shop will take care of that

	NWG_MSHOP_CLI_selectedVehicle = _this;//Save
	call (NWG_MSHOP_CLI_Settings get "FUNC_CLOSE_ALL_INTERFACES");//Close all open interfaces (will also trigger money deduction for bought vehicle)
	openMap [true,true];//Force open map
	hint ((NWG_MSHOP_CLI_Settings get "LOC_MAP_VEHICLE_HINT") call NWG_fnc_localize);//Show hint

	//... to be continued in map click handler 'NWG_MSHOP_CLI_OnMapClick'
};

//================================================================================================================
//================================================================================================================
//Map click handler
NWG_MSHOP_CLI_OnMapClick = {
	// params ["_units","_pos","_alt","_shift"];
	switch (true) do {
		//Request for item from server
		case (NWG_MSHOP_CLI_selectedItem isNotEqualTo ""): {
			private _pos = _this select 1;
			private _itemName = NWG_MSHOP_CLI_selectedItem;
			private _moneySpent = NWG_MSHOP_CLI_moneySpent;
			NWG_MSHOP_CLI_selectedItem = "";//Reset
			NWG_MSHOP_CLI_moneySpent = 0;//Reset

			//Send request to server
			[player,_itemName,_pos,_moneySpent] remoteExec ["NWG_fnc_mshopOnItemBought",2];

			//Close map
			openMap [true,false];
			openMap false;
			hintSilent "";
		};
		//Request for vehicle from server
		case (NWG_MSHOP_CLI_selectedVehicle isNotEqualTo ""): {
			private _pos = _this select 1;
			private _vehicleClassname = NWG_MSHOP_CLI_selectedVehicle;
			NWG_MSHOP_CLI_selectedVehicle = "";//Reset

			//Send request to server
			[player,_vehicleClassname,_pos] remoteExec ["NWG_fnc_mshopOnVehicleBought",2];

			//Close map
			openMap [true,false];
			openMap false;
			hintSilent "";
		};
		default {/*Do nothing*/};
	};
};

//================================================================================================================
//================================================================================================================
call _Init