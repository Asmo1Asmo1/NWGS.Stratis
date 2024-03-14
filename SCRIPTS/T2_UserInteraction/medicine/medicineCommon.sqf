#include "medicineDefines.h"
/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

//================================================================================================================
//================================================================================================================
//State management
NWG_MED_COM_IsWounded = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_wounded",false]
};
NWG_MED_COM_MarkWounded = {
    params ["_unit","_wounded"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    if ((_unit getVariable ["NWG_MED_CLI_wounded",-1]) isEqualTo _wounded) exitWith {};//Update only if needed
    _unit setVariable ["NWG_MED_CLI_wounded",_wounded,true];
};

NWG_MED_COM_GetSubstate = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {SUBSTATE_NONE};
    _this getVariable ["NWG_MED_CLI_substate",SUBSTATE_NONE]
};
NWG_MED_COM_SetSubstate = {
    params ["_unit","_substate"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    if ((_unit getVariable ["NWG_MED_CLI_substate",-1]) isEqualTo _substate) exitWith {};//Update only if needed
    _unit setVariable ["NWG_MED_CLI_substate",_substate,true];
};
NWG_MED_COM_CalculateSubstate = {
    // private _unit = _this;

    /*Check cases that we can get from the engine*/
    if (isNull _this || {!alive _this})     exitWith {SUBSTATE_NONE};//Invalid unit
    if ((vehicle _this) isNotEqualTo _this) exitWith {SUBSTATE_INVH};//Inside vehicle
    if ((alive _this) != (isAwake _this))   exitWith {SUBSTATE_RAGD};//Ragdolling. See: https://community.bistudio.com/wiki/isAwake

    /*Check cases where we must rely on our state changing logic*/
    private _curSubstate = _this call NWG_MED_COM_GetSubstate;
    if (!isNull (attachedTo _this)) exitWith {if (_curSubstate isEqualTo SUBSTATE_CARR) then {SUBSTATE_CARR} else {SUBSTATE_DRAG}};
    if (_curSubstate in [SUBSTATE_CRWL,SUBSTATE_HEAL]) exitWith {_curSubstate};//These rely solely on our state changing logic

    SUBSTATE_DOWN
};

NWG_MED_COM_IsPatched = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_patched",false]
};
NWG_MED_COM_SetPatched = {
    params ["_unit","_patched"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    if ((_unit getVariable ["NWG_MED_CLI_patched",-1]) isEqualTo _patched) exitWith {};//Update only if needed
    _unit setVariable ["NWG_MED_CLI_patched",_patched,true];
};

NWG_MED_COM_IsMedic = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_medic",false]
};
NWG_MED_COM_MarkMedic = {
    params ["_unit","_isMedic"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    if ((_unit getVariable ["NWG_MED_CLI_medic",-1]) isEqualTo _isMedic) exitWith {};//Update only if needed
    _unit setVariable ["NWG_MED_CLI_medic",_isMedic,true];
};

/*Time is completely local and never shared with others*/
NWG_MED_COM_GetTime = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {0};
    _this getVariable ["NWG_MED_CLI_time",0]
};
NWG_MED_COM_SetTime = {
    params ["_unit","_time"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_time",_time];
};