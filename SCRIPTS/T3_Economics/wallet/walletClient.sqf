//================================================================================================================
//================================================================================================================
//Settings
NWG_WLT_CLI_Settings = createHashMapFromArray [
    ["MONEYSTR_PREFIX","€$"],
    ["MONEYSTR_SEPARATOR",44],//char ","

    ["INITIAL_MONEY",20250],//Initial amount of money a player has

    ["MONEY_ADD_NOTIFY",true],//Notify player when money is added
    ["MONEY_ADD_NOTIFY_SOUND","FD_Target_PopUp_Small_F"],//Sound to play when money is added
    ["MONEY_SUB_NOTIFY",true],//Notify player when money is subtracted
    ["MONEY_SUB_NOTIFY_SOUND","FD_Target_PopUp_Small_F"],//Sound to play when money is subtracted

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Init money
    [player,(NWG_WLT_CLI_Settings get "INITIAL_MONEY")] call NWG_fnc_wltSetPlayerMoney;

    //Transfer on respawn to new player instance
    //UPD: Not required, public variables get transferred on respawn automatically
    // player addEventHandler ["Respawn",{_this call NWG_WLT_OnRespawn}];
};

//================================================================================================================
//================================================================================================================
//On respawn
// NWG_WLT_OnRespawn = {
//     params ["_player","_corpse"];
//     private _money = _corpse call NWG_fnc_wltGetPlayerMoney;
//     if (_money != 0) then {
//         [_player,_money] call NWG_fnc_wltSetPlayerMoney;
//     };
// };

//================================================================================================================
//================================================================================================================
//Notification
NWG_WLT_NotifyMoneyChange = {
    params ["_player","_amount"];

    private _isAdd = _amount >= 0;
    private ["_shouldNotify","_messageTemplate","_sound"];
    if (_isAdd) then {
        _shouldNotify = NWG_WLT_CLI_Settings get "MONEY_ADD_NOTIFY";
        _messageTemplate = "#WLT_NOTIFY_MONEY_ADD#";
        _sound = NWG_WLT_CLI_Settings get "MONEY_ADD_NOTIFY_SOUND";
    } else {
        _shouldNotify = NWG_WLT_CLI_Settings get "MONEY_SUB_NOTIFY";
        _messageTemplate = "#WLT_NOTIFY_MONEY_SUB#";
        _sound = NWG_WLT_CLI_Settings get "MONEY_SUB_NOTIFY_SOUND";
    };

    if (_shouldNotify) then {
        [_messageTemplate,(_amount call NWG_WLT_MoneyToString)] call NWG_fnc_systemChatMe;
        playSound _sound;
    };
};

//================================================================================================================
//================================================================================================================
//Group money
NWG_WLT_GetGroupMoney = {
    // private _group = _this;
    private _units = (units _this) select {alive _x && {isPlayer _x}};
    if ((count _units) == 0) exitWith {0};
    if ((count _units) == 1) exitWith {(_units#0) call NWG_fnc_wltGetPlayerMoney};

    //Sum up money for all units
    private _sum = 0;
    {_sum = _sum + _x} forEach (_units apply {_x call NWG_fnc_wltGetPlayerMoney});
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
        {[_x#0,_x#1] call NWG_fnc_wltAddPlayerMoney} forEach _balanced;
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
    private _balancing = _units apply {[_x,0,((_x call NWG_fnc_wltGetPlayerMoney) max 0)]};//[unit,share,money]
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
call _Init;