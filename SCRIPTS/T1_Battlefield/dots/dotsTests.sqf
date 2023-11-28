//================================================================================================================
//================================================================================================================
//Trigger markup
// 250 call NWG_DOTS_MarkupTrigger_Test
NWG_DOTS_MarkupTrigger_Test = {
    private _triggerRad = _this;
    private _triggerPos = getPosATL player;

    call NWG_fnc_testClearMap;
    ([_triggerPos,_triggerRad] call NWG_DOTS_MarkupTrigger) params ["_plains","_roads","_water","_roadsAway","_locations","_air"];

    {[_x,(format ["testP_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _plains;
    {[_x,(format ["testR_%1",_forEachIndex]),"ColorOrange"] call NWG_fnc_testPlaceMarker} forEach _roads;
    {[_x,(format ["testW_%1",_forEachIndex]),"ColorBlue"] call NWG_fnc_testPlaceMarker} forEach _water;
    {[_x,(format ["testRA_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _roadsAway;
    {[_x,(format ["testL_%1",_forEachIndex]),"ColorCIV"] call NWG_fnc_testPlaceMarker} forEach _locations;
    {[_x,(format ["testA_%1",_forEachIndex]),"ColorYellow"] call NWG_fnc_testPlaceMarker} forEach _air;
};

//================================================================================================================
//================================================================================================================
//Reinforcements markup
// call NWG_DOTS_MarkupReinforcement_Test
NWG_DOTS_MarkupReinforcement_Test = {
    private _pos = getPosATL player;

    call NWG_fnc_testClearMap;
    (_pos call NWG_DOTS_MarkupReinforcement) params ["_infPlains","_infRoads","_vehPlains","_vehRoads","_boats","_air"];

    {[_x,(format ["testIP_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _infPlains;
    {[_x,(format ["testIR_%1",_forEachIndex]),"ColorOrange"] call NWG_fnc_testPlaceMarker} forEach _infRoads;
    {[_x,(format ["testVP_%1",_forEachIndex]),"ColorKhaki"] call NWG_fnc_testPlaceMarker} forEach _vehPlains;
    {[_x,(format ["testVR_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _vehRoads;
    {[_x,(format ["testB_%1",_forEachIndex]),"ColorBlue"] call NWG_fnc_testPlaceMarker} forEach _boats;
    {[_x,(format ["testA_%1",_forEachIndex]),"ColorYellow"] call NWG_fnc_testPlaceMarker} forEach _air;
};

// [100,"ground"] call NWG_DOTS_FindDotForWaypoint_Test
NWG_DOTS_FindDotForWaypoint_Test = {
    params ["_rad","_type"];
    private _pos = getPosATL player;
    private _color = switch (_type) do {
        case "ground": {"ColorRed"};
        case "shore":  {"ColorGreen"};
        case "water": {"ColorBlue"};
        case "air": {"ColorCIV"};
        default {"ColorBlack"};
    };

    private _dot = [_pos,_rad,_type] call NWG_DOTS_FindDotForWaypoint;
    if (_dot isEqualTo false) exitWith {"No dot found"};

    call NWG_fnc_testClearMap;
    [_dot,"test_dot",_color] call NWG_fnc_testPlaceMarker;
};

//================================================================================================================
//================================================================================================================
//Area spawn points search
// [0,150] call NWG_DOTS_AreaSpawnsearch_Test
NWG_DOTS_AreaSpawnsearch_Test = {
    params ["_minRad","_maxRad"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_minRad,_maxRad] call NWG_DOTS_AreaSpawnsearch;
    _dots params ["_plains","_roads","_water"];
    {[_x,(format ["testP_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _plains;
    {[_x,(format ["testR_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _roads;
    {[_x,(format ["testW_%1",_forEachIndex]),"ColorBlue"] call NWG_fnc_testPlaceMarker} forEach _water;

    [_plains,_roads,_water]
};

//================================================================================================================
//================================================================================================================
//Exotic search
// [500,1000] call NWG_DOTS_FindRoadsAway_Test
NWG_DOTS_FindRoadsAway_Test = {
    params ["_minDistance","_maxDistance"];

    call NWG_fnc_testClearMap;
    private _pos = getPosATL player;
    private _root = [_pos,_maxDistance] call BIS_fnc_nearestRoad;
    if (isNull _root) exitWith {[]};

    private _dots = [(getPosATL _root),_minDistance,_maxDistance] call NWG_DOTS_FindRoadsAway;
    {[_x,(format ["test_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _dots;
};

// [500,1000] call NWG_DOTS_FindLocations_Test
NWG_DOTS_FindLocations_Test = {
    params ["_minRad","_maxRad"];

    call NWG_fnc_testClearMap;
    private _pos = getPosATL player;
    private _dots = [_pos,_minRad,_maxRad] call NWG_DOTS_FindLocations;
    {[_x,(format ["test_%1",_forEachIndex]),"ColorCIV"] call NWG_fnc_testPlaceMarker} forEach _dots;
};

// 250 call NWG_DOTS_FindShores_Test
NWG_DOTS_FindShores_Test = {
    private _rad = _this;

    call NWG_fnc_testClearMap;
    private _pos = getPosATL player;
    private _dots = [_pos,_rad] call NWG_DOTS_FindShores;
    {[_x,(format ["test_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _dots;
};

//================================================================================================================
//================================================================================================================
//Dots manipulation
// call NWG_DOTS_FindMidpoint_Test
NWG_DOTS_FindMidpoint_Test = {
    call NWG_fnc_testClearMap;
    private _dots = [(getPosATL player),150,15] call NWG_DOTS_GenerateDotsCloud;
    private _midpoint = _dots call NWG_DOTS_FindMidpoint;
    {[_x,(format ["test_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _dots;
    [_midpoint,"test_midpoint","ColorBlue"] call NWG_fnc_testPlaceMarker;
    _midpoint
};

// call NWG_DOTS_FindIndexOfNearest_Test
NWG_DOTS_FindIndexOfNearest_Test = {
    call NWG_fnc_testClearMap;
    private _dots = [(getPosATL player),150,15] call NWG_DOTS_GenerateDotsCloud;
    private _nearest = _dots deleteAt ([_dots,(getPosATL player)] call NWG_DOTS_FindIndexOfNearest);
    {[_x,(format ["test_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _dots;
    [_nearest,"test_nearest","ColorBlue"] call NWG_fnc_testPlaceMarker;
    _nearest
};

// call NWG_DOTS_FindIndexOfFarthest_Test
NWG_DOTS_FindIndexOfFarthest_Test = {
    call NWG_fnc_testClearMap;
    private _dots = [(getPosATL player),150,15] call NWG_DOTS_GenerateDotsCloud;
    private _farthest = _dots deleteAt ([_dots,(getPosATL player)] call NWG_DOTS_FindIndexOfFarthest);
    {[_x,(format ["test_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _dots;
    [_farthest,"test_farthest","ColorBlue"] call NWG_fnc_testPlaceMarker;
    _farthest
};

//================================================================================================================
//================================================================================================================
//Dots to useful coordinates
// [0,150,15] call NWG_DOTS_IsPlainSurfaceAt_Test
NWG_DOTS_IsPlainSurfaceAt_Test = {
    params ["_minRad","_maxRad","_step"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_minRad,_maxRad,_step] call NWG_DOTS_GenerateDottedArea;
    _dots = _dots select {_x call NWG_DOTS_IsPlainSurfaceAt};
    {[_x,(format ["test_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

// [0,150,30,20,2] call NWG_DOTS_FindPlainsRoadsWaterAroundDots_Test
NWG_DOTS_FindPlainsRoadsWaterAroundDots_Test = {
    params ["_minRad","_maxRad","_step","_subRad","_subRadStep"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_minRad,_maxRad,_step] call NWG_DOTS_GenerateDottedArea;
    ([_dots,_subRad,_subRadStep] call NWG_DOTS_FindPlainsRoadsWaterAroundDots) params ["_plains","_roads","_water"];

    {[_x,(format ["testP_%1",_forEachIndex]),"ColorGreen"] call NWG_fnc_testPlaceMarker} forEach _plains;
    {[_x,(format ["testR_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _roads;
    {[_x,(format ["testW_%1",_forEachIndex]),"ColorBlue"] call NWG_fnc_testPlaceMarker} forEach _water;

    [_plains,_roads,_water]
};

//================================================================================================================
//================================================================================================================
//Dots generation - Core for other functions

//[150,5] call NWG_DOTS_GenerateDotsCircle_Test
NWG_DOTS_GenerateDotsCircle_Test = {
    params ["_rad","_count"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_rad,_count] call NWG_DOTS_GenerateDotsCircle;
    {[_x,(format ["test_%1",_forEachIndex]),nil,(str _forEachIndex)] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

//[150,15] call NWG_DOTS_GenerateDotsCloud_Test
NWG_DOTS_GenerateDotsCloud_Test = {
    params ["_rad","_count"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_rad,_count] call NWG_DOTS_GenerateDotsCloud;
    {[_x,(format ["test_%1",_forEachIndex])] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

//[0,150,15] call NWG_DOTS_GenerateDottedArea_Test
NWG_DOTS_GenerateDottedArea_Test = {
    params ["_minRad","_maxRad","_step"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_minRad,_maxRad,_step] call NWG_DOTS_GenerateDottedArea;
    {[_x,(format ["test_%1",_forEachIndex])] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

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