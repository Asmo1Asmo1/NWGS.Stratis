#include "..\..\globalDefines.h"
/*
    This module implements the following logic:
    - Airstrike
    - Artillery strike
    - Mortart strike
    - Veh building demolition
    - Inf building storm
    - Veh vehicle repair
*/
/*
    Breakdown of the module:
    - Find groups that can do Airstrike
    - Send group to do Airstrike on target

    - Find groups that can do Artillery strike
    - Find groups that can do Artillery strike on this position
    - Order to do Artillery strike onto position

    - Find groups that can do Mortar strike
    - Find groups that can do Mortar strike on this position
    - Order to do Mortar strike onto position

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
    ["AIRSTRIKE_PREPARE_HEIGHT",600],//Height at which airstrike will prepare
    ["AIRSTRIKE_YELLOW_RADIUS",1400],//Distance at which plane will start descending
    ["AIRSTRIKE_FIRE_RADIUS",800],//Distance at which to start fireing
    ["AIRSTRIKE_STOP_RADIUS",400],//Distance at which to pull up
    ["AIRSTRIKE_LASER_CLASSNAME","LaserTargetW"],//Classname for laser target (faction matters!)

    ["ARTILLERY_STRIKE_WARNING_RADIUS",100],//Radius for warning strike
    ["ARTILLERY_STRIKE_WARNING_PAUSE",1],//Pause between warning strike and actual strike
    ["ARTILLERY_STRIKE_RADIUS",50],//Radius for actual fire (only if using !_precise argument)
    ["ARTILLERY_STRIKE_TIMEOUT",300],//Timeout for artillery strike (in case of any errors)

    ["MORTAR_STRIKE_WARNING_RADIUS",100],//Radius for warning strike
    ["MORTAR_STRIKE_WARNING_PAUSE",1],//Pause between warning strike and actual strike
    ["MORTAR_STRIKE_RADIUS",35],//Radius for actual fire (only if using !_precise argument)
    ["MORTAR_STRIKE_TIMEOUT",300],//Timeout for mortar strike (in case of any errors)

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
//Common
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

NWG_ACA_CreateHelper = {
    params ["_group","_target"];
    (NWG_ACA_Settings get "HELPER_CLASSNAMES") params ["_invisibleVehicle","_agentToPutIntoVehicle"];
    private _helperVeh = createVehicle [_invisibleVehicle,_target,[],0,"CAN_COLLIDE"];
    _helperVeh hideObjectGlobal true;
    _helperVeh allowDamage false;
    private _helperUnit = createAgent [_agentToPutIntoVehicle,_helperVeh,[],0,"CAN_COLLIDE"];
    _helperUnit hideObjectGlobal true;
    _helperUnit allowDamage false;
    _helperUnit moveInAny _helperVeh;
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
//Airstrike
NWG_ACA_CanDoAirstrike = {
    // private _group = _this;
    if (!alive (leader _this)) exitWith {false};
    private _veh = vehicle (leader _this);
    //return
    (alive _veh && {_veh isKindOf "Air" && {(count (_veh call NWG_fnc_spwnGetVehiclePylons)) > 0}})
};

NWG_ACA_SendToAirstrike = {
    params ["_group","_target",["_numberOfStrikes",1]];
    //Check if group can do airstrike
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
        private _preparePos = _target getPos [(NWG_ACA_Settings get "AIRSTRIKE_PREPARE_RADIUS"),(random 360)];
        _preparePos set [2,_prepareAltitude];
        _plane flyInHeight [_prepareAltitude,true];
        _plane flyInHeightASL [_prepareAltitude,_prepareAltitude,_prepareAltitude];
        _pilot doMove _preparePos;
        waitUntil {
            sleep 0.25;
            (call _abortCondition || {(_plane distance2D _preparePos) < 100})
        };
        if (call _abortCondition) exitWith {true};

        //2. Create airstrike helper at current target position
        _helper = [_group,_target] call NWG_ACA_CreateHelper;
        _laser = createVehicle [(NWG_ACA_Settings get "AIRSTRIKE_LASER_CLASSNAME"),_helper,[],0,"CAN_COLLIDE"];
        _laser attachTo [_helper,[0,0,0]];

        //3. Fly toward target
        _pilot doMove (position _helper);
        waitUntil {
            {_x reveal _helper; _x doWatch _helper; _x doTarget _helper} forEach _strikeTeam;
            sleep 0.25;
            (call _abortCondition || {(_plane distance2D _helper) <= (NWG_ACA_Settings get "AIRSTRIKE_YELLOW_RADIUS")})
        };
        if (call _abortCondition) exitWith {true};

        //4. Descend and fire
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

        //5. Release and reload
        private _restoreAltitude = call NWG_fnc_dtsGetAirHeight;
        _plane flyInHeight [_restoreAltitude,true];
        _plane flyInHeightASL [_restoreAltitude,_restoreAltitude,_restoreAltitude];
        {_x doWatch objNull; _x doTarget objNull} forEach _strikeTeam;
        _plane setVehicleAmmo 1;

        //6. Cleanup after flyby
        private _distOld = _plane distance2D _target;
        private _distNew = _distOld;
        waitUntil {
            sleep 0.25;
            if (call _abortCondition) exitWith {true};
            _distNew = _plane distance2D _target;
            if (_distNew > _distOld) exitWith {true};
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
NWG_ACA_GetArtilleryVehicles = {
    // private _group = _this;
    private _result = (units _this) apply {vehicle _x};
    _result = _result arrayIntersect _result;//Remove duplicates
    _result select {alive _x && {_x call NWG_fnc_ocIsVehicle && {((getArtilleryAmmo [_x]) isNotEqualTo []) && {alive (gunner _x)}}}}
};

NWG_ACA_CanDoArtilleryStrike = {
    // private _group = _this;
    (_this call NWG_ACA_GetArtilleryVehicles) isNotEqualTo []
};

NWG_ACA_IsInRange = {
    params ["_artillery","_position"];
    _position inRangeOfArtillery [[_artillery],((getArtilleryAmmo [_artillery]) param [0,""])]
};

NWG_ACA_CanDoArtilleryStrikeOnTarget = {
    params ["_group","_target"];
    ((_group call NWG_ACA_GetArtilleryVehicles) findIf {[_x,(position _target)] call NWG_ACA_IsInRange}) != -1
};

NWG_ACA_SendArtilleryStrike = {
    params ["_group","_target",["_precise",false]];
    if !([_group,_target] call NWG_ACA_CanDoArtilleryStrikeOnTarget) exitWith {false};
    [_group,NWG_ACA_ArtilleryStrike,_target,_precise] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_ArtilleryStrike = {
    params ["_group","_target",["_precise",false]];

    //Get artillery
    private _targetPos = position _target;
    private _artillery = _group call NWG_ACA_GetArtilleryVehicles;
    if (_artillery isEqualTo []) exitWith {"NWG_ACA_ArtilleryStrike: No artillery units found" call NWG_fnc_logError};
    _artillery = _artillery select {[_x,_targetPos] call NWG_ACA_IsInRange};
    if (_artillery isEqualTo []) exitWith {"NWG_ACA_ArtilleryStrike: No artillery units in range" call NWG_fnc_logError};
    _artillery = selectRandom _artillery;//Select random artillery unit from the list of available units

    [
        _group,
        _artillery,
        _targetPos,
        (NWG_ACA_Settings get "ARTILLERY_STRIKE_WARNING_RADIUS"),
        (NWG_ACA_Settings get "ARTILLERY_STRIKE_WARNING_PAUSE"),
        (NWG_ACA_Settings get "ARTILLERY_STRIKE_RADIUS"),
        _precise,
        (time + (NWG_ACA_Settings get "ARTILLERY_STRIKE_TIMEOUT"))
    ] call NWG_ACA_ArtilleryStrikeCore
};

NWG_ACA_ArtilleryStrikeCore = {
    params ["_group","_artillery","_targetPos","_warningRadius","_pause","_fireRadius","_precise","_timeOut"];

    //Unfreeze (fix for dynamic simulation)
    {
        if (dynamicSimulationEnabled _x) then {_x enableDynamicSimulation false};
        if (_x isEqualType objNull && {!(simulationEnabled _x)}) then {_x enableSimulationGlobal true};
    } forEach ([_group,_artillery] + (crew _artillery));

    //Make courageous
    _group setBehaviourStrong "CARELESS";
    _group setCombatBehaviour "CARELESS";

    //Prepare exit conditions
    private _gunner = gunner _artillery;
    private _abortCondition = {!alive _artillery || {!alive _gunner || {time > _timeOut}}};
    private _onExit = {
        if (!isNull _group) then {
            _group setBehaviourStrong "AWARE";
            _group setCombatBehaviour "AWARE";
        };
        if (alive _artillery) then {
            _artillery setVehicleAmmo 1;
        };
    };
    if (call _abortCondition) exitWith _onExit;//Immediate check

    //Add Fired EH to check when artillery fired
    if (isNil {_artillery getVariable "NWG_artilleryFired"}) then {
        _artillery addEventHandler ["Fired",{
            // params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
            (_this#0) setVariable ["NWG_artilleryFired",true];
        }];
    };
    _artillery setVariable ["NWG_artilleryFired",false];//Set default value

    //Prepare fire sequence
    _group selectLeader _gunner;//Fix artillery stop mid-way (arma moment)
    private _ammoType = (getArtilleryAmmo [_artillery]) param [0,""];
    _artillery setVehicleAmmo 1;
    private _fire = {
        params ["_pos","_count"];
        _artillery doArtilleryFire [_pos,_ammoType,_count];
        waitUntil {sleep 0.1; (call _abortCondition  || {_artillery getVariable ["NWG_artilleryFired",false]})};
        waitUntil {sleep 0.1; (call _abortCondition) || {unitReady _gunner}};
    };

    //Warning strike
    private _warningPos = call {
        private _strikePoints = [_targetPos,_warningRadius,5] call NWG_fnc_dtsGenerateDotsCircle;
        _strikePoints = _strikePoints select {[_artillery,_x] call NWG_ACA_IsInRange};
        if (_strikePoints isEqualTo []) exitWith {_targetPos};//Fallback
        private _allPlayers = call NWG_fnc_getPlayersOrOccupiedVehicles;
        if (_allPlayers isEqualTo []) exitWith {selectRandom _strikePoints};//Fallback
        private ["_point","_minDist","_dist"];
        _strikePoints = _strikePoints apply {
            _point = _x;
            _minDist = 100000;
            {
                _dist = _point distance _x;
                if (_dist < _minDist) then {_minDist = _dist};
            } forEach _allPlayers;
            [_minDist,_point]
        };
        _strikePoints sort false;
        ((_strikePoints#0)#1)
    };
    [_warningPos,1] call _fire;
    if (call _abortCondition) exitWith _onExit;
    _artillery setVariable ["NWG_artilleryFired",false];//Reset
    _artillery setVehicleAmmo 1;

    //Pause
    sleep _pause;
    if (call _abortCondition) exitWith _onExit;

    //Fire for effect (vanilla system: faster and more precise, but less realistic)
    if (_precise) exitWith {
        private _count = (selectRandom [3,4,5,6]);//Count was taken empirically
        [_targetPos,_count] call _fire;
        call _onExit;
    };

    //Fire for effect (custom system: slower and less precise, but more realistic)
    private _count = (selectRandom [6,8,12]);//Count was taken empirically
    private _strikePoints = [_targetPos,_fireRadius,12] call NWG_fnc_dtsGenerateDotsCloud;
    _strikePoints = _strikePoints select {[_artillery,_x] call NWG_ACA_IsInRange};
    if ((count _strikePoints) > _count) then {_strikePoints resize _count};
    //forEach strikePoint
    {
        [_x,1] call _fire;
        if (call _abortCondition) exitWith {};
        _artillery setVariable ["NWG_artilleryFired",false];//Reset
    } forEach _strikePoints;

    call _onExit;
};

//================================================================================================================
//Mortar strike (partially re-uses artillery strike logic)
NWG_ACA_GetMortars = {
    // private _group = _this;
    private _result = (units _this) apply {vehicle _x};
    _result = _result arrayIntersect _result;//Remove duplicates
    _result select {alive _x && {_x call NWG_fnc_ocIsTurret && {(getArtilleryAmmo [_x]) isNotEqualTo []}}}
};

NWG_ACA_CanDoMortarStrike = {
    // private _group = _this;
    (_this call NWG_ACA_GetMortars) isNotEqualTo []
};

NWG_ACA_CanDoMortarStrikeOnTarget = {
    params ["_group","_target"];
    ((_group call NWG_ACA_GetMortars) findIf {[_x,(position _target)] call NWG_ACA_IsInRange}) != -1
};

NWG_ACA_SendMortarStrike = {
    params ["_group","_target",["_precise",false]];
    if !([_group,_target] call NWG_ACA_CanDoMortarStrikeOnTarget) exitWith {false};
    [_group,NWG_ACA_MortarStrike,_target,_precise] call NWG_ACA_StartAdvancedLogic;
    true
};

NWG_ACA_MortarStrike = {
    params ["_group","_target",["_precise",false]];

    //Get artillery
    private _targetPos = position _target;
    private _mortar = _group call NWG_ACA_GetMortars;
    if (_mortar isEqualTo []) exitWith {"NWG_ACA_MortarStrike: No mortar units found" call NWG_fnc_logError};
    _mortar = _mortar select {[_x,_targetPos] call NWG_ACA_IsInRange};
    if (_mortar isEqualTo []) exitWith {"NWG_ACA_MortarStrike: No mortar units in range" call NWG_fnc_logError};
    _mortar = selectRandom _mortar;//Select random mortar unit from the list of available units

    [
        _group,
        _mortar,
        _targetPos,
        (NWG_ACA_Settings get "MORTAR_STRIKE_WARNING_RADIUS"),
        (NWG_ACA_Settings get "MORTAR_STRIKE_WARNING_PAUSE"),
        (NWG_ACA_Settings get "MORTAR_STRIKE_RADIUS"),
        _precise,
        (time + (NWG_ACA_Settings get "MORTAR_STRIKE_TIMEOUT"))
    ] call NWG_ACA_ArtilleryStrikeCore
};

//================================================================================================================
//Veh demolition (reuses utils from airstrike)
NWG_ACA_CanDoVehDemolition = {
    // private _group = _this;
    private _veh = vehicle (leader _group);
    if !(_veh isKindOf "Tank"  || {_veh isKindOf "Wheeled_APC_F"}) exitWith {false};
    if !((alive (gunner _veh)) && {alive (driver _veh)}) exitWith {false};
    if ((_veh call NWG_ACA_GetDataForVehicleForceFire) isEqualTo []) exitWith {false};
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

    private _timeOut = time + (NWG_ACA_Settings get "INF_STORM_TIMEOUT");
    private _abortCondition = {({alive _x} count (units _group)) < 1 || {time > _timeOut}};
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

    private _timeOut = time + 180;
    private _abortCondition = {!alive _veh || {({alive _x} count _crew) < 1 || {time > _timeOut}}};
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