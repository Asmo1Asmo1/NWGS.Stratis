#include "medicineDefines.h"

// test1 call NWG_MED_DUMMY_SetupDummy
NWG_MED_DUMMY_SetupDummy = {
    // private _unit = _this;
    _this setDamage 0.7;
    _this addEventHandler ["HandleDamage",{_this call NWG_MED_DUMMY_OnDamage}];
};

/*Dummy unit to play with*/
NWG_MED_DUMMY_nextDamageAllowedAt = 0;
NWG_MED_DUMMY_OnDamage = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    private _dmg = _this#2;
    if (_dmg < 0.1) then {_dmg = 0};//Filter out small damage

    if (_dmg >= 0.9 && {(_this#1) isEqualTo ""}) then {
        private _unit = _this#0;
        switch (true) do {
            case (!alive _unit): {};
            case (time < NWG_MED_DUMMY_nextDamageAllowedAt): {};
            case (_unit call NWG_MED_COM_IsWounded): {};
            default {_this call NWG_MED_DUMMY_DamageWhileHealthy};
        };
    };

    (_dmg min 0.9)
};

NWG_MED_DUMMY_DamageWhileHealthy = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];
    NWG_MED_DUMMY_nextDamageAllowedAt = time + 3;

    _unit setUnconscious true;
    _unit setCaptive true;
    [_unit,true] call NWG_MED_COM_MarkWounded;

    private _veh = vehicle _unit;
    switch (true) do {
        case (isNull _veh || {_veh isEqualTo _unit}): {/*Do nothing*/};
        case (_veh isKindOf "StaticWeapon"): {moveOut _unit};//Fix stucking inside static weapon
        default {_unit playActionNow "Unconscious"};//Fix animation in vehicle
    };

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;//This DUMMY works client-side, so it's ok
    [_damager,_unit,BLAME_WOUND] call NWG_fnc_medBlame;

    [_unit,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;//Will be updated in bleeding cycle
    _unit spawn NWG_MED_DUMMY_Cycle;
};

NWG_MED_DUMMY_Cycle = {
    private _unit = _this;
    private _nextUpdateAt = 0;
    waitUntil {
        //Small cycle
        if (isNull _unit || {!alive _unit}) exitWith {true};//Deleted
        if !(_unit call NWG_MED_COM_IsWounded) exitWith {
            /*Healed*/
            _unit setUnconscious false;
            _unit setCaptive false;
            _unit playActionNow "MedicOther";
            true
        };

        //Big cycle time?
        if (time < _nextUpdateAt) exitWith {sleep 0.1; false};//Go to new small cycle
        _nextUpdateAt = time + 1;

        //Check and update substate
        private _substate = _unit call NWG_MED_COM_CalculateSubstate;
        if (_substate isEqualTo SUBSTATE_INVH && {!alive (vehicle _unit)}) then {
            //Fix (im)possible stucking inside burning vehicle
            _unit moveOut (vehicle _unit);
            _substate = SUBSTATE_NONE;
        };
        if ((_unit call NWG_MED_COM_GetSubstate) isNotEqualTo _substate) then {
            [_unit,_substate] call NWG_MED_COM_SetSubstate;
        };

        //Repeat
        sleep 0.1;//Big cycle will still run every second, but smaller cycle will fire every 0.1 seconds
        false
    };
};