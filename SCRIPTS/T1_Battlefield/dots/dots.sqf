//Settings
NWG_DOTS_Settings = createHashMapFromArray [
    ["AREA_SPAWNSEARCH_DENSITY",30],//Step 1: The area is covered in random points each 'DENSITY' meters. Lower - more results. Higher - faster execution.
    ["AREA_SPAWNSEARCH_SUBRAD",20],//Step 2: Search for valid spawn point is done around each random point in 'SUBRAD' radius. Higher - more results. Lower - faster execution. Keep lower than 'DENSITY' to prevent overlap.
    ["AREA_SPAWNSEARCH_SUBRAD_STEP",1],//Step 2: From 0 to 'SUBRAD' incrementing by 'SUBRAD_STEP'. Higher - faster execution. Lower - more results. Keep as divider of 'SUBRAD' for correct work.
    ["AREA_AIR_HEIGHT",[100,125,150,175,200]],//Height that would be randomly assigned as a z coordinate for air spawn points

    ["TRIGGER_SPAWNSEARCH_SETTINGS_MULTIPLIER",1],//Multiplier for AREA_SPAWNSEARCH settings for trigger markup (leave it 1)
    ["TRIGGER_LOCATIONS_RADIUS",[25,100]],//Radius outside trigger to search for locations (_triggerRad + TRIGGER_LOCATIONS_RADIUS)
    ["TRIGGER_LOCATIONS_MINBETWEEN",100],//Min distance between locations in trigger markup
    ["TRIGGER_ROADS_RADIUS",[100,200]],//Radius outside trigger to search for roads in trigger markup
    ["TRIGGER_AIR_RADIUS",200],//(Max) radius outside trigger to markup air spawn points

    ["REINF_SPAWNSEARCH_SETTINGS_MULTIPLIER",5],//Multiplier for AREA_SPAWNSEARCH settings for reinforcement markup, keep it >1 - it does not need to be so precise as trigger search
    ["REINF_SHORECHECK_RADIUS",100],//Radius to check if there are shores around given position to decide whether or not calculate water positions
    ["REINF_INFANTRY_RADIUS",[500,700]],//Min-Max radius of the infantry spawn
    ["REINF_VEHICLE_RADIUS",[1000,1200]],//Min-Max radius of the vehicle spawn
    ["REINF_AIR_RADIUS",[3000,4000]],//Min-Max radius of the air spawn
    ["REINF_AIR_COUNT",7],//Number of air dots to generate for reinforcement markup
    ["REINF_TO_PLAYER_MIN_DISTANCE",300],//Min distance between spawn points and players

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Trigger markup
NWG_DOTS_MarkupTrigger = {
    // private _trigger = _this;
    params ["_triggerPos","_triggerRad"];

    //Markup trigger area
    private _settingsMultiplier = NWG_DOTS_Settings get "TRIGGER_SPAWNSEARCH_SETTINGS_MULTIPLIER";
    ([_triggerPos,0,_triggerRad,true,_settingsMultiplier] call NWG_DOTS_AreaSpawnsearch) params ["_plains","_roads","_water"];

    //Outside roads
    private _roadsAway = [];
    if ((count _roads)>0) then {
        private _root = _roads select ([_roads,_triggerPos] call NWG_DOTS_FindIndexOfNearest);
        (NWG_DOTS_Settings get "TRIGGER_ROADS_RADIUS") params ["_roadMinDistance","_roadMaxDistance"];
        _roadsAway = [_root,(_triggerRad+_roadMinDistance),(_triggerRad+_roadMaxDistance)] call NWG_DOTS_FindRoadsAway;
    };

    //Outside locations
    (NWG_DOTS_Settings get "TRIGGER_LOCATIONS_RADIUS") params ["_locationMinDistance","_locationMaxDistance"];
    private _locations = [_triggerPos,(_triggerRad+_locationMinDistance),(_triggerRad+_locationMaxDistance)] call NWG_DOTS_FindLocations;

    //Donate to 'roads away' and 'locations' if required (unbalanced)
    private _donateIfRequired = {
        params ["_recipient","_donor"];
        if ((count _recipient) == 0 || {(count _donor) == 0}) exitWith {};
        private _midPoint = _recipient call NWG_DOTS_FindMidpoint;
        if ((_midPoint distance2D _triggerPos) < _triggerRad) exitWith {};
        _recipient pushBack (_donor deleteAt ([_donor,_midPoint] call NWG_DOTS_FindIndexOfFarthest));
    };
    [_roadsAway,_roads] call _donateIfRequired;
    [_locations,_plains] call _donateIfRequired;

    //Air points
    private _maxRad = NWG_DOTS_Settings get "TRIGGER_AIR_RADIUS";
    private _airHeight = NWG_DOTS_Settings get "AREA_AIR_HEIGHT";
    private _air = ([_triggerPos,_triggerRad,3] call NWG_DOTS_GenerateDotsCircle) +
                   ([_triggerPos,(_triggerRad+_maxRad),3] call NWG_DOTS_GenerateDotsCloud);
    {(_x set [2,(selectRandom _airHeight)])} forEach _air;

    //return
    [_plains,_roads,_water,_roadsAway,_locations,_air]
};

//================================================================================================================
//================================================================================================================
//Reinforcements markup
NWG_DOTS_MarkupReinforcement = {
    private _pos = _this;
    private _settingsMultiplier = NWG_DOTS_Settings get "REINF_SPAWNSEARCH_SETTINGS_MULTIPLIER";

    //Calculate INF spawn radius
    private _infRad = (NWG_DOTS_Settings get "REINF_INFANTRY_RADIUS");
    ([_pos,(_infRad#0),(_infRad#1),false,_settingsMultiplier] call NWG_DOTS_AreaSpawnsearch) params ["_infPlains","_infRoads"];

    //Calculate VEH spawn radius (with BOAT if there are shores)
    private _vehRad = (NWG_DOTS_Settings get "REINF_VEHICLE_RADIUS");
    private _isShoresAround = (count ([_pos,(NWG_DOTS_Settings get "REINF_SHORECHECK_RADIUS")] call NWG_DOTS_FindShores)) > 0;
    ([_pos,(_vehRad#0),(_vehRad#1),_isShoresAround,_settingsMultiplier] call NWG_DOTS_AreaSpawnsearch) params ["_vehPlains","_vehRoads","_boats"];

    //Calculate AIR spawn radius
    (NWG_DOTS_Settings get "REINF_AIR_RADIUS") params ["_minAirRad","_maxAirRad"];
    private _airRad = (random (_maxAirRad - _minAirRad)) + _minAirRad;
    private _air = [_pos,_airRad,(NWG_DOTS_Settings get "REINF_AIR_COUNT")] call NWG_DOTS_GenerateDotsCircle;
    private _airHeight = NWG_DOTS_Settings get "AREA_AIR_HEIGHT";
    {(_x set [2,(selectRandom _airHeight)])} forEach _air;

    //Result
    private _result = [_infPlains,_infRoads,_vehPlains,_vehRoads,_boats,_air];

    //Filter by min distance to players
    private _players = call NWG_fnc_getPlayerVehiclesAll;
    private _minDist = NWG_DOTS_Settings get "REINF_TO_PLAYER_MIN_DISTANCE";
    private ["_curArray","_curDot"];
    //do
    {
        _curArray = _x;
        //do
        {
            _curDot = _x;
            if ((_players findIf {(_x distance2D _curDot) < _minDist}) != -1) then {_curArray deleteAt _forEachIndex};
        } forEachReversed _curArray; //_infPlains
    } forEach _result; //[_infPlains,_infRoads,_vehPlains,_vehRoads,_boats,_air]

    //return
    _result
};

NWG_DOTS_FindDotForWaypoint = {
    params ["_pos","_rad","_type"];

    private _dots = [];
    private _result = false;
    private _getDots = switch (_type) do {
        case "ground": { {([_pos,(_rad+(_this*10)),16] call NWG_DOTS_GenerateDotsCircle) select {!(surfaceIsWater _x)}} };
        case "water":  { {([_pos,(_rad+(_this*10)),16] call NWG_DOTS_GenerateDotsCircle) select {surfaceIsWater _x}} };
        case "shore":  { {[_pos,(_rad+(_this*10))] call NWG_DOTS_FindShores} };
        case "air":    { {[_pos,(_rad+(_this*10)),3] call NWG_DOTS_GenerateDotsCircle} };
        default {
            format ["NWG_DOTS_FindDotForWaypoint: Unknown type '%1'",_type] call NWG_fnc_logError;
            {[_pos,(_rad+(_this*10)),3] call NWG_DOTS_GenerateDotsCircle}
        };
    };

    for "_i" from 0 to 5 do {
        _dots = _i call _getDots;
        if ((count _dots) > 0) exitWith {_result = selectRandom _dots};
    };

    if (_result isNotEqualTo false && {_type isEqualTo "air"}) then {
        _result set [2,(selectRandom (NWG_DOTS_Settings get "AREA_AIR_HEIGHT"))]
    };

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Area spawn points search
NWG_DOTS_AreaSpawnsearch = {
    params ["_pos","_minRad","_maxRad",["_doWater",true],["_settingsMultiplier",1]];

    private _searchStep = (NWG_DOTS_Settings get "AREA_SPAWNSEARCH_DENSITY") * _settingsMultiplier;
    private _subSearchRad = (NWG_DOTS_Settings get "AREA_SPAWNSEARCH_SUBRAD") * _settingsMultiplier;
    private _subSearchStep = (NWG_DOTS_Settings get "AREA_SPAWNSEARCH_SUBRAD_STEP") * _settingsMultiplier;

    //Cover the area with initial search dots
    private _dots = [_pos,_minRad,_maxRad,_searchStep] call NWG_DOTS_GenerateDottedArea;

    //Search for plains, roads and water around each dot
    private _result = [_dots,_subSearchRad,_subSearchStep,_doWater] call NWG_DOTS_FindPlainsRoadsWaterAroundDots;

    //return [_plains,_roads,_water]
    _result
};

//================================================================================================================
//================================================================================================================
//Exotic search
NWG_DOTS_FindRoadsAway = {
    params ["_roadPos","_minDistance","_maxDistance"];

    //Get first road to start search from
    private _root = roadAt _roadPos;
    if (isNull _root) exitWith {[]};

    //Define variables
    private _roadWeb = [];
    private _result = [];

    //Recursive search
    private _recursiveSearch =
    {
        if (_this in _roadWeb) exitWith {};//Already added
        _roadWeb pushBack _this;

        private _distance = (getPosWorld _this) distance _roadPos;
        private _connectedRoads = roadsConnectedTo [_this,true];
        if (_distance < _minDistance) exitWith {{_x call _recursiveSearch} forEach _connectedRoads};

        if (((count _connectedRoads) <= 1) || {_distance >= (_minDistance + (random (_maxDistance - _minDistance)))}) then {
            //Add to result
            private _roadDot = getPosWorld _this;
            _roadDot set [2,0];//[x,y,=>z]
            _result pushBack _roadDot;
        } else {
            //Continue the search
            {_x call _recursiveSearch} forEach _connectedRoads;
        };
    };

    _root call _recursiveSearch;

    //return
    _result
};

NWG_DOTS_FindLocations = {
    params ["_pos","_minRad","_maxRad"];

    //Get all location types
    private _locationTypes = localNamespace getVariable "NWG_DOTS_locationTypes";
    if (isNil "_locationTypes") then {
        _locationTypes = [];
        "_locationTypes pushBack configName _x; true" configClasses (configFile >> "CfgLocationTypes");
        localNamespace setVariable ["NWG_DOTS_locationTypes",_locationTypes];
    };

    //Find nearest ground locations
    private _locations = ((nearestLocations [_pos,_locationTypes,_maxRad])
        apply {locationPosition _x})
        select {!surfaceIsWater _x && {(_x distance2D _pos) > _minRad}};

    //Find spawn area around each location
    private _searchRad = NWG_DOTS_Settings get "AREA_SPAWNSEARCH_SUBRAD";
    private _searchStep = NWG_DOTS_Settings get "AREA_SPAWNSEARCH_SUBRAD_STEP";
    private _minDist = NWG_DOTS_Settings get "TRIGGER_LOCATIONS_MINBETWEEN";
    private _result = [];
    private ["_cur","_dot"];
    //do
    {
        //Check min distance to result locations
        _cur = _x;
        if ((_result findIf {(_cur distance2D _x) < _minDist}) != -1) then {continue};

        //Find suitable spawn point around location
        for "_r" from 0 to _searchRad step _searchStep do {
            _dot = _cur getPos [_r,(random 360)];
            _dot set [2,0];
            if (!surfaceIsWater _dot && {_dot call NWG_DOTS_IsPlainSurfaceAt}) exitWith {_result pushBack _dot};
        };
    } forEach _locations;

    //return
    _result
};

NWG_DOTS_FindShores = {
    params ["_pos","_rad"];

    private _step = (_rad/10) max 15;
    private _dots = [_pos,_rad,(round ((6.28*_rad)/_step))] call NWG_DOTS_GenerateDotsCircle;
    private _result = [];

    //Pre-check that there are both water AND ground in given radius
    //(not much sence to search for shores if there is no water or no ground)
    private _waterCount = {surfaceIsWater _x} count _dots;
    if (_waterCount == 0 || {_waterCount == (count _dots)}) exitWith {_result};

    //Find them shores
    private _lastIndex = (count _dots) - 1;
    private ["_prevDot","_nextDot"];
    for "_i" from 0 to _lastIndex do {
        if (surfaceIsWater (_dots#_i)) then {continue};
        _prevDot = if (_i > 0) then {_dots#(_i-1)} else {_dots#_lastIndex};
        _nextDot = if (_i < _lastIndex) then {_dots#(_i+1)} else {_dots#0};
        if (surfaceIsWater _prevDot || {surfaceIsWater _nextDot}) then {
            _result pushBack (_dots#_i);
        };
    };

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Dots manipulation
NWG_DOTS_FindMidpoint = {
    // private _dots = _this;
    private _N = (count _this);
    private _sumX = 0;
    private _sumY = 0;
    //do
    {
        _sumX = _sumX + (_x#0);
        _sumY = _sumY + (_x#1);
    } forEach _this;

    //return
    [(_sumX/_N),(_sumY/_N),0]
};

NWG_DOTS_FindIndexOfNearest = {
    params ["_dots","_pos"];

    private _minDistance = 999999;
    private _index = -1;
    private _dist = 0;

    //do
    {
        _dist = (_x distance _pos);
        if (_dist < _minDistance) then {
            _minDistance = _dist;
            _index = _forEachIndex;
        };
    } forEach _dots;

    //return
    _index
};

NWG_DOTS_FindIndexOfFarthest = {
    params ["_dots","_pos"];

    private _maxDistance = -1;
    private _index = -1;
    private _dist = 0;

    //do
    {
        _dist = (_x distance _pos);
        if (_dist > _maxDistance) then {
            _maxDistance = _dist;
            _index = _forEachIndex;
        };
    } forEach _dots;

    //return
    _index
};

//================================================================================================================
//================================================================================================================
//Dots to useful coordinates
NWG_DOTS_IsPlainSurfaceAt = {
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

NWG_DOTS_FindPlainsRoadsWaterAroundDots = {
    params ["_dots","_searchRad","_searchStep",["_doWater",true]];

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
                if (!(_dot call NWG_DOTS_IsPlainSurfaceAt)) then { continue };
                _water pushBack _dot;
                breakTo "foreach_dots";
            };

            if (isOnRoad _dot) then {
                _dot = getPosWorld (roadAt _dot);
                _dot set [2,0];
                _roads pushBack _dot;
                breakTo "foreach_dots";
            };

            if (_dot call NWG_DOTS_IsPlainSurfaceAt) then {
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
NWG_DOTS_GenerateDotsCircle = {
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

NWG_DOTS_GenerateDotsCloud = {
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

NWG_DOTS_GenerateDottedArea = {
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