/*
    Annotation:
    This is a 'state' module meaning its only purpose is to store values and share them with any other module on request.
*/

//================================================================================================================
//================================================================================================================
//States
NWG_STHLD_States = createHashMapFromArray [
    ["OccupiedBuildings",[]],
    ["",0]
];

//================================================================================================================
//================================================================================================================
//Occupied Buildings
NWG_STHLD_IsBuildingOccupied = {
    //private _building = _this;
    //return
    (_this in (NWG_STHLD_States get "OccupiedBuildings"))
};

NWG_STHLD_MarkBuildingOccupied = {
    //private _building = _this;
    (NWG_STHLD_States get "OccupiedBuildings") pushBackUnique _this;
};