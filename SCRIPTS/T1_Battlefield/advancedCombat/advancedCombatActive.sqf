#include "..\..\globalDefines.h"
/*
    This module implements the following logic:
    - Airstrike
    - Artillery/Mortar strike
    - Veh building demolition
    - Inf building storm
    - Veh vehicle repair
*/
/*
    Breakdown of the module:
    - Find groups that can do Airstrike
    - Send group to do Airstrike on target

    - Find groups that can do Artillery strike (includes Mortar)
    - Find groups that can do Artillery strike on this position
    - Order to do Artillery strike onto position

    - Find groups that can do Veh building demolition
    - Send group to do Veh building demolition

    - Find groups that can do Inf building storm
    - Send group to do Inf building storm

    - Find groups that can do Veh vehicle repair
    - Check that this group vehicle needs repair
    - Send group to do their Veh vehicle repair
*/

//================================================================================================================
//Settings
NWG_ACA_Settings = createHashMapFromArray [
    ["AIRSTRIKE_PREPARE_RADIUS",2000],//Distance to fly away from the target in order to prepare for the airsrike
    ["AIRSTRIKE_PREPARE_HEIGHT",650],//Height at which airstrike will prepare
    ["AIRSTRIKE_DESCEND_RADIUS",1450],//Distance at which plane will start descending
    ["AIRSTRIKE_FIRE_RADIUS",850],//Distance at which to start fireing
    ["AIRSTRIKE_STOP_RADIUS",450],//Distance at which to pull up
    ["AIRSTRIKE_LASER_CLASSNAME","LaserTargetW"],//Classname for laser target (faction matters!)
    ["AIRSTRIKE_TIMEOUT",120],//Timeout for EACH STEP of airstrike (in case of any errors) (there are 6 steps)

    ["ARTILLERY_STRIKE_COUNTS",[2,3,4,5,6]],//Number of artillery strikes to do (randomly selected from this array)
    ["ARTILLERY_STRIKE_TIMEOUT",300],//Timeout for artillery strike (in case of any errors)

    ["VEH_DEMOLITION_FIRE_RADIUS",150],//Radius for fireing
    ["VEH_DEMOLITION_TIMEOUT",300],//Timeout for veh demolition

    ["INF_STORM_FIRE_RADIUS",50],//Radius for fireing
    ["INF_STORM_FIRE_TIME",10],//Time for fireing
    ["INF_STORM_STORM_TIME",20],//Time for storming the building
    ["INF_STORM_TIMEOUT",300],//Timeout for inf building storm

    ["VEH_REPAIR_RADIUS",250],//Radius for vehicle to move to repair
    ["VEH_REPAIR_TIMEOUT",300],//Timeout for veh repair

    ["HELPER_CLASSNAMES",["O_Quadbike_01_F","O_Soldier_AT_F"]],//params ["_invisibleVehicle","_agentToPutIntoVehicle"] (faction matters!)

    ["",0]
];

//================================================================================================================
//General logic assignment
NWG_ACA_StartAdvancedLogic = {
    params ["_group","_logic",["_arg1",[]],["_arg2",[]]];
    //Stop any previous logic
    private _logicHandle = _group getVariable ["NWG_ACA_LogicHandle",scriptNull];
    if (!isNull _logicHandle && {!scriptDone _logicHandle}) then {terminate _logicHandle};
    private _logicHelper = _group getVariable ["NWG_ACA_LogicHelper",objNull];
    if (!isNull _logicHelper) then {_logicHelper call NWG_ACA_DeleteHelper};
    //Start new logic
    _group setVariable ["NWG_ACA_LogicHandle",([_group,_arg1,_arg2] spawn _logic)];
};

NWG_ACA_IsDoingAdvancedLogic = {
    // private _group = _this;
    private _logicHandle = _this getVariable ["NWG_ACA_LogicHandle",scriptNull];
    //return
    (!isNull _logicHandle && {!scriptDone _logicHandle})
};

//================================================================================================================
//Logic helper (target for strikes)
NWG_ACA_CreateHelper = {
    params ["_group","_target"];
    (NWG_ACA_Settings get "HELPER_CLASSNAMES") params ["_invisibleVehicle","_agentToPutIntoVehicle"];
    private _helperVeh = createVehicle [_invisibleVehicle,(call NWG_fnc_spwnGetSafePrespawnPos),[],0,"CAN_COLLIDE"];
    _helperVeh hideObjectGlobal true;
    _helperVeh allowDamage false;
    private _helperUnit = createAgent [_agentToPutIntoVehicle,_helperVeh,[],0,"CAN_COLLIDE"];
    _helperUnit hideObjectGlobal true;
    _helperUnit allowDamage false;
    _helperUnit moveInAny _helperVeh;
    _helperVeh setPosATL (getPosATL _target);
    _group setVariable ["NWG_ACA_LogicHelper",_helperVeh];
    //return
    _helperVeh
};

