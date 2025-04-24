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
    private _oldMoney = _player getVariable ["NWG_WLT_Money",0];
    private _newMoney = (round (_oldMoney + _amount)) min 999999999;
    private _delta = _newMoney - _oldMoney;

    //Set new money amount
    _player setVariable ["NWG_WLT_Money",_newMoney,true];

    //Notify about money change
    [_player,_amount] call NWG_fnc_wltNotifyMoneyChange;

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_MONEY_CHANGED,[_oldMoney,_newMoney,_delta]] call NWG_fnc_raiseClientEvent;
    };
};

NWG_WLT_SetPlayerMoney = {
    params ["_player","_amount"];

    //Set new money amount
    private _oldMoney = _player getVariable ["NWG_WLT_Money",0];
    private _newMoney = round _amount;
    private _delta = _newMoney - _oldMoney;

    //Set new money amount
    _player setVariable ["NWG_WLT_Money",_newMoney,true];

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_MONEY_CHANGED,[_oldMoney,_newMoney,_delta]] call NWG_fnc_raiseClientEvent;
    };
};

//================================================================================================================
//================================================================================================================
//Group money
NWG_WLT_GetGroupMoney = {
    // private _group = _this;
    private _units = (units _this) select {alive _x && {isPlayer _x}};
    if ((count _units) == 0) exitWith {0};
    if ((count _units) == 1) exitWith {(_units#0) call NWG_WLT_GetPlayerMoney};

    //Sum up money for all units
    private _sum = 0;
    {_sum = _sum + _x} forEach (_units apply {_x call NWG_WLT_GetPlayerMoney});
    _sum
};

NWG_WLT_SplitMoneyToGroup = {
    params ["_group","_money"];
    if (_money == 0) exitWith {};//Do nothing

    private _units = (units _group) select {alive _x && {isPlayer _x}};
    if ((count _units) <= 0) exitWith {};
    if ((count _units) == 1) exitWith {[(_units#0),_money] call NWG_WLT_AddPlayerMoney};

    if (_money > 0) then {
        //Players earned - simple logic, each gets their share equally
        private _share = round (_money / (count _units));
        {[_x,_share] call NWG_WLT_AddPlayerMoney} forEach _units;
    } else {
        //Players spent - balance out losses based on what each player has
        private _balanced = [_money,_units] call NWG_WLT_BalanceLosses;
        {[_x#0,_x#1] call NWG_WLT_AddPlayerMoney} forEach _balanced;
    };
};

#define BALANCE_UNIT 0
#define BALANCE_SHARE 1
#define BALANCE_MONEY 2
NWG_WLT_BalanceLosses = {
    params ["_totalDebt","_units"];
    if ((count _units) == 0) exitWith {[]};//No players - nothing to balance
    if ((count _units) == 1) exitWith {[[(_units#0),_totalDebt]]};//Only one player - take all responsibility

    //Prepare variables
    _totalDebt = abs _totalDebt;
    private _balancing = _units apply {[_x,0,((_x call NWG_WLT_GetPlayerMoney) max 0)]};//[unit,share,money]
    private _balanced = [];
    private _newShare = 0;
    private _iterations = 100;//Just in case

    //Balance debt in iterations
    while {true} do {
        _iterations = _iterations - 1;
        _newShare = round (_totalDebt / ((count _balancing) max 1));

        {
            _x params ["","_curShare","_myMoney"];
            if (_myMoney > (_curShare + _newShare)) then {
                //Enough money - take their share
                _x set [BALANCE_SHARE,(_curShare + _newShare)];
                _totalDebt = _totalDebt - _newShare;
            } else {
                //Not enough money - take what they can pay
                _x set [BALANCE_SHARE,_myMoney];
                _totalDebt = _totalDebt + _curShare - _myMoney;//Restore what was (possibly) taken out on prev iteration and subtract all that player has
                _balancing deleteAt _forEachIndex;
                _balanced pushBack _x;
            };
        } forEachReversed _balancing;

        if ((count _balancing) == 0) exitWith {};
        if (_totalDebt <= 0) exitWith {
            _balanced append _balancing;
            _balancing resize 0;
        };
        if (_iterations <= 0) exitWith {
            "NWG_WLT_BalanceLosses: Exceeded max iterations" call NWG_fnc_logError;
            _balanced append _balancing;
            _balancing resize 0;
        };
    };

    //Balance the rest of the debt (if any) equally between players
    if (_totalDebt > 0) then {
        _newShare = round (_totalDebt / ((count _balanced) max 1));
        {_x set [BALANCE_SHARE,((_x#BALANCE_SHARE) + _newShare)]} forEach _balanced;
    };

    //return
    _balanced apply {[(_x#BALANCE_UNIT),-(_x#BALANCE_SHARE)]}
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