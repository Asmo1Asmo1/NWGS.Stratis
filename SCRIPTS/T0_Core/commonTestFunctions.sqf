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

NWG_fnc_testDumpToRptAndClipboard = {
    private _array = _this + [];//Shallow copy

    //Convert to strings
    {
        if !(_x isEqualType "")
            then {_array set [_forEachIndex,(str _x)]};
    } forEach _array;

    //Dump to RPT
    diag_log text "==========[       START       ]===========";
    {diag_log (text _x)} forEach _array;
    diag_log text "==========[        END        ]===========";

    //Dump to clipboard
    copyToClipboard (_array joinString (toString [13,10]));//Copy with 'new line' separator

    //Return the array
    _array
};
