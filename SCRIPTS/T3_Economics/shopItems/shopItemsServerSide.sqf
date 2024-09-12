#include "..\..\globalDefines.h"

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

	["",0]
];

//================================================================================================================
//================================================================================================================
//Prices
//Loot items types
#define CAT_CLTH 0
#define CAT_WEAP 1
#define CAT_ITEM 2
#define CAT_AMMO 3

#define CACHED_CATEGORY 0
#define CACHED_INDEX 1
#define CHART_ITEMS 0
#define CHART_PRICES 1
NWG_ISHOP_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
NWG_ISHOP_itemsPriceChart = [
	[[],[]],//CAT_CLTH [items,prices]
	[[],[]],//CAT_WEAP [items,prices]
	[[],[]],//CAT_ITEM [items,prices]
	[[],[]] //CAT_AMMO [items,prices]
];

NWG_ISHOP_EvaluateItems = {
	params ["_items",["_knownType",""]];
	private _isKnownType = _knownType isNotEqualTo "";
	private _getOrNew = {
		// private _item = _this;

		//Get cached item info if exists
		private _c = NWG_ISHOP_itemsInfoCache get _this;
		if (!isNil "_c") exitWith {
			(((NWG_ISHOP_itemsPriceChart select (_c#CACHED_CATEGORY))/*Select category in chart*/
				select CHART_PRICES)/*Select prices row*/
				select (_c#CACHED_INDEX))/*Select price by index in a row*/
		};

		//Create new item info
		private _itemType = if (_isKnownType)
			then {_knownType}
			else {_this call NWG_fnc_icatGetItemType};
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
				(format["NWG_ISHOP_EvaluateItems: Invalid item type %1",_itemType]) call NWG_fnc_logError;
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

	//return
	_items apply {round (_x call _getOrNew)}
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