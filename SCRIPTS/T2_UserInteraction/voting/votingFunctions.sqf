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