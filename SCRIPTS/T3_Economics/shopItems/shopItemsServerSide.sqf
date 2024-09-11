#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_ISHOP_Settings = createHashMapFromArray [
    ["DEFAULT_PRICE_CLTH",100],
    ["DEFAULT_PRICE_WEAP",110],
    ["DEFAULT_PRICE_ITEM",120],
    ["DEFAULT_PRICE_AMMO",130],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Prices
//Loot items types
#define CACHED_CATEGORY 0
#define CACHED_INDEX 1
#define CHART_ITEMS 0
#define CHART_PRICES 1
NWG_ISHOP_itemsInfoCache = createHashMap;//[_category,_index]
NWG_ISHOP_itemsPriceChart = [
	[[],[]],//LOOT_ITEM_TYPE_CLTH [items,prices]
	[[],[]],//LOOT_ITEM_TYPE_WEPN [items,prices]
	[[],[]],//LOOT_ITEM_TYPE_ITEM [items,prices]
	[[],[]] //LOOT_ITEM_TYPE_AMMO [items,prices]
];

NWG_ISHOP_EvaluateItems = {
	params ["_items",["_knownCatg",""]];
	private _isKnownCatg = _knownCatg isNotEqualTo "";
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
		private _category = if (_isKnownCatg)
			then {_knownCatg}
			else {_this call NWG_fnc_icatGetItemType};
		private _categoryIndex = -1;
		private _defaultPrice = 0;
		switch (_category) do {
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
				(format["NWG_ISHOP_EvaluateItems: Invalid category %1",_category]) call NWG_fnc_logError;
			};
		};
		if (_categoryIndex == -1) exitWith {_defaultPrice};//<== EXIT WITH ZERO DEFAULT on error

		//Add new item info to chart and cache
		private _index = ((NWG_ISHOP_itemsPriceChart select _categoryIndex) select CHART_ITEMS) pushBack _this;
		((NWG_ISHOP_itemsPriceChart select _categoryIndex) select CHART_PRICES) pushBack _defaultPrice;
		NWG_ISHOP_itemsInfoCache set [_this,[_categoryIndex,_index]];

		//return price
		_defaultPrice
	};

	//return
	_items apply {round (_x call _getOrNew)}
};