/*
    Annotation:
    This module searches for objects around the player
    Other modules are dependant on this one
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_RADAR_Settings = createHashMapFromArray [
    ["RADIUS",4],//Radius where to search for units/vehicles
    ["HEIGHT_DELTA",3],//If unit/vehicle is higer/lower than N meters - ignore
    ["FORWARD_ANGLE",30],//Angle defining if object is 'forward' to player

    ["",0]
];

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
        (abs (((getPosASL _x)#2) - _playerAltitude)) < (NWG_RADAR_Settings get "HEIGHT_DELTA")
    };
    private _isInFront = {
        // private _object = _this;
        private _relDir = player getRelDir _this;
        private _frontAngle = NWG_RADAR_Settings get "FORWARD_ANGLE";
        (_relDir < (_frontAngle / 2) || {_relDir > (360 - (_frontAngle / 2))})
    };

    //Search for units
    private _units = (player nearEntities [["Man"],(NWG_RADAR_Settings get "RADIUS")]) select {
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
    _units resize 0;//Clear

    //Search for vehicles
    private _vehicles = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],(NWG_RADAR_Settings get "RADIUS")] select {
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
    _vehicles resize 0;//Clear
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;