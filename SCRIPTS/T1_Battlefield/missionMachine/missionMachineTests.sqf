//================================================================================================================
//================================================================================================================
// Display all the missions available for that map
// call NWG_MIS_SER_ShowAllMissionsOnMap
NWG_MIS_SER_ShowAllMissionsOnMap = {
    call NWG_fnc_testClearMap;

    private _mapName = "Abs" + worldName;
    private _blueprints = [_mapName] call NWG_fnc_ukrpGetBlueprintsABS;
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    if (count _blueprints == 0) exitWith {"No missions available for this map"};

    private ["_pos","_rad","_markerName","_marker"];
    //forEach blueprint container:
    {
        _pos = _x select 2;
        _rad = _x select 4;
        _markerName = format ["%1_%2",_mapName,_forEachIndex];
        _marker = createMarker [_markerName,_pos];
        _marker setMarkerSize [_rad,_rad];
        _marker setMarkerShape "ELLIPSE";
    } forEach _blueprints;
};