//Spawn the vehicle in a safe place and hide it globally
//params:
//_classname - classname of the vehicle
//_NaN - not used
//_dir - direction for the vehicle to face
//_appearance - [optional] appearance of the vehicle
//_pylons - [optional] pylons of the vehicle
//returns:
//spawned vehicle
//note: The result vehicle will remain in a 'safe spot' and hidden globally
NWG_fnc_spwnPrespawnVehicle = {
    //params ["_classname","_NaN","_dir",["_appearance",false],["_pylons",false]];
    _this call NWG_SPWN_PrespawnVehicle
    //returns _vehicle
};

//Spawn the group of units in a safe place and hide them globally
//params:
//_classnames - array of classnames of the units
//_NaN - not used
//_side - [optional] side of the units (west by default)
//returns:
//array of spawned units
//note: The result units will remain in a 'safe spot' and hidden globally
NWG_fnc_spwnPrespawnUnits = {
    //params ["_classnames","_NaN",["_side",west]];
    _this call NWG_SPWN_PrespawnUnits
    //returns _units (array)
};

//Spawn the vehicle around given position
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

//Spawn the group of units around given position
//params:
//_classnames - array of classnames of the units
//_pos - position to spawn around
//_side - [optional] side of the units
//returns:
//array of spawned units
NWG_fnc_spwnSpawnUnitsAround = {
    //params ["_classnames","_pos",["_side",west]];
    _this call NWG_SPWN_SpawnUnitsAround
    //returns _units (array)
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

//Spawn the group of units into given building
//params:
//_classnames - array of classnames of the units
//_building - building to spawn into
//_side - [optional] side of the units
//returns:
//array of spawned units
NWG_fnc_spwnSpawnUnitsIntoBuilding = {
    //params ["_classnames","_building",["_side",west]];
    _this call NWG_SPWN_SpawnUnitsIntoBuilding
    //returns _units (array)
};

//Get appearance of the vehicle
//params:
//_vehicle - vehicle to get appearance of
//returns:
//appearance of the vehicle
NWG_fnc_spwnGetVehicleAppearance = {
    //private _vehicle = _this;
    _this call NWG_SPWN_GetVehicleAppearance
    //returns _appearance
};

//Set appearance of the vehicle
//params:
//_vehicle - vehicle to set appearance of
//_appearance - appearance to set
NWG_fnc_spwnSetVehicleAppearance = {
    //params ["_vehicle","_appearance"];
    _this call NWG_SPWN_SetVehicleAppearance
};

//Get pylons of the vehicle
//params:
//_vehicle - vehicle to get pylons of
//returns:
//pylons of the vehicle
NWG_fnc_spwnGetVehiclePylons = {
    //private _vehicle = _this;
    _this call NWG_SPWN_GetVehiclePylons
    //returns _pylons
};

//Set pylons of the vehicle
//params:
//_vehicle - vehicle to set pylons of
//_pylons - pylons to set
NWG_fnc_spwnSetVehiclePylons = {
    //params ["_vehicle","_pylons"];
    _this call NWG_SPWN_SetVehiclePylons
};

// Hide object globally
// params:
// _object - object to hide
NWG_fnc_spwnHideObject = {
    //private _object = _this;
    _this call NWG_SPWN_Hide
};

// Reveal object globally
// params:
// _object - object to reveal
NWG_fnc_spwnRevealObject = {
    //private _object = _this;
    _this call NWG_SPWN_Reveal
};