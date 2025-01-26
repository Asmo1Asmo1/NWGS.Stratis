/*
Dialogue records:
In the format QnA
Q	Q_ONE	Single question
	Q_RND	Array of questions to select from randomly
	Q_RNG	Array of questions to select from randomly with guarantee of not repeating until all questions are used (good for 'advice' dialogues)
	Q_CND	Array of [{condition},question,...] - whichever returns 'true' first - (_i+1) question will be displayed
Each question may be of type
	string - single localization key
	array - format ["template",{code to return arg},...]

A	A_DEF	Predefined array of answers
	A_CND	Array of [{condition},answer,...] - whichever condition returns 'true' - (_i+1) will be added to list of answers
	A_GEN	Either single code block or array of [{code},{code},answer,...] where each code block is expected to return array of answers
Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
%ANSWER_STR%
	string - single localization key
	array - format ["template",{code to return arg},...]
%NEXT_NODE%
	string - id of the next node
	NODE_BACK - get back to the previous node
	NODE_EXIT - end of dialogue, close UI
%CODE%	optional code to execute in order:
	- IF %NEXT_NODE% is NODE_EXIT - after closing the UI (serves as a callback)
	- IF %NEXT_NODE% is NODE_BACK or Defined Node - before loading the next node (e.g.: setting some variables that will affect the next node)
%CODE_ARGS%	optional arguments to pass to %CODE% (default: [])

Dialogue node structure:
[
	"NodeID",	[
	Q_XXX,	(SingleQ || [ArrayQ]),
	A_XXX,	[ArrayA]
]],
in other words:
"NodeID"  :   params ["_qType","_qBody","_aType","_aBody"];
*/
#define Q_ONE 0
#define Q_RND 1
#define Q_RNG 2
#define Q_CND 3

#define A_DEF 0
#define A_CND 1
#define A_GEN 2

#define NODE_BACK -1
#define NODE_EXIT -2


