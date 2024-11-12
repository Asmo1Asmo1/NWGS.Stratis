#include "..\..\globalDefines.h"
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
    _money = round (_money + _amount);

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