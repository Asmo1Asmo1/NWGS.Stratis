/*Any->Client*/
//Check if vehicle has customization options
//params:
//  _vehicle - object
//return:
//  boolean
NWG_fnc_vcaIsValid = {
    // private _vehicle = _this;
    _this isEqualType objNull && {alive _this && {_this call NWG_VCAPP_HasCustomizationOptions}}
};

//Open customization UI
//params:
//  _vehicle - object
//return:
//  boolean
NWG_fnc_vcaOpen = {
    // private _vehicle = _this;
    if !(_this call NWG_fnc_vcaIsValid) exitWith {false};
    _this call NWG_VCAPP_CustomizeAppearance
};

/*Client-> Server|Client*/
//Applies appearance changes to vehicle
//params:
//  _vehicle - object
//  _colors - array
//  _animations - array
NWG_fnc_vcaOnApplyChanges = {
    // params ["_vehicle","_colors","_animations"];
    private _vehicle = _this param [0,objNull];
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        (format ["NWG_fnc_vcaOnApplyChanges: Invalid arg '%1'",_vehicle]) call NWG_fnc_logError;
    };

    if (local _vehicle)
        then {_this call NWG_VCAPP_OnApplyChanges}
        else {_this remoteExec ["NWG_fnc_vcaOnApplyChanges",_vehicle]};
};