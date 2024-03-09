#include "..\..\globalDefines.h"
#include "medicineDefines.h"
//================================================================================================================
//================================================================================================================
//Settings
NWG_MED_CLI_Settings = createHashMapFromArray [
    ["ALLOWDAMAGE_ON_INIT",true],//Set this to true if you added 'player allowDamage false' in 'initPlayerLocal'

    ["INVULNERABILITY_ON_START",5],//Seconds to ignore damage after mission start
    ["INVULNERABILITY_ON_EJECTION",3],//Seconds to ignore damage while ejecting burning vehicle
    ["INVULNERABILITY_ON_WOUNDED",3],//Seconds to ignore damage when getting wounded

    ["TIME_DAMAGE_DEPLETES",10],//How much time is subtracted when damage received in wounded state

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_START");
    player addEventHandler ["HandleDamage",{_this call NWG_MED_CLI_OnDamage}];
    if (NWG_MED_CLI_Settings get "ALLOWDAMAGE_ON_INIT") then {player allowDamage true};
};

//================================================================================================================
//================================================================================================================
//State management
NWG_MED_CLI_IsWounded = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_wounded",false]
};
NWG_MED_CLI_MarkWounded = {
    params ["_unit","_wounded"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_wounded",_wounded,true];
};

NWG_MED_CLI_GetSubstate = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {SUBSTATE_NONE};
    _this getVariable ["NWG_MED_CLI_substate",SUBSTATE_NONE]
};
NWG_MED_CLI_SetSubstate = {
    params ["_unit","_substate"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_substate",_substate,true];
};

NWG_MED_CLI_GetTime = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {0};
    _this getVariable ["NWG_MED_CLI_time",0]
};
NWG_MED_CLI_SetTime = {
    params ["_unit","_time"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_time",_time,true];
};
NWG_MED_CLI_DecreaseTime = {
    params ["_unit","_timeSubtraction"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    private _time = _unit getVariable ["NWG_MED_CLI_time",0];
    _time = _time - _timeSubtraction;
    private _publicFlag = (_time % 10) == 0;//Don't spam the network with updates
    _unit setVariable ["NWG_MED_CLI_time",_time,_publicFlag];
};

//================================================================================================================
//================================================================================================================
//Damage handling
NWG_MED_CLI_nextDamageAllowedAt = 0;
NWG_MED_CLI_OnDamage = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    private _dmg = _this#2;
    if (_dmg < 0.1) then {_dmg = 0};//Filter out small damage

    if (_dmg >= 0.9 && {(_this#1) isEqualTo ""}) then {
        private _unit = _this#0;
        switch (true) do {
            case (!alive _unit): {};
            case (!alive (vehicle _unit)): {_this call NWG_MED_CLI_OnVehicleDestroy};
            case (time < NWG_MED_CLI_nextDamageAllowedAt): {};
            case (_unit call NWG_MED_CLI_IsWounded): {_this call NWG_MED_CLI_OnDamageWhileWounded};
            default {_this call NWG_MED_CLI_OnDamageWhileHealthy};
        };
    };

    (_dmg min 0.9)
};

NWG_MED_CLI_OnVehicleDestroy = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];

    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_EJECTION");
    moveOut _unit;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    [_damager,_unit,BLAME_VEH_KO] call NWG_fnc_medBlame;
};

NWG_MED_CLI_OnDamageWhileHealthy = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];
    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_WOUNDED");

    _unit setUnconscious true;
    _unit setCaptive true;
    [_unit,true] call NWG_MED_CLI_MarkWounded;

    private _veh = vehicle _unit;
    switch (true) do {
        /*Invalid vehicle*/
        case (isNull _veh): {[_unit,SUBSTATE_DOWN] call NWG_MED_CLI_SetSubstate};//Shouldn't happen
        /*Unit in ragdoll falling to the ground*/
        case (_veh isEqualTo _unit): {
            [_unit,SUBSTATE_FALL] call NWG_MED_CLI_SetSubstate;
        };
        /*Unit in static weapon*/
        case (_veh isKindOf "StaticWeapon"): {
            moveOut _unit;
            [_unit,SUBSTATE_DOWN] call NWG_MED_CLI_SetSubstate;
        };
        /*Unit in vehicle*/
        default {
            _unit playActionNow "Unconscious";
            [_unit,SUBSTATE_INVH] call NWG_MED_CLI_SetSubstate;
        };
    };

    call NWG_MED_CLI_StartBleeding;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    [_damager,_unit,BLAME_WOUND] call NWG_fnc_medBlame;
};

NWG_MED_CLI_OnDamageWhileWounded = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];
    NWG_MED_CLI_nextDamageAllowedAt = time + 1;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    if (isNull _damager) exitWith {};

    private _timeToDeplete = NWG_MED_CLI_Settings get "TIME_DAMAGE_DEPLETES";
    if (_timeToDeplete <= 0) exitWith {};

    private _timeLeft = _unit call NWG_MED_CLI_GetTime;
    if ((_timeLeft - _timeToDeplete) <= 0) then {
        [_damager,_unit,BLAME_KILL] call NWG_fnc_medBlame;
    };

    [_unit,_timeToDeplete] call NWG_MED_CLI_DecreaseTime;
};

NWG_MED_CLI_DefineDamager = {
    params [["_damager",objNull],["_instigator",objNull]];
    private _suspect = if (!isNull _instigator) then {_instigator} else {_damager};

    switch (true) do {
        case (isNull _suspect):                   {objNull};
        case (_suspect isKindOf "Man"):           {_suspect};
        case (unitIsUAV _suspect):                {((UAVControl _suspect) param [0,objNull])};
        case (_suspect isKindOf "StaticWeapon"):  {(gunner _suspect)};
        case (_suspect call NWG_fnc_ocIsVehicle): {(driver _suspect)};
        default                                   {objNull};
    }
};

//================================================================================================================
//================================================================================================================
//Bleeding cycle
NWG_MED_CLI_StartBleeding = {
    //TODO: Implement
    systemChat format ["[%1] NWG_MED_CLI_StartBleeding",time];
};

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