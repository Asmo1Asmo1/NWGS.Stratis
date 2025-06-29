//Opens map
//Params:
// - _onMapClick: Callback for map click (private _clickPos = _this)
// - _onMapClose: Callback for map close
//note: adds map to player inventory if not present
NWG_fnc_moOpen = {
	// params [["_onMapClick",{}],["_onMapClose",{}]];
	_this call NWG_MO_OpenMap;
};

//Closes map
//note: does not invoke _onMapClose callback from `NWG_fnc_moOpen`
NWG_fnc_moClose = {
	call NWG_MO_CloseMap;
};