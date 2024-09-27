#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
//Loot items types
#define CAT_CLTH 0
#define CAT_WEAP 1
#define CAT_ITEM 2
#define CAT_AMMO 3

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
	["SHOP_CHECK_PERSISTENT_ITEMS",true],//Each interaction check validity of persistent items
	["SHOP_SKIP_SENDING_PLAYER_LOOT",true],//If you're using 'lootStorage' module, player loot is already synchronized between players and server
	["SHOP_GET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsGetPlayerLoot}],//Function that returns player loot
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",0.25],//Chance that item will be added to dynamic items when bought from player

	["",0]
];

//================================================================================================================
//================================================================================================================
//Prices
NWG_ISHOP_SER_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
NWG_ISHOP_SER_itemsPriceChart = [
	[[],[]],//CAT_CLTH [items,prices]
	[[],[]],//CAT_WEAP [items,prices]
	[[],[]],//CAT_ITEM [items,prices]
	[[],[]] //CAT_AMMO [items,prices]
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
			_categoryIndex = CAT_AMMO;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_AMMO";
		};
		case LOOT_ITEM_TYPE_ITEM: {
			_categoryIndex = CAT_ITEM;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_ITEM";
		};
		case LOOT_ITEM_TYPE_WEPN: {
			_categoryIndex = CAT_WEAP;
			_defaultPrice = NWG_ISHOP_SER_Settings get "DEFAULT_PRICE_WEAP";
		};
		case LOOT_ITEM_TYPE_CLTH: {
			_categoryIndex = CAT_CLTH;
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
		case CAT_CLTH: {NWG_ISHOP_SER_Settings get "PRICE_CLTH_SETTINGS"};
		case CAT_WEAP: {NWG_ISHOP_SER_Settings get "PRICE_WEAP_SETTINGS"};
		case CAT_ITEM: {NWG_ISHOP_SER_Settings get "PRICE_ITEM_SETTINGS"};
		case CAT_AMMO: {NWG_ISHOP_SER_Settings get "PRICE_AMMO_SETTINGS"};
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
	if !(_pricesChart isEqualTypeParams [[],[],[],[]]) exitWith {
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
//Shop

//Items that are added on top of persistent items
NWG_ISHOP_SER_dynamicItems = [
	[],
	[],
	[],
	[]
];

NWG_ISHOP_SER_prevPersistentItems = [];
NWG_ISHOP_SER_prevPersistentItemsCheckResult = true;
NWG_ISHOP_SER_CheckPersistentItems = {
	// private _persistentItems = _this;

	//Check settings
	if !(NWG_ISHOP_SER_Settings get "SHOP_CHECK_PERSISTENT_ITEMS") exitWith {true};

	//Check if persistent items changed since last check (settings were updated)
	if (_this isEqualTo NWG_ISHOP_SER_prevPersistentItems) exitWith {NWG_ISHOP_SER_prevPersistentItemsCheckResult};
	NWG_ISHOP_SER_prevPersistentItems = _this;

	//Check overall structure
	if !(_this isEqualTypeParams [[],[],[],[]]) exitWith {
		(format["NWG_ISHOP_SER_CheckPersistentItems: Invalid persistent shop items format"]) call NWG_fnc_logError;
		NWG_ISHOP_SER_prevPersistentItemsCheckResult = false;
		false;
	};

	//Check that each element is of correct type
	private _ok = true;
	//foreach category
	{
		private _expected = switch (_forEachIndex) do {
			case CAT_CLTH: {LOOT_ITEM_TYPE_CLTH};
			case CAT_WEAP: {LOOT_ITEM_TYPE_WEPN};
			case CAT_ITEM: {LOOT_ITEM_TYPE_ITEM};
			case CAT_AMMO: {LOOT_ITEM_TYPE_AMMO};
			default {""};
		};

		//foreach item in category
		{
			if (_x isEqualType "" && {(_x call NWG_fnc_icatGetItemType) isNotEqualTo _expected}) then {
				(format["NWG_ISHOP_SER_CheckPersistentItems: Invalid persistent item '%1'. Expected: '%2', Actual: '%3'",_x,_expected,(_x call NWG_fnc_icatGetItemType)]) call NWG_fnc_logError;
				_ok = false;
			};
		} forEach _x;
	} forEach _this;

	//Save
	NWG_ISHOP_SER_prevPersistentItemsCheckResult = _ok;

	//return
	_ok
};

NWG_ISHOP_SER_OnShopRequest = {
	private _player = _this;

	//Get player loot
	private _playerLoot = _player call (NWG_ISHOP_SER_Settings get "SHOP_GET_PLAYER_LOOT_FUNC");
	if !(_playerLoot isEqualTypeParams [[],[],[],[]]) exitWith {
		(format["NWG_ISHOP_SER_OnShopRequest: Invalid player loot format"]) call NWG_fnc_logError;
	};

	//Get persistent shop items
	private _persistentItems = NWG_ISHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS";
	if !(_persistentItems call NWG_ISHOP_SER_CheckPersistentItems) then {
		(format["NWG_ISHOP_SER_OnShopRequest: Invalid persistent shop items"]) call NWG_fnc_logError;
		_persistentItems = [[],[],[],[]];//<== Use empty items
	};

	//Get dynamic shop items
	private _dynamicItems = NWG_ISHOP_SER_dynamicItems;//No need to check since we are the ones who update it

	//Merge shop items
	private _shopItems = [];
	{
		if ( ((count (_persistentItems#_x)) > 0) && {(count (_dynamicItems#_x)) > 0}) then {
			_shopItems pushBack ([(_persistentItems#_x),(_dynamicItems#_x)] call NWG_fnc_mergeCompactedStringArrays);
		} else {
			_shopItems pushBack ((_persistentItems#_x) + (_dynamicItems#_x));
		};
	} forEach [CAT_CLTH,CAT_WEAP,CAT_ITEM,CAT_AMMO];

	//Evaluate prices
	private _allItems = _playerLoot + _shopItems;
	_allItems = (flatten _allItems) select {_x isEqualType ""};
	_allItems = _allItems arrayIntersect _allItems;//Remove dublicates

	//Evaluate prices
	private _allPrices = _allItems apply {_x call NWG_ISHOP_SER_EvaluateItem};

	//Send back result
	private _result = [
		(if (NWG_ISHOP_SER_Settings get "SHOP_SKIP_SENDING_PLAYER_LOOT") then {[]} else {_playerLoot}),
		_shopItems,
		_allItems,
		_allPrices
	];
	_result remoteExec ["NWG_ISHOP_CLI_OnShopResponse",_player];

	//return (mostly for testing)
	_result
};

NWG_ISHOP_SER_OnTransaction = {
	params ["_itemsSoldToPlayer","_itemsBoughtFromPlayer"];
	//Update prices
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

	//Update prices for items sold to player
	[_itemsSoldToPlayer,true] call _updatePrices;
	//Update prices for items bought from player
	[_itemsBoughtFromPlayer,false] call _updatePrices;

	//Select items bought from player to add them to dynamic items
	private _chance = ((NWG_ISHOP_SER_Settings get "SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE") max 0) min 1;
	private _itemsToAdd = switch (_chance) do {
		case 0: {[]};
		case 1: {(_itemsBoughtFromPlayer + []) call NWG_fnc_unCompactStringArray};
		default {((_itemsBoughtFromPlayer + []) call NWG_fnc_unCompactStringArray) select {(random 1) <= _chance}};
	};
	if (_itemsToAdd isEqualTo []) exitWith {};//<== EXIT IF NO ITEMS TO ADD

	//Add items to dynamic items
	private _itemsToAddCategorized = [[],[],[],[]];
	private ["_itemType","_categoryIndex"];
	//foreach flat itemsToAdd - categorize
	{
		_itemType = _x call NWG_fnc_icatGetItemType;
		_categoryIndex = switch (_itemType) do {
			case LOOT_ITEM_TYPE_AMMO: {CAT_AMMO};
			case LOOT_ITEM_TYPE_ITEM: {CAT_ITEM};
			case LOOT_ITEM_TYPE_WEPN: {CAT_WEAP};
			case LOOT_ITEM_TYPE_CLTH: {CAT_CLTH};
			default {-1};
		};
		if (_categoryIndex == -1) then {
			(format["NWG_ISHOP_SER_OnTransaction: Invalid item type '%1'-'%2'",_x,_itemType]) call NWG_fnc_logError;
			continue;
		};
		(_itemsToAddCategorized#_categoryIndex) pushBack _x;
	} forEach _itemsToAdd;
	//foreach category of itemsToAdd
	{
		//Check if nothing to add - skip
		if ((count _x) == 0) then {
			continue;
		};

		//Compact array
		_x call NWG_fnc_compactStringArray;

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
	} forEach _itemsToAddCategorized;
};
