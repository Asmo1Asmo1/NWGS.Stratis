#include "..\..\globalDefines.h"

/*Any->Progress*/
//Returns player progress array
//_player: Object - The player to get the money of
//return: array - The player progress array (see globalDefines.h) | params ["_exp","_texp","_taxi","_trdr","_comm"]
NWG_fnc_pGetPlayerProgress = {
    // private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		"NWG_fnc_pGetPlayerProgress: Invalid player" call NWG_fnc_logError;
		0
	};
	if (isNull _this) exitWith {
		"NWG_fnc_pGetPlayerProgress: Player obj is null" call NWG_fnc_logError;
		0
	};

    //return
    _this call NWG_PRG_GetPlayerProgress
};

//Adds progress to player (+sends notification)
//params:
//	_player: Object - The player to add the progress to
//  _type: Number - The type of progress to add (see globalDefines.h)
//	_amount: Number - The amount of progress to add to the player (can be negative)
NWG_fnc_pAddPlayerProgress = {
	params ["_player","_type","_amount"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_pAddPlayerProgress: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_pAddPlayerProgress: Player is dead or null" call NWG_fnc_logError;
	};
	if (_amount == 0) exitWith {};//Do nothing, not even log
	if (_type < P__EXP || {_type > P_COMM}) exitWith {
		"NWG_fnc_pAddPlayerProgress: Invalid progress type" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_PRG_AddPlayerProgress}
		else {_this remoteExec ["NWG_fnc_pAddPlayerProgress",_player]};//Call where the player is local
};

//Sets the player progress array (no notification)
//params:
//	_player: Object - The player to set the progress of
//	_progress: array - The progress array to set to the player (see globalDefines.h)
NWG_fnc_pSetPlayerProgress = {
	params ["_player","_progress"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_pSetPlayerProgress: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_pSetPlayerProgress: Player is dead or null" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_PRG_SetPlayerProgress}
		else {_this remoteExec ["NWG_fnc_pSetPlayerProgress",_player]};//Call where the player is local
};

//Sends a notification to a player about their progress change
//params:
//	_player: Object - The player to send the notification to
//	_type: Number - The type of progress that was added or subtracted (see globalDefines.h)
//	_amount: Number - The amount of progress that was added or subtracted
//  _total: Number - The resulting total amount of progress
NWG_fnc_pNotifyProgressChange = {
	params ["_player","_type","_amount","_total"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_pNotifyProgressChange: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_pNotifyProgressChange: Player is dead or null" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_PRG_NotifyProgressChange}
		else {_this remoteExec ["NWG_fnc_pNotifyProgressChange",_player]};//Call where the player is local
};


/*Helper functions to ease getting progress values*/
NWG_fnc_pGetMyExp =        {(_this call NWG_fnc_pGetPlayerProgress) param [P__EXP,0]};
NWG_fnc_pGetMyLvl =        {(_this call NWG_fnc_pGetPlayerProgress) param [P__LVL,0]};
NWG_fnc_pGetMyTaxiLvl =    {(_this call NWG_fnc_pGetPlayerProgress) param [P_TAXI,0]};
NWG_fnc_pGetMyTraderLvl =  {(_this call NWG_fnc_pGetPlayerProgress) param [P_TRDR,0]};
NWG_fnc_pGetMySupportLvl = {(_this call NWG_fnc_pGetPlayerProgress) param [P_COMM,0]};

NWG_fnc_pGetPlayerLevel = {
	// private _player = _this;
	if (isNil "NWG_PRG_GetPlayerLevel") exitWith {-1};
	_this call NWG_PRG_GetPlayerLevel
};

/*Progress buy*/
//Get upgrade values
//params:
//	_type: Number - The type of upgrade to get the values of (see globalDefines.h)
//return: array - The upgrade values [bool,bool,number,number] | params ["_reachedLimit","_canAfford","_priceMoney","_priceExp"]
NWG_fnc_pGetUpgradeValues = {
	// private _type = _this;
	_this call NWG_PRG_GetUpgradeValues
};

//Can upgrade
//params:
//	_type: Number - The type of upgrade to check if can upgrade (see globalDefines.h)
//return: bool - True if can upgrade, false otherwise
NWG_fnc_pCanUpgrade = {
	// private _type = _this;
	_this call NWG_PRG_CanUpgrade
};

//Upgrade
//params:
//	_type: Number - The type of upgrade to upgrade (see globalDefines.h)
//return: bool - True if upgrade successful, false otherwise
//note: Money and Exp are subtracted internally
NWG_fnc_pUpgrade = {
	// private _type = _this;
	_this call NWG_PRG_Upgrade
};


/*Dialogue helpers*/
//Get progress stringified
//params:
// _player: Object - The player to get the progress of
// _progressType: Number - The type of progress to get (see globalDefines.h)
//return: String - The progress stringified
NWG_fnc_pGetProgressAsString = {
    params ["_player","_progressType"];
    if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_pGetProgressAsString: Invalid player" call NWG_fnc_logError;
		""
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_pGetProgressAsString: Player is dead or null" call NWG_fnc_logError;
		""
	};

    _this call NWG_PRG_GetProgressAsString
};

//Get remaining progress stringified
//params:
// _player: Object - The player to get the remaining progress of
// _progressType: Number - The type of progress to get (see globalDefines.h)
//return: String - The remaining progress (until limit) stringified
NWG_fnc_pGetRemainingAsString = {
    params ["_player","_progressType"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_pGetRemainingAsString: Invalid player" call NWG_fnc_logError;
		""
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_pGetRemainingAsString: Player is dead or null" call NWG_fnc_logError;
		""
	};

    _this call NWG_PRG_GetRemainingAsString
};


/*Dev helpers*/
// 10 call NWG_fnc_pDevFullProgress;
NWG_fnc_pDevFullProgress = {
	private _progressLvl = _this;
	for "_i" from P__EXP to P_COMM do {
		[player,_i,_progressLvl] call NWG_fnc_pAddPlayerProgress;
	};
};