#include "..\..\globalDefines.h"

/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
*/

//================================================================================================================
//================================================================================================================
//Defines
// #define NODE_BACK -1
#define NODE_EXIT -2

//Colors
#define COLOR_GREEN [0,1,0,0.75]

//N data for quests
#define LOC_NO_DATA "[NO DATA]"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLGHLP_Settings = createHashMapFromArray [
	/*Localization keys for answer generation*/
	["HELP_KEYS",    ["#AGEN_HELP_01#"]],
	["HELP_PLC_KEYS",["#AGEN_HELP_PLC_01#"]],
	["HELP_WHO_KEYS",["#AGEN_HELP_WHO_01#"]],
	["HELP_TLK_KEYS",["#AGEN_HELP_TLK_01#"]],
	["HELP_UFL_KEYS",["#AGEN_HELP_UFL_01#"]],

	["ADV_KEYS",["#AGEN_ADV_01#"]],

	["ANOTHER_Q_KEYS",["#AGEN_ANQ_01#","#AGEN_ANQ_02#","#AGEN_ANQ_03#","#AGEN_ANQ_04#","#AGEN_ANQ_05#"]],
	["BACK_KEYS",["#AGEN_BACK_01#","#AGEN_BACK_02#","#AGEN_BACK_03#","#AGEN_BACK_04#","#AGEN_BACK_05#","#AGEN_BACK_06#"]],
	["DOUBT_KEYS",["#AGEN_DOUBT_01#","#AGEN_DOUBT_02#","#AGEN_DOUBT_03#","#AGEN_DOUBT_04#","#AGEN_DOUBT_05#","#AGEN_DOUBT_06#"]],
	["EXIT_KEYS",["#AGEN_EXIT_01#","#AGEN_EXIT_02#","#AGEN_EXIT_03#","#AGEN_EXIT_04#","#AGEN_EXIT_05#","#AGEN_EXIT_06#"]],

	["PRGB_HOW_WORK_KEYS",["#AGEN_PRGB_HOW_WORK_01#"]],
	["PRGB_CUR_STAT_KEYS",["#AGEN_PRGB_CUR_STAT_01#"]],
	["PRGB_LETS_UPG_KEYS",["#AGEN_PRGB_LETS_UPG_01#"]],

	["PAY_Y_MONEY_KEYS",["#AGEN_PAY_Y_MONEY_01#","#AGEN_PAY_Y_MONEY_02#","#AGEN_PAY_Y_MONEY_03#","#AGEN_PAY_Y_MONEY_04#","#AGEN_PAY_Y_MONEY_05#"]],
	["PAY_N_MONEY_KEYS",["#AGEN_PAY_N_MONEY_01#","#AGEN_PAY_N_MONEY_02#","#AGEN_PAY_N_MONEY_03#","#AGEN_PAY_N_MONEY_04#","#AGEN_PAY_N_MONEY_05#"]],
	["PAY_REFUSE_KEYS",["#AGEN_PAY_REFUSE_01#","#AGEN_PAY_REFUSE_02#","#AGEN_PAY_REFUSE_03#","#AGEN_PAY_REFUSE_04#","#AGEN_PAY_REFUSE_05#"]],

	/*Quest start|report*/
	["QST_START__A",["#QST_START_01#","#QST_START_02#","#QST_START_03#","#QST_START_04#","#QST_START_05#"]],
	["QST_REPORT_A",["#QST_REPORT_01#","#QST_REPORT_02#","#QST_REPORT_03#","#QST_REPORT_04#","#QST_REPORT_05#"]],
	/*Quest short info*/
	["QST_DISPLAY_TEMPLATES",[
        /*QST_TYPE_VEH_STEAL:*/ "#QST_DISPLAY_VEH_STEAL#",
        /*QST_TYPE_INTERROGATE:*/ "#QST_DISPLAY_INTERROGATE#",
        /*QST_TYPE_HACK_DATA:*/ "#QST_DISPLAY_HACK_DATA#",
        /*QST_TYPE_DESTROY:*/ "#QST_DISPLAY_DESTROY#",
        /*QST_TYPE_INTEL:*/ "#QST_DISPLAY_INTEL#",
        /*QST_TYPE_INFECTION:*/ "#QST_DISPLAY_INFECTION#",
        /*QST_TYPE_WOUNDED:*/ "#QST_DISPLAY_WOUNDED#",
        /*QST_TYPE_MED_SUPPLY:*/ "#QST_DISPLAY_MED_SUPPLY#",
        /*QST_TYPE_WEAPON:*/ "#QST_DISPLAY_WEAPON#",
        /*QST_TYPE_ELECTRONICS:*/ "#QST_DISPLAY_ELECTRONICS#",
		/*QST_TYPE_BURNDOWN:*/ "#QST_DISPLAY_BURNDOWN#",
		/*QST_TYPE_TOOLS:*/ "#QST_DISPLAY_TOOLS#"
	]],
	["QST_REWARD_TEMPLATE","#QST_REWARD_TEMPLATE#"],
	["QST_REWARD_TEMPLATE_PER_ITEM","#QST_REWARD_TEMPLATE_PER_ITEM#"],
	/*Full quest dialogue*/
	["QST_LOC_DATA",[
		/*QST_TYPE_VEH_STEAL:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_VEH_STEAL_01#","#QST_DESCR_VEH_STEAL_02#","#QST_DESCR_VEH_STEAL_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_VEH_STEAL_START_A_01#","#QST_VEH_STEAL_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_VEH_STEAL_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_VEH_STEAL_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_MECH_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_INTERROGATE:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_INTERROGATE_01#","#QST_DESCR_INTERROGATE_02#","#QST_DESCR_INTERROGATE_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_INTERROGATE_START_A_01#","#QST_INTERROGATE_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_COMM_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_COMM_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_02#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_COMM_A_01#"],
			/*LOC_QST_END_BD_Q:*/["#QST_END_BD_INTERROGATE_01#"],
			/*LOC_QST_END_BD_A:*/["#QST_END_BD_ANY_A_01#","#QST_END_BD_ANY_A_02#","#QST_END_BD_ANY_A_03#","#QST_END_BD_ANY_A_04#"]
		],
		/*QST_TYPE_HACK_DATA:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_HACK_DATA_01#","#QST_DESCR_HACK_DATA_02#","#QST_DESCR_HACK_DATA_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_HACK_DATA_START_A_01#","#QST_HACK_DATA_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_COMM_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_COMM_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_02#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_COMM_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_DESTROY:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_DESTROY_01#","#QST_DESCR_DESTROY_02#","#QST_DESCR_DESTROY_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_DESTROY_START_A_01#","#QST_DESTROY_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_COMM_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_COMM_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_01#","#QST_END_GD_ANY_ACTION_COMM_02#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_COMM_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_INTEL:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_INTEL_01#","#QST_DESCR_INTEL_02#","#QST_DESCR_INTEL_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_INTEL_START_A_01#","#QST_INTEL_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#","#QST_ANY_COMM_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_DELIVER_REPORT_A_01#","#QST_ANY_DELIVER_REPORT_A_02#","#QST_ANY_DELIVER_REPORT_A_03#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_COMM_ANY_DELIVER_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_COMM_01#","#QST_END_GD_ANY_DELIVER_COMM_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_COMM_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_INFECTION:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_INFECTION_01#","#QST_DESCR_INFECTION_02#","#QST_DESCR_INFECTION_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_INFECTION_START_A_01#","#QST_INFECTION_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_MEDC_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_MEDC_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_MEDC_01#","#QST_END_GD_INFECTION_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_MEDC_A_01#"],
			/*LOC_QST_END_BD_Q:*/["#QST_END_BD_INFECTION_01#"],
			/*LOC_QST_END_BD_A:*/["#QST_END_BD_ANY_A_01#","#QST_END_BD_ANY_A_02#","#QST_END_BD_ANY_A_03#","#QST_END_BD_ANY_A_04#"]
		],
		/*QST_TYPE_WOUNDED:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_WOUNDED_01#","#QST_DESCR_WOUNDED_02#","#QST_DESCR_WOUNDED_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_WOUNDED_START_A_01#","#QST_WOUNDED_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_MEDC_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_MEDC_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_MEDC_01#","#QST_END_GD_WOUNDED_01#","#QST_END_GD_WOUNDED_02#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_MEDC_A_01#"],
			/*LOC_QST_END_BD_Q:*/["#QST_END_BD_WOUNDED_01#"],
			/*LOC_QST_END_BD_A:*/["#QST_END_BD_ANY_A_01#","#QST_END_BD_ANY_A_02#","#QST_END_BD_ANY_A_03#","#QST_END_BD_ANY_A_04#"]
		],
		/*QST_TYPE_MED_SUPPLY:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_MED_SUPPLY_01#","#QST_DESCR_MED_SUPPLY_02#","#QST_DESCR_MED_SUPPLY_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_MED_SUPPLY_START_A_01#","#QST_MED_SUPPLY_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#","#QST_ANY_MEDC_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_DELIVER_REPORT_A_01#","#QST_ANY_DELIVER_REPORT_A_02#","#QST_ANY_DELIVER_REPORT_A_03#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_MEDC_ANY_DELIVER_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_MEDC_01#","#QST_END_GD_MED_SUPPLY_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_MEDC_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_WEAPON:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_WEAPON_01#","#QST_DESCR_WEAPON_02#","#QST_DESCR_WEAPON_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_WEAPON_START_A_01#","#QST_WEAPON_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#","#QST_ANY_ROOF_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_DELIVER_REPORT_A_01#","#QST_ANY_DELIVER_REPORT_A_02#","#QST_ANY_DELIVER_REPORT_A_03#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_ROOF_ANY_DELIVER_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_ROOF_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_ROOF_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_ELECTRONICS:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_ELECTRONICS_01#","#QST_DESCR_ELECTRONICS_02#","#QST_DESCR_ELECTRONICS_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_ELECTRONICS_START_A_01#","#QST_ELECTRONICS_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#","#QST_ANY_TRDR_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_DELIVER_REPORT_A_01#","#QST_ANY_DELIVER_REPORT_A_02#","#QST_ANY_DELIVER_REPORT_A_03#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_TRDR_ANY_DELIVER_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_TRDR_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_TRDR_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_BURNDOWN:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_BURNDOWN_01#","#QST_DESCR_BURNDOWN_02#","#QST_DESCR_BURNDOWN_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_BURNDOWN_START_A_01#","#QST_BURNDOWN_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_ACTION_REPORT_Q_01#","#QST_ANY_ACTION_REPORT_Q_02#","#QST_ANY_TRDR_REPORT_Q_01#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_ACTION_REPORT_A_01#","#QST_ANY_ACTION_REPORT_A_02#","#QST_ANY_ACTION_REPORT_A_03#","#QST_ANY_ACTION_REPORT_A_04#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_TRDR_ANY_ACTION_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_ANY_TRDR_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#","#QST_END_GD_TRDR_A_01#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		],
		/*QST_TYPE_TOOLS:*/
		[
			/*LOC_QST_START__Q:*/["#QST_DESCR_TOOLS_01#","#QST_DESCR_TOOLS_02#","#QST_DESCR_TOOLS_03#"],
			/*LOC_QST_START__A:*/["#QST_ANY_START_A_01#","#QST_ANY_START_A_02#","#QST_ANY_START_A_03#","#QST_ANY_START_A_04#","#QST_ANY_START_A_05#","#QST_ANY_START_A_06#","#QST_ANY_START_A_07#","#QST_TOOLS_START_A_01#","#QST_TOOLS_START_A_02#"],
			/*LOC_QST_REPORT_Q:*/["#QST_ANY_REPORT_Q_01#","#QST_ANY_REPORT_Q_02#","#QST_ANY_REPORT_Q_03#","#QST_ANY_DELIVER_REPORT_Q_01#","#QST_ANY_DELIVER_REPORT_Q_02#"],
			/*LOC_QST_REPORT_A:*/["#QST_ANY_DELIVER_REPORT_A_01#","#QST_ANY_DELIVER_REPORT_A_02#","#QST_ANY_DELIVER_REPORT_A_03#"],
			/*LOC_QST_UNDONE_Q:*/["#QST_UNDONE_MECH_ANY_DELIVER_Q_01#"],
			/*LOC_QST_UNDONE_A:*/["#QST_UNDONE_ANY_A_01#","#QST_UNDONE_ANY_A_02#","#QST_UNDONE_ANY_A_03#","#QST_UNDONE_ANY_A_04#"],
			/*LOC_QST_END_GD_Q:*/["#QST_END_GD_TOOLS_01#"],
			/*LOC_QST_END_GD_A:*/["#QST_END_GD_ANY_A_01#","#QST_END_GD_ANY_A_02#","#QST_END_GD_ANY_A_03#","#QST_END_GD_ANY_A_04#","#QST_END_GD_ANY_A_05#"],
			/*LOC_QST_END_BD_Q:*/[LOC_NO_DATA],
			/*LOC_QST_END_BD_A:*/[]
		]
	]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Dice logic (used in conditions)
