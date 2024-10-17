//================================================================================================================
//================================================================================================================
//Settings
NWG_WLT_Settings = createHashMapFromArray [
    ["MONEYSTR_PREFIX","€$"],
    ["MONEYSTR_SEPARATOR",44],//char ","

    ["INITIAL_MONEY",1000],//Initial amount of money a player has

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Init money
    [player,(NWG_WLT_Settings get "INITIAL_MONEY")] call NWG_fnc_wltSetPlayerMoney;

    //Transfer on respawn to new player instance
    player addEventHandler ["Respawn",{_this call NWG_WLT_OnRespawn}];
};

//================================================================================================================
//================================================================================================================
//On respawn
NWG_WLT_OnRespawn = {
    params ["_player","_corpse"];
    private _money = _corpse call NWG_fnc_wltGetPlayerMoney;
    if (_money != 0) then {
        [_player,_money] call NWG_fnc_wltSetPlayerMoney;
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
    private _separator = NWG_WLT_Settings get "MONEYSTR_SEPARATOR";

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
        (NWG_WLT_Settings get "MONEYSTR_PREFIX"),
        (toString _numArray)
    ]
};

//================================================================================================================
//================================================================================================================
//Messaging
NWG_WLT_NotifyMoneyChange = {
    params ["_player","_amount"];
    [
        (if (_amount >= 0) then {"#WLT_NOTIFY_MONEY_ADD#"} else {"#WLT_NOTIFY_MONEY_SUB#"}),
        (_amount call NWG_WLT_MoneyToString)
    ] call NWG_fnc_systemChatMe;
};

//================================================================================================================
//================================================================================================================
call _Init;