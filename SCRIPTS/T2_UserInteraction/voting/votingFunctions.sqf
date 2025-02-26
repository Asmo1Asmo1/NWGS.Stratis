/*Any -> Client|Server */
//Check if vote is running
//note: auto detects wether it is running on client or server
//returns:
// bool - true if vote is running, false otherwise
NWG_fnc_voteIsRunning = {
    if (!isNil "NWG_VOTE_SER_IsVoteRunning") exitWith {
        call NWG_VOTE_SER_IsVoteRunning
    };
    if (!isNil "NWG_VOTE_CLI_voteInProgress") exitWith {
        NWG_VOTE_CLI_voteInProgress
    };

    "NWG_fnc_voteIsRunning: Both options are nil" call NWG_fnc_logError;
    false
};

/*Any -> Server */
//Get vote result on server side
//returns:
// number - result of the vote (-1 against, 0 undefined, 1 in favor) OR false if vote is still running
NWG_fnc_voteGetResult = {
    call NWG_VOTE_SER_GetVoteResult;
};

//Request to start vote on server side
//params:
// _anchor - object - anchor object
// _title - string OR array - title of the vote (singular or complex with arguments)
//returns:
// bool - true if vote was requested, false in case of error or if another vote is already running
NWG_fnc_voteRequestServer = {
    // params ["_anchor","_title"];
    _this call NWG_VOTE_SER_OnVoteRequest;
};

/* Server -> Client */
//Sends vote request to clients
//params:
// _anchor - object - anchor object
// _title - string OR array - title of the vote (singular or complex with arguments)
// _timeout - number - timeout of the vote
NWG_fnc_voteStarted = {
    // params ["_anchor","_title","_timeout"];
    if (!hasInterface) exitWith {};
    if (isNil "NWG_VOTE_CLI_OnVoteStart") exitWith {};//Fix client not ready yet
    if (isNull player || {!alive player}) exitWith {};//Fix player not ready yet
    _this call NWG_VOTE_CLI_OnVoteStart;
};

//Sends vote result to clients
//params:
// _title - string OR array - title of the vote (singular or complex with arguments)
// _result - number - result of the vote
NWG_fnc_voteEnded = {
    // params ["_title","_result"];
    if (!hasInterface) exitWith {};
    if (isNil "NWG_VOTE_CLI_OnVoteEnd") exitWith {};//Fix client not ready yet
    if (isNull player || {!alive player}) exitWith {};//Fix player not ready yet
    _this call NWG_VOTE_CLI_OnVoteEnd;
};