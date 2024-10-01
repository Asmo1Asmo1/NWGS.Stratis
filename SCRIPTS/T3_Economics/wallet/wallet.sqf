NWG_WLT_Settings = createHashMapFromArray [
    ["MONEYSTR_PREFIX","$"],
    ["MONEYSTR_SEPARATOR",44],//char ","

    ["",0]
];

NWG_WLT_GetPlayerMoney = {
    //TODO: Implement actual logic later
    //return
    1123456
};

NWG_WLT_AddPlayerMoney = {
    //TODO: Implement actual logic later
};

NWG_WLT_SetPlayerMoney = {
    //TODO: Implement actual logic later
};

//Turns money into string representation (1123456 => "$1.123.456") (does not support decimals)
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