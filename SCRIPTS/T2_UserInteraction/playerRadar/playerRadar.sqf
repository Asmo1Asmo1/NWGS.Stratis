/*
    Annotation:
    This module searches for objects around the player
    Other modules are dependant on this one
*/

//================================================================================================================
//================================================================================================================
//Settings
/*This module drops fps a little so instead of regular approach, we will optimize the shit out of it*/
#define RADAR_RADIUS 4
#define RADAR_HEIGHT_DELTA 3
#define RADAR_FORWARD_ANGLE 15

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["Draw3D",{call NWG_RADAR_OnEachFrame}];
};

//================================================================================================================
//================================================================================================================
//Logic
NWG_RADAR_unitFront = objNull;
NWG_RADAR_vehcFront = objNull;
NWG_RADAR_vehcArond = objNull;

NWG_RADAR_OnEachFrame = {
    if (isNull player || {!alive player || {(vehicle player) isNotEqualTo player}}) exitWith {
        NWG_RADAR_unitFront = objNull;
        NWG_RADAR_vehcFront = objNull;
        NWG_RADAR_vehcArond = objNull;
    };

    //Prepare
    private _playerAltitude = (getPosASL player)#2;
    private _isOnSameHeight = {
        // private _object = _this;
        (abs (((getPosASL _this)#2) - _playerAltitude)) < RADAR_HEIGHT_DELTA
    };
    private _isInFront = {
        // private _object = _this;
        private _relDir = player getRelDir _this;
        (_relDir < RADAR_FORWARD_ANGLE || {_relDir > (360 - RADAR_FORWARD_ANGLE)})
    };

    //Search for units
    private _units = (player nearEntities [["Man"],RADAR_RADIUS]) select {
        alive _x && {
        _x isNotEqualTo player && {
        isNull (attachedTo _x) && {
        isAwake _x && {
        _x call _isOnSameHeight && {
        _x call _isInFront}}}}}
    };
    switch (count _units) do {
        case 0: {NWG_RADAR_unitFront = objNull};
        case 1: {NWG_RADAR_unitFront = _units#0};
        default {
            //Several units found - select the closest one
            _units = _units apply {[(_x distance player),_x]};
            _units sort true;
            NWG_RADAR_unitFront = (_units#0)#1;
        };
    };

    //Search for vehicles
    private _vehicles = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],RADAR_RADIUS] select {
        alive _x && {
        _x call _isOnSameHeight}
    };
    switch (count _vehicles) do {
        case 0: {
            NWG_RADAR_vehcFront = objNull;
            NWG_RADAR_vehcArond = objNull;
        };
        case 1: {
            private _veh = _vehicles#0;
            if (_veh call _isInFront)
                then {NWG_RADAR_vehcFront = _veh; NWG_RADAR_vehcArond = objNull}
                else {NWG_RADAR_vehcFront = objNull; NWG_RADAR_vehcArond = _veh};
        };
        default {
            //Several vehicles found - select the closest one
            _vehicles = _vehicles apply {[(_x distance player),_x]};
            _vehicles sort true;
            private _veh = (_vehicles#0)#1;
            if (_veh call _isInFront)
                then {NWG_RADAR_vehcFront = _veh; NWG_RADAR_vehcArond = objNull}
                else {NWG_RADAR_vehcFront = objNull; NWG_RADAR_vehcArond = _veh};
        };
    };
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;