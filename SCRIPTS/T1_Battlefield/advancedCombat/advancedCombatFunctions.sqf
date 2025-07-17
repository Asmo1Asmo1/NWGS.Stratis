/*
    This module implements the following logic:
    - Airstrike
    - Artillery/Mortar strike
    - Veh building demolition
    - Inf building storm
    - Veh vehicle repair
*/

//=============================================================================
/*General*/
//Check if group is in process of doing something
//params: _group - group to check
//returns: boolean
NWG_fnc_acIsGroupBusy = {
    // private _group = _this;
    _this call NWG_ACA_IsDoingAdvancedLogic
};

//=============================================================================
/*Airstrike*/

//Check if can do airstrike
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoAirstrike = {
    // private _group = _this;
    _this call NWG_ACA_CanDoAirstrike
};

//Send group to airstrike
//params:
// _group - group to send
// _target - target object
// _numberOfStrikes - number of strikes to make
//returns:
// boolean - true if successful, false in case of error
NWG_fnc_acSendToAirstrike = {
    // params ["_group","_target",["_numberOfStrikes",1]];
    _this call NWG_ACA_SendToAirstrike
};

//=============================================================================
/*Artillery strike*/

//Check if can do artillery strike
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoArtilleryStrike = {
    // private _group = _this;
    _this call NWG_ACA_CanDoArtilleryStrike
};

//Check if this group can do artillery strike on this target
//params:
// _group - group to check
// _target - target object
//returns:
// boolean
NWG_fnc_acCanDoArtilleryStrikeOnTarget = {
    // params ["_group","_target"];
    _this call NWG_ACA_CanDoArtilleryStrikeOnTarget
};

//Send artillery strike by group
//params:
// _group - group to send
// _target - target object
//returns:
// boolean - true if successful, false in case of error or if target is out of range
NWG_fnc_acSendArtilleryStrike = {
    // params ["_group","_target"];
    _this call NWG_ACA_SendArtilleryStrike
};

//=============================================================================
/*Veh demolition*/

//Check if can do vehicled demolition of a building
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoVehDemolition = {
    // private _group = _this;
    _this call NWG_ACA_CanDoVehDemolition
};

//Send group to demolish a building
//params:
// _group - group to send
// _target - target building
//returns:
// boolean - true if successful, false in case of error (e.g. target is not a building)
NWG_fnc_acSendToVehDemolition = {
    // params ["_group","_target"];
    _this call NWG_ACA_SendToVehDemolition
};

//=============================================================================
/*Inf building storm*/

//Check if can do infantry building storm
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoInfBuildingStorm = {
    // private _group = _this;
    _this call NWG_ACA_CanDoInfBuildingStorm
};

//Send group to storm a building
//params:
// _group - group to send
// _target - target building
//returns:
// boolean - true if successful, false in case of error (e.g. target is not a building)
NWG_fnc_acSendToInfBuildingStorm = {
    // params ["_group","_target"];
    _this call NWG_ACA_SendToInfBuildingStorm
};

//=============================================================================
/*Veh vehicle repair*/

//Check if can do vehicle repair
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoVehRepair = {
    // private _group = _this;
    (_this call NWG_ACA_CanDoVehRepair) && {_this call NWG_ACA_NeedsRepair}
};

//Send group to repair their vehicle
//params:
// _group - group to send
//returns:
// boolean - true if successful, false in case of error (e.g. group has no vehicle or can't do repair)
NWG_fnc_acSendToVehRepair = {
    // private _group = _this;
    _this call NWG_ACA_SendToVehRepair
};

//=============================================================================
/*Inf vehicle capture*/

//Check if can do inf vehicle capture
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoInfVehCapture = {
    // private _group = _this;
    _this call NWG_ACA_CanDoInfVehCapture
};


//Send group to capture an enemy vehicle
//params:
// _group - group to send
//returns:
// boolean - true if successful, false in case of error (e.g. group has no vehicle or can't do capture)
NWG_fnc_acSendToInfVehCapture = {
    // private _group = _this;
    _this call NWG_ACA_SendToInfVehCapture
};

//=============================================================================
/*Veh flee*/

//Check if can do veh flee
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_acCanDoVehFlee = {
    // private _group = _this;
    _this call NWG_ACA_CanDoVehFlee
};

//Send group to flee
//params:
// _group - group to send
//returns:
// boolean - true if successful, false in case of error (e.g. group has no vehicle or can't do flee)
NWG_fnc_acSendToVehFlee = {
    // private _group = _this;
    _this call NWG_ACA_SendToVehFlee
};

//=============================================================================
/*Targeting utils*/
//Returns target type of the object
//note: send (vehicle _object) as an argument
//params: _target - target object
//returns: TARGET_TYPE_* (see advancedCombatDefines.h) ("INF","VEH","ARM","AIR","BOAT") (will return "VEH" by default if target is not recognized)
NWG_fnc_acGetTargetType = {
    // private _target = _this;
    _this call NWG_ACU_GetTargetType
};

//Returns building the target is in
//params: _target - target object
//returns: building object or objNull if target is not in a building (outside or inside not a building but something else)
NWG_fnc_acGetBuildingTargetIn = {
    // private _target = _this;
    _this call NWG_ACU_GetBuildingTargetIn
};

//Checks if the group is already performing an action
//params: _group - group to check
//returns: boolean
NWG_fnc_acIsGroupBusy = {
    // private _group = _this;
    _this call NWG_ACA_IsDoingAdvancedLogic
};

//=============================================================================
/*Statistics*/
//Print statistics to the RPT log
NWG_fnc_acPrintStatistics = {
    call NWG_ACA_PrintStatistics;
    call NWG_ACP_PrintStatistics;
};