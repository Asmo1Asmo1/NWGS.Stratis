#include "..\..\globalDefines.h"
/*
    This module implements the following logic:
    - Airstrike
    - Artillery strike
    - Mortart strike
    - Veh building demolition
    - Inf building demolition
    - Inf building storm
    - Veh vehicle repair
*/
/*
    Breakdown of the module:
    - Find groups that can do Airstrike
    - Send group to do Airstrike

    - Find groups that can do Artillery strike
    - Find groups that can do Artillery strike on this position
    - Order to do Artillery strike onto position

    - Find groups that can do Mortar strike
    - Find groups that can do Mortar strike on this position
    - Order to do Mortar strike onto position

    - Find groups that can do Veh building demolition
    - Send group to do Veh building demolition

    - Find groups that can do Inf building demolition
    - Send group to do Inf building demolition

    - Find groups that can do Inf building storm
    - Send group to do Inf building storm

    - Find groups that can do Veh vehicle repair
    - Send group to do Veh vehicle repair
*/

//================================================================================================================
//Settings
NWG_ACA_Settings = createHashMapFromArray [
    ["AIRSTRIKE_PREPARE_RADIUS",2250],//Distance to fly away from the target in order to prepare for the airsrike
    ["AIRSTRIKE_PREPARE_HEIGHT",600],//Height at which airstrike will prepare
    ["AIRSTRIKE_YELLOW_RADIUS",1600],//Distance at which plane will start descending
    ["AIRSTRIKE_FIRE_RADIUS",1000],//Distance at which to start fireing
    ["AIRSTRIKE_STOP_RADIUS",500],//Distance at which to pull up

    ["",0]
];

//================================================================================================================
//Common
NWG_ACA_StartAdvancedLogic = {
    params ["_group","_logic",["_arg",[]]];
    //Stop any previous logic
    private _logicHandle = _group getVariable ["NWG_ACA_LogicHandle",scriptNull];
    if (!isNull _logicHandle && {!scriptDone _logicHandle}) then {terminate _logicHandle};
    private _logicHelper = _group getVariable ["NWG_ACA_LogicHelper",objNull];
    if (!isNull _logicHelper) then {deleteVehicle _logicHelper};
    //Start new logic
    _group setVariable ["NWG_ACA_LogicHandle",([_group,_arg] spawn _logic)];
};

