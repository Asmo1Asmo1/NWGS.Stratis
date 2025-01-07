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
	["CATALOGUE_PATH_VANILLA","DATASETS\Server\ShopVehicles\_Vanilla.sqf"],//Path to vanilla loot catalogue

    ["DEFAULT_PRICE_AAIR_ARMED",200000],
	["DEFAULT_PRICE_AAIR_UNARMED",140000],
    ["DEFAULT_PRICE_APCS_ARMED",125000],
	["DEFAULT_PRICE_APCS_UNARMED",85000],
    ["DEFAULT_PRICE_ARTY_ARMED",200000],
	["DEFAULT_PRICE_ARTY_UNARMED",140000],
    ["DEFAULT_PRICE_BOAT_ARMED",15000],
	["DEFAULT_PRICE_BOAT_UNARMED",9000],
    ["DEFAULT_PRICE_CARS_ARMED",15000],
	["DEFAULT_PRICE_CARS_UNARMED",9000],
    ["DEFAULT_PRICE_DRON_ARMED",27000],
	["DEFAULT_PRICE_DRON_UNARMED",9000],
    ["DEFAULT_PRICE_HELI_ARMED",250000],
	["DEFAULT_PRICE_HELI_UNARMED",60000],
    ["DEFAULT_PRICE_PLAN_ARMED",300000],
	["DEFAULT_PRICE_PLAN_UNARMED",150000],
    ["DEFAULT_PRICE_SUBM_ARMED",24000],
	["DEFAULT_PRICE_SUBM_UNARMED",12000],
    ["DEFAULT_PRICE_TANK_ARMED",240000],
	["DEFAULT_PRICE_TANK_UNARMED",150000],

    //[activeFactor,passiveFactor,priceMin,priceMax]
    ["PRICE_AAIR_SETTINGS",[1000,100,70000,500000]],
    ["PRICE_APCS_SETTINGS",[1000,100,40000,250000]],
    ["PRICE_ARTY_SETTINGS",[1000,100,70000,500000]],
    ["PRICE_BOAT_SETTINGS",[100,10,8000,20000]],
    ["PRICE_CARS_SETTINGS",[100,10,4500,30000]],
    ["PRICE_DRON_SETTINGS",[100,10,4500,60000]],
    ["PRICE_HELI_SETTINGS",[500,50,30000,10000000]],
    ["PRICE_PLAN_SETTINGS",[1000,100,75000,10000000]],
    ["PRICE_SUBM_SETTINGS",[100,10,10000,24000]],
    ["PRICE_TANK_SETTINGS",[1000,100,75000,10000000]],

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
        [],/*SUBM*/
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
	private _isArmed = _this call NWG_VSHOP_SER_IsArmedVehicle;
	private _categoryIndex = -1;
	private _defaultPrice = 0;
	switch (_vehType) do {
		case LOOT_VEHC_TYPE_AAIR: {
			_categoryIndex = LOOT_VEHC_CAT_AAIR;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_AAIR_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_AAIR_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_APCS: {
			_categoryIndex = LOOT_VEHC_CAT_APCS;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_APCS_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_APCS_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_ARTY: {
			_categoryIndex = LOOT_VEHC_CAT_ARTY;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_ARTY_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_ARTY_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_BOAT: {
			_categoryIndex = LOOT_VEHC_CAT_BOAT;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_BOAT_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_BOAT_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_CARS: {
			_categoryIndex = LOOT_VEHC_CAT_CARS;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_CARS_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_CARS_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_DRON: {
			_categoryIndex = LOOT_VEHC_CAT_DRON;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_DRON_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_DRON_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_HELI: {
			_categoryIndex = LOOT_VEHC_CAT_HELI;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_HELI_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_HELI_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_PLAN: {
			_categoryIndex = LOOT_VEHC_CAT_PLAN;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_PLAN_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_PLAN_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_SUBM: {
			_categoryIndex = LOOT_VEHC_CAT_SUBM;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_SUBM_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_SUBM_ARMED")] select _isArmed;
		};
		case LOOT_VEHC_TYPE_TANK: {
			_categoryIndex = LOOT_VEHC_CAT_TANK;
			_defaultPrice = [(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_TANK_UNARMED"),(NWG_VSHOP_SER_Settings get "DEFAULT_PRICE_TANK_ARMED")] select _isArmed;
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

NWG_VSHOP_SER_notWeapon = ["Horn","designator","Flare","Smoke"];
NWG_VSHOP_SER_IsArmedVehicle = {
	private _classname = _this;

	//Get vehicle config
	private _config = configFile >> "CfgVehicles" >> _classname;
	if !(isClass _config) exitWith {
		(format["NWG_VSHOP_SER_IsArmedVehicle: Invalid vehicle classname '%1'",_classname]) call NWG_fnc_logError;
		false
	};

	//Check pylons
    if ((count ("true" configClasses (_config >> "Components" >> "TransportPylonsComponent"))) > 0) exitWith {true};

	//Check main weapon defined in root config
	private _found = false;
	private _mainWeapons = getArray (_config >> "weapons");
	if (!isNil "_mainWeapons" && {_mainWeapons isEqualTypeArray []}) then {
		_found = (_mainWeapons findIf {_cur = _x; (NWG_VSHOP_SER_notWeapon findIf {_x in _cur}) == -1}) != -1;
	};
	if (_found) exitWith {true};

	//Get all turrets and their respective weapons
	private _turrets = flatten (("true" configClasses (_config >> "Turrets")) apply {getArray (_x >> "weapons")});
	_found = (_turrets findIf {_cur = _x; (NWG_VSHOP_SER_notWeapon findIf {_x in _cur}) == -1}) != -1;

	//return
	_found
};

NWG_VSHOP_SER_UpdatePrices = {
	params ["_categoryIndex","_vehs","_isSoldToPlayer"];

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

	//Prepare for processing
	private _priceChart = (NWG_VSHOP_SER_vehsPriceChart select _categoryIndex) select CHART_PRICES;
	private _curPrice = 0;
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

		_cachedInfo = NWG_VSHOP_SER_vehsInfoCache get _x;
		if (isNil "_cachedInfo") then {
			(format["NWG_VSHOP_SER_UpdatePrices: Vehicle '%1' is not cached, evaluate items before updating prices",_x]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};
		_cachedInfo params ["_vCat","_vIndex"];
		if (_vCat != _categoryIndex) then {
			(format["NWG_VSHOP_SER_UpdatePrices: Vehicle '%1' is not in the right category. Expected: '%2', Actual: '%3'",_x,_categoryIndex,_vCat]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};
		if (_vIndex < 0 || {_vIndex >= (count _priceChart)}) then {
			(format["NWG_VSHOP_SER_UpdatePrices: Vehicle's '%1' price index '%2' is out of bounds for category '%3'",_x,_vIndex,_categoryIndex]) call NWG_fnc_logError;
			_count = 1;
			continue;
		};

		_actives pushBackUnique _vIndex;
		_totalCount = _totalCount + _count;
		_curPrice = _priceChart#_vIndex;
		_curPrice = ((_curPrice + (_activeFactor*_count)) max _priceMin) min _priceMax;
		_priceChart set [_vIndex,_curPrice];
		_curPrice = 0;
		_count = 1;

	} forEach _vehs;

	//Check at least one change was made
	if (_totalCount == 0) exitWith {
		(format["NWG_VSHOP_SER_UpdatePrices: No changes were made to the price chart for category '%1'",_categoryIndex]) call NWG_fnc_logError;
		false
	};

	//Update passive items
	{
		if (_forEachIndex in _actives) then {continue};
		_curPrice = _x;
		_curPrice = ((_curPrice + (_passiveFactor*_totalCount)) max _priceMin) min _priceMax;
		_priceChart set [_forEachIndex,_curPrice];
	} forEach _priceChart;

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
//Items chart conversion
NWG_VSHOP_SER_ArrayToChart = {
	private _array = _this;
	private _chart = LOOT_VEHC_DEFAULT_CHART;
	if ((count _array) == 0) exitWith {_chart};

	//Uncompact incoming array if needed
	if ((_array findIf {_x isEqualType 1}) != -1) then {
		_array = _array call NWG_fnc_unCompactStringArray;
	};

	//Sort items by category
	{
		switch (_x call NWG_fnc_vcatGetVehcType) do {
			case LOOT_VEHC_TYPE_AAIR: {(_chart#LOOT_VEHC_CAT_AAIR) pushBack _x};
			case LOOT_VEHC_TYPE_APCS: {(_chart#LOOT_VEHC_CAT_APCS) pushBack _x};
			case LOOT_VEHC_TYPE_ARTY: {(_chart#LOOT_VEHC_CAT_ARTY) pushBack _x};
			case LOOT_VEHC_TYPE_BOAT: {(_chart#LOOT_VEHC_CAT_BOAT) pushBack _x};
			case LOOT_VEHC_TYPE_CARS: {(_chart#LOOT_VEHC_CAT_CARS) pushBack _x};
			case LOOT_VEHC_TYPE_DRON: {(_chart#LOOT_VEHC_CAT_DRON) pushBack _x};
			case LOOT_VEHC_TYPE_HELI: {(_chart#LOOT_VEHC_CAT_HELI) pushBack _x};
			case LOOT_VEHC_TYPE_PLAN: {(_chart#LOOT_VEHC_CAT_PLAN) pushBack _x};
			case LOOT_VEHC_TYPE_SUBM: {(_chart#LOOT_VEHC_CAT_SUBM) pushBack _x};
			case LOOT_VEHC_TYPE_TANK: {(_chart#LOOT_VEHC_CAT_TANK) pushBack _x};
			default {
				(format["NWG_VSHOP_SER_ArrayToChart: Invalid item type '%1'-'%2'",_x,(_x call NWG_fnc_vcatGetVehcType)]) call NWG_fnc_logError;
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
				(format["NWG_VSHOP_SER_ValidateItemsChart: Invalid item '%1'. Expected: 'STRING'",_x]) call NWG_fnc_logError;
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
	(_persistentItems call NWG_VSHOP_SER_ValidateItemsChart) params ["_sanitizedChart","_isValid"];
	if (!_isValid) then {
		(format["NWG_VSHOP_SER_ValidatePersistentItems: Invalid persistent shop items, check logs and your NWG_VSHOP_SER_Settings"]) call NWG_fnc_logError;
		NWG_VSHOP_SER_Settings set ["SHOP_PERSISTENT_ITEMS",_sanitizedChart];
	};

	//return
	_isValid
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
	[] /*TANK*/
];

NWG_VSHOP_SER_AddDynamicItems = {
	// private _itemsArray = _this;
	if ((count _this) == 0) exitWith {};

	//Convert and validate
	((_this call NWG_VSHOP_SER_ArrayToChart) call NWG_VSHOP_SER_ValidateItemsChart) params ["_sanitizedChart","_isValid"];
	if (!_isValid) then {
		"NWG_VSHOP_SER_AddDynamicItems: Invalid items found, check RPT for details" call NWG_fnc_logError;
	};

	//foreach category of itemsToAdd
	private _newItems = [];
	{
		_newItems = [(NWG_VSHOP_SER_dynamicItems#_forEachIndex),_x] call NWG_fnc_mergeCompactedStringArrays;
		NWG_VSHOP_SER_dynamicItems set [_forEachIndex,_newItems];
	} forEach _sanitizedChart;

	//return
	_isValid
};

NWG_VSHOP_SER_RemoveDynamicItems = {
	// private _itemsArray = _this;
	if ((count _this) == 0) exitWith {};

	//foreach category of itemsToRemove
	//This whole logic is a bit complex, but it will execute faster than uncompacting both arrays and substracting one from another
	//Also, we skip validation on purpose - if item is invalid, we will not find it in dynamic items in the first place and removal will be skipped
	private ["_removeArray","_existingArray","_removeCount","_i","_existingCount","_remainingCount"];
	{
		_removeArray = _x;
		if ((count _removeArray) == 0) then {continue};

		_existingArray = NWG_VSHOP_SER_dynamicItems#_forEachIndex;
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
	} forEach (_this call NWG_VSHOP_SER_ArrayToChart);
};

NWG_VSHOP_SER_dynamicItemsCatalogue = nil;
NWG_VSHOP_SER_AddDynamicItemsFromCatalogue = {
	private _addCount = _this;

	//Check if need to compile catalogue
	if (isNil "NWG_VSHOP_SER_dynamicItemsCatalogue") then {
		private _cataloguePath = NWG_VSHOP_SER_Settings get "CATALOGUE_PATH_VANILLA";
		private _catalogue = call (_cataloguePath call NWG_fnc_compile);
		if (isNil "_catalogue" || {!(_catalogue isEqualType [])}) exitWith {
			(format["NWG_VSHOP_SER_AddDynamicItemsFromCatalogue: Failed to compile catalogue: '%1'",_cataloguePath]) call NWG_fnc_logError;
			NWG_VSHOP_SER_dynamicItemsCatalogue = [];
		};
		if ((count _catalogue) == 0) exitWith {
			(format["NWG_VSHOP_SER_AddDynamicItemsFromCatalogue: Catalogue is empty: '%1'",_cataloguePath]) call NWG_fnc_logError;
			NWG_VSHOP_SER_dynamicItemsCatalogue = [];
		};
		NWG_VSHOP_SER_dynamicItemsCatalogue = _catalogue;
	};

	//Get list of items that could be added
	private _persistentItems = (flatten (NWG_VSHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS")) select {_x isEqualType ""};
	private _dynamicItems = (flatten NWG_VSHOP_SER_dynamicItems) select {_x isEqualType ""};
	private _toAdd = (NWG_VSHOP_SER_dynamicItemsCatalogue - _persistentItems) - _dynamicItems;
	if ((count _toAdd) == 0) exitWith {};//Nothing to add

	//Shuffle and add
	_toAdd = _toAdd call NWG_fnc_arrayShuffle;
	if ((count _toAdd) > _addCount) then {
		_toAdd resize _addCount;
	};
	_toAdd call NWG_VSHOP_SER_AddDynamicItems;
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

//NEW IMPLEMENTATION
NWG_VSHOP_SER_OnTransaction = {
	params ["_itemsSoldToPlayer","_itemsBoughtFromPlayer"];

	//Prepare chance applying
	private _applyChance = {
		params ["_items","_chanceName"];
		private _chance = ((NWG_VSHOP_SER_Settings get _chanceName) max 0) min 1;
		//return
		switch (_chance) do {
			case 0: {[]};
			case 1: {_items};
			default {(_items call NWG_fnc_unCompactStringArray) select {(random 1) <= _chance}};
		}
	};

	//Update sold items
	if ((count _itemsSoldToPlayer) > 0) then {
		//Update prices
		private _soldChart = _itemsSoldToPlayer call NWG_VSHOP_SER_ArrayToChart;
		{
			if ((count _x) > 0) then {[_forEachIndex,_x,true] call NWG_VSHOP_SER_UpdatePrices};
		} forEach _soldChart;

		//Update dynamic items
		private _soldFiltered = [_itemsSoldToPlayer,"SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE"] call _applyChance;
		if ((count _soldFiltered) > 0) then {_soldFiltered call NWG_VSHOP_SER_RemoveDynamicItems};
	};

	//Update bought items
	if ((count _itemsBoughtFromPlayer) > 0) then {
		//Update prices
		private _boughtChart = _itemsBoughtFromPlayer call NWG_VSHOP_SER_ArrayToChart;
		{
			if ((count _x) > 0) then {[_forEachIndex,_x,false] call NWG_VSHOP_SER_UpdatePrices};
		} forEach _boughtChart;

		//Update dynamic items
		private _boughtFiltered = [_itemsBoughtFromPlayer,"SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE"] call _applyChance;
		if ((count _boughtFiltered) > 0) then {_boughtFiltered call NWG_VSHOP_SER_AddDynamicItems};
	};
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

	//Clear vehicle cargo
	_vehicle call NWG_fnc_clearContainerCargo;

	//Create AI crew for UAVs
	if (unitIsUAV _vehicle) then {
		(side (group _player)) createVehicleCrew _vehicle;
	};

	//return
	true
};

//================================================================================================================
//================================================================================================================
call _Init