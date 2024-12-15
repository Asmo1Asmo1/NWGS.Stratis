//Fill text with player money
//params:
// 0: gui - ui display
// 1: idc - idc of the text
//returns:
// true if successful, false otherwise
NWG_fnc_uiHelperFillTextWithPlayerMoney = {
	// params ["_gui","_idc"];
	_this call NWG_UIH_FillTextWithPlayerMoney;
};

//Blink on success
//params:
// 0: gui - ui display
// 1: idc - idc of the text
//returns:
// true if successful, false otherwise
NWG_fnc_uiHelperBlinkOnSuccess = {
	// params ["_gui","_idc"];
	_this call NWG_UIH_BlinkOnSuccess;
};

//Blink on error
//params:
// 0: gui - ui display
// 1: idc - idc of the text
//returns:
// true if successful, false otherwise
NWG_fnc_uiHelperBlinkOnError = {
	// params ["_gui","_idc"];
	_this call NWG_UIH_BlinkOnError;
};
