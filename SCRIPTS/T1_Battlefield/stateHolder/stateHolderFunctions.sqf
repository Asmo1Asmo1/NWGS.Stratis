//Get the list of occupied buildings
//returns: array of buildings that were marked as occupied by other systems
NWG_fnc_shGetOccupiedBuildings = {
    NWG_STHLD_OccupiedBuildings
};

//Add a building to the list of occupied buildings
NWG_fnc_shAddOccupiedBuilding = {
    // private _building = _this;
    NWG_STHLD_OccupiedBuildings pushBackUnique _this;
};

//Clear the list of occupied buildings
NWG_fnc_shClearOccupiedBuildings = {
    NWG_STHLD_OccupiedBuildings resize 0;
};
