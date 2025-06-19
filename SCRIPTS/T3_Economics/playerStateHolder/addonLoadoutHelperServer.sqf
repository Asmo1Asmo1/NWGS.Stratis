/*
	Addon to help get/set player loadout
*/
NWG_PSH_LH_GetLoadout = {
	// private _player = _this;
	getUnitLoadout _this
};

NWG_PSH_LH_SetLoadout = {
	params ["_player","_loadout"];
	if (isNil "_loadout" || {_loadout isEqualTo []}) exitWith {
		(format ["NWG_PSH_LH_SetLoadout: Loadout is nil or empty for player '%1'",(name _player)]) call NWG_fnc_logError;
	};
	_loadout remoteExec ["NWG_PSH_LH_SetLoadout_Core",_player];
};