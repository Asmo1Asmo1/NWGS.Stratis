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

