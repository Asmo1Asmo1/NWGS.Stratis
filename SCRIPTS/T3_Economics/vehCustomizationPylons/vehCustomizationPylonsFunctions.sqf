/*Any->Client*/
//Check if vehicle has customization options
//params:
//  _vehicle - object
//return:
//  boolean
NWG_fnc_vcpIsValid = {
    // private _vehicle = _this;
    _this isEqualType objNull && {alive _this && {_this call NWG_VCPYL_CanCustomizePylons}}
};

//Open customization UI
//params:
//  _vehicle - object
//return:
//  boolean
NWG_fnc_vcpOpen = {
    if !(_this call NWG_fnc_vcpIsValid) exitWith {false};
    _this call NWG_VCPYL_CustomizePylons
};

/*Client-> Server|Client*/
//Applies pylons preset changes to vehicle
//params:
//  _vehicle - object
//  _preset - string
//  _isPilotOwner - bool
NWG_fnc_vcpOnPresetSelected = {
    // params ["_vehicle","_preset","_isPilotOwner"];
    private _vehicle = _this param [0,objNull];
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        (format ["NWG_fnc_vcpOnPresetSelected: Invalid arg '%1'",_vehicle]) call NWG_fnc_logError;
    };

    if (local _vehicle)
        then {_this call NWG_VCPYL_OnPresetSelected}
        else {_this remoteExec ["NWG_fnc_vcpOnPresetSelected",_vehicle]};
};