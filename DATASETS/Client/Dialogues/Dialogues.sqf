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
	code - code to return answer string (e.g.: choosing answer string from a list of predefined answers for that node)
%NEXT_NODE%
	string - id of the next node
	NODE_BACK - get back to the previous node
	NODE_EXIT - end of dialogue, close UI
%CODE%	optional code to execute in order:
	- IF %NEXT_NODE% is NODE_EXIT - after closing the UI (serves as a callback)
	- IF %NEXT_NODE% is NODE_BACK or Defined Node - before loading the next node (e.g.: setting some variables that will affect the next node)
%CODE_ARGS%	optional arguments to pass to %CODE% (default: [])
%COLOR%	optional color to use for the answer in RGBA ([R,G,B,A]) format (default: [])

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

//Progress enum (see globalDefines.h)
#define P__EXP 0
#define P__LVL 1
#define P_TAXI 2
#define P_TRDR 3
#define P_COMM 4

//Colors
#define COLOR_GREEN [0,1,0,0.75]
#define COLOR_YELLOW [1,1,0,0.75]


NWG_DialogueTree = createHashMapFromArray [
	//================================================================================================================
	//================================================================================================================
	//Taxi
	/*Actual root of the dialogue*/
	[
		"TAXI_00",	[
			Q_CND,	[
				{call NWG_DLGHLP_IsNewPlayer},"#TAXI_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_03#",
				{true},"#TAXI_00_Q_04#"
			],
			A_GEN,	[
				{call NWG_DLG_TAXI_GenerateDropRoot},
				["#TAXI_00_A_02#","TAXI_PRGB",{},[],COLOR_YELLOW],
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
				{call NWG_DLG_TAXI_GenerateDropRoot},
				["#TAXI_00_A_02#","TAXI_PRGB",{},[],COLOR_YELLOW],
				{"TAXI" call NWG_DLGHLP_GenerateRoot}/*["TAXI_HELP","TAXI_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Drop me by - early*/
	[
		"TAXI_EARLY",	[
			Q_ONE,	"#TAXI_EARLY_Q_01#",
			A_GEN,	{"TAXI_01" call NWG_DLGHLP_GenerateBackExit}
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
	/*Drop me by - squad member unfit for drop by*/
	[
		"TAXI_SQD_UNFIT",	[
			Q_RND,	[
				"#TAXI_SQD_UNFIT_Q_01#",
				"#TAXI_SQD_UNFIT_Q_02#",
				"#TAXI_SQD_UNFIT_Q_03#"
			],
			A_DEF,	[[{call NWG_DLGHLP_GetRndBack},"TAXI_PS"]]
		]
	],
	/*Drop me by - payment*/
	[
		"TAXI_PAY",	[
			Q_ONE,	["#XXX_PAY_Q_01#",{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_MoneyStr}],
			A_CND,	[
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasEnoughMoney},[{call NWG_DLGHLP_GetRndPayY},NODE_EXIT,{call NWG_DLG_TAXI_Teleport}],
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasLessMoney},[{call NWG_DLGHLP_GetRndPayN},"TAXI_LOW"],
				{true},[{call NWG_DLGHLP_GetRndPayRefuse},"TAXI_CS"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				{true},[{call NWG_DLGHLP_GetRndBack},"TAXI_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Progress buy - selection*/
	[
		"TAXI_PRGB",	[
			Q_RND,	[
				"#TAXI_PRGB_Q_01#",
				"#TAXI_PRGB_Q_02#"
			],
			A_GEN,	[
				{["TAXI",true,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TAXI_PRGB_HOW_WORK","TAXI_PRGB_CUR_STAT","TAXI_PRGB_LETS_UPG"]*/
				{"TAXI_01" call NWG_DLGHLP_GenerateDoubtExit}  /*["TAXI_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - how does it work?*/
	[
		"TAXI_PRGB_HOW_WORK",	[
			Q_ONE,	"#TAXI_PRGB_HOW_WORK_Q_01#",
			A_GEN,	[
				{["TAXI",false,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TAXI_PRGB_HOW_WORK","TAXI_PRGB_CUR_STAT","TAXI_PRGB_LETS_UPG"]*/
				{"TAXI_01" call NWG_DLGHLP_GenerateBackExit}  /*["TAXI_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - current state?*/
	[
		"TAXI_PRGB_CUR_STAT",	[
			Q_ONE,	["#TAXI_PRGB_CUR_STAT_Q_01#",{P_TAXI call NWG_DLGHLP_PRGB_GetProgressStr},{P_TAXI call NWG_DLGHLP_PRGB_GetRemainingStr}],
			A_GEN,	[
				{["TAXI",true,false,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TAXI_PRGB_HOW_WORK","TAXI_PRGB_CUR_STAT","TAXI_PRGB_LETS_UPG"]*/
				{"TAXI_01" call NWG_DLGHLP_GenerateBackExit}  /*["TAXI_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - let's upgrade?*/
	[
		"TAXI_PRGB_LETS_UPG",	[
			Q_CND,	[
				{P_TAXI call NWG_DLGHLP_PRGB_LimitReached},"#TAXI_PRGB_LETS_UPG_Q_01#",
				{true},["#TAXI_PRGB_LETS_UPG_Q_02#",{P_TAXI call NWG_DLGHLP_PRGB_PricesStr}]
			],
			A_CND,	[
				{!(P_TAXI call NWG_DLGHLP_PRGB_LimitReached) && { (P_TAXI call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayY},"TAXI_PRGB_UPG",{P_TAXI call NWG_DLGHLP_PRGB_Upgrade}],
				{!(P_TAXI call NWG_DLGHLP_PRGB_LimitReached) && {!(P_TAXI call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayN},"TAXI_LOW"],
				{!(P_TAXI call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndPayRefuse},"TAXI_01"],
				{ (P_TAXI call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndBack},"TAXI_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Progress buy - not enough money*//*Not needed, reuse existing TAXI_LOW*/
	/*Progress buy - upgrade*/
	[
		"TAXI_PRGB_UPG",	[
			Q_ONE,	"#TAXI_PRGB_UPG_Q_01#",
			A_GEN,	{"TAXI_01" call NWG_DLGHLP_GenerateBackExit}/*["TAXI_01",NODE_EXIT]*/
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Mech
	/*Actual root of the dialogue*/
	[
		"MECH_00",	[
			Q_CND,	[
				{call NWG_DLGHLP_IsNewPlayer},"#MECH_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_03#",
				{[1,15] call NWG_DLGHLP_Dice},"#MECH_00_Q_04#",
				{true},"#MECH_00_Q_05#"
			],
			A_GEN,	[
				["#MECH_00_A_01#",NODE_EXIT,{call NWG_DLG_MECH_OpenShop}],
				["#MECH_00_A_02#",NODE_EXIT,{call NWG_DLG_MECH_OpenGarage}],
				{"MECH" call NWG_DLGHLP_QST_GenerateShowQuest},
				["#MECH_00_A_03#","MECH_SERV",{call NWG_DLG_MECH_GetVehPrices}],
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
				["#MECH_00_A_02#",NODE_EXIT,{call NWG_DLG_MECH_OpenGarage}],
				{"MECH" call NWG_DLGHLP_QST_GenerateShowQuest},
				["#MECH_00_A_03#","MECH_SERV",{call NWG_DLG_MECH_GetVehPrices}],
				{"MECH" call NWG_DLGHLP_GenerateRoot}/*["MECH_HELP","MECH_ADV",NODE_EXIT]*/
			]
		]
	],
	/*Services - category selection*/
	[
		"MECH_SERV",	[
			Q_RND,	[
				"#MECH_SERV_Q_01#",
				"#MECH_SERV_Q_02#",
				"#MECH_SERV_Q_03#"
			],
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
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
				{"MECH_SERV" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Services - payment*/
	[
		"MECH_PAY",	[
			Q_ONE,	["#XXX_PAY_Q_01#",{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_MoneyStr}],
			A_CND,	[
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasEnoughMoney && { (call NWG_DLG_MECH_SeparateUi)}},[{call NWG_DLGHLP_GetRndPayY},NODE_EXIT,{false call NWG_DLG_MECH_DoService}],
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasEnoughMoney && {!(call NWG_DLG_MECH_SeparateUi)}},[{call NWG_DLGHLP_GetRndPayY},"MECH_DONE",{true  call NWG_DLG_MECH_DoService}],
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasLessMoney},[{call NWG_DLGHLP_GetRndPayN},"MECH_LOW"],
				{true},[{call NWG_DLGHLP_GetRndPayRefuse},"MECH_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
	/*Services - done*/
	[
		"MECH_DONE",	[
			Q_CND,	[
				{[1,10] call NWG_DLGHLP_Dice},"#MECH_DONE_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_DONE_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_DONE_Q_03#",
				{true},"#MECH_DONE_Q_04#"
			],
			A_GEN,	{["MECH_SERV","MECH_01"] call NWG_DLGHLP_GenerateAnQBackExit}/*["MECH_SERV","MECH_01",NODE_EXIT]*/
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
				"#MECH_ADV_Q_04#",
				"#MECH_ADV_Q_05#",
				"#MECH_ADV_Q_06#"
			],
			A_GEN,	{"MECH_01" call NWG_DLGHLP_GenerateBackExit}/*["MECH_01",NODE_EXIT]*/
		]
	],
	/*Quest Display - display quest data*/
	[
		"MECH_QST_DISPLAY",	[
			Q_ONE,	["%1",{"MECH" call NWG_DLGHLP_QST_GenerateQuestDisplayQ}],
			A_GEN,	[
				{"MECH" call NWG_DLGHLP_QST_GenerateQuestDisplayA},
				{"MECH_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MECH_01",NODE_EXIT]*/
			]
		]
	],
	/*Quest Result*/
	[
		"MECH_QST_RESULT",	[
			Q_ONE,	["%1",{"MECH" call NWG_DLGHLP_QST_GenerateQuestResultQ}],
			A_GEN,	{"MECH_01" call NWG_DLGHLP_QST_GenerateQuestResultA}
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
				{call NWG_DLGHLP_IsNewPlayer},"#TRDR_00_Q_02#",
				{10  call NWG_DLGHLP_HasMoreMoneyStartSum},"#TRDR_00_Q_03#",
				{100 call NWG_DLGHLP_HasMoreMoneyStartSum},"#TRDR_00_Q_04#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_05#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_06#",
				{[1,4] call NWG_DLGHLP_Dice},"#TRDR_00_Q_07#",
				{true},"#TRDR_00_Q_08#"
			],
			A_CND,	[
				{true},["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],
				{"TRDR" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"TRDR_QST_DISPLAY",{},0,COLOR_GREEN],
				{true},["#TRDR_00_A_02#","TRDR_PRGB",{},[],COLOR_YELLOW],
				{true},["#AGEN_HELP_01#","TRDR_HELP"],
				{true},["#AGEN_ADV_01#","TRDR_ADV1"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
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
			A_CND,	[
				{true},["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],
				{"TRDR" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"TRDR_QST_DISPLAY",{},0,COLOR_GREEN],
				{true},["#TRDR_00_A_02#","TRDR_PRGB",{},[],COLOR_YELLOW],
				{true},["#AGEN_HELP_01#","TRDR_HELP"],
				{true},["#AGEN_ADV_01#","TRDR_ADV1"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
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
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasEnoughMoney},[{call NWG_DLGHLP_GetRndPayY},"TRDR_ADV2",{call NWG_DLG_TRDR_PayForAdvice}],
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasLessMoney},[{call NWG_DLGHLP_GetRndPayN},"TRDR_LOW"],
				{true},[{call NWG_DLGHLP_GetRndPayRefuse},"TRDR_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Any advice - Get advice*/
	[
		"TRDR_ADV2",	[
			Q_RNG,	[
				"#TRDR_ADV2_Q_01#",
				"#TRDR_ADV2_Q_02#",
				"#TRDR_ADV2_Q_03#",
				"#TRDR_ADV2_Q_04#"
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
	/*Progress buy - selection*/
	[
		"TRDR_PRGB",	[
			Q_RND,	[
				"#TRDR_PRGB_Q_01#",
				"#TRDR_PRGB_Q_02#"
			],
			A_GEN,	[
				{["TRDR",true,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TRDR_PRGB_HOW_WORK","TRDR_PRGB_CUR_STAT","TRDR_PRGB_LETS_UPG"]*/
				{"TRDR_01" call NWG_DLGHLP_GenerateDoubtExit}  /*["TRDR_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - how does it work?*/
	[
		"TRDR_PRGB_HOW_WORK",	[
			Q_ONE,	"#TRDR_PRGB_HOW_WORK_Q_01#",
			A_GEN,	[
				{["TRDR",false,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TRDR_PRGB_HOW_WORK","TRDR_PRGB_CUR_STAT","TRDR_PRGB_LETS_UPG"]*/
				{"TRDR_01" call NWG_DLGHLP_GenerateBackExit}  /*["TRDR_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - current state?*/
	[
		"TRDR_PRGB_CUR_STAT",	[
			Q_ONE,	["#TRDR_PRGB_CUR_STAT_Q_01#",{P_TRDR call NWG_DLGHLP_PRGB_GetProgressStr},{P_TRDR call NWG_DLGHLP_PRGB_GetRemainingStr}],
			A_GEN,	[
				{["TRDR",true,false,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["TRDR_PRGB_HOW_WORK","TRDR_PRGB_CUR_STAT","TRDR_PRGB_LETS_UPG"]*/
				{"TRDR_01" call NWG_DLGHLP_GenerateBackExit}  /*["TRDR_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - let's upgrade?*/
	[
		"TRDR_PRGB_LETS_UPG",	[
			Q_CND,	[
				{P_TRDR call NWG_DLGHLP_PRGB_LimitReached},"#TRDR_PRGB_LETS_UPG_Q_01#",
				{true},["#TRDR_PRGB_LETS_UPG_Q_02#",{P_TRDR call NWG_DLGHLP_PRGB_PricesStr}]
			],
			A_CND,	[
				{!(P_TRDR call NWG_DLGHLP_PRGB_LimitReached) && { (P_TRDR call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayY},"TRDR_PRGB_UPG",{P_TRDR call NWG_DLGHLP_PRGB_Upgrade}],
				{!(P_TRDR call NWG_DLGHLP_PRGB_LimitReached) && {!(P_TRDR call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayN},"TRDR_PRGB_LOW"],
				{!(P_TRDR call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndPayRefuse},"TRDR_01"],
				{ (P_TRDR call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndBack},"TRDR_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Progress buy - not enough money*/
	[
		"TRDR_PRGB_LOW",	[
			Q_ONE,	"#TRDR_PRGB_LOW_Q_01#",
			A_DEF,	[
				["#TRDR_PRGB_LOW_A_01#","TRDR_01"],
				["#TRDR_PRGB_LOW_A_02#",NODE_EXIT]
			]
		]
	],
	/*Progress buy - upgrade*/
	[
		"TRDR_PRGB_UPG",	[
			Q_ONE,	"#TRDR_PRGB_UPG_Q_01#",
			A_GEN,	{"TRDR_01" call NWG_DLGHLP_GenerateBackExit}/*["TRDR_01",NODE_EXIT]*/
		]
	],
	/*Quest Display - display quest data*/
	[
		"TRDR_QST_DISPLAY",	[
			Q_ONE,	["%1",{"TRDR" call NWG_DLGHLP_QST_GenerateQuestDisplayQ}],
			A_GEN,	[
				{"TRDR" call NWG_DLGHLP_QST_GenerateQuestDisplayA},
				{"TRDR_01" call NWG_DLGHLP_GenerateDoubtExit}/*["TRDR_01",NODE_EXIT]*/
			]
		]
	],
	/*Quest Result*/
	[
		"TRDR_QST_RESULT",	[
			Q_ONE,	["%1",{"TRDR" call NWG_DLGHLP_QST_GenerateQuestResultQ}],
			A_GEN,	{"TRDR_01" call NWG_DLGHLP_QST_GenerateQuestResultA}
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
				{"MEDC" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"MEDC_QST_DISPLAY",{},0,COLOR_GREEN],
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
				{"MEDC" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"MEDC_QST_DISPLAY",{},0,COLOR_GREEN],
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
				{call NWG_DLGHLP_IsNewPlayer},"#MEDC_PATCH_Q_01#",
				{!(call NWG_DLGHLP_IsNewPlayer)},["#MEDC_PATCH_Q_02#",{(call NWG_DLG_MEDC_GetPatchPrice) call NWG_DLGHLP_MoneyStr}]
			],
			A_CND,	[
				{call NWG_DLGHLP_IsNewPlayer},["#MEDC_PATCH_A_01#",NODE_EXIT,{true call NWG_DLG_MEDC_Patch}],
				{!(call NWG_DLGHLP_IsNewPlayer)},["#MEDC_PATCH_A_02#",NODE_EXIT,{false call NWG_DLG_MEDC_Patch}],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				"#MEDC_ADV_Q_03#",
				"#MEDC_ADV_Q_04#"
			],
			A_GEN,	{"MEDC_01" call NWG_DLGHLP_GenerateBackExit}/*["MEDC_01",NODE_EXIT]*/
		]
	],
	/*Quest Display - display quest data*/
	[
		"MEDC_QST_DISPLAY",	[
			Q_ONE,	["%1",{"MEDC" call NWG_DLGHLP_QST_GenerateQuestDisplayQ}],
			A_GEN,	[
				{"MEDC" call NWG_DLGHLP_QST_GenerateQuestDisplayA},
				{"MEDC_01" call NWG_DLGHLP_GenerateDoubtExit}/*["MEDC_01",NODE_EXIT]*/
			]
		]
	],
	/*Quest Result*/
	[
		"MEDC_QST_RESULT",	[
			Q_ONE,	["%1",{"MEDC" call NWG_DLGHLP_QST_GenerateQuestResultQ}],
			A_GEN,	{"MEDC_01" call NWG_DLGHLP_QST_GenerateQuestResultA}
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Comm (Commander)
	/*Actual root of the dialogue*/
	[
		"COMM_00",	[
			Q_CND,	[
				{call NWG_DLG_COMM_IsMissionStarted && {call NWG_DLG_COMM_IsAlone}},"#COMM_00_Q_01#",
				{call NWG_DLG_COMM_IsMissionStarted},"#COMM_00_Q_02#",
				{call NWG_DLGHLP_IsNewPlayer},"#COMM_00_Q_03#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_04#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_05#",
				{[1,4] call NWG_DLGHLP_Dice},"#COMM_00_Q_06#",
				{true},"#COMM_00_Q_07#"
			],
			A_CND,	[
				{call NWG_DLG_COMM_IsMissionReady},["#COMM_00_A_01#","COMM_LVL"],
				{call NWG_DLG_COMM_IsMissionStarted},["#COMM_00_A_02#",NODE_EXIT],
				{"COMM" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"COMM_QST_DISPLAY",{},0,COLOR_GREEN],
				{true},["#COMM_00_A_03#","COMM_PRGB",{},[],COLOR_YELLOW],
				{true},["#COMM_00_A_04#","COMM_HELP"],
				{true},["#COMM_00_A_05#","COMM_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
	[
		"COMM_01",	[
			Q_RND,	[
				"#COMM_00_Q_04#",
				"#COMM_00_Q_07#",
				"#XXX_01_Q_01#",
				"#MECH_01_Q_03#"
			],
			A_CND,	[
				{call NWG_DLG_COMM_IsMissionReady},["#COMM_00_A_01#","COMM_LVL"],
				{call NWG_DLG_COMM_IsMissionStarted},["#COMM_01_A_02#",NODE_EXIT],
				{"COMM" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"COMM_QST_DISPLAY",{},0,COLOR_GREEN],
				{true},["#COMM_00_A_03#","COMM_PRGB",{},[],COLOR_YELLOW],
				{true},["#COMM_00_A_04#","COMM_HELP"],
				{true},["#COMM_00_A_05#","COMM_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Level select*/
	[
		"COMM_LVL",	[
			Q_RND,	[
				"#COMM_LVL_Q_01#",
				"#COMM_LVL_Q_02#",
				"#COMM_LVL_Q_03#"
			],
			A_GEN,	[
				{call NWG_DLG_COMM_GenerateLevelSelect},
				["#COMM_LVLNLCK_EXPLAIN_A_01#","COMM_LVLNLCK_EXPLAIN"],
				["#COMM_LVL_A_02#","COMM_01"],
				["#COMM_LVL_A_03#",NODE_EXIT]
			]
		]
	],
	/*Level select - explanation*/
	[
		"COMM_LVLNLCK_EXPLAIN",	[
			Q_ONE,	"#COMM_LVLNLCK_EXPLAIN_Q_01#",
			A_GEN,	{"COMM_LVL" call NWG_DLGHLP_GenerateBackExit}
		]
	],
	/*Level select - Level Locked by player level requirements*/
	[
		"COMM_LVL_REQ_LOCKED",	[
			Q_RND,	[
				["#COMM_LVL_REQ_LOCKED_Q_01#",{call NWG_DLG_COMM_GetLevelReq}],
				["#COMM_LVL_REQ_LOCKED_Q_02#",{call NWG_DLG_COMM_GetLevelReq}]
			],
			A_GEN,	{"COMM_LVL" call NWG_DLGHLP_GenerateBackExit}
		]
	],
	/*Level select - Level unlock payment*/
	[
		"COMM_LVL_UNLOCK_PAY",	[
			Q_CND,	[
				{call NWG_DLG_COMM_IsGroupLeader},["#COMM_LVL_UNLOCK_Q_01#",{(call NWG_DLG_COMM_GetLevelUnlockPrice) call NWG_DLGHLP_MoneyStr}],
				{true},["#COMM_LVL_UNLOCK_Q_02#",{(call NWG_DLG_COMM_GetLevelUnlockPrice) call NWG_DLGHLP_MoneyStr}]
			],
			A_CND,	[
				{(call NWG_DLG_COMM_GetLevelUnlockPrice) call NWG_DLG_COMM_HasEnoughMoneyGroup},[{call NWG_DLGHLP_GetRndPayY},"COMM_LVL_UNLOCKED",{call NWG_DLG_COMM_UnlockLevel}],
				{(call NWG_DLG_COMM_GetLevelUnlockPrice) call NWG_DLG_COMM_HasLessMoneyGroup},[{call NWG_DLGHLP_GetRndPayN},"COMM_LVL"],
				{true},[{call NWG_DLGHLP_GetRndPayRefuse},"COMM_LVL"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Level select - Level unlocked*/
	[
		"COMM_LVL_UNLOCKED",	[
			Q_ONE,	"#COMM_LVL_UNLOCKED_Q_01#",
			A_GEN,	{"COMM_LVL" call NWG_DLGHLP_GenerateBackExit}
		]
	],
	/*Level select - Mission selection*/
	[
		"COMM_LVL_MISSION",	[
			Q_RND,	[
				"#COMM_LVL_MISSION_Q_01#",
				"#COMM_LVL_MISSION_Q_02#",
				"#COMM_LVL_MISSION_Q_03#"
			],
			A_DEF,	[
				["#COMM_LVL_A_01#",NODE_EXIT,{true call NWG_DLG_COMM_ShowMissionSelection}],
				["#COMM_LVL_A_02#","COMM_01"],
				["#COMM_LVL_A_03#",NODE_EXIT]
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
	/*Progress buy - selection*/
	[
		"COMM_PRGB",	[
			Q_RND,	[
				"#COMM_PRGB_Q_01#",
				"#COMM_PRGB_Q_02#"
			],
			A_GEN,	[
				{["COMM",true,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["COMM_PRGB_HOW_WORK","COMM_PRGB_CUR_STAT","COMM_PRGB_LETS_UPG"]*/
				{"COMM_01" call NWG_DLGHLP_GenerateDoubtExit}  /*["COMM_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - how does it work?*/
	[
		"COMM_PRGB_HOW_WORK",	[
			Q_ONE,	"#COMM_PRGB_HOW_WORK_Q_01#",
			A_GEN,	[
				{["COMM",false,true,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["COMM_PRGB_HOW_WORK","COMM_PRGB_CUR_STAT","COMM_PRGB_LETS_UPG"]*/
				{"COMM_01" call NWG_DLGHLP_GenerateBackExit}  /*["COMM_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - current state?*/
	[
		"COMM_PRGB_CUR_STAT",	[
			Q_ONE,	["#COMM_PRGB_CUR_STAT_Q_01#",{P_COMM call NWG_DLGHLP_PRGB_GetProgressStr},{P_COMM call NWG_DLGHLP_PRGB_GetRemainingStr}],
			A_GEN,	[
				{["COMM",true,false,true] call NWG_DLGHLP_PRGB_GeneratePrgbSel},/*["COMM_PRGB_HOW_WORK","COMM_PRGB_CUR_STAT","COMM_PRGB_LETS_UPG"]*/
				{"COMM_01" call NWG_DLGHLP_GenerateBackExit}  /*["COMM_01",NODE_EXIT]*/
			]
		]
	],
	/*Progress buy - let's upgrade?*/
	[
		"COMM_PRGB_LETS_UPG",	[
			Q_CND,	[
				{P_COMM call NWG_DLGHLP_PRGB_LimitReached},"#COMM_PRGB_LETS_UPG_Q_01#",
				{true},["#COMM_PRGB_LETS_UPG_Q_02#",{P_COMM call NWG_DLGHLP_PRGB_PricesStr}]
			],
			A_CND,	[
				{!(P_COMM call NWG_DLGHLP_PRGB_LimitReached) && { (P_COMM call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayY},"COMM_PRGB_UPG",{P_COMM call NWG_DLGHLP_PRGB_Upgrade}],
				{!(P_COMM call NWG_DLGHLP_PRGB_LimitReached) && {!(P_COMM call NWG_DLGHLP_PRGB_CanUpgrade)}},[{call NWG_DLGHLP_GetRndPayN},"COMM_PRGB_LOW"],
				{!(P_COMM call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndPayRefuse},"COMM_01"],
				{ (P_COMM call NWG_DLGHLP_PRGB_LimitReached)},[{call NWG_DLGHLP_GetRndBack},"COMM_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Progress buy - not enough money*/
	[
		"COMM_PRGB_LOW",	[
			Q_ONE,	"#COMM_PRGB_LOW_Q_01#",
			A_DEF,	[
				["#COMM_PRGB_LOW_A_01#","COMM_01"],
				["#COMM_PRGB_LOW_A_02#",NODE_EXIT]
			]
		]
	],
	/*Progress buy - upgrade*/
	[
		"COMM_PRGB_UPG",	[
			Q_ONE,	"#COMM_PRGB_UPG_Q_01#",
			A_GEN,	{"COMM_01" call NWG_DLGHLP_GenerateBackExit}/*["COMM_01",NODE_EXIT]*/
		]
	],
	/*Quest Display - display quest data*/
	[
		"COMM_QST_DISPLAY",	[
			Q_ONE,	["%1",{"COMM" call NWG_DLGHLP_QST_GenerateQuestDisplayQ}],
			A_GEN,	[
				{"COMM" call NWG_DLGHLP_QST_GenerateQuestDisplayA},
				{"COMM_01" call NWG_DLGHLP_GenerateDoubtExit}/*["COMM_01",NODE_EXIT]*/
			]
		]
	],
	/*Quest Result*/
	[
		"COMM_QST_RESULT",	[
			Q_ONE,	["%1",{"COMM" call NWG_DLGHLP_QST_GenerateQuestResultQ}],
			A_GEN,	{"COMM_01" call NWG_DLGHLP_QST_GenerateQuestResultA}
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Roof
	/*Actual root of the dialogue*/
	[
		"ROOF_00",	[
			Q_CND,	[
				{call NWG_DLGHLP_IsNewPlayer},"#ROOF_00_Q_01#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_02#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_03#",
				{[1,4] call NWG_DLGHLP_Dice},"#ROOF_00_Q_04#",
				{true},"#ROOF_00_Q_05#"
			],
			A_CND,	[
				{true},["#ROOF_00_A_00#","ROOF_TS"],
				{"ROOF" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"ROOF_QST_DISPLAY",{},0,COLOR_GREEN],
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
				{"ROOF" call NWG_DLGHLP_QST_ShowQuest},[{call NWG_DLGHLP_GetRndQuestOpen},"ROOF_QST_DISPLAY",{},0,COLOR_GREEN],
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
				{(call NWG_DLG_ROOF_GetPrice) call NWG_DLGHLP_HasEnoughMoney},[{call NWG_DLGHLP_GetRndPayY},NODE_EXIT,{call NWG_DLG_ROOF_DoReflash}],
				{(call NWG_DLG_ROOF_GetPrice) call NWG_DLGHLP_HasLessMoney},[{call NWG_DLGHLP_GetRndPayN},"ROOF_LOW"],
				{true},[{call NWG_DLGHLP_GetRndPayRefuse},"ROOF_01"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				[{call NWG_DLGHLP_GetRndBack},"ROOF_01"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				[{call NWG_DLGHLP_GetRndBack},"ROOF_01"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				{true},[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				{true},[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				[{call NWG_DLGHLP_GetRndBack},"ROOF_01"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				[{call NWG_DLGHLP_GetRndBack},"ROOF_01"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Local legends - Operator HOPA*/
	[
		"ROOF_LGND_HOPA",	[
			Q_ONE,	"#ROOF_LGND_HOPA_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Local legends - Who's Bit... Rayman? Raymon?*/
	[
		"ROOF_LGND_BIT",	[
			Q_ONE,	"#ROOF_LGND_BIT_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Local legends - Can of RedBull?*/
	[
		"ROOF_LGND_BANKA",	[
			Q_ONE,	"#ROOF_LGND_BANKA_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Local legends - What was his name... Hui? Huy? Huiyui?*/
	[
		"ROOF_LGND_HUI",	[
			Q_ONE,	"#ROOF_LGND_HUI_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
			]
		]
	],
	/*Local legends - Asmo*/
	[
		"ROOF_LGND_ASMO",	[
			Q_ONE,	"#ROOF_LGND_ASMO_Q_01#",
			A_DEF,	[
				["#ROOF_LGND_A_01#","ROOF_LGND01"],
				[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
				{true},[{call NWG_DLGHLP_GetRndBack},"ROOF_KNOW"],
				{true},[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]
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
	/*Quest Display - display quest data*/
	[
		"ROOF_QST_DISPLAY",	[
			Q_ONE,	["%1",{"ROOF" call NWG_DLGHLP_QST_GenerateQuestDisplayQ}],
			A_GEN,	[
				{"ROOF" call NWG_DLGHLP_QST_GenerateQuestDisplayA},
				{"ROOF_01" call NWG_DLGHLP_GenerateDoubtExit}/*["ROOF_01",NODE_EXIT]*/
			]
		]
	],
	/*Quest Result*/
	[
		"ROOF_QST_RESULT",	[
			Q_ONE,	["%1",{"ROOF" call NWG_DLGHLP_QST_GenerateQuestResultQ}],
			A_GEN,	{"ROOF_01" call NWG_DLGHLP_QST_GenerateQuestResultA}
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Tutorial
	/*Step 01 - Taxi*/
	[
		"TAXI_TUTOR01_00",	[
			Q_ONE,	"#TAXI_TUTOR01_00_Q#",/*New faces, you here for a job?*/
			A_DEF,	[
				["#TAXI_TUTOR01_00_A_01#","TAXI_TUTOR01_01v1"],/*Yes*/
				["#TAXI_TUTOR01_00_A_02#","TAXI_TUTOR01_01v1"],/*I'm here for fun*/
				["#TAXI_TUTOR01_00_A_03#","TAXI_TUTOR01_01v2"],/*I guess so?*/
				["#TAXI_TUTOR01_00_A_04#","TAXI_TUTOR01_01v2"] /*I don't even know where I am*/
			]
		]
	],
	[
		"TAXI_TUTOR01_01v1",	[
			Q_ONE,	"#TAXI_TUTOR01_01v1_Q#",/*That's the spirit! Commander busy, go to Trader*/
			A_DEF,	[
				["#ALL_TUTOR_JOB_A#","TAXI_TUTOR01_02"],/*So what's the job?*/
				["#TAXI_TUTOR01_01_A_02#",NODE_EXIT,{call NWG_TUT_NextStep}]/*Yeah, thanks*/
			]
		]
	],
	[
		"TAXI_TUTOR01_01v2",	[
			Q_ONE,	"#TAXI_TUTOR01_01v2_Q#",/*Guess so? You lost or something? Go to Trader*/
			A_DEF,	[
				["#ALL_TUTOR_JOB_A#","TAXI_TUTOR01_02"],/*So what's the job?*/
				["#TAXI_TUTOR01_01_A_02#",NODE_EXIT,{call NWG_TUT_NextStep}]/*Yeah, thanks*/
			]
		]
	],
	[
		"TAXI_TUTOR01_02",	[
			Q_ONE,	"#TAXI_TUTOR01_02_Q#",/*Getting rich. Go to Trader*/
			A_DEF,	[
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT,{call NWG_TUT_NextStep}]/*Yeah, thanks*/
			]
		]
	],
	[
		"MECH_TUTOR01_00",	[
			Q_ONE,	"#MECH_TUTOR01_00_Q#",/*Go talk to Taxi*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"TRDR_TUTOR01_00",	[
			Q_ONE,	"#TRDR_TUTOR01_00_Q#",/*Go talk to Taxi*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MEDC_TUTOR01_00",	[
			Q_ONE,	"#MEDC_TUTOR01_00_Q#",/*Go talk to Taxi*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"COMM_TUTOR01_00",	[
			Q_ONE,	"#COMM_TUTOR01_00_Q#",/*Go talk to Taxi*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"ROOF_TUTOR01_00",	[
			Q_ONE,	"#ROOF_TUTOR_Q#",/*Do I know you?*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]]/*Ok, bye*/
		]
	],
	/*Step 02 - Trader*/
	[
		"TAXI_TUTOR02_00",	[
			Q_ONE,	"#TAXI_TUTOR02_00_Q#",/*Go talk to Trader*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MECH_TUTOR02_00",	[
			Q_ONE,	"#MECH_TUTOR02_00_Q#",/*Go talk to Trader*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"TRDR_TUTOR02_00",	[
			Q_ONE,	"#TRDR_TUTOR02_00_Q#",/*A new customer. What? Is the commander busy?*/
			A_DEF,	[
				["#TRDR_TUTOR02_00_A_01#","TRDR_TUTOR02_01"]/*I need a gun*/
			]
		]
	],
	[
		"TRDR_TUTOR02_01",	[
			Q_ONE,	"#TRDR_TUTOR02_01_Q#",/*Of course you are. Did anyone tell you how to earn money?*/
			A_DEF,	[
				["#TRDR_TUTOR02_01_A_01#","TRDR_TUTOR02_02v1"],/*No. How?*/
				["#TRDR_TUTOR02_01_A_02#","TRDR_TUTOR02_02v2"] /*Don't care*/
			]
		]
	],
	[
		"TRDR_TUTOR02_02v1",	[
			Q_ONE,	["%1",{call NWG_TUTDLG_TRDR_DisplayTutorial}],/*Those are the basics. The rest you'll figure out yourself. Now buy and go to storage*/
			A_DEF,	[
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT,{call NWG_TUTDLG_TRDR_OpenItemsShop}],/*Open shop*/
				["#ALL_TUTOR_JOB_A#","TRDR_TUTOR02_03"]
			]
		]
	],
	[
		"TRDR_TUTOR02_02v2",	[
			Q_ONE,	"#TRDR_TUTOR02_02v2_Q#",/*Less talking more shooting? Fine by me, less time wasted*/
			A_DEF,	[
				["Ok",NODE_EXIT,{call NWG_TUTDLG_TRDR_OpenItemsShop}]/*Open shop*/
			]
		]
	],
	[
		"TRDR_TUTOR02_03",	[
			Q_ONE,	"#TRDR_TUTOR02_03_Q#",/*Black market*/
			A_DEF,	[
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT,{call NWG_TUTDLG_TRDR_OpenItemsShop}]/*Open shop*/
			]
		]
	],
	[
		"MEDC_TUTOR02_00",	[
			Q_ONE,	"#MEDC_TUTOR02_00_Q#",//*Go talk to Trader*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"COMM_TUTOR02_00",	[
			Q_ONE,	"#COMM_TUTOR02_00_Q#",/*Go talk to Trader*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"ROOF_TUTOR02_00",	[
			Q_ONE,	"#ROOF_TUTOR_Q#",/*Do I know you?*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]]/*Ok, bye*/
		]
	],
	/*Step 03 - Storage*/
	[
		"TAXI_TUTOR03_00",	[
			Q_ONE,	"#TAXI_TUTOR03_00_Q#",/*Go to Storage*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MECH_TUTOR03_00",	[
			Q_ONE,	"#MECH_TUTOR03_00_Q#",/*Go to Storage*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"TRDR_TUTOR03_00",	[
			Q_ONE,	"#TRDR_TUTOR03_00_Q#",/*Go to Storage*/
			A_DEF, [
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],/*Open shop*/
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"MEDC_TUTOR03_00",	[
			Q_ONE,	"#MEDC_TUTOR03_00_Q#",/*Go to Storage*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"COMM_TUTOR03_00",	[
			Q_ONE,	"#COMM_TUTOR03_00_Q#",/*Go to Storage*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"ROOF_TUTOR03_00",	[
			Q_ONE,	"#ROOF_TUTOR_Q#",/*Do I know you?*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]]/*Ok, bye*/
		]
	],
	/*Step 04 - Commander*/
	[
		"TAXI_TUTOR04_00",	[
			Q_ONE,	"#TAXI_TUTOR04_00_Q#",/*Go to Commander*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MECH_TUTOR04_00",	[
			Q_ONE,	"#MECH_TUTOR04_00_Q#",/*Go to Commander*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"TRDR_TUTOR04_00",	[
			Q_ONE,	"#TRDR_TUTOR04_00_Q#",/*Go to Commander*/
			A_DEF, [
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],/*Open shop*/
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"MEDC_TUTOR04_00",	[
			Q_ONE,	"#MEDC_TUTOR04_00_Q#",/*Go to Commander*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"COMM_TUTOR04_00",	[
			Q_ONE,	["#COMM_TUTOR04_00_Q#",{name player}],/*Silence in radio. You up for the job?*/
			A_DEF,	[
				["#COMM_TUTOR04_00_A_01#","COMM_TUTOR04_02"],/*Yeah, sure*/
				["#ALL_TUTOR_JOB_A#","COMM_TUTOR04_01"]/*What's the job?*/
			]
		]
	],
	[
		"COMM_TUTOR04_01",	[
			Q_ONE,	"#COMM_TUTOR04_01_Q#",/*Explains the job*/
			A_DEF,	[
				[{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_02"],/*Ok, got it*/
				["#COMM_TUTOR04_01_A_02#","COMM_TUTOR04_015"]/*Wait, really?*/
			]
		]
	],
	[
		"COMM_TUTOR04_015",	[
			Q_ONE,	"#COMM_TUTOR04_015_Q#",/*Need to keep troops motivated*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_02"]]/*Ok, got it*/
		]
	],
	[
		"COMM_TUTOR04_02",	[
			Q_ONE,	"#COMM_TUTOR04_02_Q#",/*Press 'F3' to open your tablet*/
			A_DEF, [["#COMM_TUTOR04_02_A_01#","COMM_TUTOR04_03"]]/*Done*/
		]
	],
	[
		"COMM_TUTOR04_03",	[
			Q_ONE,	"#COMM_TUTOR04_03_Q#",/*Any questions?*/
			A_DEF, [
				["#COMM_TUTOR04_03_A_01#","COMM_TUTOR04_04v1"],/*How things are done here?*/
				["#COMM_TUTOR04_03_A_02#","COMM_TUTOR04_04v2"],/*No questions*/
				["#COMM_TUTOR04_03_A_03#","COMM_TUTOR04_04v3"]/*How much longer this will take? I'm here to shoot*/
			]
		]
	],
	[
		"COMM_TUTOR04_04v1",	[
			Q_ONE,	"#COMM_HELP_USERFLOW_Q_01#",/*Explains things*/
			A_CND,	[
				{call NWG_TUTDLG_COMM_IsReadyState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v1"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsFightState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v2"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsInvalidState},["#COMM_TUTOR04_04_A_03#","COMM_TUTOR04_05v3",{call NWG_TUTDLG_COMM_WarnDeveloper}]/*Is something wrong?*/
			]
		]
	],
	[
		"COMM_TUTOR04_04v2",	[
			Q_ONE,	"#COMM_TUTOR04_04v2_Q#",/*Are you sure?*/
			A_CND,	[
				{call NWG_TUTDLG_COMM_IsReadyState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v1"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsFightState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v2"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsInvalidState},["#COMM_TUTOR04_04_A_03#","COMM_TUTOR04_05v3",{call NWG_TUTDLG_COMM_WarnDeveloper}]/*Is something wrong?*/
			]
		]
	],
	[
		"COMM_TUTOR04_04v3",	[
			Q_ONE,	"#COMM_TUTOR04_04v3_Q#",/*Regrets life choices*/
			A_CND,	[
				{call NWG_TUTDLG_COMM_IsReadyState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v1"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsFightState},  [{call NWG_DLGHLP_GetRndBack},"COMM_TUTOR04_05v2"],/*Ok, got it*/
				{call NWG_TUTDLG_COMM_IsInvalidState},["#COMM_TUTOR04_04_A_03#","COMM_TUTOR04_05v3",{call NWG_TUTDLG_COMM_WarnDeveloper}]/*Is something wrong?*/
			]
		]
	],
	[
		"COMM_TUTOR04_05v1",	[
			Q_ONE,	"#COMM_TUTOR04_05v1_Q#",/*Let's select a mission*/
			A_CND,	[
				{call NWG_TUTDLG_COMM_LevelUnlocked},["#COMM_TUTOR04_05v1_A_01#",NODE_EXIT,{call NWG_TUTDLG_COMM_OpenMissionSelect}],
				{!(call NWG_TUTDLG_COMM_LevelUnlocked)},[["#COMM_TUTOR04_05v1_A_02#",{call NWG_TUTDLG_COMM_GetLevelUnlockPrice}],NODE_EXIT,{call NWG_TUTDLG_COMM_OpenMissionSelect}]
			]
		]
	],
	[
		"COMM_TUTOR04_05v2",	[
			Q_ONE,	"#COMM_TUTOR04_05v2_Q#",/*The mission is ready*/
			A_DEF,	[["#COMM_TUTOR04_05v2_A_01#",NODE_EXIT,{call NWG_TUT_NextStep}]]/*On my way*/
		]
	],
	[
		"COMM_TUTOR04_05v3",	[
			Q_ONE,	"#COMM_TUTOR04_05v3_Q#",/*Mission is broken, let's try again*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, got it*/
		]
	],
	[
		"ROOF_TUTOR04_00",	[
			Q_ONE,	"#ROOF_TUTOR_Q#",/*Do I know you?*/
			A_DEF,	[[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]]/*Ok, bye*/
		]
	],
	/*Step 05 - Taxi*/
	[
		"TAXI_TUTOR05_00",	[
			Q_CND,	[
				{call NWG_TUTDLG_TAXI_IsVotingState},"#TAXI_TUTOR05_00_Q0#",/*You have to vote first*/
				{!(call NWG_TUTDLG_COMM_IsFightState)},"#TAXI_TUTOR05_00_Q1#",/*Hold on, mission did not start yet*/
				{true},"#TAXI_TUTOR05_00_Q2#"/*So? Are you ready for your first one?*/
			],
			A_CND, [
				{call NWG_TUTDLG_COMM_IsFightState},["#TAXI_TUTOR05_00_A_01#","TAXI_TUTOR05_01"],/*All set*/
				{call NWG_TUTDLG_COMM_IsFightState},["#TAXI_TUTOR05_00_A_02#",NODE_EXIT],/*No, something else first*/
				{!(call NWG_TUTDLG_COMM_IsFightState)},[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]
			]
		]
	],
	[
		"TAXI_TUTOR05_01",	[
			Q_ONE,	"#TAXI_TUTOR05_01_Q#",/*Before we go. Discord?*/
			A_DEF,	[
				["#TAXI_TUTOR05_01_A_01#","TAXI_TUTOR05_02",{call NWG_TUTDLG_TAXI_OpenDiscord}],/*Yes*/
				["#TAXI_TUTOR05_01_A_02#","TAXI_TUTOR05_02",{call NWG_TUTDLG_TAXI_OpenDiscord}],/*Why not*/
				["#TAXI_TUTOR05_01_A_03#","TAXI_TUTOR05_03"]/*No, thanks*/
			]
		]
	],
	[
		"TAXI_TUTOR05_02",	[
			Q_ONE,	"#TAXI_TUTOR05_02_Q#",/*Discord*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},"TAXI_TUTOR05_03"]]/*Ok, got it*/
		]
	],
	[
		"TAXI_TUTOR05_03",	[
			Q_ONE,	"#TAXI_TUTOR05_03_Q#",/*So? Where to?*/
			A_DEF, [
				["#TAXI_TUTOR05_03_A_01#","TAXI_TUTOR05_04"]/*Paradrop on the house*/
			]
		]
	],
	[
		"TAXI_TUTOR05_04",	[
			Q_ONE,	"#TAXI_TUTOR05_04_Q#",/*Paradrop on the house? How about you pay?*/
			A_CND, [
				{true},["#TAXI_TUTOR05_04_A_01#","TAXI_TUTOR05_05"],/*On the house*/
				{call NWG_TUTDLG_TAXI_HasMoneyForPara},[["#TAXI_TUTOR05_04_A_02#",{call NWG_TUTDLG_TAXI_GetParaPriceStr}],"TAXI_TUTOR05_05",{call NWG_TUTDLG_TAXI_PayForPara}],/*Ok, I'll pay*/
				{call NWG_TUTDLG_TAXI_HasMoneyForPara},[["#TAXI_TUTOR05_04_A_03#",{call NWG_TUTDLG_TAXI_GetTipPriceStr}],"TAXI_TUTOR05_05",{call NWG_TUTDLG_TAXI_PayTip}]/*Have a tip*/
			]
		]
	],
	[
		"TAXI_TUTOR05_05",	[
			Q_ONE,	"#TAXI_TUTOR05_05_Q#",/*You're the boss. Ready?*/
			A_DEF, [["#TAXI_TUTOR05_05_A_01#",NODE_EXIT,{call NWG_TUTDLG_TAXI_Paradrop}]]/*Yeah, let's go!*/
		]
	],
	[
		"MECH_TUTOR05_00",	[
			Q_ONE,	"#MECH_TUTOR05_00_Q#",/*Go to Taxi*/
			A_GEN, [
				{"MECH" call NWG_DLGHLP_QST_GenerateShowQuest},
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"TRDR_TUTOR05_00",	[
			Q_ONE,	"#TRDR_TUTOR05_00_Q#",/*Go to Taxi*/
			A_GEN, [
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],/*Open shop*/
				{"TRDR" call NWG_DLGHLP_QST_GenerateShowQuest},
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"MEDC_TUTOR05_00",	[
			Q_ONE,	"#MEDC_TUTOR05_00_Q#",/*Go to Taxi*/
			A_GEN, [
				{"MEDC" call NWG_DLGHLP_QST_GenerateShowQuest},
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"COMM_TUTOR05_00",	[
			Q_ONE,	"#COMM_TUTOR05_00_Q#",/*Go to Taxi*/
			A_GEN, [
				{"COMM" call NWG_DLGHLP_QST_GenerateShowQuest},
				[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]/*Ok, bye*/
			]
		]
	],
	[
		"ROOF_TUTOR05_00",	[
			Q_ONE,	"#ROOF_TUTOR_Q#",/*Do I know you?*/
			A_GEN, [
				{"ROOF" call NWG_DLGHLP_QST_GenerateShowQuest},
				[{call NWG_DLGHLP_GetRndExit},NODE_EXIT]/*Ok, bye*/
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Escape
	[
		"TAXI_ESCAPE_00",	[
			Q_ONE,	"#TAXI_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MECH_ESCAPE_00",	[
			Q_ONE,	"#MECH_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"TRDR_ESCAPE_00",	[
			Q_ONE,	"#TRDR_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"MEDC_ESCAPE_00",	[
			Q_ONE,	"#MEDC_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"COMM_ESCAPE_00",	[
			Q_ONE,	"#COMM_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],
	[
		"ROOF_ESCAPE_00",	[
			Q_ONE,	"#ROOF_ESCAPE_00_Q#",/*I'm not dying here!*/
			A_DEF, [[{call NWG_DLGHLP_GetRndBack},NODE_EXIT]]/*Ok, bye*/
		]
	],

	["",""]
];
