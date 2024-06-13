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
    ["DSPAWN_SKILLSET_TIER_1",[["aimingAccuracy",0.3],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.3],["reloadSpeed",0.4],["spotDistance",0.5],["spotTime",0.5]]],
    ["DSPAWN_SKILLSET_TIER_2",[["aimingAccuracy",0.4],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.4],["reloadSpeed",0.6],["spotDistance",0.8],["spotTime",0.8]]],
    ["DSPAWN_SKILLSET_TIER_3",[["aimingAccuracy",0.5],["aimingShake",0.5],["aimingSpeed",0.5],["commanding",1.0],["courage",1.0],["general",0.6],["reloadSpeed",0.8],["spotDistance",1.0],["spotTime",1.0]]],
    ["DSPAWN_SKILLSET_TIER_4",[["aimingAccuracy",1.0],["aimingShake",1.0],["aimingSpeed",1.0],["commanding",1.0],["courage",1.0],["general",1.0],["reloadSpeed",1.0],["spotDistance",1.0],["spotTime",1.0]]],

    ["ON_DSPAWN_ALLOW_WOUNDED",true],//Enable wounded state for SOME of the group members when dspawn spawns the group
    ["DSPAWN_ALLOW_WOUNDED_CHANCE",0.5],//Chance for a group member to be allowed to be wounded
    ["DSPAWN_ALLOW_WOUNDED_TIME",[10,60]],//Time range for wounded state [min,max]

    ["ON_DSPAWN_ALLOW_STAY_IN_VEHICLE",true],//Enable stay in vehicle for SOME of the groups when dspawn spawns the group
    ["DSPAWN_ALLOW_STAY_IN_VEHICLE_CHANCE",0.5],//Chance for a group to be allowed to stay in the vehicle

    ["ON_DSPAWN_ALLOW_INFSTORM",true],//Enable autonomous INFSTORM for every INF group spawned by dspawn

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
    if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_INFSTORM") then {_group call NWG_ACP_SetupInfStorm};
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
    private _units = _units select {!unitIsUAV _x && {(random 1) <= _chance}};//Filter UAV and apply chance
    if ((count _units) == 0) exitWith {};//No units left
    private _id = -1;
    //forEach unit in the group
    {
        _id = _x addEventHandler ["HandleDamage",{_this call NWG_ACP_OnWounded}];
        _x setVariable ["NWG_ACP_OnWoundedHandle",_id];
    } forEach _units;
};

NWG_ACP_OnWounded = {
    // params ["_unit","_selection","_damage","_source","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","_sel","_dmg"];

    switch (true) do {
        case (!alive _unit): {};//Bypass for dead units
        case (_sel isNotEqualTo ""): {_dmg = (_dmg min 0.75)};//Clamp damage for hits other than body
        case ((vehicle _unit) isNotEqualTo _unit): {_unit removeEventHandler [_thisEvent,_thisEventHandler]};//Remove event handler for units in vehicles
        case (_unit in (flatten NWG_ACP_unwoundQueue)): {_dmg = (_dmg min 0.75)};//Clamp damage for wounded units (will be removed later)

        default {
            /*Wound the unit on foot*/
            _dmg = (_dmg min 0.75);//Clamp damage
            _unit setUnconscious true;

            NWG_ACP_unwoundQueue pushBack [
                _unit,
                (time + 2),/*_removeHandleAt*/
                (time + ((NWG_ACP_Settings get "DSPAWN_ALLOW_WOUNDED_TIME") call NWG_fnc_randomRangeInt))/*_wakeUpAt*/
            ];

            if (isNull NWG_ACP_unwoundHandle || {scriptDone NWG_ACP_unwoundHandle}) then {NWG_ACP_unwoundHandle = [] spawn NWG_ACP_Unwound};
        };
    };

    _dmg
};

NWG_ACP_unwoundQueue = [];
NWG_ACP_unwoundHandle = scriptNull;
NWG_ACP_Unwound = {
    waitUntil {
        sleep 1;

        //forEach wounded unit
        {
            _x params ["_unit","_removeHandleAt","_wakeUpAt"];
            switch (true) do {
                //Remove dead units from the queue
                case (!alive _unit): {
                    NWG_ACP_unwoundQueue deleteAt _forEachIndex
                };
                //Remove event handler if the time has come
                case (time >= _removeHandleAt && {!isNil {_unit getVariable "NWG_ACP_OnWoundedHandle"}}): {
                    _unit removeEventHandler ["HandleDamage",(_unit getVariable "NWG_ACP_OnWoundedHandle")];
                    _unit setVariable ["NWG_ACP_OnWoundedHandle",nil];
                };
                //Unwound the unit if the time has come
                case (time >= _wakeUpAt): {
                    _unit setUnconscious false;
                    NWG_ACP_unwoundQueue deleteAt _forEachIndex
                };
            };
        } forEachReversed NWG_ACP_unwoundQueue;

        ((count NWG_ACP_unwoundQueue) <= 0)
    };
};

NWG_ACP_AllowStayInVehicle = {
    // private _vehicle = _this;
    if ((_this isEqualTo false) || {isNull _this || {!alive _this}}) exitWith {};//No vehicle passed
    if ((random 1) > (NWG_ACP_Settings get "DSPAWN_ALLOW_STAY_IN_VEHICLE_CHANCE")) exitWith {};//Apply chance
    if !((_this isKindOf "Car") || {_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}}) exitWith {};//Check type
    if ((_this call NWG_ACA_GetDataForVehicleForceFire) isEqualTo []) exitWith {};//What's the point to stay in unarmed vehicle?
    //Checks passed
    _this allowCrewInImmobile [/*brokenWheels:*/true,/*upsideDown:*/false];
};

NWG_ACP_SetupInfStorm = {
    private _group = _this;
    if (isNull _group) exitWith {};//No group passed
    if ({alive _x && {!unitIsUAV _x}} count (units _group) <= 0) exitWith {};//No units that can be used for INFSTORM
    _group addEventHandler ["EnemyDetected",{_this call NWG_ACP_GoToInfStorm}];
};

NWG_ACP_GoToInfStorm = {
    params ["_group","_newTarget"];
    if (_group call NWG_fnc_acIsGroupBusy) exitWith {};//Check if the group is busy with something else
    if !(_group call NWG_fnc_acCanDoInfBuildingStorm) exitWith {};//Check if the group can storm the building
    if ((side _newTarget) isEqualTo (side _group)) exitWith {};//Only enemy targets

    _newTarget = vehicle _newTarget;
    if ((_newTarget call NWG_fnc_acGetTargetType) isNotEqualTo "INF") exitWith {};//Only INF targets

    private _building = _newTarget call NWG_fnc_acGetBuildingTargetIn;
    if (isNull _building) exitWith {};//No building to storm

    private _ok = [_group,_building] call NWG_fnc_acSendToInfBuildingStorm;
    _ok
};


//================================================================================================================
//================================================================================================================
call _Init;