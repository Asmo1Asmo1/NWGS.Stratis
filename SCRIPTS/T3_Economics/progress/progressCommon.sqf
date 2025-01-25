#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Progress logic (must work both on server and client)
NWG_PRG_GetPlayerProgress = {
    // private _player = _this;
    _this getVariable ["NWG_PRG_Progress",P_DEFAULT_CHART]
};

NWG_PRG_AddPlayerProgress = {
    params ["_player","_type","_amount"];
    if (_amount == 0) exitWith {};//Nothing to do

    //Calculate new progress amount
    private _progress = _player getVariable ["NWG_PRG_Progress",P_DEFAULT_CHART];
    private _total = ((_progress select _type) + _amount) max 0;
    _progress set [_type,_total];

    //Set new progress amount
    private _publicFlag = if (isServer) then {[(owner _player),2]} else {[clientOwner,2]};
    _player setVariable ["NWG_PRG_Progress",_progress,_publicFlag];

    //Notify about progress change
    [_player,_type,_amount,_total] call NWG_fnc_pNotifyProgressChange;

    //Raise event
    if (local _player && {_player isEqualTo player}) then {
        [EVENT_ON_PROGRESS_CHANGED,[_type,_amount,_total]] call NWG_fnc_raiseClientEvent;
    };
};

NWG_PRG_SetPlayerProgress = {
    params ["_player","_progress"];

    //Set new progress amount
    private _publicFlag = if (isServer) then {[(owner _player),2]} else {[clientOwner,2]};
    _player setVariable ["NWG_PRG_Progress",_progress,_publicFlag];
};