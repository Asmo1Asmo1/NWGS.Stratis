// call NWG_KB_SimpleKeyBindings_Test
NWG_KB_SimpleKeyBindings_Test = {
	/*params ["_key","_expression","_locDescr","_code","_blockKeyDown"]*/
	NWG_KB_Keybindings pushBack [17,"W","",{systemChat "Pressed W"},false];
	NWG_KB_Keybindings pushBack [17,"Ctrl + W","",{systemChat "Pressed Ctrl + W"},false];
	NWG_KB_Keybindings pushBack [17,"Shift + W","",{systemChat "Pressed Shift + W"},false];
	NWG_KB_Keybindings pushBack [17,"Ctrl + Shift + W","",{systemChat "Pressed Ctrl + Shift + W"},false];
	NWG_KB_Keybindings pushBack [31,"S","",{systemChat "Pressed S (+blocking)"},true];
};