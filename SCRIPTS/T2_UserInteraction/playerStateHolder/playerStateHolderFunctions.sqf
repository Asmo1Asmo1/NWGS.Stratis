/*Any->Client*/
//Invoke state update on the client side
//params: _reason - string - reason for state change (used only for logging)
//note: use this function from any client module or event, it uses buffering and handles server notification
NWG_fnc_pshInvokeClientStateChange = {
	// private _reason = _this;
	_this call NWG_PSH_CLI_OnClientStateChange;
};

/*Any->Server*/
//Sync player state with database
NWG_fnc_pshInvokeSync = {
	call NWG_PSH_SER_SyncStates;
};

/*Client<->Server*/
//Invoke state apply to the player on player join
NWG_fnc_pshInvokePlayerJoin = {
	private _player = _this;
	if !(_player isEqualType objNull) exitWith {
		(format["NWG_fnc_pshInvokePlayerJoin: Invalid player object, expected obj, got '%1'",_player]) call NWG_fnc_logError;
	};
	if (isNull _player) exitWith {
		"NWG_fnc_pshInvokePlayerJoin: Player object is null" call NWG_fnc_logError;
	};

	if (isServer)
		then {_player call NWG_PSH_SER_OnPlayerJoin}
		else {_player remoteExec ["NWG_fnc_pshInvokePlayerJoin",2]};
};

//Invoke state update on the server side
NWG_fnc_pshInvokeStateUpdate = {
	private _player = _this;
	if !(_player isEqualType objNull) exitWith {
		(format["NWG_fnc_pshInvokeStateUpdate: Invalid player object, expected obj, got '%1'",_player]) call NWG_fnc_logError;
	};
	if (isNull _player) exitWith {
		"NWG_fnc_pshInvokeStateUpdate: Player object is null" call NWG_fnc_logError;
	};

	if (isServer)
		then {_player call NWG_PSH_SER_OnStateUpdateRequest}
		else {_player remoteExec ["NWG_fnc_pshInvokeStateUpdate",2]};
};