NWG_DLGHLP_Dice = {
	params ["_req","_dice"];
	(_req > (random _dice))
};

//================================================================================================================
//================================================================================================================
//New player check (used in conditions)
NWG_DLGHLP_IsNewPlayer = {
	(player call NWG_fnc_pGetMyLvl) < 3
};

//================================================================================================================
//================================================================================================================
//Money compare logic (used in conditions)
NWG_DLGHLP_HasEnoughMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) >= _this
};
NWG_DLGHLP_HasLessMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) < _this
};
NWG_DLGHLP_HasMoreMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) > ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};
NWG_DLGHLP_HasLessOrEqMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) <= ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};

//================================================================================================================
//================================================================================================================
//Money format (used in questions like 'That would cost you 1000$')
NWG_DLGHLP_MoneyStr = {
	// private _money = _this;
	_this call NWG_fnc_wltFormatMoney
};

//================================================================================================================
//================================================================================================================
//Answers ending generation (allows to shorten dialogue tree by generating typical answers) (use with A_GEN)
//generates answers ["Help","Advice","Exit"]
NWG_DLGHLP_GenerateRoot = {
	// private _npcName = _this;
	//return
	[
		/*Help Node*/[(selectRandom (NWG_DLGHLP_Settings get "HELP_KEYS")),(format ["%1_HELP",_this])],
		/*Adv  Node*/[(selectRandom (NWG_DLGHLP_Settings get "ADV_KEYS" )),(format ["%1_ADV",_this])],
		/*Exit Node*/[(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["What is this place?","Who are you?","Who should I talk to?","How things work?"]
NWG_DLGHLP_GenerateHelp = {
	// private _npcName = _this;
	[
		/*Userflow Node*/[(selectRandom (NWG_DLGHLP_Settings get "HELP_UFL_KEYS")),(format ["%1_HELP_USERFLOW",_this])],
		/*Who Node*/     [(selectRandom (NWG_DLGHLP_Settings get "HELP_WHO_KEYS")),(format ["%1_HELP_WHO",_this])],
		/*Talk Node*/    [(selectRandom (NWG_DLGHLP_Settings get "HELP_TLK_KEYS")),(format ["%1_HELP_TALK",_this])],
		/*Place Node*/   [(selectRandom (NWG_DLGHLP_Settings get "HELP_PLC_KEYS")),(format ["%1_HELP_PLACE",_this])]
	]
};

//generates answers ["Go back","Exit"]
NWG_DLGHLP_GenerateBackExit = {
	// private _backNode = _this;
	[
		/*Back Node*/[(selectRandom (NWG_DLGHLP_Settings get "BACK_KEYS")),_this],
		/*Exit Node*/[(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["Another question","Back","Exit"]
NWG_DLGHLP_GenerateAnQBackExit = {
	params ["_anqNode","_backNode"];
	[
		/*Another Q Node*/  [(selectRandom (NWG_DLGHLP_Settings get "ANOTHER_Q_KEYS")),_anqNode],
		/*Back Node*/       [(selectRandom (NWG_DLGHLP_Settings get "BACK_KEYS")),_backNode],
		/*Exit Node*/       [(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["Go back","Exit"]
NWG_DLGHLP_GenerateDoubtExit = {
	// private _doubtNode = _this;
	[
		/*Doubt Node*/[(selectRandom (NWG_DLGHLP_Settings get "DOUBT_KEYS")),_this],
		/*Exit Node*/ [(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//================================================================================================================
//================================================================================================================
//UI update
#define IDC_QLISTBOX 1500
// #define IDC_ALISTBOX 1501
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_TEXT_NPC 1002

NWG_DLGHLP_UI_UpdatePlayerMoney = {
	private _gui = uiNamespace getVariable ["NWG_DLG_gui",displayNull];
	if (isNull _gui) exitWith {};
	(_gui displayCtrl IDC_TEXT_LEFT) ctrlSetText (call (NWG_DLG_CLI_Settings get "TEXT_LEFT_FILL_FUNC"));//Using the function from the client module
};

//================================================================================================================
//================================================================================================================
//Quests
#define LOC_QST_START__Q 0
#define LOC_QST_START__A 1
#define LOC_QST_REPORT_Q 2
#define LOC_QST_REPORT_A 3
#define LOC_QST_UNDONE_Q 4
#define LOC_QST_UNDONE_A 5
#define LOC_QST_END_GD_Q 6
#define LOC_QST_END_GD_A 7
#define LOC_QST_END_BD_Q 8
#define LOC_QST_END_BD_A 9

/*Defines wether or not entire quest dialogue tree should be available*/
NWG_DLGHLP_QST_ShowQuest = {
	// private _npcName = _this;
	if !(_this call NWG_fnc_qstHasQuest) exitWith {false};//This NPC has no quest assigned
	if (isNil "NWG_MIS_CurrentState") exitWith {true};//Mission module is missing - fallback to showing quest if assigned to NPC
	if (player call NWG_fnc_mmWasPlayerOnMission) exitWith {true};//Player participated in mission - assume they return to report it
	if (NWG_MIS_CurrentState > MSTATE_VOTING) exitWith {true};//New mission started - assume player gets new quest
	//else return
	false
};
NWG_DLGHLP_QST_GenerateShowQuest = {
	// private _npcName = _this;
	if (_this call NWG_DLGHLP_QST_ShowQuest)
		then {[[{call NWG_DLGHLP_GetRndQuestOpen},(format ["%1_QST_DISPLAY",_this]),{},0,COLOR_GREEN]]}
		else {[]}
};

NWG_DLGHLP_QST_IsReporting = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};//Mission module is missing - fallback to false as we can not determine if this is after the mission or before
	player call NWG_fnc_mmWasPlayerOnMission
};

NWG_DLGHLP_GetRndQuestOpen = {
	if (call NWG_DLGHLP_QST_IsReporting)
		then {selectRandom (NWG_DLGHLP_Settings get "QST_REPORT_A")}
		else {selectRandom (NWG_DLGHLP_Settings get "QST_START__A")}
};

NWG_DLGHLP_QST_GenerateQuestDisplayQ = {
	disableSerialization;
	private _npcName = _this;
	private _onError = "[NO QUEST DATA]";

	//Get quest data
	private _questData = call NWG_fnc_qstGetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestDisplayQ: No quest data found" call NWG_fnc_logError;
		_onError
	};
	if ((_questData param [QST_DATA_NPC,""]) isNotEqualTo _npcName) exitWith {
		(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Quest data NPC name mismatch: %1 != %2",(_questData param [QST_DATA_NPC,""]),_npcName]) call NWG_fnc_logError;
		_onError
	};

	//Display NPC name
	private _gui = uiNamespace getVariable ["NWG_DLG_gui",displayNull];
	if (isNull _gui) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestDisplayQ: GUI is null" call NWG_fnc_logError;
		_onError
	};
	private _qListbox = _gui displayCtrl IDC_QLISTBOX;
	if (isNull _qListbox) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestDisplayQ: Quest list box is null" call NWG_fnc_logError;
		_onError
	};
	private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOC_NPC_NAME") getOrDefault [_npcName,""]) call NWG_fnc_localize;
	_qListbox lbAdd "";//Add empty line to separate records
	_qListbox lbAdd (format [(NWG_DLG_CLI_Settings get "TEMPLATE_SPEAKER_NAME"),_npcNameLoc]);//Add speaker name

	//Display quest target object based on quest type
	private _questType = _questData param [QST_DATA_TYPE,-1];
	private _displayName = "";
	private _image = "";
	switch (_questType) do {
		case QST_TYPE_VEH_STEAL;
		case QST_TYPE_INTERROGATE;
		case QST_TYPE_HACK_DATA;
		case QST_TYPE_DESTROY;
		case QST_TYPE_INTEL;
		case QST_TYPE_MED_SUPPLY;
		case QST_TYPE_ELECTRONICS;
		case QST_TYPE_INFECTION;
		case QST_TYPE_WOUNDED;
		case QST_TYPE_BURNDOWN;
		case QST_TYPE_TOOLS: {
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			private _cfg = configFile >> "CfgVehicles" >> _targetClassname;
			if !(isClass _cfg) exitWith {
				(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Target classname is not a valid vehicle: '%1'",_targetClassname]) call NWG_fnc_logError;
			};
			_displayName = getText (_cfg >> "displayName");
			_image = getText (_cfg >> "editorPreview");

			/*Try to get image from weapon config if vehicle config failed*/
			if (isNil "_image" || {_image isEqualTo ""}) then {
				_cfg = configFile >> "CfgWeapons" >> ((_targetClassname splitString "_") select 1);
				if !(isClass _cfg) exitWith {};
				_image = getText (_cfg >> "picture");
			};
		};
		case QST_TYPE_WEAPON: {
			private _targetClassname = _questData param [QST_DATA_TARGET_CLASSNAME,""];
			private _cfg = configFile >> "CfgWeapons" >> _targetClassname;
			if !(isClass _cfg) exitWith {
				(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Target classname is not a valid vehicle: '%1'",_targetClassname]) call NWG_fnc_logError;
			};
			_displayName = getText (_cfg >> "displayName");
			_image = getText (_cfg >> "picture");
		};
		default {
			(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Unknown quest type: '%1'",_questType]) call NWG_fnc_logError;
		};
	};
	private _displayTemplate = ((NWG_DLGHLP_Settings get "QST_DISPLAY_TEMPLATES") param [_questType,"%1"]) call NWG_fnc_localize;
	private _i = _qListbox lbAdd (format [_displayTemplate,_displayName]);
	_qListbox lbSetPicture [_i,_image];

	//Display reward
	private _rewardTemplate = (NWG_DLGHLP_Settings get "QST_REWARD_TEMPLATE") call NWG_fnc_localize;
	private _rewardRaw = _questData param [QST_DATA_REWARD,0];
	private _rewardStr = switch (true) do {
		case (_rewardRaw isEqualType 0): {_rewardRaw call NWG_fnc_wltFormatMoney};
		case (_rewardRaw isEqualType []): {
			private _template = (NWG_DLGHLP_Settings get "QST_REWARD_TEMPLATE_PER_ITEM") call NWG_fnc_localize;
			private _percentage = _rewardRaw param [QST_REWARD_PER_ITEM_PERCENTAGE,0];
			format [_template,_percentage]
		};
		case (_rewardRaw isEqualType ""): {_rewardRaw call NWG_fnc_localize};
		default {
			(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Unknown reward type for '%1'",_rewardRaw]) call NWG_fnc_logError;
			"[UNKNOWN REWARD]"
		};
	};
	_qListbox lbAdd (format [_rewardTemplate,_rewardStr]);

	//Displayer quest description OR report
	private _qstLocData = (NWG_DLGHLP_Settings get "QST_LOC_DATA") param [_questType,[]];
	private _toShow = if (call NWG_DLGHLP_QST_IsReporting) then {LOC_QST_REPORT_Q} else {LOC_QST_START__Q};
	selectRandom (_qstLocData param [_toShow,["[UNKNOWN QUEST DATA]"]])
};

NWG_DLGHLP_QST_GenerateQuestDisplayA = {
	private _npcName = _this;
	private _onError = [];

	//Get quest data
	private _questData = call NWG_fnc_qstGetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestDisplayQ: No quest data found" call NWG_fnc_logError;
		_onError
	};
	if ((_questData param [QST_DATA_NPC,""]) isNotEqualTo _npcName) exitWith {
		(format ["NWG_DLGHLP_QST_GenerateQuestDisplayQ: Quest data NPC name mismatch: %1 != %2",(_questData param [QST_DATA_NPC,""]),_npcName]) call NWG_fnc_logError;
		_onError
	};
	private _questType = _questData param [QST_DATA_TYPE,-1];

	//Return quest accept OR report answer
	private _qstLocData = (NWG_DLGHLP_Settings get "QST_LOC_DATA") param [_questType,[]];
	private _toShow = if (call NWG_DLGHLP_QST_IsReporting) then {LOC_QST_REPORT_A} else {LOC_QST_START__A};

	if (call NWG_DLGHLP_QST_IsReporting) then {
		private _answerStr = selectRandom (_qstLocData param [LOC_QST_REPORT_A,["[UNKNOWN QUEST ANSWER]"]]);
		private _nextNode = format ["%1_QST_RESULT",_npcName];
		private _script = switch (_npcName) do {
			case NPC_TAXI: {{NWG_DLGHLP_QST_questResult = NPC_TAXI call NWG_fnc_qstTryCloseQuest}};
			case NPC_MECH: {{NWG_DLGHLP_QST_questResult = NPC_MECH call NWG_fnc_qstTryCloseQuest}};
			case NPC_TRDR: {{NWG_DLGHLP_QST_questResult = NPC_TRDR call NWG_fnc_qstTryCloseQuest}};
			case NPC_MEDC: {{NWG_DLGHLP_QST_questResult = NPC_MEDC call NWG_fnc_qstTryCloseQuest}};
			case NPC_COMM: {{NWG_DLGHLP_QST_questResult = NPC_COMM call NWG_fnc_qstTryCloseQuest}};
			case NPC_ROOF: {{NWG_DLGHLP_QST_questResult = NPC_ROOF call NWG_fnc_qstTryCloseQuest}};
		};//Dirty hack to avoid caching npc name
		[[_answerStr,_nextNode,_script]]
	} else {
		private _answerStr = selectRandom (_qstLocData param [LOC_QST_START__A,["[UNKNOWN QUEST ANSWER]"]]);
		[[_answerStr,NODE_EXIT]]
	};
};

NWG_DLGHLP_QST_questResult = QST_RESULT_UNDONE;
NWG_DLGHLP_QST_GenerateQuestResultQ = {
	private _onError = "[ERROR]";
	private _questData = call NWG_fnc_qstGetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestDisplayQ: No quest data found" call NWG_fnc_logError;
		_onError
	};
	private _questType = _questData param [QST_DATA_TYPE,-1];
	if (_questType isEqualTo -1) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestResultQ: Invalid quest type" call NWG_fnc_logError;
		_onError
	};
	private _qstLocData = (NWG_DLGHLP_Settings get "QST_LOC_DATA") param [_questType,[]];

	//return
	switch (NWG_DLGHLP_QST_questResult) do {
		case QST_RESULT_UNDONE: {selectRandom (_qstLocData param [LOC_QST_UNDONE_Q,["[UNKNOWN QUEST RESULT]"]])};
		case QST_RESULT_GD_END: {selectRandom (_qstLocData param [LOC_QST_END_GD_Q,["[UNKNOWN QUEST RESULT]"]])};
		case QST_RESULT_BD_END: {selectRandom (_qstLocData param [LOC_QST_END_BD_Q,["[UNKNOWN QUEST RESULT]"]])};
		case false: {_onError}; //Error logged in NWG_QST_CLI_TryCloseQuest
		default {
			(format ["NWG_DLGHLP_QST_GenerateQuestResultQ: Unknown quest result: %1",NWG_DLGHLP_QST_questResult]) call NWG_fnc_logError;
			_onError
		};
	};
};

NWG_DLGHLP_QST_GenerateQuestResultA = {
	private _onError = "[ERROR]";
	private _questData = call NWG_fnc_qstGetQuestData;
	if (_questData isEqualTo false) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestResultA: No quest data found" call NWG_fnc_logError;
		_onError
	};
	private _questType = _questData param [QST_DATA_TYPE,-1];
	if (_questType isEqualTo -1) exitWith {
		"NWG_DLGHLP_QST_GenerateQuestResultA: Invalid quest type" call NWG_fnc_logError;
		_onError
	};
	private _qstLocData = (NWG_DLGHLP_Settings get "QST_LOC_DATA") param [_questType,[]];

	//return
	private _answerStr = switch (NWG_DLGHLP_QST_questResult) do {
		case QST_RESULT_UNDONE: {selectRandom (_qstLocData param [LOC_QST_UNDONE_A,["[UNKNOWN QUEST RESULT]"]])};
		case QST_RESULT_GD_END: {selectRandom (_qstLocData param [LOC_QST_END_GD_A,["[UNKNOWN QUEST RESULT]"]])};
		case QST_RESULT_BD_END: {selectRandom (_qstLocData param [LOC_QST_END_BD_A,["[UNKNOWN QUEST RESULT]"]])};
		case false: {_onError}; //Error logged in NWG_QST_CLI_TryCloseQuest
		default {
			(format ["NWG_DLGHLP_QST_GenerateQuestResultA: Unknown quest result: %1",NWG_DLGHLP_QST_questResult]) call NWG_fnc_logError;
			_onError
		};
	};
	[[_answerStr,NODE_EXIT]]
};

//================================================================================================================
//================================================================================================================
//Progress buy
NWG_DLGHLP_PRGB_GeneratePrgbSel = {
	params ["_npcName",["_howWork",true],["_curStat",true],["_letsUpg",true]];
	private _result = [];

	/*How does it work?*/
	if (_howWork) then {
		_result pushBack [(selectRandom (NWG_DLGHLP_Settings get "PRGB_HOW_WORK_KEYS")),(format ["%1_PRGB_HOW_WORK",_npcName])];
	};

	/* How to upgrade? */
	if (_curStat) then {
		_result pushBack [(selectRandom (NWG_DLGHLP_Settings get "PRGB_CUR_STAT_KEYS")),(format ["%1_PRGB_CUR_STAT",_npcName])];
	};

	/* Let's upgrade!  */
	if (_letsUpg) then {
		_result pushBack [(selectRandom (NWG_DLGHLP_Settings get "PRGB_LETS_UPG_KEYS")),(format ["%1_PRGB_LETS_UPG",_npcName])];
	};

	_result
};

NWG_DLGHLP_PRGB_GetProgressStr = {
	// private _type = _this;
	([player,_this] call NWG_fnc_pGetProgressAsString)
};
NWG_DLGHLP_PRGB_GetRemainingStr = {
	// private _type = _this;
	([player,_this] call NWG_fnc_pGetRemainingAsString)
};

NWG_DLGHLP_PRGB_LimitReached = {
	// private _type = _this;
	(_this call NWG_fnc_pGetUpgradeValues) select 0
};
NWG_DLGHLP_PRGB_CanUpgrade = {
	// private _type = _this;
	(_this call NWG_fnc_pCanUpgrade)
};
NWG_DLGHLP_PRGB_PricesStr = {
	// private _type = _this;
	(_this call NWG_fnc_pGetUpgradeValues) params ["","","_priceMoney","_priceExp"];
	format [
		"%1 Exp: %2",
		(_priceMoney call NWG_fnc_wltFormatMoney),
		_priceExp
	]
};

NWG_DLGHLP_PRGB_Upgrade = {
	// private _type = _this;
	_this call NWG_fnc_pUpgrade;
	call NWG_DLGHLP_UI_UpdatePlayerMoney;
};

//================================================================================================================
//================================================================================================================
//Payment answers
NWG_DLGHLP_GetRndPayY = {
	selectRandom (NWG_DLGHLP_Settings get "PAY_Y_MONEY_KEYS")
};
NWG_DLGHLP_GetRndPayN = {
	selectRandom (NWG_DLGHLP_Settings get "PAY_N_MONEY_KEYS")
};
NWG_DLGHLP_GetRndPayRefuse = {
	selectRandom (NWG_DLGHLP_Settings get "PAY_REFUSE_KEYS")
};

//================================================================================================================
//================================================================================================================
//Exit answers
NWG_DLGHLP_GetRndBack = {
	selectRandom (NWG_DLGHLP_Settings get "BACK_KEYS")
};
NWG_DLGHLP_GetRndExit = {
	selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")
};