NWG_DialogueTree = createHashMapFromArray [
	//================================================================================================================
	//================================================================================================================
	//Taxi
	/*Actual root of the dialogue*/
	[
		"TAXI_00",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#TAXI_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_03#",
				{true},"#TAXI_00_Q_04#"
			],
			A_GEN,	[
				["#TAXI_00_A_01#","TAXI_CS"],
				{"TAXI" call NWG_DLGHLP_GenerateRoot}/*["TAXI_HELP","TAXI_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Pseudo root for getting back in dialogue (uses same answers as TAXI_00)*/
	[
		"TAXI_01",	[
			Q_RND,	[
				"#XXX_01_Q_01#",
				"#TAXI_01_Q_02#"
			],
			A_GEN,	[
				["#TAXI_00_A_01#","TAXI_CS"],
				{"TAXI" call NWG_DLGHLP_GenerateRoot}/*["TAXI_HELP","TAXI_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Drop me by - category selection*/
	[
		"TAXI_CS",	[
			Q_RND,	[
				"#TAXI_CS_Q_01#",
				"#TAXI_CS_Q_02#",
				"#TAXI_CS_Q_03#"
			],
			A_GEN,	[
				{call NWG_DLG_TAXI_GenerateDropCategories},
				{"TAXI_01" call NWG_DLGHLP_GenerateDoubtExit}/*["TAXI_01",NODE_EXIT]*/
			]
		]
	],
	/*Drop me by - point selection*/
	[
		"TAXI_PS",	[
			Q_ONE,	"#TAXI_PS_Q_01#",
			A_GEN,	[
				{call NWG_DLG_TAXI_GenerateDropPoints},
				{"TAXI_CS" call NWG_DLGHLP_GenerateDoubtExit}/*["TAXI_CS",NODE_EXIT]*/
			]
		]
	],
	/*Drop me by - payment*/
	[
		"TAXI_PAY",	[
			Q_ONE,	["#XXX_PAY_Q_01#",{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_MoneyStr}],
			A_CND,	[
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasEnoughMoney},["#TAXI_PAY_A_01#",NODE_EXIT,{call NWG_DLG_TAXI_Teleport}],
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasLessMoney},["#TAXI_PAY_A_02#","TAXI_LOW"],
				{true},["#XXX_PAY_REFUSE#","TAXI_CS"],
				{true},["#TAXI_PAY_A_03#",NODE_EXIT]
			]
		]
	],
	/*Drop me by - not enough money*/
	[
		"TAXI_LOW",	[
			Q_RND,	[
				"#TAXI_LOW_Q_01#",
				"#TAXI_LOW_Q_02#",
				"#TAXI_LOW_Q_03#",
				"#TAXI_LOW_Q_04#"
			],
			A_DEF,	[
				["#TAXI_LOW_A_01#","TAXI_01"],
				["#TAXI_LOW_A_02#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"TAXI_HELP",	[
			Q_RND,	[
				"#TAXI_HELP_Q_01#",
				"#TAXI_HELP_Q_02#",
				"#TAXI_HELP_Q_03#",
				"#TAXI_HELP_Q_04#"
			],
			A_GEN,	{"TAXI" call NWG_DLGHLP_GenerateHelp}/*["TAXI_HELP_PLACE","TAXI_HELP_WHO","TAXI_HELP_TALK","TAXI_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"TAXI_HELP_PLACE",	[
			Q_ONE,	"#TAXI_HELP_PLACE_Q_01#",
			A_GEN,	{["TAXI_HELP","TAXI_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TAXI_HELP","TAXI_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"TAXI_HELP_WHO",	[
			Q_ONE,	"#TAXI_HELP_WHO_Q_01#",
			A_GEN,	{["TAXI_HELP","TAXI_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TAXI_HELP","TAXI_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"TAXI_HELP_TALK",	[
			Q_ONE,	"#TAXI_HELP_TALK_Q_01#",
			A_GEN,	{["TAXI_HELP","TAXI_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TAXI_HELP","TAXI_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"TAXI_HELP_USERFLOW",	[
			Q_ONE,	"#TAXI_HELP_USERFLOW_Q_01#",
			A_GEN,	{["TAXI_HELP","TAXI_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TAXI_HELP","TAXI_01",NODE_EXIT]*/
		]
	],
	/*Any advice*/
	[
		"TAXI_ADV",	[
			Q_RNG,	[
				"#TAXI_ADV_Q_01#",
				"#TAXI_ADV_Q_02#",
				"#TAXI_ADV_Q_03#",
				"#TAXI_ADV_Q_04#"
			],
			A_CND,	[
				{[1,10] call NWG_DLGHLP_Dice},["#TAXI_ADV_A_01#","TAXI_01"],
				{true},["#AGEN_BACK_01#","TAXI_01"],
				{true},["#AGEN_EXIT_03#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Mech
	/*Actual root of the dialogue*/
	[
		"MECH_00",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#MECH_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_03#",
				{[1,15] call NWG_DLGHLP_Dice},"#MECH_00_Q_04#",
				{true},"#MECH_00_Q_05#"
			],
			A_GEN,	[
				["#MECH_00_A_01#",NODE_EXIT,{call NWG_DLG_MECH_OpenShop}],
				["#MECH_00_A_02#","MECH_SERV"],
				{"MECH" call NWG_DLGHLP_GenerateRoot}/*["MECH_HELP","MECH_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"MECH_01",	[
			Q_RND,	[
				"#XXX_01_Q_01#",
				"#MECH_01_Q_02#",
				"#MECH_01_Q_03#"
			],
			A_GEN,	[
				["#MECH_00_A_01#",NODE_EXIT,{call NWG_DLG_MECH_OpenShop}],
				["#MECH_00_A_02#","MECH_SERV"],
				{"MECH" call NWG_DLGHLP_GenerateRoot}/*["MECH_HELP","MECH_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Services - category selection*/
	[
		"MECH_SERV",	[
			Q_ONE,	"#MECH_SERV_Q_01#",
			A_GEN,	[
				["#MECH_SERV_A_01#","MECH_REPAIR"],
				["#MECH_SERV_A_02#","MECH_REFUEL"],
				["#MECH_SERV_A_03#","MECH_REARM"],
				["#MECH_SERV_A_04#","MECH_APRNC"],
				["#MECH_SERV_A_05#","MECH_PYLON"],
				["#MECH_SERV_A_06#","MECH_ALWHL"],
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - repair choice*/
	[
		"MECH_REPAIR",	[
			Q_RND,	[
				"#MECH_REPAIR_Q_01#",
				"#MECH_REPAIR_Q_02#"
			],
			A_GEN,	[
				{"REPR" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - refuel choice*/
	[
		"MECH_REFUEL",	[
			Q_RND,	[
				"#MECH_REFUEL_Q_01#",
				"#MECH_REFUEL_Q_02#"
			],
			A_GEN,	[
				{"FUEL" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - rearm choice*/
	[
		"MECH_REARM",	[
			Q_RND,	[
				"#MECH_REARM_Q_01#",
				"#MECH_REARM_Q_02#"
			],
			A_GEN,	[
				{"RARM" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - appearance choice*/
	[
		"MECH_APRNC",	[
			Q_RND,	[
				"#MECH_APRNC_Q_01#",
				"#MECH_APRNC_Q_02#"
			],
			A_GEN,	[
				{"APPR" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - pylon choice*/
	[
		"MECH_PYLON",	[
			Q_RND,	[
				"#MECH_PYLON_Q_01#",
				"#MECH_PYLON_Q_02#",
				"#MECH_PYLON_Q_03#"
			],
			A_GEN,	[
				{"PYLN" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - all wheel choice*/
	[
		"MECH_ALWHL",	[
			Q_RND,	[
				"#MECH_ALWHL_Q_01#",
				"#MECH_ALWHL_Q_02#",
				"#MECH_ALWHL_Q_03#",
				"#MECH_ALWHL_Q_04#"
			],
			A_GEN,	[
				{"AWHL" call NWG_DLG_MECH_GenerateChoices},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - payment*/
	[
		"MECH_PAY",	[
			Q_ONE,	["#XXX_PAY_Q_01#",{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_MoneyStr}],
			A_CND,	[
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasEnoughMoney},["#MECH_PAY_A_01#",NODE_EXIT,{call NWG_DLG_MECH_DoService}],
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasLessMoney},["#MECH_PAY_A_02#","MECH_LOW"],
				{true},["#XXX_PAY_REFUSE#","MECH_01"],
				{true},["#AGEN_EXIT_06#",NODE_EXIT]
			]
		]
	],
	/*Services - not enough money*/
	[
		"MECH_LOW",	[
			Q_RND,	[
				"#MECH_LOW_Q_01#",
				"#MECH_LOW_Q_02#"
			],
			A_DEF,	[
				["#MECH_LOW_A_01#","MECH_01"],
				["#MECH_LOW_A_02#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"MECH_HELP",	[
			Q_RND,	[
				"#MECH_HELP_Q_01#",
				"#MECH_HELP_Q_02#",
				"#MECH_HELP_Q_03#"
			],
			A_GEN,	{"MECH" call NWG_DLGHLP_GenerateHelp}/*["MECH_HELP_PLACE","MECH_HELP_WHO","MECH_HELP_TALK","MECH_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"MECH_HELP_PLACE",	[
			Q_ONE,	"#MECH_HELP_PLACE_Q_01#",
			A_GEN,	{["MECH_HELP","MECH_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MECH_HELP","MECH_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"MECH_HELP_WHO",	[
			Q_ONE,	"#MECH_HELP_WHO_Q_01#",
			A_GEN,	{["MECH_HELP","MECH_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MECH_HELP","MECH_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"MECH_HELP_TALK",	[
			Q_ONE,	"#MECH_HELP_TALK_Q_01#",
			A_GEN,	{["MECH_HELP","MECH_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MECH_HELP","MECH_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"MECH_HELP_USERFLOW",	[
			Q_ONE,	"#MECH_HELP_USERFLOW_Q_01#",
			A_GEN,	{["MECH_HELP","MECH_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MECH_HELP","MECH_01",NODE_EXIT]*/
		]
	],
	/*Any advice*/
	[
		"MECH_ADV",	[
			Q_RNG,	[
				"#MECH_ADV_Q_01#",
				"#MECH_ADV_Q_02#",
				"#MECH_ADV_Q_03#",
				"#MECH_ADV_Q_04#"
			],
			A_GEN,	{"MECH_01" call NWG_DLGHLP_GenerateBackExit}/*["MECH_01",NODE_EXIT]*/
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Trdr
	/*Actual root of the dialogue*/
	[
		"TRDR_00",	[
			Q_CND,	[
				{0.1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#TRDR_00_Q_01#",
				{1   call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#TRDR_00_Q_02#",
				{10  call NWG_DLGHLP_HasMoreMoneyStartSum},"#TRDR_00_Q_03#",
				{100 call NWG_DLGHLP_HasMoreMoneyStartSum},"#TRDR_00_Q_04#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_05#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_06#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_07#",
				{true},"#TRDR_00_Q_08#"
			],
			A_DEF,	[
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],
				["#AGEN_HELP_01#","TRDR_HELP"],
				["#AGEN_ADV_01#","TRDR_ADV1"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"TRDR_01",	[
			Q_RND,	[
				"#TRDR_01_Q_01#",
				"#TRDR_01_Q_02#",
				"#TRDR_01_Q_03#"
			],
			A_DEF,	[
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],
				["#AGEN_HELP_01#","TRDR_HELP"],
				["#AGEN_ADV_01#","TRDR_ADV1"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"TRDR_HELP",	[
			Q_RND,	[
				"#TRDR_HELP_Q_01#",
				"#TRDR_HELP_Q_02#",
				"#TRDR_HELP_Q_03#"
			],
			A_GEN,	{"TRDR" call NWG_DLGHLP_GenerateHelp}/*["TRDR_HELP_PLACE","TRDR_HELP_WHO","TRDR_HELP_TALK","TRDR_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"TRDR_HELP_PLACE",	[
			Q_ONE,	"#TRDR_HELP_PLACE_Q_01#",
			A_GEN,	{["TRDR_HELP","TRDR_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TRDR_HELP","TRDR_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"TRDR_HELP_WHO",	[
			Q_ONE,	"#TRDR_HELP_WHO_Q_01#",
			A_GEN,	{["TRDR_HELP","TRDR_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TRDR_HELP","TRDR_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"TRDR_HELP_TALK",	[
			Q_ONE,	"#TRDR_HELP_TALK_Q_01#",
			A_GEN,	{["TRDR_HELP","TRDR_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TRDR_HELP","TRDR_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"TRDR_HELP_USERFLOW",	[
			Q_ONE,	"#TRDR_HELP_USERFLOW_Q_01#",
			A_GEN,	{["TRDR_HELP","TRDR_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["TRDR_HELP","TRDR_01",NODE_EXIT]*/
		]
	],
	/*Any advice - Pay for advice*/
	[
		"TRDR_ADV1",	[
			Q_RND,	[
				["#TRDR_ADV1_Q_01#",{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_MoneyStr}],
				["#TRDR_ADV1_Q_02#",{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_MoneyStr}],
				["#TRDR_ADV1_Q_03#",{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_MoneyStr}]
			],
			A_CND,	[
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasEnoughMoney},["#TRDR_ADV1_A_01#","TRDR_ADV2",{call NWG_DLG_TRDR_PayForAdvice}],
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasLessMoney},["#TRDR_ADV1_A_02#","TRDR_LOW"],
				{true},["#XXX_PAY_REFUSE#","TRDR_01"],
				{true},["#AGEN_EXIT_06#",NODE_EXIT]
			]
		]
	],
	/*Any advice - Get advice*/
	[
		"TRDR_ADV2",	[
			Q_RNG,	[
				"#TRDR_ADV2_Q_01#",
				"#TRDR_ADV2_Q_02#",
				"#TRDR_ADV2_Q_03#"
			],
			A_GEN,	{"TRDR_01" call NWG_DLGHLP_GenerateBackExit}/*["TRDR_01",NODE_EXIT]*/
		]
	],
	/*Any advice - Not enough money*/
	[
		"TRDR_LOW",	[
			Q_ONE,	"#TRDR_LOW_Q_01#",
			A_CND,	[
				{[1,3] call NWG_DLGHLP_Dice},["#TRDR_LOW_A_01#","TRDR_01"],
				{true},["#TRDR_LOW_A_02#","TRDR_01"],
				{true},["#TRDR_LOW_A_03#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Medc
	/*Actual root of the dialogue*/
	[
		"MEDC_00",	[
			Q_CND,	[
				{(call NWG_DLG_MEDC_IsInjured) && {[1,2] call NWG_DLGHLP_Dice}},"#MEDC_00_Q_01#",
				{call NWG_DLG_MEDC_IsInjured},"#MEDC_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MEDC_00_Q_03#",
				{[1,3] call NWG_DLGHLP_Dice},"#MEDC_00_Q_04#",
				{true},"#MEDC_00_Q_05#"
			],
			A_CND,	[
				{call NWG_DLG_MEDC_IsInjured},["#MEDC_00_A_01#","MEDC_PATCH"],
				{true},["#AGEN_HELP_01#","MEDC_HELP"],
				{true},["#AGEN_ADV_01#","MEDC_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"MEDC_01",	[
			Q_RND,	[
				"#MEDC_01_Q_01#",
				"#MEDC_01_Q_02#",
				"#MEDC_01_Q_03#"
			],
			A_CND,	[
				{call NWG_DLG_MEDC_IsInjured},["#MEDC_01_A_01#","MEDC_PATCH"],
				{true},["#AGEN_HELP_01#","MEDC_HELP"],
				{true},["#AGEN_ADV_01#","MEDC_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Medic patch*/
	[
		"MEDC_PATCH",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#MEDC_PATCH_Q_01#",
				{1 call NWG_DLGHLP_HasMoreMoneyStartSum},["#MEDC_PATCH_Q_02#",{(call NWG_DLG_MEDC_GetPatchPrice) call NWG_DLGHLP_MoneyStr}]
			],
			A_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#MEDC_PATCH_A_01#",NODE_EXIT,{true call NWG_DLG_MEDC_Patch}],
				{1 call NWG_DLGHLP_HasMoreMoneyStartSum},["#MEDC_PATCH_A_02#",NODE_EXIT,{false call NWG_DLG_MEDC_Patch}],
				{true},["#AGEN_EXIT_06#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"MEDC_HELP",	[
			Q_RND,	[
				"#MEDC_HELP_Q_01#",
				"#MEDC_HELP_Q_02#"
			],
			A_GEN,	{"MEDC" call NWG_DLGHLP_GenerateHelp}/*["MEDC_HELP_PLACE","MEDC_HELP_WHO","MEDC_HELP_TALK","MEDC_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"MEDC_HELP_PLACE",	[
			Q_ONE,	"#MEDC_HELP_PLACE_Q_01#",
			A_GEN,	{["MEDC_HELP","MEDC_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MEDC_HELP","MEDC_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"MEDC_HELP_WHO",	[
			Q_ONE,	"#MEDC_HELP_WHO_Q_01#",
			A_GEN,	{["MEDC_HELP","MEDC_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MEDC_HELP","MEDC_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"MEDC_HELP_TALK",	[
			Q_ONE,	"#MEDC_HELP_TALK_Q_01#",
			A_GEN,	{["MEDC_HELP","MEDC_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MEDC_HELP","MEDC_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"MEDC_HELP_USERFLOW",	[
			Q_ONE,	"#MEDC_HELP_USERFLOW_Q_01#",
			A_GEN,	{["MEDC_HELP","MEDC_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MEDC_HELP","MEDC_01",NODE_EXIT]*/
		]
	],
	/*Any advice*/
	[
		"MEDC_ADV",	[
			Q_RNG,	[
				"#MEDC_ADV_Q_01#",
				"#MEDC_ADV_Q_02#",
				"#MEDC_ADV_Q_03#"
			],
			A_GEN,	{"MEDC_01" call NWG_DLGHLP_GenerateBackExit}/*["MEDC_01",NODE_EXIT]*/
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Comm (Commander)
	/*Actual root of the dialogue*/
	[
		"COMM_00",	[
			Q_CND,	[
				{call NWG_DLG_COMM_IsMissionStarted},"#COMM_00_Q_01#",
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#COMM_00_Q_02#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_03#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_04#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_05#",
				{true},"#COMM_00_Q_06#"
			],
			A_CND,	[
				{call NWG_DLG_COMM_IsMissionReady},["#COMM_00_A_01#","COMM_MIS"],
				{call NWG_DLG_COMM_IsMissionStarted},["#COMM_00_A_02#",NODE_EXIT],
				{true},["#COMM_00_A_03#","COMM_HELP"],
				{true},["#COMM_00_A_04#","COMM_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"COMM_01",	[
			Q_RND,	[
				"#COMM_00_Q_03#",
				"#COMM_00_Q_06#",
				"#XXX_01_Q_01#",
				"#MECH_01_Q_03#"
			],
			A_CND,	[
				{call NWG_DLG_COMM_IsMissionReady},["#COMM_00_A_01#","COMM_MIS"],
				{call NWG_DLG_COMM_IsMissionStarted},["#COMM_01_A_02#",NODE_EXIT],
				{true},["#COMM_00_A_03#","COMM_HELP"],
				{true},["#COMM_00_A_04#","COMM_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Mission select*/
	[
		"COMM_MIS",	[
			Q_RND,	[
				"#COMM_MIS_Q_01#",
				"#COMM_MIS_Q_02#",
				"#COMM_MIS_Q_03#"
			],
			A_DEF,	[
				["#COMM_MIS_A_01#",NODE_EXIT,{call NWG_DLG_COMM_StartMission}],
				["#COMM_MIS_A_02#","COMM_01"],
				["#COMM_MIS_A_03#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"COMM_HELP",	[
			Q_RND,	[
				"#COMM_HELP_Q_01#",
				"#COMM_HELP_Q_02#"
			],
			A_GEN,	{"COMM" call NWG_DLGHLP_GenerateHelp}/*["COMM_HELP_PLACE","COMM_HELP_WHO","COMM_HELP_TALK","COMM_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"COMM_HELP_PLACE",	[
			Q_ONE,	"#COMM_HELP_PLACE_Q_01#",
			A_GEN,	{["COMM_HELP","COMM_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["COMM_HELP","COMM_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"COMM_HELP_WHO",	[
			Q_ONE,	"#COMM_HELP_WHO_Q_01#",
			A_GEN,	{["COMM_HELP","COMM_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["COMM_HELP","COMM_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"COMM_HELP_TALK",	[
			Q_ONE,	"#COMM_HELP_TALK_Q_01#",
			A_GEN,	{["COMM_HELP","COMM_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["COMM_HELP","COMM_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"COMM_HELP_USERFLOW",	[
			Q_ONE,	"#COMM_HELP_USERFLOW_Q_01#",
			A_GEN,	{["COMM_HELP","COMM_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["COMM_HELP","COMM_01",NODE_EXIT]*/
		]
	],
	/*Any advice*/
	[
		"COMM_ADV",	[
			Q_RNG,	[
				"#COMM_ADV_Q_01#",
				"#COMM_ADV_Q_02#",
				"#COMM_ADV_Q_03#",
				"#COMM_ADV_Q_04#",
				"#COMM_ADV_Q_05#"
			],
			A_GEN,	{"COMM_01" call NWG_DLGHLP_GenerateBackExit}/*["COMM_01",NODE_EXIT]*/
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Roof
	/*Actual root of the dialogue*/
	[
		"ROOF_00",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#ROOF_00_Q_01#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_02#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_03#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_04#",
				{true},"#ROOF_00_Q_05#"
			],
			A_CND,	[
				{true},["#ROOF_00_A_00#","ROOF_TS"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_01#","ROOF_WHAT"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#ROOF_00_A_02#","ROOF_KNOW"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#AGEN_HELP_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#AGEN_HELP_01#","ROOF_HELP"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#AGEN_ADV_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#AGEN_ADV_01#","ROOF_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"ROOF_01",	[
			Q_RND,	[
				"#ROOF_01_Q_01#",
				"#ROOF_01_Q_02#",
				"#ROOF_01_Q_03#"
			],
			A_CND,	[
				{true},["#ROOF_00_A_00#","ROOF_TS"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_01#","ROOF_WHAT"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#ROOF_00_A_02#","ROOF_KNOW"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#AGEN_HELP_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#AGEN_HELP_01#","ROOF_HELP"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#AGEN_ADV_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#AGEN_ADV_01#","ROOF_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Reflash - terminal selection*/
	[
		"ROOF_TS",	[
			Q_RND,	[
				"#ROOF_TS_Q_01#",
				"#ROOF_TS_Q_02#"
			],
			A_GEN,	[
				{call NWG_DLG_ROOF_GenerateChoices},
				{"ROOF_01" call NWG_DLGHLP_GenerateDoubtExit}/*["ROOF_01",NODE_EXIT]*/
			]
		]
	],
	/*Reflash - payment*/
	[
		"ROOF_PAY",	[
			Q_ONE,	["#XXX_PAY_Q_01#",{(call NWG_DLG_ROOF_GetPrice) call NWG_DLGHLP_MoneyStr}],
			A_CND,	[
				{(call NWG_DLG_ROOF_GetPrice) call NWG_DLGHLP_HasEnoughMoney},["#ROOF_PAY_A_01#",NODE_EXIT,{call NWG_DLG_ROOF_DoReflash}],
				{(call NWG_DLG_ROOF_GetPrice) call NWG_DLGHLP_HasLessMoney},["#ROOF_PAY_A_02#","ROOF_LOW"],
				{true},["#XXX_PAY_REFUSE#","ROOF_01"],
				{true},["#ROOF_PAY_A_03#",NODE_EXIT]
			]
		]
	],
	/*Reflash - not enough money*/
	[
		"ROOF_LOW",	[
			Q_RND,	[
				"#ROOF_LOW_Q_01#",
				"#ROOF_LOW_Q_02#"
			],
			A_DEF,	[
				["#ROOF_LOW_A_01#","ROOF_01"],
				["#ROOF_LOW_A_02#",NODE_EXIT]
			]
		]
	],
	/*What are you doing here*/
	[
		"ROOF_WHAT",	[
			Q_ONE,	"#ROOF_WHAT_Q_01#",
			A_DEF,	[
				["#AGEN_BACK_01#","ROOF_01"],
				["#ROOF_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Doesn't trust you*/
	[
		"ROOF_NO_TRUST",	[
			Q_RND,	[
				"#ROOF_NO_TRUST_Q_01#",
				"#ROOF_NO_TRUST_Q_02#",
				"#ROOF_NO_TRUST_Q_03#",
				"#ROOF_NO_TRUST_Q_04#"
			],
			A_DEF,	[
				["#ROOF_NO_TRUST_A_01#","ROOF_01"],
				["#ROOF_NO_TRUST_A_02#",NODE_EXIT]
			]
		]
	],
	/*What else do you know?*/
	[
		"ROOF_KNOW",	[
			Q_RND,	[
				"#ROOF_KNOW_Q_01#",
				"#ROOF_KNOW_Q_02#",
				"#ROOF_KNOW_Q_03#"
			],
			A_DEF,	[
				["#ROOF_KNOW_A_01#","ROOF_HIST00"],
				["#ROOF_KNOW_A_02#","ROOF_LGND00"],
				["#ROOF_KNOW_A_03#","ROOF_RUMR"],
				["#ROOF_0X_A_BACK3#","ROOF_01"],
				["#AGEN_DOUBT_06#",NODE_EXIT]
			]
		]
	],
	/*History - category selection*/
	[
		"ROOF_HIST00",	[
			Q_ONE,	"#ROOF_HIST00_Q_01#",
			A_DEF,	[
				["#ROOF_HIST00_A_01#","ROOF_HIST01"],
				["#ROOF_HIST00_A_02#","ROOF_HIST02"]
			]
		]
	],
	/*History - short story*/
	[
		"ROOF_HIST01",	[
			Q_ONE,	"#ROOF_HIST01_Q_01#",
			A_CND,	[
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST01_A_01#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST01_A_02#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST01_A_03#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*History - long story*/
	[
		"ROOF_HIST02",	[
			Q_ONE,	"#ROOF_HIST02_Q_01#",
			A_CND,	[
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST02_A_01#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST02_A_02#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST02_A_03#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_HIST02_A_04#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Local legends - category selection*/
	[
		"ROOF_LGND00",	[
			Q_RND,	[
				"#ROOF_LGND00_Q_01#",
				"#ROOF_LGND00_Q_02#",
				"#ROOF_LGND00_Q_03#"
			],
			A_DEF,	[
				["#ROOF_LGND00_A_01#","ROOF_LGND_HOPA"],
				["#ROOF_LGND00_A_02#","ROOF_LGND_BIT"],
				["#ROOF_LGND00_A_03#","ROOF_LGND_BANKA"],
				["#ROOF_LGND00_A_04#","ROOF_LGND_HUI"],
				["#ROOF_LGND00_A_05#","ROOF_LGND_ASMO"],
				["#ROOF_0X_A_BACK3#","ROOF_01"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Local legends - someone else*/
	[
		"ROOF_LGND01",	[
			Q_RND,	[
				"#ROOF_LGND01_Q_01#",
				"#ROOF_LGND01_Q_02#",
				"#ROOF_LGND01_Q_03#"
			],
			A_DEF,	[
				["#ROOF_LGND00_A_01#","ROOF_LGND_HOPA"],
				["#ROOF_LGND00_A_02#","ROOF_LGND_BIT"],
				["#ROOF_LGND00_A_03#","ROOF_LGND_BANKA"],
				["#ROOF_LGND00_A_04#","ROOF_LGND_HUI"],
				["#ROOF_LGND00_A_05#","ROOF_LGND_ASMO"],
				["#ROOF_0X_A_BACK3#","ROOF_01"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Local legends - Operator HOPA*/
	[
		"ROOF_LGND_HOPA",	[
			Q_ONE,	"#ROOF_LGND_HOPA_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Local legends - Who's Bit... Rayman? Raymon?*/
	[
		"ROOF_LGND_BIT",	[
			Q_ONE,	"#ROOF_LGND_BIT_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Local legends - Can of RedBull?*/
	[
		"ROOF_LGND_BANKA",	[
			Q_ONE,	"#ROOF_LGND_BANKA_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Local legends - What was his name... Hui? Huy? Huiyui?*/
	[
		"ROOF_LGND_HUI",	[
			Q_ONE,	"#ROOF_LGND_HUI_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Local legends - Asmo*/
	[
		"ROOF_LGND_ASMO",	[
			Q_ONE,	"#ROOF_LGND_ASMO_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				["#ROOF_0X_A_BACK3#","ROOF_KNOW"],
				["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Rumors - selection*/
	[
		"ROOF_RUMR",	[
			Q_RNG,	[
				"#ROOF_RUMR_Q_01#",
				"#ROOF_RUMR_Q_02#",
				"#ROOF_RUMR_Q_03#",
				"#ROOF_RUMR_Q_04#",
				"#ROOF_RUMR_Q_05#",
				"#ROOF_RUMR_Q_06#",
				"#ROOF_RUMR_Q_07#",
				"#ROOF_RUMR_Q_08#",
				"#ROOF_RUMR_Q_09#",
				"#ROOF_RUMR_Q_10#"
			],
			A_CND,	[
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_RUMR_A_01#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_RUMR_A_02#","ROOF_KNOW"],
				{[1,5] call NWG_DLGHLP_Dice},["#ROOF_RUMR_A_03#","ROOF_KNOW"],
				{true},["#ROOF_RUMR_A_04#","ROOF_RUMR"],
				{true},["#AGEN_BACK_01#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
	[
		"ROOF_HELP",	[
			Q_RND,	[
				"#ROOF_HELP_Q_01#",
				"#ROOF_HELP_Q_02#",
				"#ROOF_HELP_Q_03#"
			],
			A_GEN,	{"ROOF" call NWG_DLGHLP_GenerateHelp}/*["ROOF_HELP_PLACE","ROOF_HELP_WHO","ROOF_HELP_TALK","ROOF_HELP_USERFLOW"]*/
		]
	],
	/*What should I know - What is this place*/
	[
		"ROOF_HELP_PLACE",	[
			Q_ONE,	"#ROOF_HELP_PLACE_Q_01#",
			A_GEN,	{["ROOF_HELP","ROOF_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["ROOF_HELP","ROOF_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who are you*/
	[
		"ROOF_HELP_WHO",	[
			Q_ONE,	"#ROOF_HELP_WHO_Q_01#",
			A_GEN,	{["ROOF_HELP","ROOF_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["ROOF_HELP","ROOF_01",NODE_EXIT]*/
		]
	],
	/*What should I know - Who should I talk to*/
	[
		"ROOF_HELP_TALK",	[
			Q_ONE,	"#ROOF_HELP_TALK_Q_01#",
			A_GEN,	{["ROOF_HELP","ROOF_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["ROOF_HELP","ROOF_01",NODE_EXIT]*/
		]
	],
	/*What should I know - How things are done here*/
	[
		"ROOF_HELP_USERFLOW",	[
			Q_ONE,	"#ROOF_HELP_USERFLOW_Q_01#",
			A_GEN,	{["ROOF_HELP","ROOF_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["ROOF_HELP","ROOF_01",NODE_EXIT]*/
		]
	],
	/*Any advice*/
	[
		"ROOF_ADV",	[
			Q_RNG,	[
				"#ROOF_ADV_Q_01#",
				"#ROOF_ADV_Q_02#",
				"#ROOF_ADV_Q_03#",
				"#ROOF_ADV_Q_04#"
			],
			A_GEN,	{"ROOF_01" call NWG_DLGHLP_GenerateBackExit}/*["ROOF_01",NODE_EXIT]*/
		]
	],

	["",""]
];
