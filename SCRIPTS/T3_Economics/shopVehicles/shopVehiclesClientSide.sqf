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

//Additional vehicle type
#define LOOT_VEHC_TYPE_ALL "ALL"

//Shop types
#define SHOP_TYPE_PLATFM "PLATFM"
#define SHOP_TYPE_MOBILE "MOBILE"

//Platform check result
#define PLATFORM_ERROR -1
#define PLATFORM_OK 0
#define PLATFORM_OCCUPIED 1

//================================================================================================================
//================================================================================================================
//Settings
NWG_VSHOP_CLI_Settings = createHashMapFromArray [
	["PRICE_SELL_TO_PLAYER_MULTIPLIER",1.3],
	["PRICE_BUY_FROM_PLAYER_MULTIPLIER",0.7],
	["PRICE_REDUCE_BY_DAMAGE",true],//If true, price will be reduced by damage of the vehicle

	["GROUP_LEADER_MANAGES_GROUP_VEHICLES",true],//If true, group leader will be able to sell all vehicles of the group
	["GROUP_LEADER_MANAGES_GROUP_MONEY",true],//If true, group leader will buy vehicles for combined group money and when selling will split money between group members

	["SELL_DISTANCE",100],//Distance at which vehicles can be sold
	["SELL_DAMAGE_MULTIPLIER",0.5],//Multiplier for price reduction by damage (%50 dmg with multiplier 0.5 will reduce price by 25%)

	["PLAYER_MONEY_BLINK_COLOR_ON_ERROR",[1,0,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_ON_SUCCESS",[0,1,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON",0.3],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF",0.2],

	["ITEM_LIST_NAME_LIMIT",30],//Max number of letters for the item name
	["ITEM_LIST_TEMPLATE_W_CONDITION","%1 [%2%%] (%3)"],//Item list format string
	["ITEM_LIST_TEMPLATE_NO_CONDITION","%1 (%2)"],//Item list format string
	["ITEM_LIST_PICTURE_TYPE","editorPreview"],//Type of picture to use for the item (options: "picture", "icon", "editorPreview")

	["",0]
];

//================================================================================================================
//================================================================================================================
//Shop
NWG_VSHOP_CLI_shopType = SHOP_TYPE_PLATFM;
NWG_VSHOP_CLI_OpenPlatformShop = {
	//Check platform
	if ((call NWG_VSHOP_CLI_CheckPlatform) == PLATFORM_ERROR) exitWith {false};//Errors logged in check function

	//Get owned vehicles and convert them for sale
	private _ownedVehicles = call NWG_VSHOP_CLI_GetOwnedVehicles;
	private _ownedVehiclesClassnames = _ownedVehicles apply {(typeOf _x) call NWG_fnc_vcatGetUnifiedClassname};

	//Save shop type for when server responds
	NWG_VSHOP_CLI_shopType = SHOP_TYPE_PLATFM;

	//Request shop values from server
	[player,_ownedVehiclesClassnames] remoteExec ["NWG_fnc_vshopShopValuesRequest",2];

	//The rest will be done once server responds
};

NWG_VSHOP_CLI_OnServerResponse = {
	disableSerialization;
	params ["_shopItems","_allItems","_allPrices"];

	//Re-get owned vehicles (things could have changed since request)
	private _ownedVehicles = call NWG_VSHOP_CLI_GetOwnedVehicles;
	private _ownedVehiclesClassnames = _ownedVehicles apply {(typeOf _x) call NWG_fnc_vcatGetUnifiedClassname};
	{
		if !(_x in _allItems) then {
			_ownedVehiclesClassnames deleteAt _forEachIndex;
			_ownedVehicles deleteAt _forEachIndex;
		};
	} forEachReversed _ownedVehiclesClassnames;

	//Compile owned vehicles classnames into categories for UI categories dropdown
	private _playerLoot = LOOT_VEHC_DEFAULT_CHART;
	{
		switch (_x call NWG_fnc_vcatGetVehcType) do {
			case LOOT_VEHC_TYPE_AAIR: {(_playerLoot#LOOT_VEHC_CAT_AAIR) pushBack _x};
			case LOOT_VEHC_TYPE_APCS: {(_playerLoot#LOOT_VEHC_CAT_APCS) pushBack _x};
			case LOOT_VEHC_TYPE_ARTY: {(_playerLoot#LOOT_VEHC_CAT_ARTY) pushBack _x};
			case LOOT_VEHC_TYPE_BOAT: {(_playerLoot#LOOT_VEHC_CAT_BOAT) pushBack _x};
			case LOOT_VEHC_TYPE_CARS: {(_playerLoot#LOOT_VEHC_CAT_CARS) pushBack _x};
			case LOOT_VEHC_TYPE_DRON: {(_playerLoot#LOOT_VEHC_CAT_DRON) pushBack _x};
			case LOOT_VEHC_TYPE_HELI: {(_playerLoot#LOOT_VEHC_CAT_HELI) pushBack _x};
			case LOOT_VEHC_TYPE_PLAN: {(_playerLoot#LOOT_VEHC_CAT_PLAN) pushBack _x};
			case LOOT_VEHC_TYPE_SUBM: {(_playerLoot#LOOT_VEHC_CAT_SUBM) pushBack _x};
			case LOOT_VEHC_TYPE_TANK: {(_playerLoot#LOOT_VEHC_CAT_TANK) pushBack _x};
			default {
				(format ["NWG_VSHOP_CLI_OnServerResponse: Vehicle: '%1', Unknown vehicle type '%2'",_x,(_x call NWG_fnc_vcatGetVehcType)]) call NWG_fnc_logError;
			};
		};
	} forEach _ownedVehiclesClassnames;

	//Check if shop dialog is already open
	if (!isNull (findDisplay IDC_SHOPUI_DIALOGUE)) exitWith {
		"NWG_VSHOP_CLI_OnServerResponse: Shop dialog is already open" call NWG_fnc_logError;
	};

	//Create shop dialog
	private _shopGUI = createDialog [SHOP_UI_DIALOGUE_NAME,true];
	if (isNull _shopGUI) exitWith {
		"NWG_VSHOP_CLI_OnServerResponse: Failed to create shop dialog" call NWG_fnc_logError;
	};
	uiNamespace setVariable ["NWG_VSHOP_CLI_shopGUI",_shopGUI];

	//Save shop arguments
	private _sellPool = [_ownedVehicles,_ownedVehiclesClassnames];//Relation between unified classnames and actual vehicle objects
	uiNamespace setVariable ["NWG_VSHOP_CLI_sellPool",_sellPool];
	uiNamespace setVariable ["NWG_VSHOP_CLI_playerLoot",_playerLoot];
	uiNamespace setVariable ["NWG_VSHOP_CLI_shopItems",_shopItems];

	//Init transaction
	[_allItems,_allPrices] call NWG_VSHOP_CLI_TRA_OnOpen;

	//Initialize UI top to bottom
	//Init player money
	(call NWG_VSHOP_CLI_TRA_GetPlayerMoney) call NWG_VSHOP_CLI_UpdatePlayerMoneyText;
	//Init shop money (does not change)
	(_shopGUI displayCtrl IDC_SHOPUI_SHOPMONEYTEXT) ctrlSetText ("#VSHOP_SELLER_MONEY_CONST#" call NWG_fnc_localize);

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
			[LOOT_VEHC_TYPE_ALL,"#VSHOP_CAT_ALL#"],
			[LOOT_VEHC_TYPE_AAIR,"#VSHOP_CAT_AAIR#"],
			[LOOT_VEHC_TYPE_APCS,"#VSHOP_CAT_APCS#"],
			[LOOT_VEHC_TYPE_ARTY,"#VSHOP_CAT_ARTY#"],
			[LOOT_VEHC_TYPE_BOAT,"#VSHOP_CAT_BOAT#"],
			[LOOT_VEHC_TYPE_CARS,"#VSHOP_CAT_CARS#"],
			[LOOT_VEHC_TYPE_DRON,"#VSHOP_CAT_DRON#"],
			[LOOT_VEHC_TYPE_HELI,"#VSHOP_CAT_HELI#"],
			[LOOT_VEHC_TYPE_PLAN,"#VSHOP_CAT_PLAN#"],
			[LOOT_VEHC_TYPE_SUBM,"#VSHOP_CAT_SUBM#"],
			[LOOT_VEHC_TYPE_TANK,"#VSHOP_CAT_TANK#"]
		];
		_dropdown lbSetCurSel 0;

		//Set callback
		_dropdown setVariable ["isPlayerSide",_isPlayerSide];
		_dropdown ctrlAddEventHandler ["LBSelChanged",{_this call NWG_VSHOP_CLI_OnDropdownSelect}];
	} forEach [
		[IDC_SHOPUI_PLAYERDROPDOWN,true],
		[IDC_SHOPUI_SHOPDROPDOWN,  false]
	];
	uiNamespace setVariable ["NWG_VSHOP_CLI_plListCat",LOOT_VEHC_TYPE_ALL];
	uiNamespace setVariable ["NWG_VSHOP_CLI_shListCat",LOOT_VEHC_TYPE_ALL];

	//Disable multiplier buttons (has no sense for vehicles)
	{
		private _button = _shopGUI displayCtrl _x;
		_button ctrlEnable false;
		_button ctrlShow false;
	} forEach [
		IDC_SHOPUI_PLAYERX1BUTTON,
		IDC_SHOPUI_PLAYERX10BUTTON,
		IDC_SHOPUI_PLAYERALLBUTTON,
		IDC_SHOPUI_SHOPX1BUTTON,
		IDC_SHOPUI_SHOPX10BUTTON,
		IDC_SHOPUI_SHOPALLBUTTON
	];

	//Init player and shop lists
	private _plList = (_shopGUI displayCtrl IDC_SHOPUI_PLAYERLIST);
	private _shList = (_shopGUI displayCtrl IDC_SHOPUI_SHOPLIST);
	_plList setVariable ["isPlayerSide",true];
	_shList setVariable ["isPlayerSide",false];
	uiNamespace setVariable ["NWG_VSHOP_CLI_plList",_plList];
	uiNamespace setVariable ["NWG_VSHOP_CLI_shList",_shList];
	[true,LOOT_VEHC_TYPE_ALL] call NWG_VSHOP_CLI_UpdateItemsList;
	[false,LOOT_VEHC_TYPE_ALL] call NWG_VSHOP_CLI_UpdateItemsList;
	_plList ctrlAddEventHandler ["LBDblClick",{_this call NWG_VSHOP_CLI_OnListDobuleClick}];
	_shList ctrlAddEventHandler ["LBDblClick",{_this call NWG_VSHOP_CLI_OnListDobuleClick}];

	//On close
	_shopGUI displayAddEventHandler ["Unload",{
		//Finalize transaction
		call NWG_VSHOP_CLI_TRA_OnClose;

		//Dispose variables
		uiNamespace setVariable ["NWG_VSHOP_CLI_shopGUI",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_sellPool",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_playerLoot",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_shopItems",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_plListCat",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_shListCat",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_plList",nil];
		uiNamespace setVariable ["NWG_VSHOP_CLI_shList",nil];
    }];
};

//================================================================================================================
//================================================================================================================
//Platform utils
NWG_VSHOP_CLI_CheckPlatform = {
	//Check platform object existence
	private _platform = NWG_VSHOP_spawnPlatform;
	if (isNil "_platform") exitWith {
		(format ["NWG_VSHOP_CLI_CheckPlatform: Spawn platform is not set"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};
	if !(_platform isEqualType objNull) exitWith {
		(format ["NWG_VSHOP_CLI_CheckPlatform: Spawn platform is not an object"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};
	if (isNull _platform) exitWith {
		(format ["NWG_VSHOP_CLI_CheckPlatform: Spawn platform is null"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};

	//Check that platform is empty
	private _platformRadius = (0 boundingBoxReal _platform)#2;
	private _obstacles = _platform nearEntities [["Man","Car","Tank","Helicopter","Plane","Ship"],_platformRadius];
	if ((count _obstacles) == 0) exitWith {PLATFORM_OK};//<= Exit if no obstacles found

	//Remove platform and player from the list
	_obstacles = _obstacles - [_platform,player];
	if ((count _obstacles) == 0) exitWith {PLATFORM_OK};//<= Exit if no obstacles found

	//Try deleting dead obstacles
	private _deadObstacles = _obstacles select {!alive _x};
	if ((count _deadObstacles) > 0) then {
		_obstacles = _obstacles - _deadObstacles;
		{_x call NWG_fnc_vshopDeleteVehicle} forEach _deadObstacles;
	};

	//return
	if ((count _obstacles) == 0)
		then {PLATFORM_OK}
		else {PLATFORM_OCCUPIED};
};

//================================================================================================================
//================================================================================================================
//Vehicle ownership utils
NWG_VSHOP_CLI_GetOwnedVehicles = {
	//Get raw list of owned vehicles
	private _getGroupVehicles = (NWG_VSHOP_CLI_Settings get "GROUP_LEADER_MANAGES_GROUP_VEHICLES") && {player isEqualTo (leader (group player))};
	private _ownedVehicles = if (_getGroupVehicles)
		then {flatten ((units (group player)) apply {_x call NWG_fnc_vownGetOwnedVehicles})}
		else {player call NWG_fnc_vownGetOwnedVehicles};
	if ((count _ownedVehicles) == 0) exitWith {_ownedVehicles};//<= Exit if no vehicles owned

	//Filter out dead vehicles and duplicates
	_ownedVehicles = _ownedVehicles select {alive _x};
	_ownedVehicles = _ownedVehicles arrayIntersect _ownedVehicles;

	//Filter out vehicles that can not be sold
	_ownedVehicles = _ownedVehicles select {_x call NWG_VSHOP_CLI_CanSellOwnedVehicle};

	//return
	_ownedVehicles
};

NWG_VSHOP_CLI_CanSellOwnedVehicle = {
	// private _vehicle = _this;

	//Null check
	if (isNull _this) exitWith {
		"NWG_VSHOP_CLI_CanSellOwnedVehicle: Vehicle is null" call NWG_fnc_logError;
		false
	};

	//Vehicle state checks
	if !(alive _this) exitWith {false};//Check that vehicle is alive
	if ((count (crew _this)) > 0) exitWith {false};//Check that vehicle is not occupied

	//Check that vehicle is in the sell distance to the platform
	private _platform = NWG_VSHOP_spawnPlatform;
	if (isNil "_platform" || {!(_platform isEqualType objNull) || {isNull _platform}}) then {
		(format ["NWG_VSHOP_CLI_CanSellOwnedVehicle: Spawn platform is invalid, fallback to player instance"]) call NWG_fnc_logError;
		_platform = player;
	};
	if ((_this distance _platform) > (NWG_VSHOP_CLI_Settings get "SELL_DISTANCE")) exitWith {false};

	//Checks passed - return
	true
};

//'damage _vehicle' is unreliable and returns '0' even when the engine is red, hull is destroyed and wheels are flying off
//(in other words - another Arma moment)
//this function calculates damage based on the average damage of all hitpoints
NWG_VSHOP_CLI_GetDamageOfOwnedVehicle = {
	// private _vehicle = _this;
	(getAllHitPointsDamage _this) params ["",["_selection",[]],["_dmg",[]]];
	private _dmgCount = 0;
	private _dmgSum = 0;
	{
		//Count non-empty selections only.
		//For offroad those those are 'glass' and they are many, so they affect the average a lot
		if ((_selection#_forEachIndex) isNotEqualTo "") then {
			_dmgCount = _dmgCount + 1;
			_dmgSum = _dmgSum + _x;
		};
	} forEach _dmg;
	if (_dmgCount == 0) exitWith {0};//Prevent division by zero
	//return
	_dmgSum / _dmgCount
};

//================================================================================================================
//================================================================================================================
//Player money indicator
NWG_VSHOP_CLI_UpdatePlayerMoneyText = {
	disableSerialization;
	private _playerMoney = _this;
	private _shopGUI = uiNamespace getVariable ["NWG_VSHOP_CLI_shopGUI",displayNull];
	if (isNull _shopGUI) exitWith {
		"NWG_VSHOP_CLI_UpdatePlayerMoneyText: Shop GUI is null" call NWG_fnc_logError;
	};
	(_shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT) ctrlSetText (_playerMoney call NWG_fnc_wltFormatMoney);
};

NWG_VSHOP_CLI_blinkHandle = scriptNull;
NWG_VSHOP_CLI_BlinkPlayerMoney = {
	// params ["_color","_times"];
	if (!isNull NWG_VSHOP_CLI_blinkHandle && {!scriptDone NWG_VSHOP_CLI_blinkHandle}) then {
		terminate NWG_VSHOP_CLI_blinkHandle;
	};

	NWG_VSHOP_CLI_blinkHandle = _this spawn {
		disableSerialization;
		params ["_color","_times"];
		private _shopGUI = uiNamespace getVariable ["NWG_VSHOP_CLI_shopGUI",displayNull];
		if (isNull _shopGUI) exitWith {
			"NWG_VSHOP_CLI_BlinkPlayerMoney: Shop GUI is null" call NWG_fnc_logError;
		};
		private _textCtrl = _shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT;
		if (isNull _textCtrl) exitWith {
			"NWG_VSHOP_CLI_BlinkPlayerMoney: Text control is null" call NWG_fnc_logError;
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
				sleep (NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON");
			} else {
				//Turn off
				_textCtrl ctrlSetBackgroundColor _origColor;
				sleep (NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF");
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
NWG_VSHOP_CLI_OnDropdownSelect = {
	params ["_control","_lbCurSel"];
	private _listCat = _control lbData _lbCurSel;
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	[_isPlayerSide,_listCat] call NWG_VSHOP_CLI_UpdateItemsList;
};

//================================================================================================================
//================================================================================================================
//Items lists
NWG_VSHOP_CLI_UpdateItemsList = {
	disableSerialization;
	params ["_isPlayerSide",["_listCat",""],["_dropSelection",true]];

	private _list = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_VSHOP_CLI_plList",controlNull]}
		else {uiNamespace getVariable ["NWG_VSHOP_CLI_shList",controlNull]};

	if (_listCat isEqualTo "")
		then {_listCat = _list getVariable ["listCat",LOOT_VEHC_TYPE_ALL]}
		else {_list setVariable ["listCat",_listCat]};

	private _itemsCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_VSHOP_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_VSHOP_CLI_shopItems",[]]};

	private _itemsToShow = switch (_listCat) do {
		case LOOT_VEHC_TYPE_ALL: {flatten _itemsCollection};
		case LOOT_VEHC_TYPE_AAIR: {_itemsCollection#LOOT_VEHC_CAT_AAIR};
		case LOOT_VEHC_TYPE_APCS: {_itemsCollection#LOOT_VEHC_CAT_APCS};
		case LOOT_VEHC_TYPE_ARTY: {_itemsCollection#LOOT_VEHC_CAT_ARTY};
		case LOOT_VEHC_TYPE_BOAT: {_itemsCollection#LOOT_VEHC_CAT_BOAT};
		case LOOT_VEHC_TYPE_CARS: {_itemsCollection#LOOT_VEHC_CAT_CARS};
		case LOOT_VEHC_TYPE_DRON: {_itemsCollection#LOOT_VEHC_CAT_DRON};
		case LOOT_VEHC_TYPE_HELI: {_itemsCollection#LOOT_VEHC_CAT_HELI};
		case LOOT_VEHC_TYPE_PLAN: {_itemsCollection#LOOT_VEHC_CAT_PLAN};
		case LOOT_VEHC_TYPE_SUBM: {_itemsCollection#LOOT_VEHC_CAT_SUBM};
		case LOOT_VEHC_TYPE_TANK: {_itemsCollection#LOOT_VEHC_CAT_TANK};
		default {
			"NWG_VSHOP_CLI_UpdateItemsList: Invalid category" call NWG_fnc_logError;
			[]
		};
	};

	//Clear list
	lbClear _list;

	//Fill list
	private _i = -1;
	//forEach _itemsToShow
	{
		(_x call NWG_VSHOP_CLI_GetItemInfo) params ["_picture","_displayName"];
		([_x,_isPlayerSide] call NWG_VSHOP_CLI_TRA_GetPrice) params ["_price","_condition"];

		_i = _list lbAdd ([_displayName,_price,_condition] call NWG_VSHOP_CLI_FormatListRecord);//Add formatted record
		_list lbSetData [_i,_x];//Set data (item classname)
		_list lbSetPicture [_i, _picture];//Set picture
	} forEach _itemsToShow;

	//Drop selection
	if (_dropSelection) then {_list lbSetCurSel -1};
};

NWG_VSHOP_CLI_itemInfoCache = createHashMap;
NWG_VSHOP_CLI_GetItemInfo = {
	// private _item = _this;

	//Try cache first
	private _cached = NWG_VSHOP_CLI_itemInfoCache get _this;
	if (!isNil "_cached") exitWith {_cached};

	//Get vehicle config
	private _cfg = configFile >> "CfgVehicles" >> _this;
	if !(isClass _cfg) exitWith {
		(format ["NWG_VSHOP_CLI_GetItemInfo: Item '%1' not found in CfgVehicles",_this]) call NWG_fnc_logError;
		["",""]
	};

	//Get config values
	private _picture = getText (_cfg >> (NWG_VSHOP_CLI_Settings get "ITEM_LIST_PICTURE_TYPE"));
	private _displayName = getText (_cfg >> "displayName");

	//Cache and return
	private _itemInfo = [_picture,_displayName];
	NWG_VSHOP_CLI_itemInfoCache set [_this,_itemInfo];
	_itemInfo
};

NWG_VSHOP_CLI_FormatListRecord = {
	params ["_displayName","_price","_condition"];

	//Limit display name
	private _limit = NWG_VSHOP_CLI_Settings get "ITEM_LIST_NAME_LIMIT";
	if ((count _displayName) > _limit) then {
		//Shorten the string and replace last 3 letters with '...'
		_displayName = (_displayName select [0,(_limit-3)]) + "...";
	};

	//Format and return
	if (_condition >= 0) then {
		format [(NWG_VSHOP_CLI_Settings get "ITEM_LIST_TEMPLATE_W_CONDITION"),_displayName,_condition,(_price call NWG_fnc_wltFormatMoney)]
	} else {
		format [(NWG_VSHOP_CLI_Settings get "ITEM_LIST_TEMPLATE_NO_CONDITION"),_displayName,(_price call NWG_fnc_wltFormatMoney)]
	}
};

//================================================================================================================
//================================================================================================================
//Buy|Sell logic (on list double click)

NWG_VSHOP_CLI_OnListDobuleClick = {
	params ["_control","_selectedIndex"];

	//Gather UI variables
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	private _item = _control lbData _selectedIndex;
	if (_item isEqualTo "") exitWith {
		"NWG_VSHOP_CLI_OnListDobuleClick: Item is empty" call NWG_fnc_logError;
	};

	//Define collection search script (returns: [_catIndex,_itemIndex])
	private _findInCollection = {
		params ["_item","_collection"];

		private _categoryIndex = _collection findIf {_item in _x};
		if (_categoryIndex == -1) exitWith {[-1,-1]};

		private _catArray = _collection#_categoryIndex;
		private _itemIndex = _catArray find _item;
		if (_itemIndex == -1) exitWith {[_categoryIndex,-1]};

		//return
		[_categoryIndex,_itemIndex]
	};

	//Find item in 'source' collection
	private _sourceCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_VSHOP_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_VSHOP_CLI_shopItems",[]]};
	([_item,_sourceCollection] call _findInCollection) params ["_categoryIndex","_itemIndex"];
	if (_categoryIndex == -1) exitWith {
		"NWG_VSHOP_CLI_OnListDobuleClick: Item not found in collection" call NWG_fnc_logError;
	};
	if (_itemIndex == -1) exitWith {
		"NWG_VSHOP_CLI_OnListDobuleClick: Item not found in category" call NWG_fnc_logError;//Should not happen
	};

	//Check platform for buying vehicles in SHOP_TYPE_PLATFM mode
	private _ok = call {
		if (_isPlayerSide) exitWith {true};//Double click on player side - Means we're selling - skip platform check
		if (NWG_VSHOP_CLI_shopType isNotEqualTo SHOP_TYPE_PLATFM) exitWith {true};//Not in PLATFM mode - skip platform check
		//return
		(call NWG_VSHOP_CLI_CheckPlatform) == PLATFORM_OK
	};
	if (!_ok) exitWith {
		//Platform is occupied
		[(NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_ERROR"),2] call NWG_VSHOP_CLI_BlinkPlayerMoney;
		"#VSHOP_PLATFORM_OCCUPIED#" call NWG_fnc_systemChatMe;
	};

	//Check that vehicle can be sold
	_ok = call {
		if (!_isPlayerSide) exitWith {true};//Double click on shop side - Means we're buying - skip vehicle sell check
		private _vehicle = [_item,false] call NWG_VSHOP_CLI_GetVehicleFromSellPool;
		if (isNull _vehicle) exitWith {false};//Vehicle not found - can not sell
		//return
		_vehicle call NWG_VSHOP_CLI_CanSellOwnedVehicle
	};
	if (!_ok) exitWith {
		//Vehicle can not be sold
		[(NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_ERROR"),2] call NWG_VSHOP_CLI_BlinkPlayerMoney;
		"#VSHOP_CANNOT_SELL_VEHICLE#" call NWG_fnc_systemChatMe;
	};

	//Try adding to transaction record (also updates player money)
	_ok = [_item,!_isPlayerSide] call NWG_VSHOP_CLI_TRA_TryAddToTransaction;
	if (!_ok) exitWith {
		//Not enough money
		[(NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_ERROR"),2] call NWG_VSHOP_CLI_BlinkPlayerMoney;
	};

	//Remove from 'source' collection
	private _catArray = _sourceCollection#_categoryIndex;
	_catArray deleteAt _itemIndex;

	//Move to 'target' collection
	private _targetCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_VSHOP_CLI_shopItems",[]]}
		else {uiNamespace getVariable ["NWG_VSHOP_CLI_playerLoot",[]]};
	([_item,_targetCollection] call _findInCollection) params ["","_itemIndex"];
	if (_itemIndex != -1) then {
		//Insert item into target collection
		private _catArray = _targetCollection#_categoryIndex;
		private _temp = _catArray select [_itemIndex];
		_catArray resize _itemIndex;
		_catArray pushBack _item;
		_catArray append _temp;
	} else {
		//Add new item to target collection
		(_targetCollection#_categoryIndex) pushBack _item;
	};

	//Re-save collections
	if (_isPlayerSide) then {
		uiNamespace setVariable ["NWG_VSHOP_CLI_playerLoot",_sourceCollection];
		uiNamespace setVariable ["NWG_VSHOP_CLI_shopItems",_targetCollection];
	} else {
		uiNamespace setVariable ["NWG_VSHOP_CLI_shopItems",_sourceCollection];
		uiNamespace setVariable ["NWG_VSHOP_CLI_playerLoot",_targetCollection];
	};

	//Update UI
	[_isPlayerSide,"",true] call NWG_VSHOP_CLI_UpdateItemsList;//Update source list
	[!_isPlayerSide,"",false] call NWG_VSHOP_CLI_UpdateItemsList;//Update target list
	(call NWG_VSHOP_CLI_TRA_GetPlayerMoney) call NWG_VSHOP_CLI_UpdatePlayerMoneyText;//Update player money text
	[(NWG_VSHOP_CLI_Settings get "PLAYER_MONEY_BLINK_COLOR_ON_SUCCESS"),1] call NWG_VSHOP_CLI_BlinkPlayerMoney;//Blink player money

	//Delete sold vehicle
	if (_isPlayerSide) exitWith {
		private _vehicle = [_item,true] call NWG_VSHOP_CLI_GetVehicleFromSellPool;
		if (isNull _vehicle) exitWith {
			"NWG_VSHOP_CLI_OnListDobuleClick: Vehicle not found in sell pool after check" call NWG_fnc_logError;
		};
		_vehicle remoteExec ["NWG_fnc_vshopDeleteVehicle",2];
	};

	//Place bought vehicle
	if (!_isPlayerSide) exitWith {
		[player,_item] remoteExec ["NWG_fnc_vshopSpawnVehicleAtPlatform",2];
	};
};

NWG_VSHOP_CLI_GetVehicleFromSellPool = {
	params ["_classname",["_withDelete",false]];

	private _sellPool = uiNamespace getVariable ["NWG_VSHOP_CLI_sellPool",[[],[]]];
	_sellPool params ["_vehicles","_classnames"];//[_ownedVehicles,_ownedVehiclesClassnames]
	private _i = _classnames find _classname;
	if (_i == -1) exitWith {
		// Do not log error here - happens all the time with freshly bought vehicle
		objNull
	};

	private _vehicle = _vehicles#_i;
	if (_withDelete) then {
		_vehicles deleteAt _i;
		_classnames deleteAt _i;
		uiNamespace setVariable ["NWG_VSHOP_CLI_sellPool",[_vehicles,_classnames]];
	};

	//return
	_vehicle
};

NWG_VSHOP_CLI_AddVehicleToSellPool = {
	private _vehicle = _this;

	//Check that shop UI is open
	private _shopGUI = uiNamespace getVariable ["NWG_VSHOP_CLI_shopGUI",displayNull];
	if (isNull _shopGUI) exitWith {};//Probably player closed shop UI by that time

	private _sellPool = uiNamespace getVariable ["NWG_VSHOP_CLI_sellPool",[[],[]]];
	_sellPool params ["_vehicles","_classnames"];//[_ownedVehicles,_ownedVehiclesClassnames]
	_vehicles pushBack _vehicle;
	_classnames pushBack ((typeOf _vehicle) call NWG_fnc_vcatGetUnifiedClassname);
	uiNamespace setVariable ["NWG_VSHOP_CLI_sellPool",[_vehicles,_classnames]];
};

//================================================================================================================
//================================================================================================================
//Transaction
NWG_VSHOP_CLI_TRA_OnOpen = {
	params ["_allItems","_allPrices"];

	//Form price matrix
	private _pricesMap = createHashMap;
	{_pricesMap set [_x,(_allPrices select _forEachIndex)]} forEach _allItems;

	//Get player side shop money
	private _getGroupMoney = (NWG_VSHOP_CLI_Settings get "GROUP_LEADER_MANAGES_GROUP_MONEY") && {player isEqualTo (leader (group player))};
	private _playerMoney = if (_getGroupMoney) then {
		private _groupMoney = (units (group player)) apply {_x call NWG_fnc_wltGetPlayerMoney};
		private _sum = 0;
		{_sum = _sum + _x} forEach _groupMoney;
		_sum
	} else {
		player call NWG_fnc_wltGetPlayerMoney
	};

	//Save transaction variables
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_pricesMap",_pricesMap];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_soldToPlayer",[]];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_boughtFromPlayer",[]];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_playerMoney",_playerMoney];
};

NWG_VSHOP_CLI_TRA_GetPlayerMoney = {
	uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_playerMoney",0]
};

NWG_VSHOP_CLI_TRA_GetPrice = {
	params ["_item","_isPlayerSide"];

	//Calculate price based on classname and transaction side
	private _price = (uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_pricesMap",createHashMap]) getOrDefault [_item,0];
	private _multiplier = if (_isPlayerSide)
		then {NWG_VSHOP_CLI_Settings get "PRICE_BUY_FROM_PLAYER_MULTIPLIER"}
		else {NWG_VSHOP_CLI_Settings get "PRICE_SELL_TO_PLAYER_MULTIPLIER"};
	_price = _price * _multiplier;

	//If we're selling to player - that's all (+ignore condition)
	if (!_isPlayerSide) exitWith {[_price,-1]};//<= Exit if selling to player

	//Else - we're buying from player - get their actual vehicle
	private _vehicle = [_item,false] call NWG_VSHOP_CLI_GetVehicleFromSellPool;
	if (isNull _vehicle) exitWith {
		//That is possible if player is selling the vehicle they just bought and server did not process that yet and did not add it to sell pool
		//Meaning vehicle is in pristine condition (at least that's what we'll assume)
		[_price,100]//<= Exit if vehicle not found in sell pool
	};

	//Calculate vehicle condition
	private _damage = _vehicle call NWG_VSHOP_CLI_GetDamageOfOwnedVehicle;
	_damage = _damage * 100;//dmg 0..1 -> 0..100
	_damage = round(_damage / 5) * 5;//Round damage to nearest 5 (0,5,10,15...90,95,100)
	_damage = (_damage max 0) min 100;//Clamp to 0-100
	private _condition = 100 - _damage;

	//Calculate price reduction by damage
	_damage = _damage * (NWG_VSHOP_CLI_Settings get "SELL_DAMAGE_MULTIPLIER");//Apply multiplier
	_damage = (_damage max 0) min 100;//Clamp again (to support multiplier -1 for example)
	if (_damage > 0) then {
		_price = _price * ((100 - _damage) / 100);
	};

	//return
	[_price,_condition]
};

NWG_VSHOP_CLI_TRA_TryAddToTransaction = {
	params ["_item","_isSellingToPlayer"];
	private _price = ([_item,!_isSellingToPlayer] call NWG_VSHOP_CLI_TRA_GetPrice) select 0;
	private _playerMoney = call NWG_VSHOP_CLI_TRA_GetPlayerMoney;

	//If buying from player
	if (!_isSellingToPlayer) exitWith {
		//Add to transaction
		private _trArray = uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_boughtFromPlayer",[]];
		_trArray pushBack _item;
		uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_boughtFromPlayer",_trArray];
		//Add to player money
		uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_playerMoney",(_playerMoney + _price)];
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
	private _trArray = uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_soldToPlayer",[]];
	_trArray pushBack _item;
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_soldToPlayer",_trArray];
	//Subtract from player money
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_playerMoney",(_playerMoney - _price)];
	//return
	true
};

NWG_VSHOP_CLI_TRA_OnClose = {
	//Form transaction report
	//Get transactions
	private _soldToPlayer = uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_soldToPlayer",[]];
	private _boughtFromPlayer = uiNamespace getVariable ["NWG_VSHOP_CLI_TRA_boughtFromPlayer",[]];

	//Filter out mutual records (same item bought and sold in one session) (+ compact arrays)
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
		[_soldToPlayer,_boughtFromPlayer] remoteExec ["NWG_fnc_vshopReportTransaction",2];
	};

	//Update player(s) money
	private _playerVirtualMoney = call NWG_VSHOP_CLI_TRA_GetPlayerMoney;
	private _splitMoney = (NWG_VSHOP_CLI_Settings get "GROUP_LEADER_MANAGES_GROUP_MONEY") && {player isEqualTo (leader (group player))};
	private _splitBetween = if (_splitMoney)
		then {(units (group player)) select {isPlayer _x}}/*This is the only place where we MUST filter out AI units*/
		else {[player]};
	private _playerActualMoney = 0;
	{_playerActualMoney = _playerActualMoney + (_x call NWG_fnc_wltGetPlayerMoney)} forEach _splitBetween;
	private _delta = _playerVirtualMoney - _playerActualMoney;
	switch (true) do {
		case (_delta > 0): {
			//Player(s) earned and each gets their share equally
			private _share = round (_delta / ((count _splitBetween) max 1));
			{[_x,_share] call NWG_fnc_wltAddPlayerMoney} forEach _splitBetween;
		};
		case (_delta < 0): {
			//Player(s) spent and each pays their share OR at least what they have
			private _balanced = [_delta,_splitBetween] call NWG_VSHOP_CLI_TRA_BalanceLosses;
			{[_x#0,_x#1] call NWG_fnc_wltAddPlayerMoney} forEach _balanced;
		};
		default {/*Delta is 0 - do nothing*/};
	};

	//Dispose uiNamespace variables
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_pricesMap",nil];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_soldToPlayer",nil];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_boughtFromPlayer",nil];
	uiNamespace setVariable ["NWG_VSHOP_CLI_TRA_playerMoney",nil];
};

NWG_VSHOP_CLI_TRA_BalanceLosses = {
	params ["_totalDebt","_players"];
	if ((count _players) == 0) exitWith {[]};//No players - nothing to balance
	if ((count _players) == 1) exitWith {[[(_players#0),_totalDebt]]};//Only one player - take all responsibility

	//Prepare variables
	_totalDebt = abs _totalDebt;
	private _balancing = _players apply {[_x,0,((_x call NWG_fnc_wltGetPlayerMoney) max 0)]};
	private _balanced = [];
	private _shareAbs = 0;
	private _iterations = 100;//Just in case

	//Balance debt in iterations
	private _newShare = 0;
	while {true} do {
		_iterations = _iterations - 1;
		_shareAbs = round (_totalDebt / ((count _balancing) max 1));

		{
			_x params ["_player","_curShare","_myMoney"];
			_newShare = _curShare + _shareAbs;
			if (_myMoney > _newShare) then {
				//Enough money - take their share
				_x set [1,_newShare];
				_totalDebt = _totalDebt - _shareAbs;
			} else {
				//Not enough money - take what they can pay
				_x set [1,_myMoney];
				_totalDebt = _totalDebt - (_myMoney - _curShare);
				_balancing deleteAt _forEachIndex;
				_balanced pushBack _x;
			};
		} forEachReversed _balancing;

		if ((count _balancing) == 0) exitWith {};
		if (_totalDebt <= 0) exitWith {
			_balanced append _balancing;
			_balancing resize 0;
		};
		if (_iterations <= 0) exitWith {
			"NWG_VSHOP_CLI_TRA_BalanceLosses: Exceeded max iterations" call NWG_fnc_logError;
			_balanced append _balancing;
			_balancing resize 0;
		};
	};

	//Balance the rest of the debt (if any) equally between players
	if (_totalDebt > 0) then {
		_shareAbs = round (_totalDebt / ((count _balanced) max 1));
		{_x set [1,((_x#1) + _shareAbs)]} forEach _balanced;
	};

	//Format to result
	private _result = _balanced apply {[(_x#0),-(_x#1)]};

	//return
	_result
};
