#include "..\..\globalDefines.h"
#include "databaseDefines.h"
/*
	Database for players
	note: In order to work, every column must be string (VARCHAR/TEXT/etc.) and NULL allowed (except for the ID - it must be NOT NULL)
	note: It uses syncronous requests with one at a time get/set/update - this is extremely slow, but more reliable since we are working with big chunks of data
*/

//======================================================================================================
//======================================================================================================
//Defines
/*relation enum*/
#define RELATION_DB 0
#define RELATION_STATE 1

//======================================================================================================
//======================================================================================================
//Settings
NWG_DB_PL_Settings = createHashMapFromArray [
	/*Table*/
	["TABLE_NAME","players"],
	["TABLE_ID_FIELD","steam_id"],
	["TABLE_FIELDS",["loadout","add_weapon","loot_storage_c","loot_storage_w","loot_storage_i","loot_storage_a","wallet","progress","garage"]],
	["TABLE_TYPES",[[],[],[],[],[],[],1,[],[]]],

	/*Debug and settings*/
	// ["DEBUG_LOG",false],//Log every request to DB
	["RETURN_ON_NO_INIT",true],//What to return if DB not initialized (e.g.: return 'true' if caller expects it to silently refuse service)

	/*Default values*/
	["DEFAULT_VALUES", [
		["loadout",[]],
		["add_weapon",[]],
		["loot_storage",LOOT_ITEM_DEFAULT_CHART],
		["wallet",WLT_DEFAULT_MONEY],
		["progress",P_DEFAULT_CHART],
		["garage",[]]
	]],

	/*DB to State relation*/
	["DB_TO_STATE", [
		["loadout","loadout"],
		["add_weapon","add_weapon"],
		["loot_storage_c",["loot_storage",LOOT_ITEM_CAT_CLTH]],
		["loot_storage_w",["loot_storage",LOOT_ITEM_CAT_WEAP]],
		["loot_storage_i",["loot_storage",LOOT_ITEM_CAT_ITEM]],
		["loot_storage_a",["loot_storage",LOOT_ITEM_CAT_AMMO]],
		["wallet","wallet"],
		["progress","progress"],
		["garage","garage"]
	]],

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Create
NWG_DB_PL_CreateWithId = {
	private _playerID = _this;
	// private _debugLog = NWG_DB_PL_Settings get "DEBUG_LOG";

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (_debugLog) then {(format ["NWG_DB_PL_CreateWithId: DB not initialized, refusing service for id: '%1'",_playerID]) call NWG_fnc_logInfo};
		(NWG_DB_PL_Settings get "RETURN_ON_NO_INIT")
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_CreateWithId: Creating player with id: '%1'",_playerID]) call NWG_fnc_logInfo};

	//Check incoming id
	if !(_playerID isEqualType "") exitWith {
		(format ["NWG_DB_PL_CreateWithId: Invalid id type: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};
	if (_playerID isEqualTo "") exitWith {
		(format ["NWG_DB_PL_CreateWithId: Empty id: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};

	//Create new DB record (all fields will be NULL)
	private _createRequest = format [
		"0:%1:INSERT INTO %2 (%3) VALUES ('%4')",
		NWG_DB_Protocol,
		(NWG_DB_PL_Settings get "TABLE_NAME"),
		(NWG_DB_PL_Settings get "TABLE_ID_FIELD"),
		_playerID
	];
	// if (_debugLog) then {(format ["NWG_DB_PL_CreateWithId: Creating request: '%1'",_createRequest]) call NWG_fnc_logInfo};
	private _createResult = "extDB3" callExtension _createRequest;
	if (_createResult isNotEqualTo DB_OK) exitWith {
		(format ["NWG_DB_PL_CreateWithId: Failed to create player with id: '%1'. Result: '%2'",_playerID,_createResult]) call NWG_fnc_logError;
		false
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_CreateWithId: Created success for player with id: '%1'. Result: '%2'",_playerID,_createResult]) call NWG_fnc_logInfo};

	//Create mock state to use with update (fill table with default values)
	private _playerState = createHashMap;
	{
		_x params ["_key","_value"];
		if (_value isEqualType []) then {_value = +_value};//Deep copy (fix players sharing same loot_storage array)
		_playerState set [_key,_value];
	} forEach (NWG_DB_PL_Settings get "DEFAULT_VALUES");
	private _updateOk = [_playerID,_playerState] call NWG_DB_PL_UpdateById;
	if (!_updateOk) exitWith {
		(format ["NWG_DB_PL_CreateWithId: Failed first update for player with id: '%1'. Result: '%2'",_playerID,_updateOk]) call NWG_fnc_logError;
		false
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_CreateWithId: First update success for player with id: '%1'",_playerID]) call NWG_fnc_logInfo};

	//Return success
	true
};

//======================================================================================================
//======================================================================================================
//Update
NWG_DB_PL_UpdateById = {
	params ["_playerID","_playerState"];
	// private _debugLog = NWG_DB_PL_Settings get "DEBUG_LOG";

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (_debugLog) then {(format ["NWG_DB_PL_UpdateById: DB not initialized, refusing service for id: '%1'",_playerID]) call NWG_fnc_logInfo};
		(NWG_DB_PL_Settings get "RETURN_ON_NO_INIT")
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_UpdateById: Updating player with id: '%1'",_playerID]) call NWG_fnc_logInfo};

	//Check incoming id
	if !(_playerID isEqualType "") exitWith {
		(format ["NWG_DB_PL_UpdateById: Invalid id type: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};
	if (_playerID isEqualTo "") exitWith {
		(format ["NWG_DB_PL_UpdateById: Empty id: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};

	//Update db one value at a time
	private _tableName = NWG_DB_PL_Settings get "TABLE_NAME";
	private _tableIdField = NWG_DB_PL_Settings get "TABLE_ID_FIELD";
	private _fields = NWG_DB_PL_Settings get "TABLE_FIELDS";
	private _relation = NWG_DB_PL_Settings get "DB_TO_STATE";
	private _success = true;
	private ["_field","_stateKey","_stateValue","_updateRequest","_updateResult"];
	{
		//Get field - value pair
		_field = _x;
		_stateKey = (_relation select _forEachIndex) select RELATION_STATE;
		_stateValue = switch (true) do {
			case (_stateKey isEqualType []): {(_playerState getOrDefault [(_stateKey#0),[]]) param [(_stateKey#1),nil]};
			case (_stateKey isEqualType ""): {_playerState get _stateKey};
			default {nil};
		};
		if (isNil "_stateValue") then {
			(format ["NWG_DB_PL_UpdateById: State value is nil for field: '%1', key: '%2'",_field,_stateKey]) call NWG_fnc_logError;
			continue;
		};
		if (_stateValue isEqualType 1) then {
			_stateValue = text (_stateValue toFixed 0);
		};
		// if (_debugLog) then {(format ["NWG_DB_PL_UpdateById: Sequence field: [%1,%2]",_field,_stateValue]) call NWG_fnc_logInfo};

		//Compile update request
		_updateRequest = format [
			"0:%1:UPDATE %2 SET %3='%4' WHERE %5='%6' LIMIT 1",
			NWG_DB_Protocol,
			_tableName,
			_field,
			_stateValue,
			_tableIdField,
			_playerID
		];
		// if (_debugLog) then {(format ["NWG_DB_PL_UpdateById: Update request: '%1'",_updateRequest]) call NWG_fnc_logInfo};

		//Send update request
		_updateResult = "extDB3" callExtension _updateRequest;
		if (_updateResult isNotEqualTo DB_OK) then {
			(format ["NWG_DB_PL_UpdateById: Failed to update field: '%1' for player with id: '%2'. Result: '%3'",_field,_playerID,_updateResult]) call NWG_fnc_logError;
			_success = false;
		};
		// if (_debugLog) then {(format ["NWG_DB_PL_UpdateById: Update success, result: '%1'",_updateResult]) call NWG_fnc_logInfo};
	} forEach _fields;

	//Return success
	_success
};

//======================================================================================================
//======================================================================================================
//Get
NWG_DB_PL_GetById = {
	private _playerID = _this;
	// private _debugLog = NWG_DB_PL_Settings get "DEBUG_LOG";

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (_debugLog) then {(format ["NWG_DB_PL_GetById: DB not initialized, refusing service for id: '%1'",_playerID]) call NWG_fnc_logInfo};
		false
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_GetById: DB initialized, getting player with id: '%1'",_playerID]) call NWG_fnc_logInfo};

	//Check incoming id
	if !(_playerID isEqualType "") exitWith {
		(format ["NWG_DB_PL_GetById: Invalid id type: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};
	if (_playerID isEqualTo "") exitWith {
		(format ["NWG_DB_PL_GetById: Empty id: '%1'",_playerID]) call NWG_fnc_logError;
		false
	};
	// if (_debugLog) then {(format ["NWG_DB_PL_GetById: Getting player with id: '%1'",_playerID]) call NWG_fnc_logInfo};

	//Create default state
	private _playerState = createHashMap;
	{
		_x params ["_key","_value"];
		if (_value isEqualType []) then {_value = +_value};//Deep copy (fix players sharing same loot_storage array)
		_playerState set [_key,_value];
	} forEach (NWG_DB_PL_Settings get "DEFAULT_VALUES");

	//Get player state from DB (one value at a time)
	private _tableName = NWG_DB_PL_Settings get "TABLE_NAME";
	private _tableIdField = NWG_DB_PL_Settings get "TABLE_ID_FIELD";
	private _fields = NWG_DB_PL_Settings get "TABLE_FIELDS";
	private _types = NWG_DB_PL_Settings get "TABLE_TYPES";
	private _relation = NWG_DB_PL_Settings get "DB_TO_STATE";
	private _success = true;
	private ["_field","_stateKey","_stateValue","_getRequest","_getResult","_getResultArray","_type"];
	{
		//Get field - value pair
		_field = _x;
		_stateKey = (_relation select _forEachIndex) select RELATION_STATE;

		//Compile get request
		_getRequest = format [
			"0:%1:SELECT %2 FROM %3 WHERE %4='%5' LIMIT 1",
			NWG_DB_Protocol,
			_field,
			_tableName,
			_tableIdField,
			_playerID
		];
		// if (_debugLog) then {(format ["NWG_DB_PL_GetById: Get request: '%1'",_getRequest]) call NWG_fnc_logInfo};

		//Send get request
		_getResult = "extDB3" callExtension _getRequest;
		if (_getResult isEqualTo DB_NOT_FOUND) exitWith {
			// if (_debugLog) then {(format ["NWG_DB_PL_GetById: Player not found: '%1'",_playerID]) call NWG_fnc_logInfo};
			_success = false;
		};
		if (_getResult isEqualTo "") exitWith {
			"NWG_DB_PL_GetById: Extension error" call NWG_fnc_logError;
			_success = false;
		};

		//Parse result
		_getResultArray = parseSimpleArray _getResult;
		if ((_getResultArray#0) != 1) exitWith {
			(format ["NWG_DB_PL_GetById: Error while getting field: '%1' for player with id: '%2'. Result: '%3'",_field,_playerID,_getResult]) call NWG_fnc_logError;
			_success = false;
		};
		// if (_debugLog) then {(format ["NWG_DB_PL_GetById: Get success, result: '%1'",_getResult]) call NWG_fnc_logInfo};
		_stateValue = (((_getResultArray)#1)#0)#0;//wtf

		//Re-parse result core if needed (case with VARCHARs for example)
		if (_stateValue isEqualType "") then {
			// if (_debugLog) then {(format ["NWG_DB_PL_GetById: State value is string, re-parsing..."]) call NWG_fnc_logInfo};
			_type = _types select _forEachIndex;
			_stateValue = switch (true) do {
				case (_type isEqualType []): {parseSimpleArray _stateValue};
				case (_type isEqualType 1): {parseNumber _stateValue};
				default {_stateValue};
			};
		};
		// if (_debugLog) then {(format ["NWG_DB_PL_GetById: State value: '%1'",_stateValue]) call NWG_fnc_logInfo};

		//Assign state value
		switch (true) do {
			case (_stateKey isEqualType []): {(_playerState getOrDefault [(_stateKey#0),[]]) set [(_stateKey#1),_stateValue]};
			case (_stateKey isEqualType ""): {_playerState set [_stateKey,_stateValue]};
			default {
				(format ["NWG_DB_PL_GetById: Invalid state key type: '%1'",_stateKey]) call NWG_fnc_logError;
				_success = false;
			};
		};
	} forEach _fields;

	//return
	if (!_success) exitWith {false};
	_playerState
};