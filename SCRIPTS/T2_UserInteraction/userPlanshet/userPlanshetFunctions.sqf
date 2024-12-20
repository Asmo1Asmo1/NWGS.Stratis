/*Any<->Client*/
// Open planshet main menu
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenMainMenu = {
	call NWG_UP_OpenMainMenu
};

//Open secondary menu
//params:
// name - name of the menu to put into title row (if title row is enabled)
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenSecondaryMenu = {
	// private _windowName = _this;
	_this call NWG_UP_OpenSecondaryMenu
};

//Open secondary menu prefilled with items
//params:
// name - name of the menu to put into title row (if title row is enabled)
// (optional) items - array of strings - items to put into listbox
// (optional) data  - array of strings - data to put into listbox for each item (if omitted, empty string is used)
// (optional) callback - function to call when item is selected | params: ["_listBox","_selectedIndex","_withTitleRow"];
//		- _listBox - listbox control
//		- _selectedIndex - index of the selected item
//		- _withTitleRow - true if title row is enabled (meaning that item 0 is a title row and actual items start from index 1)
// returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenSecondaryMenuPrefilled = {
	// params ["_windowName",["_items",[]],["_data",[]],["_callback",{}]];
	_this call NWG_UP_OpenSecondaryMenuPrefilled
};

//Open secondary menu with dropdown
//note: this is a special type of interface that does not support window name and has no title row
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenSecondaryWithDropdown = {
	_this call NWG_UP_OpenSecondaryWithDropdown
};

//Get all opened menus
//returns: array of opened menus
NWG_fnc_upGetAllMenus = {
	call NWG_UP_GetAllWindows
};

//Close all menus
NWG_fnc_upCloseAllMenus = {
	call NWG_UP_CloseAllWindows
};

