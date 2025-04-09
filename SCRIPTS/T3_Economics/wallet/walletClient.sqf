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
call _Init;