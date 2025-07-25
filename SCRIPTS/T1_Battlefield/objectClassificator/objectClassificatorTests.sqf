//==================================================================================================
//Manual console testing

//test1 call NWG_OBCL_IsBuilding
//test1 call NWG_OBCL_GetBuildingCategory
//test1 call NWG_OBCL_GetSameBuildings


//==================================================================================================
//Environment testing
//150 call NWG_OBCL_Tests_IsBuilding
NWG_OBCL_Tests_IsBuilding = {
    private _radius = _this;

    call NWG_fnc_testClearMap;

    private _objectsAround = player nearObjects _radius;
    {
        if (_x call NWG_OBCL_IsBuilding) then {
            [(getPosWorld _x),(format ["%1_test",_foreachIndex])] call NWG_fnc_testPlaceMarker;
        };
    } forEach _objectsAround;
};

//150 call NWG_OBCL_Tests_IsBuilding_SpeedTest
NWG_OBCL_Tests_IsBuilding_SpeedTest = {
    // private _radius = _this;
    private _buildingsCount = 0;
    private _objectsAround = player nearObjects _this;
    {
        if (_x call NWG_OBCL_IsBuilding) then {
           _buildingsCount = _buildingsCount + 1;
        };
    } forEach _objectsAround;
    //return
    _buildingsCount
};

//==================================================================================================
//IsArmedVehicle testing
// call NWG_OBCL_Tests_IsArmedVehicle
NWG_OBCL_Tests_IsArmedVehicle = {
    private _vehiclesAround = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],500];
    private _armedVehicles = [];
    private _unarmedVehicles = [];
    {
        if (_x call NWG_OBCL_IsArmedVehicle)
            then {_armedVehicles pushBack _x}
            else {_unarmedVehicles pushBack _x};
    } forEach _vehiclesAround;

    _armedVehicles = _armedVehicles apply {getText ((configOf _x) >> "displayName")};
    _unarmedVehicles = _unarmedVehicles apply {getText ((configOf _x) >> "displayName")};
    diag_log "==== ARMED VEHICLES ====";
    _armedVehicles call NWG_fnc_testDumpToRptAndClipboard;
    diag_log "==== UNARMED VEHICLES ====";
    _unarmedVehicles call NWG_fnc_testDumpToRptAndClipboard;

    "Done, check RPT for results"
};

// call NWG_OBCL_Bench_IsArmedVehicle
NWG_OBCL_Bench_IsArmedVehicle = {
    private _vehiclesAround = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],500];
    {_x call NWG_OBCL_IsArmedVehicle} forEach _vehiclesAround;
};