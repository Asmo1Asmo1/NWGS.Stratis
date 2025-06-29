#include "..\..\globalDefines.h"

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
	["LOC_SUPPORT_NEED_TEMPLATE","#MSHOP_SUPPORT_NEED_TEMPLATE#"],
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

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MSHOP_CLI_priceMap = createHashMap;
NWG_MSHOP_CLI_supportMap = createHashMap;
NWG_MSHOP_CLI_selectedItem = [];
NWG_MSHOP_CLI_selectedVehicle = "";

//================================================================================================================
//================================================================================================================
//Player money text
NWG_MSHOP_CLI_FillPlayerMoneyText = {
	private _gui = _this;
	private _idc = IDC_TEXT_LEFT;
	[_gui,_idc] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
};

NWG_MSHOP_CLI_BlinkPlayerMoneyTextOnError = {
	private _gui = _this;
	private _idc = IDC_TEXT_LEFT;
	[_gui,_idc] call NWG_fnc_uiHelperBlinkOnError;
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
	private _values = _this;//["C0I0",price,supportLevel,"C0I1",price,supportLevel,...]

	//Get interface
	private _interface = uiNamespace getVariable ["NWG_MSHOP_CLI_shopInterface",displayNull];
	if (isNull _interface) exitWith {
		"NWG_MSHOP_CLI_OnServerResponse: Interface was closed during request" call NWG_fnc_logInfo;
		false
	};

	//Setup price and support level maps
	for "_i" from 0 to ((count _values) - 1) step 3 do {
		NWG_MSHOP_CLI_priceMap set [(_values#_i),(_values#(_i + 1))];
		NWG_MSHOP_CLI_supportMap set [(_values#_i),(_values#(_i + 2))];
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
			_selectedIndex call ((NWG_MSHOP_CLI_Settings get "FUNCS_ON_CATEGORY_SELECTED") select _selectedIndex);
		};
	}];

	true
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
	private _displayNameLocTempalte = NWG_MSHOP_CLI_Settings get "LOC_ITEM_TEMPLATE";
	private _supportNeedLocTemplate = NWG_MSHOP_CLI_Settings get "LOC_SUPPORT_NEED_TEMPLATE";
	private _mySupportLevel = player call NWG_fnc_pGetMySupportLvl;
	for "_i" from 0 to 100 do {
		private _itemName = format ["C%1I%2",_categoryIndex,_i];
		if !(_itemName in NWG_MSHOP_CLI_priceMap) exitWith {};//No more items in this category that we know of

		private _supportNeed = NWG_MSHOP_CLI_supportMap get _itemName;
		if (_mySupportLevel >= _supportNeed) then {
			private _itemDisplayName = (format [_displayNameLocTempalte,_categoryIndex,_i]) call NWG_fnc_localize;
			private _itemDisplayPrice = (NWG_MSHOP_CLI_priceMap get _itemName) call NWG_fnc_wltFormatMoney;
			private _itemRow = format [(NWG_MSHOP_CLI_Settings get "ITEM_ROW_TEMPLATE"),_itemDisplayName,_itemDisplayPrice];
			private _index = _listBox lbAdd _itemRow;
			_listBox lbSetData [_index,_itemName];
		} else {
			private _supportNeedText = format [(_supportNeedLocTemplate call NWG_fnc_localize),_supportNeed];
			private _index = _listBox lbAdd _supportNeedText;
			_listBox lbSetColor [_index,[1,1,1,0.5]];
			_listBox lbSetData [_index,""];
		};
	};

	//Setup event handlers
	_listBox ctrlAddEventHandler ["LBDblClick",{
		params ["_listBox","_selectedIndex"];
		private _withTitleRow = NWG_MSHOP_CLI_Settings get "TITLE_ROW_EXPECTED";
		private _expected = if (_withTitleRow) then {1} else {0};
		if (_selectedIndex >= _expected) then {
			private _itemName = _listBox lbData _selectedIndex;
			if (_itemName isNotEqualTo "") then {[_listBox,_itemName] call NWG_MSHOP_CLI_OnItemSelected};
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

	//Close all open interfaces
	[player,-_itemPrice] call NWG_fnc_wltAddPlayerMoney;//Decrease player money (bezobrazno zato odnoobrazno)
	call (NWG_MSHOP_CLI_Settings get "FUNC_CLOSE_ALL_INTERFACES");//Close all open interfaces

	//Prepare map callbacks
	NWG_MSHOP_CLI_selectedItem = [_itemName,_itemPrice];//Save
	private _onMapClick = {
		private _clickPos = _this;
		NWG_MSHOP_CLI_selectedItem params ["_itemName","_moneySpent"];
		NWG_MSHOP_CLI_selectedItem = [];//Reset

		//Send request to server
		[player,_itemName,_clickPos,_moneySpent] remoteExec ["NWG_fnc_mshopOnItemBought",2];

		//Close map
		call NWG_fnc_moClose;
		hintSilent "";
	};
	private _onMapClose = {
		NWG_MSHOP_CLI_selectedItem params ["_itemName","_moneySpent"];
		NWG_MSHOP_CLI_selectedItem = [];//Reset
		[player,_moneySpent] call NWG_fnc_wltAddPlayerMoney;//Return money
	};

	//Open map and show hint
	hint ((NWG_MSHOP_CLI_Settings get "LOC_MAP_ITEM_HINT") call NWG_fnc_localize);
	[_onMapClick,_onMapClose] call NWG_fnc_moOpen;
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

	//Close all open interfaces (will also trigger money deduction for bought vehicle)
	call (NWG_MSHOP_CLI_Settings get "FUNC_CLOSE_ALL_INTERFACES");

	//Prepare map callbacks
	NWG_MSHOP_CLI_selectedVehicle = _this;
	private _onMapClick = {
		private _clickPos = _this;
		private _vehicleClassname = NWG_MSHOP_CLI_selectedVehicle;
		NWG_MSHOP_CLI_selectedVehicle = "";//Reset

		//Send request to server
		[player,_vehicleClassname,_clickPos] remoteExec ["NWG_fnc_mshopOnVehicleBought",2];

		//Close map
		call NWG_fnc_moClose;
		hintSilent "";
	};
	private _onMapClose = {
		private _vehicleClassname = NWG_MSHOP_CLI_selectedVehicle;
		NWG_MSHOP_CLI_selectedVehicle = "";//Reset
		_vehicleClassname call NWG_fnc_vshopRefund;//Refund vehicle price
		hintSilent "";
	};

	//Open map and show hint
	hint ((NWG_MSHOP_CLI_Settings get "LOC_MAP_VEHICLE_HINT") call NWG_fnc_localize);
	[_onMapClick,_onMapClose] call NWG_fnc_moOpen;
};
