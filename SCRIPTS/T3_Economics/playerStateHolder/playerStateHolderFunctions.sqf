/*Any->Client*/
//Invoke state update on the client side
//params: _reason - string - reason for state change (used only for logging)
//note: use this function from any client module or event, it uses buffering and handles server notification
//note: state is not updated automatically, usage of this function is required
NWG_fnc_pshOnClientStateChange = {
	// private _reason = _this;
	_this call NWG_PSH_CLI_OnClientStateChange;
};

/*Any->Server*/
//Sync holded states with database
//note: states are not synced automatically, usage of this function is required
//note: sync is a heavy operation, use 'spawn'
NWG_fnc_pshSyncRequest = {
	call NWG_PSH_SER_SyncStates;
};

/*Client<->Server*/
//Invokes state apply to the player on player join
NWG_fnc_pshOnPlayerJoined = {
	private _player = _this;
	if !(_player isEqualType objNull) exitWith {
		(format["NWG_fnc_pshOnPlayerJoined: Invalid player object, expected obj, got '%1'",_player]) call NWG_fnc_logError;
	};
	if (isNull _player) exitWith {
		"NWG_fnc_pshOnPlayerJoined: Player object is null" call NWG_fnc_logError;
	};

	if (isServer)
		then {_player call NWG_PSH_SER_OnStateApplyRequest}
		else {_player remoteExec ["NWG_fnc_pshOnPlayerJoined",2]};
};

//Invokes state update on the server side
NWG_fnc_pshStateUpdateRequest = {
	private _player = _this;
	if !(_player isEqualType objNull) exitWith {
		(format["NWG_fnc_pshStateUpdateRequest: Invalid player object, expected obj, got '%1'",_player]) call NWG_fnc_logError;
	};
	if (isNull _player) exitWith {
		"NWG_fnc_pshStateUpdateRequest: Player object is null" call NWG_fnc_logError;
	};

	if (isServer)
		then {_player call NWG_PSH_SER_OnStateUpdateRequest}
		else {_player remoteExec ["NWG_fnc_pshStateUpdateRequest",2]};
};
