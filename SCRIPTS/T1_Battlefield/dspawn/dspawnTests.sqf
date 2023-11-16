//================================================================================================================
//================================================================================================================
//Populate trigger
// [250,20] call NWG_DSPAWN_TRIGGER_PopulateTrigger_Test
NWG_DSPAWN_TRIGGER_PopulateTrigger_Test = {
    params ["_radius","_groupsCount",["_filter",[]]];
    private _trigger = [(getPosATL player),_radius];
    [_trigger,_groupsCount,"NATO",_filter] call NWG_DSPAWN_TRIGGER_PopulateTrigger
};

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
NWG_DSPAWN_PATROL_TEST_GeneratePatrol = {
    private _isAirPatrol = _this;
    private _pos = getPosATL player;
    private _minRad = if (_isAirPatrol) then {200} else {50};
    private _maxRad = if (_isAirPatrol) then {500} else {150};

    ([_pos,_minRad,_maxRad] call NWG_fnc_dtsMarkupArea) params ["_plains","_roads","_water"];
    private _dots = if (_isAirPatrol)
        then {_plains + _roads + _water}
        else {_plains + _roads};
    if (count _dots < 3) exitWith {[]};

    private _dot1 = selectRandom _dots;
    private _dot2 = _dots select ([_dots,_pos] call NWG_fnc_dtsFindIndexOfFarthest);
    private _dot3 = selectRandom _dots;
    while {_dot3 isEqualTo _dot1 || {_dot3 isEqualTo _dot2}} do {_dot3 = selectRandom _dots};
    private _result = [_dot1,_dot2,_dot3];

    if (_isAirPatrol) then {
        private _airHeight = NWG_DOTS_Settings get "TRIGGER_AIR_HEIGHT";//Dirty hack
        {(_x set [2,(selectRandom _airHeight)])} forEach _result;
    };

    //return
    _result
};

// call NWG_DSPAWN_PATROL_TEST_Infantry
NWG_DSPAWN_PATROL_TEST_Infantry = {
    private _groupDescr = [["INF","AA"],1,false,["B_Soldier_TL_F","B_soldier_AA_F","B_soldier_AA_F","B_soldier_AAA_F"]],
    private _patrolRoute = false call NWG_DSPAWN_PATROL_TEST_GeneratePatrol;
    if (count _patrolRoute < 3) exitWith {"Could not generate patrol route"};

    private _group = ([_groupDescr,(_patrolRoute#0)] call NWG_DSPAWN_SpawnInfantryGroup)#0;
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;

    _group
};

// call NWG_DSPAWN_PATROL_TEST_Vehicle
NWG_DSPAWN_PATROL_TEST_Vehicle = {
    private _groupDescr = [
            ["VEH","MOT","REG","PARADROPPABLE+"],1,
            ["B_LSV_01_unarmed_F"],
            ["B_Soldier_F","B_Soldier_F","B_Soldier_F","B_Soldier_F"]
    ];
    private _patrolRoute = false call NWG_DSPAWN_PATROL_TEST_GeneratePatrol;
    if (count _patrolRoute < 3) exitWith {"Could not generate patrol route"};

    private _group = ([_groupDescr,(_patrolRoute#0),((_patrolRoute#0) getDir (_patrolRoute#1))] call NWG_DSPAWN_SpawnVehicledGroup)#0;
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;

    _group
};

// call NWG_DSPAWN_PATROL_TEST_Arm
NWG_DSPAWN_PATROL_TEST_Arm = {
    private _groupDescr = [
            ["ARM","MEC","AT"],2,
            ["B_MBT_01_cannon_F",[["Sand",1],["showBags",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5]],false],
            ["B_crew_F","B_crew_F","B_crew_F","B_crew_F"]
    ];
    private _patrolRoute = false call NWG_DSPAWN_PATROL_TEST_GeneratePatrol;
    if (count _patrolRoute < 1) exitWith {"Could not generate patrol route"};
    _patrolRoute resize 1;

    private _group = ([_groupDescr,(_patrolRoute#0),(random 360)] call NWG_DSPAWN_SpawnVehicledGroup)#0;
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;

    _group
};

// call NWG_DSPAWN_PATROL_TEST_Helicopter
NWG_DSPAWN_PATROL_TEST_Helicopter = {
    private _groupDescr = [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],1,
            ["B_Heli_Light_01_F"],
            ["B_Helipilot_F","B_Helipilot_F","B_Helipilot_F","B_Helipilot_F"]
    ];
    private _patrolRoute = true call NWG_DSPAWN_PATROL_TEST_GeneratePatrol;
    if (count _patrolRoute < 3) exitWith {"Could not generate patrol route"};

    private _group = ([_groupDescr,(_patrolRoute#0),((_patrolRoute#0) getDir (_patrolRoute#1))] call NWG_DSPAWN_SpawnVehicledGroup)#0;
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;

    _group
};

// call NWG_DSPAWN_PATROL_TEST_Plane
NWG_DSPAWN_PATROL_TEST_Plane = {
    private _groupDescr = [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],2,
            ["B_Plane_CAS_01_dynamicLoadout_F"],
            ["B_Fighter_Pilot_F"]
    ];
    private _patrolRoute = true call NWG_DSPAWN_PATROL_TEST_GeneratePatrol;
    if (count _patrolRoute < 3) exitWith {"Could not generate patrol route"};

    private _group = ([_groupDescr,(_patrolRoute#0),((_patrolRoute#0) getDir (_patrolRoute#1))] call NWG_DSPAWN_SpawnVehicledGroup)#0;
    [_group,_patrolRoute] call NWG_DSPAWN_SendToPatrol;

    _group
};

// call NWG_DSPAWN_PATROL_TEST_All
NWG_DSPAWN_PATROL_TEST_All = {
    private _tests = [
        NWG_DSPAWN_PATROL_TEST_Infantry,
        NWG_DSPAWN_PATROL_TEST_Vehicle,
        NWG_DSPAWN_PATROL_TEST_Arm,
        NWG_DSPAWN_PATROL_TEST_Helicopter,
        NWG_DSPAWN_PATROL_TEST_Plane
    ];

    private _result = [];
    {_result pushBack (call _x)} forEach _tests;

    _result
};

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