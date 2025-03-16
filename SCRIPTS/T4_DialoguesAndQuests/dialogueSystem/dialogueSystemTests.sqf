#define DIALOGUE_NAME "dialogueUI"
#define NPC_NAME "Cicero"
//--- dialogueUI
#define IDC_QLISTBOX 1500
#define IDC_ALISTBOX 1501

NWG_Dialogue_Test_loremIpsum = [
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit",
	"Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
	"Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat",
	"Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur",
	"Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"
];

// call NWG_Dialogue_Test_WithFish to test this dialogue
NWG_Dialogue_Test_WithFish = {
	disableSerialization;

	//Open ui and get controls
	private _gui = createDialog [DIALOGUE_NAME,true];
	if (isNull _gui) exitWith {
		"Err: Could not create dialogue"//Returning string will output it in the console
	};
	private _qListbox = _gui displayCtrl IDC_QLISTBOX;
	if (isNull _qListbox) exitWith {
		"Err: Could not create qListbox"
	};
	private _aListbox = _gui displayCtrl IDC_ALISTBOX;
	if (isNull _aListbox) exitWith {
		"Err: Could not create aListbox"
	};

	//Prefill dialogue listbox
	_gui call NWG_Dialogue_Test_FillListboxes;

	//Setup event handlers
	_qListbox ctrlAddEventHandler ["LBSelChanged",{
		params ["_listBox","_selectedIndex"];
		if (_selectedIndex > -1)
			then {_listBox lbSetCurSel -1};
	}];
	_aListbox ctrlAddEventHandler ["LBSelChanged",{
		params ["_listBox","_selectedIndex"];
		if (_selectedIndex > -1) then {
			private _answer = _listBox lbData _selectedIndex;
			_listBox lbSetCurSel -1;
			[(ctrlParent _listBox),_answer] call NWG_Dialogue_Test_FillListboxes;
		};
	}];
};

NWG_Dialogue_Test_FillListboxes = {
	params ["_gui",["_playerAnswer",""]];

	//Update Q listbox with player answer
	if (_playerAnswer isNotEqualTo "") then {
		private _qListbox = _gui displayCtrl IDC_QLISTBOX;
		_qListbox lbAdd "";
		_qListbox lbAdd (format ["[%1]: %2",(name player),_playerAnswer]);
	};

	//Update Q listbox with NPC questions
	private _questions = [];
	private _qNum = (round (random (count NWG_Dialogue_Test_loremIpsum))) max 1;
	for "_i" from 1 to _qNum do {
		_questions pushBack (selectRandom NWG_Dialogue_Test_loremIpsum);
	};
	private _qListbox = _gui displayCtrl IDC_QLISTBOX;
	_qListbox lbAdd "";
	_qListbox lbAdd (format ["[%1]: %2",NPC_NAME,(_questions deleteAt 0)]);
	{
		_qListbox lbAdd _x;
	} forEach _questions;
	_qListbox ctrlSetScrollValues [1,-1];//Scroll to bottom

	//Update A listbox
	private _answers = [];
	private _aNum = (round (random (count NWG_Dialogue_Test_loremIpsum))) max 1;
	for "_i" from 1 to _aNum do {
		_answers pushBack (selectRandom NWG_Dialogue_Test_loremIpsum);
	};
	private _aListbox = _gui displayCtrl IDC_ALISTBOX;
	lbClear _aListbox;
	{
		_i = _aListbox lbAdd (format ["%1: %2",(_forEachIndex + 1),_x]);
		_aListbox lbSetData [_i,_x];
	} forEach _answers;
};

//===========================================
//===========================================
//Answers generation
NWG_Dialogue_Test_GenerateAnswers = {
	private _array = ["Apple","Orange","Banana","Pineapple","Kiwi","Mango","Peach","Pear","Plum","Cherry"];
	private _count = (round (random 5)) max 1;
	private _generated = [];
	for "_i" from 1 to _count do {
		_generated pushBack [(selectRandom _array),"TEST_08"];
	};
	_generated
};


