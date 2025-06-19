/*
	Addon to help get/set player loadout
*/
private _Init = {
	waitUntil {
		sleep 0.1;
		if (isNull (findDisplay 46)) exitWith {false};//Game display not found
		if (isNull player) exitWith {false};//Player not found
		if (!local player) exitWith {false};//Player is not local yet
		true
	};
	player action ["SwitchWeapon",player,player,-1];//Switch weapon to -1 (legacy from Arma 2, puts all weapons away)
};

NWG_PSH_LH_SetLoadout_Core = {
	private _loadout = _this;
	if (isNil "_loadout" || {_loadout isEqualTo []}) exitWith {
		(format ["NWG_PSH_LH_SetLoadout_Core: Loadout is nil or empty for player '%1'",(name player)]) call NWG_fnc_logError;
	};
	[player,_loadout,{call NWG_fnc_invInvokeChangeCheck}] call NWG_fnc_setUnitLoadout;
};

[] spawn _Init;