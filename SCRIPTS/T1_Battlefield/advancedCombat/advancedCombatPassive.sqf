#include "..\..\globalDefines.h"
#include "advancedCombatDefines.h"
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
    ["TIER_MIN",1],//Minimum tier to apply skills
    ["TIER_MAX",4],//Maximum tier to apply skills (leader of the group will be one tier higher, so keep it at -1 from skillset)
    ["TIER_TO_SKILLSET",[
        /*Tier 0*/[],//Just to skip the index
        /*Tier 1*/[["aimingAccuracy",0.3],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.3],["reloadSpeed",0.4],["spotDistance",0.4],["spotTime",0.4]],
        /*Tier 2*/[["aimingAccuracy",0.4],["aimingShake",0.4],["aimingSpeed",0.4],["commanding",1.0],["courage",1.0],["general",0.5],["reloadSpeed",0.6],["spotDistance",0.6],["spotTime",0.6]],
        /*Tier 3*/[["aimingAccuracy",0.6],["aimingShake",0.6],["aimingSpeed",0.6],["commanding",1.0],["courage",1.0],["general",0.7],["reloadSpeed",0.8],["spotDistance",0.8],["spotTime",0.8]],
        /*Tier 4*/[["aimingAccuracy",0.8],["aimingShake",0.8],["aimingSpeed",0.8],["commanding",1.0],["courage",1.0],["general",0.9],["reloadSpeed",1.0],["spotDistance",1.0],["spotTime",1.0]],
        /*Tier 5*/[["aimingAccuracy",0.9],["aimingShake",0.9],["aimingSpeed",0.9],["commanding",1.0],["courage",1.0],["general",1.0],["reloadSpeed",1.0],["spotDistance",1.0],["spotTime",1.0]]
    ]],

    ["ON_DSPAWN_ALLOW_WOUNDED",true],//Enable wounded state for SOME of the group members when dspawn spawns the group
    ["ALLOW_WOUNDED_CHANCE",0.6],//Chance for a group member to be allowed to be wounded
    ["ALLOW_WOUNDED_TIME",[10,60]],//Time range for wounded state [min,max]

    ["ON_DSPAWN_ALLOW_STAY_IN_VEHICLE",true],//Enable stay in vehicle for SOME of the groups when dspawn spawns the group
    ["ALLOW_STAY_IN_VEHICLE_CHANCE",0.5],//Chance for a group to be allowed to stay in the vehicle

    ["STATISTICS_ENABLED",true],//If true, the system will keep track of statistics and output them to the RPT log

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
    // params ["_group","_vehicle","_units","_tags","_tier","_faction"];
    params ["_group","_vehicle","_units","","_tier"];

    if (NWG_ACP_Settings get "ON_DSPAWN_SET_SKILL") then {[_group,_tier] call NWG_ACP_SetGroupSkills};
    if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_WOUNDED") then {_units call NWG_ACP_AllowWounded};
    if (NWG_ACP_Settings get "ON_DSPAWN_ALLOW_STAY_IN_VEHICLE") then {_vehicle call NWG_ACP_AllowStayInVehicle};
};

NWG_ACP_SetGroupSkills = {
    params ["_group","_tier"];
    private _skillSets = NWG_ACP_Settings get "TIER_TO_SKILLSET";
    private _memberTier = (_tier max (NWG_ACP_Settings get "TIER_MIN")) min (NWG_ACP_Settings get "TIER_MAX");//Clamp tier to min-max range
    private _leaderTier = _memberTier + 1;//Leader is always one tier higher than the rest of the group (so can be 4)
    private _leaderSkillSet = (_skillSets param [_leaderTier,[]]);
    private _memberSkillSet = (_skillSets param [_memberTier,[]]);
    private _setSkill = {
        params ["_unit","_skillSet"];
        {_unit setSkill _x} forEach _skillSet;
    };

    private _leader = leader _group;
    private _members = (units _group) - [_leader];

    [_leader,_leaderSkillSet] call _setSkill;
    {[_x,_memberSkillSet] call _setSkill} forEach _members;

    //Statistics
    private _totalCount = (count _members) + 1;//+1 for leader
    [STAT_ACP_SKILLSET,STAT_ACP_TOTAL,_totalCount] call NWG_ACP_AddStat;
    [STAT_ACP_SKILLSET,STAT_ACP_APPLIED,_totalCount] call NWG_ACP_AddStat;//There is no skip for skillset
};

