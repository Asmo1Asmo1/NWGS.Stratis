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