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
NWG_ISHOP_Settings = createHashMapFromArray [
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
	["SHOP_SKIP_SENDING_PLAYER_LOOT",true],//If you're using 'lootStorage' module, player loot is synchronized between players and server already
	["SHOP_GET_PLAYER_LOOT_FUNC",{_this call NWG_fnc_lsGetPlayerLoot}],//Function that returns player loot

	["",0]
];

//================================================================================================================
//================================================================================================================
//Prices
NWG_ISHOP_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
NWG_ISHOP_itemsPriceChart = [
	[[],[]],//CAT_CLTH [items,prices]
	[[],[]],//CAT_WEAP [items,prices]
	[[],[]],//CAT_ITEM [items,prices]
	[[],[]] //CAT_AMMO [items,prices]
];

NWG_ISHOP_EvaluateItem = {
	// private _item = _this;

	//Get cached item info if exists
	private _c = NWG_ISHOP_itemsInfoCache get _this;
	if (!isNil "_c") exitWith {
		(((NWG_ISHOP_itemsPriceChart select (_c#CACHED_CATEGORY))/*Select category in chart*/
			select CHART_PRICES)/*Select prices row*/
			select (_c#CACHED_INDEX))/*Select price by index in a row*/
	};

	//Create new item info
	private _itemType = _this call NWG_fnc_icatGetItemType;
	private _categoryIndex = -1;
	private _defaultPrice = 0;
	switch (_itemType) do {
		case LOOT_ITEM_TYPE_AMMO: {
			_categoryIndex = 3;
			_defaultPrice = NWG_ISHOP_Settings get "DEFAULT_PRICE_AMMO";
		};
		case LOOT_ITEM_TYPE_ITEM: {
			_categoryIndex = 2;
			_defaultPrice = NWG_ISHOP_Settings get "DEFAULT_PRICE_ITEM";
		};
		case LOOT_ITEM_TYPE_WEPN: {
			_categoryIndex = 1;
			_defaultPrice = NWG_ISHOP_Settings get "DEFAULT_PRICE_WEAP";
		};
		case LOOT_ITEM_TYPE_CLTH: {
			_categoryIndex = 0;
			_defaultPrice = NWG_ISHOP_Settings get "DEFAULT_PRICE_CLTH";
		};
		default {
			(format["NWG_ISHOP_EvaluateItem: Invalid item type %1",_itemType]) call NWG_fnc_logError;
		};
	};
	if (_categoryIndex == -1) exitWith {_defaultPrice};//<== EXIT WITH ZERO DEFAULT on error

	//Add new item info to chart and cache
	private _itemIndex = ((NWG_ISHOP_itemsPriceChart select _categoryIndex) select CHART_ITEMS) pushBack _this;
	((NWG_ISHOP_itemsPriceChart select _categoryIndex) select CHART_PRICES) pushBack _defaultPrice;
	NWG_ISHOP_itemsInfoCache set [_this,[_categoryIndex,_itemIndex]];

	//return price
	_defaultPrice
};

NWG_ISHOP_UpdatePrices = {
	params ["_item","_quantity","_isSoldToPlayer"];

	//Get item info
	private _cachedInfo = NWG_ISHOP_itemsInfoCache get _item;
	if (isNil "_cachedInfo") exitWith {
		(format["NWG_ISHOP_UpdatePrices: Item '%1' is not cached, evaluate items before updating prices",_item]) call NWG_fnc_logError;
		false
	};
	_cachedInfo params ["_categoryIndex","_itemIndex"];

	//Get category settings
	private _settings = switch (_categoryIndex) do {
		case CAT_CLTH: {NWG_ISHOP_Settings get "PRICE_CLTH_SETTINGS"};
		case CAT_WEAP: {NWG_ISHOP_Settings get "PRICE_WEAP_SETTINGS"};
		case CAT_ITEM: {NWG_ISHOP_Settings get "PRICE_ITEM_SETTINGS"};
		case CAT_AMMO: {NWG_ISHOP_Settings get "PRICE_AMMO_SETTINGS"};
		default {
			(format["NWG_ISHOP_UpdatePrices: Invalid category %1",_category]) call NWG_fnc_logError;
			nil
		};
	};
	if (isNil "_settings") exitWith {
		(format["NWG_ISHOP_UpdatePrices: Failed to get category settings for index: '%1'",_categoryIndex]) call NWG_fnc_logError;
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
	private _priceChart = (NWG_ISHOP_itemsPriceChart select _categoryIndex) select CHART_PRICES;
	private _activeMultiplier = 1 + (_activeFactor*_quantity);
	private _passiveMultiplier = 1 + (_passiveFactor*_quantity);
	//Process passive multipliers (overlap with active item is accepted)
	{_priceChart set [_forEachIndex,(((_x*_passiveMultiplier) max _priceMin) min _priceMax)]} forEach _priceChart;
	//Process active multiplier
	_priceChart set [_itemIndex,((((_priceChart#_itemIndex)*_activeMultiplier) max _priceMin) min _priceMax)];

	//return
	true
};

NWG_ISHOP_DownloadPrices = {
	//return
	NWG_ISHOP_itemsPriceChart
};

NWG_ISHOP_UploadPrices = {
	private _pricesChart = _this;
	if !(_pricesChart isEqualTypeParams [[],[],[],[]]) exitWith {
		(format["NWG_ISHOP_UploadPrices: Invalid prices chart format"]) call NWG_fnc_logError;
		false
	};

	//Update prices chart
	NWG_ISHOP_itemsPriceChart = _pricesChart;

	//Update item info cache
	private _newCache = createHashMap;
	{
		private _categoryIndex = _forEachIndex;
		{_newCache set [_x,[_categoryIndex,_forEachIndex]]} forEach (_x#CHART_ITEMS);
	} forEach _pricesChart;
	NWG_ISHOP_itemsInfoCache = _newCache;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Shop

//Items that are added on top of persistent items
NWG_ISHOP_dynamicItems = [
	[],
	[],
	[],
	[]
];

NWG_ISHOP_OnShopRequest = {
	private _player = _this;

	//So... what should I do here?
	//Well, first, we need a) player loot, b) persistent+dynaic shop items
	//Then I guess we need to evaluate prices for all of these items
	//And what will we return as a result?
	//[playerItems,shopItems,pricesMap]

	//Get player loot
	private _playerLoot = _player call (NWG_ISHOP_Settings get "SHOP_GET_PLAYER_LOOT_FUNC");
	if !(_playerLoot isEqualTypeParams [[],[],[],[]]) exitWith {
		(format["NWG_ISHOP_OnShopRequest: Invalid player loot format"]) call NWG_fnc_logError;
	};

	//Get persistent shop items
	private _persistentItems = NWG_ISHOP_Settings get "SHOP_PERSISTENT_ITEMS";
	private _isError = false;
	if (NWG_ISHOP_Settings get "SHOP_CHECK_PERSISTENT_ITEMS") then {
		//Check overall structure
		if !(_persistentItems isEqualTypeParams [[],[],[],[]]) exitWith {
			(format["NWG_ISHOP_OnShopRequest: Invalid persistent shop items format"]) call NWG_fnc_logError;
			_isError = true;
		};

		//Check that each element is of correct type
		private ["_expected","_i"];
		{
			_expected = switch (_forEachIndex) do {
				case CAT_CLTH: {LOOT_ITEM_TYPE_CLTH};
				case CAT_WEAP: {LOOT_ITEM_TYPE_WEPN};
				case CAT_ITEM: {LOOT_ITEM_TYPE_ITEM};
				case CAT_AMMO: {LOOT_ITEM_TYPE_AMMO};
				default {""};
			};
			_i = _x findIf {_x isEqualType "" && {(_x call NWG_fnc_icatGetItemType) isNotEqualTo _expected}};
			if (_i != -1) exitWith {
				(format["NWG_ISHOP_OnShopRequest: Invalid persistent item '%1'. Expected: '%2', Actual: '%3'",(_x#_i),_expected,((_x#_i) call NWG_fnc_icatGetItemType)]) call NWG_fnc_logError;
				_isError = true;
			};
		} forEach _persistentItems;
	};
	if (_isError) exitWith {
		false
	};

	//Get dynamic shop items
	private _dynamicItems = NWG_ISHOP_dynamicItems;

	//Combine shop items
	private _shopItems = [
		((_persistentItems#CAT_CLTH) + (_dynamicItems#CAT_CLTH)),
		((_persistentItems#CAT_WEAP) + (_dynamicItems#CAT_WEAP)),
		((_persistentItems#CAT_ITEM) + (_dynamicItems#CAT_ITEM)),
		((_persistentItems#CAT_AMMO) + (_dynamicItems#CAT_AMMO))
	];

	//Evaluate prices
	private _allItems = _playerLoot + _shopItems;
	_allItems = (flatten _allItems) select {_x isEqualType ""};
	_allItems = _allItems arrayIntersect _allItems;//Remove dublicates

	//Evaluate prices
	private _allPrices = _allItems apply {_x call NWG_ISHOP_EvaluateItem};

	//Send back result
	private _result = [
		(if (NWG_ISHOP_Settings get "SHOP_SKIP_SENDING_PLAYER_LOOT") then {[]} else {_playerLoot}),
		_shopItems,
		_allItems,
		_allPrices
	];
	_result remoteExec ["NWG_ISHOP_OnShopResponse",_player];

	//return (mostly for testing)
	_result
};