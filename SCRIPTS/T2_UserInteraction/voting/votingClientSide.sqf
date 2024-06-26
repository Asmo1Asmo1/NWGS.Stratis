//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["HandleChatMessage",{_this call NWG_VOTE_CLI_OnChatMessage}];
};

//================================================================================================================
//================================================================================================================
//Golos
NWG_VOTE_CLI_OnGolosRequest = {
    //params ["_anchor","_title","_timeout"];
    if (NWG_VOTE_CLI_golosInProgress) then {call NWG_VOTE_CLI_OnGolosEnd};//Abort previous vote
    NWG_VOTE_CLI_golos = 0;
    NWG_VOTE_CLI_golosInProgress = true;
    NWG_VOTE_CLI_golosHandle = _this spawn NWG_VOTE_CLI_GolosCore;
};

NWG_VOTE_CLI_OnGolosEnd = {
    NWG_VOTE_CLI_golos = 0;
    NWG_VOTE_CLI_golosInProgress = false;
    if (!isNull NWG_VOTE_CLI_golosHandle || {!scriptDone NWG_VOTE_CLI_golosHandle}) then {
        hintSilent "";//Clear hint
        terminate NWG_VOTE_CLI_golosHandle;
    };
};

NWG_VOTE_CLI_golos = 0;
NWG_VOTE_CLI_golosInProgress = false;
NWG_VOTE_CLI_golosHandle = scriptNull;
NWG_VOTE_CLI_GolosCore = {
    params ["_anchor","_title","_timeout"];
    private _abortCondition = {isNull _anchor || {!alive _anchor || {!(_anchor call NWG_VOTE_COM_IsValid)}}};
    if (call _abortCondition) exitWith {};//Immediate check

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

//================================================================================================================
//================================================================================================================
//Chat handler
NWG_VOTE_CLI_OnChatMessage = {
    // params ["_channel","_owner","_from","_text","_person","_name","_strID","_forcedDisplay","_isPlayerMessage","_sentenceType","_chatMessageType","_params"];
    params ["","","","_text","_sender"];

    if (_sender isEqualTo player && {NWG_VOTE_CLI_golosInProgress}) then {
        private _answer = 0;
        if ("+" in _text) then {_answer = _answer + 1};
        if ("-" in _text) then {_answer = _answer - 1};
        if (_answer != 0) then {NWG_VOTE_CLI_golos = _answer};
    };

    //Always return false to not to mess with chat system
    false
};

//================================================================================================================
//================================================================================================================
//Poset-compilation init
call _Init;