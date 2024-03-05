NWG_MARKERS_colorCollection = [
    "ColorRed",
    "ColorBlue",
    "ColorCIV",
    "Color2_FD_F",
    "ColorPink",
    "Color4_FD_F",
    "Color5_FD_F",
    "ColorOrange"
];

NWG_MARKERS_OnGroupColorRequest = {
    private _group = _this;
    if (isNull _group) exitWith {"NWG_MARKERS_OnGroupColorRequest: group is null" call NWG_fnc_logError};
    if !(isNil {_group getVariable "NWG_MARKERS_groupColor"}) exitWith {};//Ignore if already set (two clients requested at +/- same time)

    private _color = NWG_MARKERS_colorCollection deleteAt 0;
    NWG_MARKERS_colorCollection pushBack _color;
    _group setVariable ["NWG_MARKERS_groupColor",_color,true];
};