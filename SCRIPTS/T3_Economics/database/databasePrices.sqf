#include "..\..\globalDefines.h"
#include "databaseDefines.h"

/*
	Annotation
	Yeah, this is less flexible module with defines instead of settings and hardcoded table columns.
	Because, honestly, writing two database modules in one day makes me really tired.
	Imagine me sticking to original plan and doing separate modules for items and vehicles, and then auto-generating requests based on settings.
	So sorry not sorry. If you want to reuse it - you'll have to rewrite it.
	If you want to see a better version - check 'databasePlayers.sqf'
*/

//======================================================================================================
//======================================================================================================
//Defines
// #define DEBUG_LOG false
#define TABLE_NAME_ITEMS "items"
#define TABLE_NAME_VEHS "vehs"

//======================================================================================================
//======================================================================================================
//High level functions (Items)
NWG_DB_PRC_LoadItemPrices = {
	private _chartToLoadTo = (LOOT_ITEM_DEFAULT_CHART) apply {[[],[]]};
	private _result = [TABLE_NAME_ITEMS,_chartToLoadTo] call NWG_DB_PRC_Load;
	if (_result isEqualTo false) exitWith {
		"NWG_DB_PRC_LoadItemPrices: Failed to load items prices" call NWG_fnc_logError;
		false
	};
	_result
};

NWG_DB_PRC_SaveItemPrices = {
	// private _chartToSave = _this;
	private _result = [TABLE_NAME_ITEMS,_this,2] call NWG_DB_PRC_Save;
	if (_result isEqualTo false) exitWith {
		"NWG_DB_PRC_SaveItemPrices: Failed to save items prices" call NWG_fnc_logError;
		false
	};
	true
};

//======================================================================================================
//======================================================================================================
//High level functions (Vehicles)
NWG_DB_PRC_LoadVehiclePrices = {
	private _chartToLoadTo = (LOOT_VEHC_DEFAULT_CHART) apply {[[],[]]};
	private _result = [TABLE_NAME_VEHS,_chartToLoadTo] call NWG_DB_PRC_Load;
	if (_result isEqualTo false) exitWith {
		"NWG_DB_PRC_LoadVehiclePrices: Failed to load vehicles prices" call NWG_fnc_logError;
		false
	};
	_result
};

NWG_DB_PRC_SaveVehiclePrices = {
	// private _chartToSave = _this;
	private _result = [TABLE_NAME_VEHS,_this,0] call NWG_DB_PRC_Save;
	if (_result isEqualTo false) exitWith {
		"NWG_DB_PRC_SaveVehiclePrices: Failed to save vehicles prices" call NWG_fnc_logError;
		false
	};
	true
};

