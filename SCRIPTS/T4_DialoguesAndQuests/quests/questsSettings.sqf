#include "..\..\globalDefines.h"

NWG_QST_Settings = createHashMapFromArray [
	/*Quest Settings*/
	["QUEST_ENABLED",[
		// QST_TYPE_VEH_STEAL,
		// QST_TYPE_INTERROGATE,
		QST_TYPE_HACK_DATA
		// QST_TYPE_DESTROY,
		// QST_TYPE_INTEL,
		// QST_TYPE_INFECTION,
		// QST_TYPE_WOUNDED,
		// QST_TYPE_MED_SUPPLY,
		// QST_TYPE_WEAPON,
		// QST_TYPE_ELECTRONICS,
	]],
	["QUEST_GIVERS",[
		/*QST_TYPE_VEH_STEAL:*/ NPC_MECH,
		/*QST_TYPE_INTERROGATE:*/ NPC_COMM,
		/*QST_TYPE_HACK_DATA:*/ NPC_COMM,
		/*QST_TYPE_DESTROY:*/ NPC_COMM,
		/*QST_TYPE_INTEL:*/ NPC_COMM,
		/*QST_TYPE_INFECTION:*/ NPC_MECH,
		/*QST_TYPE_WOUNDED:*/ NPC_MECH,
		/*QST_TYPE_MED_SUPPLY:*/ NPC_MECH,
		/*QST_TYPE_WEAPON:*/ NPC_ROOF,
		/*QST_TYPE_ELECTRONICS:*/ NPC_ROOF
	]],
	["QUEST_DICE_WEIGHTS",[
		/*QST_TYPE_VEH_STEAL:*/ 1,
		/*QST_TYPE_INTERROGATE:*/ 1,
		/*QST_TYPE_HACK_DATA:*/ 1,
		/*QST_TYPE_DESTROY:*/ 1,
		/*QST_TYPE_INTEL:*/ 1,
		/*QST_TYPE_INFECTION:*/ 2,
		/*QST_TYPE_WOUNDED:*/ 1,
		/*QST_TYPE_MED_SUPPLY:*/ 1,
		/*QST_TYPE_WEAPON:*/ 1,
		/*QST_TYPE_ELECTRONICS:*/ 1
	]],
	["QUEST_REWARDS",[
		/*QST_TYPE_VEH_STEAL:*/ {
			params ["_targetClassname","_multiplier"];
			private _price = _targetClassname call NWG_fnc_vshopEvaluateVehPrice;
			private _reward = _price + (_price * (_multiplier * 0.05));//Apply 5% of multiplier
			_reward = (round (_reward / 100)) * 100;//Round to nearest 100
			_reward
		},
		/*QST_TYPE_INTERROGATE:*/ 1000,
		/*QST_TYPE_HACK_DATA:*/ 1000,
		/*QST_TYPE_DESTROY:*/ 1000,
		/*QST_TYPE_INTEL:*/ "TODO",
		/*QST_TYPE_INFECTION:*/ 1000,
		/*QST_TYPE_WOUNDED:*/ 1000,
		/*QST_TYPE_MED_SUPPLY:*/ "TODO",
		/*QST_TYPE_WEAPON:*/ {0/*TODO*/},
		/*QST_TYPE_ELECTRONICS:*/ "TODO"
	]],
	["QUEST_DEFAULT_REWARD",1000],

	/*External functions*/
	["FUNC_GET_REWARD_MULTIPLIER",{(call NWG_fnc_mmGetMissionLevel) + 1}],//Applies only to number or code type rewards
	["FUNC_REWARD_PLAYER",{
		params ["_player","_reward"];
		[_player,P__EXP,1] call NWG_fnc_pAddPlayerProgress;//Add experience
		[_player,P_TEXP,1] call NWG_fnc_pAddPlayerProgress;//Add total experience (level up)
		[_player,_reward] call NWG_fnc_wltAddPlayerMoney;//Add money reward
	}],

	/*Marker Settings*/
	["MARKER_TYPE","mil_warning"],
	["MARKER_COLOR","ColorBlack"],
	["MARKER_SIZE",0.75],

	/*Localization*/
	["LOC_QUEST_DONE",[
		/*QST_TYPE_VEH_STEAL:*/ false,
		/*QST_TYPE_INTERROGATE:*/ "#QST_INTERROGATE_DONE#",
		/*QST_TYPE_HACK_DATA:*/ false,
		/*QST_TYPE_DESTROY:*/ "#QST_DESTROY_DONE#",
		/*QST_TYPE_INTEL:*/ false,
		/*QST_TYPE_INFECTION:*/ false,
		/*QST_TYPE_WOUNDED:*/ false,
		/*QST_TYPE_MED_SUPPLY:*/ false,
		/*QST_TYPE_WEAPON:*/ false,
		/*QST_TYPE_ELECTRONICS:*/ false
	]],
	["LOC_QUEST_CLOSED",[
		/*QST_TYPE_VEH_STEAL:*/ "#QST_VEH_STEAL_CLOSED#",
		/*QST_TYPE_INTERROGATE:*/ "#QST_INTERROGATE_CLOSED#",
		/*QST_TYPE_HACK_DATA:*/ false,
		/*QST_TYPE_DESTROY:*/ "#QST_DESTROY_CLOSED#",
		/*QST_TYPE_INTEL:*/ false,
		/*QST_TYPE_INFECTION:*/ false,
		/*QST_TYPE_WOUNDED:*/ false,
		/*QST_TYPE_MED_SUPPLY:*/ false,
		/*QST_TYPE_WEAPON:*/ false,
		/*QST_TYPE_ELECTRONICS:*/ false
	]],
	["LOC_UNKONW_WINNER","#QST_UNKONW_WINNER#"],

	/*Interrogate quest*/
	["INTERROGATE_TARGETS",[
		"B_Competitor_F",
		"B_officer_F",
		"B_Officer_Parade_F",
		"B_Officer_Parade_Veteran_F",
		"B_RangeMaster_F",
		"B_recon_TL_F",
		"B_Captain_Pettka_F",
		"I_G_Story_SF_Captain_F",
		"B_G_officer_F",
		"B_CTRG_Miller_F",
		"O_officer_F",
		"O_Officer_Parade_F",
		"O_Officer_Parade_Veteran_F",
		"O_T_Officer_F",
		"I_officer_F",
		"I_Officer_Parade_F",
		"I_Officer_Parade_Veteran_F",
		"I_Story_Colonel_F",
		"I_Story_Officer_01_F",
		"I_Captain_Hladas_F",
		"I_E_Officer_F",
		"I_E_Officer_Parade_F",
		"I_E_Officer_Parade_Veteran_F",
		"C_Nikos",
		"C_IDAP_Man_AidWorker_08_F",
		"C_man_hunter_1_F"
	]],
	["INTERROGATE_BREAK_LIMIT",10],//Max number of hits to break the target
	["INTERROGATE_TITLE","#QST_INTERROGATE_TITLE#"],
	["INTERROGATE_ICON","a3\ui_f\data\igui\cfg\actions\talk_ca.paa"],

	/*Hack data quest*/
	["HACK_DATA_TARGETS",[
		"Land_Laptop_device_F",
		"Land_Laptop_unfolded_F",
		"Land_Laptop_Intel_01_F",
		"Land_Laptop_Intel_02_F",
		"Land_Laptop_Intel_Oldman_F",
		"Land_PCSet_01_screen_F",
		"Land_PCSet_Intel_01_F",
		"Land_PCSet_Intel_02_F",
		"Land_MultiScreenComputer_01_black_F",
		"Land_MultiScreenComputer_01_olive_F",
		"Land_MultiScreenComputer_01_sand_F",
		"Land_Laptop_03_black_F",
		"Land_Laptop_03_olive_F",
		"Land_Laptop_03_sand_F"
	]],
	["HACK_DATA_TITLE","#QST_HACK_DATA_TITLE#"],
	["HACK_DATA_ICON","a3\ui_f\data\igui\cfg\holdactions\holdaction_hack_ca.paa"],

	/*Destroy object quest*/
	["DESTROY_TARGETS",[
		"Land_Cargo_HQ_V1_F",
		"Land_Cargo_HQ_V2_F",
		"Land_Cargo_HQ_V3_F",
		"Land_Medevac_HQ_V1_F",
		"Land_Research_HQ_F",
		"Land_Cargo_Tower_V1_No1_F",
		"Land_Cargo_Tower_V1_No2_F",
		"Land_Cargo_Tower_V1_No3_F",
		"Land_Cargo_Tower_V1_No4_F",
		"Land_Cargo_Tower_V1_No5_F",
		"Land_Cargo_Tower_V1_No6_F",
		"Land_Cargo_Tower_V1_No7_F",
		"Land_Cargo_Tower_V1_F",
		"Land_Cargo_Tower_V2_F",
		"Land_Cargo_Tower_V3_F",
		"Land_Cargo_Tower_V4_F",
		"Land_TTowerBig_1_F",
		"Land_TTowerBig_2_F"
	]],

	/*Localization*/
	["LOC_NPC_TO_MARKER_TEXT",createHashMapFromArray [
		[NPC_TAXI,"#NPC_TAXI_NAME#"],
		[NPC_MECH,"#NPC_MECH_NAME#"],
		[NPC_TRDR,"#NPC_TRDR_NAME#"],
		[NPC_MEDC,"#NPC_MEDC_NAME#"],
		[NPC_COMM,"#NPC_COMM_NAME#"],
		[NPC_ROOF,"#NPC_ROOF_NAME#"]
	]],
	["INTERROGATE_FAILED",["#QST_INTERROGATE_FAILED_01#","#QST_INTERROGATE_FAILED_02#","#QST_INTERROGATE_FAILED_03#"]],
	["INTERROGATE_DONE",["#QST_INTERROGATE_DONE_01#","#QST_INTERROGATE_DONE_02#","#QST_INTERROGATE_DONE_03#"]],
	["INTERROGATE_SUCCESS",["#QST_INTERROGATE_SUCCESS_01#","#QST_INTERROGATE_SUCCESS_02#","#QST_INTERROGATE_SUCCESS_03#"]],

	/*External functions*/
	["FUNC_GET_PLAYER_VEHICLES",{_this call NWG_fnc_vownGetOwnedVehicles}],
	["FUNC_DELETE_VEHICLE",{_this call NWG_fnc_vshopDeleteVehicle}],

	["",0]
];