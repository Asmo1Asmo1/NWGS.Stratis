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
#define RADAR_RADIUS_ANIM 3
#define RADAR_RADIUS_VEHC 4
#define RADAR_HEIGHT_DELTA_UNIT 2
#define RADAR_HEIGHT_DELTA_ANIM 2
#define RADAR_HEIGHT_DELTA_VEHC 3
#define RADAR_FORWARD_ANGLE_UNIT 25
#define RADAR_FORWARD_ANGLE_ANIM 25
#define RADAR_FORWARD_ANGLE_VEHC 35

#define IS_SAME_HEIGHT_UNIT(ARG) ((abs (((getPosASL ARG) select 2) - ((getPosASL player) select 2))) < RADAR_HEIGHT_DELTA_UNIT)
#define IS_SAME_HEIGHT_ANIM(ARG) ((abs (((getPosASL ARG) select 2) - ((getPosASL player) select 2))) < RADAR_HEIGHT_DELTA_ANIM)
#define IS_SAME_HEIGHT_VEHC(ARG) ((abs (((getPosASL ARG) select 2) - ((getPosASL player) select 2))) < RADAR_HEIGHT_DELTA_VEHC)
#define IS_IN_FRONT_UNIT(ARG) ((player getRelDir ARG) < RADAR_FORWARD_ANGLE_UNIT || {(player getRelDir ARG) > (360 - RADAR_FORWARD_ANGLE_UNIT)})
#define IS_IN_FRONT_ANIM(ARG) ((player getRelDir ARG) < RADAR_FORWARD_ANGLE_ANIM || {(player getRelDir ARG) > (360 - RADAR_FORWARD_ANGLE_ANIM)})
#define IS_IN_FRONT_VEHC(ARG) ((player getRelDir ARG) < RADAR_FORWARD_ANGLE_VEHC || {(player getRelDir ARG) > (360 - RADAR_FORWARD_ANGLE_VEHC)})

//================================================================================================================
//================================================================================================================
//Fields
/*Dedmen — 03/06/2024: objNull is not a permanently-allocated value every time you call it, a new one is created*/
NWG_RADAR_objNull = objNull;
NWG_RADAR_unitFront = NWG_RADAR_objNull;
NWG_RADAR_animFront = NWG_RADAR_objNull;
NWG_RADAR_vehcFront = NWG_RADAR_objNull;
NWG_RADAR_vehcArond = NWG_RADAR_objNull;

NWG_RADAR_unitArgs = [["Man"],RADAR_RADIUS_UNIT];
NWG_RADAR_vehcArgs = [["Car","Tank","Helicopter","Plane","Ship"],RADAR_RADIUS_VEHC];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["Draw3D",{call NWG_RADAR_OnEachFrame}];
};

//================================================================================================================
//================================================================================================================
//Logic
NWG_RADAR_OnEachFrame = {
    if (isNull player || {!alive player || {!isNull objectParent player}}) exitWith {
        NWG_RADAR_unitFront = NWG_RADAR_objNull;
        NWG_RADAR_animFront = NWG_RADAR_objNull;
        NWG_RADAR_vehcFront = NWG_RADAR_objNull;
        NWG_RADAR_vehcArond = NWG_RADAR_objNull;
    };

    //Search for units /*nearEntities - will filter out dead units so no need to check for alive*/
    private _entities = player nearEntities NWG_RADAR_unitArgs;
    private _i = _entities findIf {
        _x isNotEqualTo player && {
        IS_SAME_HEIGHT_UNIT(_x) && {
        IS_IN_FRONT_UNIT(_x) }}
    };
    NWG_RADAR_unitFront = if (_i != -1)
        then {_entities#_i}
        else {NWG_RADAR_objNull};

    //Search for animals /*nearestObjects - because we do need !alive animals for hunting*/
    _entities = nearestObjects [player,["Animal"],RADAR_RADIUS_ANIM];
    _i = _entities findIf {
        IS_SAME_HEIGHT_ANIM(_x) && {
        IS_IN_FRONT_ANIM(_x) }
    };
    NWG_RADAR_animFront = if (_i != -1)
        then {_entities#_i}
        else {NWG_RADAR_objNull};

    //Search for vehicles /*nearEntities - will filter out dead vehicles so no need to check for alive*/
    _entities = player nearEntities NWG_RADAR_vehcArgs;
    _i = _entities findIf {
        IS_SAME_HEIGHT_VEHC(_x)
    };
    if (_i != -1) then {
        if (IS_IN_FRONT_VEHC(_entities#_i)) then {
            NWG_RADAR_vehcFront = _entities#_i;
            NWG_RADAR_vehcArond = NWG_RADAR_objNull;
        } else {
            NWG_RADAR_vehcFront = NWG_RADAR_objNull;
            NWG_RADAR_vehcArond = _entities#_i;
        };
    } else {
        NWG_RADAR_vehcFront = NWG_RADAR_objNull;
        NWG_RADAR_vehcArond = NWG_RADAR_objNull;
    };
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;