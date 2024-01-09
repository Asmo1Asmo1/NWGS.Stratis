NWG_fnc_testClearMap = {
    {deleteMarker _x} forEach allMapMarkers;
};

NWG_fnc_testPlaceMarker = {
    params ["_pos","_name",["_color","ColorRed"],["_text",""]];

    private _marker = createMarkerLocal [_name,_pos];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal "mil_dot";
    _marker setMarkerColorLocal _color;
    _marker setMarkerTextLocal _text;
};