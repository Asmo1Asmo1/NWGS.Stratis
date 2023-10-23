//Settings
NWG_SPWB_Settings = createHashMapFromArray [
    ["AREA_SPAWNSEARCH_DENSITY",30],//Step 1: The area is covered in random points each 'DENSITY' meters. Higher - more results. Lower - faster execution.
    ["AREA_SPAWNSEARCH_SUBRAD",20],//Step 2: Search for valid spawn point is done around each random point in 'SUBRAD' radius. Higher - more results. Lower - faster execution. Keep lower than 'DENSITY' to prevent overlap.
    ["AREA_SPAWNSEARCH_SUBRAD_STEP",2],//Step 2: From 0 to 'SUBRAD' incrementing by 'SUBRAD_STEP'. Higher - faster execution. Lower - more results. Keep as divider of 'SUBRAD' for correct work.
    ["",0]
];

//================================================================================================================
//================================================================================================================
//Area spawn points search

NWG_SPWB_MarkupArea = {
    params ["_pos","_minRad","_maxRad"];

    private _searchStep = NWG_SPWB_Settings get "AREA_SPAWNSEARCH_DENSITY";
    private _subSearchRad = NWG_SPWB_Settings get "AREA_SPAWNSEARCH_SUBRAD";
    private _subSearchStep = NWG_SPWB_Settings get "AREA_SPAWNSEARCH_SUBRAD_STEP";

    //Cover the area with initial search dots
    private _dots = [_pos,_minRad,_maxRad,_searchStep] call NWG_SPWB_GenerateDottedArea;

    //Search for plains, roads and water around each dot
    private _result = [_dots,_subSearchRad,_subSearchStep,/*_doPlains:*/true,/*_doRoads:*/true,/*_doWater:*/true] call NWG_SPWB_FindPlainsRoadsWaterAroundDots;

    //return [_plains,_roads,_water]
    _result
};

//================================================================================================================
//================================================================================================================
//Dots to useful coordinates

NWG_SPWB_IsPlainSurfaceAt = {
    // private _dot = _this;

    // Is position flat and bit away from terrain objects
    if ((count (_this isFlatEmpty [1,-1,0.25,1,([0,2] select (surfaceIsWater _this))])) == 0) exitWith {false};

    // Is it indeed away from terrain and mission objects
    if ((count (nearestTerrainObjects [_this,[],8,false,true])) > 0) exitWith {false};
    if ((count (_this nearEntities 8)) > 0) exitWith {false};

    // Is not inside some rock or building
    private _thisASL = AGLtoASL _this;
    if ((count (lineIntersectsSurfaces [_thisASL,(_thisASL vectorAdd [0, 0, 50]),objNull,objNull,false,1,"GEOM","NONE"])) > 0) exitWith {false};

    // After all checks have passed, return true
    true
};

NWG_SPWB_FindPlainsRoadsWaterAroundDots = {
    params ["_dots","_searchRad","_searchStep",["_doPlains",true],["_doRoads",true],["_doWater",true]];

    private _plains = [];
    private _roads = [];
    private _water = [];
    private "_dot";

    //do
    {
        scopeName "foreach_dots";

        for "_r" from 0 to _searchRad step _searchStep do {
            _dot = _x getPos [_r,(random 360)];
            _dot set [2,0];

            if (surfaceIsWater _dot) then {
                if (!_doWater) then { continue };
                if (((ASLToATL _dot)#2) < 5) then { continue };//Depth check
                if (!(_dot call NWG_SPWB_IsPlainSurfaceAt)) then { continue };
                _water pushBack _dot;
                breakTo "foreach_dots";
            };

            if (isOnRoad _dot) then {
                if (!_doRoads) then { continue };
                _dot = getPosWorld (roadAt _dot);
                _dot set [2,0];
                _roads pushBack _dot;
                breakTo "foreach_dots";
            };

            if (_doPlains && {_dot call NWG_SPWB_IsPlainSurfaceAt}) then {
                _plains pushBack _dot;
                breakTo "foreach_dots";
            };
        };

    } forEach _dots;

    //return
    [_plains,_roads,_water]
};

//================================================================================================================
//================================================================================================================
//Dots generation - Core for other functions

NWG_SPWB_GenerateDotsCircle = {
    params ["_pos","_rad","_count"];

    private _sector = 360/_count;
    private _randShift = (random (_sector*2)) - _sector;
    private _result = [];
    private "_dot";

    for "_i" from 0 to (_count-1) do {
        _dot = _pos getPos [_rad,((_sector * _i) + _randShift)];
        _dot set [2,0];
        _result pushBack _dot;
    };

    //return
    _result
};

NWG_SPWB_GenerateDotsCloud = {
    params ["_pos","_rad","_count"];

    private _result = [];
    private "_dot";

    for "_i" from 0 to (_count-1) do {
        _dot = _pos getPos [((sqrt random 1) * _rad),(random 360)];
        _dot set [2,0];
        _result pushBack _dot;
    };

    //return
    _result
};

NWG_SPWB_GenerateDottedArea = {
    params ["_pos","_minRad","_maxRad","_step"];

    private _result = [];
    private _curRad = _minRad;
    private ["_count","_sector","_randShift","_dot"];

    while { _curRad <= _maxRad } do {
        _count = (round ((6.28*_curRad)/_step)) max 1;
        _sector = 360/_count;
        _randShift = (random (_sector*2)) - _sector;

        for "_i" from 0 to (_count-1) do {
            _dot = _pos getPos [_curRad,((_sector * _i) + _randShift)];
            _dot set [2,0];
            _result pushBack _dot;
        };

        _curRad = _curRad + _step;
    };

    //return
    _result
};