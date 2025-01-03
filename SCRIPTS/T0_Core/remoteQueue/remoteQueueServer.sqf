/*
	Annotation
	This is a remote execution queue for commands that MUST reach the clients connecting at any point of the mission
	This is NOT a replacement for a JIP queue, but an overhead we have to build because of our architecture choices

	Explanation:
	We refused to use predefined functions, hence, when new player joins, they have to obtain all the code from the server via network
	If any remote or JIP command arrives until it is done - it gets skipped (e.g.: NPCs not being interactable)
	It is not a problem in most cases, but for a few that are critical, we have to build this queue
	DO NOT USE EXCEPT ABSOLUTELY NECESSARY
*/

//================================================================================================================
//Defines
#define RQ_BUFFERING_DELAY 0.5

#define RQ_ID 0
#define RQ_ANCHOR 1
#define RQ_FUNC 2
#define RQ_ARGS 3

//================================================================================================================
//Compile check
if (!isNil "NWG_RemoteQueue") exitWith {};//Fix double compile issue in local testing

//================================================================================================================
//Commands queue
NWG_RemoteQueue = [];//Global queue that will be propagated to clients
NWG_RQ_SER_remoteQueueID = 0;//Incrementing counter for consistency

//================================================================================================================
//Enqueue logic
NWG_RQ_SER_AddCommand = {
	params ["_anchorObject","_funcName",["_args",[]]];
	if !(_anchorObject isEqualType objNull) exitWith {
		(format ["NWG_RQ_AddCommand: Anchor object is not an object for command '%1'",_funcName]) call NWG_fnc_logError;
		false
	};
	if (isNull _anchorObject) exitWith {
		(format ["NWG_RQ_AddCommand: Anchor object is null for command '%1'",_funcName]) call NWG_fnc_logError;
		false
	};

	//Add to queue
	private _counter = NWG_RQ_SER_remoteQueueID;
	NWG_RQ_SER_remoteQueueID = _counter + 1;
	NWG_RemoteQueue pushBack [_counter,_anchorObject,_funcName,_args];

	//Clear the queue from outdated commands (by checking anchor object)
	{
		if (isNull (_x#RQ_ANCHOR) || {!alive (_x#RQ_ANCHOR)})
			then {NWG_RemoteQueue deleteAt _forEachIndex};
	} forEachReversed NWG_RemoteQueue;

	//Setup propagation
	NWG_RQ_SER_propagateAt = time + RQ_BUFFERING_DELAY;
	if (isNull NWG_RQ_SER_propagateHandle || {scriptDone NWG_RQ_SER_propagateHandle})
		then {NWG_RQ_SER_propagateHandle = [] spawn NWG_RQ_SER_Propagate};

	//return
	true
};

//================================================================================================================
//Propagation logic
NWG_RQ_SER_propagateHandle = scriptNull;
NWG_RQ_SER_propagateAt = 0;
NWG_RQ_SER_Propagate = {
	//Wait for the buffer time
	waitUntil {
		sleep 0.1;
		time >= NWG_RQ_SER_propagateAt
	};

	//Propagate the queue
	publicVariable "NWG_RemoteQueue";

	//Notify the clients (with slight delay)
	//note: we do nested spawn to avoid dead zone between 'publicVariable' and 'remoteExec' where if new value is received, it will be ignored until the next time
	[] spawn {
		sleep RQ_BUFFERING_DELAY;
		remoteExec ["NWG_fnc_rqOnBroadcast",0];
	};
};
