#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
#define CACHED_CATEGORY 0
#define CACHED_INDEX 1
#define CHART_ITEMS 0
#define CHART_PRICES 1

#define LOOT_VEHC_TYPE_AAIR "AAIR"  // Anti-Air (EdSubcat_AAs)
#define LOOT_VEHC_TYPE_APCS "APCS"  // Armored Personnel Carriers (EdSubcat_APCs)
#define LOOT_VEHC_TYPE_ARTY "ARTY"  // Artillery (EdSubcat_Artillery)
#define LOOT_VEHC_TYPE_BOAT "BOAT"  // Boats (EdSubcat_Boats)
#define LOOT_VEHC_TYPE_CARS "CARS"  // Cars (EdSubcat_Cars)
#define LOOT_VEHC_TYPE_DRON "DRON"  // Drones (EdSubcat_Drones)
#define LOOT_VEHC_TYPE_HELI "HELI"  // Helicopters (EdSubcat_Helicopters)
#define LOOT_VEHC_TYPE_PLAN "PLAN"  // Planes (EdSubcat_Planes)
#define LOOT_VEHC_TYPE_SUBM "SUBM"  // Submersibles (EdSubcat_Submersibles)
#define LOOT_VEHC_TYPE_TANK "TANK"  // Tanks (EdSubcat_Tanks)

//================================================================================================================
//================================================================================================================
//Settings
NWG_VSHOP_SER_Settings = createHashMapFromArray [
    ["DEFAULT_PRICE_AAIR",50000],
    ["DEFAULT_PRICE_APCS",35000],
    ["DEFAULT_PRICE_ARTY",45000],
    ["DEFAULT_PRICE_BOAT",15000],
    ["DEFAULT_PRICE_CARS",5000],
    ["DEFAULT_PRICE_DRON",10000],
    ["DEFAULT_PRICE_HELI",40000],
    ["DEFAULT_PRICE_PLAN",60000],
    ["DEFAULT_PRICE_SUBM",30000],
    ["DEFAULT_PRICE_TANK",55000],

    //[activeFactor,passiveFactor,priceMin,priceMax]
    ["PRICE_AAIR_SETTINGS",[0.01,0.002,40000,80000]],
    ["PRICE_APCS_SETTINGS",[0.01,0.002,25000,50000]],
    ["PRICE_ARTY_SETTINGS",[0.01,0.002,35000,70000]],
    ["PRICE_BOAT_SETTINGS",[0.01,0.002,10000,25000]],
    ["PRICE_CARS_SETTINGS",[0.01,0.002,3000,10000]],
    ["PRICE_DRON_SETTINGS",[0.01,0.002,7000,20000]],
    ["PRICE_HELI_SETTINGS",[0.01,0.002,30000,60000]],
    ["PRICE_PLAN_SETTINGS",[0.01,0.002,45000,100000]],
    ["PRICE_SUBM_SETTINGS",[0.01,0.002,20000,50000]],
    ["PRICE_TANK_SETTINGS",[0.01,0.002,40000,90000]],

	//Items that are added to each shop interaction
	["SHOP_PERSISTENT_ITEMS",[
		[],/*AAIR*/
        [],/*APCS*/
        [],/*ARTY*/
        ["B_Boat_Transport_01_F","B_Boat_Armed_01_minigun_F"],/*BOAT*/
        ["B_G_Offroad_01_F","B_MRAP_01_F","B_LSV_01_unarmed_F","B_Quadbike_01_F"],/*CARS*/
        [],/*DRON*/
        ["B_Heli_Light_01_F"],/*HELI*/
        [],/*PLAN*/
        ["B_SDV_01_F"],/*SUBM*/
        []/*TANK*/
	]],
	["SHOP_CHECK_PERSISTENT_ITEMS_ON_INIT",false],//Check validity of persistent items on init
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",1],//Chance that item will be added to dynamic items when bought from player
	["SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE",0],//Chance that item will be removed from dynamic items when sold to player

    ["SPAWN_PLATFORM_FUNC",{_this call NWG_fnc_spwnSpawnVehicleExact}],//Function to use for spawn on the platform. params ["_classname","_pos","_dir"]

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_VSHOP_spawnPlatform = objNull;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	if (NWG_VSHOP_SER_Settings get "SHOP_CHECK_PERSISTENT_ITEMS_ON_INIT") then {
		call NWG_VSHOP_SER_ValidatePersistentItems;
	};
};

