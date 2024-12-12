//================================================================================================================
//================================================================================================================
//Settings
NWG_MARKERS_Settings = createHashMapFromArray [
    ["REFRESH_RATE",1],//How often to refresh markers
    ["HEIGHT_DELTA",5],//If unit is higer/lower than N meters - change marker type
    ["ALLOW_AI_UNITS",true],//Allow AI units to be visible on the map

    ["",0]
];

private _Init = {
    localNamespace setVariable ["NWG_MARKERS_prevTime",0];
    addMissionEventHandler ["EachFrame",{call NWG_MARKERS_Cycle}];
};

//================================================================================================================
//================================================================================================================
//Cycle
NWG_MARKERS_nextRefresh = 0;
NWG_MARKERS_Cycle = {
    if (isNull player || {!alive player}) exitWith {};//Don't draw markers if player is dead or absent
    if (!visibleMap && {!visibleGPS}) exitWith {};//Don't draw markers if there is no map to draw on
    if (time < NWG_MARKERS_nextRefresh) exitWith {};//Check if it's time to refresh
    NWG_MARKERS_nextRefresh = time + (NWG_MARKERS_Settings get "REFRESH_RATE");
    call NWG_MARKERS_Draw;
};

//================================================================================================================
//================================================================================================================
//Icons
#define ICON_UNIT 0
#define ICON_UNIT_HIGHER 1
#define ICON_UNIT_LOWER 2
#define ICON_MEDIC 3
#define ICON_TEAM_LEADER 4
#define ICON_CAR 5
#define ICON_TRUCK 6
#define ICON_TANK 7
#define ICON_HELI 8
#define ICON_PLANE 9
#define ICON_BOAT 10

NWG_MARKERS_icons = [
    "mil_dot"     ,//UNIT
    "mil_triangle",//UNIT_HIGHER
    "mil_box"     ,//UNIT_LOWER (yeah, milbox is lame, but there is no 'upsidedown triangle' icon T_T)
    "loc_heal"    ,//MEDIC
    "loc_move"    ,//TEAM_LEADER
    "loc_car"     ,//CAR
    "loc_Truck"   ,//TRUCK
    "loc_defend"  ,//TANK
    "loc_heli"    ,//HELI
    "loc_plane"   ,//PLANE
    "loc_boat"     //BOAT
];
NWG_MARKERS_GetMarkerTypeForUnit = {
    params ["_unit","_playerAltitude"];

    //Check special cases
    if (_unit isEqualTo (leader (group _unit))) exitWith {ICON_TEAM_LEADER};//Leader of the group
    if (!isNil "NWG_fnc_medIsMedic" && {_unit call NWG_fnc_medIsMedic}) exitWith {ICON_MEDIC};//Medic

    //Check altitude
    private _delta = ((getPosASL _unit)#2) - _playerAltitude;
    switch (true) do {
        case ((abs _delta) <= (NWG_MARKERS_Settings get "HEIGHT_DELTA")): {ICON_UNIT};//Unit on the same level as player
        case (_delta > 0): {ICON_UNIT_HIGHER};//Unit is higher
        default {ICON_UNIT_LOWER};//Unit is lower
    }
};
NWG_MARKERS_GetMarkerTypeForVehicle = {
    // private _vehicle = _this;
    switch (true) do {
        case (_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}): {ICON_TANK};
        case (_this isKindOf "Plane"):      {ICON_PLANE};
        case (_this isKindOf "Helicopter"): {ICON_HELI};
        case (_this isKindOf "Ship"):       {ICON_BOAT};
        case (_this isKindOf "Car"): {(if ((getMass _this) < 10000) then {ICON_CAR} else {ICON_TRUCK})};
        default {-1};//Unknown vehicle (parachute, static weapon, etc)
    }
};

//================================================================================================================
//================================================================================================================
//Draw
NWG_MARKERS_markers = [];
NWG_MARKERS_Draw = {
    //Delete previous markers if any
    {deleteMarkerLocal _x} forEach NWG_MARKERS_markers;
    NWG_MARKERS_markers resize 0;

    //Prepare data to work on
    private _newMarkers = [];
    private _playerAltitude = (getPosASL player)#2;
    private _units = (call NWG_fnc_getPlayersAll) select {alive _x && {(side (group _x)) isEqualTo (side (group player))}};
    if (NWG_MARKERS_Settings get "ALLOW_AI_UNITS") then {
        _units append ((units (group player)) select {alive _x && {!isPlayer _x}});
    };

    private _onFoot = _units select {(vehicle _x) isEqualTo _x};
    private _vehicles = (_units - _onFoot) apply {vehicle _x};
    _vehicles = _vehicles arrayIntersect _vehicles;//Remove duplicates
    private _markerType = 0;
    private _delta = 0;

    //Draw onFoot units
    {
        _markerType = [_x,_playerAltitude] call NWG_MARKERS_GetMarkerTypeForUnit;
        _newMarkers pushBack ([_x,_markerType] call NWG_MARKERS_DrawMarker);
    } forEach _onFoot;

    //Draw vehicle markers
    private _crew = [];
    private _unitToShow = objNull;
    //forEach vehicle
    {
        _crew = crew _x;
        _unitToShow = _crew param [(_crew findIf {_x in _units}),objNull];
        if (isNull _unitToShow) then {continue};
        _markerType = _x call NWG_MARKERS_GetMarkerTypeForVehicle;
        if (_markerType == -1) then {_markerType = [_unitToShow,_playerAltitude] call NWG_MARKERS_GetMarkerTypeForUnit};
        _newMarkers pushBack ([_unitToShow,_markerType,(count _crew)] call NWG_MARKERS_DrawMarker);
    } forEach _vehicles;

    NWG_MARKERS_markers append _newMarkers;
};

NWG_MARKERS_DrawMarker = {
    params ["_unit","_markerType",["_crewCount",0]];

    private _marker = createMarkerLocal [(name _unit),_unit];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal (NWG_MARKERS_icons#_markerType);

    /*Fix marker text for certain types*/
    private _prefix = switch (_markerType) do {
        case ICON_UNIT;
        case ICON_UNIT_HIGHER;
        case ICON_UNIT_LOWER: {""};
        default {" "};
    };
    private _text = if (_crewCount > 0)
        then {format ["%1%2 [%3]",_prefix,(name _unit),_crewCount]}
        else {format ["%1%2",_prefix,(name _unit)]};
    _marker setMarkerTextLocal _text;

    private _group = group _unit;
    private _color = switch (true) do {
        case (!isNil "NWG_fnc_medIsWounded" && {_unit call NWG_fnc_medIsWounded}): {"ColorYellow"};//Wounded
        case (isNil "_group" || {isNull _group}): {"ColorBlack"};//Check possible dynamic groups error
        case (_group isEqualTo (group player)): {"ColorGreen"};//Teammate
        case (!isNil {_group getVariable "NWG_MARKERS_groupColor"}): {_group getVariable "NWG_MARKERS_groupColor"};//Group color set
        default {
            _group call NWG_fnc_markSetGroupColor;
            "ColorBlack"
        };
    };
    _marker setMarkerColorLocal _color;

    //return
    _marker
};

call _Init;