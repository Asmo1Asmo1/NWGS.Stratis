//================================================================================================================
//================================================================================================================
//Spawning of a vehicle
// call NWG_SPWN_SpawnVehicleFreely_Test
NWG_SPWN_SpawnVehicleFreely_Test = {
    private _pos = getPosATL player;
    _pos set [2,0];

    ["B_MRAP_01_F",_pos,(random 360)] call NWG_SPWN_SpawnVehicleFreely;
};