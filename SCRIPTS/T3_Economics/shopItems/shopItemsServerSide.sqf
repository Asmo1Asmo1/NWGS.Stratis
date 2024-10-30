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
    ["DEFAULT_PRICE_CLTH",1000],
    ["DEFAULT_PRICE_WEAP",2000],
    ["DEFAULT_PRICE_ITEM",500],
    ["DEFAULT_PRICE_AMMO",300],

	//[activeFactor,passiveFactor,priceMin,priceMax]
	["PRICE_CLTH_SETTINGS",[0.001,0.0002,500,2000]],
	["PRICE_WEAP_SETTINGS",[0.001,0.0002,1000,3000]],
	["PRICE_ITEM_SETTINGS",[0.001,0.0002,300,700]],
	["PRICE_AMMO_SETTINGS",[0.001,0.0002,100,500]],

	//Items that are added to each shop interaction
	["SHOP_PERSISTENT_ITEMS",[
		[],
		["arifle_MX_F","arifle_MXC_F","arifle_AKM_F","arifle_AKS_F"],
		[5,"ItemRadio",3,"ItemCompass","O_UavTerminal",3,"acc_flashlight",1,"MineDetector",10,"FirstAidKit"],
		[10,"30Rnd_65x39_caseless_mag",10,"30Rnd_762x39_Mag_F",10,"30Rnd_545x39_Mag_F"]
	]],
	["SHOP_CHECK_PERSISTENT_ITEMS_ON_INIT",false],//Check validity of persistent items on init
	["SHOP_SKIP_SENDING_PLAYER_LOOT",true],//If you're using 'lootStorage' module, player loot is already synchronized between players and server
	["SHOP_GET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsGetPlayerLoot}],//Function that returns player loot
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",0.5],//Chance that item will be added to dynamic items when bought from player
	["SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE",1],//Chance that item will be removed from dynamic items when sold to player

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
	// private _item = _this;

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

NWG_ISHOP_SER_UpdatePrices = {
	params ["_item","_quantity","_isSoldToPlayer"];

	//Get item info
	private _cachedInfo = NWG_ISHOP_SER_itemsInfoCache get _item;
	if (isNil "_cachedInfo") exitWith {
		(format["NWG_ISHOP_SER_UpdatePrices: Item '%1' is not cached, evaluate items before updating prices",_item]) call NWG_fnc_logError;
		false
	};
	_cachedInfo params ["_categoryIndex","_itemIndex"];

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
	_settings params ["_activeFactor","_passiveFactor","_priceMin","_priceMax"];

	//Define price change
	if (_isSoldToPlayer) then {
		//Item is sold to player, so its price should be increased while others decreased
		//_activeFactor //unchanged
		_passiveFactor = -_passiveFactor;//Turned into negative value
	} else {
		//Item is bought from player, so its price should be decreased while others increased
		_activeFactor = -_activeFactor;//Turned into negative value
		//_passiveFactor //unchanged
	};

	//Process the update
	private _priceChart = (NWG_ISHOP_SER_itemsPriceChart select _categoryIndex) select CHART_PRICES;
	private _activeMultiplier = 1 + (_activeFactor*_quantity);
	private _passiveMultiplier = 1 + (_passiveFactor*_quantity);
	//Process passive multipliers (overlap with active item is accepted)
	{_priceChart set [_forEachIndex,(((_x*_passiveMultiplier) max _priceMin) min _priceMax)]} forEach _priceChart;
	//Process active multiplier
	_priceChart set [_itemIndex,((((_priceChart#_itemIndex)*_activeMultiplier) max _priceMin) min _priceMax)];

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
            case LOOT_ITEM_CAT_ITEM: {{_this}};
            case LOOT_ITEM_CAT_AMMO: {{_this}};
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
	(_persistentItems call NWG_ISHOP_SER_ValidateItemsChart) params ["_chartAfterValidation","_isValid"];
	if (!_isValid) then {
		(format["NWG_ISHOP_SER_ValidatePersistentItems: Invalid persistent shop items, check logs and your NWG_ISHOP_SER_Settings"]) call NWG_fnc_logError;
	};

	NWG_ISHOP_SER_Settings set ["SHOP_PERSISTENT_ITEMS",_chartAfterValidation];
};

//================================================================================================================
//================================================================================================================
//Dynamic items

//Items that are added on top of persistent items
NWG_ISHOP_SER_dynamicItems = [
	[],
	[],
	[],
	[]
];

NWG_ISHOP_SER_DownloadDynamicItems = {
	//return
	NWG_ISHOP_SER_dynamicItems
};

NWG_ISHOP_SER_UploadDynamicItems = {
	// private _dynamicItems = _this;
	(_this call NWG_ISHOP_SER_ValidateItemsChart) params ["_chartAfterValidation","_isValid"];
	if (!_isValid) then {
		(format["NWG_ISHOP_SER_UploadDynamicItems: Invalid dynamic shop items, check logs and your NWG_ISHOP_SER_Settings"]) call NWG_fnc_logError;
	};
	NWG_ISHOP_SER_dynamicItems = _chartAfterValidation;
	//return
	_isValid
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
		if ((count (_persistentItems#_x)) > 0 && {(count (_dynamicItems#_x)) > 0}) then {
			_shopItems pushBack ([(_persistentItems#_x),(_dynamicItems#_x)] call NWG_fnc_mergeCompactedStringArrays);
		} else {
			_shopItems pushBack ((_persistentItems#_x) + (_dynamicItems#_x));
		};
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

	/* ==Update prices== */
	private _updatePrices = {
		params ["_items","_isSoldToPlayer"];
		private _quantity = 1;
		{
			switch (true) do {
				case (_x isEqualType 1): {
					_quantity = _x;
				};
				case (_x isEqualType ""): {
					[_x,_quantity,_isSoldToPlayer] call NWG_ISHOP_SER_UpdatePrices;
					_quantity = 1;
				};
				default {
					(format["NWG_ISHOP_SER_OnTransaction: Invalid item type '%1'",_x]) call NWG_fnc_logError;
				};
			};
		} forEach _items;
	};
	[_itemsSoldToPlayer,true] call _updatePrices;
	[_itemsBoughtFromPlayer,false] call _updatePrices;


	/* ==Prepare script for categorization== */
	private _getCategorizedItemsToProcess = {
		params ["_items","_chanceName"];
		if ((count _items) == 0) exitWith {[]};

		private _chance = ((NWG_ISHOP_SER_Settings get _chanceName) max 0) min 1;
		_items = switch (_chance) do {
			case 0: {[]};
			case 1: {(_items + []) call NWG_fnc_unCompactStringArray};
			default {((_items + []) call NWG_fnc_unCompactStringArray) select {(random 1) <= _chance}};
		};
		if ((count _items) == 0) exitWith {[]};

		private _itemsCategorized = LOOT_ITEM_DEFAULT_CHART;
		{
			switch (_x call NWG_fnc_icatGetItemType) do {
				case LOOT_ITEM_TYPE_AMMO: {(_itemsCategorized#LOOT_ITEM_CAT_AMMO) pushBack _x};
				case LOOT_ITEM_TYPE_ITEM: {(_itemsCategorized#LOOT_ITEM_CAT_ITEM) pushBack _x};
				case LOOT_ITEM_TYPE_WEAP: {(_itemsCategorized#LOOT_ITEM_CAT_WEAP) pushBack _x};
				case LOOT_ITEM_TYPE_CLTH: {(_itemsCategorized#LOOT_ITEM_CAT_CLTH) pushBack _x};
				default {
					(format["NWG_ISHOP_SER_OnTransaction: Invalid item type '%1'-'%2'",_x,(_x call NWG_fnc_icatGetItemType)]) call NWG_fnc_logError;
				};
			};
		} forEach _items;

		{_x call NWG_fnc_compactStringArray} forEach _itemsCategorized;

		//return
		_itemsCategorized
	};


	/* ==Add dynamic items== */
	//foreach category of itemsToAdd
	{
		if ((count _x) == 0) then {continue};

		//Check if nothing was stored - replace
		if ((count (NWG_ISHOP_SER_dynamicItems#_forEachIndex)) == 0) then {
			NWG_ISHOP_SER_dynamicItems set [_forEachIndex,_x];
			continue;
		};

		//Both arrays are non-empty - merge
		NWG_ISHOP_SER_dynamicItems set [
			_forEachIndex,
			([(NWG_ISHOP_SER_dynamicItems#_forEachIndex),_x] call NWG_fnc_mergeCompactedStringArrays)
		];
	} forEach ([_itemsBoughtFromPlayer,"SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE"] call _getCategorizedItemsToProcess);


	/* ==Remove dynamic items== */
	//foreach category of itemsToRemove
	private ["_removeArray","_removeCount","_existingArray","_existingCount","_i","_remainingCount"];
	{
		_removeArray = _x;
		if ((count _removeArray) == 0) then {continue};

		_existingArray = NWG_ISHOP_SER_dynamicItems#_forEachIndex;
		if ((count _existingArray) == 0) then {continue};

		//foreach item in removeArray
		_removeCount = 1;//Init
		{
			if (_x isEqualType 1) then {_removeCount = _x; continue};

			_i = _existingArray find _x;
			if (_i == -1) then {continue};//Item not found (could happen if 2 or more players report at the same time or if persistent items were sold)

			_existingCount = _existingArray param [(_i-1),false];
			_remainingCount = if (_existingCount isEqualType 1)
				then {_existingCount - _removeCount}
				else {0};
			_removeCount = 1;//Reset

			switch (true) do {
				case (_existingCount isEqualTo false): {_existingArray deleteAt _i};//_i points to first element of array and we need to remove at least one element
				case (_existingCount isEqualType ""): {_existingArray deleteAt _i};//_i points to element without count (so its count is '1') and we need to remove at least one element
				case (_remainingCount <= 0): {_existingArray deleteAt _i; _existingArray deleteAt (_i-1)};//Remove >=all elements - remove element itself and its count
				case (_remainingCount == 1): {_existingArray deleteAt (_i-1)};//Remove only count of the element (so its count becomes '1')
				default {_existingArray set [(_i-1),_remainingCount]};//Decrease count
			};
		} forEach _removeArray;
	} forEach ([_itemsSoldToPlayer,"SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE"] call _getCategorizedItemsToProcess);
};
