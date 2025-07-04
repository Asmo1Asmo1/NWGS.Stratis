#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
#define CACHED_CATEGORY 0
#define CACHED_INDEX 1
#define CHART_ITEMS 0
#define CHART_PRICES 1

//================================================================================================================
//================================================================================================================
//Settings
NWG_ISHOP_SER_Settings = createHashMapFromArray [
	//Default prices
    ["DEFAULT_PRICE_CLTH",1000],
    ["DEFAULT_PRICE_WEAP",2000],
    ["DEFAULT_PRICE_ITEM",500],
    ["DEFAULT_PRICE_AMMO",300],

	//Prices dynamic settings | params ["_activeAdd","_passiveAdd","_priceMin","_priceMax"]
	["PRICE_CLTH_SETTINGS",[10,0.1,200,10000]],
	["PRICE_WEAP_SETTINGS",[20,0.2,400,20000]],
	["PRICE_ITEM_SETTINGS",[5,0.05,100,5000]],
	["PRICE_AMMO_SETTINGS",[5,0.05,100,3000]],

	//Items that are added to each shop interaction
	["SHOP_PERSISTENT_ITEMS",[
		["B_AssaultPack_khk"],
		["arifle_MX_F","arifle_MXC_F"],
		["ItemRadio","ItemCompass","ItemMap","O_UavTerminal","acc_flashlight","MineDetector",10,"FirstAidKit","Sleeping_bag_folded_01"],
		[10,"30Rnd_65x39_caseless_mag"]
	]],
	["SHOP_CHECK_PERSISTENT_ITEMS_ON_INIT",false],//Check validity of persistent items on init
	["SHOP_SKIP_SENDING_PLAYER_LOOT",true],//If you're using 'lootStorage' module, player loot is already synchronized between players and server
	["SHOP_GET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsGetPlayerLoot}],//Function that returns player loot

	//Buy Back | Sold Out
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",0],//Chance that item will be added to dynamic items when bought from player
	["SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE",0],//Chance that item will be removed from dynamic items when sold to player

	//Junk items - items that will be ignored and never added to dynamic items on buy from player
	["SHOP_JUNK_ITEMS",[
		"FlashDisk","Files","FilesSecret","FileTopSecret","FileNetworkStructure","DocumentsSecret",
		"SatPhone","MobilePhone","SmartPhone",
		"Money","Money_stack","Money_roll","Money_bunch",
		"Laptop_Unfolded","Laptop_Closed","ButaneCanister","Keys","Wallet_ID",
		"Bandage","Antimalaricum","Antibiotic","AntimalaricumVaccine"
	]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	if (NWG_ISHOP_SER_Settings get "SHOP_CHECK_PERSISTENT_ITEMS_ON_INIT") then {
		call NWG_ISHOP_SER_ValidatePersistentItems;
	};
};

//================================================================================================================
//================================================================================================================
//Prices
NWG_ISHOP_SER_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
NWG_ISHOP_SER_itemsPriceChart = [
	[[],[]],//LOOT_ITEM_CAT_CLTH [items,prices]
	[[],[]],//LOOT_ITEM_CAT_WEAP [items,prices]
	[[],[]],//LOOT_ITEM_CAT_ITEM [items,prices]
	[[],[]] //LOOT_ITEM_CAT_AMMO [items,prices]
];

NWG_ISHOP_SER_EvaluateItem = {
	// private _itemClassname = _this;

	//Get cached item info if exists
	private _c = NWG_ISHOP_SER_itemsInfoCache get _this;
	if (!isNil "_c") exitWith {
		(((NWG_ISHOP_SER_itemsPriceChart select (_c#CACHED_CATEGORY))/*Select category in chart*/
			select CHART_PRICES)/*Select prices row*/
			select (_c#CACHED_INDEX))/*Select price by index in a row*/
	};

	//Create new item info
	private _itemType = _this call NWG_fnc_icatGetItemType;
	private _categoryIndex = -1;
	private _defaultPrice = 0;
	switch (_itemType) do {
		case LOOT_ITEM_TYPE_AMMO: {
			_categoryIndex = LOOT_ITEM_CAT_AMMO;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_AMMO";
		};
		case LOOT_ITEM_TYPE_ITEM: {
			_categoryIndex = LOOT_ITEM_CAT_ITEM;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_ITEM";
		};
		case LOOT_ITEM_TYPE_WEAP: {
			_categoryIndex = LOOT_ITEM_CAT_WEAP;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_WEAP";
		};
		case LOOT_ITEM_TYPE_CLTH: {
			_categoryIndex = LOOT_ITEM_CAT_CLTH;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_CLTH";
		};
		default {
			(format["NWG_ISHOP_SER_EvaluateItem: Invalid item type %1",_itemType]) call NWG_fnc_logError;
		};
	};
	if (_categoryIndex == -1) exitWith {_defaultPrice};//<== EXIT WITH ZERO DEFAULT on error

	//Add new item info to chart and cache
	private _itemIndex = ((NWG_ISHOP_SER_itemsPriceChart select _categoryIndex) select CHART_ITEMS) pushBack _this;
	((NWG_ISHOP_SER_itemsPriceChart select _categoryIndex) select CHART_PRICES) pushBack _defaultPrice;
	NWG_ISHOP_SER_itemsInfoCache set [_this,[_categoryIndex,_itemIndex]];

	//return price
	_defaultPrice
};

NWG_ISHOP_SER_EvaluateItemFull = {
	// private _itemClassname = _this;
	private _currentPrice = _this call NWG_ISHOP_SER_EvaluateItem;
	private _itemType = _this call NWG_fnc_icatGetItemType;
	private _defaultPrice = switch (_itemType) do {
		case LOOT_ITEM_TYPE_AMMO: {NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_AMMO"};
		case LOOT_ITEM_TYPE_ITEM: {NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_ITEM"};
		case LOOT_ITEM_TYPE_WEAP: {NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_WEAP"};
		case LOOT_ITEM_TYPE_CLTH: {NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_CLTH"};
		default {
			(format["NWG_ISHOP_SER_EvaluateItemFull: Invalid item type '%1' for item '%2'",_itemType,_this]) call NWG_fnc_logError;
			1
		};
	};
	//return
	[_currentPrice,_defaultPrice,(_currentPrice / _defaultPrice)]
};

NWG_ISHOP_SER_SetItemPrice = {
	params ["_itemClassname","_newPrice"];
	private _cachedInfo = NWG_ISHOP_SER_itemsInfoCache get _itemClassname;
	if (isNil "_cachedInfo") exitWith {
		(format["NWG_ISHOP_SER_SetItemPrice: Item '%1' is not cached, evaluate item before setting price",_itemClassname]) call NWG_fnc_logError;
		false
	};
	_cachedInfo params ["_iCat","_iIndex"];
	((NWG_ISHOP_SER_itemsPriceChart select _iCat) select CHART_PRICES) set [_iIndex,_newPrice];
	//return
	true
};

NWG_ISHOP_SER_UpdatePrices = {
	params ["_categoryIndex","_items","_isSoldToPlayer"];

	//Get category settings
	private _settings = switch (_categoryIndex) do {
		case LOOT_ITEM_CAT_CLTH: {NWG_ISHOP_SER_Settings get "PRICE_CLTH_SETTINGS"};
		case LOOT_ITEM_CAT_WEAP: {NWG_ISHOP_SER_Settings get "PRICE_WEAP_SETTINGS"};
		case LOOT_ITEM_CAT_ITEM: {NWG_ISHOP_SER_Settings get "PRICE_ITEM_SETTINGS"};
		case LOOT_ITEM_CAT_AMMO: {NWG_ISHOP_SER_Settings get "PRICE_AMMO_SETTINGS"};
		default {
			(format["NWG_ISHOP_SER_UpdatePrices: Invalid category %1",_category]) call NWG_fnc_logError;
			nil
		};
	};
	if (isNil "_settings") exitWith {
		(format["NWG_ISHOP_SER_UpdatePrices: Failed to get category settings for index: '%1'",_categoryIndex]) call NWG_fnc_logError;
		false
	};
	_settings params ["_activeAdd","_passiveAdd","_priceMin","_priceMax"];

	//Define price change
	if (_isSoldToPlayer) then {
		//Item is sold to player, so its price should be increased while others decreased
		//_activeAdd //unchanged
		_passiveAdd = -_passiveAdd;//Turned into negative value
	} else {
		//Item is bought from player, so its price should be decreased while others increased
		_activeAdd = -_activeAdd;//Turned into negative value
		//_passiveAdd //unchanged
	};

	//Prepare for processing
	private _priceChart = (NWG_ISHOP_SER_itemsPriceChart select _categoryIndex) select CHART_PRICES;
	private _actives = [];
	private _totalCount = 0;

	//Update active items
	private _count = 1;
	private _cachedInfo = [];
	{
		if (_x isEqualType 1) then {
			_count = _x;
			continue;
		};

		_cachedInfo = NWG_ISHOP_SER_itemsInfoCache get _x;
		if (isNil "_cachedInfo") then {
			(format["NWG_ISHOP_SER_UpdatePrices: Item '%1' is not cached, evaluate items before updating prices",_x]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};
		_cachedInfo params ["_iCat","_iIndex"];
		if (_iCat != _categoryIndex) then {
			(format["NWG_ISHOP_SER_UpdatePrices: Item '%1' is not in the right category. Expected: '%2', Actual: '%3'",_x,_categoryIndex,_iCat]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};
		if (_iIndex < 0 || {_iIndex >= (count _priceChart)}) then {
			(format["NWG_ISHOP_SER_UpdatePrices: Item's '%1' price index '%2' is out of bounds for category '%3'",_x,_iIndex,_categoryIndex]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};

		_actives pushBackUnique _iIndex;
		_totalCount = _totalCount + _count;
		_priceChart set [_iIndex,((((_priceChart#_iIndex) + (_activeAdd * _count)) max _priceMin) min _priceMax)];
		_count = 1;

	} forEach _items;

	//Check at least one change was made
	if (_totalCount == 0) exitWith {
		(format["NWG_ISHOP_SER_UpdatePrices: No changes were made to the price chart for category '%1'",_categoryIndex]) call NWG_fnc_logError;
		false
	};

	//Update passive items
	{
		if !(_forEachIndex in _actives)
			then {_priceChart set [_forEachIndex,(((_x + (_passiveAdd * _totalCount)) max _priceMin) min _priceMax)]};
	} forEach _priceChart;

	//return
	true
};

NWG_ISHOP_SER_DownloadPrices = {
	//return
	NWG_ISHOP_SER_itemsPriceChart
};

NWG_ISHOP_SER_UploadPrices = {
	private _pricesChart = _this;
	if !(_pricesChart isEqualTypeArray LOOT_ITEM_DEFAULT_CHART) exitWith {
		(format["NWG_ISHOP_SER_UploadPrices: Invalid prices chart format"]) call NWG_fnc_logError;
		false
	};

	//Update prices chart
	NWG_ISHOP_SER_itemsPriceChart = _pricesChart;

	//Update item info cache
	private _newCache = createHashMap;
	{
		private _categoryIndex = _forEachIndex;
		{_newCache set [_x,[_categoryIndex,_forEachIndex]]} forEach (_x#CHART_ITEMS);
	} forEach _pricesChart;
	NWG_ISHOP_SER_itemsInfoCache = _newCache;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Items chart conversion
NWG_ISHOP_SER_ArrayToChart = {
	private _array = _this;
	private _chart = LOOT_ITEM_DEFAULT_CHART;
	if ((count _array) == 0) exitWith {_chart};

	//Uncompact incoming array if needed
	if ((_array findIf {_x isEqualType 1}) != -1) then {
		_array = _array call NWG_fnc_unCompactStringArray;
	};

	//Sort items by category
	{
		switch (_x call NWG_fnc_icatGetItemType) do {
			case LOOT_ITEM_TYPE_CLTH: {(_chart#LOOT_ITEM_CAT_CLTH) pushBack _x};
			case LOOT_ITEM_TYPE_WEAP: {(_chart#LOOT_ITEM_CAT_WEAP) pushBack _x};
			case LOOT_ITEM_TYPE_ITEM: {(_chart#LOOT_ITEM_CAT_ITEM) pushBack _x};
			case LOOT_ITEM_TYPE_AMMO: {(_chart#LOOT_ITEM_CAT_AMMO) pushBack _x};
			default {
				(format["NWG_ISHOP_SER_ArrayToChart: Invalid item type '%1'-'%2'",_x,(_x call NWG_fnc_icatGetItemType)]) call NWG_fnc_logError;
			};
		};
	} forEach _array;

	//Compact each category
	{_x call NWG_fnc_compactStringArray} forEach _chart;

	//return
	_chart
};

//================================================================================================================
//================================================================================================================
//Items chart validation
NWG_ISHOP_SER_ValidateItemsChart = {
	// private _itemsChart = _this;

	//Check empty chart
	if (_this isEqualTo LOOT_ITEM_DEFAULT_CHART) exitWith {
		[LOOT_ITEM_DEFAULT_CHART,true]
	};

	//Check overall structure
	if !(_this isEqualTypeArray LOOT_ITEM_DEFAULT_CHART) exitWith {
		(format["NWG_ISHOP_SER_ValidateItemsChart: Invalid items chart format"]) call NWG_fnc_logError;
		//return
		[LOOT_ITEM_DEFAULT_CHART,false]
	};

	//Check each element
	private _validationResult = true;
	//foreach category
	{
		if ((count _x) == 0) then {continue};//Skip empty categories

		private _expectedCat = switch (_forEachIndex) do {
			case LOOT_ITEM_CAT_CLTH: {LOOT_ITEM_TYPE_CLTH};
			case LOOT_ITEM_CAT_WEAP: {LOOT_ITEM_TYPE_WEAP};
			case LOOT_ITEM_CAT_ITEM: {LOOT_ITEM_TYPE_ITEM};
			case LOOT_ITEM_CAT_AMMO: {LOOT_ITEM_TYPE_AMMO};
			default {""};
		};
		if (_expectedCat isEqualTo "") then {
			(format["NWG_ISHOP_SER_ValidateItemsChart: Invalid category index: '%1'",_forEachIndex]) call NWG_fnc_logError;
			_validationResult = false;
			continue;
		};

		private _getBaseClass = switch (_forEachIndex) do {
            case LOOT_ITEM_CAT_CLTH: {{_this call NWG_fnc_icatGetBaseBackpack}};
            case LOOT_ITEM_CAT_WEAP: {{_this call NWG_fnc_icatGetBaseWeapon}};
            default {{_this}};
		};

		private _failedItems = [];
		private ["_itemCat","_itemBaseClass"];
		//foreach item in category
		{
			//Skip count
			if (_x isEqualType 1) then {continue};

			//Check that item is a string (just in case)
			if !(_x isEqualType "") then {
				(format["NWG_ISHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: 'STRING'",_x]) call NWG_fnc_logError;
				_failedItems pushBackUnique _x;
				continue;
			};

			//Check item category
			_itemCat = _x call NWG_fnc_icatGetItemType;
			if (_itemCat isNotEqualTo _expectedCat) then {
				(format["NWG_ISHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: '%2', Actual: '%3'",_x,_expectedCat,_itemCat]) call NWG_fnc_logError;
				_failedItems pushBackUnique _x;
				continue;
			};

			//Check item base class
			_itemBaseClass = _x call _getBaseClass;
			if (_x isNotEqualTo _itemBaseClass) then {
				(format["NWG_ISHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: '%2'",_x,_itemBaseClass]) call NWG_fnc_logError;
				_failedItems pushBackUnique _x;
			};
		} forEach _x;

		//Remove failed items if any
		if ((count _failedItems) > 0) then {
			_validationResult = false;
			private _newItems = _x + [];//Shallow copy
			_newItems = _newItems call NWG_fnc_unCompactStringArray;//Uncompact
			_newItems = _newItems - _failedItems;//Remove failed items
			_newItems = _newItems call NWG_fnc_compactStringArray;//Compact
			_this set [_forEachIndex,_newItems];//Replace
		};
	} forEach _this;

	//return
	[_this,_validationResult]
};

NWG_ISHOP_SER_ValidatePersistentItems = {
	private _persistentItems = NWG_ISHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS";
	(_persistentItems call NWG_ISHOP_SER_ValidateItemsChart) params ["_sanitizedChart","_isValid"];
	if (!_isValid) then {
		(format["NWG_ISHOP_SER_ValidatePersistentItems: Invalid persistent shop items, check logs and your NWG_ISHOP_SER_Settings"]) call NWG_fnc_logError;
		NWG_ISHOP_SER_Settings set ["SHOP_PERSISTENT_ITEMS",_sanitizedChart];
	};

	_isValid
};

//================================================================================================================
//================================================================================================================
//Dynamic items

//Items that are added on top of persistent items
NWG_ISHOP_SER_dynamicItems = [
	[],/*CLTH*/
	[],/*WEAP*/
	[],/*ITEM*/
	[] /*AMMO*/
];

NWG_ISHOP_SER_AddDynamicItems = {
	// private _itemsArray = _this;
	if ((count _this) == 0) exitWith {};

	//Convert and validate
	((_this call NWG_ISHOP_SER_ArrayToChart) call NWG_ISHOP_SER_ValidateItemsChart) params ["_sanitizedChart","_isValid"];
	if (!_isValid) then {
		"NWG_ISHOP_SER_AddDynamicItems: Invalid items found, check RPT for details" call NWG_fnc_logError;
	};

	//foreach category of itemsToAdd
	private _newItems = [];
	{
		_newItems = [(NWG_ISHOP_SER_dynamicItems#_forEachIndex),_x] call NWG_fnc_mergeCompactedStringArrays;
		NWG_ISHOP_SER_dynamicItems set [_forEachIndex,_newItems];
	} forEach _sanitizedChart;

	//return
	_isValid
};

NWG_ISHOP_SER_AddDynamicItemsExternal = {
	private _items = _this;

	if ((_items findIf {_x isEqualType 1}) != -1) then {
		_items = _items call NWG_fnc_unCompactStringArray;
	};

	_items = _items call NWG_ISHOP_SER_RemoveJunkFromItems;
	_items call NWG_ISHOP_SER_AddDynamicItems;
};

NWG_ISHOP_SER_RemoveDynamicItems = {
	// private _itemsArray = _this;
	if ((count _this) == 0) exitWith {};

	//foreach category of itemsToRemove
	//This whole logic is a bit complex, but it will execute faster than uncompacting both arrays and substracting one from another
	//Also, we skip validation on purpose - if item is invalid, we will not find it in dynamic items in the first place and removal will be skipped
	private ["_removeArray","_existingArray","_removeCount","_i","_existingCount","_remainingCount"];
	{
		_removeArray = _x;
		if ((count _removeArray) == 0) then {continue};

		_existingArray = NWG_ISHOP_SER_dynamicItems#_forEachIndex;
		if ((count _existingArray) == 0) then {continue};

		//foreach item in removeArray
		_removeCount = 1;//Init
		{
			if (_x isEqualType 1) then {
				_removeCount = _x;
				continue
			};

			_i = _existingArray find _x;
			if (_i == -1) then {
				//Item not found (double report or trying to remove persistent or invalid items)
				_removeCount = 1;
				continue
			};

			_existingCount = _existingArray param [(_i-1),""];
			_remainingCount = if (_existingCount isEqualType 1) then {_existingCount - _removeCount} else {0};
			_removeCount = 1;//Reset

			switch (true) do {
				case (_existingCount isEqualType ""): {_existingArray deleteAt _i};//_i points to element without count (so its count is '1') and we need to remove at least one element
				case (_remainingCount <= 0): {_existingArray deleteAt _i; _existingArray deleteAt (_i-1)};//Remove >=all elements - remove both element itself and its count
				case (_remainingCount == 1): {_existingArray deleteAt (_i-1)};//Remove only the count of the element (so its count becomes '1')
				default {_existingArray set [(_i-1),_remainingCount]};//Decrease count
			};
		} forEach _removeArray;
	} forEach (_this call NWG_ISHOP_SER_ArrayToChart);
};

//================================================================================================================
//================================================================================================================
//Junk sanitaion
NWG_ISHOP_SER_RemoveJunkFromItems = {
	// private _items = _this;
	_this - (NWG_ISHOP_SER_Settings get "SHOP_JUNK_ITEMS")
};

//================================================================================================================
//================================================================================================================
//Shop

NWG_ISHOP_SER_OnShopRequest = {
	private _player = _this;

	//Get player loot
	private _playerLoot = _player call (NWG_ISHOP_SER_Settings get "SHOP_GET_PLAYER_LOOT_FUNC");
	if !(_playerLoot isEqualTypeArray LOOT_ITEM_DEFAULT_CHART) exitWith {
		(format["NWG_ISHOP_SER_OnShopRequest: Invalid player loot format"]) call NWG_fnc_logError;
	};

	//Merge shop items
	private _persistentItems = NWG_ISHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS";
	private _dynamicItems = NWG_ISHOP_SER_dynamicItems;
	private _shopItems = [];
	{
		_shopItems pushBack ([(_persistentItems#_x),(_dynamicItems#_x)] call NWG_fnc_mergeCompactedStringArrays);
	} forEach [LOOT_ITEM_CAT_CLTH,LOOT_ITEM_CAT_WEAP,LOOT_ITEM_CAT_ITEM,LOOT_ITEM_CAT_AMMO];

	//Evaluate prices
	private _allItems = _playerLoot + _shopItems;
	_allItems = (flatten _allItems) select {_x isEqualType ""};
	_allItems = _allItems arrayIntersect _allItems;//Remove duplicates
	private _allPrices = _allItems apply {_x call NWG_ISHOP_SER_EvaluateItem};

	//Send back result
	private _result = [
		(if (NWG_ISHOP_SER_Settings get "SHOP_SKIP_SENDING_PLAYER_LOOT") then {[]} else {_playerLoot}),
		_shopItems,
		_allItems,
		_allPrices
	];
	_result remoteExec ["NWG_fnc_ishopShopValuesResponse",_player];

	//return (mostly for testing)
	_result
};

NWG_ISHOP_SER_OnTransaction = {
	params ["_itemsSoldToPlayer","_itemsBoughtFromPlayer"];

	//Prepare script for updating dynamic items
	private _applyChanceRemoveJunk = {
		params ["_items","_chanceName"];
		private _chance = ((NWG_ISHOP_SER_Settings get _chanceName) max 0) min 1;
		if (_chance == 0) exitWith {[]};

		_items = _items call NWG_fnc_unCompactStringArray;
		_items = _items call NWG_ISHOP_SER_RemoveJunkFromItems;
		if (_chance == 1) exitWith {_items};

		//return
		_items select {(random 1) <= _chance}
	};

	//Update sold items
	if ((count _itemsSoldToPlayer) > 0) then {
		//Update prices
		private _soldChart = _itemsSoldToPlayer call NWG_ISHOP_SER_ArrayToChart;
		{
			if ((count _x) > 0) then {[_forEachIndex,_x,true] call NWG_ISHOP_SER_UpdatePrices};
		} forEach _soldChart;

		//Update dynamic items
		private _soldFiltered = [_itemsSoldToPlayer,"SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE"] call _applyChanceRemoveJunk;
		if ((count _soldFiltered) > 0) then {_soldFiltered call NWG_ISHOP_SER_RemoveDynamicItems};
	};

	//Update bought items
	if ((count _itemsBoughtFromPlayer) > 0) then {
		//Update prices
		private _boughtChart = _itemsBoughtFromPlayer call NWG_ISHOP_SER_ArrayToChart;
		{
			if ((count _x) > 0) then {[_forEachIndex,_x,false] call NWG_ISHOP_SER_UpdatePrices};
		} forEach _boughtChart;

		//Update dynamic items
		private _boughtFiltered = [_itemsBoughtFromPlayer,"SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE"] call _applyChanceRemoveJunk;
		if ((count _boughtFiltered) > 0) then {_boughtFiltered call NWG_ISHOP_SER_AddDynamicItems};
	};
};
