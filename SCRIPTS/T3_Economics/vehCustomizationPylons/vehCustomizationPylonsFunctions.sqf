/*Client-> Server|Client*/
//Applies pylons preset changes to vehicle
//params:
//  _vehicle - object
//  _preset - string
//  _isPilotOwner - bool
NWG_fnc_vcpylOnPresetSelected = {
    // params ["_vehicle","_preset","_isPilotOwner"];
    private _vehicle = _this param [0,objNull];
    if (isNull _vehicle || {!alive _vehicle}) exitWith {
        (format ["NWG_fnc_vcpylOnPresetSelected: Invalid arg '%1'",_vehicle]) call NWG_fnc_logError;
    };

    if (local _vehicle)
        then {_this call NWG_VCPYL_OnPresetSelected}
        else {_this remoteExec ["NWG_fnc_vcpylOnPresetSelected",_vehicle]};
};