//======================================================================================================
//======================================================================================================
//Load
NWG_DB_PRC_Load = {
	params ["_tableName","_chartToLoadTo"];

	//Check arguments
	if (_tableName isEqualTo "" || {!(_tableName isEqualType "")}) exitWith {
		(format ["NWG_DB_PRC_Load: Table name is empty or not a string: '%1'",_tableName]) call NWG_fnc_logError;
		false
	};
	if !(_chartToLoadTo isEqualType []) exitWith {
		(format ["NWG_DB_PRC_Load: Chart to load to is not an array: '%1'",_chartToLoadTo]) call NWG_fnc_logError;
		false
	};
	private _chartOk = _chartToLoadTo findIf {!(_x isEqualTypeArray [[],[]])} == -1;
	if (!_chartOk) exitWith {
		(format ["NWG_DB_PRC_Load: Chart to load to is invalid: '%1'",_chartToLoadTo]) call NWG_fnc_logError;
		false
	};

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		_chartToLoadTo//Return default chart
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Loading prices"]) call NWG_fnc_logInfo};

	//Prepare variables
	private _id = 0;
	private _cat = 0;
	private _classname = "";
	private _price = 0;

	//Load item after item until DB_NOT_FOUND
	private _success = true;
	private _maxIterations = 5000;
	private ["_getResult","_getResultArray","_catArray"];
	while {_maxIterations > 0} do {
		_maxIterations = _maxIterations - 1;
		if (_maxIterations < 2500) then {"NWG_DB_PRC_Load: Too much iterations!" call NWG_fnc_logError};

		_getResult = "extDB3" callExtension (format ["0:%1:SELECT * FROM %2 WHERE id=%3 LIMIT 1",NWG_DB_Protocol,_tableName,_id]);
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
		if !(_getResultArray isEqualTypeArray [0,0,"",""]) exitWith {
			(format ["NWG_DB_PRC_Load: Incorrect type or number of fields in result. Id: '%1'. Result: '%2'",_id,_getResultArray]) call NWG_fnc_logError;
			_success = false;
		};
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Load: Get success. Result: '%1'",_getResultArray]) call NWG_fnc_logInfo};

		//Parse into variables
		// _id = _getResultArray#0;//Not used
		_cat = _getResultArray#1;
		_classname = _getResultArray#2;
		_price = parseNumber (_getResultArray#3);

		//Add to chart
		_catArray = _chartToLoadTo param [_cat,false];
		if (_catArray isEqualTo false) exitWith {
			(format ["NWG_DB_PRC_Load: Cat '%1' not found in chart: '%2'",_cat,_chartToLoadTo]) call NWG_fnc_logError;
			_success = false;
		};
		(_catArray#0) pushBack _classname;
		(_catArray#1) pushBack _price;

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
NWG_DB_PRC_Save = {
	params ["_tableName","_chartToSave","_pricePrecision"];

	//Check arguments
	if (_tableName isEqualTo "" || {!(_tableName isEqualType "")}) exitWith {
		(format ["NWG_DB_PRC_Save: Table name is empty or not a string: '%1'",_tableName]) call NWG_fnc_logError;
		false
	};
	if !(_chartToSave isEqualType []) exitWith {
		(format ["NWG_DB_PRC_Save: Chart to save is not an array: '%1'",_chartToSave]) call NWG_fnc_logError;
		false
	};
	private _chartOk = _chartToSave findIf {!(_x isEqualTypeArray [[],[]])} == -1;
	if (!_chartOk) exitWith {
		(format ["NWG_DB_PRC_Save: Chart to save is invalid: '%1'",_chartToSave]) call NWG_fnc_logError;
		false
	};

	//Check if DB is initialized
	if (!NWG_DB_Success) exitWith {
		// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: DB not initialized, refusing service"]) call NWG_fnc_logInfo};
		true//Return true if caller expects it to silently refuse service
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Saving prices"]) call NWG_fnc_logInfo};

	//Drop table
	private _dropResult = "extDB3" callExtension (format ["0:%1:TRUNCATE %2",NWG_DB_Protocol,_tableName]);
	if (_dropResult isNotEqualTo DB_OK) exitWith {
		(format ["NWG_DB_PRC_Save: Table drop failed. Table: '%1'. Drop result: '%2'",_tableName,_dropResult]) call NWG_fnc_logError;
		false
	};
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Table dropped: '%1'. Drop result: '%2'",_tableName,_dropResult]) call NWG_fnc_logInfo};

	//Fill table again
	private _id = -1;
	private _success = true;
	private ["_cat","_item","_price","_insertResult"];
	//for each category
	{
		_x params ["_items","_prices"];
		_cat = _forEachIndex;

		//for each item
		{
			_id = _id + 1;
			_item = _x;
			_price = text ((_prices param [_forEachIndex,0]) toFixed _pricePrecision);
			_insertResult = "extDB3" callExtension (format ["0:%1:INSERT INTO %2 (id,cat,item,price) VALUES (%3,%4,'%5','%6')",NWG_DB_Protocol,_tableName,_id,_cat,_item,_price]);
			if (_insertResult isNotEqualTo DB_OK) exitWith {
				(format ["NWG_DB_PRC_Save: Insert failed. Table: '%1'. Insert result: '%2'",_tableName,_insertResult]) call NWG_fnc_logError;
				_success = false;
			};
		} forEach _items;

		if (!_success) exitWith {};
	} forEach _chartToSave;
	// if (DEBUG_LOG) then {(format ["NWG_DB_PRC_Save: Successfully saved '%1' items",_id]) call NWG_fnc_logInfo};

	//Return result
	if (!_success) exitWith {false};
	true
};