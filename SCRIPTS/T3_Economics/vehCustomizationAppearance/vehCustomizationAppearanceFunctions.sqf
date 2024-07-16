/*Client-> Server|Client*/
//Applies appearance changes to vehicle
//params:
//  _vehicle - object
//  _colors - array
//  _animations - array
NWG_fnc_vcappOnApplyChanges = {
    // params ["_vehicle","_colors","_animations"];
    private _vehicle = _this param [0,objNull];
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        (format ["NWG_fnc_vcappOnApplyChanges: Invalid arg '%1'",_vehicle]) call NWG_fnc_logError;
    };

    if (local _vehicle)
        then {_this call NWG_VCAPP_OnApplyChanges}
        else {_this remoteExec ["NWG_fnc_vcappOnApplyChanges",_vehicle]};
};