NWG_ACA_DeleteHelper = {
    private _helper = _this;
    if (isNull _helper) exitWith {"NWG_ACA_DeleteHelper: helper is null" call NWG_fnc_logError};
    {_helper deleteVehicleCrew _x } forEach (crew _helper);
    deleteVehicle _helper;
};

//================================================================================================================
//Waypoints logic
NWG_ACA_CreateWaypointAround = {
    params ["_group","_target",["_radius",0],["_posType","ground"],["_posHeight",0],["_wpType","MOVE"]];

    _group call NWG_fnc_dsClearWaypoints;//Clear existing waypoints
    private _targetPos = getPosASL _target;
    _targetPos set [2,0];
    private _wpPos = [_targetPos,(_radius max 1),_posType] call NWG_fnc_dtsFindDotForWaypoint;//Get position for new waypoint
    _wpPos set [2,_posHeight];
    if (_posHeight > 0) then {_wpPos = ASLToAGL _wpPos};

    private _wp = [_group,_wpPos,_wpType] call NWG_fnc_dsAddWaypoint;//Create new waypoint
    _group setVariable ["NWG_ACA_IsWaypointCompleted",false];//Track waypoint completion (part 1)
    _wp setWaypointStatements ["true", "if (local this) then {this call NWG_ACA_OnWaypointCompleted}"];//Track waypoint completion (part 2)

    //return
    _wp
};

NWG_ACA_CreateWaypointAt = {
    params ["_group","_target",["_wpType","MOVE"]];

    _group call NWG_fnc_dsClearWaypoints;//Clear existing waypoints
    private _wp = _group addWaypoint [_target,0];//Create new waypoint exactly at the target
    _wp setWaypointType _wpType;//Specify waypoint type
    _group setVariable ["NWG_ACA_IsWaypointCompleted",false];//Track waypoint completion (part 1)
    _wp setWaypointStatements ["true", "if (local this) then {this call NWG_ACA_OnWaypointCompleted}"];//Track waypoint completion (part 2)

    //return
    _wp
};

NWG_ACA_OnWaypointCompleted = {
    // private _groupLeader = _this;
    private _group = group _this;
    _group setVariable ["NWG_ACA_IsWaypointCompleted",true];
};

NWG_ACA_IsWaypointCompleted = {
    // private _group = _this;
    _this getVariable ["NWG_ACA_IsWaypointCompleted",false]
};

//================================================================================================================
//Airstrike
NWG_ACA_CanDoAirstrike = {
    // private _group = _this;
    if (!alive (leader _this)) exitWith {false};

    //Get leader's vehicle
    private _veh = vehicle (leader _this);
    if (!alive _veh) exitWith {false};
    if (_veh isEqualTo (leader _this)) exitWith {false};//Leader on-foot

    //Check cache
    private _flag = _veh getVariable "NWG_ACA_vehCanAirstrike";//Check cached result
    if (!isNil "_flag") exitWith {_flag};

    //Check if vehicle can do airstrike
    _flag = (_veh isKindOf "Air" && {(count (_veh call NWG_fnc_spwnGetVehiclePylons)) > 0});

    //Cache and return
    _veh setVariable ["NWG_ACA_vehCanAirstrike",_flag];
    _flag
};