//================================================================================================================
//================================================================================================================
//Setup spawn platform object
NWG_VSHOP_SER_SetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    NWG_VSHOP_spawnPlatform = _this;
    publicVariable "NWG_VSHOP_spawnPlatform";
};

//================================================================================================================
//================================================================================================================
//Prices
NWG_VSHOP_SER_vehsInfoCache = createHashMap;//[_categoryIndex,_vehIndex]
NWG_VSHOP_SER_vehsPriceChart = [
	[[],[]],//LOOT_VEHC_TYPE_AAIR [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_APCS [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_ARTY [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_BOAT [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_CARS [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_DRON [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_HELI [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_PLAN [items,prices]
    [[],[]],//LOOT_VEHC_TYPE_SUBM [items,prices]
    [[],[]] //LOOT_VEHC_TYPE_TANK [items,prices]
];

NWG_VSHOP_SER_EvaluateVeh = {
	// private _veh = _this;

	//Get cached item info if exists
	private _c = NWG_VSHOP_SER_vehsInfoCache get _this;
	if (!isNil "_c") exitWith {
		(((NWG_VSHOP_SER_vehsPriceChart select (_c#CACHED_CATEGORY))/*Select category in chart*/
			select CHART_PRICES)/*Select prices row*/
			select (_c#CACHED_INDEX))/*Select price by index in a row*/
	};

	//Create new item info
	private _vehType = _this call NWG_fnc_vcatGetVehcType;
	private _categoryIndex = -1;
	private _defaultPrice = 0;
	switch (_vehType) do {
		case LOOT_VEHC_TYPE_AAIR: {
			_categoryIndex = LOOT_VEHC_CAT_AAIR;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_AAIR";
		};
		case LOOT_VEHC_TYPE_APCS: {
			_categoryIndex = LOOT_VEHC_CAT_APCS;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_APCS";
		};
		case LOOT_VEHC_TYPE_ARTY: {
			_categoryIndex = LOOT_VEHC_CAT_ARTY;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_ARTY";
		};
		case LOOT_VEHC_TYPE_BOAT: {
			_categoryIndex = LOOT_VEHC_CAT_BOAT;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_BOAT";
		};
		case LOOT_VEHC_TYPE_CARS: {
			_categoryIndex = LOOT_VEHC_CAT_CARS;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_CARS";
		};
		case LOOT_VEHC_TYPE_DRON: {
			_categoryIndex = LOOT_VEHC_CAT_DRON;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_DRON";
		};
		case LOOT_VEHC_TYPE_HELI: {
			_categoryIndex = LOOT_VEHC_CAT_HELI;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_HELI";
		};
		case LOOT_VEHC_TYPE_PLAN: {
			_categoryIndex = LOOT_VEHC_CAT_PLAN;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_PLAN";
		};
		case LOOT_VEHC_TYPE_SUBM: {
			_categoryIndex = LOOT_VEHC_CAT_SUBM;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_SUBM";
		};
		case LOOT_VEHC_TYPE_TANK: {
			_categoryIndex = LOOT_VEHC_CAT_TANK;
			_defaultPrice = NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_TANK";
		};
		default {
			(format["NWG_VSHOP_SER_EvaluateVeh: Invalid veh type %1",_vehType]) call NWG_fnc_logError;
		};
	};
	if (_categoryIndex == -1) exitWith {_defaultPrice};//<== EXIT WITH ZERO DEFAULT on error

	//Add new item info to chart and cache
	private _vehIndex = ((NWG_VSHOP_SER_vehsPriceChart select _categoryIndex) select CHART_ITEMS) pushBack _this;
	((NWG_VSHOP_SER_vehsPriceChart select _categoryIndex) select CHART_PRICES) pushBack _defaultPrice;
	NWG_VSHOP_SER_vehsInfoCache set [_this,[_categoryIndex,_vehIndex]];

	//return price
	_defaultPrice
};

NWG_VSHOP_SER_UpdatePrices = {
	params ["_veh","_quantity","_isSoldToPlayer"];

	//Get item info
	private _cachedInfo = NWG_VSHOP_SER_vehsInfoCache get _veh;
	if (isNil "_cachedInfo") exitWith {
		(format["NWG_VSHOP_SER_UpdatePrices: Vehicle '%1' is not cached, evaluate items before updating prices",_veh]) call NWG_fnc_logError;
		false
	};
	_cachedInfo params ["_categoryIndex","_vehIndex"];

	//Get category settings
	private _settings = switch (_categoryIndex) do {
		case LOOT_VEHC_CAT_AAIR: {NWG_VSHOP_SER_Settings get "PRICE_AAIR_SETTINGS"};
		case LOOT_VEHC_CAT_APCS: {NWG_VSHOP_SER_Settings get "PRICE_APCS_SETTINGS"};
		case LOOT_VEHC_CAT_ARTY: {NWG_VSHOP_SER_Settings get "PRICE_ARTY_SETTINGS"};
		case LOOT_VEHC_CAT_BOAT: {NWG_VSHOP_SER_Settings get "PRICE_BOAT_SETTINGS"};
		case LOOT_VEHC_CAT_CARS: {NWG_VSHOP_SER_Settings get "PRICE_CARS_SETTINGS"};
		case LOOT_VEHC_CAT_DRON: {NWG_VSHOP_SER_Settings get "PRICE_DRON_SETTINGS"};
		case LOOT_VEHC_CAT_HELI: {NWG_VSHOP_SER_Settings get "PRICE_HELI_SETTINGS"};
		case LOOT_VEHC_CAT_PLAN: {NWG_VSHOP_SER_Settings get "PRICE_PLAN_SETTINGS"};
		case LOOT_VEHC_CAT_SUBM: {NWG_VSHOP_SER_Settings get "PRICE_SUBM_SETTINGS"};
		case LOOT_VEHC_CAT_TANK: {NWG_VSHOP_SER_Settings get "PRICE_TANK_SETTINGS"};
		default {
			(format["NWG_VSHOP_SER_UpdatePrices: Invalid category %1",_category]) call NWG_fnc_logError;
			nil
		};
	};
	if (isNil "_settings") exitWith {
		(format["NWG_VSHOP_SER_UpdatePrices: Failed to get category settings for index: '%1'",_categoryIndex]) call NWG_fnc_logError;
		false
	};
	_settings params ["_activeFactor","_passiveFactor","_priceMin","_priceMax"];

	//Define price change
	if (_isSoldToPlayer) then {
		//Vehicle is sold to player, so its price should be increased while others decreased
		//_activeFactor //unchanged
		_passiveFactor = -_passiveFactor;//Turned into negative value
	} else {
		//Vehicle is bought from player, so its price should be decreased while others increased
		_activeFactor = -_activeFactor;//Turned into negative value
		//_passiveFactor //unchanged
	};

	//Process the update
	private _priceChart = (NWG_VSHOP_SER_vehsPriceChart select _categoryIndex) select CHART_PRICES;
	private _activeMultiplier = 1 + (_activeFactor*_quantity);
	private _passiveMultiplier = 1 + (_passiveFactor*_quantity);
	//Process passive multipliers (overlap with active item is accepted)
	{_priceChart set [_forEachIndex,(((_x*_passiveMultiplier) max _priceMin) min _priceMax)]} forEach _priceChart;
	//Process active multiplier
	_priceChart set [_vehIndex,((((_priceChart#_vehIndex)*_activeMultiplier) max _priceMin) min _priceMax)];

	//return
	true
};

NWG_VSHOP_SER_DownloadPrices = {
	//return
	NWG_VSHOP_SER_vehsPriceChart
};

NWG_VSHOP_SER_UploadPrices = {
	private _pricesChart = _this;
	if !(_pricesChart isEqualTypeArray LOOT_VEHC_DEFAULT_CHART) exitWith {
		(format["NWG_VSHOP_SER_UploadPrices: Invalid prices chart format"]) call NWG_fnc_logError;
		false
	};

	//Update prices chart
	NWG_VSHOP_SER_vehsPriceChart = _pricesChart;

	//Update item info cache
	private _newCache = createHashMap;
	{
		private _categoryIndex = _forEachIndex;
		{_newCache set [_x,[_categoryIndex,_forEachIndex]]} forEach (_x#CHART_ITEMS);
	} forEach _pricesChart;
	NWG_VSHOP_SER_vehsInfoCache = _newCache;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Items chart validation
NWG_VSHOP_SER_ValidateItemsChart = {
	// private _itemsChart = _this;

	//Check empty chart
	if (_this isEqualTo LOOT_VEHC_DEFAULT_CHART) exitWith {
		[LOOT_VEHC_DEFAULT_CHART,true]
	};

	//Check overall structure
	if !(_this isEqualTypeArray LOOT_VEHC_DEFAULT_CHART) exitWith {
		(format["NWG_VSHOP_SER_ValidateItemsChart: Invalid items chart format"]) call NWG_fnc_logError;
		[LOOT_VEHC_DEFAULT_CHART,false]
	};

	//Check that each element is of correct type
	private _validationResult = true;
	//foreach category
	{
		if ((count _x) == 0) then {continue};//Skip empty categories

		private _expectedCat = switch (_forEachIndex) do {
			case LOOT_VEHC_CAT_AAIR: {LOOT_VEHC_TYPE_AAIR};
			case LOOT_VEHC_CAT_APCS: {LOOT_VEHC_TYPE_APCS};
			case LOOT_VEHC_CAT_ARTY: {LOOT_VEHC_TYPE_ARTY};
			case LOOT_VEHC_CAT_BOAT: {LOOT_VEHC_TYPE_BOAT};
			case LOOT_VEHC_CAT_CARS: {LOOT_VEHC_TYPE_CARS};
			case LOOT_VEHC_CAT_DRON: {LOOT_VEHC_TYPE_DRON};
			case LOOT_VEHC_CAT_HELI: {LOOT_VEHC_TYPE_HELI};
			case LOOT_VEHC_CAT_PLAN: {LOOT_VEHC_TYPE_PLAN};
			case LOOT_VEHC_CAT_SUBM: {LOOT_VEHC_TYPE_SUBM};
			case LOOT_VEHC_CAT_TANK: {LOOT_VEHC_TYPE_TANK};
			default {""};
		};
		if (_expectedCat isEqualTo "") then {
			(format["NWG_VSHOP_SER_ValidateItemsChart: Invalid category index: '%1'",_forEachIndex]) call NWG_fnc_logError;
			_validationResult = false;
			continue;
		};

		private _failedItems = [];
		private ["_itemCat","_itemUnifiedClassname"];
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
			_itemCat = _x call NWG_fnc_vcatGetVehcType;
			if (_itemCat isNotEqualTo _expectedCat) then {
				(format["NWG_VSHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: '%2', Actual: '%3'",_x,_expectedCat,_itemCat]) call NWG_fnc_logError;
				_failedItems pushBackUnique _x;
				continue;
			};

			//Check item unified classname
			_itemUnifiedClassname = _x call NWG_fnc_vcatGetUnifiedClassname;
			if (_x isNotEqualTo _itemUnifiedClassname) then {
				(format["NWG_VSHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: '%2'",_x,_itemUnifiedClassname]) call NWG_fnc_logError;
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

NWG_VSHOP_SER_ValidatePersistentItems = {
	private _persistentItems = NWG_VSHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS";
	(_persistentItems call NWG_VSHOP_SER_ValidateItemsChart) params ["_chartAfterValidation","_isValid"];
	if (!_isValid) then {
		(format["NWG_VSHOP_SER_ValidatePersistentItems: Invalid persistent shop items, check logs and your NWG_VSHOP_SER_Settings"]) call NWG_fnc_logError;
	};

	NWG_VSHOP_SER_Settings set ["SHOP_PERSISTENT_ITEMS",_chartAfterValidation];
};

//================================================================================================================
//================================================================================================================
//Dynamic items

//Vehicles that are added on top of persistent items
NWG_VSHOP_SER_dynamicItems = [
	[],/*AAIR*/
	[],/*APCS*/
	[],/*ARTY*/
	[],/*BOAT*/
	[],/*CARS*/
	[],/*DRON*/
	[],/*HELI*/
	[],/*PLAN*/
	[],/*SUBM*/
	[]/*TANK*/
];

NWG_VSHOP_SER_DownloadDynamicItems = {
	//return
	NWG_VSHOP_SER_dynamicItems
};

NWG_VSHOP_SER_UploadDynamicItems = {
	// private _dynamicItems = _this;
	(_this call NWG_VSHOP_SER_ValidateItemsChart) params ["_chartAfterValidation","_isValid"];
	if (!_isValid) then {
		(format["NWG_VSHOP_SER_UploadDynamicItems: Invalid dynamic shop items, check logs and your NWG_VSHOP_SER_Settings"]) call NWG_fnc_logError;
	};
	NWG_VSHOP_SER_dynamicItems = _chartAfterValidation;
	//return
	_isValid
};

//================================================================================================================
//================================================================================================================
//Shop
NWG_VSHOP_SER_OnShopRequest = {
	params ["_player","_ownedVehicles"];

	//Merge shop items (omitting count)
	private _persistentItems = NWG_VSHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS";
	private _dynamicItems = NWG_VSHOP_SER_dynamicItems;
	private _shopItems = [];
    private _toAdd = [];
	//foreach category
	{
        _toAdd = ((_persistentItems#_x) + (_dynamicItems#_x)) select {_x isEqualType ""};
        _toAdd = _toAdd arrayIntersect _toAdd;//Remove duplicates
        _shopItems set [_x,_toAdd];
    } forEach [
        LOOT_VEHC_CAT_AAIR,
        LOOT_VEHC_CAT_APCS,
        LOOT_VEHC_CAT_ARTY,
        LOOT_VEHC_CAT_BOAT,
        LOOT_VEHC_CAT_CARS,
        LOOT_VEHC_CAT_DRON,
        LOOT_VEHC_CAT_HELI,
        LOOT_VEHC_CAT_PLAN,
        LOOT_VEHC_CAT_SUBM,
        LOOT_VEHC_CAT_TANK
    ];

	//Evaluate prices
	private _allItems = _ownedVehicles + _shopItems;
	_allItems = (flatten _allItems) select {_x isEqualType ""};
	_allItems = _allItems arrayIntersect _allItems;//Remove duplicates
	private _allPrices = _allItems apply {_x call NWG_VSHOP_SER_EvaluateVeh};

	//Send back result
	private _result = [
		_shopItems,
		_allItems,
		_allPrices
	];
	_result remoteExec ["NWG_fnc_vshopShopValuesResponse",_player];

	//return (mostly for testing)
	_result
};

NWG_VSHOP_SER_OnTransaction = {
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
					[_x,_quantity,_isSoldToPlayer] call NWG_VSHOP_SER_UpdatePrices;
					_quantity = 1;
				};
				default {
					(format["NWG_VSHOP_SER_OnTransaction: Invalid item type '%1'",_x]) call NWG_fnc_logError;
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

		private _chance = ((NWG_VSHOP_SER_Settings get _chanceName) max 0) min 1;
		_items = switch (_chance) do {
			case 0: {[]};
			case 1: {(_items + []) call NWG_fnc_unCompactStringArray};
			default {((_items + []) call NWG_fnc_unCompactStringArray) select {(random 1) <= _chance}};
		};
		if ((count _items) == 0) exitWith {[]};

		private _itemsCategorized = LOOT_VEHC_DEFAULT_CHART;
		{
			switch (_x call NWG_fnc_vcatGetVehcType) do {
				case LOOT_VEHC_TYPE_AAIR: {(_itemsCategorized#LOOT_VEHC_CAT_AAIR) pushBack _x};
				case LOOT_VEHC_TYPE_APCS: {(_itemsCategorized#LOOT_VEHC_CAT_APCS) pushBack _x};
				case LOOT_VEHC_TYPE_ARTY: {(_itemsCategorized#LOOT_VEHC_CAT_ARTY) pushBack _x};
				case LOOT_VEHC_TYPE_BOAT: {(_itemsCategorized#LOOT_VEHC_CAT_BOAT) pushBack _x};
				case LOOT_VEHC_TYPE_CARS: {(_itemsCategorized#LOOT_VEHC_CAT_CARS) pushBack _x};
				case LOOT_VEHC_TYPE_DRON: {(_itemsCategorized#LOOT_VEHC_CAT_DRON) pushBack _x};
				case LOOT_VEHC_TYPE_HELI: {(_itemsCategorized#LOOT_VEHC_CAT_HELI) pushBack _x};
				case LOOT_VEHC_TYPE_PLAN: {(_itemsCategorized#LOOT_VEHC_CAT_PLAN) pushBack _x};
				case LOOT_VEHC_TYPE_SUBM: {(_itemsCategorized#LOOT_VEHC_CAT_SUBM) pushBack _x};
				case LOOT_VEHC_TYPE_TANK: {(_itemsCategorized#LOOT_VEHC_CAT_TANK) pushBack _x};
				default {
					(format["NWG_VSHOP_SER_OnTransaction: Invalid item type '%1'-'%2'",_x,(_x call NWG_fnc_vcatGetVehcType)]) call NWG_fnc_logError;
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
		if ((count (NWG_VSHOP_SER_dynamicItems#_forEachIndex)) == 0) then {
			NWG_VSHOP_SER_dynamicItems set [_forEachIndex,_x];
			continue;
		};

		//Both arrays are non-empty - merge
		NWG_VSHOP_SER_dynamicItems set [
			_forEachIndex,
			([(NWG_VSHOP_SER_dynamicItems#_forEachIndex),_x] call NWG_fnc_mergeCompactedStringArrays)
		];
	} forEach ([_itemsBoughtFromPlayer,"SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE"] call _getCategorizedItemsToProcess);


	/* ==Remove dynamic items== */
	//foreach category of itemsToRemove
	private ["_removeArray","_removeCount","_existingArray","_existingCount","_i","_remainingCount"];
	{
		_removeArray = _x;
		if ((count _removeArray) == 0) then {continue};

		_existingArray = NWG_VSHOP_SER_dynamicItems#_forEachIndex;
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

//================================================================================================================
//================================================================================================================
//Vehicles processing
NWG_VSHOP_SER_DeleteVehicle = {
	// private _vehicle = _this;
	deleteVehicle _this;
};

NWG_VSHOP_SER_SpawnVehicleAtPlatform = {
	params ["_player","_vehicleClassname"];
    if (_vehicleClassname isEqualTo "" || {!(_vehicleClassname isEqualType "")}) exitWith {
        (format["NWG_VSHOP_SER_SpawnVehicleAtPlatform: Invalid vehicle classname '%1'",_vehicleClassname]) call NWG_fnc_logError;
        false
    };

    private _platform = NWG_VSHOP_spawnPlatform;
    if (isNil "_platform" || {!(_platform isEqualType objNull) || {isNull _platform}}) exitWith {
        (format["NWG_VSHOP_SER_SpawnVehicleAtPlatform: No platform found"]) call NWG_fnc_logError;
        false
    };

    private _spwnFunc = (NWG_VSHOP_SER_Settings get "SPAWN_PLATFORM_FUNC");
    if (isNil "_spwnFunc" || {!(_spwnFunc isEqualType {})}) exitWith {
        (format["NWG_VSHOP_SER_SpawnVehicleAtPlatform: Invalid spawn function defined"]) call NWG_fnc_logError;
        false
    };

	//Spawn vehicle
    private _pos = getPosASL _platform;
    private _dir = getDir _platform;
    private _vehicle = [_vehicleClassname,_pos,_dir] call _spwnFunc;
	if (_vehicle isEqualTo false) exitWith {
		(format["NWG_VSHOP_SER_SpawnVehicleAtPlatform: Failed to spawn vehicle '%1'",_vehicleClassname]) call NWG_fnc_logError;
		false
	};
	if (!(_vehicle isEqualType objNull) || {isNull _vehicle}) exitWith {
		(format["NWG_VSHOP_SER_SpawnVehicleAtPlatform: Spawned vehicle is null"]) call NWG_fnc_logError;
		false
	};

	//Add vehicle to player's sell pool
	_vehicle remoteExec ["NWG_fnc_vshopAddVehicleToSellPool",_player];

	//Setup vehicle ownership
	[_vehicle,_player] call NWG_fnc_vownPairVehAndPlayer;

	//return
	true
};

//================================================================================================================
//================================================================================================================
call _Init