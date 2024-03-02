//=============================================================================
/*Server->Server*/

//Send reinforcements to the given position
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _attackPos - position to send the reinforcements to
// _groupsCount - number of groups to send
// _faction - faction of the reinforcements
// _filter - array of groups to filter out (optional)
// _side - side of the reinforcements (optional, default: west)
NWG_fnc_dsSendReinforcements = {
    // params ["_attackPos","_groupsCount","_faction",["_filter",[]],["_side",west]];
    _this call NWG_DSPAWN_REINF_SendReinforcements
};

// Returns the group's tags, generating them if they don't exist
//params:
// _group - group to get the tags from
//returns:
// array of tags
NWG_fnc_dsGetOrGenerateTags = {
    // private _group = _this;
    private _tags = _this call NWG_DSPAWN_TAGs_GetTags;
    if ((count _tags) == 0) then {
        _tags = [_this] call NWG_DSPAWN_TAGs_GenerateTags;
        [_this,_tags] call NWG_DSPAWN_TAGs_SetTags;
    };

    //return
    _tags
};

//Sends the group to attack the given position
//params:
// _group - group to send
// _attackPos - position to attack
NWG_fnc_dsSendToAttack = {
    // params ["_group","_attackPos"];
    _this call NWG_DSPAWN_SendToAttack
};

//Inner utility to define the weapon tag for the given object
//params:
// _object - object to define the weapon tag for (vehicle or unit)
//returns:
// weapon tag "AA", "AT", "AA|AT" or "REG"
NWG_fnc_dsDefineWeaponTagForObject = {
    // private _object = _this;
    _this call NWG_DSPAWN_TAGs_DefineWeaponTagForObject
};

//=============================================================================
/*Additional code helpers*/

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