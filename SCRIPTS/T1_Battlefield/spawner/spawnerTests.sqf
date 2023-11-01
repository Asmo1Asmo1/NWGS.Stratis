//================================================================================================================
//================================================================================================================
//Spawning of a vehicle
// call NWG_SPWN_SpawnVehicleFreely_Test
NWG_SPWN_SpawnVehicleFreely_Test = {
    private _pos = getPosATL player;
    _pos set [2,0];

    ["B_MRAP_01_F",_pos,(random 360)] call NWG_SPWN_SpawnVehicleFreely;
};

//================================================================================================================
//================================================================================================================
//Spawning of units

// call NWG_SPWN_SpawnUnitsFreely_Test
NWG_SPWN_SpawnUnitsFreely_Test = {
    private _pos = getPosATL player;
    _pos set [2,0];

    [["O_Survivor_F","B_Deck_Crew_F","I_Survivor_F","C_man_p_beggar_F"],_pos] call NWG_SPWN_SpawnUnitsFreely;
};