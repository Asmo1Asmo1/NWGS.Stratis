#include "..\..\globalDefines.h"
#include "garageDefines.h"

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

//Platform check result
#define PLATFORM_ERROR -1
#define PLATFORM_OK 0
#define PLATFORM_OCCUPIED 1

//================================================================================================================
//================================================================================================================
//Settings
NWG_GRG_CLI_Settings = createHashMapFromArray [
	["MIN_DISTANCE",100],//Distance at which vehicles can be put into garage
	["MAX_CAPACITY",3],//Maximum number of vehicles that can be stored in garage

	["ITEM_LIST_PICTURE_TYPE","editorPreview"],//Type of picture to use for the item (options: "picture", "icon", "editorPreview")

	["",0]
];

//================================================================================================================
//================================================================================================================
//UI representation
NWG_GRG_CLI_OpenGaragePlatform = {
	disableSerialization;

	//Checks
	if (!isNull (findDisplay IDC_SHOPUI_DIALOGUE)) exitWith {
		"NWG_GRG_CLI_OpenGaragePlatform: UI is already open" call NWG_fnc_logError;
		false
	};
	if ((call NWG_GRG_CLI_CheckPlatform) == PLATFORM_ERROR) exitWith {
		"NWG_GRG_CLI_OpenGaragePlatform: Platform error" call NWG_fnc_logError;
		false
	};

	//Create shop dialog
	private _shopGUI = createDialog [SHOP_UI_DIALOGUE_NAME,true];
	if (isNull _shopGUI) exitWith {
		"NWG_GRG_CLI_OnServerResponse: Failed to create shop dialog" call NWG_fnc_logError;
	};
	uiNamespace setVariable ["NWG_GRG_CLI_shopGUI",_shopGUI];

	//Get player owned vehicles
	private _playerLoot = call NWG_GRG_CLI_GetOwnedVehicles;
	_playerLoot = _playerLoot apply {_x call NWG_GRG_VehicleToGarageArray};
	_playerLoot = _playerLoot call NWG_GRG_CLI_SortItems;
	uiNamespace setVariable ["NWG_GRG_CLI_playerLoot",_playerLoot];

	//Get garage items (already formatted and sorted)
	private _shopItems = player call NWG_GRG_GetGarageArray;
	uiNamespace setVariable ["NWG_GRG_CLI_shopItems",_shopItems];

	//Initialize UI top rows
	(_shopGUI displayCtrl IDC_SHOPUI_PLAYERMONEYTEXT) ctrlSetText "";//Always empty
	call NWG_GRG_CLI_UpdateGarageCapacityUI;

	//Init category dropdowns
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
		_dropdown ctrlAddEventHandler ["LBSelChanged",{_this call NWG_GRG_CLI_OnDropdownSelect}];
	} forEach [
		[IDC_SHOPUI_PLAYERDROPDOWN,true],
		[IDC_SHOPUI_SHOPDROPDOWN,  false]
	];
	uiNamespace setVariable ["NWG_GRG_CLI_plListCat",LOOT_VEHC_TYPE_ALL];
	uiNamespace setVariable ["NWG_GRG_CLI_shListCat",LOOT_VEHC_TYPE_ALL];

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
	uiNamespace setVariable ["NWG_GRG_CLI_plList",_plList];
	uiNamespace setVariable ["NWG_GRG_CLI_shList",_shList];
	[true,LOOT_VEHC_TYPE_ALL] call NWG_GRG_CLI_UpdateItemsList;
	[false,LOOT_VEHC_TYPE_ALL] call NWG_GRG_CLI_UpdateItemsList;
	_plList ctrlAddEventHandler ["LBDblClick",{_this call NWG_GRG_CLI_OnListDobuleClick}];
	_shList ctrlAddEventHandler ["LBDblClick",{_this call NWG_GRG_CLI_OnListDobuleClick}];

	//On close
	_shopGUI displayAddEventHandler ["Unload",{
		//Finalize transaction
		call NWG_GRG_CLI_TRA_OnClose;

		//Dispose variables
		uiNamespace setVariable ["NWG_GRG_CLI_shopGUI",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_playerLoot",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_shopItems",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_plListCat",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_shListCat",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_plList",nil];
		uiNamespace setVariable ["NWG_GRG_CLI_shList",nil];
    }];
};

