//================================================================================================================
//================================================================================================================
//Additional code helpers

// Attaches a turret to a vehicle
//params:
// _group - group to attach the turret to
// _vehicle - vehicle to attach the turret to
// _NaN - not used
// _turretClassname - classname of the turret to attach
// _attachToValues - array of values to properly attach (use NWG_DSPAWN_Dev_AC_GetAttachToValues to get this)
// _gunnerClassname - classname of the gunner to attach to the turret (optional, will create a default turret's gunner if not provided)
NWG_fnc_dsAcHelperAttachTurret = {
    //params ["_group","_vehicle","_NaN","_turretClassname","_attachToValues",["_gunnerClassname","DEFAULT"]];
    _this call NWG_DSPAWN_AC_AttachTurret
};