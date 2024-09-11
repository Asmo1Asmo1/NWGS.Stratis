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
		["Random batch new   ",["B_AssaultPack_blk","G_Aviator","130Rnd_338_Mag","hgun_P07_F"],"",[_dC,_dI,_dA,_dW]],
		["Random batch cached",["B_AssaultPack_blk","G_Aviator","130Rnd_338_Mag","hgun_P07_F"],"",[_dC,_dI,_dA,_dW]],
		["Clothes batch      ",["U_B_T_Soldier_F","U_O_R_Gorka_01_F","V_TacVest_khk","H_Watchcap_cbr"],LOOT_ITEM_TYPE_CLTH,[_dC,_dC,_dC,_dC]],
		["Items batch        ",["ItemMap","O_UavTerminal","NVGogglesB_gry_F","G_Lady_Blue"],LOOT_ITEM_TYPE_ITEM,[_dI,_dI,_dI,_dI]],
		["Ammo batch         ",["7Rnd_408_Mag","FlareGreen_F","Vorona_HE","HandGrenade"],LOOT_ITEM_TYPE_AMMO,[_dA,_dA,_dA,_dA]],
		["Weapons batch      ",["arifle_CTARS_blk_F","srifle_DMR_01_F","launch_MRAWS_olive_F","hgun_ACPC2_F"],LOOT_ITEM_TYPE_WEAP,[_dW,_dW,_dW,_dW]],
		["Invalid category   ",["launch_RPG7_F","SMG_03C_hex","V_EOD_olive_F","acc_flashlight"],"Invalid",[0,0,0,0]],
		["Invalid items      ",["ItemInvalid","asdasd","TrustMeBro","G_LadyBoy_Blue"],"",[0,0,0,0]]
	];

	private _errors = [];
	{
		_x params ["_name","_items","_knownCatg","_expectedPrices"];
		private _actualPrices = [_items,_knownCatg] call NWG_ISHOP_EvaluateItems;
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