#include "..\..\globalDefines.h"

// call NWG_LS_CLI_LootByAction_Test
NWG_LS_CLI_LootByAction_Test = {
	private _target = cursorTarget;
	if (isNull _target) exitWith {"No target selected"};

	_target spawn {
		private _target = _this;
		sleep 1;

		[player,LOOT_ITEM_DEFAULT_CHART] call NWG_fnc_lsSetPlayerLoot;//Clear player loot
		_target call NWG_LS_CLI_LootByAction;//Loot target
		with missionNamespace do {
			call NWG_LS_CLI_OpenMyStorage;//Open storage to see loot
		};
	};
};

// call NWG_LS_CLI_GetBasicBackpack_Test_EqualWithBisFunc
NWG_LS_CLI_GetBasicBackpack_Test_EqualWithBisFunc = {
    private _testCases = [
		"bag_base",
		"b_assaultpack_base",
		"b_assaultpack_khk",
		"b_assaultpack_dgtl",
		"b_assaultpack_rgr",
		"b_assaultpack_sgg",
		"b_assaultpack_blk",
		"b_assaultpack_cbr",
		"b_assaultpack_mcamo",
		"b_assaultpack_ocamo",
		"b_kitbag_base",
		"b_kitbag_rgr",
		"b_kitbag_mcamo",
		"b_kitbag_sgg",
		"b_kitbag_cbr",
		"b_tacticalpack_base",
		"b_tacticalpack_rgr",
		"b_tacticalpack_mcamo",
		"b_tacticalpack_ocamo",
		"b_tacticalpack_blk",
		"b_tacticalpack_oli",
		"b_fieldpack_base",
		"b_fieldpack_khk",
		"b_fieldpack_ocamo",
		"b_fieldpack_oucamo",
		"b_fieldpack_cbr",
		"b_fieldpack_blk",
		"b_carryall_base",
		"b_carryall_ocamo",
		"b_carryall_oucamo",
		"b_carryall_mcamo",
		"b_carryall_khk",
		"b_carryall_cbr",
		"b_bergen_base",
		"b_bergen_sgg",
		"b_bergen_mcamo",
		"b_bergen_rgr",
		"b_bergen_blk",
		"b_outdoorpack_base",
		"b_outdoorpack_blk",
		"b_outdoorpack_tan",
		"b_outdoorpack_blu",
		"b_huntingbackpack",
		"b_assaultpackg",
		"b_bergeng",
		"b_bergenc_base",
		"b_bergenc_red",
		"b_bergenc_grn",
		"b_bergenc_blu",
		"b_parachute",
		"b_assaultpack_rgr_lat",
		"b_assaultpack_rgr_medic",
		"b_assaultpack_rgr_repair",
		"b_assault_diver",
		"b_assaultpack_blk_diverexp",
		"b_kitbag_rgr_exp",
		"b_fieldpack_blk_diverexp",
		"o_assault_diver",
		"b_fieldpack_ocamo_medic",
		"b_fieldpack_cbr_lat",
		"b_fieldpack_cbr_repair",
		"b_carryall_ocamo_exp",
		"b_fieldpack_oli",
		"b_carryall_oli",
		"g_assaultpack",
		"g_bergen",
		"c_bergen_base",
		"c_bergen_red",
		"c_bergen_grn",
		"c_bergen_blu",
		"b_assaultpack_mcamo_at",
		"b_assaultpack_rgr_reconmedic",
		"b_assaultpack_rgr_reconexp",
		"b_assaultpack_rgr_reconlat",
		"b_assaultpack_mcamo_aa",
		"b_assaultpack_mcamo_aar",
		"b_assaultpack_mcamo_ammo",
		"b_kitbag_mcamo_eng",
		"b_carryall_mcamo_aaa",
		"b_carryall_mcamo_aat",
		"b_fieldpack_ocamo_aa",
		"b_fieldpack_ocamo_aar",
		"b_fieldpack_ocamo_reconmedic",
		"b_fieldpack_cbr_at",
		"b_fieldpack_cbr_aat",
		"b_fieldpack_cbr_aa",
		"b_fieldpack_cbr_aaa",
		"b_fieldpack_cbr_medic",
		"b_fieldpack_ocamo_reconexp",
		"b_fieldpack_cbr_ammo",
		"b_fieldpack_cbr_rpg_at",
		"b_carryall_ocamo_aaa",
		"b_carryall_ocamo_eng",
		"b_carryall_cbr_aat",
		"b_fieldpack_oucamo_at",
		"b_fieldpack_oucamo_lat",
		"b_carryall_oucamo_aat",
		"b_fieldpack_oucamo_aa",
		"b_carryall_oucamo_aaa",
		"b_fieldpack_oucamo_aar",
		"b_fieldpack_oucamo_medic",
		"b_fieldpack_oucamo_ammo",
		"b_fieldpack_oucamo_repair",
		"b_carryall_oucamo_exp",
		"b_carryall_oucamo_eng",
		"i_fieldpack_oli_aa",
		"i_assault_diver",
		"i_fieldpack_oli_ammo",
		"i_fieldpack_oli_medic",
		"i_fieldpack_oli_repair",
		"i_fieldpack_oli_lat",
		"i_fieldpack_oli_at",
		"i_fieldpack_oli_aar",
		"i_carryall_oli_aat",
		"i_carryall_oli_exp",
		"i_carryall_oli_aaa",
		"i_carryall_oli_eng",
		"g_tacticalpack_eng",
		"g_fieldpack_medic",
		"g_fieldpack_lat",
		"g_carryall_ammo",
		"g_carryall_exp",
		"b_bergeng_test_b_soldier_overloaded",
		"weapon_bag_base",
		"b_respawn_tentdome_f",
		"b_respawn_tenta_f",
		"b_respawn_sleeping_bag_f",
		"b_respawn_sleeping_bag_blue_f",
		"b_respawn_sleeping_bag_brown_f",
		"b_uav_01_backpack_f",
		"o_uav_01_backpack_f",
		"i_uav_01_backpack_f",
		"b_mortar_01_support_f",
		"o_mortar_01_support_f",
		"i_mortar_01_support_f",
		"b_mortar_01_weapon_f",
		"o_mortar_01_weapon_f",
		"i_mortar_01_weapon_f",
		"b_hmg_01_support_f",
		"o_hmg_01_support_f",
		"i_hmg_01_support_f",
		"b_hmg_01_support_high_f",
		"o_hmg_01_support_high_f",
		"i_hmg_01_support_high_f",
		"b_hmg_01_weapon_f",
		"o_hmg_01_weapon_f",
		"i_hmg_01_weapon_f",
		"b_hmg_01_a_weapon_f",
		"b_gmg_01_weapon_f",
		"o_gmg_01_weapon_f",
		"i_gmg_01_weapon_f",
		"b_gmg_01_a_weapon_f",
		"b_hmg_01_high_weapon_f",
		"o_hmg_01_high_weapon_f",
		"i_hmg_01_high_weapon_f",
		"b_hmg_01_a_high_weapon_f",
		"b_gmg_01_high_weapon_f",
		"o_gmg_01_high_weapon_f",
		"i_gmg_01_high_weapon_f",
		"b_gmg_01_a_high_weapon_f",
		"b_aa_01_weapon_f",
		"o_aa_01_weapon_f",
		"i_aa_01_weapon_f",
		"b_at_01_weapon_f",
		"o_at_01_weapon_f",
		"i_at_01_weapon_f",
		"b_assaultpack_kerry",
		"b_b_parachute_02_f",
		"b_o_parachute_02_f",
		"b_i_parachute_02_f"
	];

    private _failed = [];
    private ["_customResult","_bisfncResult"];
    //forEach testCase
    {
        _customResult = _x call NWG_fnc_icatGetBaseBackpack;
        _bisfncResult = _x call BIS_fnc_basicBackpack;

        if (_customResult isNotEqualTo _bisfncResult)
            then {_failed pushBack _x};

    } forEach _testCases;

    {
        (format["%1 failed",_x]) call NWG_fnc_logError;
    } forEach _failed;

    //return to console
    if (count _failed == 0)
        then {"All tests passed successfully"}
        else {"Some tests failed, see log for details"}
};