/*
    This is a core part of the module that should be compiled both on the server and every client.
    This is done because the command is 'La' - it will work only on the machine where the vehicle is local.
*/
NWG_VCAPP_OnApplyChanges = {
    params ["_vehicle","_colors","_animations"];
    private _ok = [_vehicle,_colors,_animations] call BIS_fnc_initVehicle;
    if (!_ok) exitWith {
        (format ["NWG_VCAPP_OnApplyChanges: Failed to init vehicle '%1'",_vehicle]) call NWG_fnc_logError;
    };
};