#include "..\..\globalDefines.h"
#include "databaseDefines.h"

/*
	Annotation
	Fixed module for escape billboard
*/

//======================================================================================================
//======================================================================================================
//Defines
// #define DEBUG_LOG false
#define TABLE_NAME "escbillboard"

//======================================================================================================
//======================================================================================================
//Load
NWG_DB_ESCB_LoadWinners = {
	private _chartToLoadTo = [];

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		_chartToLoadTo//Return default chart
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Loading prices"]) call NWG_fnc_logInfo};

	//Prepare variables
	private _id = 0;
	private _name = "";

	//Load item after item until DB_NOT_FOUND
	private _success = true;
	private _maxIterations = 5000;
	private ["_getResult","_getResultArray"];
	while {_maxIterations > 0} do {
		_maxIterations = _maxIterations - 1;
		if (_maxIterations < 2500) then {"NWG_DB_PRC_Load: Too much iterations!" call NWG_fnc_logError};

		_getResult = "extDB3" callExtension (format ["0:%1:SELECT * FROM %2 WHERE id=%3 LIMIT 1",NWG_DB_Protocol,TABLE_NAME,_id]);
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Loading item id: '%1'. Result: '%2'",_id,_getResult]) call NWG_fnc_logInfo};
		if (_getResult isEqualTo DB_NOT_FOUND) exitWith {
			// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Item not found: '%1'. End of loading.",_id]) call NWG_fnc_logInfo};
			_success = true;
		};
		if (_getResult isEqualTo "") exitWith {
			"NWG_DB_PRC_Load: Extension error" call NWG_fnc_logError;
			_success = false;
		};

		//Parse result
		_getResultArray = parseSimpleArray _getResult;
		if ((_getResultArray#0) != 1) exitWith {
			(format ["NWG_DB_PRC_Load: Error while getting id: '%1'. Result: '%2'",_id,_getResult]) call NWG_fnc_logError;
			_success = false;
		};
		_getResultArray = (_getResultArray#1)#0;//wtf
		if !(_getResultArray isEqualTypeArray [0,""]) exitWith {
			(format ["NWG_DB_PRC_Load: Incorrect type or number of fields in result. Id: '%1'. Result: '%2'",_id,_getResultArray]) call NWG_fnc_logError;
			_success = false;
		};
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Get success. Result: '%1'",_getResultArray]) call NWG_fnc_logInfo};

		//Parse into variables
		// _id = _getResultArray#0;//Not used
		_name = _getResultArray#1;

		//Add to chart
		_chartToLoadTo pushBack _name;

		//Next item
		_id = _id + 1;
	};

	//Return result
	if (!_success) exitWith {false};
	_chartToLoadTo
};

//======================================================================================================
//======================================================================================================
//Save
NWG_DB_ESCB_SaveWinners = {
	private _chartToSave = _this;

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		true//Return true if caller expects it to silently refuse service
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Saving prices"]) call NWG_fnc_logInfo};

	//Drop table
	private _dropResult = "extDB3" callExtension (format ["0:%1:TRUNCATE %2",NWG_DB_Protocol,TABLE_NAME]);
	if (_dropResult isNotEqualTo DB_OK) exitWith {
		(format ["NWG_DB_PRC_Save: Table drop failed. Table: '%1'. Drop result: '%2'",TABLE_NAME,_dropResult]) call NWG_fnc_logError;
		false
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Table dropped: '%1'. Drop result: '%2'",TABLE_NAME,_dropResult]) call NWG_fnc_logInfo};

	//Fill table again
	private _id = -1;
	private _success = true;
	private ["_item","_insertResult"];
	//for each category
	{
		_id = _id + 1;
		_item = _x;
		_insertResult = "extDB3" callExtension (format ["0:%1:INSERT INTO %2 (id,name) VALUES (%3,%4)",NWG_DB_Protocol,TABLE_NAME,_id,_item]);
		if (_insertResult isNotEqualTo DB_OK) exitWith {
			(format ["NWG_DB_PRC_Save: Insert failed. Table: '%1'. Insert result: '%2'",TABLE_NAME,_insertResult]) call NWG_fnc_logError;
			_success = false;
		};
		if (!_success) exitWith {};
	} forEach _chartToSave;
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Successfully saved '%1' items",_id]) call NWG_fnc_logInfo};

	//Return result
	if (!_success) exitWith {false};
	true
};