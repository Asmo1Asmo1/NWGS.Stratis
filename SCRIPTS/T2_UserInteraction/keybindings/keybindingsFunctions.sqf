//Get all keybindings
//returns: array of keybindings | params ["_key","_expression","_locDescr","_code","_blockKeyDown"]
//note: keybindings returned in the same order as they are defined, so it is safe to use index for other functions
NWG_fnc_kbGetAllKeybindings = {
	NWG_KB_Keybindings
};

//Is key supported
//params: key - number
//returns: boolean
NWG_fnc_kbIsKeySupported = {
	// private _key = _this;
	_this in NWG_KB_keyToButtonMap
};

//Update keybinding
//params:
// index - number, index of the keybinding to update
// newKey - number, new key to set
// isShift - boolean, is shift key pressed
// isCtrl - boolean, is ctrl key pressed
// isAlt - boolean, is alt key pressed
//returns: boolean, true if the keybinding was updated, false otherwise
NWG_fnc_kbUpdateKeybinding = {
	// params ["_index","_newKey","_isShift","_isCtrl","_isAlt"];
	_this call NWG_KB_UpdateKeybinding;
};

//Drop keybinding
//params: index - number, index of the keybinding to drop
//returns: boolean, true if the keybinding was dropped, false otherwise
NWG_fnc_kbDropKeybinding = {
	// private _index = _this;
	_this call NWG_KB_DropKeybinding;
};

//Toggle keybinding key down block
//params: index - number, index of the keybinding to toggle
//returns: boolean, true if the keybinding was changed, false otherwise
NWG_fnc_kbToggleKeybindingKeyDownBlock = {
	// private _index = _this;
	_this call NWG_KB_ToggleKeybindingKeyDownBlock;
};

