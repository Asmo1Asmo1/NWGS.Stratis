#include "..\..\globalDefines.h"

//Progress
// #define P__EXP 0 /*Experience*/
// #define P__LVL 1 /*Total Experience*/
// #define P_TAXI 2 /*Progress with Taxi*/
// #define P_TRDR 3 /*Progress with Trader*/
// #define P_COMM 4 /*Progress with Commander*/
// #define P_DEFAULT_CHART [0,0,0,0,0]

//================================================================================================================
//================================================================================================================
//Settings
NWG_PRG_Settings = createHashMapFromArray [
    /*Initial progress*/
    ["INITIAL_PROGRESS",P_DEFAULT_CHART],//Initial amount of progress a player has

    /*Upper limits*/
	["LIMITS",[
		-1,/*P__EXP*/
		-1,/*P__LVL*/
		10,/*P_TAXI*/
		10,/*P_TRDR*/
		5  /*P_COMM*/
	]],

    /*Upgrade prices*//*params ["_priceMoney","_priceExp"]*/
	["PRICES",[
		[5000,      2],/*0->1*/
		[15000,     4],/*1->2*/
		[50000,     6],/*2->3*/
		[150000,    10],/*3->4*/
		[500000,    15],/*4->5*/
		[1500000,   20],/*5->6*/
		[5000000,   25],/*6->7*/
		[15000000,  30],/*7->8*/
		[50000000,  40],/*8->9*/
		[100000000, 50]/*9->10*/
	]],

    /*Notifications*/
    ["NOTIFY_LOCALIZATION",[
        "#PRG_NOTIFY__EXP#",/*P__EXP*/
        "#PRG_NOTIFY_TEXP#",/*P__LVL*/
        "#PRG_NOTIFY_TAXI#",/*P_TAXI*/
        "#PRG_NOTIFY_TRDR#",/*P_TRDR*/
        "#PRG_NOTIFY_COMM#"/*P_COMM*/
    ]],
    ["NOTIFY_MULTIPLIER",[
        1,/*P__EXP*/
        1,/*P__LVL*/
        10,/*P_TAXI*/
        10,/*P_TRDR*/
        1/*P_COMM*/
    ]],
    ["NOTIFY_SYSTEMCHAT",[
        true,/*P__EXP*/
        false,/*P__LVL*/
        true,/*P_TAXI*/
        true,/*P_TRDR*/
        true/*P_COMM*/
    ]],
    ["NOTIFY_HINT",[
        false,/*P__EXP*/
        true,/*P__LVL*/
        true,/*P_TAXI*/
        true,/*P_TRDR*/
        true/*P_COMM*/
    ]],

    /*Stringifying*/
    ["STRINGIFY",[
        "Exp: %1",/*P__EXP*/
        "lvl %1", /*P__LVL*/
        "%1%%",   /*P_TAXI*/
        "%1%%",   /*P_TRDR*/
        "%1"      /*P_COMM*/
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

    private _amountStr = if (_amount >= 0)
        then {format ["+%1",_amount]}
        else {format ["%1",_amount]};

    //System chat
    if ((NWG_PRG_Settings get "NOTIFY_SYSTEMCHAT") select _type) then {
        [_locKey,_amountStr,_total] call NWG_fnc_systemChatMe;
    };

    //Hint
    if ((NWG_PRG_Settings get "NOTIFY_HINT") select _type) then {
        private _message = format [(_locKey call NWG_fnc_localize),_amountStr,_total];
        _message = _message splitString ".";
        _message = _message joinString "\n";
        hint _message;
    };
};

//================================================================================================================
//================================================================================================================
//Progress buy logic
NWG_PRG_GetUpgradeValues = {
	private _type = _this;
	if (_type < P_TAXI || {_type > ((count (NWG_PRG_Settings get "LIMITS"))-1)}) exitWith {
		(format ["NWG_PRG_GetUpgradeValues: Invalid type: %1",_type]) call NWG_fnc_logError;
		[false,false,-1,-1]
	};

	//Check upgrade limits
	private _myLevel = (player call NWG_fnc_pGetPlayerProgress) param [_type,0];
	if (_myLevel >= ((NWG_PRG_Settings get "LIMITS") select _type)) exitWith {
		[true,false,-1,-1]
	};

	//Get 'canAfford' and 'price' values
	private _myMoney = player call NWG_fnc_wltGetPlayerMoney;
	private _myExp = player call NWG_fnc_pGetMyExp;
	((NWG_PRG_Settings get "PRICES") param [_myLevel,[]]) params ["_priceMoney","_priceExp"];
    if (isNil "_priceMoney" || {isNil "_priceExp"}) exitWith {
        (format ["NWG_PRG_GetUpgradeValues: Invalid price for type: '%1', level: '%2'",_type,_myLevel]) call NWG_fnc_logError;
        [false,false,-1,-1]
    };
	private _canAfford = _myMoney >= _priceMoney && {_myExp >= _priceExp};

	//return
	[false,_canAfford,_priceMoney,_priceExp]
};

NWG_PRG_CanUpgrade = {
	// private _type = _this;
	(_this call NWG_PRG_GetUpgradeValues) params ["_reachedLimit","_canAfford"];
	//return
	(!_reachedLimit && _canAfford)
};

NWG_PRG_Upgrade = {
	// private _type = _this;
	(_this call NWG_PRG_GetUpgradeValues) params ["_reachedLimit","_canAfford","_priceMoney","_priceExp"];
	if (_reachedLimit) exitWith {
		(format ["NWG_PRG_Upgrade: Upgrade limit reached: %1",_this]) call NWG_fnc_logError;
		false
	};
	if (!_canAfford) exitWith {
		(format ["NWG_PRG_Upgrade: Cannot afford upgrade: %1",_this]) call NWG_fnc_logError;
		false
	};

	//Pay for upgrade
	[player,-_priceMoney] call NWG_fnc_wltAddPlayerMoney;
	[player,P__EXP,-_priceExp] call NWG_fnc_pAddPlayerProgress;

	//Upgrade
	[player,_this,1] call NWG_fnc_pAddPlayerProgress;

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Dialogue helpers
NWG_PRG_GetProgressAsString = {
    params ["_player","_progressType"];
    private _progressLvl = (_player call NWG_fnc_pGetPlayerProgress) param [_progressType,0];
    private _multiplier  = (NWG_PRG_Settings get "NOTIFY_MULTIPLIER") select _progressType;
    private _stringify   = (NWG_PRG_Settings get "STRINGIFY") select _progressType;
    //return
    format [_stringify,(_progressLvl * _multiplier)]
};

NWG_PRG_GetRemainingAsString = {
    params ["_player","_progressType"];
    private _progressLvl = (_player call NWG_fnc_pGetPlayerProgress) param [_progressType,0];
    private _multiplier  = (NWG_PRG_Settings get "NOTIFY_MULTIPLIER") select _progressType;
    private _limit       = (NWG_PRG_Settings get "LIMITS") select _progressType;
    private _stringify   = (NWG_PRG_Settings get "STRINGIFY") select _progressType;
    //return
    format [_stringify,((_limit - _progressLvl) * _multiplier)]
};

//================================================================================================================
//================================================================================================================
call _Init;