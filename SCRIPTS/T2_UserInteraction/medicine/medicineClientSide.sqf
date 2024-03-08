#include "..\..\globalDefines.h"
#include "medicineDefines.h"
//================================================================================================================
//================================================================================================================
//Settings

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["HandleDamage",{_this call NWG_MED_CLI_OnDamage}];
};

//================================================================================================================
//================================================================================================================
//State management
NWG_MED_CLI_SetState = {
    params ["_wounded","_substate","_time"];
    if (isNull player || {!alive player}) exitWith {};
    player setVariable ["NWG_MED_CLI_wounded",_wounded,true];
    player setVariable ["NWG_MED_CLI_substate",_substate,true];
    player setVariable ["NWG_MED_CLI_time",_time,true];
};

NWG_MED_CLI_AddTime = {
    // private _timeAddition = _this;
    if (isNull player || {!alive player}) exitWith {};
    private _time = player getVariable ["NWG_MED_CLI_time",0];
    _time = _time + _this;
    private _publicFlag = (_time % 10) == 0;//Don't spam the network with updates
    player setVariable ["NWG_MED_CLI_time",_time,_publicFlag];
};

NWG_MED_CLI_IsWounded = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_wounded",false]
};

NWG_MED_CLI_GetSubstate = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {SUBSTATE_NONE};
    _this getVariable ["NWG_MED_CLI_substate",SUBSTATE_NONE]
};

//================================================================================================================
//================================================================================================================
//Damage handling
NWG_MED_CLI_OnDamage = {
    // params ["_unit","_selection","_dmg","_killer","_projectile","_hitIndex","_instigator","_hitPoint"];
    private _dmg = _this#2;
    if (_dmg < 0.1) then {_dmg = 0};//Filter out small damage

    if (_dmg >= 0.9 && {(_this#1) isEqualTo ""}) then {
        if ((_this#0) call NWG_MED_CLI_IsWounded)
            then {_this call NWG_MED_CLI_OnDamageWhileWounded}
            else {_this call NWG_MED_CLI_OnDamageWhileHealthy};
    };

    (_dmg min 0.9)
};

NWG_MED_CLI_OnDamageWhileHealthy = {
    //TODO: Implement
    systemChat format ["%1 damage while healthy",time];
};

NWG_MED_CLI_OnDamageWhileWounded = {
    //TODO: Implement
    systemChat format ["%1 damage while wounded",time];
};

//================================================================================================================
//================================================================================================================
//Bleeding cycle

//================================================================================================================
//================================================================================================================
//Self actions

//================================================================================================================
//================================================================================================================
//Units actions

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;