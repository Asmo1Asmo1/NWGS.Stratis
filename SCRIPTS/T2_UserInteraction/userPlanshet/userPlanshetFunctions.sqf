/*Any<->Client*/
// Open planshet main menu
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenMainMenu = {
	call NWG_UP_OpenMainMenu
};

//Open secondary menu
//params:
// name - name of the menu put in title row
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenSecondaryMenu = {
	// private _windowName = _this;
	_this call NWG_UP_OpenSecondaryMenu
};

//Open secondary menu with dropdown
//note: this is a special type of interface that does not support window name and has no title row
//returns: opened dialog window or 'false' in case of error
NWG_fnc_upOpenSecondaryWithDropdown = {
	_this call NWG_UP_OpenSecondaryWithDropdown
};

//Close all menus
NWG_fnc_upCloseAllMenus = {
	call NWG_UP_CloseAllWindows
};

