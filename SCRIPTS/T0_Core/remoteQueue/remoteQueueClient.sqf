//================================================================================================================
//Fields
// NWG_RemoteQueue = nil;//Global queue that will be recieved from the server //Fix double compile issue in local testing by commenting out (nils server side)
NWG_RQ_CLI_lastID = -1;//Last command ID recieved from the server
NWG_RQ_CLI_inited = false;//Flag that indicates if the client is initialized

//================================================================================================================
//Init
private _Init = {
	waitUntil {
		sleep 0.1;
		!isNil "NWG_RemoteQueue"
	};

	call NWG_RQ_CLI_OnBroadcast;
};

//================================================================================================================
//On broadcast
NWG_RQ_CLI_OnBroadcast = {
	//Get last executed ID
	private _lastID = NWG_RQ_CLI_lastID;

	//For each enqueued command
	{
		//Unpack
		_x params ["_id","_anchor","_funcName","_args"];

		//Check if need to skip
		if (_id <= _lastID) then {continue};//Skip commands that were already executed
		if (isNull _anchor || {!alive _anchor}) then {continue};//Skip commands that are outdated

		//Get executable function
		private _func = missionNamespace getVariable [_funcName,false];
		if (_func isEqualTo false) then {
			(format ["NWG_RQ_CLI_OnBroadcast: Function '%1' is not defined",_funcName]) call NWG_fnc_logError;
			continue;
		};
		if !(_func isEqualType {}) then {
			(format ["NWG_RQ_CLI_OnBroadcast: Function '%1' is not a valid function",_funcName]) call NWG_fnc_logError;
			continue;
		};

		//Execute
		([_anchor] + _args) call _func;

		//Update last ID
		NWG_RQ_CLI_lastID = _id;
	} forEach NWG_RemoteQueue;

	//Mark as initialized
	if (!NWG_RQ_CLI_inited) then {
		NWG_RQ_CLI_inited = true;
	};
};

//================================================================================================================
[] spawn _Init;