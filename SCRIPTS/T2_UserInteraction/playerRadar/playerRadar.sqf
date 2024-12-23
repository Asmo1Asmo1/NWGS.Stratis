/*
    Annotation:
    This module searches for objects around the player
    Other modules are dependant on this one
*/

//================================================================================================================
//================================================================================================================
//Settings
/*This module is affecting fps, so instead of regular approach, we will optimize the shit out of it*/
#define RADAR_RADIUS_UNIT 3
#define RADAR_RADIUS_VEH 4
#define RADAR_HEIGHT_DELTA_UNIT 2
#define RADAR_HEIGHT_DELTA_VEH 3
#define RADAR_FORWARD_ANGLE 20

#define IS_SAME_HEIGHT_UNIT(ARG) ((abs (((getPosASL ARG) select 2) - ((getPosASL player) select 2))) < RADAR_HEIGHT_DELTA_UNIT)
#define IS_SAME_HEIGHT_VEH(ARG) ((abs (((getPosASL ARG) select 2) - ((getPosASL player) select 2))) < RADAR_HEIGHT_DELTA_VEH)
#define IS_IN_FRONT(ARG) ((player getRelDir ARG) < RADAR_FORWARD_ANGLE || {(player getRelDir ARG) > (360 - RADAR_FORWARD_ANGLE)})

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["Draw3D",{call NWG_RADAR_OnEachFrame}];
};

//================================================================================================================
//================================================================================================================
//Logic
/*Dedmen — 03/06/2024 9:53 PM: objNull is not a permanently-allocated value every time you call it, a new one is created*/
NWG_RADAR_objNull = objNull;
NWG_RADAR_unitFront = NWG_RADAR_objNull;
NWG_RADAR_vehcFront = NWG_RADAR_objNull;
NWG_RADAR_vehcArond = NWG_RADAR_objNull;

NWG_RADAR_OnEachFrame = {
    if (isNull player || {!alive player || {!isNull objectParent player}}) exitWith {
        NWG_RADAR_unitFront = NWG_RADAR_objNull;
        NWG_RADAR_vehcFront = NWG_RADAR_objNull;
        NWG_RADAR_vehcArond = NWG_RADAR_objNull;
    };

    //Search for units
    private _units = (player nearEntities [["Man"],RADAR_RADIUS_UNIT]) select {
        alive _x && {
        _x isNotEqualTo player && {
        IS_SAME_HEIGHT_UNIT(_x) && {
        IS_IN_FRONT(_x) }}}
    };
    switch (count _units) do {
        case 0: {NWG_RADAR_unitFront = NWG_RADAR_objNull};
        case 1: {NWG_RADAR_unitFront = _units#0};
        default {
            //Several units found - select the closest one
            _units = _units apply {[(_x distance player),_x]};
            _units sort true;
            NWG_RADAR_unitFront = (_units#0)#1;
        };
    };

    //Search for vehicles
    private _vehicles = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],RADAR_RADIUS_VEH] select {
        alive _x && {
        IS_SAME_HEIGHT_VEH(_x)}
    };
    switch (count _vehicles) do {
        case 0: {
            NWG_RADAR_vehcFront = NWG_RADAR_objNull;
            NWG_RADAR_vehcArond = NWG_RADAR_objNull;
        };
        case 1: {
            private _veh = _vehicles#0;
            if (IS_IN_FRONT(_veh))
                then {NWG_RADAR_vehcFront = _veh; NWG_RADAR_vehcArond = NWG_RADAR_objNull}
                else {NWG_RADAR_vehcFront = NWG_RADAR_objNull; NWG_RADAR_vehcArond = _veh};
        };
        default {
            //Several vehicles found - select the closest one
            _vehicles = _vehicles apply {[(_x distance player),_x]};
            _vehicles sort true;
            private _veh = (_vehicles#0)#1;
            if (IS_IN_FRONT(_veh))
                then {NWG_RADAR_vehcFront = _veh; NWG_RADAR_vehcArond = NWG_RADAR_objNull}
                else {NWG_RADAR_vehcFront = NWG_RADAR_objNull; NWG_RADAR_vehcArond = _veh};
        };
    };
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;