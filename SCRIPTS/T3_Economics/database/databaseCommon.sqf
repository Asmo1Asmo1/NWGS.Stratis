#include "databaseDefines.h"
#include "..\..\secrets.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_DB_Settings = createHashMapFromArray [
	["DB_NAME",DATABASE_NAME],//Database name
	["DB_TEST_TABLE","init_test"],//Table used to test connection

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Fields
NWG_DB_Protocol = 0;
NWG_DB_Success = false;

//======================================================================================================
//======================================================================================================
//Init
private _Init = {
	private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
	if (_isDevBuild) exitWith {"NWG_DB_Init: Dev build detected, skipping DB initialization" call NWG_fnc_logInfo};

    NWG_DB_Protocol = profileNamespace getVariable ["NWG_DB_SavedProtocol",0];

    //Try 'empty' DB request to check if DB Init needed
    private _testResponse = "extDB3" callExtension (format["0:%1:SELECT id FROM %2 WHERE id='0' LIMIT 1",NWG_DB_Protocol,(NWG_DB_Settings get "DB_TEST_TABLE")]);
    // format ["NWG_DB_Test: Response:'%1'",_testResponse] call NWG_fnc_logInfo;
    if (_testResponse isEqualTo DB_OK) exitWith {
		"NWG_DB_Init: Test success, using existing connection and protocol" call NWG_fnc_logInfo;
		NWG_DB_Success = true;
	};
	// "NWG_DB_Init: Test failed, establishing new connection and protocol" call NWG_fnc_logInfo;

    //Generate new protocol
    NWG_DB_Protocol = ceil random 9999;
    profileNamespace setVariable ["NWG_DB_SavedProtocol",NWG_DB_Protocol];
    saveProfileNamespace;

	//Establish database connection
    private _connectionSuccess = false;
    for "_i" from 1 to MAX_INIT_ATTEMPTS do {
        private _connectionResult = "Extdb3" callExtension (format["9:ADD_DATABASE:%1",(NWG_DB_Settings get "DB_NAME")]);
        if (_connectionResult isEqualTo "[1]") exitWith {
			"NWG_DB_Init: Connection established" call NWG_fnc_logInfo;
			_connectionSuccess = true
		};

        //else
		(format ["NWG_DB_Init: Connection failed [%1/%2]. Response: '%3'",_i,MAX_INIT_ATTEMPTS,_connectionResult]) call NWG_fnc_logError;
        _connectionSuccess = false;
    };
    if (!_connectionSuccess) exitWith {
		"NWG_DB_Init: Initial connection failed" call NWG_fnc_logError;
		NWG_DB_Success = false;
	};//Stop script execution if initial connection failed

	//Establish database protocol
    private _protocolSuccess = false;
    for "_i" from 1 to MAX_INIT_ATTEMPTS do {
        private _protocolResult = "Extdb3" callExtension (format["9:ADD_DATABASE_PROTOCOL:%1:SQL:%2:TEXT",(NWG_DB_Settings get "DB_NAME"),NWG_DB_Protocol]);
        if (_protocolResult isEqualTo "[1]") exitWith {
			"NWG_DB_Init: Protocol established" call NWG_fnc_logInfo;
			_protocolSuccess = true;
		};

        //else
		(format ["NWG_DB_Init: Protocol failed [%1/%2]. Response: '%3'",_i,MAX_INIT_ATTEMPTS,_protocolResult]) call NWG_fnc_logError;
        _protocolSuccess = false;
    };

    //Check if both connection and protocol were established
    NWG_DB_Success = _connectionSuccess && _protocolSuccess;
};

//======================================================================================================
//======================================================================================================
call _Init;