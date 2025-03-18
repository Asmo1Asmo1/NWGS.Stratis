/*Any->Wallet*/
//Returns the amount of money a player has
//params:
//	_player: Object - The player to get the money of
//return: Number - The amount of money the player has
NWG_fnc_wltGetPlayerMoney = {
    // private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		"NWG_fnc_wltGetPlayerMoney: Invalid player" call NWG_fnc_logError;
		0
	};
	if (isNull _this) exitWith {
		"NWG_fnc_wltGetPlayerMoney: Player obj is null" call NWG_fnc_logError;
		0
	};

    //return
    _this call NWG_WLT_GetPlayerMoney
};

//Returns initial money amount that player starts with
//note: initial money setting exists only on client side
//return: Number - The initial money amount
NWG_fnc_wltGetInitialMoney = {
	if (isNil "NWG_WLT_Settings") exitWith {
		"NWG_fnc_wltGetInitialMoney: NWG_WLT_Settings is not defined, make sure you call this function on client side" call NWG_fnc_logError;
		0
	};
	NWG_WLT_Settings get "INITIAL_MONEY"
};

//Adds money to a player (+sends notification)
//params:
//	_player: Object - The player to add the money to
//	_amount: Number - The amount of money to add to the player (can be negative)
NWG_fnc_wltAddPlayerMoney = {
	params ["_player","_amount"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_wltAddPlayerMoney: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_wltAddPlayerMoney: Player is dead or null" call NWG_fnc_logError;
	};
	if (isNil "_amount") exitWith {
		"NWG_fnc_wltAddPlayerMoney: Amount is nil" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_WLT_AddPlayerMoney}
		else {_this remoteExec ["NWG_fnc_wltAddPlayerMoney",_player]};//Call where the player is local
};

//Sets the amount of money a player has (no notification)
//params:
//	_player: Object - The player to set the money of
//	_amount: Number - The amount of money to set to the player
NWG_fnc_wltSetPlayerMoney = {
	params ["_player","_amount"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_wltSetPlayerMoney: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_wltSetPlayerMoney: Player is dead or null" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_WLT_SetPlayerMoney}
		else {_this remoteExec ["NWG_fnc_wltSetPlayerMoney",_player]};//Call where the player is local
};

//Returns the sum of money the group has
//params:
//	_group: Group - The group to get the money of
//return: Number - The sum of money the group has
NWG_fnc_wltGetGroupMoney = {
	// private _group = _this;
	if (!(_this isEqualType grpNull) || {isNull _this}) exitWith {
		"NWG_fnc_wltGetGroupMoney: Invalid group" call NWG_fnc_logError;
		0
	};

	//return
	_this call NWG_WLT_GetGroupMoney
};

//Splits money between players in a group
//params:
//	_group: Group - The group to split the money between
//	_money: Number - The amount of money to split
//note: positive amount will be split equally, negative will be balanced out if any player has less than fair share
NWG_fnc_wltSplitMoneyToGroup = {
	params ["_group","_money"];
	if (!(_group isEqualType grpNull) || {isNull _group}) exitWith {
		"NWG_fnc_wltSplitMoneyToGroup: Invalid group" call NWG_fnc_logError;
	};

	_this call NWG_WLT_SplitMoneyToGroup
};

//Formats money into a string
//params:
//	_money: Number - The amount of money to format
//return: String - The formatted money string
NWG_fnc_wltFormatMoney = {
	// private _money = _this;
	if !(_this isEqualType 0) exitWith {
		"NWG_fnc_wltFormatMoney: Invalid money" call NWG_fnc_logError;
		""
	};

	//return
	_this call NWG_WLT_MoneyToString
};

//Sends a notification to a player about their money change
//params:
//	_player: Object - The player to send the notification to
//	_amount: Number - The amount of money that was added or subtracted
NWG_fnc_wltNotifyMoneyChange = {
	params ["_player","_amount"];
	if !(_player isEqualType objNull) exitWith {
		"NWG_fnc_wltNotifyMoneyChange: Invalid player" call NWG_fnc_logError;
	};
	if (!alive _player || {isNull _player}) exitWith {
		"NWG_fnc_wltNotifyMoneyChange: Player is dead or null" call NWG_fnc_logError;
	};

	if (local _player)
		then {_this call NWG_WLT_NotifyMoneyChange}
		else {_this remoteExec ["NWG_fnc_wltNotifyMoneyChange",_player]};//Call where the player is local
};
