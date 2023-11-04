//================================================================================================================
//================================================================================================================
//Group spawn
NWG_DSPAWN_SpawnVehicledGroup = {
    params  ["_vehicleClassname","_unitClassnames","_pos","_dir",
            ["_vehicleAppearance", false],["_vehiclePylons", false],["_deferReveal", false],["_side", west]];

    private _vehicle = [_vehicleClassname,_pos,_dir,_vehicleAppearance,_vehiclePylons,_deferReveal] call NWG_fnc_spwnSpawnVehicleAround;
    private _units = [_unitClassnames,_vehicle,_side] call NWG_fnc_spwnSpawnUnitsIntoVehicle;
    private _group = group (_units#0);

    //return
    _group
};
