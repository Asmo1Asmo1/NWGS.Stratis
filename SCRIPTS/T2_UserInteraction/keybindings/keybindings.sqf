//================================================================================================================
//================================================================================================================
//Defines
#define KEY_CODE 0
#define KEY_EXPRESSION 1
#define LOC_DESCR 2
#define CODE_TO_RUN 3
#define BLOCK_KEY_DOWN 4

#define KEY_NOT_SET -1
#define EXPRESSION_NOT_SET ""

#define SAVE_IN_DEBUG_MODE false
#define PROTECTED_INDEX 0

//================================================================================================================
//================================================================================================================
//Keybindings
/*params ["_key","_expression","_locDescr","_code","_blockKeyDown"]*/
/*note: we use separate missionNamespace variable instead of settings to speed things up, this logic runs every key press after all*/
/*note: first keybinding is protected from being unassigned*/
NWG_KB_Keybindings = [
	[61,"F3","#KB_USER_PLANSHET#",{call NWG_fnc_upOpenMainMenu},true],
	[59,"F1","#KB_ACT_EARPLUGS#",{call NWG_fnc_akToggleEarPlugs},true],
	[60,"F2","#KB_ACT_WEAPONS_AWAY#",{call NWG_fnc_akWeaponsAway},true],
	[62,"F4","#KB_VIEW_DISTANCE#",{call NWG_fnc_vdOpenMenu},true],
	[57,"Space","#KB_ACT_PARACHUTE_DEPLOYMENT#",{call NWG_fnc_akParachuteDeployment},false],
	[18,"Shift + E","#AV_JUMP_OUT_TITLE#",{call NWG_fnc_avJumpOut},false],
	[25,"P","#AV_SEAT_SWITCH_NEXT_TITLE#",{call NWG_fnc_avSeatSwitchNext},false],
	[24,"O","#AV_SEAT_SWITCH_PREV_TITLE#",{call NWG_fnc_avSeatSwitchPrev},false],
	[KEY_NOT_SET,EXPRESSION_NOT_SET,"#AV_ALL_WHEEL_TITLE_ON#",{call NWG_fnc_avAllWheelOn},false],
	[KEY_NOT_SET,EXPRESSION_NOT_SET,"#AV_ALL_WHEEL_TITLE_OFF#",{call NWG_fnc_avAllWheelOff},false],
	[KEY_NOT_SET,EXPRESSION_NOT_SET,"#AV_QUICK_VEH_ACCESS_TITLE#",{call NWG_fnc_akQuickVehicleAccess},false]
];

