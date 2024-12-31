/*
	Player state holder
	States to carry:
		T1: -
		T2: loadout, additionalWeapon;
		T3: lootStorage, wallet
*/

//================================================================================================================
//================================================================================================================
//Defines
#define STATE_GET_CODE 0
#define STATE_SET_CODE 1

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
		["loadout",		[{_this call NWG_PSH_LH_GetLoadout},	{_this call NWG_PSH_LH_SetLoadout}]],
		["add_weapon",	[{_this call NWG_fnc_awGetHolderData},	{_this call NWG_fnc_awAddHolderDataAndCreateObject}]],
		["loot_storage",[{_this call NWG_fnc_lsGetPlayerLoot},	{_this call NWG_fnc_lsSetPlayerLoot}]],
		["wallet",		[{_this call NWG_fnc_wltGetPlayerMoney},{_this call NWG_fnc_wltSetPlayerMoney}]]
	]],

/*
	State DB syncing
*/
	["FUNC_LOAD_STATE_BY_ID",{nil}],//TODO: Add database connector in future versions
	["FUNC_SAVE_STATE_BY_ID",{nil}],//TODO: Add database connector in future versions

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
	NWG_PSH_SER_playerStateCache set [_playerId,_playerState];

	//return
	true
};

//================================================================================================================
//================================================================================================================
//States sync
NWG_PSH_SER_SyncStates = {
	{
		[_x,_y] call (NWG_PSH_SER_Settings get "FUNC_SAVE_STATE_BY_ID");
	} forEach NWG_PSH_SER_playerStateCache;
};

//================================================================================================================
//================================================================================================================
//State get/set for other modules
NWG_PSH_SER_GetState = {
	params ["_playerId","_stateName"];
	private _playerState = NWG_PSH_SER_playerStateCache get _playerId;
	if (isNil "_playerState") exitWith {false};
	_playerState getOrDefault [_stateName,false]
};

NWG_PSH_SER_SetState = {
	params ["_playerId","_stateName","_stateValue"];
	private _playerState = NWG_PSH_SER_playerStateCache get _playerId;
	if (isNil "_playerState") exitWith {false};
	_playerState set [_stateName,_stateValue];
	NWG_PSH_SER_playerStateCache set [_playerId,_playerState];
	true
};
