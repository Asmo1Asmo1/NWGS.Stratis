#include "..\..\globalDefines.h"
#include "advancedCombatDefines.h"
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
    ["AIRSTRIKE_TIMEOUT",180],//Timeout for EACH STEP of airstrike (in case of any errors) (there are 6 steps)

    ["ARTILLERY_STRIKE_COUNTS",[2,3,4,5,6]],//Number of artillery strikes to do (randomly selected from this array)
    ["ARTILLERY_STRIKE_TIMEOUT",300],//Timeout for artillery strike (in case of any errors)

    ["VEH_DEMOLITION_DURATION",40],//How long to try to demolish a building (in seconds)
    ["VEH_DEMOLITION_TIMEOUT",300],//Timeout for veh demolition

    ["INF_STORM_FIRE_RADIUS",35],//Radius for fireing
    ["INF_STORM_FIRE_TIME",10],//Time for fireing
    ["INF_STORM_STORM_TIME",60],//Time for storming the building
    ["INF_STORM_TIMEOUT",300],//Timeout for inf building storm

    ["VEH_REPAIR_RADIUS",500],//Radius for vehicle to initially move to repair (repair starts when no players are within 'VEH_REPAIR_PLAYER_DISTANCE')
    ["VEH_REPAIR_PLAYER_DISTANCE",200],//Distance from nearest player to assume repair is safe
    ["VEH_REPAIR_TIMEOUT",180],//Timeout for EACH STEP of veh repair

    ["INF_VEH_CAPTURE_RADIUS",150],//Radius to search for vehicles to capture
    ["INF_VEH_CAPTURE_MARK_TIME",120],//Time to mark vehicle for capture (in seconds)
    ["INF_VEH_CAPTURE_TIMEOUT",240],//Timeout for inf vehicle capture

    ["VEH_FLEE_RADIUS",3000],//Radius to flee from current position
    ["VEH_FLEE_DESPAWN_RADIUS",1000],//Radius to check for players before despawning
    ["VEH_FLEE_TIMEOUT",600],//Timeout for veh flee

    ["HELPER_WAYPOINT_ADD",true],//Add first waypoint at current vehicle position to be visible at spectator view
    ["HELPER_CLASSNAMES",["O_Quadbike_01_F","O_Soldier_AT_F"]],//params ["_invisibleVehicle","_agentToPutIntoVehicle"] (faction matters!)

    ["STATISTICS_ENABLED",true],//If true, the system will keep track of statistics and output them to the RPT log

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
    private _aslPos = getPosASL _target;
    private _worldPos = getPosWorld _target;
    _helperVeh setPosASL [(_aslPos#0),(_aslPos#1),(((_aslPos#2) + (_worldPos#2)) / 2)];//Slightly above ground
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
    if (NWG_ACA_Settings get "HELPER_WAYPOINT_ADD") then {
        _group addWaypoint [(vehicle (leader _group)),0];//Create first waypoint at current vehicle position
    };

    private _targetPos = getPosASL _target;
    _targetPos set [2,0];
    private _wpPos = [_targetPos,(_radius max 1),_posType] call NWG_fnc_dtsFindDotForWaypoint;//Get position for new waypoint
    if (_wpPos isEqualTo false) then {
        (format ["NWG_ACA_CreateWaypointAround: failed to find waypoint position for args: '%1', fallback to target position: %2",_this,_targetPos]) call NWG_fnc_logError;
        _wpPos = _targetPos;
    };
    _wpPos set [2,_posHeight];
    if (_posHeight > 0) then {_wpPos = ASLToAGL _wpPos};

    private _wp = [_group,_wpPos,_wpType] call NWG_fnc_dsAddWaypoint;//Create new waypoint
    _group setVariable ["NWG_ACA_IsWaypointCompleted",false];//Track waypoint completion (part 1)
    _wp setWaypointStatements ["true", "if (local this) then {this call NWG_ACA_OnWaypointCompleted}"];//Track waypoint completion (part 2)
    if (NWG_ACA_Settings get "HELPER_WAYPOINT_ADD") then {_group setCurrentWaypoint _wp};

    //return
    _wp
};

NWG_ACA_CreateWaypointAt = {
    params ["_group","_target",["_wpType","MOVE"]];

    _group call NWG_fnc_dsClearWaypoints;//Clear existing waypoints
    if (NWG_ACA_Settings get "HELPER_WAYPOINT_ADD") then {
        _group addWaypoint [(vehicle (leader _group)),0];//Create first waypoint at current vehicle position
    };

    private _wp = _group addWaypoint [_target,0];//Create new waypoint exactly at the target
    _wp setWaypointType _wpType;//Specify waypoint type
    _group setVariable ["NWG_ACA_IsWaypointCompleted",false];//Track waypoint completion (part 1)
    _wp setWaypointStatements ["true", "if (local this) then {this call NWG_ACA_OnWaypointCompleted}"];//Track waypoint completion (part 2)
    if (NWG_ACA_Settings get "HELPER_WAYPOINT_ADD") then {_group setCurrentWaypoint _wp};

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
    [STAT_ACA_AIRSTRIKE,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _plane = vehicle (leader _group);
    private _pilot = currentPilot _plane;//Fix for some helicopters
    private _abortCondition = {!alive _plane || {!alive _pilot || {!alive _target}}};
    if (call _abortCondition) exitWith {
        [STAT_ACA_AIRSTRIKE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";

    _plane setVehicleAmmo 1;//Lock'n'load
    private _strikeData = _plane call NWG_ACA_GetDataForVehicleForceFire;
    private _strikeTeam = crew _plane;
    private _prepareAltitude = (NWG_ACA_Settings get "AIRSTRIKE_PREPARE_HEIGHT");
    private _helper = objNull;
    private _laser = objNull;

    //Statistics
    private _statFired = false;
    private _statTimed = false;

    //Start Airstrike cycle
    for "_i" from 1 to _numberOfStrikes do {
        if (call _abortCondition) exitWith {};

        //0. Fix pilots stucking in one place (No longer needed?)
        // if !(unitIsUAV _plane) then {
        //     private _crew = (crew _plane) select {alive _x};
        //     _group leaveVehicle _plane;
        //     {_x disableCollisionWith _plane; _x moveOut _plane} forEach _crew;
        //     _plane engineOn true;
        //     _group addVehicle _plane;
        //     {_x moveInAny _plane} forEach _crew;
        // };

        //1. Fly away from the target
        private _timeoutAt = time + (NWG_ACA_Settings get "AIRSTRIKE_TIMEOUT");
        [_group,_target,(NWG_ACA_Settings get "AIRSTRIKE_PREPARE_RADIUS"),"air",_prepareAltitude,"MOVE"] call NWG_ACA_CreateWaypointAround;
        _plane flyInHeight [_prepareAltitude,true];
        _plane flyInHeightASL [_prepareAltitude,_prepareAltitude,_prepareAltitude];
        waitUntil {
            sleep 1;
            if (call _abortCondition) exitWith {true};//Abort the mission
            if (time > _timeoutAt) exitWith {true};//Timeout
            if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint reached
            false/*go to next iteration*/
        };
        if (call _abortCondition) exitWith {};
        if (time > _timeoutAt && {(_plane distance2D _target) < (NWG_ACA_Settings get "AIRSTRIKE_DESCEND_RADIUS")}) exitWith {_statTimed = true};

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
        if (call _abortCondition) exitWith {};
        if (time > _timeoutAt && {(_plane distance2D _target) < (NWG_ACA_Settings get "AIRSTRIKE_STOP_RADIUS")}) exitWith {_statTimed = true};

        //4. Descend and fire (we take manual control over Arma physics and AI behavior for this part, so no need to check for waypoint completion or timeout)
        _plane flyInHeight [0,true];
        _plane flyInHeightASL [0,0,0];
        {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
        private ["_dirVectorNormalized","_currentSpeed","_newVelocity"];
        waitUntil {
            sleep 0.05;//Smallest value required for plane not to jiggle
            if (call _abortCondition) exitWith {true};

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

            //Exit when close enough
            (_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_FIRE_RADIUS")
        };
        waitUntil {
            sleep 0.05;//Smallest value required for plane not to jiggle
            if (call _abortCondition) exitWith {true};

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

            //Fire sequence
            if ((random 1) > 0.4) then {
                [_plane,_strikeData,_helper] call NWG_ACA_VehicleForceFire;//Fire
                _statFired = true;
            };

            //Exit when close enough
            (_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_STOP_RADIUS")
        };
        if (call _abortCondition) exitWith {};

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
        if (call _abortCondition) exitWith {};
        if (!isNull _helper) then {
            deleteVehicle _laser;
            _helper call NWG_ACA_DeleteHelper;
        };
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

    //Statistics
    if (_statFired) exitWith {[STAT_ACA_AIRSTRIKE,STAT_ACA_SUCCESS] call NWG_ACA_AddStat};
    if (_statTimed) exitWith {[STAT_ACA_AIRSTRIKE,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat};
    [STAT_ACA_AIRSTRIKE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
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
    if (!alive (gunner _veh)) exitWith {objNull};//No gunner

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
    [_group,NWG_ACA_ArtilleryStrike,_target] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_ArtilleryStrike = {
    params ["_group","_target"];
    [STAT_ACA_ARTILLERY,STAT_ACA_TOTAL] call NWG_ACA_AddStat;

    //Prepare variables
    private _artillery = _group call NWG_ACA_GetArtilleryVehicle;
    if (isNull _artillery) exitWith {
        "NWG_ACA_ArtilleryStrike: No artillery units found" call NWG_fnc_logError;
        [STAT_ACA_ARTILLERY,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };
    private _count = selectRandom (NWG_ACA_Settings get "ARTILLERY_STRIKE_COUNTS");
    private _timeoutAt = time + (NWG_ACA_Settings get "ARTILLERY_STRIKE_TIMEOUT");
    private _gunner = gunner _artillery;
    private _abortCondition = {!alive _artillery || {!alive _gunner}};
    if (call _abortCondition) exitWith {
        [STAT_ACA_ARTILLERY,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

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
        if (time > _timeoutAt) exitWith {true};
        if ((_artillery getVariable ["NWG_ACA_artFiredCountDown",0]) <= 0) exitWith {true};
        false
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

    //Statistics
    if ((_artillery getVariable ["NWG_ACA_artFiredCountDown",_count]) < _count) exitWith {[STAT_ACA_ARTILLERY,STAT_ACA_SUCCESS] call NWG_ACA_AddStat};
    if (time > _timeoutAt) exitWith {[STAT_ACA_ARTILLERY,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat};
    [STAT_ACA_ARTILLERY,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
};

//================================================================================================================
//Veh demolition (reuses utils from airstrike)
NWG_ACA_CanDoVehDemolition = {
    // private _group = _this;

    //Get leader's vehicle
    private _veh = vehicle (leader _this);
    if (!alive _veh) exitWith {false};
    if (_veh isEqualTo (leader _this)) exitWith {false};//Leader on-foot
    if (!alive (gunner _veh)) exitWith {false};//No gunner
    if (!alive (driver _veh)) exitWith {false};//No driver

    //Check cache
    private _flag = _veh getVariable "NWG_ACA_vehCanDemolition";//Check cache
    if (!isNil "_flag") exitWith {_flag};

    //Check if vehicle can do demolition
    _flag = (_veh isKindOf "Tank"  || {_veh isKindOf "Wheeled_APC_F"});
    _flag = _flag && {_veh call NWG_fnc_ocIsArmedVehicle};

    //Cache and return
    _veh setVariable ["NWG_ACA_vehCanDemolition",_flag];
    _flag
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
    private _raycastFrom = (getPosASL _obj1) vectorAdd [0,0,1.5];//Raise the position a bit
    private _raycastTo = (getPosASL _obj2) vectorAdd [0,0,1.5];//Raise the position a bit
    private _raycast = lineIntersectsSurfaces [_raycastFrom,_raycastTo,_obj1,objNull,true,1,"FIRE","VIEW",true];

    //return
    (count _raycast) == 0 || {((_raycast#0)#2) isEqualTo _obj2 || {((_raycast#0)#3) isEqualTo _obj2}}
};

NWG_ACA_ReplaceTarget = {
    private _target = _this;
    if (!alive _target || {isObjectHidden _target || {((getPosATL _target)#2) < 0}}) then {
        private _replacements = (nearestObjects [_target,["house"],10,true]) select {alive _x};
        _replacements = _replacements - [_target];
        _target = if ((count _replacements) > 0)
            then {_replacements select 0}/*Get closest replacement*/
            else {objNull};/*No replacements*/
    };
    //return
    _target
};

NWG_ACA_VehDemolition = {
    params ["_group","_target"];
    [STAT_ACA_VEH_DEMOL,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _veh = vehicle (leader _group);
    private _timeoutAt = time + (NWG_ACA_Settings get "VEH_DEMOLITION_TIMEOUT");
    private _abortCondition = {
        !alive _veh || {
        !alive (driver _veh) || {
        !alive (gunner _veh) || {
        !alive _target || {
        ((_veh nearEntities [["Man"],7]) findIf {isPlayer _x}) != -1}}}}};
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_DEMOL,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    //Setup
    _veh setVehicleAmmo 1;
    private _strikeData = _veh call NWG_ACA_GetDataForVehicleForceFire;
    private _strikeTeam = crew _veh;
    private _helper = objNull;
    _group setCombatMode "BLUE";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Teardown
    private _onExit = {
        {_x doWatch objNull; _x doTarget objNull} forEach (_strikeTeam select {alive _x});//Release target from sight
        if (!isNull _helper) then {_helper call NWG_ACA_DeleteHelper};//Delete helper
        if (alive _veh) then {_veh setVehicleAmmo 1};//Reload
        if (!isNull _group) then {_group setCombatMode "RED"; _group call NWG_fnc_dsReturnToPatrol};//Return to patrol
    };

    //Move to the target
    [_group,_target,5,"ground"] call NWG_ACA_CreateWaypointAround;
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if ([_veh,_target] call NWG_ACA_IsClearLineBetween) exitWith {true};//Ready to fire
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        if (time > _timeoutAt) exitWith {true};
        false
    };
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_DEMOL,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    if (time > _timeoutAt) exitWith {
        [STAT_ACA_VEH_DEMOL,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Stop and watch
    _group call NWG_fnc_dsClearWaypoints;
    private _helper = [_group,_target] call NWG_ACA_CreateHelper;
    {doStop _x; _x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
    sleep 2;//Wait for turret to turn
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_DEMOL,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Fire
    private _stopFireAt = time + (NWG_ACA_Settings get "VEH_DEMOLITION_DURATION");
    {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;//Keep targeting
    _group setCombatMode "RED";
    private _statFired = false;
    waitUntil {
        sleep 0.1;
        _target = _target call NWG_ACA_ReplaceTarget;
        if (call _abortCondition) exitWith {true};
        if (time > _stopFireAt) exitWith {true};
        {_x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;//Keep targeting
        if ((random 1) > 0.2) exitWith {false};//Chance to skip fire (fires too often otherwise)
        [_veh,_strikeData,_helper] call NWG_ACA_VehicleForceFire;
        _statFired = true;
        false
    };

    //Cleanup
    call _onExit;

    //Statistics
    if (_statFired) exitWith {[STAT_ACA_VEH_DEMOL,STAT_ACA_SUCCESS] call NWG_ACA_AddStat};
    [STAT_ACA_VEH_DEMOL,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
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
    [STAT_ACA_INF_STORM,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _timeoutAt = time + (NWG_ACA_Settings get "INF_STORM_TIMEOUT");
    private _abortCondition = {({alive _x} count (units _group)) < 1};
    if (call _abortCondition) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    //Setup
    private _strikeTeam = units _group;
    private _helper = objNull;
    _group setCombatMode "BLUE";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Teardown
    private _onExit = {
        {_x doWatch objNull; _x doTarget objNull} forEach (_strikeTeam select {alive _x});//Release target from sight
        if (!isNull _helper) then {_helper call NWG_ACA_DeleteHelper};//Delete helper
        if (!isNull _group) then {_group setCombatMode "RED"; _group call NWG_fnc_dsReturnToPatrol};//Return to patrol
    };

    //Get closer to the building
    [_group,_target,5,"ground"] call NWG_ACA_CreateWaypointAround;
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if (time > _timeoutAt) exitWith {true};
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        //Exit cycle when within firing range
        ((leader _group) distance _target) <= (NWG_ACA_Settings get "INF_STORM_FIRE_RADIUS")
    };
    if (call _abortCondition) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    if (time > _timeoutAt) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Ensure enough units can see the target
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if (time > _timeoutAt) exitWith {true};
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        //Exit cycle when enough units can see the target
        _strikeTeam = _strikeTeam select {alive _x};
        (({[_x,_target] call NWG_ACA_IsClearLineBetween} count _strikeTeam) >= (ceil ((count _strikeTeam) * 0.5)))
    };
    if (call _abortCondition) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    if (time > _timeoutAt) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Stop and watch
    _group call NWG_fnc_dsClearWaypoints;
    _helper = [_group,_target] call NWG_ACA_CreateHelper;
    _group setCombatMode "RED";
    _group reveal [_helper,4];
    {doStop _x; _x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;

    //Fire
    private _stopFireAt = time + (NWG_ACA_Settings get "INF_STORM_FIRE_TIME");
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        _target = _target call NWG_ACA_ReplaceTarget;

        //forEach unit
        _strikeTeam = _strikeTeam select {alive _x};//Update list
        private ["_unit","_weaponsInfo","_primaryWeapon","_secondaryWeapon","_g","_i","_fireType","_muzzle"];
        {
            _unit = _x;
            _weaponsInfo = _unit weaponsInfo [""];

            _i = if (true) then {
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
            } else {-1};
            if (_i == -1) then {continue};//Something went wrong
            _muzzle = (_weaponsInfo#_i)#3;
            _unit doTarget _helper;
            switch (_fireType) do {
                case FIRE_TYPE_SPPRS : {_unit doSuppressiveFire _helper};
                case FIRE_TYPE_WEAPN : {_unit selectWeapon _muzzle; _unit fire _muzzle};
                case FIRE_TYPE_GRNDE : {[_unit,_muzzle] call BIS_fnc_fire};
            };
            sleep (random 0.5);
        } forEach _strikeTeam;

        time > _stopFireAt
    };
    if (!isNull _helper) then {_helper call NWG_ACA_DeleteHelper};
    if (call _abortCondition) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Storm the building
    private _buildingPos = _target buildingPos -1;
    if (_buildingPos isEqualTo []) then {_buildingPos = [(getPosATL _target)]};
    _buildingPos = _buildingPos apply {[_x#2,_x]};//Conver for sorting by height
    _buildingPos sort false;//Descending order (highest to lowest)
    _buildingPos = _buildingPos apply {_x#1};//Convert back
    private _playersPos = (_target nearEntities ["Man",10]) apply {ASLtoAGL (getPosASL _x)};
    _buildingPos = _playersPos + _buildingPos;//Add players positions to the list (as first)
    private _attempts = 100;
    while {_attempts > 0 && {(count _buildingPos) < (count _strikeTeam)}} do {
        _attempts = _attempts - 1;
        _buildingPos append _buildingPos;
    };
    if (_attempts <= 0) exitWith {
        "NWG_ACA_InfBuildingStorm: failed to find enough positions to storm the building" call NWG_fnc_logError;
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    _strikeTeam = _strikeTeam select {alive _x};//Update list
    if ((count _strikeTeam) <= 0) exitWith {
        [STAT_ACA_INF_STORM,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };//No units left
    {
        _x forceSpeed -1;
        _x doMove (_buildingPos select _forEachIndex);
        _x moveTo (_buildingPos select _forEachIndex);
        _x setDestination [(_buildingPos select _forEachIndex),"FORMATION PLANNED",true];
    } foreach _strikeTeam;
    private _stopStormAt = time + (NWG_ACA_Settings get "INF_STORM_STORM_TIME");
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        time > _stopStormAt
    };
    //No need to check for abort condition here, because it's ok if players killed the units at this point

    //Cleanup
    call _onExit;

    //Statistics
    [STAT_ACA_INF_STORM,STAT_ACA_SUCCESS] call NWG_ACA_AddStat;
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
    if !(_group call NWG_ACA_NeedsRepair) exitWith {
        "NWG_ACA_SendToVehRepair: tried to send group that doesn't need repair" call NWG_fnc_logError;
        false;
    };

    [_group,NWG_ACA_VehRepair] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_VehRepair = {
    params ["_group"];
    [STAT_ACA_VEH_REPAIR,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _veh = vehicle (leader _group);
    private _crew = crew _veh;
    private _abortCondition = {!alive _veh || {({alive _x} count _crew) < 1}};
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_REPAIR,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    //Reload the crew if driver is dead
    if (!alive (driver _veh)) then {
        {_x moveOut _veh; _x moveInAny _veh} forEach _crew;
    };

    //Setup
    _group setCombatMode "RED";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Teardown
    private _onExit = {
        if (!isNull _group) then {_group call NWG_fnc_dsReturnToPatrol};
    };

    //Prepare script to check players proximity
    private _getPlayers = if (!isNil "NWG_fnc_medIsWounded")
        then { {call NWG_fnc_getPlayersAll select {!(_x call NWG_fnc_medIsWounded)}} }
        else { {call NWG_fnc_getPlayersOrOccupiedVehicles} };
    private _isSafeToRepair = {
        private _players = call _getPlayers;
        if (_players isEqualTo []) exitWith {true};
        private _minDist = 100000;
        {_minDist = _minDist min (_veh distance _x)} forEach _players;
        _minDist >= (NWG_ACA_Settings get "VEH_REPAIR_PLAYER_DISTANCE")
    };

    //Move to the repair position (or at least away from players)
    private _timeoutAt = time + (NWG_ACA_Settings get "VEH_REPAIR_TIMEOUT");
    [_group,_veh,(NWG_ACA_Settings get "VEH_REPAIR_RADIUS"),"ground"] call NWG_ACA_CreateWaypointAround;
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if (time > _timeoutAt) exitWith {true};//Timeout
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        call _isSafeToRepair
    };
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_REPAIR,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Unload the crew
    _crew = _crew select {alive _x};
    {doStop _x} forEach _crew;
    sleep 2;
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_REPAIR,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    _crew = _crew select {alive _x};
    _group leaveVehicle _veh;
    {_x moveOut _veh} forEach _crew;

    //Repair
    sleep 1;
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_REPAIR,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    _crew = _crew select {alive _x};
    {
        _x setDir (_x getDir _veh);
        _x switchMove "Acts_carFixingWheel";
        _x playMoveNow "Acts_carFixingWheel";
    } forEach _crew;
    sleep ((random 2)+5);
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_REPAIR,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };
    _veh setDamage 0;

    //Reload the crew
    _group addVehicle _veh;
    _crew = _crew select {alive _x};
    {_x moveInAny _veh} forEach _crew;

    //Cleanup
    call _onExit;

    //Statistics
    [STAT_ACA_VEH_REPAIR,STAT_ACA_SUCCESS] call NWG_ACA_AddStat;
};

//================================================================================================================
//Inf vehicle capture
NWG_ACA_GetInfVehCaptureTarget = {
    private _group = _this;

    //Get possible target vehicle
    private _veh = ((leader _group) nearEntities [["Car","Tank","Wheeled_APC_F"],(NWG_ACA_Settings get "INF_VEH_CAPTURE_RADIUS")] select {
        ((crew _x) isEqualTo []) && {_x call NWG_fnc_ocIsArmedVehicle}
    }) param [0,objNull];
    if (isNull _veh || {!alive _veh}) exitWith {objNull};

    //Check that we can claim the vehicle for capture
    if ([_veh,_group] call NWG_ACA_CanClaimForInfVehCapture) exitWith {_veh};
    objNull
};

NWG_ACA_CanClaimForInfVehCapture = {
    params ["_veh","_group"];
    private _mark = _veh getVariable "NWG_ACA_InfVehCaptureMark";
    if (isNil "_mark") exitWith {true};//No mark yet
    _mark params ["_markGroup","_markTime"];
    if (_markGroup isEqualTo _group) exitWith {true};//Same group, so OK
    if (({alive _x} count (units _markGroup)) == 0) exitWith {true};//Mark group is dead
    if (time > _markTime) exitWith {true};//Mark expired
    false
};

NWG_ACA_ClaimForInfVehCapture = {
    params ["_veh","_group"];
    if !([_veh,_group] call NWG_ACA_CanClaimForInfVehCapture) exitWith {false};
    _veh setVariable ["NWG_ACA_InfVehCaptureMark",[_group,(time + (NWG_ACA_Settings get "INF_VEH_CAPTURE_MARK_TIME"))]];
    true
};

NWG_ACA_CanDoInfVehCapture = {
    //private _group = _this;
    (_this call NWG_ACA_CanDoInfBuildingStorm) && {!isNull (_this call NWG_ACA_GetInfVehCaptureTarget)}
};

NWG_ACA_SendToInfVehCapture = {
    // private _group = _this;

    //Check if group is infantry and has a valid target vehicle
    if !(_this call NWG_ACA_CanDoInfBuildingStorm) exitWith {
        "NWG_ACA_SendToInfVehCapture: tried to send group that can't do inf vehicle capture" call NWG_fnc_logError;
        false;
    };
    private _targetVehicle = _this call NWG_ACA_GetInfVehCaptureTarget;
    if (isNull _targetVehicle) exitWith {
        "NWG_ACA_SendToInfVehCapture: no valid vehicle found to capture" call NWG_fnc_logError;
        false;
    };
    if !([_targetVehicle,_this] call NWG_ACA_ClaimForInfVehCapture) exitWith {
        "NWG_ACA_SendToInfVehCapture: could not claim vehicle for capture" call NWG_fnc_logError;
        false;
    };

    //Reuse target vehicle as target arg for advanced logic (to reduce number of searches)
    [_this,NWG_ACA_InfVehCapture,_targetVehicle] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_InfVehCapture = {
    params ["_group","_targetVehicle"];
    [STAT_ACA_VEH_CAPTURE,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _leader = leader _group;
    private _timeoutAt = time + (NWG_ACA_Settings get "INF_VEH_CAPTURE_TIMEOUT");
    private _abortCondition = {
        ({alive _x} count (units _group)) < 1 || {
        !alive _targetVehicle || {
        (crew _targetVehicle) findIf {!(_x in (units _group))} != -1}}
    };
    private _successCondition = {((units _group) select {alive _x}) findIf {(vehicle _x) isNotEqualTo _targetVehicle} == -1};
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_CAPTURE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    //Setup
    _group setCombatMode "BLUE";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Teardown
    private _onExit = {
        if (!isNull _group) then {_group setCombatMode "RED"; _group call NWG_fnc_dsReturnToPatrol};//Return to patrol
    };

    //Add vehicle to group
    _group addVehicle _targetVehicle;

    //Create waypoint to get in the vehicle
    [_group,_targetVehicle,"GETIN"] call NWG_ACA_CreateWaypointAt;

    //Wait for waypoint completion or timeout
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if (call _successCondition) exitWith {true};
        if (time > _timeoutAt) exitWith {true};//Timeout
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        false
    };

    //Cleanup
    call _onExit;

    //Statistics
    if (call _abortCondition) exitWith {[STAT_ACA_VEH_CAPTURE,STAT_ACA_ABORTED] call NWG_ACA_AddStat};
    if (call _successCondition) exitWith {[STAT_ACA_VEH_CAPTURE,STAT_ACA_SUCCESS] call NWG_ACA_AddStat};
    if (time > _timeoutAt) exitWith {[STAT_ACA_VEH_CAPTURE,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat};
    [STAT_ACA_VEH_CAPTURE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
};

//================================================================================================================
//Veh flee
NWG_ACA_CanDoVehFlee = {
    //private _group = _this;
    if ((count (units _this)) != 1) exitWith {false};//Exactly one unit must be in the group
    if (!alive (leader _this)) exitWith {false};

    //Get leader's vehicle
    private _veh = vehicle (leader _this);
    if (!alive _veh) exitWith {false};
    if (_veh isEqualTo (leader _this)) exitWith {false};//Leader on-foot

    //Check that their vehicle is of kind 'Car','Tank' or 'Wheeled_APC_F'
    if !(_veh isKindOf "Car" || {_veh isKindOf "Tank" || {_veh isKindOf "Wheeled_APC_F"}}) exitWith {false};

    //return
    true
};

NWG_ACA_SendToVehFlee = {
    // private _group = _this;
    //Use NWG_ACA_CanDoVehFlee to re-check
    if !(_this call NWG_ACA_CanDoVehFlee) exitWith {
        "NWG_ACA_SendToVehFlee: tried to send group that can't do veh flee" call NWG_fnc_logError;
        false;
    };

    //Start advanced logic
    [_this,NWG_ACA_VehFlee] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_VehFlee = {
    params ["_group"];
    [STAT_ACA_VEH_FLEE,STAT_ACA_TOTAL] call NWG_ACA_AddStat;
    private _veh = vehicle (leader _group);
    private _timeoutAt = time + (NWG_ACA_Settings get "VEH_FLEE_TIMEOUT");
    private _abortCondition = {!alive _veh || {!alive (leader _group)}};
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_FLEE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
    };//Immediate check

    //Setup
    _group setCombatMode "BLUE";
    _group setSpeedMode "FULL";
    _group setBehaviourStrong "AWARE";

    //Teardown
    private _onExit = {
        if (!isNull _group) then {_group setCombatMode "RED"; _group call NWG_fnc_dsReturnToPatrol};
    };

    //Create waypoint around group's own vehicle with flee radius and 'ground' type
    [_group,_veh,(NWG_ACA_Settings get "VEH_FLEE_RADIUS"),"ground"] call NWG_ACA_CreateWaypointAround;

    //Wait for waypoint to be completed
    waitUntil {
        sleep 1;
        if (call _abortCondition) exitWith {true};
        if (_group call NWG_ACA_IsWaypointCompleted) exitWith {true};//Waypoint completed
        if (time > _timeoutAt) exitWith {true};//Timeout
        false
    };
    if (call _abortCondition) exitWith {
        [STAT_ACA_VEH_FLEE,STAT_ACA_ABORTED] call NWG_ACA_AddStat;
        call _onExit;
    };

    //Check that there are no players anywhere near despawn radius
    private _players = call NWG_fnc_getPlayersOrOccupiedVehicles;
    private _minDist = 100000;
    {_minDist = _minDist min (_veh distance2D _x)} forEach _players;
    if (_minDist >= (NWG_ACA_Settings get "VEH_FLEE_DESPAWN_RADIUS")) exitWith {
        [STAT_ACA_VEH_FLEE,STAT_ACA_SUCCESS] call NWG_ACA_AddStat;
        _group call NWG_fnc_gcDeleteGroup;
    };

    //Cleanup
    call _onExit;

    //Statistics
    if (time > _timeoutAt)
        then {[STAT_ACA_VEH_FLEE,STAT_ACA_TIMEOUT] call NWG_ACA_AddStat}
        else {[STAT_ACA_VEH_FLEE,STAT_ACA_ABORTED] call NWG_ACA_AddStat};
};

//================================================================================================================
//Statistics
NWG_ACA_statistics = [
/*STAT_ACA_AIRSTRIKE:*/     [0,0,0,0],
/*STAT_ACA_ARTILLERY:*/     [0,0,0,0],
/*STAT_ACA_VEH_DEMOL:*/     [0,0,0,0],
/*STAT_ACA_INF_STORM:*/     [0,0,0,0],
/*STAT_ACA_VEH_REPAIR:*/    [0,0,0,0],
/*STAT_ACA_VEH_CAPTURE:*/   [0,0,0,0],
/*STAT_ACA_VEH_FLEE:*/      [0,0,0,0]
];

NWG_ACA_AddStat = {
    params ["_logicType","_statType"];
    if !(NWG_ACA_Settings get "STATISTICS_ENABLED") exitWith {};

    private _stats = NWG_ACA_statistics param [_logicType,[]];
    private _stat = _stats param [_statType,0];
    _stats set [_statType,_stat + 1];
    NWG_ACA_statistics set [_logicType,_stats];
};

NWG_ACA_PrintStatistics = {
    //Check if statistics are enabled
    if !(NWG_ACA_Settings get "STATISTICS_ENABLED") exitWith {
        "NWG_ACA_PrintStatistics: statistics are disabled" call NWG_fnc_logInfo;
    };

    //Print statistics
    private _stats = NWG_ACA_statistics;
    private _format = {
        params ["_total","_aborted","_timeout","_success"];
        (format ["Total:%1 (A:%2, T:%3, S:%4)",_total,_aborted,_timeout,_success])
    };
    private _lines = [
        (format ["AIRSTRIKE:   %1",((_stats#STAT_ACA_AIRSTRIKE) call _format)]),
        (format ["ARTILLERY:   %1",((_stats#STAT_ACA_ARTILLERY) call _format)]),
        (format ["VEH DEMOL:   %1",((_stats#STAT_ACA_VEH_DEMOL) call _format)]),
        (format ["INF STORM:   %1",((_stats#STAT_ACA_INF_STORM) call _format)]),
        (format ["VEH REPAIR:  %1",((_stats#STAT_ACA_VEH_REPAIR) call _format)]),
        (format ["VEH CAPTURE: %1",((_stats#STAT_ACA_VEH_CAPTURE) call _format)]),
        (format ["VEH FLEE:    %1",((_stats#STAT_ACA_VEH_FLEE) call _format)])
    ];
    diag_log text "==========[  AC ACTIVE STATS  ]===========";
    {diag_log (text _x)} forEach _lines;
    diag_log text "==========[        END        ]===========";

    //Drop statistics
    {NWG_ACA_statistics set [_forEachIndex,(_x apply {0})]} forEach NWG_ACA_statistics;
};