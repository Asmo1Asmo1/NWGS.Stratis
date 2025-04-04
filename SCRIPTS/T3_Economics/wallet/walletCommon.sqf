#include "..\..\globalDefines.h"
//================================================================================================================
//================================================================================================================
//Settings
NWG_WLT_COM_Settings = createHashMapFromArray [
    ["MONEYSTR_PREFIX","€$"],
    ["MONEYSTR_SEPARATOR",44],//char ","

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Money logic (must work both on server and client)
NWG_WLT_GetPlayerMoney = {
    // private _player = _this;
    _this getVariable ["NWG_WLT_Money",0]
};

NWG_WLT_AddPlayerMoney = {
    params ["_player","_amount"];
    _amount = round _amount;
    if (_amount == 0) exitWith {};//Nothing to do

    //Calculate new money amount
    private _money = _player getVariable ["NWG_WLT_Money",0];
    _money = (round (_money + _amount)) min 999999999;

    //Set new money amount
    private _publicFlag = if (isServer) then {[(owner _player),2]} else {[clientOwner,2]};
    _player setVariable ["NWG_WLT_Money",_money,_publicFlag];

    //Notify about money change
    [_player,_amount] call NWG_fnc_wltNotifyMoneyChange;

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_MONEY_CHANGED,_money] call NWG_fnc_raiseClientEvent;
    };
};

NWG_WLT_SetPlayerMoney = {
    params ["_player","_amount"];

    //Set new money amount
    private _publicFlag = if (isServer) then {[(owner _player),2]} else {[clientOwner,2]};
    _player setVariable ["NWG_WLT_Money",(round _amount),_publicFlag];

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_MONEY_CHANGED,_amount] call NWG_fnc_raiseClientEvent;
    };
};

//================================================================================================================
//================================================================================================================
//Stringify
//Turns money into string representation (1123456 => "€$1.123.456") (does not support decimals)
NWG_WLT_MoneyToString = {
    // private _money = _this;
    private _isNegative = _this < 0;
    if (_isNegative) then {
        _this = _this * -1;//Normalize for formatting
    };

    //Disassemble
    private _numArray = toArray (_this toFixed 0);//number->string->array of numbers
    private _separator = NWG_WLT_COM_Settings get "MONEYSTR_SEPARATOR";

    //Insert separator every 3 digits
    private _temp = _numArray + [];
    private _sepFlag = 0;
    _numArray resize 0;
    {
        _numArray pushBack _x;
        _sepFlag = _sepFlag + 1;
        if (_sepFlag == 3 && {_forEachIndex > 0}) then {
            _numArray pushBack _separator;
            _sepFlag = 0;
        };
    } forEachReversed _temp;
    reverse _numArray;

    //return
    format ["%1%2%3",
        (["","-"] select _isNegative),
        (NWG_WLT_COM_Settings get "MONEYSTR_PREFIX"),
        (toString _numArray)
    ]
};