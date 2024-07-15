/*
    This is a core part of the module that should be compiled both on the server and every client.
    This is done because most of the commands are 'La' - they will work only on the machine where the vehicle is local.
*/
NWG_VCPYL_OnPresetSelected = {
    params ["_vehicle","_preset","_isPilotOwner"];

    //TODO: Implement
    systemChat "NWG_VCPYL_OnPresetSelected: Not implemented yet";
    systemChat str _this;
};