#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Prices change over time
// call NWG_ECOT_PricesLifetime_Test_RandomEqual
NWG_ECOT_PricesLifetime_Test_RandomEqual = {
	private _items = ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","ChemicalDetector_01_watch_F","MineDetector","FirstAidKit","Medikit","ToolKit"];
	private _randomization = [[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1]];//[[buyChance,sellChance],[buyChance,sellChance],...]
	[_items,_randomization] call NWG_ECOT_PricesLifetime_Simulation;
};

// call NWG_ECOT_PricesLifetime_Test_RandomWeighted
NWG_ECOT_PricesLifetime_Test_RandomWeighted = {
	private _items = ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","ChemicalDetector_01_watch_F","MineDetector","FirstAidKit","Medikit","ToolKit"];
	private _randomization = [[1,1],[1,2],[2,2],[2,1],[3,3],[3,3],[4,4],[2,4],[5,5],[5,3]];//[[buyChance,sellChance],[buyChance,sellChance],...]
	[_items,_randomization] call NWG_ECOT_PricesLifetime_Simulation;
};

NWG_ECOT_PricesLifetime_Simulation = {
	params ["_items","_randomization"];

	//Clear cache and prices
	NWG_ISHOP_SER_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
	NWG_ISHOP_SER_itemsPriceChart = [
		[[],[]],//LOOT_ITEM_CAT_CLTH [items,prices]
		[[],[]],//LOOT_ITEM_CAT_WEAP [items,prices]
		[[],[]],//LOOT_ITEM_CAT_ITEM [items,prices]
		[[],[]] //LOOT_ITEM_CAT_AMMO [items,prices]
	];

	//Prepare operations selection
	private _buySelection = [];
	private _sellSelection = [];
	private _item = "";
	{
		_x params ["_buyCount","_sellCount"];
		_item = _items#_forEachIndex;
		for "_i" from 1 to _buyCount do {
			_buySelection pushBack _item;
		};
		for "_i" from 1 to _sellCount do {
			_sellSelection pushBack _item;
		};
	} forEach _randomization;

	//Run simulation
	private _prices = [];
	private _reports = [];
	private _iToFixedLength = {
		// private _i = _this;
		// 0 => "0000", 1 => "0001", 10 => "0010", 100 => "0100", 1000 => "1000"
		private _s = str _this;
		private _l = count _s;
		private _r = "";
		for "_i" from 1 to (4 - _l) do {
			_r = _r + "0";
		};
		//return
		_r + _s
	};
	for "_i" from 0 to 9900 do {
		_prices = _items apply {round (_x call NWG_ISHOP_SER_EvaluateItem)};

		if ((_i mod 100) == 0) then {
			_reports pushBack (format ["Iteration %1. Prices: %2",(_i call _iToFixedLength),_prices]);
			_buySelection = _buySelection call NWG_fnc_arrayShuffle;
			_sellSelection = _sellSelection call NWG_fnc_arrayShuffle;
		};

		[LOOT_ITEM_CAT_ITEM,[(selectRandom _buySelection)], true ] call NWG_ISHOP_SER_UpdatePrices;
		[LOOT_ITEM_CAT_ITEM,[(selectRandom _sellSelection)],false] call NWG_ISHOP_SER_UpdatePrices;
	};

	_reports call NWG_fnc_testDumpToRptAndClipboard;
	"Simulation finished, check the report!"
};


//Random equal:
/*
Iteration 0000. Prices: [500,500,500,500,500,500,500,500,500,500]
Iteration 0100. Prices: [498,501,502,497,502,499,500,499,500,502]
Iteration 0200. Prices: [498,500,505,497,499,501,500,499,499,501]
...
Iteration 9700. Prices: [494,488,484,511,515,511,501,487,525,482]
Iteration 9800. Prices: [493,491,486,510,515,509,501,487,522,483]
Iteration 9900. Prices: [493,491,484,513,515,509,501,486,522,485]
*/

