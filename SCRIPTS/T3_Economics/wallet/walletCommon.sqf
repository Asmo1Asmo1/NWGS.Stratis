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

    private _money = _player getVariable ["NWG_WLT_Money",0];
    _money = round (_money + _amount);
    _player setVariable ["NWG_WLT_Money",_money,true];

    [_player,_amount] call NWG_fnc_wltNotifyMoneyChange;
};

NWG_WLT_SetPlayerMoney = {
    params ["_player","_amount"];
    _player setVariable ["NWG_WLT_Money",(round _amount),true];
};