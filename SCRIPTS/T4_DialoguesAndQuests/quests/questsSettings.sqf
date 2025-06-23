#include "..\..\globalDefines.h"

NWG_QST_Settings = createHashMapFromArray [
	/*Quest Settings*/
	["QUEST_ENABLED",[
		QST_TYPE_VEH_STEAL,
		QST_TYPE_INTERROGATE,
		QST_TYPE_HACK_DATA,
		QST_TYPE_DESTROY,
		QST_TYPE_INTEL,
		QST_TYPE_INFECTION,
		QST_TYPE_WOUNDED,
		QST_TYPE_MED_SUPPLY,
		QST_TYPE_WEAPON,
		QST_TYPE_ELECTRONICS,
		QST_TYPE_BURNDOWN,
		QST_TYPE_TOOLS
	]],
	["QUEST_GIVERS",[
		/*QST_TYPE_VEH_STEAL:*/ NPC_MECH,
		/*QST_TYPE_INTERROGATE:*/ NPC_COMM,
		/*QST_TYPE_HACK_DATA:*/ NPC_COMM,
		/*QST_TYPE_DESTROY:*/ NPC_COMM,
		/*QST_TYPE_INTEL:*/ NPC_COMM,
		/*QST_TYPE_INFECTION:*/ NPC_MEDC,
		/*QST_TYPE_WOUNDED:*/ NPC_MEDC,
		/*QST_TYPE_MED_SUPPLY:*/ NPC_MEDC,
		/*QST_TYPE_WEAPON:*/ NPC_ROOF,
		/*QST_TYPE_ELECTRONICS:*/ NPC_TRDR,
		/*QST_TYPE_BURNDOWN:*/ NPC_TRDR,
		/*QST_TYPE_TOOLS:*/ NPC_MECH
	]],
	["QUEST_DICE_WEIGHTS",[
		/*QST_TYPE_VEH_STEAL:*/   3,
		/*QST_TYPE_INTERROGATE:*/ 3,
		/*QST_TYPE_HACK_DATA:*/   3,
		/*QST_TYPE_DESTROY:*/     3,
		/*QST_TYPE_INTEL:*/       3,
		/*QST_TYPE_INFECTION:*/   5,
		/*QST_TYPE_WOUNDED:*/     2,
		/*QST_TYPE_MED_SUPPLY:*/  3,
		/*QST_TYPE_WEAPON:*/      3,
		/*QST_TYPE_ELECTRONICS:*/ 3,
		/*QST_TYPE_BURNDOWN:*/    3,
		/*QST_TYPE_TOOLS:*/       3
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
		/*QST_TYPE_DESTROY:*/ 900,
		/*QST_TYPE_INTEL:*/ "INTEL_ITEMS",
		/*QST_TYPE_INFECTION:*/ 1200,
		/*QST_TYPE_WOUNDED:*/ 1100,
		/*QST_TYPE_MED_SUPPLY:*/ "MED_SUPPLY_ITEMS",
		/*QST_TYPE_WEAPON:*/ {
			params ["_targetClassname","_multiplier"];
			private _price = _targetClassname call NWG_fnc_ishopEvaluateItemPrice;
			private _reward = _price + (_price * (_multiplier * 0.1));//Apply 10% of multiplier
			_reward = (round (_reward / 10)) * 10;//Round to nearest 10
			_reward
		},
		/*QST_TYPE_ELECTRONICS:*/ "ELECTRONICS_ITEMS",
		/*QST_TYPE_BURNDOWN:*/ 1000,
		/*QST_TYPE_TOOLS:*/ "TOOLS_ITEMS"
	]],
	["QUEST_DEFAULT_REWARD",1000],
	["QUETS_IGNORE_LAST",4],//Ignore last N quest types if possible (try not to repeat them in a row)

	/*External functions*/
	["FUNC_GET_REWARD_MULTIPLIER",{(call NWG_fnc_mmGetMissionLevel) + 1}],
	["FUNC_GET_ITEM_PRICE_MULT",{1 + (_this * 0.1)}],//How to calculate item price based on reward multiplier
	["FUNC_GET_ITEM_PRICE",{_this call NWG_fnc_ishopEvaluateItemPrice}],
	["FUNC_REWARDABLE_PLAYER",{
		// private _player = _this;
		isPlayer _this && {_this call NWG_fnc_mmWasPlayerOnMission}
	}],
	["FUNC_REWARD_PLAYER",{
		params ["_player","_reward"];
		[_player,P__EXP,1] call NWG_fnc_pAddPlayerProgress;//Add experience
		[_player,P__LVL,1] call NWG_fnc_pAddPlayerProgress;//Level up
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
		/*QST_TYPE_HACK_DATA:*/ "#QST_HACK_DATA_DONE#",
		/*QST_TYPE_DESTROY:*/ "#QST_DESTROY_DONE#",
		/*QST_TYPE_INTEL:*/ false,
		/*QST_TYPE_INFECTION:*/ false,
		/*QST_TYPE_WOUNDED:*/ "#QST_WOUNDED_DONE#",
		/*QST_TYPE_MED_SUPPLY:*/ false,
		/*QST_TYPE_WEAPON:*/ false,
		/*QST_TYPE_ELECTRONICS:*/ false,
		/*QST_TYPE_BURNDOWN:*/ "#QST_BURNDOWN_DONE#",
		/*QST_TYPE_TOOLS:*/ false
	]],
	["LOC_QUEST_CLOSED",[
		/*QST_TYPE_VEH_STEAL:*/ "#QST_VEH_STEAL_CLOSED#",
		/*QST_TYPE_INTERROGATE:*/ "#QST_INTERROGATE_CLOSED#",
		/*QST_TYPE_HACK_DATA:*/ "#QST_HACK_DATA_CLOSED#",
		/*QST_TYPE_DESTROY:*/ "#QST_DESTROY_CLOSED#",
		/*QST_TYPE_INTEL:*/ "#QST_INTEL_CLOSED#",
		/*QST_TYPE_INFECTION:*/ "#QST_INFECTION_CLOSED#",
		/*QST_TYPE_WOUNDED:*/ "#QST_WOUNDED_CLOSED#",
		/*QST_TYPE_MED_SUPPLY:*/ "#QST_MED_SUPPLY_CLOSED#",
		/*QST_TYPE_WEAPON:*/ "#QST_WEAPON_CLOSED#",
		/*QST_TYPE_ELECTRONICS:*/ "#QST_ELECTRONICS_CLOSED#",
		/*QST_TYPE_BURNDOWN:*/ "#QST_BURNDOWN_CLOSED#",
		/*QST_TYPE_TOOLS:*/ "#QST_TOOLS_CLOSED#"
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
	["INTERROGATE_KILL_LIMIT",-2],//If break counter is below this, the target will be killed (keep below zero as 'zero' means target will talk)
	["INTERROGATE_TIE_TITLE","#QST_INTERROGATE_TIE_TITLE#"],
	["INTERROGATE_TIE_ICON","a3\ui_f\data\igui\cfg\holdactions\holdaction_secure_ca.paa"],
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
	["HACK_TEXTURES_UNHACKED",["a3\structures_f_heli\items\electronics\data\tablet_screen_co.paa"]],
	["HACK_TEXTURES_HACKED",["a3\structures_f_epc\items\electronics\data\electronics_screens_laptop_device_co.paa","a3\structures_f\items\electronics\data\electronics_screens_laptop_co.paa"]],

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
		"Land_TTowerBig_2_F",
		"Land_Radar_F"
	]],

	/*Intel quest*/
	["INTEL_ITEMS_OBJECTS",[
		"Item_SecretDocuments",
		"Item_FileTopSecret",
		"Item_SecretFiles",
		"Item_Files",
		"Item_NetworkStructure"
	]],
	["INTEL_ITEMS",[
		"FilesSecret",
		"FileTopSecret",
		"DocumentsSecret",
		"FileNetworkStructure",
		"Files"
	]],//Akshually, they are 'ammo' lol

	/*Infection quest*/
	["INFECTED_TARGETS",[
		"C_Man_casual_1_F_afro_sick",
		"C_Man_casual_3_F_afro_sick",
		"C_man_sport_2_F_afro_sick",
		"C_Man_casual_4_F_afro_sick",
		"C_Man_casual_5_F_afro_sick",
		"C_Man_casual_6_F_afro_sick",
		"C_man_polo_1_F_afro_sick",
		"C_man_polo_2_F_afro_sick",
		"C_man_polo_3_F_afro_sick",
		"C_man_polo_6_F_afro_sick"
	]],

	/*Wounded quest*/
	["WOUNDED_TITLE","#QST_WOUNDED_TITLE#"],
	["WOUNDED_ICON","a3\ui_f\data\igui\cfg\holdactions\holdaction_secure_ca.paa"],

	/*Med Supply quest*/
	["MED_SUPPLY_ITEMS_OBJECTS",[
		"Item_Antibiotic",
		"Item_Antimalaricum",
		"Item_AntimalaricumVaccine",
		"Item_Bandage",
		"Item_FirstAidKit",
		"Item_Medikit"
	]],
	["MED_SUPPLY_ITEMS",[
		"Medikit",
		"FirstAidKit",
		"AntimalaricumVaccine",
		"Antimalaricum",
		"Bandage",
		"Antibiotic"
	]],

	/*Electronics quest*/
	["ELECTRONICS_ITEMS_OBJECTS",[
		"Item_FlashDisk",
		"Item_Laptop_closed",
		"Item_Laptop_Unfolded",
		"Item_SmartPhone",
		"Item_MobilePhone",
		"Item_SatPhone"
	]],
	["ELECTRONICS_ITEMS",[
		"FlashDisk",
		"Laptop_Closed",
		"SmartPhone",
		"MobilePhone",
		"SatPhone",
		"Laptop_Unfolded"
	]],

	/*Burndown quest*/
	["BURNDOWN_TARGETS",[
		"I_supplyCrate_F",
		"O_supplyCrate_F",
		"C_T_supplyCrate_F",
		"C_supplyCrate_F",
		"IG_supplyCrate_F",
		"I_EAF_supplyCrate_F",
		"B_supplyCrate_F",
		"I_CargoNet_01_ammo_F",
		"O_CargoNet_01_ammo_F",
		"C_IDAP_CargoNet_01_supplies_F",
		"I_E_CargoNet_01_ammo_F",
		"B_CargoNet_01_ammo_F"
	]],
	["BURNDOWN_TITLE","#QST_BURNDOWN_TITLE#"],
	["BURNDOWN_ICON","a3\ui_f\data\igui\cfg\actions\obsolete\ui_action_fire_in_flame_ca.paa"],

	/*Tools quest*/
	["TOOLS_ITEMS_OBJECTS",[
		"Item_ToolKit",
		"Item_Butane_canister"
	]],
	["TOOLS_ITEMS",[
		"ToolKit",
		"ButaneCanister"
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
	["FUNC_GET_PLAYER_VEHICLES",{(group _this) call NWG_fnc_vownGetOwnedVehiclesGroup}],
	["FUNC_DELETE_VEHICLE",{_this call NWG_fnc_vshopDeleteVehicle}],
	["FUNC_HAS_ITEM",{_this call NWG_fnc_invHasItem}],
	["FUNC_GET_ITEM_COUNT",{_this call NWG_fnc_invGetItemCount}],
	["FUNC_REMOVE_ITEMS",{_this call NWG_fnc_invRemoveItems}],
	["FUNC_SET_LOADOUT",{_this call NWG_fnc_invSetPlayerLoadout}],
	["FUNC_ON_WOUNDED_UNTIED",{_this remoteExec ["NWG_QST_MC_SetWounded",2]}],

	["",0]
];