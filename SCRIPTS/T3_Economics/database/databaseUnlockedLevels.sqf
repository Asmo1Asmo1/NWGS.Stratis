#include "..\..\globalDefines.h"
#include "databaseDefines.h"

/*
	Annotation
	Hardcoded module for unlocked levels
*/

//======================================================================================================
//======================================================================================================
//Defines
// #define DEBUG_LOG false
#define TABLE_NAME "unlockedlevels"

//======================================================================================================
//======================================================================================================
//Load
NWG_DB_UL_LoadLevels = {
	private _id = 0;
	private _chartToLoadTo = [];

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_UL_LoadLevels: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		_chartToLoadTo//Return default chart
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_UL_LoadLevels: Loading prices"]) call NWG_fnc_logInfo};

	//Load item after item until DB_NOT_FOUND
	private _success = true;
	private ["_getResult","_getResultArray"];
	if (true) then {
		_getResult = "extDB3" callExtension (format ["0:%1:SELECT * FROM %2 WHERE id=%3 LIMIT 1",NWG_DB_Protocol,TABLE_NAME,_id]);
		// if (DEBUG_LOG) then {(format ["NWG_DB_UL_LoadLevels: Loading item id: '%1'. Result: '%2'",_id,_getResult]) call NWG_fnc_logInfo};
		if (_getResult isEqualTo DB_NOT_FOUND) exitWith {
			// if (DEBUG_LOG) then {(format ["NWG_DB_UL_LoadLevels: Item not found: '%1'. End of loading.",_id]) call NWG_fnc_logInfo};
			"NWG_DB_UL_LoadLevels: Data not found" call NWG_fnc_logError;
			_success = false;
		};
		if (_getResult isEqualTo "") exitWith {
			"NWG_DB_UL_LoadLevels: Extension error" call NWG_fnc_logError;
			_success = false;
		};

		//Parse result
		_getResultArray = parseSimpleArray _getResult;
		if ((_getResultArray#0) != 1) exitWith {
			(format ["NWG_DB_UL_LoadLevels: Error while getting id: '%1'. Result: '%2'",_id,_getResult]) call NWG_fnc_logError;
			_success = false;
		};
		_getResultArray = (_getResultArray#1)#0;//wtf
		if !(_getResultArray isEqualTypeArray [0,""]) exitWith {
			(format ["NWG_DB_UL_LoadLevels: Incorrect type or number of fields in result. Id: '%1'. Result: '%2'",_id,_getResultArray]) call NWG_fnc_logError;
			_success = false;
		};
		// if (DEBUG_LOG) then {(format ["NWG_DB_UL_LoadLevels: Get success. Result: '%1'",_getResultArray]) call NWG_fnc_logInfo};

		//Parse into variables
		// _id = _getResultArray#0;//Not used
		_chartToLoadTo = _getResultArray#1;
	};

	//Return result
	if (!_success) exitWith {false};
	_chartToLoadTo
};

//======================================================================================================
//======================================================================================================
//Save
NWG_DB_UL_SaveLevels = {
	private _chartToSave = _this;

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_UL_SaveLevels: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		true//Return true if caller expects it to silently refuse service
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_UL_SaveLevels: Saving prices"]) call NWG_fnc_logInfo};

	//Drop table
	private _dropResult = "extDB3" callExtension (format ["0:%1:TRUNCATE %2",NWG_DB_Protocol,TABLE_NAME]);
	if (_dropResult isNotEqualTo DB_OK) exitWith {
		(format ["NWG_DB_UL_SaveLevels: Table drop failed. Table: '%1'. Drop result: '%2'",TABLE_NAME,_dropResult]) call NWG_fnc_logError;
		false
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_UL_SaveLevels: Table dropped: '%1'. Drop result: '%2'",TABLE_NAME,_dropResult]) call NWG_fnc_logInfo};

	//Fill table again
	private _id = 0;
	private _success = true;
	private ["_item","_insertResult"];
	if (true) then {
		_item = _chartToSave;
		_insertResult = "extDB3" callExtension (format ["0:%1:INSERT INTO %2 (id,array) VALUES (%3,%4)",NWG_DB_Protocol,TABLE_NAME,_id,_item]);
		if (_insertResult isNotEqualTo DB_OK) exitWith {
			(format ["NWG_DB_UL_SaveLevels: Insert failed. Table: '%1'. Insert result: '%2'",TABLE_NAME,_insertResult]) call NWG_fnc_logError;
			_success = false;
		};
		if (!_success) exitWith {};
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_UL_SaveLevels: Successfully saved '%1' items",_id]) call NWG_fnc_logInfo};

	//Return result
	if (!_success) exitWith {false};
	true
};