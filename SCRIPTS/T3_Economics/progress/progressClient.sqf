#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_PRG_Settings = createHashMapFromArray [
    ["INITIAL_PROGRESS",P_DEFAULT_CHART],//Initial amount of progress a player has

    /*Notifications*/
    ["NOTIFY_LOCALIZATION",[
        "#PRG_NOTIFY__EXP#",/*P__EXP*/
        "#PRG_NOTIFY_TEXP#",/*P_TEXP*/
        "#PRG_NOTIFY_TAXI#",/*P_TAXI*/
        "#PRG_NOTIFY_TRDR#",/*P_TRDR*/
        "#PRG_NOTIFY_COMM#"/*P_COMM*/
    ]],
    ["NOTIFY_MULTIPLIER",[
        1,/*P__EXP*/
        1,/*P_TEXP*/
        10,/*P_TAXI*/
        10,/*P_TRDR*/
        1/*P_COMM*/
    ]],
    ["NOTIFY_SYSTEMCHAT",[
        true,/*P__EXP*/
        false,/*P_TEXP*/
        true,/*P_TAXI*/
        true,/*P_TRDR*/
        true/*P_COMM*/
    ]],
    ["NOTIFY_HINT",[
        false,/*P__EXP*/
        true,/*P_TEXP*/
        true,/*P_TAXI*/
        true,/*P_TRDR*/
        true/*P_COMM*/
    ]],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Init progress
    [player,(NWG_PRG_Settings get "INITIAL_PROGRESS")] call NWG_fnc_pSetPlayerProgress;
};

//================================================================================================================
//================================================================================================================
//Notification
NWG_PRG_NotifyProgressChange = {
    params ["_player","_type","_amount","_total"];
    private _locKey = (NWG_PRG_Settings get "NOTIFY_LOCALIZATION") select _type;
    private _multiplier = (NWG_PRG_Settings get "NOTIFY_MULTIPLIER") select _type;
    _amount = _amount * _multiplier;
    _total = _total * _multiplier;

    //System chat
    if ((NWG_PRG_Settings get "NOTIFY_SYSTEMCHAT") select _type) then {
        [_locKey,_amount,_total] call NWG_fnc_systemChatMe;
    };

    //Hint
    if ((NWG_PRG_Settings get "NOTIFY_HINT") select _type) then {
        private _message = format [(_locKey call NWG_fnc_localize),_amount,_total];
        _message = _message splitString ".";
        _message = _message joinString "\n";
        hint _message;
    };
};

//================================================================================================================
//================================================================================================================
call _Init;