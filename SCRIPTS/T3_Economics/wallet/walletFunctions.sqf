/*Any->Any*/
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

/*Any->Client*/
//Returns initial money amount that player starts with
//note: initial money setting exists only on client side
//return: Number - The initial money amount
NWG_fnc_wltGetInitialMoney = {
	if (isNil "NWG_WLT_CLI_Settings") exitWith {
		"NWG_fnc_wltGetInitialMoney: NWG_WLT_CLI_Settings is not defined, make sure you call this function on client side" call NWG_fnc_logError;
		0
	};
	NWG_WLT_CLI_Settings get "INITIAL_MONEY"
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

	if (isServer)
		then {_this call NWG_WLT_SplitMoneyToGroup}
		else {_this remoteExec ["NWG_fnc_wltSplitMoneyToGroup",2]};
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

/*Any->Server*/
//Distributes money between players (server-side with checks)
//note: It does not recalculate distribution in case of errors and just proceeds according to arguments given
//params:
//	_unitMoneyPairs: Array - Array of pairs of units and money to distribute (e.g. [[_unit1,100],[_unit2,200]])
//	_caller: String - (optional, default: "UNKNOWN") The caller of the function (used for logging only)
//	_cancelOnError: Boolean - (optional, default: false) If true, distribution will be cancelled if there is at least one error in arguments
NWG_fnc_wltDistributeMoneys = {
	// params ["_unitMoneyPairs",["_caller","UNKNOWN"],["_cancelOnError",false]];
	if (isServer)
		then {_this call NWG_WLT_DistributeMoneys}
		else {_this remoteExec ["NWG_fnc_wltDistributeMoneys",2]};
};