//Spawn the vehicle with free space search around given position
//params:
//_classname - classname of the vehicle
//_pos - position to spawn around
//_dir - direction for the vehicle to face
//_appearance - [optional] appearance of the vehicle
//_pylons - [optional] pylons of the vehicle
//_deferReveal - [optional] if true, vehicle will remain hidden globally after spawn
//returns:
//spawned vehicle
NWG_fnc_spwnSpawnVehicleAround = {
    //params ["_classname","_pos","_dir",["_appearance",false],["_pylons",false],["_deferReveal",false]];
    _this call NWG_SPWN_SpawnVehicleAround
    //returns _vehicle
};

//Spawn the group of units into given vehicle
//params:
//_classnames - array of classnames of the units
//_vehicle - vehicle to spawn into
//_side - [optional] side of the units
//returns:
//array of spawned units
NWG_fnc_spwnSpawnUnitsIntoVehicle = {
    //params ["_classnames","_vehicle",["_side",west]];
    _this call NWG_SPWN_SpawnUnitsIntoVehicle
    //returns _units (array)
};
