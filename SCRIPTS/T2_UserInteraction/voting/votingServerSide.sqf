//================================================================================================================
//================================================================================================================
//Settings
NWG_VOTE_SER_Settings = createHashMapFromArray [
    ["DEFAULT_TIMEOUT",120],//Default timeout for voting
    ["DEFAULT_THRESHOLD_MULTIPLIER",0.5],//Used to determine vote result: 'for' >= 'all'*X || 'against' >= 'all'*X
    ["",0]
];

//================================================================================================================
//================================================================================================================
//Voting
NWG_VOTE_SER_OnVoteRequest = {
    params ["_anchor","_title","_forCallback","_againstCallback","_failCallback",
        ["_timeout",(NWG_VOTE_SER_Settings get "DEFAULT_TIMEOUT")],
        ["_votersFilter",{true}]
    ];

    NWG_VOTE_SER_votingQueue pushBack [
        _anchor,_title,_forCallback,_againstCallback,_failCallback,_timeout,_votersFilter
    ];

    if (isNull NWG_VOTE_SER_votingHandle || {scriptDone NWG_VOTE_SER_votingHandle}) then {
        NWG_VOTE_SER_votingHandle = [] spawn NWG_VOTE_SER_VoteCore;
    };
};

NWG_VOTE_SER_votingQueue = [];
NWG_VOTE_SER_votingHandle = scriptNull;
NWG_VOTE_SER_VoteCore = {
    //Until queue is emptied
    while {(count NWG_VOTE_SER_votingQueue) > 0} do {
        //Unpack first queue item
        (NWG_VOTE_SER_votingQueue deleteAt 0) params [
            "_anchor","_title","_forCallback","_againstCallback","_failCallback","_timeout","_votersFilter"
        ];
        if (isNull _anchor || {!alive _anchor}) then {call _failCallback; continue};//Abort if anchor is dead/disconnected

        //Get voters
        private _voters = (call NWG_fnc_getPlayersAll) select {_x isNotEqualTo _anchor};
        _voters = _voters select _votersFilter;
        private _all = count _voters;
        if (_all == 0) then {call _failCallback; continue};//Abort if no voters

        //Prepre variables
        private _stopServerAt = time + _timeout + 1;//Give extra second for vote result to be processed
        private _mult = (NWG_VOTE_SER_Settings get "DEFAULT_THRESHOLD_MULTIPLIER");
        private _threshold = (round (_all * _mult)) max 1;
        private _for = 0;
        private _against = 0;
        private _voteResult = 0;

        //Configure anchor
        [_anchor,_for]     call NWG_VOTE_COM_SetFor;
        [_anchor,_against] call NWG_VOTE_COM_SetAgainst;

        //Start voting
        [_anchor,_title,_timeout] remoteExec ["NWG_fnc_voteRequestGolos",_voters];

        //Wait for voting result
        waitUntil {
            if (isNull _anchor || {!alive _anchor}) exitWith {true};//Abort if anchor is dead/disconnected
            if (time > _stopServerAt) exitWith {true};//Abort if timeout is reached

            _for     = _anchor call NWG_VOTE_COM_GetFor;
            _against = _anchor call NWG_VOTE_COM_GetAgainst;
            _voteResult = switch (true) do {
                case (_for     >= _threshold): { 1};
                case (_against >= _threshold): {-1};
                default {0};
            };

            if (_voteResult != 0) exitWith {true};//Exit if vote result is determined

            sleep 1;
            false
        };

        //Re-collect voters because they could have changed
        _voters = (call NWG_fnc_getPlayersAll) select {_x isNotEqualTo _anchor};
        _voters = _voters select _votersFilter;

        //End the voting for all voters
        [] remoteExec ["NWG_fnc_voteRequestGolosEnd",_voters];

        //Clear anchor
        if (!isNull _anchor) then {_anchor call NWG_VOTE_COM_Clear};

        //Execute callback based on vote result
        switch (_voteResult) do {
            case  1: {call _forCallback};
            case -1: {call _againstCallback};
            default  {call _failCallback}/*Will also fire in case anchor is null or timeout reached*/
        };
    };
};