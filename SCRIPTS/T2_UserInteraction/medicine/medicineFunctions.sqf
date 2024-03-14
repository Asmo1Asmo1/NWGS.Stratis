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

/* Server -> Client */

//Flips unit direction (fix of setDir being La Ge)
//params:
//_unit - the unit to flip 180 degrees
NWG_fnc_medFlipUnit = {
    private _unit = _this;
    if (isNull _unit) exitWith {};
    if (!local _unit) exitWith {_this remoteExec ["NWG_fnc_medFlipUnit",_unit]};//Enforce locality

    _unit setDir ((getDir _unit) + 180);
};

//Plays an animation on a unit
//params:
//_unit - the unit to play the animation on
//_anim - the animation to play
NWG_fnc_medPlayAnim = {
    params ["_unit","_anim"];
    if (isNull _unit) exitWith {};
    if (!local _unit) exitWith {_this remoteExec ["NWG_fnc_medPlayAnim",_unit]};

    _this call NWG_fnc_playAnim;//Play the animation
    _unit playMove "UnconsciousFaceUp";//Fix medicine animations require additional playMove to keep playing in cycle
};

//Loads a unit into a vehicle
//params:
//_unit - the unit to load
//_veh - the vehicle to load into
//_seat - the cargo seat to load into
NWG_fnc_medLoadIntoVehicle = {
    params ["_unit","_veh","_seat"];
    if (isNull _unit) exitWith {};
    if (!local _unit) exitWith {_this remoteExec ["NWG_fnc_medLoadIntoVehicle",_unit]};//Enforce locality

    _unit moveInCargo [_veh,_seat];
    if (!(isPlayer _unit)) exitWith {};//Don't do anything additional if it's an NPC
    _unit playActionNow "Unconscious";
    _unit setCaptive false;
};