//Random weighted
/*
Iteration 0000. Prices: [500,500,500,500,500,500,500,500,500,500]
Iteration 0100. Prices: [501,500,502,502,498,497,499,496,501,505]
Iteration 0200. Prices: [501,497,500,504,499,498,496,491,503,511]
...
Iteration 9700. Prices: [487,355,488,697,523,500,512,300,497,698]
Iteration 9800. Prices: [488,355,490,699,521,499,512,300,497,697]
Iteration 9900. Prices: [487,353,491,700,525,500,510,300,496,699]
*/

//================================================================================================================
//================================================================================================================
//Mission profit syntetic test
NWG_ECOT_MissionProfit_Settings = createHashMapFromArray [
	["LOOT_CHANCE_VEH_CAR",0.85],//Hypothetical chance for players to loot vehicle instead of destroying it
	["LOOT_CHANCE_VEH_ARM",0.75],//Hypothetical chance for players to loot vehicle instead of destroying it
	["LOOT_CHANCE_VEH_AIR",0.10],//Hypothetical chance for players to loot vehicle instead of destroying it
	["LOOT_CHANCE_VEH_BOAT",0.25],//Hypothetical chance for players to loot vehicle instead of destroying it

	["LOOT_CHANCE_CONTAINER",1],//Hypothetical chance for players to find and loot container
	["LOOT_CHANCE_UNIT",1],//Hypothetical chance for players to loot unit

	["SELL_CHANCE_VEH_CAR",0.65],//Hypothetical chance for players to sell vehicle instead of destroying it
	["SELL_CHANCE_VEH_ARM",0.55],//Hypothetical chance for players to sell vehicle instead of destroying it
	["SELL_CHANCE_VEH_AIR",0.05],//Hypothetical chance for players to sell vehicle instead of destroying it
	["SELL_CHANCE_VEH_BOAT",0.05],//Hypothetical chance for players to sell vehicle instead of destroying it

	["",0]
];

