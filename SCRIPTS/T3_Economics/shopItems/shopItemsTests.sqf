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

//================================================================================================================
//================================================================================================================
//Items chart validation
// call NWG_ISHOP_SER_ValidateItemsChart_Test
NWG_ISHOP_SER_ValidateItemsChart_Test = {
	private _testCases = [
		["Empty chart",    LOOT_ITEM_DEFAULT_CHART,	LOOT_ITEM_DEFAULT_CHART,true],
		["Invalid chart 1",[[],[],[],1],	LOOT_ITEM_DEFAULT_CHART,false],
		["Invalid chart 2",[[],[],[]],		LOOT_ITEM_DEFAULT_CHART,false],
		["Invalid chart 3",[[],[],[],[],[]],LOOT_ITEM_DEFAULT_CHART,false],
		["Persistent items",(NWG_ISHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS"),(NWG_ISHOP_SER_Settings get "SHOP_PERSISTENT_ITEMS"),true],
		["Incorrect items",
			[
				["B_AssaultPack_mcamo_AT"],
				["arifle_MXC_Holo_pointer_F",2,"arifle_MXC_F",2,"FirstAidKit"],
				[5,"ItemRadio",3,"ItemCompass"],
				[10,"30Rnd_65x39_caseless_mag",10,"30Rnd_762x39_Mag_F",10,"30Rnd_545x39_Mag_F"]
			],
			[
				[],
				[2,"arifle_MXC_F"],
				[5,"ItemRadio",3,"ItemCompass"],
				[10,"30Rnd_65x39_caseless_mag",10,"30Rnd_762x39_Mag_F",10,"30Rnd_545x39_Mag_F"]
			],
			false
		]
	];

	private _errors = [];
	{
		_x params ["_name","_items","_expectedChart","_expectedValid"];
		(_items call NWG_ISHOP_SER_ValidateItemsChart) params ["_actualChart","_actualValid"];
		if (_actualChart isNotEqualTo _expectedChart || {_actualValid isNotEqualTo _expectedValid}) then {
			_errors pushBack (format ["TestCase:'%1'. Expected: %2 %3. Actual: %4 %5",_name,_expectedChart,_expectedValid,_actualChart,_actualValid]);
		};
	} forEach _testCases;

	if (_errors isNotEqualTo []) then {
		_errors call NWG_fnc_testDumpToRptAndClipboard;
		"Some tests failed, check the report!"
	} else {
		"All tests passed"
	};
};

//================================================================================================================
//================================================================================================================
//Validate loot mission catalogue (yes, it's from another module, but validation is done here)
// call NWG_ISHOP_SER_ValidateLootMissionCatalogue_Test
NWG_ISHOP_SER_ValidateLootMissionCatalogue_Test = {
	private _filePath = "DATASETS\Server\LootMission\_Vanilla.sqf";
	private _catalogue = call (_filePath call NWG_fnc_compile);
	if (isNil "_catalogue" || {!(_catalogue isEqualType [])}) exitWith {"Failed to load catalogue"};

	private _errors = [];
	{
		if !(_x isEqualTypeArray [[],0,[]]) then {
			_errors pushBack (format ["Invalid catalogue format. Expected: [[],0,[]]. Actual: %1",_x]);
			continue;
		};

		_x params ["_tags","_tier","_items"];
		(_items call NWG_ISHOP_SER_ValidateItemsChart) params ["","_isValid"];
		if (!_isValid) then {
			_errors pushBack (format ["Invalid items chart found. Tags to find it: '%1'",_tags]);
		};
	} forEach _catalogue;

	if (_errors isNotEqualTo []) then {
		_errors call NWG_fnc_testDumpToRptAndClipboard;
		"Some tests failed, check the report!"
	} else {
		"All tests passed"
	};
};