NWG_ACA_SendToAirstrike = {
    params ["_group","_target",["_numberOfStrikes",1]];
    if !(_group call NWG_ACA_CanDoAirstrike) exitWith {
        "NWG_ACA_SendToAirstrike: tried to send group that can't do airstrike" call NWG_fnc_logError;
        false;
    };

    [_group,NWG_ACA_Airstrike,_target,_numberOfStrikes] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_Airstrike = {
    params ["_group","_target",["_numberOfStrikes",1]];
    private _plane = vehicle (leader _group);
    private _pilot = currentPilot _plane;//Fix for some helicopters
    private _abortCondition = {!alive _plane || {!alive _pilot || {!alive _target}}};
    if (call _abortCondition) exitWith {};//Immediate check

    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";

    _plane setVehicleAmmo 1;//Lock'n'load
    private _strikeData = _plane call NWG_ACA_GetDataForVehicleForceFire;
    private _strikeTeam = crew _plane;
    private _prepareAltitude = (NWG_ACA_Settings get "AIRSTRIKE_PREPARE_HEIGHT");
    private _helper = objNull;
    private _laser = objNull;

    //Start Airstrike cycle
    private _counter = 0;
    waitUntil
    {
        if (call _abortCondition) exitWith {true};

        //0. Fix pilots stucking in one place
        if !(unitIsUAV _plane) then {
            private _crew = (crew _plane) select {alive _x};
            _group leaveVehicle _plane;
            {_x disableCollisionWith _plane; _x moveOut _plane} forEach _crew;
            _plane engineOn true;
            _group addVehicle _plane;
            {_x moveInAny _plane} forEach _crew;
        };

        //1. Fly away from the target
        private _timeoutAt = time + (NWG_ACA_Settings get "AIRSTRIKE_TIMEOUT");
        [_group,_target,(NWG_ACA_Settings get "AIRSTRIKE_PREPARE_RADIUS"),"air",_prepareAltitude,"MOVE"] call NWG_ACA_CreateWaypointAround;
        _plane flyInHeight [_prepareAltitude,true];
        _plane flyInHeightASL [_prepareAltitude,_prepareAltitude,_prepareAltitude];
        waitUntil {
            sleep 1;
            if (call _abortCondition) exitWith {true};
            if (time > _timeoutAt) exitWith {true};//Timeout
            if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint reached
            false/*go to next iteration*/
        };
        if (call _abortCondition) exitWith {true};
        if (time > _timeoutAt && {(_plane distance2D _target) < (NWG_ACA_Settings get "AIRSTRIKE_DESCEND_RADIUS")}) exitWith {
            "NWG_ACA_Airstrike: timeout reached at 'Fly away' stage and plane is not far enough - exiting cycle" call NWG_fnc_logError;
            true
        };

        //2. Create airstrike helper at current target position
        _helper = [_group,_target] call NWG_ACA_CreateHelper;
        _laser = createVehicle [(NWG_ACA_Settings get "AIRSTRIKE_LASER_CLASSNAME"),_helper,[],0,"CAN_COLLIDE"];
        _laser attachTo [_helper,[0,0,0]];

        //3. Fly toward target
        _timeoutAt = time + (NWG_ACA_Settings get "AIRSTRIKE_TIMEOUT");
        [_group,_target,5,"air",_prepareAltitude,"MOVE"] call NWG_ACA_CreateWaypointAround;
        waitUntil {
            sleep 1;
            if (call _abortCondition) exitWith {true};
            {_x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;//Watch at helper
            if (time > _timeoutAt) exitWith {true};//Timeout
            if ((_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_DESCEND_RADIUS")) exitWith {true};//Enough, descend
            if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint reached (shouldn't happen actually)
            false
        };
        if (call _abortCondition) exitWith {true};
        if (time > _timeoutAt && {(_plane distance2D _target) < (NWG_ACA_Settings get "AIRSTRIKE_STOP_RADIUS")}) exitWith {
            "NWG_ACA_Airstrike: timeout reached at 'Fly toward target' stage and plane is not far enough - exiting cycle" call NWG_fnc_logError;
            true
        };

        //4. Descend and fire (we take manual control over Arma physics and AI behavior for this part, so no need to check for waypoint completion or timeout)
        _plane flyInHeight [0,true];
        _plane flyInHeightASL [0,0,0];
        {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
        private ["_dirVectorNormalized","_currentSpeed","_newVelocity"];
        waitUntil {
            sleep 0.05;//Smallest value required for plane not to jiggle
            if (call _abortCondition) exitWith {true};
            if ((_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_STOP_RADIUS")) exitWith {true};//Enough, stop
            if ((_plane distance2D _helper) >= (NWG_ACA_Settings get "AIRSTRIKE_FIRE_RADIUS")) exitWith {false};//Continue getting closer

            //Continuously recalculate direction to target
            _dirVectorNormalized = vectorNormalized ((getPosASL _helper) vectorDiff (getPosASL _plane));
            _currentSpeed = vectorMagnitude (velocity _plane);
            if (_currentSpeed < 50) then {_currentSpeed = 100}; //Minimum speed to prevent stalling
            _newVelocity = _dirVectorNormalized vectorMultiply _currentSpeed;

            //Update plane direction and velocity
            _plane setVectorDirAndUp [_dirVectorNormalized,[0,0,1]];
            _plane setVelocity _newVelocity;

            //Ensure targeting is maintained
            {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;

            if ((random 1) > 0.4) exitWith {false};//Chance to skip fire (fires too often otherwise)
            [_plane,_strikeData,_helper] call NWG_ACA_VehicleForceFire;//Fire
            false
        };
        if (call _abortCondition) exitWith {true};

        //5. Release and reload
        private _restoreAltitude = call NWG_fnc_dtsGetAirHeight;
        _plane flyInHeight [_restoreAltitude,true];
        _plane flyInHeightASL [_restoreAltitude,_restoreAltitude,_restoreAltitude];
        {_x doWatch objNull; _x doTarget objNull} forEach _strikeTeam;//Release target from sight
        _plane setVehicleAmmo 1;

        //6. Cleanup after flyby
        _timeoutAt = time + (NWG_ACA_Settings get "AIRSTRIKE_TIMEOUT");
        private _distOld = _plane distance2D _target;
        private _distNew = _distOld;
        waitUntil {
            sleep 1;
            if (call _abortCondition) exitWith {true};
            if (time > _timeoutAt) exitWith {true};//Timeout
            _distNew = _plane distance2D _target;
            if (_distNew > _distOld) exitWith {true};//Plane is moving away from target
            _distOld = _distNew;
            false
        };
        if (call _abortCondition) exitWith {true};
        if (!isNull _helper) then {
            deleteVehicle _laser;
            _helper call NWG_ACA_DeleteHelper;
        };

        //return
        _counter = _counter + 1;
        _counter >= _numberOfStrikes
    };

    //Cleanup
    if (!isNull _helper) then {
        deleteVehicle _laser;
        _helper call NWG_ACA_DeleteHelper;
    };
    if (!isNull _group) then {
        _group setBehaviourStrong "AWARE";
        _group setCombatBehaviour "AWARE";
        _group call NWG_fnc_dsReturnToPatrol;
    };
    if (alive _plane) then {
        _plane setVehicleAmmo 1;
    };
};

/*Utils*/
NWG_ACA_GetDataForVehicleForceFire = {
    // private _vehicle = _this;

    //Get initial vehicle info like unit and its turret
    private _result = ((fullCrew [_this,"",false])
        select {(_x#2) == -1})/*Filter out cargo units*/
        apply {[_x#0,_x#3]};/*Repack into [unit,turret]*/

    //For each turret get its weapons and firemodes for each weapon
    private _falseWeapons = ["Horn","Laserdesignator","SmokeLauncher","CMFlareLauncher"];
    private ["_turret","_weapons","_cur","_fireModes","_muzzles"];
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
            _muzzles = (getArray (configFile >> "CfgWeapons" >> _cur >> "muzzles"));
            if (_muzzles isNotEqualTo ["this"] && {!(_cur in _muzzles)}) then {_cur = _muzzles param [0,_cur]};
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

//================================================================================================================
//Artillery strike
NWG_ACA_GetArtilleryVehicle = {
    // private _group = _this;
    if (!alive (leader _this)) exitWith {objNull};

    //Get leader's vehicle
    private _veh = vehicle (leader _this);
    if (!alive _veh) exitWith {objNull};
    if (_veh isEqualTo (leader _this)) exitWith {objNull};//Leader on-foot

    //Check cache
    private _flag = _veh getVariable "NWG_ACA_vehCanArtillery";//Check cache
    if (!isNil "_flag") exitWith {if (_flag) then {_veh} else {objNull}};

    //Check if vehicle can do artillery fire
    _flag = (_veh call NWG_fnc_ocIsVehicle) || {_veh call NWG_fnc_ocIsTurret};
    _flag = _flag && {(getArtilleryAmmo [_veh]) isNotEqualTo []};

    //Cache and return
    _veh setVariable ["NWG_ACA_vehCanArtillery",_flag];
    if (_flag) then {_veh} else {objNull}
};

NWG_ACA_CanDoArtilleryStrike = {
    // private _group = _this;
    !isNull (_this call NWG_ACA_GetArtilleryVehicle)
};

NWG_ACA_CanDoArtilleryStrikeOnTarget = {
    params ["_group","_target"];
    if (isNull _target || {!alive _target}) exitWith {false};//Target is not valid
    private _artillery = _group call NWG_ACA_GetArtilleryVehicle;
    if (isNull _artillery) exitWith {false};
    (position _target) inRangeOfArtillery [[_artillery],((getArtilleryAmmo [_artillery]) param [0,""])]
};

NWG_ACA_SendArtilleryStrike = {
    params ["_group","_target"];
    if !([_group,_target] call NWG_ACA_CanDoArtilleryStrikeOnTarget) exitWith {false};
    [_group,NWG_ACA_ArtilleryStrike,_target,_precise] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_ArtilleryStrike = {
    params ["_group","_target"];

    //Prepare variables
    private _artillery = _group call NWG_ACA_GetArtilleryVehicle;
    if (isNull _artillery) exitWith {"NWG_ACA_ArtilleryStrike: No artillery units found" call NWG_fnc_logError};
    private _count = selectRandom (NWG_ACA_Settings get "ARTILLERY_STRIKE_COUNTS");
    private _timeoutAt = time + (NWG_ACA_Settings get "ARTILLERY_STRIKE_TIMEOUT");
    private _gunner = gunner _artillery;
    private _abortCondition = {!alive _artillery || {!alive _gunner || {time > _timeoutAt}}};
    if (call _abortCondition) exitWith {};//Immediate check

    //Unfreeze (fix for dynamic simulation)
    {
        if (dynamicSimulationEnabled _x) then {_x enableDynamicSimulation false};
        if (_x isEqualType objNull && {!(simulationEnabled _x)}) then {_x enableSimulationGlobal true};
    } forEach ([_group,_artillery] + (crew _artillery));

    //Make courageous
    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";

    //Add Fired EH to check when artillery fired
    if (isNil {_artillery getVariable "NWG_ACA_artFiredCountDown"}) then {
        _artillery addEventHandler ["Fired",{
            // params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
            private _artillery = _this#0;
            private _countDown = _artillery getVariable ["NWG_ACA_artFiredCountDown",0];
            _artillery setVariable ["NWG_ACA_artFiredCountDown",(_countDown - 1)];
        }];
    };

    //Save expected number of strikes
    _artillery setVariable ["NWG_ACA_artFiredCountDown",_count];

    //Start fire
    private _wp = [_group,_target,"SCRIPTED"] call NWG_ACA_CreateWaypointAt;
    private _script = format ["A3\functions_f\waypoints\fn_wpArtillery.sqf [%1]",_count];
    _wp setWaypointScript _script;

    //Wait for completion
    waitUntil {
        sleep 0.1;
        if (call _abortCondition) exitWith {true};
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};
        if ((_artillery getVariable ["NWG_ACA_artFiredCountDown",0]) <= 0) exitWith {true};
        if (time > _timeoutAt) exitWith {true};
        false
    };
    if (time > _timeoutAt) then {
        "NWG_ACA_ArtilleryStrikeCore: timeout reached" call NWG_fnc_logError;
    };

    //Cleanup
    if (!isNull _group) then {
        _group setBehaviourStrong "AWARE";
        _group setCombatBehaviour "AWARE";
        _group call NWG_fnc_dsClearWaypoints;
    };
    if (alive _artillery) then {
        _artillery setVehicleAmmo 1;
    };
};

//================================================================================================================
//Veh demolition (reuses utils from airstrike)
NWG_ACA_CanDoVehDemolition = {
    // private _group = _this;
    private _veh = vehicle (leader _group);
    if !(_veh isKindOf "Tank"  || {_veh isKindOf "Wheeled_APC_F"}) exitWith {false};
    if !((alive (gunner _veh)) && {alive (driver _veh)}) exitWith {false};
    if !(_veh call NWG_fnc_ocIsArmedVehicle) exitWith {false};
    //All checks passed
    true
};

NWG_ACA_SendToVehDemolition = {
    params ["_group","_target"];
    //Check if group can do veh demolition
    if !(_group call NWG_ACA_CanDoVehDemolition) exitWith {
        "NWG_ACA_SendToVehDemolition: tried to send group that can't do veh demolition" call NWG_fnc_logError;
        false;
    };
    if !(_target call NWG_fnc_ocIsBuilding) exitWith {
        "NWG_ACA_SendToVehDemolition: target is not a building" call NWG_fnc_logError;
        false;
    };

    [_group,NWG_ACA_VehDemolition,_target] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_IsClearLineBetween = {
    params ["_obj1","_obj2"];
    private _raycastFrom = getPosASL _obj1; _raycastFrom = _raycastFrom vectorAdd [0,0,1.5];//Raise the position a bit
    private _raycastTo = getPosASL _obj2;
    private _raycast = lineIntersectsSurfaces [_raycastFrom,_raycastTo,_obj1,objNull,true,1,"FIRE","VIEW",true];

    if ((count _raycast) == 0) exitWith {true};/*No obstacles*/
    if (((_raycast#0)#2) isEqualTo _obj2) exitWith {true};/*The first/only obstacle is the target itself*/
    if (((_raycast#0)#3) isEqualTo _obj2) exitWith {true};/*The first/only obstacle is the target itself*/
    false/*There is an obstacle between the two objects*/
};

NWG_ACA_VehDemolition = {
    params ["_group","_target"];
    private _veh = vehicle (leader _group);
    private _timeoutAt = time + (NWG_ACA_Settings get "VEH_DEMOLITION_TIMEOUT");
    private _abortCondition = {!alive _veh || {!alive (driver _veh) || {!alive (gunner _veh) || {!alive _target || {time > _timeoutAt}}}}};
    if (call _abortCondition) exitWith {};//Immediate check

    _veh setVehicleAmmo 1;
    private _strikeData = _veh call NWG_ACA_GetDataForVehicleForceFire;
    private _strikeTeam = crew _veh;
    _group setCombatMode "RED";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Move to the target
    _strikeTeam doMove (position _target);
    private _lastPos = getPosATL _veh;
    waitUntil {
        sleep 3;
        if (call _abortCondition) exitWith {true};
        if ((_veh distance _lastPos) < 1) then {_strikeTeam doMove (position _target)};
        _lastPos = getPosATL _veh;
        if ((_veh distance _target) > (NWG_ACA_Settings get "VEH_DEMOLITION_FIRE_RADIUS")) exitWith {false};//Out of range
        if !([_veh,_target] call NWG_ACA_IsClearLineBetween) exitWith {false};//Obstacle between
        true
    };
    if (call _abortCondition) exitWith {};

    //Watch
    private _helper = [_group,_target] call NWG_ACA_CreateHelper;
    {doStop _x; _x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
    sleep 1;//Wait for turret to turn
    if (call _abortCondition) exitWith {_helper call NWG_ACA_DeleteHelper};

    //Fire until _abortCondition is met
    waitUntil {
        sleep ((random 1)+1);
        if (call _abortCondition) exitWith {true};
        [_veh,_strikeData,_helper] call NWG_ACA_VehicleForceFire;
        _veh setVehicleAmmo 1;
        false
    };
    _helper call NWG_ACA_DeleteHelper;
};

//================================================================================================================
//Inf building storm
NWG_ACA_CanDoInfBuildingStorm = {
    //private _group = _this;
    //Just check that it is an infantry group
    private _units = ((units _this) select {alive _x});
    if ((count _units) == 0) exitWith {false};//No alive units
    //return
    (_units findIf {(vehicle _x) isNotEqualTo _x}) == -1
};

NWG_ACA_SendToInfBuildingStorm = {
    params ["_group","_target"];
    //Check if group can do inf building storm
    if !(_group call NWG_ACA_CanDoInfBuildingStorm) exitWith {
        "NWG_ACA_SendToInfBuildingStorm: tried to send group that can't do inf building storm" call NWG_fnc_logError;
        false;
    };
    if !(_target call NWG_fnc_ocIsBuilding) exitWith {
        "NWG_ACA_SendToInfBuildingStorm: target is not a building" call NWG_fnc_logError;
        false;
    };

    [_group,NWG_ACA_InfBuildingStorm,_target] call NWG_ACA_StartAdvancedLogic;
    true
};

#define FIRE_TYPE_SPPRS 0
#define FIRE_TYPE_WEAPN 1
#define FIRE_TYPE_GRNDE 2
NWG_ACA_InfBuildingStorm = {
    params ["_group","_target"];

    private _timeout = time + (NWG_ACA_Settings get "INF_STORM_TIMEOUT");
    private _abortCondition = {({alive _x} count (units _group)) < 1 || {time > _timeout}};
    if (call _abortCondition) exitWith {};//Immediate check

    _group setCombatMode "RED";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Get closer to the building
    (units _group) doMove (position _target);
    waitUntil {
        sleep 2;
        if (call _abortCondition) exitWith {true};
        (units _group) doMove (position _target);
        if (((leader _group) distance _target) > (NWG_ACA_Settings get "INF_STORM_FIRE_RADIUS")) exitWith {false};//Out of range
        if !([(leader _group),_target] call NWG_ACA_IsClearLineBetween) exitWith {false};//Obstacle between
        true
    };
    if (call _abortCondition) exitWith {};

    //Attack the building
    private _helper = [_group,_target] call NWG_ACA_CreateHelper;
    private _units = (units _group) select {alive _x};
    doStop _units;
    _group reveal [_helper,4];
    _units doWatch _helper; _units doTarget _helper;
    private _fireTime = time + (NWG_ACA_Settings get "INF_STORM_FIRE_TIME");

    waitUntil {
        if (call _abortCondition) exitWith {true};
        _units = _units select {alive _x};//Update list

        //forEach unit
        private ["_unit","_weaponsInfo","_primaryWeapon","_secondaryWeapon","_g","_i","_fireType","_muzzle"];
        {
            _unit = _x;
            _weaponsInfo = _unit weaponsInfo [""];

            _i = call {
                _primaryWeapon = primaryWeapon _unit;
                _secondaryWeapon = secondaryWeapon _unit;

                //Obstacle between unit and a target
                if (!([_unit,_target] call NWG_ACA_IsClearLineBetween)) exitWith {
                    _fireType = FIRE_TYPE_SPPRS;
                    _weaponsInfo findIf {(_x#2) isEqualTo _primaryWeapon};
                };
                //AT unit that sees the target
                if (_secondaryWeapon isNotEqualTo "") exitWith {
                    _fireType = FIRE_TYPE_WEAPN;
                    _weaponsInfo findIf {(_x#2) isEqualTo _secondaryWeapon};
                };
                //Sub-barrel grenade launcher
                _g = _weaponsInfo findIf {(_x#5) isEqualTo "1Rnd_HE_Grenade_shell" && {(_x#6) > 0}};
                if (_g != -1) exitWith {_fireType = FIRE_TYPE_WEAPN; _g};
                //Grenades
                _g = _weaponsInfo findIf {(_x#5) isEqualTo "HandGrenade" && {(_x#6) > 0}};
                if (_g != -1) exitWith {_fireType = FIRE_TYPE_GRNDE; _g};
                _g = _weaponsInfo findIf {(_x#5) isEqualTo "MiniGrenade" && {(_x#6) > 0}};
                if (_g != -1) exitWith {_fireType = FIRE_TYPE_GRNDE; _g};
                //Fallback to primary weapon
                _fireType = FIRE_TYPE_SPPRS;
                _weaponsInfo findIf {(_x#2) isEqualTo _primaryWeapon};
            };
            if (_i == -1) then {continue};//Something went wrong
            _muzzle = (_weaponsInfo#_i)#3;
            _unit doTarget _helper;
            switch (_fireType) do {
                case FIRE_TYPE_SPPRS : {_unit doSuppressiveFire _helper};
                case FIRE_TYPE_WEAPN : {_unit selectWeapon _muzzle; _unit fire _muzzle};
                case FIRE_TYPE_GRNDE : {[_unit,_muzzle] call BIS_fnc_fire};
            };
            sleep (random 0.5);
        } forEach _units;

        sleep 3;
        time > _fireTime
    };
    _helper call NWG_ACA_DeleteHelper;
    if (call _abortCondition) exitWith {};

    //Check if target is (half-destroyed)
    private _continue = true;
    if (!alive _target || {isObjectHidden _target || {((getPosATL _target)#2) < 0}}) then {
        private _replacements = nearestObjects [_target,["house"],10,true];
        _replacements = _replacements - [_target];
        if ((count _replacements) <= 0) exitWith {_continue = false};//Target is destroyed and there are no replacements
        _target = _replacements select 0;//Get closest replacement
    };
    if (!_continue) exitWith {};

    //Prepare storming positions
    _units = _units select {alive _x};//Update list
    private _buildingPos = _target buildingPos -1;
    if (_buildingPos isEqualTo []) then {_buildingPos = [(getPosATL _target)]};
    _buildingPos = _buildingPos apply {[_x#2,_x]};//Conver for sorting
    _buildingPos sort false;//Descending order
    _buildingPos = _buildingPos apply {_x#1};//Convert back
    while {(count _buildingPos) < (count _units)} do {_buildingPos append _buildingPos};//Extend the list to match the number of units

    //Storm the building
    private _stormTime = time + (NWG_ACA_Settings get "INF_STORM_STORM_TIME");
    private ["_pos"];
    waitUntil {
        if (call _abortCondition) exitWith {true};

        {
            _pos = _buildingPos select _forEachIndex;
            _x forceSpeed -1;
            _x doMove _pos;
            _x moveTo _pos;
            _x setDestination [_pos,"FORMATION PLANNED",true];
        } foreach _units;

        sleep 3;
        time > _stormTime
    };
};

//================================================================================================================
//Veh vehicle repair
NWG_ACA_CanDoVehRepair = {
    // private _group = _this;
    private _veh = vehicle (leader _this);
    if !(alive _veh) exitWith {false};
    if !(_veh isKindOf "Car" || {_veh isKindOf "Tank"}) exitWith {false};
    if (unitIsUAV _veh) exitWith {false};
    //return
    true
};

NWG_ACA_NeedsRepair = {
    // private _group = _this;
    if !(_this call NWG_ACA_CanDoVehRepair) exitWith {false};
    private _veh = vehicle (leader _this);
    (((getAllHitPointsDamage _veh)#2) findIf {_x >= 0.25}) != -1
};

NWG_ACA_SendToVehRepair = {
    private _group = _this;
    //Check if group can do veh repair
    if !(_group call NWG_ACA_CanDoVehRepair) exitWith {
        "NWG_ACA_SendToVehRepair: tried to send group that can't do veh repair" call NWG_fnc_logError;
        false;
    };
    if !(_group call NWG_ACA_NeedsRepair) exitWith {false};

    [_group,NWG_ACA_VehRepair] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_VehRepair = {
    params ["_group"];
    private _veh = vehicle (leader _group);
    private _crew = crew _veh;

    //Reload the crew if driver is dead
    if (!alive (driver _veh)) then {
        {_x moveOut _veh; _x moveInAny _veh} forEach _crew;
    };

    private _timeout = time + 180;
    private _abortCondition = {!alive _veh || {({alive _x} count _crew) < 1 || {time > _timeout}}};
    if (call _abortCondition) exitWith {};//Immediate check

    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";
    private _onExit = {
        if (!isNull _group) then {
            _group setBehaviourStrong "AWARE";
            _group setCombatBehaviour "AWARE";
        };
    };

    //Find a repair position
    private _repairPos = call {
        private _vehPos = getPosATL _veh;
        if !(canMove _veh) exitWith {_vehPos};//Vehicle is stuck
        private _radius = (NWG_ACA_Settings get "VEH_REPAIR_RADIUS");
        private _posOptions = [_vehPos,_radius,9] call NWG_fnc_dtsGenerateDotsCircle;
        _posOptions = _posOptions select {!surfaceIsWater _x};
        if (_posOptions isEqualTo []) exitWith {_vehPos};//Fallback
        private _allPlayers = call NWG_fnc_getPlayersOrOccupiedVehicles;
        if (_allPlayers isEqualTo []) exitWith {selectRandom _posOptions};//Fallback
        private ["_point","_minDist","_dist"];
        _posOptions = _posOptions apply {
            _point = _x;
            _minDist = 100000;
            {
                _dist = _point distance _x;
                if (_dist < _minDist) then {_minDist = _dist};
            } forEach _allPlayers;
            [_minDist,_point]
        };
        _posOptions sort false;
        ((_posOptions#0)#1)
    };

    //Move to the repair position
    _crew doMove _repairPos;
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        (_veh distance _repairPos) < 15
    };
    if (call _abortCondition) exitWith _onExit;

    //Unload the crew
    _crew = _crew select {alive _x};
    doStop _crew;
    sleep 2;
    if (call _abortCondition) exitWith _onExit;
    _crew = _crew select {alive _x};
    _group leaveVehicle _veh;
    {_x moveOut _veh} forEach _crew;

    //Repair
    sleep 1;
    if (call _abortCondition) exitWith _onExit;
    _crew = _crew select {alive _x};
    {
        _x setDir (_x getDir _veh);
        _x switchMove "Acts_carFixingWheel";
        _x playMoveNow "Acts_carFixingWheel";
    } forEach _crew;
    sleep ((random 2)+5);
    if (call _abortCondition) exitWith _onExit;
    _veh setDamage 0;

    //Reload the crew
    _group addVehicle _veh;
    _crew = _crew select {alive _x};
    {_x moveInAny _veh} forEach _crew;

    call _onExit;
};