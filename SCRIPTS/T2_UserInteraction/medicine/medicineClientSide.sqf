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

    ["TIME_BLEEDING_TIME",900],//Start bleeding with this amount of 'time left'
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
NWG_MED_CLI_CalculateSubstate = {
    // private _unit = _this;

    /*Check cases that we can get from the engine*/
    if (isNull _this || {!alive _this})     exitWith {SUBSTATE_NONE};//Invalid unit
    if ((vehicle _this) isNotEqualTo _this) exitWith {SUBSTATE_INVH};//Inside vehicle
    if ((alive _this) != (isAwake _this))   exitWith {SUBSTATE_RAGD};//Ragdolling. See: https://community.bistudio.com/wiki/isAwake

    /*Check cases where we must rely on our state changing logic*/
    private _curSubstate = _this call NWG_MED_CLI_GetSubstate;
    if (!isNull (attachedTo _this)) exitWith {if (_curSubstate isEqualTo SUBSTATE_CARR) then {SUBSTATE_CARR} else {SUBSTATE_DRAG}};
    if (_curSubstate in [SUBSTATE_CRWL,SUBSTATE_HEAL]) exitWith {_curSubstate};//These rely solely on our state changing logic

    SUBSTATE_DOWN
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
            [_unit,SUBSTATE_RAGD] call NWG_MED_CLI_SetSubstate;
        };
        /*Unit in static weapon*/
        case (_veh isKindOf "StaticWeapon"): {
            moveOut _unit;
            [_unit,SUBSTATE_RAGD] call NWG_MED_CLI_SetSubstate;
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

    NWG_MED_CLI_isPatched = false;
    NWG_MED_CLI_lastDamager = _damager;
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
NWG_MED_CLI_isBleeding = false;
NWG_MED_CLI_isPatched = false;
NWG_MED_CLI_lastDamager = objNull;
NWG_MED_CLI_bleedingCycleHandle = scriptNull;

NWG_MED_CLI_StartBleeding = {
    if (NWG_MED_CLI_isBleeding) exitWith {};//Prevent double start
    NWG_MED_CLI_isPatched = false;
    NWG_MED_CLI_lastDamager = objNull;
    private _startTime = NWG_MED_CLI_Settings get "TIME_BLEEDING_TIME";
    [player,_startTime] call NWG_MED_CLI_SetTime;
    call NWG_MED_CLI_PostProcessEnable;
    NWG_MED_CLI_bleedingCycleHandle = [] spawn NWG_MED_CLI_BleedingCycle;
    NWG_MED_CLI_isBleeding = true;
};

NWG_MED_CLI_StopBleeding = {
    if (!NWG_MED_CLI_isBleeding) exitWith {};//Prevent double stop
    terminate NWG_MED_CLI_bleedingCycleHandle;
    call NWG_MED_CLI_PostProcessDisable;
    hintSilent "";//Clear hint
    NWG_MED_CLI_isPatched = false;
    NWG_MED_CLI_lastDamager = objNull;
    NWG_MED_CLI_isBleeding = false;
};

NWG_MED_CLI_BleedingCycle = {
    private _abortCondition = {isNull player || {!alive player}};

    waitUntil {
        if (call _abortCondition) exitWith {true};

        //Check and update substate
        private _substate = player call NWG_MED_CLI_CalculateSubstate;
        if (_substate isEqualTo SUBSTATE_INVH && {!alive (vehicle player)}) then {
            //Fix (im)possible stucking inside burning vehicle
            player moveOut (vehicle player);
            _substate = SUBSTATE_DOWN;
        };
        if ((player call NWG_MED_CLI_GetSubstate) isNotEqualTo _substate) then {
            [player,_substate] call NWG_MED_CLI_SetSubstate;
        };

        //Check time left
        private _timeLeft = player call NWG_MED_CLI_GetTime;
        if (_timeLeft <= 0) exitWith {
            /*Someone decreased our time while we were doing 'sleep'*/
            if (!isNull NWG_MED_CLI_lastDamager) then {[NWG_MED_CLI_lastDamager,player,BLAME_KILL] call NWG_fnc_medBlame};
            [] spawn NWG_MED_CLI_Respawn;//Fix wierdest error where unit appears naked after respawn (yes, by using 'spawn' inside another 'spawn')
            true;//Exit cycle
        };

        //Deplete time
        private _timeToDeplete = 1;
        if !(NWG_MED_CLI_isPatched) then {_timeToDeplete = 2};//Increase if unit not patched
        if !(_substate in [SUBSTATE_INVH,SUBSTATE_DOWN]) then {_timeToDeplete = _timeToDeplete * 2};//Increase if unit is not still
        _timeLeft = _timeLeft - _timeToDeplete;
        if (_timeLeft <= 0) exitWith {
            /*Our time ran out naturally*/
            [] spawn NWG_MED_CLI_Respawn;
            true;//Exit cycle
        };
        [player,_timeToDeplete] call NWG_MED_CLI_DecreaseTime;

        //Calculate closest player
        private _allValidPlayers = (call NWG_fnc_getPlayersAll) select {
            alive _x && {
            _x isNotEqualTo player && {
            !(_x call NWG_MED_CLI_IsWounded) && {
            (side (group _x)) isEqualTo (side (group player))}}}
        };
        private _closestPlayer = if ((count _allValidPlayers) > 0) then {
            _allValidPlayers = _allValidPlayers apply {[(_x distance player),_x]};
            _allValidPlayers sort true;
            (_allValidPlayers#0)#1
        } else {objNull};

        //Output info to the UI
        //TODO: Add actual formatting and localization
        hintSilent format ["DEBUG:\nt:%1 d:%2\np:%3 pDist:%4",_timeLeft,_timeToDeplete,(name _closestPlayer),(_closestPlayer distance player)];

        //Repeat
        sleep 1;
        false
    };
};

/*Post-process bleeding visuals*/
NWG_MED_CLI_postProcessHandles = [];
NWG_MED_CLI_PostProcessEnable = {
    private _ppHandles = [];
    private _create = {
        params ["_name","_priority"];
        private _handle = -1;
        while {_handle = ppEffectCreate [_name,_priority]; _handle < 0} do {_priority = _priority + 1};
        _handle
    };

    _ppHandles pushBack (["ColorCorrections",1500] call _create);
    _ppHandles pushBack (["ColorCorrections",1501] call _create);
    _ppHandles pushBack (["DynamicBlur",401] call _create);

    (_ppHandles#0) ppEffectAdjust [1,1,0.15,[0.3,0.3,0.3,0],[0.3,0.3,0.3,0.3],[1,1,1,1]];
	(_ppHandles#1) ppEffectAdjust [1,1,0,[0.15,0,0,1],[1.0,0.5,0.5,1],[0.587,0.199,0.114,0],[1,1,0,0,0,0.2,1]];
	(_ppHandles#2) ppEffectAdjust [0];
    _ppHandles ppEffectCommit 0;
    _ppHandles ppEffectEnable true;
	{_x ppEffectForceInNVG true} forEach _ppHandles;

    NWG_MED_CLI_postProcessHandles = _ppHandles;
};

NWG_MED_CLI_PostProcessDisable = {
    private _ppHandles = NWG_MED_CLI_postProcessHandles;
    NWG_MED_CLI_postProcessHandles = [];

    //Graceful disable. Step 1: Fade out
    (_ppHandles#0) ppEffectAdjust [1,1,0,[1,1,1,0],[0,0,0,1],[0,0,0,0]];
	(_ppHandles#1) ppEffectAdjust [1,1,0,[1,1,1,0],[0,0,0,1],[0,0,0,0]];
	(_ppHandles#2) ppEffectAdjust [0];
    _ppHandles ppEffectCommit 1;

    //Graceful disable. Step 2: Disable
    _ppHandles spawn {
        sleep 1.25;
        _this ppEffectEnable false;
        ppEffectDestroy _this;
    };
};

//================================================================================================================
//================================================================================================================
//Respawn
NWG_MED_CLI_Respawn = {
    //TODO: Implement respawn
    systemChat format ["%1 is dead",name player];
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