#include "..\..\globalDefines.h"
/*
    This module implements the following logic:
    - Set group skill based on TIER
    - Allow wounded state
    - Allow stay in the vehicle
    It does this by subscribing to dspawn 'group spawned' event and modifying the group accordingly.
*/

//================================================================================================================
//Settings
NWG_ACP_Settings = createHashMapFromArray [
    ["ON_DSPAWN_SET_SKILL",true],//Enable group skill change based on TIER when dspawn spawns the group
    ["DSPAWN_SKILLSET_TIER_1",[["aimingAccuracy",0.2],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.25],["reloadSpeed",0.4],["spotDistance",0.5],["spotTime",0.5]]],
    ["DSPAWN_SKILLSET_TIER_2",[["aimingAccuracy",0.3],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.4],["reloadSpeed", 0.6],["spotDistance",0.8],["spotTime",0.8]]],
    ["DSPAWN_SKILLSET_TIER_3",[["aimingAccuracy",0.4],["aimingShake",0.5],["aimingSpeed",0.5],["commanding",1.0],["courage",1.0],["general",0.6],["reloadSpeed", 0.8],["spotDistance",1.0],["spotTime",1.0]]],
    ["DSPAWN_SKILLSET_TIER_4",[["aimingAccuracy",1.0],["aimingShake",1.0],["aimingSpeed",1.0],["commanding",1.0],["courage",1.0],["general",1.0],["reloadSpeed", 1.0],["spotDistance",1.0],["spotTime",1.0]]],

    ["ON_DSPAWN_ALLOW_WOUNDED",true],//Enable wounded state for SOME of the group members when dspawn spawns the group
    ["DSPAWN_ALLOW_WOUNDED_CHANCE",0.5],//Chance for a group member to be allowed to be wounded
    ["DSPAWN_ALLOW_WOUNDED_TIME",[10,60]],//Time range for wounded state [min,max]

    ["ON_DSPAWN_ALLOW_STAY_IN_VEHICLE",true],//Enable stay in vehicle for SOME of the groups when dspawn spawns the group
    ["DSPAWN_ALLOW_STAY_IN_VEHICLE_CHANCE",0.5],//Chance for a group to be allowed to stay in the vehicle

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    //Subscribe to dspawn 'group spawned' event
    [EVENT_ON_DSPAWN_GROUP_SPAWNED,{_this call NWG_ACP_OnDspawnGroupSpawned}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//Handlers
NWG_ACP_OnDspawnGroupSpawned = {
    params ["_group","_vehicle","_units","_tags","_tier"];

    if (NWG_ACP_Settings get "ON_DSPAWN_SET_SKILL") then {[_group,_tier] call NWG_ACP_SetGroupSkills};
    if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_WOUNDED") then {_units call NWG_ACP_AllowWounded};
    if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_STAY_IN_VEHICLE") then {_vehicle call NWG_ACP_AllowStayInVehicle};
};

NWG_ACP_SetGroupSkills = {
    params ["_group","_tier"];
    private _memberTier = (_tier max 1) min 3;//Clamp tier to 1-3
    private _leaderTier = _memberTier + 1;//Leader is always one tier higher than the rest of the group (so can be 4)
    private _leaderSkillSet = NWG_ACP_Settings get (format ["DSPAWN_SKILLSET_TIER_%1",_leaderTier]);
    private _memberSkillSet = NWG_ACP_Settings get (format ["DSPAWN_SKILLSET_TIER_%1",_memberTier]);
    private _setSkill = {
        params ["_unit","_skillSet"];
        {_unit setSkill _x} forEach _skillSet;
    };

    private _leader = leader _group;
    private _members = (units _group) - [_leader];

    [_leader,_leaderSkillSet] call _setSkill;
    {[_x,_memberSkillSet] call _setSkill} forEach _members;
};

NWG_ACP_AllowWounded = {
    private _units = _this;
    private _chance = NWG_ACP_Settings get "DSPAWN_ALLOW_WOUNDED_CHANCE";
    private _units = _units select {(random 1) <= _chance};//Apply chance
    if ((count _units) == 0) exitWith {};//No units passed the chance
    { _x addEventHandler ["HandleDamage",{_this call NWG_ACP_OnWounded}] } forEach _units;
};

NWG_ACP_OnWounded = {
    params ["_unit","_selection","_damage"/*,"_source","_projectile","_hitIndex","_instigator","_hitPoint"*/];

    switch (true) do {
        case (!alive _unit): {/*Do nothing*/};//Do nothing for dead units
        case ((vehicle _unit) isNotEqualTo _unit): {/*Do nothing*/};//Do nothing for units in vehicles
        case (_selection in ["legs","arms","hands"]): {
            /*Try playing 'falling' animation for hit in legs, arms or hands*/
            if !((toUpper (stance _unit)) in ["CROUCH","STAND"]) exitWith {};//Only play animation when standing due to lack of animations, sry
            private _anim = switch (currentWeapon _unit) do {
                case (""): {"AmovPercMstpSnonWnonDnon"};
                case (primaryWeapon _unit): {selectRandom [
                        "AmovPercMstpSrasWrflDnon_AadjPpneMstpSrasWrflDleft",
                        "AmovPercMstpSrasWrflDnon_AadjPpneMstpSrasWrflDright",
                        "AmovPercMsprSlowWrfldf_AmovPpneMstpSrasWrflDnon",
                        "AmovPercMsprSlowWrfldf_AmovPpneMstpSrasWrflDnon_2"]
                };
                case (handgunWeapon _unit): {selectRandom [
                        "AmovPercMstpSrasWpstDnon_AadjPpneMstpSrasWpstDleft",
                        "AmovPercMstpSrasWpstDnon_AadjPpneMstpSrasWpstDright",
                        "AmovPercMsprSlowWpstDf_AmovPpneMstpSrasWpstDnon"]
                };
                default {""};
            };
            if (_anim isEqualTo "") exitWith {};//Exit if no animation for this weapon exists, i.e. binocular or rocket launcher
            [_unit, _anim] call NWG_fnc_playAnim;
        };
        default {
            /*Wound the unit*/
            _unit setUnconscious true;
            (NWG_ACP_Settings get "DSPAWN_ALLOW_WOUNDED_TIME") params ["_min","_max"];
            private _wakeUpAt = time + ((random (_max - _min)) + _min);
            NWG_ACP_unwoundQueue pushBack [_unit,_wakeUpAt];
            if (isNull NWG_ACP_unwoundHandle || {scriptDone NWG_ACP_unwoundHandle}) then {NWG_ACP_unwoundHandle = [] spawn NWG_ACP_Unwound};
        };
    };

    _unit removeEventHandler [_thisEvent,_thisEventHandler];//Make it one-time event
    _damage
};

NWG_ACP_unwoundQueue = [];
NWG_ACP_unwoundHandle = scriptNull;
NWG_ACP_Unwound = {
    waitUntil {
        sleep 1;

        //forEach wounded unit
        {
            if (!alive (_x#0)) then {NWG_ACP_unwoundQueue deleteAt _forEachIndex; continue};//Remove dead units from the queue
            if (time > (_x#1)) then {(_x#0) setUnconscious false; NWG_ACP_unwoundQueue deleteAt _forEachIndex};//Unwound the unit if the time has come
        } forEachReversed NWG_ACP_unwoundQueue;

        ((count NWG_ACP_unwoundQueue) <= 0)
    };
};

NWG_ACP_AllowStayInVehicle = {
    // private _vehicle = _this;
    //TODO
};

//================================================================================================================
//Post-compilation init
call _Init;