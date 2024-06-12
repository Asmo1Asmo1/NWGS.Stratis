//=============================================================================
/*Server->Server*/

//Populates the given trigger with the given number of groups of the given faction
//params:
// _trigger - trigger to populate
// _groupsCount - number of groups to populate
// _faction - faction of the groups
// _filter - array of groups to filter out (optional)
// _side - side of the groups (optional, default: west)
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsPopulateTrigger = {
    // params ["_trigger","_groupsCount","_faction",["_filter",[]],["_side",west]];
    _this call NWG_DSPAWN_TRIGGER_PopulateTrigger
};

//Send reinforcements to the given position
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _attackPos - position to send the reinforcements to
// _groupsCount - number of groups to send
// _faction - faction of the reinforcements
// _filter - array of groups to filter out (optional)
// _side - side of the reinforcements (optional, default: west)
// _spawnMap - array positions to spawn the reinforcements on (optional, default: [nil,nil,nil,nil] for [INF,VEH,BOAT,AIR])
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsSendReinforcements = {
    // params ["_attackPos","_groupsCount","_faction",["_filter",[]],["_side",west],["_spawnMap",[nil,nil,nil,nil]]];
    _this call NWG_DSPAWN_REINF_SendReinforcements
};

//Checks if the given group is spawned by 'dspawn' subsystem
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_dsIsDspawnGroup = {
    // private _group = _this;
    _this getVariable ["NWG_DSPAWN_ownership",false]
};

// Returns the group's tags
//params:
// _group - group to get the tags from
//returns:
// array of tags if found, empty array otherwise
NWG_fnc_dsGetTags = {
    // private _group = _this;
    _this call NWG_DSPAWN_TAGs_GetTags
};

//Adopts the given group assigning it dspawn's tags, allowing it to be controlled by dspawn
//params:
// _group - group to adopt
NWG_fnc_dsAdoptGroup = {
    // private _group = _this;
    private _tags = [_this] call NWG_DSPAWN_TAGs_GenerateTags;
    [_this,_tags] call NWG_DSPAWN_TAGs_SetTags;
    _this setVariable ["NWG_DSPAWN_ownership",true];
};

//Sends the group to attack the given position
//params:
// _group - group to send
// _attackPos - position to attack
NWG_fnc_dsSendToAttack = {
    // params ["_group","_attackPos"];
    _this call NWG_DSPAWN_SendToAttack
};

/*Exposure of inner utilities (sorry, not sorry)*/

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

//Attaches a turret to a vehicle
//params:
// _spawnResult - [_group,_vehicle,_units] array - _this argument of additional code
// _turretClassname - classname of the turret to attach
// _attachToValues - array of values to properly attach (use NWG_DSPAWN_Dev_AC_GetAttachToValues to get this)
// _gunnerClassname - classname of the gunner to attach to the turret (optional, will create a default turret's gunner if not provided)
NWG_fnc_dsAcHelperAttachTurret = {
    //params ["_spawnResult","_turretClassname","_attachToValues",["_gunnerClassname","DEFAULT"]];
    _this spawn NWG_DSPAWN_AC_AttachTurret
};

//Dresses up units randomly from provided loadouts
//params:
// _spawnResult - [_group,_vehicle,_units] array - _this argument of additional code
// _loadouts - array of loadouts to choose from
NWG_fnc_dsAcHelperDressUnits = {
    //params ["_spawnResult","_loadouts"];
    _this call NWG_DSPAWN_AC_DressUnits
};