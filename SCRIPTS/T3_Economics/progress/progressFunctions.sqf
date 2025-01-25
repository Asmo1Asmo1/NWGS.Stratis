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
NWG_fnc_pGetMyExp = {(player call NWG_fnc_pGetPlayerProgress) param [P__EXP,0]};
NWG_fnc_pGetMyLvl = {(player call NWG_fnc_pGetPlayerProgress) param [P_TEXP,0]};
NWG_fnc_pGetMyTaxiLvl = {(player call NWG_fnc_pGetPlayerProgress) param [P_TAXI,0]};
NWG_fnc_pGetMyTraderLvl = {(player call NWG_fnc_pGetPlayerProgress) param [P_TRDR,0]};
NWG_fnc_pGetMySupportLvl = {(player call NWG_fnc_pGetPlayerProgress) param [P_COMM,0]};
