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
				["#XXX_HELP_A_01#","TAXI_HELP"],
				["#XXX_HELP_A_02#","TAXI_ADV"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
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
				["#XXX_HELP_A_01#","TAXI_HELP"],
				["#XXX_HELP_A_02#","TAXI_ADV"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
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
				["#XXX_HELP_A_03#","TAXI_HELP_PLACE"],
				["#XXX_HELP_A_04#","TAXI_HELP_WHO"],
				["#XXX_HELP_A_05#","TAXI_HELP_TALK"],
				["#XXX_HELP_A_06#","TAXI_HELP_USERFLOW"]
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
				["#XXX_HELP_A_07#","TAXI_HELP"],
				["#XXX_HELP_A_08#","TAXI_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
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
				["#XXX_HELP_A_07#","TAXI_HELP"],
				["#XXX_HELP_A_08#","TAXI_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
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
				["#XXX_HELP_A_07#","TAXI_HELP"],
				["#XXX_HELP_A_08#","TAXI_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
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
				["#XXX_HELP_A_07#","TAXI_HELP"],
				["#XXX_HELP_A_08#","TAXI_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
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
				{true},["#XXX_HELP_A_08#","TAXI_01"],
				{true},["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Mech
	/*Actual root of the dialogue*/
/*
MECH_00	Q_CND	$<1000	"Newcomer?|Don't scratch anything here"
		rand	"Yes?"
		rand	"What can I help you with?"
		rand	"Hey, have you seen...|a guy with a red crowbar?|The fucker owns me|That's MY fucking crowbar|And it is my favorite|You meet him - you let me know|Okay?"
		{true}	"Buy? Sell? Repair?"
	A_DEF		"Open the shop"			{close dialogue, open vehicle shop}
			"I need your services"			MECH_SERV
			"What should I know?"			MECH_HELP
			"Any advice?"			MECH_ADV
*/
	[
		"MECH_00",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#MECH_00_Q_01#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MECH_00_Q_03#",
				{[1,15] call NWG_DLGHLP_Dice},"#MECH_00_Q_04#",
				{true},"#MECH_00_Q_05#"
			],
			A_DEF,	[
				["#MECH_00_A_01#",NODE_EXIT,{call NWG_DLG_MECH_OpenShop}],
				["#MECH_00_A_02#","MECH_SERV"],
				["#XXX_HELP_A_01#","MECH_HELP"],
				["#XXX_HELP_A_02#","MECH_ADV"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
/*
MECH_01	Q_RND		"Anything else?"
			"What?"
			"Yeah, what?"
	A_DEF		"Open the shop"			{close dialogue, open vehicle shop}
			"I need your services"			MECH_SERV
			"What should I know?"			MECH_HELP
			"Any advice?"			MECH_ADV
*/
	[
		"MECH_01",	[
			Q_RND,	[
				"#MECH_01_Q_01#",
				"#MECH_01_Q_02#",
				"#MECH_01_Q_03#"
			],
			A_DEF,	[
				["#MECH_00_A_01#",NODE_EXIT,{call NWG_DLG_MECH_OpenShop}],
				["#MECH_00_A_02#","MECH_SERV"],
				["#XXX_HELP_A_01#","MECH_HELP"],
				["#XXX_HELP_A_02#","MECH_ADV"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Services - category selection*/
/*
MECH_SERV	Q_ONE		"What kind of?"
	A_DEF		"I need repair"			MECH_REPAIR
			"I need refuel"			MECH_REFUEL
			"Rearm"			MECH_REARM
			"Can you customize my vehicle?"			MECH_APRNC
			"New pylons"			MECH_PYLON
			"Install 'All Wheel' drive gear"			MECH_ALWHL
			"On the second thought"			MECH_01
			"No, nothing"			NODE_EXIT
*/
	[
		"MECH_SERV",	[
			Q_ONE,	"#MECH_SERV_Q_01#",
			A_DEF,	[
				["#MECH_SERV_A_01#","MECH_REPAIR"],
				["#MECH_SERV_A_02#","MECH_REFUEL"],
				["#MECH_SERV_A_03#","MECH_REARM"],
				["#MECH_SERV_A_04#","MECH_APRNC"],
				["#MECH_SERV_A_05#","MECH_PYLON"],
				["#MECH_SERV_A_06#","MECH_ALWHL"],
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Services - repair choice*/
/*
MECH_REPAIR	Q_RND		"Sure thing, which vehicle?"
			"Repairs is what I do. Which one to look at?
	A_GEN		{call XXX}
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
	[
		"MECH_REPAIR",	[
			Q_RND,	[
				"#MECH_REPAIR_Q_01#",
				"#MECH_REPAIR_Q_02#"
			],
			A_GEN,	[
				{"REPR" call NWG_DLG_MECH_GenerateChoices},
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - refuel choice*/
/*
MECH_REFUEL	Q_RND		"You're lucky I have some. Which one?"
			"Yeah, got some fuel. Which one?"
	A_GEN		{call XXX}			MECH_PAY
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
	[
		"MECH_REFUEL",	[
			Q_RND,	[
				"#MECH_REFUEL_Q_01#",
				"#MECH_REFUEL_Q_02#"
			],
			A_GEN,	[
				{"FUEL" call NWG_DLG_MECH_GenerateChoices},
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - rearm choice*/
/*
MECH_REARM	Q_RND		"Got some ammo. Which one to top up?"
			"Sure thing"
	A_GEN		{call XXX}			MECH_PAY
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
	[
		"MECH_REARM",	[
			Q_RND,	[
				"#MECH_REARM_Q_01#",
				"#MECH_REARM_Q_02#"
			],
			A_GEN,	[
				{"RARM" call NWG_DLG_MECH_GenerateChoices},
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - appearance choice*/
/*
MECH_APRNC	Q_RND		"Drive with a style kinda guy?|Sure thing"
			"You want me to pimp your ride?"
	A_GEN		{call XXX}			MECH_PAY
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
	[
		"MECH_APRNC",	[
			Q_RND,	[
				"#MECH_APRNC_Q_01#",
				"#MECH_APRNC_Q_02#"
			],
			A_GEN,	[
				{"APPR" call NWG_DLG_MECH_GenerateChoices},
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - pylon choice*/
/*
MECH_PYLON	Q_RND		"Let's do some heavy lifting then"
			"I don't mind heavy lifting, but this missiles are pain in the ass|But sure, let's do it"
			"Guess we've got a real pilot here, huh?"
	A_GEN		{call XXX}			MECH_PAY
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
	[
		"MECH_PYLON",	[
			Q_RND,	[
				"#MECH_PYLON_Q_01#",
				"#MECH_PYLON_Q_02#",
				"#MECH_PYLON_Q_03#"
			],
			A_GEN,	[
				{"PYLN" call NWG_DLG_MECH_GenerateChoices},
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - all wheel choice*/
/*
MECH_ALWHL	Q_RND		"Yeah, crazy stuff|But extremely useful"
			"So you like my invetion?|It ain't cheap"
			"Yeah, let's make you a monster truck"
			"Glad someone appreciates it"
	A_GEN		{call XXX}			MECH_PAY
			"On the second thought"			MECH_01
			"No, forget it"			NODE_EXIT
*/
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
				["#MECH_0X_A_BACK1#","MECH_01"],
				["#MECH_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*Services - payment*/
/*
MECH_PAY	Q_ONE		"That would be {X}"
	A_CND	$>=X	"Take it"			{close dialogue, deplete cash, perform action}
		$<X	"That's more than I have"			MECH_LOW
		{true}	"I've changed my mind"			MECH_01
		{true}	"Never mind"			NODE_EXIT
*/
	[
		"MECH_PAY",	[
			Q_ONE,	["#MECH_PAY_Q_01#",{call NWG_DLG_MECH_GetPriceStr}],
			A_CND,	[
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasEnoughMoney},["#MECH_PAY_A_01#",NODE_EXIT,{call NWG_DLG_MECH_DoService}],
				{(call NWG_DLG_MECH_GetPrice) call NWG_DLGHLP_HasLessMoney},["#MECH_PAY_A_02#","MECH_LOW"],
				{true},["#MECH_0X_A_BACK2#","MECH_01"],
				{true},["#MECH_0X_A_EXIT3#",NODE_EXIT]
			]
		]
	],
	/*Services - not enough money*/
/*
MECH_LOW	Q_RND		"Told you it ain't cheap"
			"Sorry, no discounts"
	A_DEF		"I guess"			MECH_01
			"Well, see you"			NODE_EXIT
*/
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
/*
MECH_HELP	Q_RND		"About what?"
			"Yeah? About what?"
			"In particular?"
	A_DEF		"What is this place?"			MECH_HELP_PLACE
			"Who are you?"			MECH_HELP_WHO
			"Who are others?"			MECH_HELP_TALK
			"How things are done here?"			MECH_HELP_USERFLOW
*/
	[
		"MECH_HELP",	[
			Q_RND,	[
				"#MECH_HELP_Q_01#",
				"#MECH_HELP_Q_02#",
				"#MECH_HELP_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_03#","MECH_HELP_PLACE"],
				["#XXX_HELP_A_04#","MECH_HELP_WHO"],
				["#XXX_HELP_A_05#","MECH_HELP_TALK"],
				["#XXX_HELP_A_06#","MECH_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
MECH_HELP_PLACE	Q_ONE		"Describes the place..."
	A_DEF		"Another question"			MECH_HELP
			"Got it"			MECH_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MECH_HELP_PLACE",	[
			Q_ONE,	"#MECH_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MECH_HELP"],
				["#XXX_HELP_A_08#","MECH_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
MECH_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			MECH_HELP
			"Got it"			MECH_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MECH_HELP_WHO",	[
			Q_ONE,	"#MECH_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MECH_HELP"],
				["#XXX_HELP_A_08#","MECH_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
MECH_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			MECH_HELP
			"Got it"			MECH_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MECH_HELP_TALK",	[
			Q_ONE,	"#MECH_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MECH_HELP"],
				["#XXX_HELP_A_08#","MECH_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
MECH_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			MECH_HELP
			"Got it"			MECH_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MECH_HELP_USERFLOW",	[
			Q_ONE,	"#MECH_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MECH_HELP"],
				["#XXX_HELP_A_08#","MECH_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice*/
/*
MECH_ADV	Q_RND		"Avoid drowning your vehicle|You can repair it if it's broken|Refuel it if it's empty|Hell, even flip it back on ot's wheels|But drownning?|That's a 'no return' and 'warranty void'|Nothing you can do"
			"I'm not sure if I should tell it|But hell, there's so much work|So listen|Repair your own vehicle before selling it|I will buy it for more|And won't have to spend much time with it|A win-win, right?"
			"Don't get greedy|If you see you need to sacrifice your ride|Do it|You can always get a new one|Better loose some additionals|Than half of what you got so far"
			"Keep your toolkit with you|If you go on wheels|Yeah, that simple"
	A_DEF		"Got it"			MECH_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MECH_ADV",	[
			Q_RND,	[
				"#MECH_ADV_Q_01#",
				"#MECH_ADV_Q_02#",
				"#MECH_ADV_Q_03#",
				"#MECH_ADV_Q_04#"
			],
			A_DEF,	[
				["#XXX_HELP_A_08#","MECH_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Trdr
	/*Actual root of the dialogue*/
/*
TRDR_00	Q_CND	$<100	"Hope you worth my time"
		$<1000	"Newcomer?|Look but don't touch"
		$>100000	"Welcome to my shop, friend"
		$>1000000	"My favorite customer|How are you today?"
		rand	"Yes?"
		rand	"Look who we got here"
		rand	"Buy or sell?"
		{true}	"Come on in"
	A_DEF		"Let's trade"			{close dialogue, open vehicle shop}
			"What should I know?"			TRDR_HELP
			"Any advice?"			TRDR_ADV
			"No, nothing"			NODE_EXIT
*/
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
				["#XXX_HELP_A_01#","TRDR_HELP"],
				["#XXX_HELP_A_02#","TRDR_ADV1"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
/*
TRDR_01	Q_RND		"Made your mind?"
			"So what it will be?"
			"Something else?"
	A_DEF		"Let's trade"			{close dialogue, open items shop}
			"What should I know?"			TRDR_HELP
			"Any advice?"			TRDR_ADV1
			"No, nothing"			NODE_EXIT
*/
	[
		"TRDR_01",	[
			Q_RND,	[
				"#TRDR_01_Q_01#",
				"#TRDR_01_Q_02#",
				"#TRDR_01_Q_03#"
			],
			A_DEF,	[
				["#TRDR_00_A_01#",NODE_EXIT,{call NWG_DLG_TRDR_OpenItemsShop}],
				["#XXX_HELP_A_01#","TRDR_HELP"],
				["#XXX_HELP_A_02#","TRDR_ADV1"],
				["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
/*
TRDR_HELP	Q_RND		"About what?"
			"Yeah? About what?"
			"Keep it short"
	A_DEF		"What is this place?"			TRDR_HELP_PLACE
			"Who are you?"			TRDR_HELP_WHO
			"Who are others?"			TRDR_HELP_TALK
			"How things are done here?"			TRDR_HELP_USERFLOW
*/
	[
		"TRDR_HELP",	[
			Q_RND,	[
				"#TRDR_HELP_Q_01#",
				"#TRDR_HELP_Q_02#",
				"#TRDR_HELP_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_03#","TRDR_HELP_PLACE"],
				["#XXX_HELP_A_04#","TRDR_HELP_WHO"],
				["#XXX_HELP_A_05#","TRDR_HELP_TALK"],
				["#XXX_HELP_A_06#","TRDR_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
TRDR_HELP_PLACE	Q_ONE		"Describes the place..."
	A_DEF		"Another question"			TRDR_HELP
			"Got it"			TRDR_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TRDR_HELP_PLACE",	[
			Q_ONE,	"#TRDR_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","TRDR_HELP"],
				["#XXX_HELP_A_08#","TRDR_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
TRDR_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			TRDR_HELP
			"Got it"			TRDR_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TRDR_HELP_WHO",	[
			Q_ONE,	"#TRDR_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","TRDR_HELP"],
				["#XXX_HELP_A_08#","TRDR_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
TRDR_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			TRDR_HELP
			"Got it"			TRDR_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TRDR_HELP_TALK",	[
			Q_ONE,	"#TRDR_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","TRDR_HELP"],
				["#XXX_HELP_A_08#","TRDR_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
TRDR_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			TRDR_HELP
			"Got it"			TRDR_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TRDR_HELP_USERFLOW",	[
			Q_ONE,	"#TRDR_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","TRDR_HELP"],
				["#XXX_HELP_A_08#","TRDR_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice - Pay for advice*/
/*
TRDR_ADV1	Q_RND		"Advice?|Put your money on the table|That's my advice|Next advice will cost you {X}"
			"Heard 'Advices are cheap'?|Well|Not mine though|How about {X}?"
			"{X}"
	A_CND	$>=X	"Here"			TRDR_ADV2
		$<X	"Don't have that much right now"			TRDR_LOW
		{true}	"I've changed my mind"			TRDR_01
		{true}	"Never mind"			NODE_EXIT
*/
	[
		"TRDR_ADV1",	[
			Q_RND,	[
				["#TRDR_ADV1_Q_01#",{call NWG_DLG_TRDR_GetAdvPriceStr}],
				["#TRDR_ADV1_Q_02#",{call NWG_DLG_TRDR_GetAdvPriceStr}],
				["#TRDR_ADV1_Q_03#",{call NWG_DLG_TRDR_GetAdvPriceStr}]
			],
			A_CND,	[
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasEnoughMoney},["#TRDR_ADV1_A_01#","TRDR_ADV2",{call NWG_DLG_TRDR_PayForAdvice}],
				{(call NWG_DLG_TRDR_GetAdvPrice) call NWG_DLGHLP_HasLessMoney},["#TRDR_ADV1_A_02#","TRDR_LOW"],
				{true},["#TRDR_0X_A_BACK1#","TRDR_01"],
				{true},["#TRDR_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Any advice - Get advice*/
/*
TRDR_ADV2	Q_RND		"Don't stick with just one gun|There is always something to shoot from|But if you stick with one and only|You'll have a hard time finding ammo"
			"Always share with others|Might sound stupid, I know|But they can get your ass out|Or frag you|And say you were like that when they found you|Always remember that"
			"Found a pile of bodies?|Loot them|Only then move on|You never know if you see them again|Animals, loyal frineds, fire|So many things can get your loot spoiled"
	A_DEF		"Got it"			TRDR_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"TRDR_ADV2",	[
			Q_RND,	[
				"#TRDR_ADV2_Q_01#",
				"#TRDR_ADV2_Q_02#",
				"#TRDR_ADV2_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_08#","TRDR_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice - Not enough money*/
/*
TRDR_LOW	Q_ONE		"Don't waste my time then|Advice... pfft"
	A_DEF		"Something else"			TRDR_01
			"Never mind"			NODE_EXIT
*/
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
/*
MEDC_00	Q_CND	{health<100 && rand}	"Are you injured? Need my help?"
		{health<100}	"You don't look good, son"
		rand	"Yes? Yes?"
		rand	"Did you bring your med card?"
		{true}	"Need pills?|Me too, son, me too"
	A_CND	{health<100}	"Yeah, I am. Can you patch me up?"			MEDC_PATCH
		{true}	"What should I know?"			MEDC_HELP
		{true}	"Any advice?"			MEDC_ADV
		{true}	"No, nothing"			NODE_EXIT
*/
	[
		"MEDC_00",	[
			Q_CND,	[
				{(call NWG_DLG_MEDC_IsInjured) && {call NWG_DLGHLP_Coin}},"#MEDC_00_Q_01#",
				{call NWG_DLG_MEDC_IsInjured},"#MEDC_00_Q_02#",
				{[1,3] call NWG_DLGHLP_Dice},"#MEDC_00_Q_03#",
				{[1,3] call NWG_DLGHLP_Dice},"#MEDC_00_Q_04#",
				{true},"#MEDC_00_Q_05#"
			],
			A_CND,	[
				{call NWG_DLG_MEDC_IsInjured},["#MEDC_00_A_01#","MEDC_PATCH"],
				{true},["#XXX_HELP_A_01#","MEDC_HELP"],
				{true},["#XXX_HELP_A_02#","MEDC_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
/*
MEDC_01	Q_RND		"You look tired, son"
			"Make sure you eat well"
			"You need some sleep schedule"
	A_CND	{health<100}	"Can you patch me up?"			MEDC_PATCH
		{true}	"What should I know?"			MEDC_HELP
		{true}	"Any advice?"			MEDC_ADV
		{true}	"No, nothing"			NODE_EXIT
*/
	[
		"MEDC_01",	[
			Q_RND,	[
				"#MEDC_01_Q_01#",
				"#MEDC_01_Q_02#",
				"#MEDC_01_Q_03#"
			],
			A_CND,	[
				{call NWG_DLG_MEDC_IsInjured},["#MEDC_01_A_01#","MEDC_PATCH"],
				{true},["#XXX_HELP_A_01#","MEDC_HELP"],
				{true},["#XXX_HELP_A_02#","MEDC_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Medic patch*/
/*
MEDC_PATCH	Q_CND	$<1000	"Sure thing, son|And since you're new here|Let's say your insurance covers it|Shall we?"
		{true}	"Sure thing|It will cost you just {X}"
	A_CND	$<1000	"Thanks,doc"			{close dialogue, patch player}
		$>1000	"Yeah, here you go"			{close dialogue, deplete money, patch player}
			"Never mind"			NODE_EXIT
*/
	[
		"MEDC_PATCH",	[
			Q_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},"#MEDC_PATCH_Q_01#",
				{1 call NWG_DLGHLP_HasMoreMoneyStartSum},["#MEDC_PATCH_Q_02#",{call NWG_DLG_MEDC_GetPatchPriceStr}]
			],
			A_CND,	[
				{1 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#MEDC_PATCH_A_01#",NODE_EXIT,{true call NWG_DLG_MEDC_Patch}],
				{1 call NWG_DLGHLP_HasMoreMoneyStartSum},["#MEDC_PATCH_A_02#",NODE_EXIT,{false call NWG_DLG_MEDC_Patch}],
				{true},["#MEDC_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
/*
MEDC_HELP	Q_RND		"What would you like to know, son?"
			"Sure, what is it?"
	A_DEF		"What is this place?"			MEDC_HELP_PLACE
			"Who are you?"			MEDC_HELP_WHO
			"Who are others?"			MEDC_HELP_TALK
			"How things are done here?"			MEDC_HELP_USERFLOW
*/
	[
		"MEDC_HELP",	[
			Q_RND,	[
				"#MEDC_HELP_Q_01#",
				"#MEDC_HELP_Q_02#"
			],
			A_DEF,	[
				["#XXX_HELP_A_03#","MEDC_HELP_PLACE"],
				["#XXX_HELP_A_04#","MEDC_HELP_WHO"],
				["#XXX_HELP_A_05#","MEDC_HELP_TALK"],
				["#XXX_HELP_A_06#","MEDC_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
MEDC_HELP_PLACE	Q_ONE		"Describes the place..."
	A_DEF		"Another question"			MEDC_HELP
			"Got it"			MEDC_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MEDC_HELP_PLACE",	[
			Q_ONE,	"#MEDC_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MEDC_HELP"],
				["#XXX_HELP_A_08#","MEDC_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
MEDC_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			MEDC_HELP
			"Got it"			MEDC_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MEDC_HELP_WHO",	[
			Q_ONE,	"#MEDC_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MEDC_HELP"],
				["#XXX_HELP_A_08#","MEDC_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
MEDC_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			MEDC_HELP
			"Got it"			MEDC_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MEDC_HELP_TALK",	[
			Q_ONE,	"#MEDC_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MEDC_HELP"],
				["#XXX_HELP_A_08#","MEDC_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
MEDC_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			MEDC_HELP
			"Got it"			MEDC_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"MEDC_HELP_USERFLOW",	[
			Q_ONE,	"#MEDC_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","MEDC_HELP"],
				["#XXX_HELP_A_08#","MEDC_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice*/
/*
MEDC_ADV	Q_RND		"There is...|There are...|(stares above your head)|Some... things..."
			"Don't mix those|I did|But that's okay..."
			"Just keep an eye out for each other|Hmm...."
	A_DEF		"Hello?"			MEDC_01
			"All right"			MEDC_01
			"Ok, bye"			NODE_EXIT
*/
	[
		"MEDC_ADV",	[
			Q_RND,	[
				"#MEDC_ADV_Q_01#",
				"#MEDC_ADV_Q_02#",
				"#MEDC_ADV_Q_03#"
			],
			A_DEF,	[
				["#MEDC_ADV_A_01#","MEDC_01"],
				["#MEDC_ADV_A_02#","MEDC_01"],
				["#MEDC_ADV_A_03#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Comm (Commander)
	/*Actual root of the dialogue*/
/*
COMM_00	Q_CND	mis>READY	"We're in a middle of an OP|Go join the others|And make it fast"
		$<1000	"Newcomer?|You know how to fight?|Good
		rand	"I'm listening"
		rand	"Report, soldier"
		rand	"At ease, soldier"
		{true}	"Make it quick"
	A_CND	mis==READY	"Ready to fight, sir"			COMM_MIS
		mis>READY	"Moving out"			NODE_EXIT
			"Can you explain me something?"			COMM_HELP
			"Any advice, sir?"			COMM_ADV
			"No, nothing"			NODE_EXIT
*/
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
/*
COMM_01	Q_RND		"Make it quick"
			"Anything else?"
	A_CND	mis==READY	"Ready to fight, sir"			COMM_MIS
		mis>READY	"I'll be on my way"			NODE_EXIT
			"Can you explain me something?"			COMM_HELP
			"Any advice, sir?"			COMM_ADV
			"No, nothing"			NODE_EXIT
*/
	[
		"COMM_01",	[
			Q_RND,	[
				"#COMM_00_Q_03#",
				"#COMM_00_Q_06#",
				"#COMM_01_Q_01#"
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
/*
COMM_MIS	Q_RND		"Goodspeed, soldier|Here's what we dealing with"
			"Here are the options"
			"Intelligence hinted on several points"
	A_DEF		"Show me"			{close dialogue, open mission select}
			"Something else first, sir"			COMM_01
			"Need more time for preparations"			NODE_EXIT
*/
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
/*
COMM_HELP	Q_RND		"What is it?"
			"Sure, what is it?"
	A_DEF		"What is this place?"			COMM_HELP_PLACE
			"Who are you?"			COMM_HELP_WHO
			"Who are others?"			COMM_HELP_TALK
			"How things are done here?"			COMM_HELP_USERFLOW
*/
	[
		"COMM_HELP",	[
			Q_RND,	[
				"#COMM_HELP_Q_01#",
				"#COMM_HELP_Q_02#"
			],
			A_DEF,	[
				["#XXX_HELP_A_03#","COMM_HELP_PLACE"],
				["#XXX_HELP_A_04#","COMM_HELP_WHO"],
				["#XXX_HELP_A_05#","COMM_HELP_TALK"],
				["#XXX_HELP_A_06#","COMM_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
COMM_HELP_PLACE	Q_ONE		"Describes the place..."
	A_DEF		"Another question"			COMM_HELP
			"Got it"			COMM_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"COMM_HELP_PLACE",	[
			Q_ONE,	"#COMM_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","COMM_HELP"],
				["#XXX_HELP_A_08#","COMM_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
COMM_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			COMM_HELP
			"Got it"			COMM_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"COMM_HELP_WHO",	[
			Q_ONE,	"#COMM_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","COMM_HELP"],
				["#XXX_HELP_A_08#","COMM_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
COMM_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			COMM_HELP
			"Got it"			COMM_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"COMM_HELP_TALK",	[
			Q_ONE,	"#COMM_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","COMM_HELP"],
				["#XXX_HELP_A_08#","COMM_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
COMM_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			COMM_HELP
			"Got it"			COMM_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"COMM_HELP_USERFLOW",	[
			Q_ONE,	"#COMM_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","COMM_HELP"],
				["#XXX_HELP_A_08#","COMM_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice*/
/*
COMM_ADV	Q_RND		"Always communicate|Make sure you know where others are|And that they know where you are|To avoid friendly fire and privide support"
			"Keep radio channels busy with info|And free from garbage"
			"Plan everything|How will you approach the target|Where will you strike|How will you exfil"
		{true}	"All right"			COMM_01
		{true}	"Ok, bye"			NODE_EXIT
*/
	[
		"COMM_ADV",	[
			Q_RND,	[
				"#COMM_ADV_Q_01#",
				"#COMM_ADV_Q_02#",
				"#COMM_ADV_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_08#","COMM_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
	//================================================================================================================
	//Roof
	/*Actual root of the dialogue*/
/*
ROOF_00	Q_CND	$<1000	"New guy, eh?"
		rand	"What's up?"
		rand	"Yeah?"
		rand	"You need something?"
		{true}	"Stupid barrels..."
	A_CND	$<10000	"What are you doing here?"			ROOF_WHAT
		$<10000	"What else can you tell?"			ROOF_NO_TRUST
		$>10000	"What else can you tell?"			ROOF_KNOW
		$<10000	"Is there something I should know?"			ROOF_NO_TRUST
		$>10000	"Is there something I should know?"			ROOF_HELP
		$<10000	"Any advice?"			ROOF_NO_TRUST
		$>10000	"Any advice?"			ROOF_ADV
			"No, nothing"			NODE_EXIT
*/
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
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_01#","ROOF_WHAT"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#ROOF_00_A_02#","ROOF_KNOW"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#XXX_HELP_A_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#XXX_HELP_A_01#","ROOF_HELP"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#XXX_HELP_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#XXX_HELP_A_02#","ROOF_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*Pseudo root for getting back in dialogue*/
/*
ROOF_01	Q_RND		"Shouldn't you do something?"
			"Shouldn't you be somewhere?"
			"Anyway, how about you be on your way?"
	A_CND	$<10000	"What else do you know?"			ROOF_NO_TRUST
		$<10000	"What else do you know?"			ROOF_NO_TRUST
		$>10000	"What else do you know?"			ROOF_KNOW
		$<10000	"Is there something I should know?"			ROOF_NO_TRUST
		$>10000	"Is there something I should know?"			ROOF_HELP
		$<10000	"Any advice?"			ROOF_NO_TRUST
		$>10000	"Any advice?"			ROOF_ADV
			"No, nothing"			NODE_EXIT
*/
	[
		"ROOF_01",	[
			Q_RND,	[
				"#ROOF_01_Q_01#",
				"#ROOF_01_Q_02#",
				"#ROOF_01_Q_03#"
			],
			A_CND,	[
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_01#","ROOF_WHAT"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#ROOF_00_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#ROOF_00_A_02#","ROOF_KNOW"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#XXX_HELP_A_01#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#XXX_HELP_A_01#","ROOF_HELP"],
				{10 call NWG_DLGHLP_HasLessOrEqMoneyStartSum},["#XXX_HELP_A_02#","ROOF_NO_TRUST"],
				{10 call NWG_DLGHLP_HasMoreMoneyStartSum},["#XXX_HELP_A_02#","ROOF_ADV"],
				{true},["#XXX_QUIT_DIALOGUE#",NODE_EXIT]
			]
		]
	],
	/*What are you doing here*/
/*
ROOF_WHAT	Q_ONE		"Describes the role..."
	A_DEF		"Got it"			ROOF_01
			"Ok, bye"			NODE_EXIT
*/
	[
		"ROOF_WHAT",	[
			Q_ONE,	"#ROOF_WHAT_Q_01#",
			A_DEF,	[
				["#ROOF_0X_A_BACK2#","ROOF_01"],
				["#ROOF_0X_A_EXIT1#",NODE_EXIT]
			]
		]
	],
	/*Doesn't trust you*/
/*
ROOF_NO_TRUST	Q_RND		"Sorry 'bratan'|I don't know you|You don't know me|It is how it is"
			"Mhm...|Maybe later|Not now|Not right now"
			"Is there no work for you?"
			"I'm busy|And so should be you|Right?"
	A_DEF		"That's ok"			ROOF_01
			"Ok, bye"			NODE_EXIT
*/
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
/*
ROOF_KNOW	Q_RND		"I know may things|This place's history|Local legends|Some rumors|What is it for you?"
			"Well, not like I have nothing to do|But why not|Go on|What's you interested in?"
			"I know a litttle bit of this|A little bit of that|What do you need to know?"
	A_DEF		"History of this place"			ROOF_HIST00
			"Local legends"			ROOF_LGND00
			"Local rumors"			ROOF_RUMR
			"Something else"			ROOF_01
			"Actually, no, forget it"			NODE_EXIT
*/
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
				["#ROOF_KNOW_A_04#","ROOF_01"],
				["#ROOF_KNOW_A_05#",NODE_EXIT]
			]
		]
	],
	/*History - category selection*/
/*
ROOF_HIST00	Q_ONE		"A short story or a long one?"
	A_DEF		"Short story"			ROOF_HIST01
			"Long story"			ROOF_HIST02
*/
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
/*
ROOF_HIST01	Q_ONE		"Tells short story..."
	A_CND	rand	"That's interesting"			ROOF_KNOW
		rand	"Hm. Got that"			ROOF_KNOW
		rand 	"That story sucks"			ROOF_KNOW
		{true}	"Got it"			ROOF_KNOW
			"I need to go"			NODE_EXIT
*/
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
/*
ROOF_HIST02	Q_ONE		"Tells longest story..."
	A_CND	rand	"That's interesting"			ROOF_KNOW
		rand	"Hm. Got that"			ROOF_KNOW
		rand	"I almost fell asleep"			ROOF_KNOW
		rand 	"That story sucks"			ROOF_KNOW
		{true}	"Got it"			ROOF_KNOW
			"I need to go"			NODE_EXIT
*/
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
/*
ROOF_LGND00	Q_RND		"It's not like 'legends' legends|Not like 'dwarfs and fairies'|There are guys here who we call local legends|So who do you want to know about?"
			"Local legendary operators|Who do you want to hear about?"
			"Yep, local legends they are|Nice guys|Well, most of them|Some of them... it depends"
	A_DEF		"Operator HOPA"			ROOF_LGND_HOPA
			"Who's Bit... Rayman? Raymon?"			ROOF_LGND_BIT
			"Can of RedBull?"			ROOF_LGND_BANKA
			"What was his name... Hui? Huy? Huiyui?"			ROOF_LGND_HUI
			"Asmo"			ROOF_LGND_ASMO
*/
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
/*
ROOF_LGND01	Q_RND		"It's not like 'legends' legends|Not like 'dwarfs and fairies'|There are guys here who we call local legends|So who do you want to know about?"
			"Local legendary operators|Who do you want to hear about?"
			"Yep, local legends they are|Nice guys|Well, most of them|Some of them... it depends"
	A_DEF		"Operator HOPA"			ROOF_LGND_HOPA
			"Who's Bit... Rayman? Raymon?"			ROOF_LGND_BIT
			"Can of RedBull?"			ROOF_LGND_BANKA
			"What was his name... Hui? Huy? Huiyui?"			ROOF_LGND_HUI
			"Asmo"			ROOF_LGND_ASMO
*/
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
/*
ROOF_LGND_HOPA	Q_ONE		"Fucking genius that's who he is|That guy could attach anything to anyone|Build entire systems overnight|All with duct tape, sticks and shit|Legendary engineer"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
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
/*
ROOF_LGND_BIT	Q_ONE		"No, Rayman is another guy|But that Bit-Ramon?|Fucking lunatic|Would crash his heli into the building|Just to get there a 'Bit' faster|And annihilate everyone inside|We thought he and MoshPit where the most badass fuckers out there|And were kinda expecting them to meet|Turns out|It was the same guy|Fighting for both sides|Just for shit and giggles|Oh, and fuck load of money of course"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
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
/*
ROOF_LGND_BANKA	Q_ONE		"No, 'Banka RedBulla'|A strange name I know|He would spend hours in the arsenal|Trying to match his outfit to some 1969 brigade only he heard about|Quite a passion for history, eh?|Most fun was when he was put in charge|Everyone were dressing up|No exceptions|People kinda liked it even|He would also tell you much more than I could ever|Walking talking history book and enthusiast"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
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
/*
ROOF_LGND_HUI	Q_ONE		"Don't look at me|I still have no idea how to spell his name|Legendary pilot who could give you a ride|In and out|With ANY airbourne machine available|Planes, choppers, vtols - the guy knew them all|And could land a mohawk on a satan's dick|If he wanted to"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
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
/*
ROOF_LGND_ASMO	Q_ONE		"Who the fuck is Asmo?"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
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
/*
ROOF_RUMR	Q_RND		"Have you seen the bones yet?|Some guys been talking|How there are bones|Just scattered around the house|And worst part|Different people point to different sites|So shit might be widespread|And we have no idea why|Or who's doing this"
			"Some locals caught some...|Sort of flu or smallpox|But now they are quaranteed|At military guarded camps|I don't know what it is|But that's no good news|That's for sure"
			"Let's see...|We do have a problem with some|Maniac who kills people|And strips their meat from bones|And plays with the skulls|How about that kind of rumor?|Scared?|Don't be|You have a gun|He might have too"
			"Sorry, nothing comes to mind"
			"Radio towers|I'm telling you|They emit radiation|Can you believe that?|So glad we have none of those here"
			"Don't drink local water|They put something into it"
			"There was a shipwreck nearby|A hundred meters off the coast|And no survivors|Can you imagine?|Who... or what killed those people?"
			"Hey, I won't tell where and what|You WILL know when you see it|Just|Don't look it in the eyes, ok?"
			"We do have some occult shit happening here|Not sure what it is|Not sure if we have to worry"
			"There is a secret cave somwhere on this island|What?|Yeah, I'm telling that no matter the island|There is always at least one"
	A_DEF		"Got it"			ROOF_KNOW
			"Thanks, but I need to go now"			NODE_EXIT
*/
	[
		"ROOF_RUMR",	[
			Q_RND,	[
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
				{true},["#ROOF_0X_A_BACK2#","ROOF_KNOW"],
				{true},["#ROOF_0X_A_EXIT2#",NODE_EXIT]
			]
		]
	],
	/*What should I know - cat selection*/
/*
ROOF_HELP	Q_RND		"What would you like to know?"
			"Yeah, what is it?"
			"So? Any specific questions?"
	A_DEF		"What is this place?"			ROOF_HELP_PLACE
			"Who are you?"			ROOF_HELP_WHO
			"Who are others?"			ROOF_HELP_TALK
			"How things are done here?"			ROOF_HELP_USERFLOW
*/
	[
		"ROOF_HELP",	[
			Q_RND,	[
				"#ROOF_HELP_Q_01#",
				"#ROOF_HELP_Q_02#",
				"#ROOF_HELP_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_03#","ROOF_HELP_PLACE"],
				["#XXX_HELP_A_04#","ROOF_HELP_WHO"],
				["#XXX_HELP_A_05#","ROOF_HELP_TALK"],
				["#XXX_HELP_A_06#","ROOF_HELP_USERFLOW"]
			]
		]
	],
	/*What should I know - What is this place*/
/*
ROOF_HELP_PLACE	Q_ONE		"Describes the place..."
	A_DEF		"Another question"			ROOF_HELP
			"Got it"			ROOF_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"ROOF_HELP_PLACE",	[
			Q_ONE,	"#ROOF_HELP_PLACE_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","ROOF_HELP"],
				["#XXX_HELP_A_08#","ROOF_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who are you*/
/*
ROOF_HELP_WHO	Q_ONE		"Describes himself..."
	A_DEF		"Another question"			ROOF_HELP
			"Got it"			ROOF_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"ROOF_HELP_WHO",	[
			Q_ONE,	"#ROOF_HELP_WHO_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","ROOF_HELP"],
				["#XXX_HELP_A_08#","ROOF_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - Who should I talk to*/
/*
ROOF_HELP_TALK	Q_ONE		"Describes others..."
	A_DEF		"Another question"			ROOF_HELP
			"Got it"			ROOF_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"ROOF_HELP_TALK",	[
			Q_ONE,	"#ROOF_HELP_TALK_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","ROOF_HELP"],
				["#XXX_HELP_A_08#","ROOF_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*What should I know - How things are done here*/
/*
ROOF_HELP_USERFLOW	Q_ONE		"Describes gameplay loop..."
	A_DEF		"Another question"			ROOF_HELP
			"Got it"			ROOF_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"ROOF_HELP_USERFLOW",	[
			Q_ONE,	"#ROOF_HELP_USERFLOW_Q_01#",
			A_DEF,	[
				["#XXX_HELP_A_07#","ROOF_HELP"],
				["#XXX_HELP_A_08#","ROOF_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],
	/*Any advice*/
/*
ROOF_ADV	Q_RND		"Do your thing|That's my advice"
			"Make sure you have everything you need before going into wilderness"
			"Don't tell anyone you saw me here|Don't tell anyone anything actually"
	A_DEF		"Got it"			ROOF_01
			"Thanks, bye"			NODE_EXIT
*/
	[
		"ROOF_ADV",	[
			Q_RND,	[
				"#ROOF_ADV_Q_01#",
				"#ROOF_ADV_Q_02#",
				"#ROOF_ADV_Q_03#"
			],
			A_DEF,	[
				["#XXX_HELP_A_08#","ROOF_01"],
				["#XXX_HELP_A_09#",NODE_EXIT]
			]
		]
	],

	//================================================================================================================
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