//================================================================================================================
//================================================================================================================
//Fields
/*Key to button mapping*//*see: https://community.bistudio.com/wiki/DIK_KeyCodes */
NWG_KB_keyToButtonMap = createHashMapFromArray [
	/*Function Keys F1..F15*/
	[59,"F1"],// F1	F1..F15	DIK_F1	0x3B	59	N/A
	[60,"F2"],// F2	F1..F15	DIK_F2	0x3C	60	N/A
	[61,"F3"],// F3	F1..F15	DIK_F3	0x3D	61	N/A
	[62,"F4"],// F4	F1..F15	DIK_F4	0x3E	62	N/A
	[63,"F5"],// F5	F1..F15	DIK_F5	0x3F	63	N/A
	[64,"F6"],// F6	F1..F15	DIK_F6	0x40	64	N/A
	[65,"F7"],// F7	F1..F15	DIK_F7	0x41	65	N/A
	[66,"F8"],// F8	F1..F15	DIK_F8	0x42	66	N/A
	[67,"F9"],// F9	F1..F15	DIK_F9	0x43	67	N/A
	[68,"F10"],// F10	F1..F15	DIK_F10	0x44	68	N/A
	[87,"F11"],// F11	F1..F15	DIK_F11	0x57	87	N/A
	[88,"F12"],// F12	F1..F15	DIK_F12	0x58	88	N/A
	[100,"F13"],// F13	F1..F15	DIK_F13	0x64	100	NEC PC98
	[101,"F14"],// F14	F1..F15	DIK_F14	0x65	101	NEC PC98
	[102,"F15"],// F15	F1..F15	DIK_F15	0x66	102	NEC PC98

	/*Numbers 0..9*/
	[11,"0"],// 0	0..9	DIK_0	0x0B	11	N/A
	[2,"1"],// 1	0..9	DIK_1	0x02	2	N/A
	[3,"2"],// 2	0..9	DIK_2	0x03	3	N/A
	[4,"3"],// 3	0..9	DIK_3	0x04	4	N/A
	[5,"4"],// 4	0..9	DIK_4	0x05	5	N/A
	[6,"5"],// 5	0..9	DIK_5	0x06	6	N/A
	[7,"6"],// 6	0..9	DIK_6	0x07	7	N/A
	[8,"7"],// 7	0..9	DIK_7	0x08	8	N/A
	[9,"8"],// 8	0..9	DIK_8	0x09	9	N/A
	[10,"9"],// 9	0..9	DIK_9	0x0A	10

	/*Numpad Keys 0..9*/
	[82,"Num 0"],// 0	Numpad	DIK_NUMPAD0	0x52	82	N/A
	[79,"Num 1"],// 1	Numpad	DIK_NUMPAD1	0x4F	79	N/A
	[80,"Num 2"],// 2	Numpad	DIK_NUMPAD2	0x50	80	N/A
	[81,"Num 3"],// 3	Numpad	DIK_NUMPAD3	0x51	81	N/A
	[75,"Num 4"],// 4	Numpad	DIK_NUMPAD4	0x4B	75	N/A
	[76,"Num 5"],// 5	Numpad	DIK_NUMPAD5	0x4C	76	N/A
	[77,"Num 6"],// 6	Numpad	DIK_NUMPAD6	0x4D	77	N/A
	[71,"Num 7"],// 7	Numpad	DIK_NUMPAD7	0x47	71	N/A
	[72,"Num 8"],// 8	Numpad	DIK_NUMPAD8	0x48	72	N/A
	[73,"Num 9"],// 9	Numpad	DIK_NUMPAD9	0x49	73	N/A

	/*Alphabet Keys a..z*/
	[30,"A"],// A	DIK_A	0x1E	30	N/A
	[48,"B"],// B	DIK_B	0x30	48	N/A
	[46,"C"],// C	DIK_C	0x2E	46	N/A
	[32,"D"],// D	DIK_D	0x20	32	N/A
	[18,"E"],// E	DIK_E	0x12	18	N/A
	[33,"F"],// F	DIK_F	0x21	33	N/A
	[34,"G"],// G	DIK_G	0x22	34	N/A
	[35,"H"],// H	DIK_H	0x23	35	N/A
	[23,"I"],// I	DIK_I	0x17	23	N/A
	[36,"J"],// J	DIK_J	0x24	36	N/A
	[37,"K"],// K	DIK_K	0x25	37	N/A
	[38,"L"],// L	DIK_L	0x26	38	N/A
	[50,"M"],// M	DIK_M	0x32	50	N/A
	[49,"N"],// N	DIK_N	0x31	49	N/A
	[24,"O"],// O	DIK_O	0x18	24	N/A
	[25,"P"],// P	DIK_P	0x19	25	N/A
	[16,"Q"],// Q	DIK_Q	0x10	16	N/A
	[19,"R"],// R	DIK_R	0x13	19	N/A
	[31,"S"],// S	DIK_S	0x1F	31	N/A
	[20,"T"],// T	DIK_T	0x14	20	N/A
	[22,"U"],// U	DIK_U	0x16	22	N/A
	[47,"V"],// V	DIK_V	0x2F	47	N/A
	[17,"W"],// W	DIK_W	0x11	17	N/A
	[45,"X"],// X	DIK_X	0x2D	45	N/A
	[21,"Y"],// Y	DIK_Y	0x15	21	N/A
	[44,"Z"],// Z	DIK_Z	0x2C	44	N/A

	/*Symbol Keys*/
	[146,":"],// 				Graphics	DIK_COLON		0x92	146	NEC PC98
	[147,"_"],// 				Graphics	DIK_UNDERLINE	0x93	147	NEC PC98
	[12,"-"],// Minus		Graphics	DIK_MINUS		0x0C	12	N/A
	[13,"="],// 				Graphics	DIK_EQUALS		0x0D	13	N/A
	[26,"["],// 				Graphics	DIK_LBRACKET	0x1A	26	N/A
	[27,"]"],// 				Graphics	DIK_RBRACKET	0x1B	27	N/A
	[39,";"],// Semicolon	Graphics	DIK_SEMICOLON	0x27	39	N/A
	[40,"'"],// Apostrophe	Graphics	DIK_APOSTROPHE	0x28	40	N/A
	[41,"`"],// Accent grave	Graphics	DIK_GRAVE		0x29	41	N/A
	[43,"\"],// Backslash	Graphics	DIK_BACKSLASH	0x2B	43	N/A
	[51,","],// Comma		Graphics	DIK_COMMA		0x33	51	N/A
	[52,"."],// Period (main)Graphics	DIK_PERIOD		0x34	52	N/A
	[53,"/"],// Slash (main)	Graphics	DIK_SLASH		0x35	53	N/A
	[55,"Num *"],// * (numpad)	Graphics	DIK_MULTIPLY		0x37	55	N/A
	[74,"Num -"],// - (numpad)	Graphics	DIK_SUBTRACT		0x4A	74	N/A
	[78,"Num +"],// + (numpad)	Graphics	DIK_ADD			0x4E	78	N/A
	[83,"Num ."],// . (numpad)	Graphics	DIK_DECIMAL	0x53	83	N/A
	[141,"Num ="],// = (numpad)	Graphics	DIK_NUMPADEQUALS	0x8D	141	NEC PC98
	[181,"Num /"],// / (numpad)	Graphics	DIK_NUMPADSLASH	181	N/A

	/*Arrow Keypad*/
	[199,"Home"],// ArrowKeypad	DIK_HOME	0xC7	199	Home on arrow keypad
	[200,"Up"],// ArrowKeypad	DIK_UP	0xC8	200	UpArrow on arrow keypad
	[201,"PgUp"],// ArrowKeypad	DIK_PRIOR	0xC9	201	PgUp on arrow keypad
	[203,"Left"],// ArrowKeypad	DIK_LEFT	0xCB	203	LeftArrow on arrow keypad
	[205,"Right"],// ArrowKeypad	DIK_RIGHT	0xCD	205	RightArrow on arrow keypad
	[207,"End"],// ArrowKeypad	DIK_END	0xCF	207	End on arrow keypad
	[208,"Down"],// ArrowKeypad	DIK_DOWN	0xD0	208	DownArrow on arrow keypad
	[209,"PgDn"],// ArrowKeypad	DIK_NEXT	0xD1	209	PgDn on arrow keypad
	[210,"Insert"],// ArrowKeypad	DIK_INSERT	0xD2	210	Insert on arrow keypad

	/*Other Keys*/
	[57,"Space"]// Space		Graphics	DIK_SPACE		0x39	57	N/A
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Setup key handler
	waitUntil {!isNull (findDisplay 46)};//46 is a mission display, see https://community.bistudio.com/wiki/findDisplay
	findDisplay 46 displayAddEventHandler ["KeyDown", {
		// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
		_this call NWG_KB_OnKeyDown;
	}];

	//Load keybindings
	NWG_KB_Keybindings call NWG_KB_LoadKeybindings;
};

//================================================================================================================
//================================================================================================================
//On Key Down
NWG_KB_OnKeyDown = {
	// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
	params ["","_key","_s","_c","_a"];

	//Simple check that key is part of any keybindings
	if ((NWG_KB_Keybindings findIf {(_x#KEY_CODE) == _key}) == -1) exitWith {false};

	//Find exact keybinding by expression (can overlap, e.g.: "Ctrl + F2" and "F2")
	private _keybindings = NWG_KB_Keybindings;
	private _i = -1;
	if (_s || _c || _a) then {
		private _exp = [_key,_s,_c,_a] call NWG_KB_KeyToExpression;
		_i = _keybindings findIf {(_x#KEY_EXPRESSION) isEqualTo _exp};
	};
	if (_i == -1) then {
		private _exp = [_key,false,false,false] call NWG_KB_KeyToExpression;
		_i = _keybindings findIf {(_x#KEY_EXPRESSION) isEqualTo _exp};
	};
	if (_i == -1) exitWith {false};

	//Execute the expressions
	// params ["_key","_expression","_locDescr","_code","_blockKeyDown"];
	private _keybinding = _keybindings#_i;
	call (_keybinding param [CODE_TO_RUN,{}]);
	//return
	(_keybinding param [BLOCK_KEY_DOWN,false])
};

//================================================================================================================
//================================================================================================================
//Key to expression
NWG_KB_KeyToExpression = {
	params ["_key","_isShift","_isCtrl","_isAlt"];
	private _button = NWG_KB_keyToButtonMap get _key;
	if (isNil "_button") exitWith {false};

	//Ctrl > Alt > Shift > Default
	switch (true) do {
		case (!_isShift && !_isCtrl && !_isAlt):{_button};
		case (_isShift  && _isCtrl  && _isAlt):	{format ["Ctrl + Alt + Shift + %1",_button]};
		case (_isShift  && _isCtrl): 			{format ["Ctrl + Shift + %1",_button]};
		case (_isShift  && _isAlt): 			{format ["Alt + Shift + %1",_button]};
		case (_isCtrl   && _isAlt): 			{format ["Ctrl + Alt + %1",_button]};
		case (_isShift): 						{format ["Shift + %1",_button]};
		case (_isCtrl): 						{format ["Ctrl + %1",_button]};
		case (_isAlt): 							{format ["Alt + %1",_button]};
		default {_button};
	}
};

//================================================================================================================
//================================================================================================================
//Update keybindings
NWG_KB_UpdateKeybinding = {
	params ["_index","_newKey","_isShift","_isCtrl","_isAlt"];
	//Check arguments
	if (_index < 0 || _index >= (count NWG_KB_Keybindings)) exitWith {false};
	if !(_newKey in NWG_KB_keyToButtonMap) exitWith {false};

	//Generate new expression
	private _newExpression = [_newKey,_isShift,_isCtrl,_isAlt] call NWG_KB_KeyToExpression;

	//Iterate over all keybindings, drop those that have the same expression, set new expression
	{
		if (_forEachIndex != PROTECTED_INDEX && {(_x#KEY_EXPRESSION) isEqualTo _newExpression}) then {
			_x set [KEY_CODE,KEY_NOT_SET];
			_x set [KEY_EXPRESSION,EXPRESSION_NOT_SET];
		};

		if (_forEachIndex == _index) then {
			_x set [KEY_CODE,_newKey];
			_x set [KEY_EXPRESSION,_newExpression];
		};
	} forEach NWG_KB_Keybindings;

	//Save keybindings
	NWG_KB_Keybindings call NWG_KB_SaveKeybindings;

	//return
	true
};

NWG_KB_DropKeybinding = {
	private _index = _this;
	if (_index == PROTECTED_INDEX) exitWith {false};
	if (_index < 0 || _index >= (count NWG_KB_Keybindings)) exitWith {false};

	private _keybinding = NWG_KB_Keybindings#_index;
	_keybinding set [KEY_CODE,KEY_NOT_SET];
	_keybinding set [KEY_EXPRESSION,EXPRESSION_NOT_SET];

	//Save keybindings
	NWG_KB_Keybindings call NWG_KB_SaveKeybindings;

	//return
	true
};

NWG_KB_ToggleKeybindingKeyDownBlock = {
	private _index = _this;
	if (_index < 0 || _index >= (count NWG_KB_Keybindings)) exitWith {false};
	private _keybinding = NWG_KB_Keybindings#_index;
	_keybinding set [BLOCK_KEY_DOWN,!(_keybinding#BLOCK_KEY_DOWN)];

	//Save keybindings
	NWG_KB_Keybindings call NWG_KB_SaveKeybindings;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Save/Load
NWG_KB_SaveKeybindings = {
	private _keybindings = _this;
	private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
	if (_isDevBuild && !SAVE_IN_DEBUG_MODE) exitWith {true};//Return true as if saving is successful

	private _saveStruct = _keybindings apply {[_x#KEY_CODE,_x#KEY_EXPRESSION,_x#BLOCK_KEY_DOWN]};//Save only those that can be changed
	profileNamespace setVariable ["NWG_KB_Keybindings",_saveStruct];
	saveProfileNamespace;

	//return
	true
};

NWG_KB_LoadKeybindings = {
	private _keybindings = _this;
	private _loadStruct = profileNamespace getVariable ["NWG_KB_Keybindings",[]];

	//Update keybindings (will work fine if we add or remove last keybindings, not so fine if we change the order, try to avoid that)
	{
		private _loaded = _loadStruct param [_forEachIndex,nil];
		if (isNil "_loaded") exitWith {};
		_loaded params ["_key","_expression","_blockKeyDown"];
		_x set [KEY_CODE,_key];
		_x set [KEY_EXPRESSION,_expression];
		_x set [BLOCK_KEY_DOWN,_blockKeyDown];
	} forEach _keybindings;

	//return
	_keybindings
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;