//================================================================================================================
//================================================================================================================
//Dots generation - Core for other functions

//[150,5] call NWG_SPWB_GenerateDotsCircle_Test
NWG_SPWB_GenerateDotsCircle_Test = {
    params ["_rad","_count"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_rad,_count] call NWG_SPWB_GenerateDotsCircle;
    {[_x,(format ["test_%1",_forEachIndex]),nil,(str _forEachIndex)] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

//[150,15] call NWG_SPWB_GenerateDotsCloud_Test
NWG_SPWB_GenerateDotsCloud_Test = {
    params ["_rad","_count"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_rad,_count] call NWG_SPWB_GenerateDotsCloud;
    {[_x,(format ["test_%1",_forEachIndex])] call NWG_fnc_testPlaceMarker} forEach _dots;

    _dots
};

//[0,150,15] call NWG_SPWB_GenerateDottedArea_Test
NWG_SPWB_GenerateDottedArea_Test = {
    params ["_minRad","_maxRad","_step"];

    call NWG_fnc_testClearMap;
    private _dots = [(getPosWorld player),_minRad,_maxRad,_step] call NWG_SPWB_GenerateDottedArea;
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