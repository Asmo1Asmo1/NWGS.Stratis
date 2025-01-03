/*Any->Server*/
//Enqueue command for propagation
//params:
//	_anchorObject: object that is used for:
//		1. Check - the command will be recieved by connecting clients while it is alive and not null
//		2. Arg - this object will be used as a first argument for the function (so end result will look like: '([_anchorObject]+_args) call (missionNamespace getVariable _funcName)')
//	_funcName: name of the function
//	_args: (optional, default: []) array of additional arguments for the function (so end result will look like: '([_anchorObject]+_args) call (missionNamespace getVariable _funcName)')
//returns: boolean - true if the command was added, false in case of error
//note: ⚠️ This function propagates the entire command queue (minus outdated commands) making it heavy and network consuming operation
//note: ⚠️ Use only if absolutely necessary. This is WORSE than in-built Arma JIP queue system
NWG_fnc_rqAddCommand = {
	// params ["_anchorObject","_funcName",["_args",[]]];
	if (isServer)
		then {_this call NWG_RQ_SER_AddCommand}
		else {_this remoteExec ["NWG_fnc_rqAddCommand",2]};
};

/*Server->Client*/
//Broadcast notification that the command queue has been updated
NWG_fnc_rqOnBroadcast = {
	if (!hasInterface) exitWith {};//Only clients
	if (isNil "NWG_RQ_CLI_OnBroadcast") exitWith {};//Only if client is ready to receive
	if (isNil "NWG_RQ_CLI_inited" || {!NWG_RQ_CLI_inited}) exitWith {};//Only if client checked the queue at least once
	call NWG_RQ_CLI_OnBroadcast;
};