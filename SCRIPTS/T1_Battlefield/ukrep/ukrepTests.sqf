// call NWG_UKREP_VectorMathTest
NWG_UKREP_VectorMathTest = {
    //Determine if previous algorithm and new one give exact same results
    private _rootPos = [0.3428,0.1775,0.1693];
    private _curPos  = [0.8342,0.1346,0.7526];

    private _oldOffset = [
        ((_curPos#0)-(_rootPos#0)),
        ((_curPos#1)-(_rootPos#1)),
        ((_curPos#2)-(_rootPos#2))
    ];
    private _newOffset = _curPos vectorDiff _rootPos;

    private _oldPos = [
        ((_rootPos#0)+(_oldOffset#0)),
        ((_rootPos#1)+(_oldOffset#1)),
        ((_rootPos#2)+(_oldOffset#2))
    ];
    private _newPos = _rootPos vectorAdd _newOffset;

    //return
    [(_oldOffset isEqualTo _newOffset),(_oldPos isEqualTo _newPos)]
};

//================================================================================================================
//================================================================================================================
//Test utils
NWG_UKREP_TEST_placedObjects = [];
NWG_UKREP_TEST_Clear = {
    if (NWG_UKREP_TEST_placedObjects isNotEqualTo [])
        then {[] call NWG_fnc_gcDeleteMission};
    NWG_UKREP_TEST_placedObjects resize 0;
};

//================================================================================================================
//================================================================================================================
//Public placement
// call NWG_UKREP_PUBLIC_PlaceABS_Test
NWG_UKREP_PUBLIC_PlaceABS_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceABS = {
    // params ["_cataloguePage",["_blueprintName",""],["_blueprintPos",[]],["_chances",[]],["_faction","NATO"],["_groupRules",[]]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_blueprintName] call NWG_UKREP_PUBLIC_PlaceABS;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// call NWG_UKREP_PUBLIC_PlaceREL_Position_Test
NWG_UKREP_PUBLIC_PlaceREL_Position_Test = {
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceREL_Position = {
    // params ["_cataloguePage","_pos","_dir",["_blueprintName",""],["_chances",[]],["_faction","NATO"],["_groupRules",[]],["_adaptToGround",true]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _pos = getPosATL player;
    private _dir = getDir player;
    private _result = [_cataloguePage,_pos,_dir,_blueprintName] call NWG_UKREP_PUBLIC_PlaceREL_Position;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};

// test1 call NWG_UKREP_PUBLIC_PlaceREL_Object_Test
NWG_UKREP_PUBLIC_PlaceREL_Object_Test = {
    private _object = _this;
    call NWG_UKREP_TEST_Clear;
    // NWG_UKREP_PUBLIC_PlaceREL_Object = {
    // params ["_cataloguePage","_object",["_objectType",""],["_blueprintName",""],["_chances",[]],["_faction","NATO"],["_groupRules",[]],["_adaptToGround",true]];
    private _cataloguePage = "testUkrep";
    private _blueprintName = "BUNKER";
    private _result = [_cataloguePage,_object,"",_blueprintName] call NWG_UKREP_PUBLIC_PlaceREL_Object;
    NWG_UKREP_TEST_placedObjects = _result;
    _result
};