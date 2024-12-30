//================================================================================================================
//================================================================================================================
//Settings
NWG_WLT_Settings = createHashMapFromArray [
    ["MONEYSTR_PREFIX","€$"],
    ["MONEYSTR_SEPARATOR",44],//char ","

    ["INITIAL_MONEY",15000],//Initial amount of money a player has

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
    [player,(NWG_WLT_Settings get "INITIAL_MONEY")] call NWG_fnc_wltSetPlayerMoney;

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

    private _isAdd = _amount >= 0;
    private ["_shouldNotify","_messageTemplate","_sound"];
    if (_isAdd) then {
        _shouldNotify = NWG_WLT_Settings get "MONEY_ADD_NOTIFY";
        _messageTemplate = "#WLT_NOTIFY_MONEY_ADD#";
        _sound = NWG_WLT_Settings get "MONEY_ADD_NOTIFY_SOUND";
    } else {
        _shouldNotify = NWG_WLT_Settings get "MONEY_SUB_NOTIFY";
        _messageTemplate = "#WLT_NOTIFY_MONEY_SUB#";
        _sound = NWG_WLT_Settings get "MONEY_SUB_NOTIFY_SOUND";
    };

    if (_shouldNotify) then {
        [_messageTemplate,(_amount call NWG_WLT_MoneyToString)] call NWG_fnc_systemChatMe;
        playSound _sound;
    };
};

//================================================================================================================
//================================================================================================================
call _Init;