/*
    This is a core part of the module that should be compiled both on the server and every client.
    This is done because most of the commands are 'La' - they will work only on the machine where the vehicle is local.
*/
NWG_VCPYL_OnPresetSelected = {
    params ["_vehicle","_preset","_isPilotOwner"];

    private _newPylons = getArray (configOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Presets" >> _preset >> "attachment");
    private _pylonPaths = configProperties [configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"];
    _pylonPaths = _pylonPaths apply {getArray (_x >> "turret")};

    for "_i" from 0 to ((count _pylonPaths)-1) do {
        _vehicle setPylonLoadout [
            /*pylon number:*/(_i+1),
            /*magazine:*/(_newPylons param [_i,""]),
            /*forced:*/true,
            /*turret:*/(if (_isPilotOwner) then {[]} else {_pylonPaths#_i})
        ];
    };
};