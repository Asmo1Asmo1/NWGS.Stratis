#include "votingDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_VOTE_SER_Settings = createHashMapFromArray [
    ["TIMEOUT",60],//Voting timeout

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_VOTE_SER_voteHandle = scriptNull;
NWG_VOTE_SER_voteResult = VOTE_UNDEFINED;
NWG_VOTE_SER_currentAnchor = objNull; // Track current voting anchor
NWG_VOTE_SER_votersWhoVoted = []; // Track players who already voted

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
        "NWG_VOTE_SER_OnVoteRequest: Another vote is running" call NWG_fnc_logError;
        false
    };

    NWG_VOTE_SER_voteResult = VOTE_UNDEFINED;
    NWG_VOTE_SER_voteHandle = _this spawn NWG_VOTE_SER_VoteCore;
    true
};

//================================================================================================================
//================================================================================================================
//Voting core logic
NWG_VOTE_SER_VoteCore = {
    params ["_anchor","_title"];

    //Checks
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

    // Calculate thresholds based on voter count
    private _thresholdInfavor = if ((_votersCount % 2) == 0)
        then {(_votersCount / 2) + 1}/*Even number of voters: 50% + 1 vote (simple majority)*/
        else {ceil(_votersCount / 2)};/*Odd number of voters: ceil(50%) (majority)*/
    private _thresholdAgainst = if ((_votersCount % 2) == 0)
        then {_votersCount / 2}      /*Even number of voters: 50% (half can block)*/
        else {ceil(_votersCount / 2)}/*Odd number of voters: ceil(50%) (majority needed to block)*/

    private _voteResult = VOTE_UNDEFINED;

    //Configure anchor
    [_anchor,0] call NWG_VOTE_COM_SetInfavor;
    [_anchor,0] call NWG_VOTE_COM_SetAgainst;

    // Initialize server tracking
    NWG_VOTE_SER_currentAnchor = _anchor;
    NWG_VOTE_SER_votersWhoVoted = [];

    //Start voting
    [_anchor,_title,_timeout] remoteExec ["NWG_fnc_voteOnStarted",0];

    //Wait for voting result
    waitUntil {
        if (call _abortCondition) exitWith {true};//Abort if anchor is dead/disconnected
        if (time > _timeoutAt) exitWith {true};//Abort if timeout is reached

        _voteResult = switch (true) do {
            case ((_anchor call NWG_VOTE_COM_GetInfavor) >= _thresholdInfavor): {VOTE_INFAVOR};
            case ((_anchor call NWG_VOTE_COM_GetAgainst) >= _thresholdAgainst): {VOTE_AGAINST};
            default {VOTE_UNDEFINED};
        };
        if (_voteResult != VOTE_UNDEFINED) exitWith {true};//Exit if vote result is determined

        sleep 1;
        false
    };

    //Finalize voting
    [_title,_voteResult] remoteExec ["NWG_fnc_voteOnEnded",0];
    if (_anchor call NWG_VOTE_COM_IsValidAnchor) then {_anchor call NWG_VOTE_COM_Clear};
    NWG_VOTE_SER_voteResult = _voteResult;

    // Clear server tracking
    NWG_VOTE_SER_currentAnchor = objNull;
    NWG_VOTE_SER_votersWhoVoted = [];
};

NWG_VOTE_SER_OnPlayerVote = {
    params ["_player", "_voteType"];

    // Validation checks
    if !(call NWG_VOTE_SER_IsVoteRunning) exitWith {
        "NWG_VOTE_SER_OnPlayerVote: No vote is running" call NWG_fnc_logError;
    };
    if (isNull NWG_VOTE_SER_currentAnchor || {!alive NWG_VOTE_SER_currentAnchor}) exitWith {
        "NWG_VOTE_SER_OnPlayerVote: Invalid anchor" call NWG_fnc_logError;
    };
    if (_player in NWG_VOTE_SER_votersWhoVoted) exitWith {
        "NWG_VOTE_SER_OnPlayerVote: Player already voted" call NWG_fnc_logError;
    };

    // Record that this player voted
    NWG_VOTE_SER_votersWhoVoted pushBack _player;

    // Apply vote safely on server
    switch (_voteType) do {
        case VOTE_INFAVOR: {
            private _currentValue = NWG_VOTE_SER_currentAnchor call NWG_VOTE_COM_GetInfavor;
            [NWG_VOTE_SER_currentAnchor, _currentValue + 1] call NWG_VOTE_COM_SetInfavor;
        };
        case VOTE_AGAINST: {
            private _currentValue = NWG_VOTE_SER_currentAnchor call NWG_VOTE_COM_GetAgainst;
            [NWG_VOTE_SER_currentAnchor, _currentValue + 1] call NWG_VOTE_COM_SetAgainst;
        };
        default {
            (format ["NWG_VOTE_SER_OnPlayerVote: Invalid vote type: '%1'",_voteType]) call NWG_fnc_logError;
        };
    };
};