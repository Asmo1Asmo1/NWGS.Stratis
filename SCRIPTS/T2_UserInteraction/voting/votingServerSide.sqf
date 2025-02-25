#include "votingDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_VOTE_SER_Settings = createHashMapFromArray [
    ["TIMEOUT",120],//Voting timeout
    ["THRESHOLD_MULTIPLIER",0.5],//Used to determine vote result: 'for' >= 'all'*X || 'against' >= 'all'*X

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_VOTE_SER_voteHandle = scriptNull;
NWG_VOTE_SER_voteResult = VOTE_UNDEFINED;

//================================================================================================================
//================================================================================================================
//Voting public functions
NWG_VOTE_SER_IsVoteRunning = {
    !isNull NWG_VOTE_SER_voteHandle && {!scriptDone NWG_VOTE_SER_voteHandle}
};
NWG_VOTE_SER_GetVoteResult = {
    if (call NWG_VOTE_SER_IsVoteRunning) exitWith {false};
    NWG_VOTE_SER_voteResult
};
NWG_VOTE_SER_OnVoteRequest = {
    params ["_anchor","_title"];
    if (isNull _anchor || {!alive _anchor}) exitWith {
        "NWG_VOTE_SER_OnVoteRequest: Invalid anchor" call NWG_fnc_logError;
        false
    };
    if ((count (call NWG_fnc_getPlayersAll)) <= 0) exitWith {
        "NWG_VOTE_SER_OnVoteRequest: No voters" call NWG_fnc_logError;
        false
    };
    if (call NWG_VOTE_SER_IsVoteRunning) exitWith {
        false
    };

    NWG_VOTE_SER_voteHandle = _this spawn NWG_VOTE_SER_VoteCore;
    true
};

//================================================================================================================
//================================================================================================================
//Voting core logic
NWG_VOTE_SER_VoteCore = {
    params ["_anchor","_title"];
    if (isNull _anchor || {!alive _anchor}) exitWith {
        "NWG_VOTE_SER_VoteCore: Invalid anchor" call NWG_fnc_logError;
        false
    };

    private _votersCount = count (call NWG_fnc_getPlayersAll);
    if (_votersCount == 0) exitWith {
        "NWG_VOTE_SER_VoteCore: No voters" call NWG_fnc_logError;
        false
    };

    //Prepre variables
    private _abortCondition = {!(_anchor call NWG_VOTE_COM_IsValidAnchor)};
    private _timeout = NWG_VOTE_SER_Settings get "TIMEOUT";
    private _timeoutAt = time + _timeout + 1;//Give extra second for vote result to be processed
    private _threshold = (round (_votersCount * (NWG_VOTE_SER_Settings get "THRESHOLD_MULTIPLIER"))) max 1;
    private _voteResult = VOTE_UNDEFINED;

    //Configure anchor
    [_anchor,0] call NWG_VOTE_COM_SetInfavor;
    [_anchor,0] call NWG_VOTE_COM_SetAgainst;

    //Start voting
    [_anchor,_title,_timeout] remoteExec ["NWG_fnc_voteStarted",0];

    //Wait for voting result
    waitUntil {
        if (call _abortCondition) exitWith {true};//Abort if anchor is dead/disconnected
        if (time > _timeoutAt) exitWith {true};//Abort if timeout is reached

        _voteResult = switch (true) do {
            case ((_anchor call NWG_VOTE_COM_GetInfavor) >= _threshold): {VOTE_INFAVOR};
            case ((_anchor call NWG_VOTE_COM_GetAgainst) >= _threshold): {VOTE_AGAINST};
            default {VOTE_UNDEFINED};
        };
        if (_voteResult != VOTE_UNDEFINED) exitWith {true};//Exit if vote result is determined

        sleep 1;
        false
    };

    //Finalize voting
    [_title,_voteResult] remoteExec ["NWG_fnc_voteEnded",0];
    if (_anchor call NWG_VOTE_COM_IsValidAnchor) then {_anchor call NWG_VOTE_COM_Clear};
    NWG_VOTE_SER_voteResult = _voteResult;
};