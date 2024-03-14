/* Client -> Server */

//Reports blame to the server
//params:
//_activeUnit - the unit that did the thing
//_passiveUnit - affected unit
//_blame - the blame 'enum' value (see 'medicineDefines.h' for possible values)
NWG_fnc_medBlame = {
    // params ["_activeUnit","_passiveUnit","_blame"];
    if (isServer)
        then {_this call NWG_MED_SER_OnBlame}
        else {_this remoteExec ["NWG_fnc_medBlame",2]};
};

//Reports a medical action to the server
//params:
//_activeUnit - the unit that did the action
//_passiveUnit - affected unit
//_action - the action 'enum' value (see 'medicineDefines.h' for possible values)
NWG_fnc_medReportMedAction = {
    // params ["_activeUnit","_passiveUnit","_action"];
    if (isServer)
        then {_this call NWG_MED_SER_OnMedAction}
        else {_this remoteExec ["NWG_fnc_medReportMedAction",2]};
};

/* Any -> Any */

//Checks if a unit is wounded
//returns: boolean
NWG_fnc_medIsWounded = {
    // private _unit = _this;
    _this call NWG_MED_COM_IsWounded
};

//Checks if a unit is a medic
//returns: boolean
NWG_fnc_medIsMedic = {
    // private _unit = _this;
    _this call NWG_MED_COM_IsMedic
};