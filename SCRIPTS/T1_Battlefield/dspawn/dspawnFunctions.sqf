//=============================================================================
/*Server->Server*/

//Configures dspawn for all future 'xxxCfg' functions calls
//params:
// _side - side of the dspawn (east, west, independent)
// _faction - faction of the dspawn (string)
// _reinfMap - reinfMap of the dspawn (array of arrays) (get the from 'NWG_fnc_dtsMarkupReinforcement')
//returns:
// true if success, false otherwise
NWG_fnc_dsConfigure = {
    // params ["_side","_faction","_reinfMap"];
    _this call NWG_DSPAWN_Configure
};

//Populates the trigger
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _trigger - trigger to populate
// _groupsCount - number of groups to populate
// _faction - faction of the groups
// _filter - (optional, default: []) array to filter catalogue by (_filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];)
// _side - (optional, default: west) side of the groups (also supports argument of group to spawn into, but it is not recommended)
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsPopulateTrigger = {
    // params ["_trigger","_groupsCount","_faction",["_filter",[]],["_side",west]];
    _this call NWG_DSPAWN_TRIGGER_PopulateTrigger
};

//Populates the trigger with some arguments already set (side, faction, reinfMap are expected to be set by 'NWG_fnc_dsConfigure')
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _trigger - trigger to populate
// _groupsCount - number of groups to populate
// _filter - (optional, default: []) array to filter catalogue by (_filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];)
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsPopulateTriggerCfg = {
    // params ["_trigger","_groupsCount",["_filter",[]]];
    _this call NWG_DSPAWN_TRIGGER_PopulateTriggerCfg
};

//Sends reinforcements to the given position
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _attackPos - position to send the reinforcements to
// _groupsCount - number of groups to send
// _faction - faction of the reinforcements
// _filter - (optional, default: []) array to filter catalogue by (_filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];)
// _side - (optional, default: west) side of the reinforcements (also supports argument of group to spawn into, but it is not recommended)
// _spawnMap - (optional, default: [nil,nil,nil,nil] for [INF,VEH,BOAT,AIR]) array positions to spawn the reinforcements on, if left empty, script will calculate them automatically
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsSendReinforcements = {
    // params ["_attackPos","_groupsCount","_faction",["_filter",[]],["_side",west],["_spawnMap",[nil,nil,nil,nil]]];
    _this call NWG_DSPAWN_REINF_SendReinforcements
};

//Sends reinforcements to the given position with some arguments already set (side, faction, reinfMap are expected to be set by 'NWG_fnc_dsConfigure')
//WARNING: This function is quite heavy. It is advised to use 'spawn' instead of 'call'
//params:
// _attackPos - position to send the reinforcements to
// _groupsCount - number of groups to send
// _filter - (optional, default: []) array to filter catalogue by (_filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];)
//returns:
// number of groups actually spawned OR false in case of error
NWG_fnc_dsSendReinforcementsCfg = {
    // params ["_attackPos","_groupsCount",["_filter",[]]];
    _this call NWG_DSPAWN_REINF_SendReinforcementsCfg
};

//Spawns a single group around the given position without setting any behavior
//params:
// _pos - position to spawn the group around
// _radius - radius to spawn the group
// _faction - catalogue faction to choose the group from
// _filter - (optional, default: []) array to filter catalogue by (_filter params [["_tagsWhiteList",[]],["_tagsBlackList",[]],["_tierWhiteList",[]]];)
// _membership - (optional, default: west) side or group to spawn into
// _skipFinalize - (optional, default: false) if true, will skip: additional code, dspawn tags, dspawn ownership, group behavior and event propagation
//returns:
// [_group,_vehicle,_units] or false in case of error
NWG_fnc_dsSpawnSingleGroup = {
    // params ["_pos","_radius","_faction",["_filter",[]],["_membership",west],["_skipFinalize",false]];
    _this call NWG_DSPAWN_SpawnSingleGroup
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

//Sends the group to destroy given object
//params:
// _group - group to send
// _target - object to destroy
NWG_fnc_dsSendToDestroy = {
    // params ["_group","_target"];
    _this call NWG_DSPAWN_SendToDestroy
};

//Imitates paradrop of the given object/vehicle
//note: while not mandatory, it is recommended to hide the object/vehicle before calling this function by either 'NWG_fnc_spwnHideObject' or '_deferReveal' argument of spawning functions
//params:
// _object - object/vehicle to imitate paradrop for
// _paradropBy - classname of the vehicle to use for paradrop
//returns:
// true if success, false otherwise
NWG_fnc_dsImitateParadrop = {
    // params ["_object","_paradropBy"];
    _this call NWG_DSPAWN_ImitateParadrop
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