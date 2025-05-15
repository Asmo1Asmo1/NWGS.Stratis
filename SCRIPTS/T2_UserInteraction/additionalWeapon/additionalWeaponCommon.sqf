#include "additionalWeaponDefines.h"

//================================================================================================================
//Holder data logic
NWG_AW_GetHolderData = {
    // private _unit = _this;
    _this getVariable ["NWG_AW_HolderLoadout",[]]
};

NWG_AW_SetHolderData = {
    params ["_unit","_data"];
    private _publicFlag = if (isServer) then {[(owner _unit),2]} else {[clientOwner,2]};
    _unit setVariable ["NWG_AW_HolderLoadout",_data,_publicFlag];
};

//================================================================================================================
//Holder object logic
NWG_AW_CreateHolderObject = {
    params ["_unit","_config"];
    if (_config isEqualTo []) exitWith {false};
    if (DELETE_HOLDER_IN_VEHCILE && {(vehicle _unit) isNotEqualTo _unit}) exitWith {false};

    private _holder = createVehicle ["Library_WeaponHolder", _unit, [], 0, "CAN_COLLIDE"];
    _holder attachTo [_unit, [0,0.6,-0.75], "Spine3", true];
    _holder setVectorDirAndUp [[0, 1, 1], [0, 0.5, 0]];
    _holder addWeaponWithAttachmentsCargoGlobal [_config,1];
    _holder setDamage 1;//Prevent taking items out of the holder
    _holder lockInventory true;

    //return
    _holder
};

NWG_AW_DeleteHolderObject = {
    private _unit = _this;

    private _holder = ((attachedObjects _unit) select {_x isKindOf "Library_WeaponHolder"}) param [0,objNull];
    if (isNull _holder) exitWith {false};

    detach _holder;
    deleteVehicle _holder;
    true
};