// [] spawn NWG_ECOT_MissionProfit_Test
NWG_ECOT_MissionProfit_Test = {
	private _showMessage = {
		systemChat (format ["[%1] %2...",time,_this]);
		sleep 0.1;
	};

	//Wait for mission to be ready
	"Waiting for mission to be ready" call _showMessage;
	waitUntil {sleep 0.1; NWG_MIS_CurrentState == MSTATE_FIGHT_READY};
	"Mission ready" call _showMessage;

	//1. Drop player money
	"Dropping player money" call _showMessage;
	[player,0] call NWG_fnc_wltSetPlayerMoney;
	"Player money dropped" call _showMessage;

	//2. Fill vehicle shop to the brim with options (for manual check later)
	"Filling vehicle shop" call _showMessage;
	100 call NWG_fnc_vshopAddDynamicItems;
	"Vehicle shop filled" call _showMessage;

	//3. Collect mission objects and separate them into categories
	"Collecting mission objects" call _showMessage;
	private _containers = [];
	private _units = [];
	private _vehCars = [];
	private _vehArms = [];
	private _vehAirs = [];
	private _vehBoats = [];

	{
        switch (_x call NWG_fnc_ocGetObjectType) do {
			/*Decorations*/
            case OBJ_TYPE_DECO: {
				private _type = typeOf _x;
				switch (true) do {
					case (_type in (NWG_LM_SER_Settings get "CONT_LOOT_TYPES")): {_containers pushBack _x};
					case (_type in (NWG_LM_SER_Settings get "CONT_WEAP_TYPES")): {_containers pushBack _x};
					case (_type in (NWG_LM_SER_Settings get "CONT_RUG_TYPES")) : {_containers pushBack _x};
					case (_type in (NWG_LM_SER_Settings get "CONT_MED_TYPES")) : {_containers pushBack _x};
				};
            };

			/*Units*/
            case OBJ_TYPE_UNIT: {
				_units pushBack _x;
            };

			/*Vehicles*/
            case OBJ_TYPE_VEHC: {
				switch (true) do {
					case (_x isKindOf "Air"): {_vehAirs pushBack _x};
					case (_x isKindOf "Tank" || {_x isKindOf "Wheeled_APC_F"}) : {_vehArms pushBack _x};
					case (_x isKindOf "Ship"): {_vehBoats pushBack _x};
					default {_vehCars pushBack _x};
				};
            };
        };
    } forEach ((allMissionObjects "") select {!(_x in NWG_GC_originalObjects) && {!((typeOf _x) in NWG_GC_environmentExclude)}});
	"Mission objects collected" call _showMessage;

	//4. Mark all lootable objects on map
	"Marking lootable objects" call _showMessage;
	{
		[_x,(format ["LootObj_%1",_forEachIndex]),"ColorBlack"] call NWG_fnc_testPlaceMarker;
	} forEach (_containers + _vehCars + _vehArms + _vehAirs + _vehBoats);
	"Lootable objects marked" call _showMessage;

	//5. Wait for player signal to continue
	"Waiting for signal. Press 'Enter' to continue" call _showMessage;
	NWG_ECOT_MissionProfit_Test_Continue = false;
	(findDisplay 46) displayAddEventHandler ["KeyDown",{
		params ["_display","_keyCode","_shift","_ctrl","_alt"];
		//Wait for 'Enter' key
		if (_keyCode == 28) then {
			NWG_ECOT_MissionProfit_Test_Continue = true;
		};
		//Bypass keydown
		false
	}];
	waitUntil {sleep 0.1; NWG_ECOT_MissionProfit_Test_Continue};
	NWG_ECOT_MissionProfit_Test_Continue = false;
	"Signal received" call _showMessage;

	//6. Prepare selling the loot script
	private _sellLoot = {
		//Prepare transaction values
		private _loot = flatten (player call NWG_fnc_lsGetPlayerLoot);
		[player,LOOT_ITEM_DEFAULT_CHART] call NWG_fnc_lsSetPlayerLoot;
		private _allItems = _loot select {_x isEqualType ""};
		private _allPrices = _allItems apply {_x call NWG_ISHOP_SER_EvaluateItem};

		//Emulate shop transaction
		[_allItems,_allPrices] call NWG_ISHOP_CLI_TRA_OnOpen;
		private _count = 1;
		{
			if (_x isEqualType 1)
				then {_count = _x}
				else {[_x,_count,false] call NWG_ISHOP_CLI_TRA_TryAddToTransaction; _count = 1};
		} forEach _loot;
		call NWG_ISHOP_CLI_TRA_OnClose;
	};

	//7. Loot every container (+sell the loot)
	"Looting containers" call _showMessage;
	private _lootChance = NWG_ECOT_MissionProfit_Settings get "LOOT_CHANCE_CONTAINER";
	if (_lootChance < 1) then {
		_containers = _containers call NWG_fnc_arrayShuffle;
		_containers = _containers select {(random 1) <= _lootChance};
	};
	{
		_x call NWG_LS_CLI_LootContainer_Core;
	} forEach _containers;

	"Selling containers loot" call _showMessage;
	call _sellLoot;
	"Containers loot sold" call _showMessage;

	//8. Loot every vehicle
	"Looting vehicles" call _showMessage;
	private _lootVehicles = {
		params ["_vehicles","_lootChanceName"];
		_lootChance = NWG_ECOT_MissionProfit_Settings get _lootChanceName;
		private _toLoot= if (_lootChance < 1) then {
			_vehicles call NWG_fnc_arrayShuffle;
			_vehicles select {(random 1) <= _lootChance};
		} else {_vehicles};
		{
			_x call NWG_LS_CLI_LootContainer_Core;
		} forEach _toLoot;
	};

	[_vehCars,"LOOT_CHANCE_VEH_CAR"] call _lootVehicles;
	[_vehArms,"LOOT_CHANCE_VEH_ARM"] call _lootVehicles;
	[_vehAirs,"LOOT_CHANCE_VEH_AIR"] call _lootVehicles;
	[_vehBoats,"LOOT_CHANCE_VEH_BOAT"] call _lootVehicles;

	"Selling vehicles loot" call _showMessage;
	call _sellLoot;
	"Vehicles loot sold" call _showMessage;

	//9. Loot every enemy unit
	"Looting units" call _showMessage;
	NWG_LS_CLI_Settings set ["ALLOW_LOOTING_ALIVE_UNITS",true];//Allow looting of alive units
	_lootChance = NWG_ECOT_MissionProfit_Settings get "LOOT_CHANCE_UNIT";
	private _toLoot = if (_lootChance < 1) then {
		_units call NWG_fnc_arrayShuffle;
		_units select {(random 1) <= _lootChance};
	} else {_units};
	{
		_x call NWG_LS_CLI_LootContainer_Core;
		_x call NWG_LS_CLI_LootContainer_Core;//Loot their uniform too
	} forEach _toLoot;

	"Selling units loot" call _showMessage;
	call _sellLoot;
	"Units loot sold" call _showMessage;

	/*Loot selling result*/
	private _lootYield = player call NWG_fnc_wltGetPlayerMoney;

	//10. Sell vehicles
	"Selling vehicles" call _showMessage;
	private _sellPool = [];
	private _addToSellPool = {
		params ["_vehicles","_sellChanceName"];
		if ((count _vehicles) == 0) exitWith {};

		private _sellChance = NWG_ECOT_MissionProfit_Settings get _sellChanceName;
		private _toSell = if (_sellChance < 1) then {
			_vehicles call NWG_fnc_arrayShuffle;
			_vehicles select {(random 1) <= _sellChance};
		} else {_vehicles};
		if ((count _toSell) == 0) exitWith {};
		_sellPool append _toSell;
	};

	[_vehCars,"SELL_CHANCE_VEH_CAR"] call _addToSellPool;
	[_vehArms,"SELL_CHANCE_VEH_ARM"] call _addToSellPool;
	[_vehAirs,"SELL_CHANCE_VEH_AIR"] call _addToSellPool;
	[_vehBoats,"SELL_CHANCE_VEH_BOAT"] call _addToSellPool;

	if ((count _sellPool) > 0) then {
		/*Emulate shop transaction*/
		private _allItems = _sellPool apply {(typeOf _x) call NWG_fnc_vcatGetUnifiedClassname};
		private _allPrices = _allItems apply {_x call NWG_VSHOP_SER_EvaluateVeh};
		[_allItems,_allPrices] call NWG_VSHOP_CLI_TRA_OnOpen;
		{
			[_x,false] call NWG_VSHOP_CLI_TRA_TryAddToTransaction;
		} forEach _allItems;
		call NWG_VSHOP_CLI_TRA_OnClose;
	};
	{deleteVehicle _x} forEach _sellPool;
	"Sold vehicles" call _showMessage;

	/*Vehicle selling result*/
	private _sellYield = (player call NWG_fnc_wltGetPlayerMoney) - _lootYield;

	//11. Form report
	private _playerMoney = player call NWG_fnc_wltGetPlayerMoney;
	private _misDifficulty = call NWG_fnc_mmGetMissionDifficulty;
	private _report = [];

	/*Add header*/
	_report pushBack "===== [Mission Profit Test] =====";
	_report pushBack (format ["Mission difficulty: '%1'",_misDifficulty]);
	_report pushBack (format ["Player earned: '%1' (Loot sell: '%2' | Vehicles sell: '%3')",(_playerMoney toFixed 0),(_lootYield toFixed 0),(_sellYield toFixed 0)]);
	private _toFixedStringLength = {
		private _string = _this;
		for "_i" from 1 to (7 - (count _string)) do {
			_string = _string + " ";
		};
		_string
	};

	/*Add vehicles to report*/
	private _buyMultiplier = NWG_VSHOP_CLI_Settings get "PRICE_SELL_TO_PLAYER_MULTIPLIER";
	_report pushBack (format ["== Vehicles player can buy (Buy multiplier: '%1')",_buyMultiplier]);
	private _addToReportVeh = {
		params ["_type","_isArmed"];
		private _settingsSuffix = if (_isArmed) then {"ARMED"} else {"UNARMED"};
		private _reportSuffix = if (_isArmed)
			then {"ARMED  "}
			else {"UNARMED"};
		private _rawPrice = NWG_VSHOP_SER_Settings get (format ["DEFAULT_PRICE_%1_%2",_type,_settingsSuffix]);
		private _buyPrice = _rawPrice * _buyMultiplier;
		private _buyCount = _playerMoney / _buyPrice;

		_report pushBack (format [
			"[%1 %2] Raw price: '%3' | Price for player: '%4' | Can buy: %5",
			_type,
			_reportSuffix,
			((_rawPrice toFixed 0) call _toFixedStringLength),
			((_buyPrice toFixed 0) call _toFixedStringLength),
			(_buyCount toFixed 2)
		]);
	};

	{
		[_x,true] call _addToReportVeh;
		[_x,false] call _addToReportVeh;
	} forEach ["AAIR","APCS","ARTY","BOAT","CARS","DRON","HELI","PLAN","SUBM","TANK"];

	/*Add items to report*/
	_buyMultiplier = NWG_ISHOP_CLI_Settings get "PRICE_SELL_TO_PLAYER_MULTIPLIER";
	_report pushBack (format ["== Items player can buy (Buy multiplier: '%1')",_buyMultiplier]);
	private _addToReportItem = {
		private _type = _this;
		private _rawPrice = NWG_ISHOP_SER_Settings get (format ["DEFAULT_PRICE_%1",_type]);
		private _buyPrice = _rawPrice * _buyMultiplier;
		private _buyCount = _playerMoney / _buyPrice;
		_report pushBack (format [
			"[%1] Raw price: '%2' | Price for player: '%3' | Can buy: %4",
			_type,
			((_rawPrice toFixed 0) call _toFixedStringLength),
			((_buyPrice toFixed 0) call _toFixedStringLength),
			(_buyCount toFixed 2)
		]);
	};
	{
		_x call _addToReportItem;
	} forEach ["CLTH","WEAP","ITEM","AMMO"];

	/*Add footer*/
	_report pushBack "================================================";
	_report call NWG_fnc_testDumpToRptAndClipboard;
	"Report generated" call _showMessage;
};

