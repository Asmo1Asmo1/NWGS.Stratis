//================================================================================================================
//================================================================================================================
//Spawning of a vehicle
// call NWG_SPWN_SpawnVehicleAround_Test
NWG_SPWN_SpawnVehicleAround_Test = {
    private _pos = getPosATL player;
    _pos set [2,0];

    ["B_MRAP_01_F",_pos,(random 360)] call NWG_SPWN_SpawnVehicleAround;
};

//================================================================================================================
//================================================================================================================
//Spawning of units

// call NWG_SPWN_SpawnUnitsAround_Test
NWG_SPWN_SpawnUnitsAround_Test = {
    private _pos = getPosATL player;
    _pos set [2,0];

    [["O_Survivor_F","B_Deck_Crew_F","I_Survivor_F","C_man_p_beggar_F"],_pos] call NWG_SPWN_SpawnUnitsAround;
};

// call NWG_SPWN_SpawnUnitsIntoVehicle_Test
// note: requires vehicle 'test1' to be placed in the editor
NWG_SPWN_SpawnUnitsIntoVehicle_Test = {
    [["O_Survivor_F","B_Deck_Crew_F","I_Survivor_F","C_man_p_beggar_F"],test1] call NWG_SPWN_SpawnUnitsIntoVehicle;
};

// call NWG_SPWN_SpawnUnitsIntoBuilding_Test
// note: requires building 'test2' to be placed in the editor
NWG_SPWN_SpawnUnitsIntoBuilding_Test = {
    [["O_Survivor_F","B_Deck_Crew_F","I_Survivor_F","C_man_p_beggar_F"],test2] call NWG_SPWN_SpawnUnitsIntoBuilding;
};