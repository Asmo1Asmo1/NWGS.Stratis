NWG_VOTE_CLI_golos = 0;
NWG_VOTE_CLI_OnGolosRequest = {
    params ["_anchor","_title","_timeout"];

    //Check
    private _abortCondition = {isNull _anchor || {!alive _anchor || {!(_anchor call NWG_VOTE_COM_IsValid)}}};
    if (call _abortCondition) exitWith {};//Immediate check

    //Setup vote
    NWG_VOTE_CLI_golos = 0;
    private _handlerID = addMissionEventHandler ["HandleChatMessage",{
	    // params ["_channel","_owner","_from","_text","_person","_name","_strID","_forcedDisplay","_isPlayerMessage","_sentenceType","_chatMessageType","_params"];
        params ["","","","_text","_sender"];

        if (_sender isEqualTo player) then {
            private _answer = 0;
            if ("+" in _text) then {_answer = _answer + 1};
            if ("-" in _text) then {_answer = _answer - 1};
            if (_answer != 0) then {NWG_VOTE_CLI_golos = _answer};
        };

        //Always return false to not to mess with chat system
        false
    }];

    //Voting cycle
    _title = _title call NWG_fnc_translateMessage;
    private _stopClientAt = time + _timeout;
    private _counterTemplate = "#VOTE_COUNTER_TEMPLATE#" call NWG_fnc_localize;

    waitUntil {
        if (call _abortCondition) exitWith {true};//Abort check
        if (NWG_VOTE_CLI_golos != 0) exitWith {true};//Vote received
        if (time > _stopClientAt) exitWith {true};//Timeout

        private _for = _anchor call NWG_VOTE_COM_GetFor;
        private _against = _anchor call NWG_VOTE_COM_GetAgainst;
        private _timeLeft = (round (_stopClientAt - time)) max 1;
        hint (format [_counterTemplate,_for,_against,_timeLeft]);

        sleep 1;
        false
    };
    removeMissionEventHandler ["HandleChatMessage",_handlerID];//Cleanup

    //Vote result
    switch (true) do {
        case (call _abortCondition): {
            hintSilent ("#VOTE_HINT_ABORTED#" call NWG_fnc_localize);
        };
        case (NWG_VOTE_CLI_golos > 0): {
            _anchor call NWG_VOTE_COM_AddFor;
            hintSilent ("#VOTE_HINT_VOTE_RECEIVED#" call NWG_fnc_localize);
        };
        case (NWG_VOTE_CLI_golos < 0): {
            _anchor call NWG_VOTE_COM_AddAgainst;
            hintSilent ("#VOTE_HINT_VOTE_RECEIVED#" call NWG_fnc_localize);
        };
        default {
            hintSilent ("#VOTE_HINT_TIMEOUT#" call NWG_fnc_localize);
        };
    };
};