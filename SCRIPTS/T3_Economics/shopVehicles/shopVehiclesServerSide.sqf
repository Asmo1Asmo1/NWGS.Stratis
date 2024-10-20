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
	["SHOP_CHECK_PERSISTENT_ITEMS",true],//Each interaction check validity of persistent items
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",1],//Chance that item will be added to dynamic items when bought from player
	["SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE",0],//Chance that item will be removed from dynamic items when sold to player

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_VSHOP_SER_spawnPlatform = objNull;

//================================================================================================================
//================================================================================================================
//Setup spawn platform object
NWG_VSHOP_SER_SetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    NWG_VSHOP_SER_spawnPlatform = _this;
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
	params ["_veh","_isSoldToPlayer"];

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
	private _activeMultiplier = 1 + _activeFactor;
	private _passiveMultiplier = 1 + _passiveFactor;
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
	if !(_pricesChart isEqualTypeParams [[],[],[],[],[],[],[],[],[],[]]) exitWith {
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