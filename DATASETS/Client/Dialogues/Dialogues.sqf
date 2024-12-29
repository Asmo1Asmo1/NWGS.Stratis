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

