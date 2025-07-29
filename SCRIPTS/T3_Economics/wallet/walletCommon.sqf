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
    if ((count _units) == 1) exitWith {[(_units#0),_money] call NWG_fnc_wltAddPlayerMoney};

    if (_money > 0) then {
        //Players earned - simple logic, each gets their share equally
        private _share = round (_money / (count _units));
        {[_x,_share] call NWG_fnc_wltAddPlayerMoney} forEach _units;
    } else {
        //Players spent - balance out losses based on what each player has
        private _balanced = [_money,_units] call NWG_WLT_BalanceLosses;
        {[(_x#0),(_x#1)] call NWG_fnc_wltAddPlayerMoney} forEach _balanced;
    };
};

#define BALANCE_MONEY 0
#define BALANCE_SHARE 1
#define BALANCE_UNIT 2
NWG_WLT_BalanceLosses = {
    params ["_totalDebt","_units"];
    if ((count _units) == 0) exitWith {[]};
    if ((count _units) == 1) exitWith {[[(_units#0),_totalDebt]]};
    _totalDebt = round (abs _totalDebt);
    if (_totalDebt == 0) exitWith {[]};

    //Prepare data
    private _money = 0;
    private _totalMoney = 0;
    private _balancing = _units apply {
        _money = (round (_x call NWG_WLT_GetPlayerMoney)) max 0;
        _totalMoney = _totalMoney + _money;
        [_money,0,_x]
    };

    //Check if we have enough money to cover the debt
    if (_totalMoney == _totalDebt) exitWith {
        private _balanced = _balancing apply {[(_x#BALANCE_UNIT),-(_x#BALANCE_MONEY)]};
        //return
        _balanced
    };
    if (_totalMoney < _totalDebt) exitWith {
        (format ["NWG_WLT_BalanceLosses: Not enough money '%1' to cover the debt: %2. Should never happen.",_totalMoney,_totalDebt]) call NWG_fnc_logError;
        private _delta = _totalDebt - _totalMoney;
        private _share = round (_delta / (count _units));
        private _balanced = _balancing apply {[(_x#BALANCE_UNIT),-((_x#BALANCE_MONEY)+_share)]};
        //return
        _balanced
    };

    //Sort units and distribute debt
    _balancing sort false;//Will sort by money, highest to lowest (we need it that way because we will iterate in reverse order)
    private _balanced = [];
    private _share = round (_totalDebt / (count _units));
    {
        if ((_x#BALANCE_MONEY) >= _share) then {
            //Enough money to cover the share
            _x set [BALANCE_SHARE,_share];//Sign up for full share
            _balanced pushBack _x;//Add to balanced list
            _balancing deleteAt _forEachIndex;//Remove from balancing list
            _totalDebt = _totalDebt - _share;//Subtract from total debt
        } else {
            //Not enough money
            private _delta = _share - (_x#BALANCE_MONEY);
            _x set [BALANCE_SHARE,_x#BALANCE_MONEY];//Sign up for what we have
            _balanced pushBack _x;//Add to balanced list
            _balancing deleteAt _forEachIndex;//Remove from balancing list
            _totalDebt = _totalDebt - _x#BALANCE_MONEY;//Subtract from total debt
            _share = round (_totalDebt / ((count _balancing) max 1));//Re-calculate share based on remaining units
        };
    } forEachReversed _balancing;

    //Check if we have any debt left
    if (_totalDebt > 100) then {
        (format ["NWG_WLT_BalanceLosses: High amount of debt left: '%1'",_totalDebt]) call NWG_fnc_logError;
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