NWG_ACP_AllowWounded = {
    private _allUnits = _this select {!unitIsUAV _x};
    if ((count _allUnits) == 0) exitWith {};//No units to process
    private _chance = NWG_ACP_Settings get "ALLOW_WOUNDED_CHANCE";
    private _units = _allUnits select {(random 1) <= _chance};//Apply chance
    if ((count _units) > 0) then {
        private _id = -1;
        //forEach unit in the group
        {
            _id = _x addEventHandler ["HandleDamage",{_this call NWG_ACP_OnWounded}];
            _x setVariable ["NWG_ACP_OnWoundedHandle",_id];
        } forEach _units;
    };

    //Statistics
    [STAT_ACP_WOUNDED,STAT_ACP_TOTAL,(count _allUnits)] call NWG_ACP_AddStat;
    [STAT_ACP_WOUNDED,STAT_ACP_SKIPPED,((count _allUnits) - (count _units))] call NWG_ACP_AddStat;
    [STAT_ACP_WOUNDED,STAT_ACP_APPLIED,(count _units)] call NWG_ACP_AddStat;
};

NWG_ACP_OnWounded = {
    // params ["_unit","_selection","_damage","_source","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","_sel","_dmg"];

    switch (true) do {
        case (!alive _unit): {};//Bypass for dead units
        case (_dmg < 0.1): {_dmg = 0};//Clamp minor damage
        case (_sel isNotEqualTo ""): {_dmg = (_dmg min 0.75)};//Clamp damage for hits other than body
        case ((vehicle _unit) isNotEqualTo _unit): {_unit removeEventHandler [_thisEvent,_thisEventHandler]};//Remove event handler for units in vehicles
        case (_unit in (flatten NWG_ACP_unwoundQueue)): {_dmg = (_dmg min 0.75)};//Clamp damage for wounded units (will be stopped by removing this handler, see below)

        default {
            /*Wound the unit*/
            _dmg = (_dmg min 0.75);//Clamp damage
            _unit setUnconscious true;

            NWG_ACP_unwoundQueue pushBack [
                _unit,
                (time + 2),/*_removeHandleAt*/
                (time + ((NWG_ACP_Settings get "ALLOW_WOUNDED_TIME") call NWG_fnc_randomRangeInt))/*_wakeUpAt*/
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
    //Checks
    if ((_this isEqualTo false) || {isNull _this || {!alive _this}}) exitWith {};//No vehicle passed
    if !((_this isKindOf "Car") || {_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}}) exitWith {};//Check type
    if !(_this call NWG_fnc_ocIsArmedVehicle) exitWith {};//What's the point to stay in unarmed vehicle?
    [STAT_ACP_STAY_IN_VEHICLE,STAT_ACP_TOTAL,1] call NWG_ACP_AddStat;//Statistics

    //Apply chance
    if ((random 1) > (NWG_ACP_Settings get "ALLOW_STAY_IN_VEHICLE_CHANCE")) exitWith {
        [STAT_ACP_STAY_IN_VEHICLE,STAT_ACP_SKIPPED,1] call NWG_ACP_AddStat;
    };

    //Apply allow
    _this allowCrewInImmobile [/*brokenWheels:*/true,/*upsideDown:*/false];
    [STAT_ACP_STAY_IN_VEHICLE,STAT_ACP_APPLIED,1] call NWG_ACP_AddStat;
};

//================================================================================================================
//Statistics
NWG_ACP_statistics = [
/*STAT_ACP_SKILLSET:*/       [0,0,0],
/*STAT_ACP_WOUNDED:*/        [0,0,0],
/*STAT_ACP_STAY_IN_VEHICLE:*/[0,0,0]
];

NWG_ACP_AddStat = {
    params ["_logicType","_statType","_value"];
    if !(NWG_ACP_Settings get "STATISTICS_ENABLED") exitWith {};

    private _stats = NWG_ACP_statistics param [_logicType,[]];
    private _stat = _stats param [_statType,0];
    _stats set [_statType,_stat + _value];
    NWG_ACP_statistics set [_logicType,_stats];
};

NWG_ACP_PrintStatistics = {
    //Check if statistics are enabled
    if !(NWG_ACP_Settings get "STATISTICS_ENABLED") exitWith {
        "NWG_ACP_PrintStatistics: statistics are disabled" call NWG_fnc_logInfo;
    };

    //Print statistics
    private _stats = NWG_ACP_statistics;
    private _format = {
        params ["_total","_skipped","_applied"];
        (format ["Total:%1 (Skp:%2, App:%3)",_total,_skipped,_applied])
    };
    private _lines = [
        (format ["SKILLSET:    %1",((_stats#STAT_ACP_SKILLSET) call _format)]),
        (format ["WOUNDED:     %1",((_stats#STAT_ACP_WOUNDED) call _format)]),
        (format ["STAY IN VEH: %1",((_stats#STAT_ACP_STAY_IN_VEHICLE) call _format)])
    ];
    diag_log text "==========[  AC PASSIVE STATS ]===========";
    {diag_log (text _x)} forEach _lines;

    //Drop statistics
    {NWG_ACP_statistics set [_forEachIndex,(_x apply {0})]} forEach NWG_ACP_statistics;
};

//================================================================================================================
//================================================================================================================
call _Init;