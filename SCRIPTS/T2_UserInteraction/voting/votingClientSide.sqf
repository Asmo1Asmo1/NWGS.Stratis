#include "votingDefines.h"

//================================================================================================================
//================================================================================================================
//Fields
NWG_VOTE_CLI_voteInProgress = false;
NWG_VOTE_CLI_voteHandle = scriptNull;
NWG_VOTE_CLI_myVote = VOTE_UNDEFINED;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["HandleChatMessage",{_this call NWG_VOTE_CLI_OnChatMessage}];
};

//================================================================================================================
//================================================================================================================
//Voting
NWG_VOTE_CLI_OnVoteStart = {
    //params ["_anchor","_title","_timeout"];
    if (!isNull NWG_VOTE_CLI_voteHandle && {!scriptDone NWG_VOTE_CLI_voteHandle}) then {terminate NWG_VOTE_CLI_voteHandle};//Abort previous vote
    NWG_VOTE_CLI_voteInProgress = true;
    NWG_VOTE_CLI_myVote = VOTE_UNDEFINED;
    NWG_VOTE_CLI_voteHandle = _this spawn NWG_VOTE_CLI_VoteCore;
};

NWG_VOTE_CLI_OnVoteEnd = {
    params ["_title","_result"];
    if (!isNull NWG_VOTE_CLI_voteHandle && {!scriptDone NWG_VOTE_CLI_voteHandle}) then {terminate NWG_VOTE_CLI_voteHandle};//Abort running vote
    NWG_VOTE_CLI_voteInProgress = false;
    NWG_VOTE_CLI_myVote = VOTE_UNDEFINED;

    private _hintTitle = _title call NWG_fnc_translateMessage;
    private _hintFooter = switch (_result) do {
        case VOTE_INFAVOR: {"#VOTE_RESULT_INFAVOR#"};
        case VOTE_AGAINST: {"#VOTE_RESULT_AGAINST#"};
        case VOTE_UNDEFINED: {"#VOTE_RESULT_UNDEFINED#"};
        default {""};
    };
    _hintFooter = _hintFooter call NWG_fnc_localize;

    hintSilent ([_hintTitle,_hintFooter] joinString "\n");
};

NWG_VOTE_CLI_VoteCore = {
    params ["_anchor","_title","_timeout"];
    private _abortCondition = {!(_anchor call NWG_VOTE_COM_IsValidAnchor)};
    if (call _abortCondition) exitWith {};//Immediate check
    private _timeoutAt = time + _timeout;

    //Wait for player vote
    private _hintTitle = _title call NWG_fnc_translateMessage;
    private _hintBodyTemplate = "#VOTE_HINT_BODY#" call NWG_fnc_localize;
    private _hintBody = "";
    private _hintFooter = "#VOTE_HINT_FOOTER_DO#" call NWG_fnc_localize;
    waitUntil {
        if (call _abortCondition) exitWith {true};//Abort check
        if (time > _timeoutAt) exitWith {true};//Timeout
        if (!NWG_VOTE_CLI_voteInProgress) exitWith {true};//Vote ended
        if (NWG_VOTE_CLI_myVote != VOTE_UNDEFINED) exitWith {true};//Player vote received

        _hintBody = format [
            _hintBodyTemplate,
            (_anchor call NWG_VOTE_COM_GetInfavor),
            (_anchor call NWG_VOTE_COM_GetAgainst),
            ((round (_timeoutAt - time)) max 1)
        ];

        hint ([_hintTitle,_hintBody,_hintFooter] joinString "\n");
        sleep 1;
        false
    };

    //Apply player vote
    switch (NWG_VOTE_CLI_myVote) do {
        case VOTE_INFAVOR: {_anchor call NWG_VOTE_COM_AddInfavor};
        case VOTE_AGAINST: {_anchor call NWG_VOTE_COM_AddAgainst};
    };

    //Wait for voting to end
    private _myVoteStr = switch (NWG_VOTE_CLI_myVote) do {
        case VOTE_INFAVOR: {"+"};
        case VOTE_AGAINST: {"-"};
        default {""};
    };
    _hintFooter = format [("#VOTE_HINT_FOOTER_DONE#" call NWG_fnc_localize),_myVoteStr];
    waitUntil {
        if (call _abortCondition) exitWith {true};//Abort check
        if (time > _timeoutAt) exitWith {true};//Timeout
        if (!NWG_VOTE_CLI_voteInProgress) exitWith {true};//Vote ended

        _hintBody = format [
            _hintBodyTemplate,
            (_anchor call NWG_VOTE_COM_GetInfavor),
            (_anchor call NWG_VOTE_COM_GetAgainst),
            ((round (_timeoutAt - time)) max 1)
        ];

        hintSilent ([_hintTitle,_hintBody,_hintFooter] joinString "\n");
        sleep 1;
        false
    };
};

//================================================================================================================
//================================================================================================================
//Chat handler
NWG_VOTE_CLI_OnChatMessage = {
    // params ["_channel","_owner","_from","_text","_person","_name","_strID","_forcedDisplay","_isPlayerMessage","_sentenceType","_chatMessageType","_params"];
    params ["","","","_text","_sender"];

    if (_sender isEqualTo player && {NWG_VOTE_CLI_voteInProgress && {NWG_VOTE_CLI_myVote == VOTE_UNDEFINED}}) then {
        private _answer = 0;
        if ("+" in _text) then {_answer = _answer + 1};
        if ("-" in _text) then {_answer = _answer - 1};
        if (_answer != 0) then {NWG_VOTE_CLI_myVote = _answer};
    };

    //Always return false to not to mess with chat system
    false
};

//================================================================================================================
//================================================================================================================
call _Init;