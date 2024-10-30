#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
//--- shopUI (copy to shopUI.sqf)
#define SHOP_UI_DIALOGUE_NAME "shopUI"
#define IDC_SHOPUI_DIALOGUE 7101
#define IDC_SHOPUI_PLAYERMONEYTEXT 1000
#define IDC_SHOPUI_SHOPMONEYTEXT 1001
#define IDC_SHOPUI_PLAYERLIST 1500
#define IDC_SHOPUI_SHOPLIST 1501
#define IDC_SHOPUI_PLAYERX1BUTTON 1600
#define IDC_SHOPUI_PLAYERX10BUTTON 1601
#define IDC_SHOPUI_PLAYERALLBUTTON 1602
#define IDC_SHOPUI_SHOPX1BUTTON 1603
#define IDC_SHOPUI_SHOPX10BUTTON 1604
#define IDC_SHOPUI_SHOPALLBUTTON 1605
#define IDC_SHOPUI_PLAYERDROPDOWN 2100
#define IDC_SHOPUI_SHOPDROPDOWN 2101

//Additional loot item type
#define LOOT_ITEM_TYPE_ALL "ALL"

//Button multipliers
#define BUTTON_MULTIPLIER_X01 1
#define BUTTON_MULTIPLIER_X10 10
#define BUTTON_MULTIPLIER_ALL 1000