NWG_ACA_GetDataForVehicleForceFire = {
    // private _vehicle = _this;

    //Get initial vehicle info like unit and its turret
    private _result = ((fullCrew [_this,"",false])
        select {(_x#2) == -1})/*Filter out cargo units*/
        apply {[_x#0,_x#3]};/*Repack into [unit,turret]*/

    //For each turret get its weapons and firemodes for each weapon
    private _falseWeapons = ["Horn","Laserdesignator","SmokeLauncher","CMFlareLauncher"];
    private ["_turret","_weapons","_cur","_fireModes"];
    {
        _turret = _x#1;
        if (_turret isEqualTo []) then {_turret = [-1]};
        _weapons = (_this weaponsTurret _turret) select {
            _cur = _x;
            ((_falseWeapons findIf {_x in _cur}) == -1)
        };
        if (_weapons isEqualTo []) then {
            _result deleteAt _forEachIndex;
            continue;
        };
        _weapons = _weapons apply {
            _cur = _x;
            _fireModes = (getArray (configFile >> "CfgWeapons" >> _cur >> "modes"));
            if (_fireModes isEqualTo ["this"]) then {_fireModes = [_cur]};
            [_cur,_fireModes]
        };
        _x set [1,_weapons];
    } forEachReversed _result;

    //return
    _result
};

NWG_ACA_VehicleForceFire = {
    params ["_vehicle","_data","_target"];
    //do
    {
        private _gunner = _x#0;
        (selectRandom (_x#1)) params ["_weapon","_fireModes"];
        _gunner reveal _target;
        _gunner doWatch _target;
        _gunner doTarget _target;
        _gunner forceWeaponFire [_weapon,(selectRandom _fireModes)];
    } forEach _data;
};

NWG_ACA_CreateHelper = {
    params ["_group","_target"];
    private _helper = createVehicle ["CBA_O_InvisibleTargetVehicle",_target,[],0,"CAN_COLLIDE"];
    createVehicleCrew _helper;
    private _laser = createVehicle ["LaserTargetW",_helper,[],0,"CAN_COLLIDE"];
    _laser attachTo [_helper,[0,0,0]];
    _helper setVariable ["NWG_ACA_laser",_laser];
    _group setVariable ["NWG_ACA_LogicHelper",_helper];
    //return
    _helper
};

NWG_ACA_DeleteHelper = {
    // private _group = _this;
    if (isNull _this) exitWith {};
    private _helper = _this getVariable ["NWG_ACA_LogicHelper",objNull];
    if (isNull _helper) exitWith {};
    private _helperGroup = group _helper;
    private _laser = _helper getVariable ["NWG_ACA_laser",objNull];
    if (!isNull _laser) then {deleteVehicle _laser};
    deleteVehicle _helper;
    deleteGroup _helperGroup;
};

//================================================================================================================
//Airstrike
NWG_ACA_CanDoAirstrike = {
    // private _group = _this;
    if (!alive (leader _this)) exitWith {false};
    private _veh = vehicle (leader _this);
    //return
    (alive _veh && {_veh isKindOf "Air" && {(count (_veh call NWG_fnc_spwnGetVehiclePylons)) > 0}})
};

NWG_ACA_FindGroupsForAirstrike = {
    // private _groups = _this;
    //return
    _this select {_x call NWG_ACA_CanDoAirstrike}
};

NWG_ACA_SendToAirstrike = {
    params ["_group","_target",["_checkGroupValid",true]];
    //Check if group can do airstrike
    if (_checkGroupValid && {!(_group call NWG_ACA_CanDoAirstrike)}) exitWith {
        "NWG_ACA_SendToAirstrike: tried to send group that can't do airstrike" call NWG_fnc_logError;
        false;
    };
    [_group,NWG_ACA_Airstrike,_target] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_Airstrike = {
    params ["_group","_target"];
    private _plane = vehicle (leader _group);
    private _pilot = currentPilot _plane;//Fix for some helicopters
    private _abortCondition = {!alive _plane || {!alive _pilot || {!alive _target}}};
    if (call _abortCondition) exitWith {};//Immediate check

    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";

    _plane setVehicleAmmo 1;//Lock'n'load
    private _strikeData = _plane call NWG_ACA_GetDataForVehicleForceFire;
    private _strikeTeam = _strikeData apply {_x#0};
    private _helper = [_group,_target] call NWG_ACA_CreateHelper;
    _group setVariable ["NWG_ACA_LogicHelper",_helper];
    private _originalAltitude = (getPosASL _plane)#2;
    private _prepareAltitude = (NWG_ACA_Settings get "AIRSTRIKE_PREPARE_HEIGHT");

    //Start Airstrike cycle
    waitUntil
    {
        if (call _abortCondition) exitWith {true};

        //0. Fix pilots stucking in one place
        private _crew = (crew _plane) select {alive _x};
        _group leaveVehicle _plane;
        {_x disableCollisionWith _plane; _x moveOut _plane} forEach _crew;
        _plane engineOn true;
        _group addVehicle _plane;
        {_x moveInAny _plane} forEach _crew;

        //1. Fly away from the target
        private _preparePos = _helper getPos [(NWG_ACA_Settings get "AIRSTRIKE_PREPARE_RADIUS"),(random 360)];
        _preparePos set [2,_prepareAltitude];
        _plane flyInHeight [_prepareAltitude,true];
        _plane flyInHeightASL [_prepareAltitude,_prepareAltitude,_prepareAltitude];
        _pilot doMove _preparePos;
        waitUntil {
            sleep 0.5;
            (call _abortCondition || {(_plane distance2D _preparePos) < 100})
        };
        if (call _abortCondition) exitWith {true};

        //2. Fly toward target
        _pilot doMove (position _helper);
        waitUntil {
            {_x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
            sleep 0.5;
            (call _abortCondition || {(_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_YELLOW_RADIUS")})
        };
        if (call _abortCondition) exitWith {true};

        //3. Descend and fire
        _plane flyInHeight [0,true];
        _plane flyInHeightASL [0,0,0];
        {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
        private _dirVectorNormalized = vectorNormalized ((getPosASL _helper) vectorDiff (getPosASL _plane));
        private _newVelocity = _dirVectorNormalized vectorMultiply (vectorMagnitude (velocity _plane));
        waitUntil {
            _plane setVectorDirAndUp [_dirVectorNormalized,[0,0,1]];
            _plane setVelocity _newVelocity;
            sleep 0.05;
            if (call _abortCondition || {(_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_STOP_RADIUS")}) exitWith {true};
            if ((_plane distance2D _helper) >= (NWG_ACA_Settings get "AIRSTRIKE_FIRE_RADIUS")) exitWith {false};//Continue
            if ((random 1) > 0.4) exitWith {false};//Continue
            //Fire
            [_plane,_strikeData,_helper] call NWG_ACA_VehicleForceFire;
            false
        };
        if (call _abortCondition) exitWith {true};

        //4. Release and reload
        _plane flyInHeight [_originalAltitude,true];
        _plane flyInHeightASL [_originalAltitude,_originalAltitude,_originalAltitude];
        {_x doWatch objNull; _x doTarget objNull} forEach _strikeTeam;
        _plane setVehicleAmmo 1;

        //always return
        false
    };

    //Cleanup
    if (!isNull _group) then {
        _group call NWG_ACA_DeleteHelper;
        _group setBehaviourStrong "AWARE";
        _group setCombatBehaviour "AWARE";
    };
    if (!isNull _plane) then {
        _plane setVehicleAmmo 1;
    };
};