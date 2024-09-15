#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Prices

// call NWG_ISHOP_EvaluateItems_Test
NWG_ISHOP_EvaluateItems_Test = {
	private _dC = NWG_ISHOP_Settings get "DEFAULT_PRICE_CLTH";
	private _dI = NWG_ISHOP_Settings get "DEFAULT_PRICE_ITEM";
	private _dA = NWG_ISHOP_Settings get "DEFAULT_PRICE_AMMO";
	private _dW = NWG_ISHOP_Settings get "DEFAULT_PRICE_WEAP";

	private _testCases = [
		["Random batch new   ",["B_AssaultPack_blk","G_Aviator","130Rnd_338_Mag","hgun_P07_F"],[_dC,_dI,_dA,_dW]],
		["Random batch cached",["B_AssaultPack_blk","G_Aviator","130Rnd_338_Mag","hgun_P07_F"],[_dC,_dI,_dA,_dW]],
		["Clothes batch      ",["U_B_T_Soldier_F","U_O_R_Gorka_01_F","V_TacVest_khk","H_Watchcap_cbr"],[_dC,_dC,_dC,_dC]],
		["Items batch        ",["ItemMap","O_UavTerminal","NVGogglesB_gry_F","G_Lady_Blue"],[_dI,_dI,_dI,_dI]],
		["Ammo batch         ",["7Rnd_408_Mag","FlareGreen_F","Vorona_HE","HandGrenade"],[_dA,_dA,_dA,_dA]],
		["Weapons batch      ",["arifle_CTARS_blk_F","srifle_DMR_01_F","launch_MRAWS_olive_F","hgun_ACPC2_F"],[_dW,_dW,_dW,_dW]],
		["Invalid items      ",["ItemInvalid","asdasd","TrustMeBro","G_LadyBoy_Blue"],[0,0,0,0]]
	];

	private _errors = [];
	{
		_x params ["_name","_items","_expectedPrices"];
		private _actualPrices = _items apply {_x call NWG_ISHOP_EvaluateItem};
		if (_actualPrices isNotEqualTo _expectedPrices) then {
			_errors pushBack (format ["TestCase:'%1'. Expected: %2. Actual: %3",_name,_expectedPrices,_actualPrices]);
		};
	} forEach _testCases;

	if (_errors isNotEqualTo []) then {
		_errors call NWG_fnc_testDumpToRptAndClipboard;
		"Some tests failed, check the report!"
	} else {
		"All tests passed"
	}
};

//** BIG ECONOMY TEST **//

NWG_ISHOP_PricesLifetime_Test_RandomEqual = {
	private _items = ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","ChemicalDetector_01_watch_F","MineDetector","FirstAidKit","Medikit","ToolKit"];
	private _randomization = [[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1],[1,1]];//[[buyChance,sellChance],[buyChance,sellChance],...]
	[_items,_randomization] call NWG_ISHOP_PricesLifetime_Simulation;
};

NWG_ISHOP_PricesLifetime_Test_RandomWeighted = {
	private _items = ["ItemMap","ItemGPS","ItemRadio","ItemCompass","ItemWatch","ChemicalDetector_01_watch_F","MineDetector","FirstAidKit","Medikit","ToolKit"];
	private _randomization = [[1,1],[1,2],[2,2],[2,1],[3,3],[3,3],[4,4],[2,4],[5,5],[5,3]];//[[buyChance,sellChance],[buyChance,sellChance],...]
	[_items,_randomization] call NWG_ISHOP_PricesLifetime_Simulation;
};

NWG_ISHOP_PricesLifetime_Simulation = {
	params ["_items","_randomization"];

	//Clear cache and prices
	NWG_ISHOP_itemsInfoCache = createHashMap;//[_categoryIndex,_itemIndex]
	NWG_ISHOP_itemsPriceChart = [
		[[],[]],//CAT_CLTH [items,prices]
		[[],[]],//CAT_WEAP [items,prices]
		[[],[]],//CAT_ITEM [items,prices]
		[[],[]] //CAT_AMMO [items,prices]
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
		_prices = [_items,LOOT_ITEM_TYPE_ITEM] call NWG_ISHOP_EvaluateItems;

		if ((_i mod 100) == 0) then {
			_reports pushBack (format ["Iteration %1. Prices: %2",(_i call _iToFixedLength),_prices]);
			_buySelection = _buySelection call NWG_fnc_arrayShuffle;
			_sellSelection = _sellSelection call NWG_fnc_arrayShuffle;
		};

		[(selectRandom _buySelection),1,true] call NWG_ISHOP_UpdatePrices;
		[(selectRandom _sellSelection),1,false] call NWG_ISHOP_UpdatePrices;
	};

	_reports call NWG_fnc_testDumpToRptAndClipboard;
	"Simulation finished, check the report!"
};


//Random equal:
/*
"Iteration 0000. Prices: [500,500,500,500,500,500,500,500,500,500]"
"Iteration 0100. Prices: [501,500,500,499,499,498,501,504,498,498]"
"Iteration 0200. Prices: [501,501,506,499,498,500,496,509,495,496]"
"Iteration 0300. Prices: [503,500,506,500,498,499,494,509,497,494]"
"Iteration 0400. Prices: [504,500,501,500,501,501,494,508,499,492]"
...
"Iteration 9600. Prices: [505,514,498,506,508,479,496,495,514,483]"
"Iteration 9700. Prices: [506,512,496,503,509,479,497,497,515,485]"
"Iteration 9800. Prices: [502,514,496,503,509,481,496,496,516,484]"
"Iteration 9900. Prices: [503,513,498,502,508,481,494,496,521,482]"
*/

//Random weighted
/*
"Iteration 0000. Prices: [500,500,500,500,500,500,500,500,500,500]"
"Iteration 0100. Prices: [501,498,499,503,501,504,498,502,495,499]"
"Iteration 0200. Prices: [502,497,500,507,502,507,495,497,497,497]"
"Iteration 0300. Prices: [500,496,501,509,501,505,497,493,496,503]"
...
"Iteration 9600. Prices: [495,357,504,699,510,496,501,301,499,700]"
"Iteration 9700. Prices: [498,356,504,700,511,493,498,300,500,700]"
"Iteration 9800. Prices: [500,356,502,700,505,494,501,300,502,700]"
"Iteration 9900. Prices: [499,355,502,699,509,493,501,300,500,700]"
*/