/*
===== [Mission Profit Test] =====
Mission difficulty: 'EASY'
Player earned: '486780' (Loot sell: '480030' | Vehicles sell: '6750')
== Vehicles player can buy (Buy multiplier: '1.5')
[AAIR ARMED  ] Raw price: '200000 ' | Price for player: '300000 ' | Can buy: 1.62
[AAIR UNARMED] Raw price: '140000 ' | Price for player: '210000 ' | Can buy: 2.32
[APCS ARMED  ] Raw price: '125000 ' | Price for player: '187500 ' | Can buy: 2.60
[APCS UNARMED] Raw price: '85000  ' | Price for player: '127500 ' | Can buy: 3.82
[ARTY ARMED  ] Raw price: '200000 ' | Price for player: '300000 ' | Can buy: 1.62
[ARTY UNARMED] Raw price: '140000 ' | Price for player: '210000 ' | Can buy: 2.32
[BOAT ARMED  ] Raw price: '15000  ' | Price for player: '22500  ' | Can buy: 21.63
[BOAT UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 36.06
[CARS ARMED  ] Raw price: '15000  ' | Price for player: '22500  ' | Can buy: 21.63
[CARS UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 36.06
[DRON ARMED  ] Raw price: '27000  ' | Price for player: '40500  ' | Can buy: 12.02
[DRON UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 36.06
[HELI ARMED  ] Raw price: '250000 ' | Price for player: '375000 ' | Can buy: 1.30
[HELI UNARMED] Raw price: '50000  ' | Price for player: '75000  ' | Can buy: 6.49
[PLAN ARMED  ] Raw price: '300000 ' | Price for player: '450000 ' | Can buy: 1.08
[PLAN UNARMED] Raw price: '150000 ' | Price for player: '225000 ' | Can buy: 2.16
[SUBM ARMED  ] Raw price: '24000  ' | Price for player: '36000  ' | Can buy: 13.52
[SUBM UNARMED] Raw price: '12000  ' | Price for player: '18000  ' | Can buy: 27.04
[TANK ARMED  ] Raw price: '240000 ' | Price for player: '360000 ' | Can buy: 1.35
[TANK UNARMED] Raw price: '150000 ' | Price for player: '225000 ' | Can buy: 2.16
== Items player can buy (Buy multiplier: '1.5')
[CLTH] Raw price: '1000   ' | Price for player: '1500   ' | Can buy: 324.52
[WEAP] Raw price: '2000   ' | Price for player: '3000   ' | Can buy: 162.26
[ITEM] Raw price: '500    ' | Price for player: '750    ' | Can buy: 649.04
[AMMO] Raw price: '300    ' | Price for player: '450    ' | Can buy: 1081.73
================================================
*/