//================================================================================================================
//================================================================================================================
//Settings
NWG_ISHOP_CLI_Settings = createHashMapFromArray [
	["PRICE_SELL_TO_PLAYER_MULTIPLIER",1.3],
	["PRICE_BUY_FROM_PLAYER_MULTIPLIER",0.7],

	["SHOP_SKIP_SENDING_PLAYER_LOOT",true],//If you're using 'lootStorage' module, player loot is already synchronized between players and server
	["SHOP_GET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsGetPlayerLoot}],//Function that returns player loot
	["SHOP_SET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsSetPlayerLoot}],//Function that sets player loot

	["PLAYER_MONEY_BLINK_COLOR_ON_ERROR",[1,0,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_ON_SUCCESS",[0,1,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON",0.3],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF",0.2],

	["MULTIPLIER_BUTTON_ACTIVE_COLOR",[1,1,1,1]],
	["MULTIPLIER_BUTTON_INACTIVE_COLOR",[1,1,1,0.2]],

	["ITEM_LIST_NAME_LIMIT",30],//Max number of letters for the item name
	["ITEM_LIST_TEMPLATE_W_COUNT","%1 [x%2] (%3)"],//Item list format string
	["ITEM_LIST_TEMPLATE_W_NO_COUNT","%1 (%2)"],//Item list format string

	["",0]
];

//================================================================================================================
//================================================================================================================
//Shop
NWG_ISHOP_CLI_OpenShop = {
	//Send request to server
	player remoteExec ["NWG_fnc_ishopShopValuesRequest",2];
	//The rest will be done once server responds
};

NWG_ISHOP_CLI_OnServerResponse = {
	disableSerialization;
	params ["_playerLoot","_shopItems","_allItems","_allPrices"];
	//If player loot was skipped - get it here
	if (_playerLoot isEqualTo [] || {NWG_ISHOP_CLI_Settings get "SHOP_SKIP_SENDING_PLAYER_LOOT"}) then {
		_playerLoot = player call (NWG_ISHOP_CLI_Settings get "SHOP_GET_PLAYER_LOOT_FUNC");
	};

	//Check if shop dialog is already open
	if (!isNull (findDisplay IDC_SHOPUI_DIALOGUE)) exitWith {
		"NWG_ISHOP_CLI_OnServerResponse: Shop dialog is already open" call NWG_fnc_logError;
	};

	//Create shop dialog
	private _shopGUI = createDialog [SHOP_UI_DIALOGUE_NAME,true];
	if (isNull _shopGUI) exitWith {
		"NWG_ISHOP_CLI_OnServerResponse: Failed to create shop dialog" call NWG_fnc_logError;
	};
	uiNamespace setVariable ["NWG_ISHOP_CLI_shopGUI",_shopGUI];

	//Save player loot and shop items for both UI and transaction logic
	uiNamespace setVariable ["NWG_ISHOP_CLI_playerLoot",(+_playerLoot)];//Save as deep copy
	uiNamespace setVariable ["NWG_ISHOP_CLI_shopItems",(+_shopItems)];//Save as deep copy

	//Init transaction
	[_allItems,_allPrices] call NWG_ISHOP_CLI_TRA_OnOpen;

	//Initialize UI top to bottom
	//Init player money
	(call NWG_ISHOP_CLI_TRA_GetPlayerMoney) call NWG_ISHOP_CLI_UpdatePlayerMoneyText;
	//Init shop money (does not change)
	(_shopGUI displayCtrl IDC_SHOPUI_SHOPMONEYTEXT) ctrlSetText ("#ISHOP_SELLER_MONEY_CONST#" call NWG_fnc_localize);

	//Init player and shop category dropdowns
	{
		//Get dropdown control from shop GUI
		_x params ["_idc","_isPlayerSide"];
		private _dropdown = _shopGUI displayCtrl _idc;

		//Fill dropdown with items
		private _index = -1;
		{
			_x params ["_cat","_title"];
			_index = _dropdown lbAdd (_title call NWG_fnc_localize);
			_dropdown lbSetData [_index,_cat];
		} forEach [
			[LOOT_ITEM_TYPE_ALL,"#ISHOP_CAT_ALL#"],
			[LOOT_ITEM_TYPE_CLTH,"#ISHOP_CAT_CLTH#"],
			[LOOT_ITEM_TYPE_WEAP,"#ISHOP_CAT_WEAP#"],
			[LOOT_ITEM_TYPE_ITEM,"#ISHOP_CAT_ITEM#"],
			[LOOT_ITEM_TYPE_AMMO,"#ISHOP_CAT_AMMO#"]
		];
		_dropdown lbSetCurSel 0;

		//Set callback
		_dropdown setVariable ["isPlayerSide",_isPlayerSide];
		_dropdown ctrlAddEventHandler ["LBSelChanged",{_this call NWG_ISHOP_CLI_OnDropdownSelect}];
	} forEach [
		[IDC_SHOPUI_PLAYERDROPDOWN,true],
		[IDC_SHOPUI_SHOPDROPDOWN,  false]
	];
	uiNamespace setVariable ["NWG_ISHOP_CLI_plListCat",LOOT_ITEM_TYPE_ALL];
	uiNamespace setVariable ["NWG_ISHOP_CLI_shListCat",LOOT_ITEM_TYPE_ALL];

	//Init player and shop multiplier buttons
	private _allButtons = [];
	{
		_x params ["_idc","_multiplier","_isPlayerSide"];
		private _button = _shopGUI displayCtrl _idc;
		_button setVariable ["multiplier",_multiplier];
		_button setVariable ["isPlayerSide",_isPlayerSide];
		switch (_multiplier) do {
			case (BUTTON_MULTIPLIER_X01): {/*nothing*/};
			case (BUTTON_MULTIPLIER_X10): {_button ctrlSetTooltip ("#ISHOP_MULT_X10_TT#" call NWG_fnc_localize)};
			case (BUTTON_MULTIPLIER_ALL): {_button ctrlSetTooltip ("#ISHOP_MULT_ALL_TT#" call NWG_fnc_localize)};
		};

		_button ctrlAddEventHandler ["ButtonClick",{_this call NWG_ISHOP_CLI_OnMultiplierButtonClick}];
		_allButtons pushBack _button;
	} forEach [
		[IDC_SHOPUI_PLAYERX1BUTTON,  BUTTON_MULTIPLIER_X01,true],
		[IDC_SHOPUI_PLAYERX10BUTTON, BUTTON_MULTIPLIER_X10,true],
		[IDC_SHOPUI_PLAYERALLBUTTON, BUTTON_MULTIPLIER_ALL,true],
		[IDC_SHOPUI_SHOPX1BUTTON,  BUTTON_MULTIPLIER_X01,false],
		[IDC_SHOPUI_SHOPX10BUTTON, BUTTON_MULTIPLIER_X10,false],
		[IDC_SHOPUI_SHOPALLBUTTON, BUTTON_MULTIPLIER_ALL,false]
	];
	uiNamespace setVariable ["NWG_ISHOP_CLI_allButtons",_allButtons];
	uiNamespace setVariable ["NWG_ISHOP_CLI_plMultiplier",BUTTON_MULTIPLIER_X01];
	uiNamespace setVariable ["NWG_ISHOP_CLI_shMultiplier",BUTTON_MULTIPLIER_X01];
	[BUTTON_MULTIPLIER_X01,0] call NWG_ISHOP_CLI_SetNewMultiplier;//Set default multipliers

	//Init changing multipliers on 'Ctrl'(x10) and 'Shift'(x1000) keys holding
	_shopGUI displayAddEventHandler ["KeyDown",{_this call NWG_ISHOP_CLI_OnKeyDown}];
	_shopGUI displayAddEventHandler ["KeyUp",{_this call NWG_ISHOP_CLI_OnKeyUp}];

	//Init player and shop lists
	private _plList = (_shopGUI displayCtrl IDC_SHOPUI_PLAYERLIST);
	private _shList = (_shopGUI displayCtrl IDC_SHOPUI_SHOPLIST);
	_plList setVariable ["isPlayerSide",true];
	_shList setVariable ["isPlayerSide",false];
	uiNamespace setVariable ["NWG_ISHOP_CLI_plList",_plList];
	uiNamespace setVariable ["NWG_ISHOP_CLI_shList",_shList];
	[true,LOOT_ITEM_TYPE_ALL] call NWG_ISHOP_CLI_UpdateItemsList;
	[false,LOOT_ITEM_TYPE_ALL] call NWG_ISHOP_CLI_UpdateItemsList;
	_plList ctrlAddEventHandler ["LBDblClick",{_this call NWG_ISHOP_CLI_OnListDobuleClick}];
	_shList ctrlAddEventHandler ["LBDblClick",{_this call NWG_ISHOP_CLI_OnListDobuleClick}];

	//On close
	_shopGUI displayAddEventHandler ["Unload",{
		//Finalize transaction
		call NWG_ISHOP_CLI_TRA_OnClose;

		//Dispose variables
		uiNamespace setVariable ["NWG_ISHOP_CLI_shopGUI",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_plListCat",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_shListCat",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_allButtons",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_plMultiplier",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_shMultiplier",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_playerLoot",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_shopItems",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_plList",nil];
		uiNamespace setVariable ["NWG_ISHOP_CLI_shList",nil];
    }];
};

//================================================================================================================
//================================================================================================================
//Player money indicator
NWG_ISHOP_CLI_UpdatePlayerMoneyText = {
	disableSerialization;
	private _playerMoney = _this;
	private _shopGUI = uiNamespace getVariable ["NWG_ISHOP_CLI_shopGUI",displayNull];
	if (isNull _shopGUI) exitWith {
		"NWG_ISHOP_CLI_UpdatePlayerMoneyText: Shop GUI is null" call NWG_fnc_logError;
	};
	(_shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT) ctrlSetText (_playerMoney call NWG_fnc_wltFormatMoney);
};

NWG_ISHOP_CLI_blinkHandle = scriptNull;
NWG_ISHOP_CLI_BlinkPlayerMoney = {
	// params ["_color","_times"];
	if (!isNull NWG_ISHOP_CLI_blinkHandle && {!scriptDone NWG_ISHOP_CLI_blinkHandle}) then {
		terminate NWG_ISHOP_CLI_blinkHandle;
	};

	NWG_ISHOP_CLI_blinkHandle = _this spawn {
		disableSerialization;
		params ["_color","_times"];
		private _shopGUI = uiNamespace getVariable ["NWG_ISHOP_CLI_shopGUI",displayNull];
		if (isNull _shopGUI) exitWith {
			"NWG_ISHOP_CLI_BlinkPlayerMoney: Shop GUI is null" call NWG_fnc_logError;
		};
		private _textCtrl = _shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT;
		if (isNull _textCtrl) exitWith {
			"NWG_ISHOP_CLI_BlinkPlayerMoney: Text control is null" call NWG_fnc_logError;
		};
		private _origColor = _textCtrl getVariable "origColor";
		if (isNil "_origColor") then {
			_origColor = ctrlBackgroundColor _textCtrl;
			_textCtrl setVariable ["origColor",_origColor];
		};

		private _isOn = false;
		private _blinkCount = 0;
		waitUntil {
			_textCtrl = if (!isNull _shopGUI)
				then {_shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT}
				else {controlNull};
			if (isNull _textCtrl) exitWith {true};//Could be closed at this point and that's ok

			if (!_isOn && {_blinkCount >= _times}) exitWith {true};//Exit loop
			if (!_isOn) then {
				//Turn on
				_textCtrl ctrlSetBackgroundColor _color;
				sleep (NWG_ISHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON");
			} else {
				//Turn off
				_textCtrl ctrlSetBackgroundColor _origColor;
				sleep (NWG_ISHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF");
			};
			_blinkCount = _blinkCount + 0.5;//Increment (each blink is two steps - ON and OFF, that is why we add 0.5)
			_isOn = !_isOn;//Toggle
			false//Get to the next iteration
		};
	};
};

//================================================================================================================
//================================================================================================================
//Dropdowns
NWG_ISHOP_CLI_OnDropdownSelect = {
	params ["_control","_lbCurSel"];
	private _listCat = _control lbData _lbCurSel;
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	[_isPlayerSide,_listCat] call NWG_ISHOP_CLI_UpdateItemsList;
};

//================================================================================================================
//================================================================================================================
//Multipliers
NWG_ISHOP_CLI_OnMultiplierButtonClick = {
	params ["_control"];
	private _multiplier = _control getVariable ["multiplier",BUTTON_MULTIPLIER_X01];
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	private _side = if (_isPlayerSide) then {-1} else {1};
	[_multiplier,_side] call NWG_ISHOP_CLI_SetNewMultiplier;
};

NWG_ISHOP_CLI_OnKeyDown = {
	// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
	params ["","","_shift","_ctrl"];
	if (!_shift && !_ctrl) exitWith {nil};//Return 'nothing' from KeyDown event to aviod key interception

	private _newMultiplier = if (_shift)
		then {BUTTON_MULTIPLIER_ALL}
		else {BUTTON_MULTIPLIER_X10};

	if (_newMultiplier != (uiNamespace getVariable ["NWG_ISHOP_CLI_plMultiplier",BUTTON_MULTIPLIER_X01]) || {
		_newMultiplier != (uiNamespace getVariable ["NWG_ISHOP_CLI_shMultiplier",BUTTON_MULTIPLIER_X01])}
	) then {
		[_newMultiplier,0] call NWG_ISHOP_CLI_SetNewMultiplier;
	};
};

NWG_ISHOP_CLI_OnKeyUp = {
	// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
	// params ["","","_shift","_ctrl"];
	// if (!_shift && !_ctrl) exitWith {nil}; //'Fix' stucking multipliers
	[BUTTON_MULTIPLIER_X01,0] call NWG_ISHOP_CLI_SetNewMultiplier;
};

NWG_ISHOP_CLI_SetNewMultiplier = {
	params ["_newMultiplier","_side"];

	//Update UI
	private _allButtons = uiNamespace getVariable ["NWG_ISHOP_CLI_allButtons",[]];
	private _predicate = switch (_side) do {
		case -1: {{(_x getVariable ["isPlayerSide",true]) == true}};//Player side
		case  1: {{(_x getVariable ["isPlayerSide",true]) == false}};//Shop side
		case  0: {{true}};//Both sides
	};
	private _activeColor = NWG_ISHOP_CLI_Settings get "MULTIPLIER_BUTTON_ACTIVE_COLOR";
	private _inactiveColor = NWG_ISHOP_CLI_Settings get "MULTIPLIER_BUTTON_INACTIVE_COLOR";
	{
		if (_x getVariable ["multiplier",BUTTON_MULTIPLIER_X01] == _newMultiplier)
			then {_x ctrlSetTextColor _activeColor}
			else {_x ctrlSetTextColor _inactiveColor};
	} forEach (_allButtons select _predicate);

	//Update multiplier code values
	if (_side <= 0) then {uiNamespace setVariable ["NWG_ISHOP_CLI_plMultiplier",_newMultiplier]};
	if (_side >= 0) then {uiNamespace setVariable ["NWG_ISHOP_CLI_shMultiplier",_newMultiplier]};
};

//================================================================================================================
//================================================================================================================
//Items lists
NWG_ISHOP_CLI_UpdateItemsList = {
	disableSerialization;
	params ["_isPlayerSide",["_listCat",""],["_dropSelection",true]];

	private _list = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_ISHOP_CLI_plList",controlNull]}
		else {uiNamespace getVariable ["NWG_ISHOP_CLI_shList",controlNull]};

	if (_listCat isEqualTo "")
		then {_listCat = _list getVariable ["listCat",LOOT_ITEM_TYPE_ALL]}
		else {_list setVariable ["listCat",_listCat]};

	private _itemsCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_ISHOP_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_ISHOP_CLI_shopItems",[]]};

	private _itemsToShow = switch (_listCat) do {
		case LOOT_ITEM_TYPE_ALL: {flatten _itemsCollection};
		case LOOT_ITEM_TYPE_CLTH: {_itemsCollection#LOOT_ITEM_CAT_CLTH};
		case LOOT_ITEM_TYPE_WEAP: {_itemsCollection#LOOT_ITEM_CAT_WEAP};
		case LOOT_ITEM_TYPE_ITEM: {_itemsCollection#LOOT_ITEM_CAT_ITEM};
		case LOOT_ITEM_TYPE_AMMO: {_itemsCollection#LOOT_ITEM_CAT_AMMO};
		default {
			"NWG_ISHOP_CLI_UpdateItemsList: Invalid category" call NWG_fnc_logError;
			[]
		};
	};

	//Clear list
	lbClear _list;

	//Fill list
	private _count = 1;
	private _price = 0;
	private _i = -1;
	//forEach _itemsToShow
	{
		if (_x isEqualType 0) then {_count = _x; continue};//If array elemnt is number (else string)

		(_x call NWG_ISHOP_CLI_GetItemInfo) params ["_picture","_displayName"];
		_price = [_x,_isPlayerSide] call NWG_ISHOP_CLI_TRA_GetPrice;

		_i = _list lbAdd ([_displayName,_count,_price] call NWG_ISHOP_CLI_FormatListRecord);//Add formatted record
		_list lbSetData [_i,_x];//Set data (item classname)
		_list lbSetPicture [_i, _picture];//Set picture
		_count = 1;//Reset count
	} forEach _itemsToShow;

	//Drop selection
	if (_dropSelection) then {_list lbSetCurSel -1};
};

NWG_ISHOP_CLI_itemInfoCache = createHashMap;
NWG_ISHOP_CLI_GetItemInfo = {
	// private _item = _this;

	//Try cache first
	private _cached = NWG_ISHOP_CLI_itemInfoCache get _this;
	if (!isNil "_cached") exitWith {_cached};

	//Get info from config
	private _cfg = configNull;
	{
		_cfg = configFile >> _x >> _this;
		if (isClass _cfg) exitWith {};//Found
	} forEach ["CfgWeapons","CfgMagazines","CfgGlasses","CfgVehicles"];

	//Picture
	private _picture = getText (_cfg >> "picture");
	if (_picture isEqualTo "") then {_picture = getText (_cfg >> "icon")};

	//DisplayName
	private _displayName = getText (_cfg >> "displayName");

	//Cache and return
	private _itemInfo = [_picture,_displayName];
	NWG_ISHOP_CLI_itemInfoCache set [_this,_itemInfo];
	_itemInfo
};

NWG_ISHOP_CLI_FormatListRecord = {
	params ["_displayName","_count","_price"];

	//Limit display name
	private _limit = NWG_ISHOP_CLI_Settings get "ITEM_LIST_NAME_LIMIT";
	if ((count _displayName) > _limit) then {
		//Shorten the string and replace last 3 letters with '...'
		_displayName = (_displayName select [0,(_limit-3)]) + "...";
	};

	//Format and return
	if (_count > 1) then {
		format [(NWG_ISHOP_CLI_Settings get "ITEM_LIST_TEMPLATE_W_COUNT"),_displayName,_count,(_price call NWG_fnc_wltFormatMoney)]
	} else {
		format [(NWG_ISHOP_CLI_Settings get "ITEM_LIST_TEMPLATE_W_NO_COUNT"),_displayName,(_price call NWG_fnc_wltFormatMoney)]
	}
};

//================================================================================================================
//================================================================================================================
//Buy|Sell logic (on list double click)
NWG_ISHOP_CLI_OnListDobuleClick = {
	params ["_control","_selectedIndex"];

	//Gather UI variables
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	private _item = _control lbData _selectedIndex;
	if (_item isEqualTo "") exitWith {
		"NWG_ISHOP_CLI_OnListDobuleClick: Item is empty" call NWG_fnc_logError;
	};
	private _multiplier = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_ISHOP_CLI_plMultiplier",BUTTON_MULTIPLIER_X01]}
		else {uiNamespace getVariable ["NWG_ISHOP_CLI_shMultiplier",BUTTON_MULTIPLIER_X01]};

	//Define collection search script (returns: [_catIndex,_itemIndex,_itemCountIndex,_itemCount])
	private _findInCollection = {
		params ["_item","_collection"];
		private _categoryIndex = _collection findIf {_item in _x};
		if (_categoryIndex == -1) exitWith {[-1,-1,-1,0]};
		private _catArray = _collection#_categoryIndex;
		private _itemIndex = _catArray find _item;
		if (_itemIndex == -1) exitWith {[_categoryIndex,-1,-1,0]};
		private _itemCountIndex = if (_itemIndex > 0 && {(_catArray select (_itemIndex-1)) isEqualType 0})
			then {_itemIndex-1}
			else {-1};
		private _itemCount = if (_itemCountIndex != -1)
			then {_catArray select _itemCountIndex}
			else {1};
		//return
		[_categoryIndex,_itemIndex,_itemCountIndex,_itemCount]
	};

	//Find item in 'source' collection
	private _sourceCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_ISHOP_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_ISHOP_CLI_shopItems",[]]};
	([_item,_sourceCollection] call _findInCollection) params ["_categoryIndex","_itemIndex","_itemCountIndex","_itemCount"];
	if (_categoryIndex == -1) exitWith {
		"NWG_ISHOP_CLI_OnListDobuleClick: Item not found in collection" call NWG_fnc_logError;
	};
	if (_itemIndex == -1) exitWith {
		"NWG_ISHOP_CLI_OnListDobuleClick: Item not found in category" call NWG_fnc_logError;//Should not happen
	};

	//Define sell|buy (in other words - move to another collection) count
	private _moveCount = _itemCount min _multiplier;//Whatever is smaller
	if (_moveCount == 0) exitWith {
		"NWG_ISHOP_CLI_OnListDobuleClick: Move count can't be zero" call NWG_fnc_logError;
	};
	private _moveAll = _moveCount == _itemCount;

	//Try adding to transaction record (also updates player money)
	private _ok = [_item,_moveCount,!_isPlayerSide] call NWG_ISHOP_CLI_TRA_TryAddToTransaction;
	if (!_ok) exitWith {
		//Not enough money
		[(NWG_ISHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_ERROR"),2] call NWG_ISHOP_CLI_BlinkPlayerMoney;
	};

	//Remove from 'source' collection (_itemCount can be only >= _moveCount and never less)
	private _catArray = _sourceCollection#_categoryIndex;
	if (_moveAll) then {
		//Bought|Sold all item instances
		_catArray deleteAt _itemIndex;//Remove item itself
		if (_itemCountIndex != -1) then {_catArray deleteAt _itemCountIndex};//Remove item count
	} else {
		//There are more items in collection than we need to move (also means that _itemCount > 1 and _itemCountIndex != -1)
		_catArray set [_itemCountIndex,((_catArray#_itemCountIndex)-_moveCount)];
	};

	//Move to 'target' collection
	private _targetCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_ISHOP_CLI_shopItems",[]]}
		else {uiNamespace getVariable ["NWG_ISHOP_CLI_playerLoot",[]]};
	([_item,_targetCollection] call _findInCollection) params ["","_itemIndex","_itemCountIndex","_itemCount"];
	private _catArray = _targetCollection#_categoryIndex;
	switch (true) do {
		case (_itemIndex == -1): {
			//Item not found in target collection, add new
			if (_moveCount > 1) then {_catArray pushBack _moveCount};
			_catArray pushBack _item;
		};
		case (_itemCountIndex == -1): {
			//Item found, but only one instance - we must insert new count
			private _tail = _catArray select [_itemIndex];
			_catArray resize _itemIndex;
			_catArray pushBack (_moveCount + 1);
			_catArray append _tail;
		};
		default {
			//Item found and has more than one instance, just add count
			_catArray set [_itemCountIndex,((_catArray#_itemCountIndex)+_moveCount)];
		};
	};

	//Re-save collections
	if (_isPlayerSide) then {
		uiNamespace setVariable ["NWG_ISHOP_CLI_playerLoot",_sourceCollection];
		uiNamespace setVariable ["NWG_ISHOP_CLI_shopItems",_targetCollection];
	} else {
		uiNamespace setVariable ["NWG_ISHOP_CLI_shopItems",_sourceCollection];
		uiNamespace setVariable ["NWG_ISHOP_CLI_playerLoot",_targetCollection];
	};

	//Update UI
	[_isPlayerSide,"",_moveAll] call NWG_ISHOP_CLI_UpdateItemsList;//Update source list
	[!_isPlayerSide,"",false] call NWG_ISHOP_CLI_UpdateItemsList;//Update target list
	(call NWG_ISHOP_CLI_TRA_GetPlayerMoney) call NWG_ISHOP_CLI_UpdatePlayerMoneyText;//Update player money text
	[(NWG_ISHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_SUCCESS"),1] call NWG_ISHOP_CLI_BlinkPlayerMoney;//Blink player money
};

//================================================================================================================
//================================================================================================================
//Transaction
NWG_ISHOP_CLI_TRA_OnOpen = {
	params ["_allItems","_allPrices"];

	private _pricesMap = createHashMap;
	{_pricesMap set [_x,(_allPrices select _forEachIndex)]} forEach _allItems;
	private _playerMoney = player call NWG_fnc_wltGetPlayerMoney;

	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_pricesMap",_pricesMap];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_soldToPlayer",[]];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_boughtFromPlayer",[]];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_playerMoney",_playerMoney];
};

NWG_ISHOP_CLI_TRA_GetPlayerMoney = {
	uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_playerMoney",0]
};

NWG_ISHOP_CLI_TRA_GetPrice = {
	params ["_item","_isPlayerSide"];
	private _price = (uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_pricesMap",createHashMap]) getOrDefault [_item,0];
	private _multiplier = if (_isPlayerSide)
		then {NWG_ISHOP_CLI_Settings get "PRICE_BUY_FROM_PLAYER_MULTIPLIER"}
		else {NWG_ISHOP_CLI_Settings get "PRICE_SELL_TO_PLAYER_MULTIPLIER"};
	//return
	(_price * _multiplier)
};

NWG_ISHOP_CLI_TRA_TryAddToTransaction = {
	params ["_item","_count","_isSellingToPlayer"];
	private _price = ([_item,!_isSellingToPlayer] call NWG_ISHOP_CLI_TRA_GetPrice) * _count;
	private _playerMoney = call NWG_ISHOP_CLI_TRA_GetPlayerMoney;

	//If buying from player
	if (!_isSellingToPlayer) exitWith {
		//Add to transaction
		private _trArray = uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_boughtFromPlayer",[]];
		_trArray pushBack _count;
		_trArray pushBack _item;
		uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_boughtFromPlayer",_trArray];
		//Add to player money
		uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_playerMoney",(_playerMoney + _price)];
		//return
		true
	};

	//If selling to player
	//Check if player has enough money
	if (_price > _playerMoney) exitWith {
		//Not enough money
		false
	};

	//Add to transaction
	private _trArray = uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_soldToPlayer",[]];
	_trArray pushBack _count;
	_trArray pushBack _item;
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_soldToPlayer",_trArray];
	//Subtract from player money
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_playerMoney",(_playerMoney - _price)];
	//return
	true
};

NWG_ISHOP_CLI_TRA_OnClose = {
	//Form transaction report
	//Get transactions
	private _soldToPlayer = uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_soldToPlayer",[]];
	private _boughtFromPlayer = uiNamespace getVariable ["NWG_ISHOP_CLI_TRA_boughtFromPlayer",[]];

	//Filter out mutual records (same item bought and sold in one session) (also compacts arrays)
	_soldToPlayer = _soldToPlayer call NWG_fnc_unCompactStringArray;
	_boughtFromPlayer = _boughtFromPlayer call NWG_fnc_unCompactStringArray;
	private _i = -1;
	{
		_i = _soldToPlayer find _x;
		if (_i != -1) then {
			//Mutual annihilation
			_soldToPlayer deleteAt _i;
			_boughtFromPlayer deleteAt _forEachIndex;
		};
	} forEachReversed _boughtFromPlayer;
	_soldToPlayer = _soldToPlayer call NWG_fnc_compactStringArray;
	_boughtFromPlayer = _boughtFromPlayer call NWG_fnc_compactStringArray;

	//Send transaction report to server
	if ((count _soldToPlayer) > 0 || {count _boughtFromPlayer > 0}) then {
		[_soldToPlayer,_boughtFromPlayer] remoteExec ["NWG_fnc_ishopReportTransaction",2];
	};

	//Update player money
	private _playerVirtualMoney = call NWG_ISHOP_CLI_TRA_GetPlayerMoney;
	private _playerActualMoney = player call NWG_fnc_wltGetPlayerMoney;
	private _delta = _playerVirtualMoney - _playerActualMoney;
	if (_delta != 0) then {
		[player,(round _delta)] call NWG_fnc_wltAddPlayerMoney;
	};

	//Update player loot
	private _playerVirtualLoot = uiNamespace getVariable ["NWG_ISHOP_CLI_playerLoot",[]];
	private _playerActualLoot = player call (NWG_ISHOP_CLI_Settings get "SHOP_GET_PLAYER_LOOT_FUNC");
	if (_playerVirtualLoot isNotEqualTo _playerActualLoot) then {
		//We have a new loot
		[player,_playerVirtualLoot] call (NWG_ISHOP_CLI_Settings get "SHOP_SET_PLAYER_LOOT_FUNC");
	};

	//Dispose uiNamespace variables
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_pricesMap",nil];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_soldToPlayer",nil];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_boughtFromPlayer",nil];
	uiNamespace setVariable ["NWG_ISHOP_CLI_TRA_playerMoney",nil];
};