//================================================================================================================
//================================================================================================================
//Platform utils
NWG_GRG_CLI_CheckPlatform = {
	//Check platform object existence
	private _platform = NWG_GRG_SpawnPlatform;
	if (isNil "_platform") exitWith {
		(format ["NWG_GRG_CLI_CheckPlatform: Spawn platform is not set"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};
	if !(_platform isEqualType objNull) exitWith {
		(format ["NWG_GRG_CLI_CheckPlatform: Spawn platform is not an object"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};
	if (isNull _platform) exitWith {
		(format ["NWG_GRG_CLI_CheckPlatform: Spawn platform is null"]) call NWG_fnc_logError;
		PLATFORM_ERROR
	};

	//Check that platform is empty
	private _platformRadius = (0 boundingBoxReal _platform)#2;
	private _obstacles = _platform nearEntities [["Man","Car","Tank","Helicopter","Plane","Ship"],_platformRadius];
	if ((count _obstacles) == 0) exitWith {PLATFORM_OK};//<= Exit if no obstacles found

	//Remove AI units, player and platform itself (just in case) from the list
	private _toIgnore = _obstacles select {_x isKindOf "Man" && {!isPlayer _x}};
	_toIgnore pushBack _platform;
	_toIgnore pushBack player;
	_obstacles = _obstacles - _toIgnore;
	if ((count _obstacles) == 0) exitWith {PLATFORM_OK};//<= Exit if no obstacles found

	//Try deleting dead obstacles
	private _deadObstacles = _obstacles select {!alive _x};
	if ((count _deadObstacles) > 0) then {
		_obstacles = _obstacles - _deadObstacles;
		{_x call NWG_fnc_grgDeleteVehicle} forEach _deadObstacles;
	};

	//return
	if ((count _obstacles) == 0)
		then {PLATFORM_OK}
		else {PLATFORM_OCCUPIED};
};

//================================================================================================================
//================================================================================================================
//Vehicle ownership utils
NWG_GRG_CLI_GetOwnedVehicles = {
	//Get raw list of owned vehicles
	private _ownedVehicles = player call NWG_fnc_vownGetOwnedVehicles;
	if ((count _ownedVehicles) == 0) exitWith {[]};//<= Exit if no vehicles owned

	//Get spawn platform
	private _platform = NWG_GRG_SpawnPlatform;
	if (isNil "_platform" || {!(_platform isEqualType objNull) || {isNull _platform}}) then {
		(format ["NWG_GRG_CLI_GetOwnedVehicles: Spawn platform is invalid, fallback to player instance"]) call NWG_fnc_logError;
		_platform = player;
	};
	private _minDistance = NWG_GRG_CLI_Settings get "MIN_DISTANCE";

	//Filter and return
	_ownedVehicles select {
		alive _x && {
		((count ((crew _x) select {!unitIsUAV _x})) == 0) && {
		((_x distance _platform) <= _minDistance)}}
	}
};

//================================================================================================================
//================================================================================================================
//Top row UI utils
NWG_GRG_CLI_UpdateGarageCapacityUI = {
	disableSerialization;
	private _shopGUI = uiNamespace getVariable ["NWG_GRG_CLI_shopGUI",displayNull];
	private _shopItems = uiNamespace getVariable ["NWG_GRG_CLI_shopItems",[]];
	(_shopGUI displayCtrl IDC_SHOPUI_SHOPMONEYTEXT) ctrlSetText (format [
		"%1 / %2",
		(count _shopItems),
		(NWG_GRG_CLI_Settings get "MAX_CAPACITY")
	]);
};

NWG_GRG_CLI_BlinkTopRow = {
	params ["_success","_playerSide"];
	private _shopGUI = uiNamespace getVariable ["NWG_GRG_CLI_shopGUI",displayNull];
	private _idc = if (_playerSide) then {IDC_SHOPUI_PLAYERMONEYTEXT} else {IDC_SHOPUI_SHOPMONEYTEXT};
	if (_success)
		then {[_shopGUI,_idc] call NWG_fnc_uiHelperBlinkOnSuccess}
		else {[_shopGUI,_idc] call NWG_fnc_uiHelperBlinkOnError};
};

//================================================================================================================
//================================================================================================================
//Dropdowns
NWG_GRG_CLI_OnDropdownSelect = {
	params ["_control","_lbCurSel"];
	private _listCat = _control lbData _lbCurSel;
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	[_isPlayerSide,_listCat] call NWG_GRG_CLI_UpdateItemsList;
};

//================================================================================================================
//================================================================================================================
//Items lists
NWG_GRG_CLI_UpdateItemsList = {
	disableSerialization;
	params ["_isPlayerSide",["_listCat",""]];

	private _list = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_GRG_CLI_plList",controlNull]}
		else {uiNamespace getVariable ["NWG_GRG_CLI_shList",controlNull]};

	if (_listCat isEqualTo "")
		then {_listCat = _list getVariable ["listCat",LOOT_VEHC_TYPE_ALL]}
		else {_list setVariable ["listCat",_listCat]};

	private _itemsCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_GRG_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_GRG_CLI_shopItems",[]]};

	private _itemsToShow = if (_listCat isEqualTo LOOT_VEHC_TYPE_ALL)
		then {_itemsCollection}
		else {_itemsCollection select {((_x#GR_CLASSNAME) call NWG_fnc_vcatGetVehcType) isEqualTo _listCat}};

	//Fill list
	lbClear _list;
	private _classname = "";
	private _i = -1;
	{
		_classname = _x#GR_CLASSNAME;
		(_classname call NWG_GRG_CLI_GetItemInfo) params [["_displayName",""],["_picture",""]];
		_i = _list lbAdd _displayName;//Add display name
		_list lbSetData [_i,_classname];//Set data (item classname)
		_list lbSetPicture [_i,_picture];//Set picture
	} forEach _itemsToShow;
};

//================================================================================================================
//================================================================================================================
//Buy|Sell logic (on list double click)
NWG_GRG_CLI_OnListDobuleClick = {
	params ["_control","_selectedIndex"];

	//Gather UI variables
	private _isPlayerSide = _control getVariable ["isPlayerSide",true];
	private _className = _control lbData _selectedIndex;
	if (_className isEqualTo "") exitWith {
		"NWG_GRG_CLI_OnListDobuleClick: Item is empty" call NWG_fnc_logError;
	};

	//Find item in 'source' collection
	private _sourceCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_GRG_CLI_playerLoot",[]]}
		else {uiNamespace getVariable ["NWG_GRG_CLI_shopItems",[]]};
	private _sourceIndex = _sourceCollection findIf {(_x#GR_CLASSNAME) isEqualTo _className};
	if (_sourceIndex == -1) exitWith {
		"NWG_GRG_CLI_OnListDobuleClick: Item not found in source collection" call NWG_fnc_logError;
	};

	//Check platform for spawning vehicles
	private _ok = call {
		if (_isPlayerSide) exitWith {true};//Double click on player side - Means we're garaging - skip platform check
		(call NWG_GRG_CLI_CheckPlatform) == PLATFORM_OK
	};
	if (!_ok) exitWith {
		[false,false] call NWG_GRG_CLI_BlinkTopRow;
		"#VSHOP_PLATFORM_OCCUPIED#" call NWG_fnc_systemChatMe;
	};

	//Check garage capacity
	_ok = call {
		if (!_isPlayerSide) exitWith {true};//Double click on shop side - Means we're spawning - skip vehicle check
		(count (uiNamespace getVariable ["NWG_GRG_CLI_shopItems", []])) < (NWG_GRG_CLI_Settings get "MAX_CAPACITY")
	};
	if (!_ok) exitWith {
		[false,false] call NWG_GRG_CLI_BlinkTopRow;
	};

	//Check that vehicle can be 'garaged'
	_ok = call {
		if (!_isPlayerSide) exitWith {true};//Double click on shop side - Means we're spawning - skip vehicle check
		((call NWG_GRG_CLI_GetOwnedVehicles) findIf {(typeOf _x) isEqualTo _className}) != -1
	};
	if (!_ok) exitWith {
		[false,true] call NWG_GRG_CLI_BlinkTopRow;
		"#VSHOP_CANNOT_SELL_VEHICLE#" call NWG_fnc_systemChatMe;
	};

	//Move to 'target' collection
	private _targetCollection = if (_isPlayerSide)
		then {uiNamespace getVariable ["NWG_GRG_CLI_shopItems", []]}
		else {uiNamespace getVariable ["NWG_GRG_CLI_playerLoot",[]]};
	private _fullItem = _sourceCollection deleteAt _sourceIndex;
	_targetCollection pushBack _fullItem;
	_targetCollection = _targetCollection call NWG_GRG_CLI_SortItems;

	//Re-save collections
	if (_isPlayerSide) then {
		uiNamespace setVariable ["NWG_GRG_CLI_playerLoot",_sourceCollection];
		uiNamespace setVariable ["NWG_GRG_CLI_shopItems",_targetCollection];
	} else {
		uiNamespace setVariable ["NWG_GRG_CLI_shopItems",_sourceCollection];
		uiNamespace setVariable ["NWG_GRG_CLI_playerLoot",_targetCollection];
	};

	//Update UI
	[_isPlayerSide,""] call NWG_GRG_CLI_UpdateItemsList;//Update source list
	[!_isPlayerSide,""] call NWG_GRG_CLI_UpdateItemsList;//Update target list
	call NWG_GRG_CLI_UpdateGarageCapacityUI;//Update garage capacity indicator
	[true,_isPlayerSide] call NWG_GRG_CLI_BlinkTopRow;//Blink green

	//Spawn/Despawn actual vehicle
	if (_isPlayerSide) then {
		//Delete 'garaged' vehicle
		private _actualVehicles = call NWG_GRG_CLI_GetOwnedVehicles;
		private _vehIndex = _actualVehicles findIf {(typeOf _x) isEqualTo _className};
		if (_vehIndex == -1) exitWith {"NWG_GRG_CLI_OnListDobuleClick: Vehicle not found in owned vehicles after check" call NWG_fnc_logError};
		(_actualVehicles#_vehIndex) remoteExec ["NWG_fnc_grgDeleteVehicle",2];
	} else {
		//Spawn vehicle
		[player,_fullItem] remoteExec ["NWG_fnc_grgSpawnVehicle",2];
	};
};

//================================================================================================================
//================================================================================================================
//Items info (+sorting)
NWG_GRG_CLI_itemInfoCache = createHashMap;
NWG_GRG_CLI_GetItemInfo = {
	// private _item = _this;

	//Try cache first
	private _cached = NWG_GRG_CLI_itemInfoCache get _this;
	if (!isNil "_cached") exitWith {_cached};

	//Get vehicle config
	private _cfg = configFile >> "CfgVehicles" >> _this;
	if !(isClass _cfg) exitWith {
		(format ["NWG_GRG_CLI_GetItemInfo: Item '%1' not found in CfgVehicles",_this]) call NWG_fnc_logError;
		["",""]
	};

	//Get config values
	private _picture = getText (_cfg >> (NWG_GRG_CLI_Settings get "ITEM_LIST_PICTURE_TYPE"));
	private _displayName = getText (_cfg >> "displayName");

	//Cache and return
	private _itemInfo = [_displayName,_picture];
	NWG_GRG_CLI_itemInfoCache set [_this,_itemInfo];
	_itemInfo
};

NWG_GRG_CLI_SortItems = {
	// private _items = _this;

	//Sort by display name (alphabetically)
	private _sorting = _this apply {[(((_x#GR_CLASSNAME) call NWG_GRG_CLI_GetItemInfo) param [0,""]),_x]};
	_sorting sort true;
	_this resize 0;
	_this append (_sorting apply {_x#1});

	_this
};

//================================================================================================================
//================================================================================================================
//Transaction
NWG_GRG_CLI_TRA_OnClose = {
	disableSerialization;
	//Get 'garaged' vehicles and apply them as new garage array
	private _newGarageArray = uiNamespace getVariable ["NWG_GRG_CLI_shopItems",[]];
	[player,_newGarageArray] call NWG_GRG_SetGarageArray;
};
