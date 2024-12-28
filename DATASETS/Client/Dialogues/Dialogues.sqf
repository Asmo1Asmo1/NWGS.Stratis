/*
Dialogue records:
In the format QnA
Q	Q_ONE	Single question
	Q_RND	Array of questions to select from randomly
	Q_CND	Array of [{condition},question,...] - whichever returns 'true' first - (_i+1) question will be displayed
Each question may be of type
	string - single localization key
	array - format ["template",{code to return arg},...]

A	A_DEF	Predefined array of answers
	A_CND	Array of [{condition},answer,...] - whichever condition returns 'true' - (_i+1) will be added to list of answers
	A_GEN	Code that will generate array of answers (also supported to have [CODE,DEF_ANSER1,DEF_ANSER2,...] to generate answers in addition to predefined ones)
Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
%ANSWER_STR%	string - single localization key
	array - format ["template",{code to return arg},...]
%NEXT_NODE%	string - id of the next node
	"" - end of dialogue, close UI
%CODE%	optional code to execute AFTER selecting the next node or closing the UI

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
#define Q_CND 2

#define A_DEF 0
#define A_CND 1
#define A_GEN 2

#define NODE_BACK -1
#define NODE_EXIT -2


NWG_DialogueTree = createHashMapFromArray [
	//================================================================================================================
	//Taxi
	/*Actual root of the dialogue*/
/*
TAXI_00	Q_CND	$<1000	"Always good to see new faces"
		rand	"How's it going, boss?"
		rand	"Need a ride?"
		{true}	"Hey, what's up?"
	A_DEF		"Drop me by..."			TAXI_CS
			"What should I know?"			TAXI_HELP
			"Any advice?"			TAXI_ADV
*/
	[
		"TAXI_00",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#TAXI_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#TAXI_00_Q_03#",
				{true},"#TAXI_00_Q_04#"
			],
			A_DEF,	[
				["#TAXI_00_A_01#","TAXI_CS"],
				["#TAXI_00_A_02#","TAXI_HELP"],
				["#TAXI_00_A_03#","TAXI_ADV"]
			]
		]
	],
	/*Pseudo root for getting back in dialogue (uses same answers as TAXI_00)*/
/*
TAXI_01	Q_RND		"Anything else?"
			"Yeah, what?"
	A_DEF		"Drop me by..."			TAXI_CS
			"What should I know?"			TAXI_HELP
			"Any advice?"			TAXI_ADV
*/
	[
		"TAXI_01",	[
			Q_RND,	[
				"#TAXI_01_Q_01#",
				"#TAXI_01_Q_02#"
			],
			A_DEF,	[
				["#TAXI_00_A_01#","TAXI_CS"],
				["#TAXI_00_A_02#","TAXI_HELP"],
				["#TAXI_00_A_03#","TAXI_ADV"]
			]
		]
	],
	/*Drop me by - category selection*/