/*
===== [Mission Profit Test] =====
Mission difficulty: 'NORM'
Player earned: '851968' (Loot sell: '800218' | Vehicles sell: '51750')
== Vehicles player can buy (Buy multiplier: '1.5')
[AAIR ARMED  ] Raw price: '200000 ' | Price for player: '300000 ' | Can buy: 2.84
[AAIR UNARMED] Raw price: '140000 ' | Price for player: '210000 ' | Can buy: 4.06
[APCS ARMED  ] Raw price: '125000 ' | Price for player: '187500 ' | Can buy: 4.54
[APCS UNARMED] Raw price: '85000  ' | Price for player: '127500 ' | Can buy: 6.68
[ARTY ARMED  ] Raw price: '200000 ' | Price for player: '300000 ' | Can buy: 2.84
[ARTY UNARMED] Raw price: '140000 ' | Price for player: '210000 ' | Can buy: 4.06
[BOAT ARMED  ] Raw price: '15000  ' | Price for player: '22500  ' | Can buy: 37.87
[BOAT UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 63.11
[CARS ARMED  ] Raw price: '15000  ' | Price for player: '22500  ' | Can buy: 37.87
[CARS UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 63.11
[DRON ARMED  ] Raw price: '27000  ' | Price for player: '40500  ' | Can buy: 21.04
[DRON UNARMED] Raw price: '9000   ' | Price for player: '13500  ' | Can buy: 63.11
[HELI ARMED  ] Raw price: '250000 ' | Price for player: '375000 ' | Can buy: 2.27
[HELI UNARMED] Raw price: '50000  ' | Price for player: '75000  ' | Can buy: 11.36
[PLAN ARMED  ] Raw price: '300000 ' | Price for player: '450000 ' | Can buy: 1.89
[PLAN UNARMED] Raw price: '150000 ' | Price for player: '225000 ' | Can buy: 3.79
[SUBM ARMED  ] Raw price: '24000  ' | Price for player: '36000  ' | Can buy: 23.67
[SUBM UNARMED] Raw price: '12000  ' | Price for player: '18000  ' | Can buy: 47.33
[TANK ARMED  ] Raw price: '240000 ' | Price for player: '360000 ' | Can buy: 2.37
[TANK UNARMED] Raw price: '150000 ' | Price for player: '225000 ' | Can buy: 3.79
== Items player can buy (Buy multiplier: '1.5')
[CLTH] Raw price: '1000   ' | Price for player: '1500   ' | Can buy: 567.98
[WEAP] Raw price: '2000   ' | Price for player: '3000   ' | Can buy: 283.99
[ITEM] Raw price: '500    ' | Price for player: '750    ' | Can buy: 1135.96
[AMMO] Raw price: '300    ' | Price for player: '450    ' | Can buy: 1893.26
================================================
*/