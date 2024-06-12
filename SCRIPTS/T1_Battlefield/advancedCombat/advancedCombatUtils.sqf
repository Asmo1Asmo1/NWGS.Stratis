#include "..\..\globalDefines.h"
#include "advancedCombatDefines.h"
/*
    This module implements the following logic:
    - Get the type of vehicle
    - Get the building where unit is
    note: It is used by other systems to get the arguments for advanced combat active methods
*/
NWG_ACU_GetTargetType = {
    // private _target = _this;
    switch (true) do {
        case (_this isKindOf "Man"): {TARGET_TYPE_INF};
        case (_this isKindOf "StaticWeapon"): {TARGET_TYPE_INF};//Static weapons are not actually infantry, but they are not vehicles either
        case (_this isKindOf "Air"): {
            if (_this isKindOf "ParachuteBase")/*Parachutes give false positives for "Air"*/
                then {TARGET_TYPE_INF}
                else {TARGET_TYPE_AIR}
        };
        case (_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}) : {TARGET_TYPE_ARM};
        case (_this isKindOf "Ship"): {TARGET_TYPE_BOAT};
        default {TARGET_TYPE_VEH};
    }
};

NWG_ACU_GetBuildingTargetIn = {
    // private _target = _this;
    private _raycastFrom = getPosWorld _this;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _raycast = (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_this,objNull,true,-1,"FIRE","VIEW",true]));
    private _i = _raycast findIf {_x isEqualType objNull && {!isNull _x && {_x call NWG_fnc_ocIsBuilding}}};
    //return
    if (_i == -1) then {objNull} else {_raycast select _i};
};