/*
TAXI_CS	Q_RND		"Where to, boss?"
			"Sure thing, boss|Where do you need to?"
			"Okay, where to?"
	A_GEN		{call XXX}			TAXI_PS
			"No, actually..."			TAXI_01
			"Never mind, bye"			NODE_EXIT
*/
	[
		"TAXI_CS",	[
			Q_RND,	[
				"#TAXI_CS_Q_01#",
				"#TAXI_CS_Q_02#",
				"#TAXI_CS_Q_03#"
			],
			A_GEN,	[
				{call NWG_DLG_TAXI_GenerateDropCategories},
				["#TAXI_0X_A_BACK1#","TAXI_01"],
				["#TAXI_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Drop me by - point selection*/
/*
TAXI_PS	Q_ONE		"Which one?"
	A_GEN		{call XXX}			TAXI_PAY
			"I've changed my mind"			TAXI_CS
			"Never mind, bye"			NODE_EXIT
*/
	[
		"TAXI_PS",	[
			Q_ONE,	"#TAXI_PS_Q_01#",
			A_GEN,	[
				{call NWG_DLG_TAXI_GenerateDropPoints},
				["#TAXI_0X_A_BACK2#","TAXI_CS"],
				["#TAXI_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Drop me by - payment*/
/*
TAXI_PAY	Q_ONE		"That would be {X}"
	A_CND	$>=X	"Here you go"			{close dialogue, deplete cash, teleport player}
		$<X	"Sorry, I don't have that"			TAXI_LOW
		{true}	"I've changed my mind"			TAXI_CS
		{true}	"Never mind, bye"			NODE_EXIT
*/
	[
		"TAXI_PAY",	[
			Q_ONE,	["#TAXI_PAY_Q_01#",{call NWG_DLG_TAXI_GetPriceStr}],
			A_CND,	[
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasEnoughMoney},["#TAXI_PAY_A_01#",NODE_EXIT,{call NWG_DLG_TAXI_Teleport}],
				{(call NWG_DLG_TAXI_GetPrice) call NWG_DLGHLP_HasLessMoney},["#TAXI_PAY_A_02#","TAXI_LOW"],
				{true},["#TAXI_0X_A_BACK2#","TAXI_CS"],
				{true},["#TAXI_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Drop me by - not enough money*/
/*
TAXI_LOW	Q_RND		"That' a shame, boss"
			"Come back when you have it, boss"
			"Low on cash, boss? Try selling some stuff"
	A_DEF		"You're right"			TAXI_01
			"See you later"			NODE_EXIT
*/
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
/*
TAXI_HELP	Q_RND		"Specific or in general?"
			"What would you like to know?"
			"A lot of things|But is there anything specific?"
			"Shoot the question, boss"
	A_DEF		"What is this place?"			TAXI_HELP_PLACE
			"Who are you?"			TAXI_HELP_WHO
			"Who should I talk to?"			TAXI_HELP_TALK
			"How things are done here?"			TAXI_HELP_USERFLOW
*/
	[
		"TAXI_HELP",	[
			Q_RND,	[
				"#TAXI_HELP_Q_01#",
				"#TAXI_HELP_Q_02#",
				"#TAXI_HELP_Q_03#",
				"#TAXI_HELP_Q_04#"
			],
			A_DEF,	[
				["#XXX_HELP_A_01#","TAXI_HELP_PLACE"],
				["#XXX_HELP_A_02#","TAXI_HELP_WHO"],
				["#XXX_HELP_A_03#","TAXI_HELP_TALK"],
				["#XXX_HELP_A_04#","TAXI_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
TAXI_HELP_PLACE	Q_ONE		"Taxi driver describes the place the way he sees it..."
	A_DEF		"Another question"			TAXI_HELP
			"Got it"			TAXI_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TAXI_HELP_PLACE",	[
			Q_ONE,	"#TAXI_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_05#","TAXI_HELP"],
				["#XXX_HELP_A_06#","TAXI_01"],
				["#XXX_HELP_A_07#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
TAXI_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			TAXI_HELP
			"Got it"			TAXI_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TAXI_HELP_WHO",	[
			Q_ONE,	"#TAXI_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_05#","TAXI_HELP"],
				["#XXX_HELP_A_06#","TAXI_01"],
				["#XXX_HELP_A_07#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
TAXI_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			TAXI_HELP
			"Got it"			TAXI_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TAXI_HELP_TALK",	[
			Q_ONE,	"#TAXI_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_05#","TAXI_HELP"],
				["#XXX_HELP_A_06#","TAXI_01"],
				["#XXX_HELP_A_07#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
TAXI_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			TAXI_HELP
			"Got it"			TAXI_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TAXI_HELP_USERFLOW",	[
			Q_ONE,	"#TAXI_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_05#","TAXI_HELP"],
				["#XXX_HELP_A_06#","TAXI_01"],
				["#XXX_HELP_A_07#",NODE_EXIT]
			]
		]
	],
	/*Any advice*/
/*
TAXI_ADV	Q_RND		"Alyways plan your exit route|As much as I like doing my job and getting my cut|As much I want my customers to become regulars|You know what I mean?"
			"Don't rush into the fight|If you want me drop you near you squad|Ask them first if it is safe"
			"Always tip your driver|That would be me"
	A_CND	rand	"That is a good wisdom"			TAXI_01
		{true}	"Got it"			TAXI_01
		{true}	"Thanks, bye"			NODE_EXIT
*/
	[
		"TAXI_ADV",	[
			Q_RND,	[
				"#TAXI_ADV_Q_01#",
				"#TAXI_ADV_Q_02#",
				"#TAXI_ADV_Q_03#"
			],
			A_CND,	[
				{[1,10] call NWG_DLGHLP_Dice},["#TAXI_ADV_A_01#","TAXI_01"],
				{true},["#XXX_HELP_A_06#","TAXI_01"],
				{true},["#XXX_HELP_A_07#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//Test
	/*Test00 - "Choose what to test"*/
	[
		"TEST_00",	[
		Q_ONE,	"#TEST_00_Q#",
		A_DEF,	[
			["#TEST_00_A_01#","TEST_01"],
			["#TEST_00_A_02#","TEST_02"],
			["#TEST_00_A_03#","TEST_03"],
			["#TEST_00_A_04#","TEST_04"],
			["#TEST_00_A_05#","TEST_05"],
			["#TEST_00_A_06#","TEST_06"],
			["#TEST_00_A_07#","TEST_07"],
			["#TEST_00_A_08#","TEST_08"]
		]
	]],
	/*Test01 - "Single question"*/
	[
		"TEST_01",	[
		Q_ONE,	"#TEST_01_Q#",
		A_DEF,	[
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test02 - "Random questions"*/
	[
		"TEST_02",	[
		Q_RND,	[
			"#TEST_02_Q_01#",
			"#TEST_02_Q_02#",
			"#TEST_02_Q_03#"
		],
		A_DEF,	[
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test03 - "Conditioned questions"*/
	[
		"TEST_03",	[
		Q_CND,	[
			{(player call NWG_fnc_wltGetPlayerMoney) <= 1000},"#TEST_03_Q_01#",
			{(player call NWG_fnc_wltGetPlayerMoney) > 1000},"#TEST_03_Q_02#"
		],
		A_DEF,	[
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test04 - "Predefined answers"*/
	[
		"TEST_04",	[
		Q_RND,	[
			"#TEST_04_Q_01#",
			"#TEST_04_Q_02#"
		],
		A_DEF,	[
			["#TEST_0X_A_AGAIN#","TEST_04"],
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test05 - "Conditioned answers"*/
	[
		"TEST_05",	[
		Q_ONE,	"#TEST_05_Q#",
		A_CND,	[
			{(player call NWG_fnc_wltGetPlayerMoney) > 1000},["#TEST_05_A_01#","TEST_05"],
			{true},["#TEST_0X_A_BACK#",NODE_BACK],
			{true},["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test06 - "Answer with template"*/
	[
		"TEST_06",	[
		Q_ONE,	"#TEST_06_Q#",
		A_DEF,	[
			[["#TEST_06_A_01#",{name player},{(player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney}],"TEST_06"],
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test07 - "Answer with code execution"*/
	[
		"TEST_07",	[
		Q_ONE,	"#TEST_07_Q#",
		A_DEF,	[
			["#TEST_07_A_01#","TEST_07",{systemChat "Hello from code execution"}],
			["#TEST_07_A_02#",NODE_EXIT,{systemChat "You exited"}],
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],
	/*Test08 - "Generated answers"*/
	[
		"TEST_08",	[
		Q_ONE,	"#TEST_08_Q#",
		A_GEN,	[
			{call NWG_Dialogue_Test_GenerateAnswers},
			["#TEST_0X_A_BACK#",NODE_BACK],
			["#TEST_0X_A_EXIT#",NODE_EXIT]
		]
	]],


	["",""]
];

