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

//================================================================================================================
//================================================================================================================
//Defines
#define Q_ONE 0
#define Q_RND 1
#define Q_CND 2

#define A_DEF 0
#define A_CND 1
#define A_GEN 2

#define STRING_SEPARATOR "|"
#define NODE_BACK -1
#define NODE_EXIT -2

#define DIALOGUE_NAME "dialogueUI"
//--- dialogueUI
#define IDC_QLISTBOX 1500
#define IDC_ALISTBOX 1501
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001
#define IDC_TEXT_NPC 1002

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLG_CLI_Settings = createHashMapFromArray [
	/*Localization settings*/
	["LOCALIZATION",createHashMapFromArray [
		["TEST","#NPC_TEST_NAME#"],
		["TAXI","#NPC_TAXI_NAME#"],
		["MECH","#NPC_MECH_NAME#"],
		["TRDR","#NPC_TRDR_NAME#"],
		["MEDC","#NPC_MEDC_NAME#"],
		["COMM","#NPC_COMM_NAME#"],
		["ROOF","#NPC_ROOF_NAME#"]
	]],

	/*Text filling functions*/
	["TEXT_LEFT_FILL_FUNC", {(player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney}],
	["TEXT_RIGHT_FILL_FUNC",{name player}],

	/*Formatting settings*/
	["TEMPLATE_SPEAKER_NAME","[%1]:"],
	["TEMPLATE_ANSWER","%1: %2"],

	/*Delay settings - make dialogues appear more natural*/
	["DELAY_NEXT_QUESTION",[0.1,0.5]],
	["DELAY_NEXT_QUESTION_ROW",[0.25,1]],
	["DELAY_NEXT_QUESTION_ROW_SPEED_CASCADE",true],//If true, next row will be displayed faster than previous
	["DELAY_NEXT_ANSWERS",0.05],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
// NWG_DialogueTree = createHashMap;//Is defined and compiled in 'DATASETS\Client\Dialogues\Dialogues.sqf'

//================================================================================================================
//================================================================================================================
//Dialogue logic
NWG_DLG_CLI_OpenDialogue = {
	disableSerialization;
	private _npcName = _this;

	//Get root node of dialogue
	private _rootNodeName = format ["%1_00",_npcName];
	private _rootNode = NWG_DialogueTree get _rootNodeName;
	if (isNil "_rootNode") exitWith {
		(format ["NWG_DLG_CLI_OpenDialogue: Root node not found: '%1'",_rootNodeName]) call NWG_fnc_logError;
		false
	};

	//Open dialogue UI
	private _gui = createDialog [DIALOGUE_NAME,true];
	if (isNull _gui) exitWith {
		"NWG_DLG_CLI_OpenDialogue: Could not create dialogue" call NWG_fnc_logError;
		false
	};

	//Fill text fields
	private _npcNameLoc = ((NWG_DLG_CLI_Settings get "LOCALIZATION") getOrDefault [_npcName,""]) call NWG_fnc_localize;
	(_gui displayCtrl IDC_TEXT_LEFT)  ctrlSetText (call (NWG_DLG_CLI_Settings get "TEXT_LEFT_FILL_FUNC"));
	(_gui displayCtrl IDC_TEXT_RIGHT) ctrlSetText (call (NWG_DLG_CLI_Settings get "TEXT_RIGHT_FILL_FUNC"));
	(_gui displayCtrl IDC_TEXT_NPC)   ctrlSetText _npcNameLoc;

	//Get listboxes
	private _qListbox = _gui displayCtrl IDC_QLISTBOX;
	if (isNull _qListbox) exitWith {
		"NWG_DLG_CLI_OpenDialogue: qListbox is null" call NWG_fnc_logError;
		false
	};
	private _aListbox = _gui displayCtrl IDC_ALISTBOX;
	if (isNull _aListbox) exitWith {
		"NWG_DLG_CLI_OpenDialogue: aListbox is null" call NWG_fnc_logError;
		false
	};

	//Save and dispose data
	uiNamespace setVariable ["NWG_DLG_gui",_gui];
	uiNamespace setVariable ["NWG_DLG_qListbox",_qListbox];
	uiNamespace setVariable ["NWG_DLG_aListbox",_aListbox];
	uiNamespace setVariable ["NWG_DLG_answers",[]];
	uiNamespace setVariable ["NWG_DLG_npcNameLoc",_npcNameLoc];
	uiNamespace setVariable ["NWG_DLG_nodeHistory",[]];
	_gui displayAddEventHandler ["Unload",{
		uiNamespace setVariable ["NWG_DLG_gui",nil];
		uiNamespace setVariable ["NWG_DLG_qListbox",nil];
		uiNamespace setVariable ["NWG_DLG_aListbox",nil];
		uiNamespace setVariable ["NWG_DLG_answers",nil];
		uiNamespace setVariable ["NWG_DLG_npcNameLoc",nil];
		uiNamespace setVariable ["NWG_DLG_nodeHistory",nil];
	}];

	//Setup event handlers
	_gui displayAddEventHandler ["KeyDown", {
		// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
		//[keyCode,"keyboard button"] is [2,"1"],[3,"2"],...,[9,"8"]
		private _keyCode = _this#1;
		private _intercept = false;
		if (_keyCode >= 2 && {_keyCode <= 9}) then {
			(_keyCode-2) call NWG_DLG_CLI_OnAnswerSelected;
			_intercept = true;
		};
		_intercept
	}];
	_qListbox ctrlAddEventHandler ["LBSelChanged",{
		params ["_listBox","_selectedIndex"];
		if (_selectedIndex > -1) then {
			_listBox lbSetCurSel -1;
			_listBox ctrlSetScrollValues [1,-1];//Scroll to bottom
		};
	}];
	_aListbox ctrlAddEventHandler ["LBSelChanged",{
		params ["_listBox","_selectedIndex"];
		if (_selectedIndex > -1) then {
			_selectedIndex call NWG_DLG_CLI_OnAnswerSelected;
		};
	}];

	//Load root node
	[_rootNodeName,/*withDelays:*/false] call NWG_DLG_CLI_LoadNextNode;
	true
};

NWG_DLG_CLI_IsUIClosed = {
	isNull (uiNamespace getVariable ["NWG_DLG_gui",displayNull])
};

NWG_DLG_CLI_LoadNextNode = {
	disableSerialization;
	params ["_nodeName",["_withDelays",true]];

	//Check args
	private _node = NWG_DialogueTree get _nodeName;
	if (isNil "_node") exitWith {
		(format ["NWG_DLG_CLI_LoadNextNode: Node not found: '%1'",_nodeName]) call NWG_fnc_logError;
		false
	};
	if (_withDelays && {!canSuspend}) then {
		"NWG_DLG_CLI_LoadNextNode: Cannot use delays if script is not 'spawn'ed" call NWG_fnc_logError;
		_withDelays = false;
	};
	if (call NWG_DLG_CLI_IsUIClosed) exitWith {
		"NWG_DLG_CLI_LoadNextNode: GUI is closed before we could load node" call NWG_fnc_logError;
		false
	};

	//Delay before next question
	if (_withDelays) then {sleep ((NWG_DLG_CLI_Settings get "DELAY_NEXT_QUESTION") call NWG_fnc_randomRangeFloat)};
	if (call NWG_DLG_CLI_IsUIClosed) exitWith {false};

	//Unpack node
	_node params ["_qType","_qBody","_aType","_aBody"];

	//Extract and format next question
	private _question = switch (_qType) do {
		case Q_ONE: {_qBody};
		case Q_RND: {selectRandom _qBody};
		case Q_CND: {
			private ["_selected"];
			for "_i" from 0 to ((count _qBody) - 1) step 2 do {
				if ((call (_qBody param [_i,{false}])) isEqualTo true)
					exitWith {_selected = (_qBody param [(_i+1),""])};
			};
			_selected
		};
		default {
			(format ["NWG_DLG_CLI_LoadNextNode: Invalid question type: '%1'",_qType]) call NWG_fnc_logError;
			""
		};
	};
	_question = switch (true) do {
		case (isNil "_question"): {
			(format ["NWG_DLG_CLI_LoadNextNode: Question is nil for node '%1'",_nodeName]) call NWG_fnc_logError;
			""
		};
		case (_question isEqualType ""): {
			_question call NWG_fnc_localize
		};
		case (_question isEqualType []): {
			_question = _question + [];//Shallow copy to prevent modifying original array
			private _template = (_question deleteAt 0) call NWG_fnc_localize;
			private _args = _question apply {(call _x) call NWG_fnc_localize};
			format ([_template]+_args)
		};
	};
	forceUnicode 1;//Fix splitString for unicode
	_question = _question splitString STRING_SEPARATOR;
	if ((count _question) == 0) exitWith {
		(format ["NWG_DLG_CLI_LoadNextNode: Question is empty for node '%1'",_nodeName]) call NWG_fnc_logError;
		false
	};

	//Show next question
	private _qListbox = uiNamespace getVariable ["NWG_DLG_qListbox",controlNull];
	private _npcNameLoc = uiNamespace getVariable ["NWG_DLG_npcNameLoc",""];
	_qListbox lbAdd "";//Add empty line to separate records
	_qListbox lbAdd (format [(NWG_DLG_CLI_Settings get "TEMPLATE_SPEAKER_NAME"),_npcNameLoc]);//Add speaker name
	_qListbox lbAdd (_question deleteAt 0);//Add first question line
	_qListbox ctrlSetScrollValues [1,-1];//Scroll to bottom
	private _rowDelayCur = (NWG_DLG_CLI_Settings get "DELAY_NEXT_QUESTION_ROW") call NWG_fnc_randomRangeFloat;
	private _isCascade = NWG_DLG_CLI_Settings get "DELAY_NEXT_QUESTION_ROW_SPEED_CASCADE";
	private _rowDelayNew = _rowDelayCur;
	{
		if (_withDelays) then {
			_rowDelayNew = (NWG_DLG_CLI_Settings get "DELAY_NEXT_QUESTION_ROW") call NWG_fnc_randomRangeFloat;
			if (_isCascade) then {_rowDelayNew = _rowDelayNew min _rowDelayCur; _rowDelayCur = _rowDelayNew};
			sleep _rowDelayNew;
		};
		if (call NWG_DLG_CLI_IsUIClosed) exitWith {false};
		_qListbox lbAdd _x;
		_qListbox ctrlSetScrollValues [1,-1];//Scroll to bottom
	} forEach _question;
	if (call NWG_DLG_CLI_IsUIClosed) exitWith {false};

	//Delay before next answers
	if (_withDelays) then {sleep (NWG_DLG_CLI_Settings get "DELAY_NEXT_ANSWERS")};
	if (call NWG_DLG_CLI_IsUIClosed) exitWith {false};

	//Extract and select next answers
	private _answers = switch (_aType) do {
		case A_DEF: {_aBody};
		case A_CND: {
			private _selected = [];
			for "_i" from 0 to ((count _aBody) - 1) step 2 do {
				if ((call (_aBody param [_i,{false}])) isEqualTo true)
					then {_selected pushBack (_aBody param [(_i+1),[]])};
			};
			_selected
		};
		case A_GEN: {
			//Pure code generation
			if (_aBody isEqualType {}) exitWith {call _aBody};
			//Mixed with predefined answers
			private _generated = [];
			{
				if (_x isEqualType {})
					then {_generated append (call _x)}
					else {_generated pushBack _x};
			} forEach _aBody;
			_generated
		};
		default {
			(format ["NWG_DLG_CLI_LoadNextNode: Invalid answer type: '%1'",_aType]) call NWG_fnc_logError;
			[]
		};
	};
	uiNamespace setVariable ["NWG_DLG_answers",_answers];//Save for later use

	//Show next answers
	private _aListbox = uiNamespace getVariable ["NWG_DLG_aListbox",controlNull];
	private _template = NWG_DLG_CLI_Settings get "TEMPLATE_ANSWER";
	private _nextAnswer = "";
	private _i = -1;
	{
		_nextAnswer = switch (true) do {
			case (_x isEqualType []): {
				private _ansX = _x+[];//Shallow copy to prevent modifying original array
				private _ansTemplate = (_ansX deleteAt 0) call NWG_fnc_localize;
				private _ansArgs = _ansX apply {(call _x) call NWG_fnc_localize};
				format ([_ansTemplate]+_ansArgs)
			};
			case (_x isEqualType ""): {
				_x call NWG_fnc_localize;
			};
			default {
				(format ["NWG_DLG_CLI_LoadNextNode: Invalid answer type: '%1'",_x]) call NWG_fnc_logError;
				""
			};
		};

		_i = _aListbox lbAdd (format [_template,(_forEachIndex+1),_nextAnswer]);
		_aListbox lbSetData [_i,_nextAnswer];//Save raw answer string for later use
	} forEach (_answers apply {_x#0});

	//Update history
	private _nodeHistory = uiNamespace getVariable ["NWG_DLG_nodeHistory",[]];
	private _i = _nodeHistory find _nodeName;
	if (_i != -1) then {_nodeHistory = _nodeHistory select [0,_i]};
	_nodeHistory pushBack _nodeName;
	uiNamespace setVariable ["NWG_DLG_nodeHistory",_nodeHistory];

	//return
	true
};

NWG_DLG_CLI_OnAnswerSelected = {
	private _answerIndex = _this;
	private _answers = uiNamespace getVariable ["NWG_DLG_answers",[]];
	if (_answerIndex < 0 || {_answerIndex >= (count _answers)}) exitWith {false};
	if (call NWG_DLG_CLI_IsUIClosed) exitWith {false};
	uiNamespace setVariable ["NWG_DLG_answers",[]];

	//Extract selected answer
	(_answers#_answerIndex) params ["","_nextNode",["_code",{}]];

	//Extract selected answer as string
	private _aListbox = uiNamespace getVariable ["NWG_DLG_aListbox",controlNull];
	private _answerString = _aListbox lbData _answerIndex;

	//If back - go to previous node
	if (_nextNode isEqualTo NODE_BACK) then {
		private _nodeHistory = uiNamespace getVariable ["NWG_DLG_nodeHistory",[]];
		if ((count _nodeHistory) <= 1) exitWith {_nextNode = NODE_EXIT};//No history - exit
		_nodeHistory deleteAt ((count _nodeHistory) - 1);//Delete current node
		_nextNode = _nodeHistory deleteAt ((count _nodeHistory) - 1);//Extract previous node
		uiNamespace setVariable ["NWG_DLG_nodeHistory",_nodeHistory];
	};

	//If end of dialogue - exit
	if (_nextNode isEqualTo NODE_EXIT) exitWith {
		closeDialog 0;//Close dialogue
		_answerString call _code;//Run code as callback
		true
	};

	//Display selected answer in UI
	private _qListbox = uiNamespace getVariable ["NWG_DLG_qListbox",controlNull];
	_qListbox lbAdd "";//Add empty line to separate records
	_qListbox lbAdd (format [(NWG_DLG_CLI_Settings get "TEMPLATE_SPEAKER_NAME"),(name player)]);//Add speaker name
	_qListbox lbAdd _answerString;//Add answer
	_qListbox ctrlSetScrollValues [1,-1];//Scroll to bottom

	//Clear answers
	_aListbox lbSetCurSel -1;
	lbClear _aListbox;

	//Run code
	_answerString call _code;

	//Load next node
	[_nextNode,/*withDelays:*/true] spawn NWG_DLG_CLI_LoadNextNode;

	//return
	true
};