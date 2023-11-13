//================================================================================================================
//================================================================================================================
//Populate trigger
// [20,[]] call NWG_DSPAWN_TRIGGER_Populate_Test
// [20,[["MOT"],["ARM"]]] call NWG_DSPAWN_TRIGGER_Populate_Test
NWG_DSPAWN_TRIGGER_CalculatePopulation_Test = {
    // params ["_targetCount","_filter"];
    _this call NWG_DSPAWN_TRIGGER_CalculatePopulation
};

// 150 call NWG_DSPAWN_TRIGGER_FindOccupiableBuildings_Test
NWG_DSPAWN_TRIGGER_FindOccupiableBuildings_Test = {
    private _rad = _this;
    private _pos = getPosATL player;
    private _buildings = [_pos,_rad] call NWG_DSPAWN_TRIGGER_FindOccupiableBuildings;

    call NWG_fnc_testClearMap;
    {
        [(getPosWorld _x),(format ["%1_test",_foreachIndex])] call NWG_fnc_testPlaceMarker;
    } forEach _buildings;
};

//================================================================================================================
//================================================================================================================
//Catalogue read
// call NWG_DSPAWN_GetCatalogueValues_Test
NWG_DSPAWN_GetCatalogueValues_Test = {
    ["NATO",[ ["VEH"],["MEC"],[1] ] ] call NWG_DSPAWN_GetCatalogueValues
};

//================================================================================================================
//================================================================================================================
//String array

// call NWG_DSPAWN_Dev_CompactStringArray_Test
NWG_DSPAWN_Dev_CompactStringArray_Test = {
    ["aaa","bbb","aaa","ccc","ccc","ccc"] call NWG_DSPAWN_Dev_CompactStringArray
    //expected: [2,"aaa","bbb",3,"ccc"]
};

// call NWG_DSPAWN_UnCompactStringArray_Test
NWG_DSPAWN_UnCompactStringArray_Test = {
    [2,"aaa","bbb",3,"ccc"] call NWG_DSPAWN_UnCompactStringArray
    //expected: ["aaa","aaa","bbb","ccc","ccc","ccc"]
};

//================================================================================================================
//================================================================================================================
//Passengers
// 6 call NWG_DSPAWN_GeneratePassengers_Test
NWG_DSPAWN_GeneratePassengers_Test = {
    private _count = _this;
    private _container = [
        ["com1","com2","com3"],
        ["Mid1","Mid2","Mid3"],
        ["RAR1","RAR2","RAR3"]
    ];

    [_container,_count] call NWG_DSPAWN_GeneratePassengers
};

// 6 call NWG_DSPAWN_FillWithPassengers_Test
NWG_DSPAWN_FillWithPassengers_Test = {
    private _pasCount = _this;
    private _container = [
        ["com1","com2","com3"],
        ["Mid1","Mid2","Mid3"],
        ["RAR1","RAR2","RAR3"]
    ];

    private _unitsDescr = ["ex1","ex2"];
    private _dop = [];
    _dop resize _pasCount;
    _dop = _dop apply {"RANDOM"};
    _unitsDescr append _dop;

    [_unitsDescr,_container] call NWG_DSPAWN_FillWithPassengers
};

//================================================================================================================
//================================================================================================================
//Spawn
NWG_DSPAWN_TestGroupDescription = [
    ["VEH","MOT","REG"],1,
    ["B_MRAP_01_F"],
    ["B_Soldier_F",3,"RANDOM"]
];

NWG_DSPAN_TestPassengersCatalogue = [
    ["B_RangeMaster_F","B_Survivor_F","B_Deck_Crew_F"],
    ["O_Survivor_F"],
    ["C_Man_formal_1_F","C_Man_formal_2_F","C_Man_formal_3_F"]
];

// call NWG_DSPAWN_PrepareGroupForSpawn_Test
NWG_DSPAWN_PrepareGroupForSpawn_Test = {
    private _groupDescr = NWG_DSPAWN_TestGroupDescription;
    private _passengersContainer = NWG_DSPAN_TestPassengersCatalogue;
    [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn
};

// call NWG_DSPAWN_SpawnVehicledGroup_Test
NWG_DSPAWN_SpawnVehicledGroup_Test = {
    private _groupDescr = NWG_DSPAWN_TestGroupDescription;
    private _passengersContainer = NWG_DSPAN_TestPassengersCatalogue;
    _groupDescr = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;

    private _pos = getPosATL player;
    private _dir = random 360;

    [_groupDescr,_pos,_dir] call NWG_DSPAWN_SpawnVehicledGroup
};

// call NWG_DSPAWN_SpawnInfantryGroup_Test
NWG_DSPAWN_SpawnInfantryGroup_Test = {
    private _groupDescr = NWG_DSPAWN_TestGroupDescription;
    private _passengersContainer = NWG_DSPAN_TestPassengersCatalogue;
    _groupDescr = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;
    private _pos = getPosATL player;

    [_groupDescr,_pos] call NWG_DSPAWN_SpawnInfantryGroup
};

// call NWG_DSPAWN_SpawnInfantryGroupInBuilding_Test
//note: requires 'test2' building in editor
NWG_DSPAWN_SpawnInfantryGroupInBuilding_Test = {
    private _groupDescr = NWG_DSPAWN_TestGroupDescription;
    private _passengersContainer = NWG_DSPAN_TestPassengersCatalogue;
    _groupDescr = [_groupDescr,_passengersContainer] call NWG_DSPAWN_PrepareGroupForSpawn;

    [_groupDescr,test2] call NWG_DSPAWN_SpawnInfantryGroupInBuilding
};

//================================================================================================================
//================================================================================================================
//TAGs system

//================================================================================================================
//================================================================================================================
//Waypoints

//================================================================================================================
//================================================================================================================
//Patrol logic

//================================================================================================================
//================================================================================================================
//Attack logic

//================================================================================================================
//================================================================================================================
//Paradrop

//================================================================================================================
//================================================================================================================
//Test utils

NWG_fnc_testClearMap =
{
    //do
    {
        deleteMarker _x;
    } forEach allMapMarkers;
};

NWG_fnc_testPlaceMarker =
{
    params ["_pos","_name",["_color","ColorRed"],["_text",""]];

    private _marker = createMarkerLocal [_name,_pos];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal "mil_dot";
    _marker setMarkerColorLocal _color;
    _marker setMarkerTextLocal _text;
};