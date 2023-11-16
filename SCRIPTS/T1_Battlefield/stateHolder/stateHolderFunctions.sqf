// Checks if building was reported to be occupied by any module
// params: building - object
// returns: bool
NWG_fnc_shIsBuildingOccupied = {
    // private _building = _this;
    // return
    _this call NWG_STHLD_IsBuildingOccupied
};

// Marks building as occupied by any module
// params: building - object
// returns: void
NWG_fnc_shMarkBuildingOccupied = {
    // private _building = _this;
    _this call NWG_STHLD_MarkBuildingOccupied;
};