/*
	Player state holder
	States to carry:
		T1: -
		T2: loadout, additionalWeapon;
		T3: lootStorage, wallet, progress
*/

//================================================================================================================
//================================================================================================================
//Defines
#define STATE_GET_CODE 0
#define STATE_SET_CODE 1

#define STATE_DIRTY "is_dirty"

//================================================================================================================
//================================================================================================================
//Settings
NWG_PSH_SER_Settings = createHashMapFromArray [
/*
	State holding
	State|GetCode|SetCode
	get params: _player
	set params: [_player,_data]
*/
	["STATES_TO_HOLD",createHashMapFromArray [
		["loadout",		[{_this call NWG_PSH_LH_GetLoadout},	 {_this call NWG_PSH_LH_SetLoadout}]],
		["add_weapon",	[{_this call NWG_fnc_awGetHolderData},	 {_this call NWG_fnc_awAddHolderDataAndCreateObject}]],
		["loot_storage",[{_this call NWG_fnc_lsGetPlayerLoot},	 {_this call NWG_fnc_lsSetPlayerLoot}]],
		["wallet",		[{_this call NWG_fnc_wltGetPlayerMoney}, {_this call NWG_fnc_wltSetPlayerMoney}]],
		["progress",	[{_this call NWG_fnc_pGetPlayerProgress},{_this call NWG_fnc_pSetPlayerProgress}]],
		["garage",		[{_this call NWG_fnc_grgGetGarageArray}, {_this call NWG_fnc_grgSetGarageArray}]]
	]],

/*
	State DB syncing
*/
	["FUNC_NEW_STATE_BY_ID", {_this call NWG_fnc_dbCreatePlayer}],//params: _playerID | returns: boolean
	["FUNC_LOAD_STATE_BY_ID",{_this call NWG_fnc_dbGetPlayer}],   //params: _playerID | returns: hashmap or false in case of error
	["FUNC_SAVE_STATE_BY_ID",{_this call NWG_fnc_dbUpdatePlayer}],//params: [_playerID, _hashmap] | returns: boolean

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_PSH_SER_playerStateCache = createHashMap;

//================================================================================================================
//================================================================================================================
//Player ID
NWG_PSH_SER_GetPlayerId = {
	// private _player = _this;

	private _cached = _this getVariable "NWG_PSH_SER_steamId";
	if (!isNil "_cached") exitWith {_cached};

	if (!isPlayer _this) exitWith {
		(format ["NWG_PSH_SER_GetPlayerId: Unit is not a player: '%1':'%2'",_this,(name _this)]) call NWG_fnc_logError;
		false
	};

	private _steamId = getPlayerUID _this;
	if (_steamId isEqualTo "") exitWith {
		(format ["NWG_PSH_SER_GetPlayerId: Unit has no steam id: '%1':'%2'",_this,(name _this)]) call NWG_fnc_logError;
		false
	};

	_this setVariable ["NWG_PSH_SER_steamId",_steamId];
	_steamId
};

//================================================================================================================
//================================================================================================================
//State apply
NWG_PSH_SER_OnStateApplyRequest = {
	private _player = _this;

	//Get player id
	private _playerId = _player call NWG_PSH_SER_GetPlayerId;
	if (isNil "_playerId" || {_playerId isEqualTo false}) exitWith {
		(format ["NWG_PSH_SER_OnStateApplyRequest: Player id not found for player: '%1'",(name _player)]) call NWG_fnc_logError;
		false
	};

	//Get player state
	private _playerState = call {
		//Try getting state from cache
		private _cached = NWG_PSH_SER_playerStateCache get _playerId;
		if (!isNil "_cached") exitWith {_cached};

		//Try getting state from database
		private _stored = _playerId call (NWG_PSH_SER_Settings get "FUNC_LOAD_STATE_BY_ID");
		if (!isNil "_stored" && {_stored isNotEqualTo false}) exitWith {
			NWG_PSH_SER_playerStateCache set [_playerId,_stored];
			_stored
		};

		//Create new state in database (can not use it though - it will be completely empty resulting in unit undress and money 0)
		private _ok = _playerId call (NWG_PSH_SER_Settings get "FUNC_NEW_STATE_BY_ID");
		if (!_ok) then {
			(format ["NWG_PSH_SER_OnStateApplyRequest: Failed to create new state in database for player '%1' with id '%2'",(name _player),_playerId]) call NWG_fnc_logError;
		};

		//else - return false
		false
	};

	//If state not found - create new and invoke state update to fill it
	if (isNil "_playerState" || {_playerState isEqualTo false}) exitWith {
		NWG_PSH_SER_playerStateCache set [_playerId,createHashMap];
		_player call NWG_PSH_SER_OnStateUpdateRequest;
	};

	//Else - state found - apply it
	{
		if (_x in _playerState)
			then {[_player,(_playerState get _x)] call (_y#STATE_SET_CODE)}
			else {(format ["NWG_PSH_SER_OnStateApplyRequest: Player state missing key: '%1'",_x]) call NWG_fnc_logError};
	} forEach (NWG_PSH_SER_Settings get "STATES_TO_HOLD");

	//return
	true
};

//================================================================================================================
//================================================================================================================
//State update
NWG_PSH_SER_OnStateUpdateRequest = {
	private _player = _this;

	//Get player id
	private _playerId = _player call NWG_PSH_SER_GetPlayerId;
	if (isNil "_playerId" || {_playerId isEqualTo false}) exitWith {
		(format ["NWG_PSH_SER_OnStateUpdateRequest: Player id not found for player: '%1'",(name _player)]) call NWG_fnc_logError;
		false
	};

	//Get player state
	private _playerState = NWG_PSH_SER_playerStateCache get _playerId;
	if (isNil "_playerState") exitWith {
		(format ["NWG_PSH_SER_OnStateUpdateRequest: Player state not found, init player first: '%1'",_playerId]) call NWG_fnc_logError;
		false
	};

	//Update player state
	{
		_playerState set [_x,(_player call (_y#STATE_GET_CODE))];
	} forEach (NWG_PSH_SER_Settings get "STATES_TO_HOLD");
	_playerState set [STATE_DIRTY,true];
	NWG_PSH_SER_playerStateCache set [_playerId,_playerState];

	//return
	true
};

//================================================================================================================
//================================================================================================================
//States sync
NWG_PSH_SER_SyncStates = {
	private _ok = true;
	{
		if !(_y getOrDefault [STATE_DIRTY,false]) then {continue};//No need to re-write state if there were no changes
		_ok = [_x,_y] call (NWG_PSH_SER_Settings get "FUNC_SAVE_STATE_BY_ID");
		if (!_ok) then {(format ["NWG_PSH_SER_SyncStates: Failed to save state for player with id '%1'",_x]) call NWG_fnc_logError};
		_y set [STATE_DIRTY,false];
	} forEach NWG_PSH_SER_playerStateCache;
};
