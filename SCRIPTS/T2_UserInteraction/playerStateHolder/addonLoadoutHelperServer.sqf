/*
	Addon to help get/set player loadout
*/
NWG_PSH_LH_GetLoadout = {
	// private _player = _this;
	getUnitLoadout _this
};

NWG_PSH_LH_SetLoadout = {
	params ["_player","_loadout"];
	_player setUnitLoadout _loadout;
	remoteExec ["NWG_fnc_invInvokeChangeCheck",_player];
};