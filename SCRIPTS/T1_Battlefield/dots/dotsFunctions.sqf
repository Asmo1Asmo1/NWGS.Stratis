//Markups the trigger area with dots
//params:
//_triggerPos: center of the trigger
//_triggerRad: radius of the trigger
//returns:
//array of positions [_plains,_roads,_water,_roadsAway,_locations,_air]
NWG_fnc_dtsMarkupTrigger = {
    //params ["_triggerPos","_triggerRad"];
    _this call NWG_DOTS_MarkupTrigger
};

//Markups an area with dots
//params:
//_pos: center of the area
//_minRad: radius from center
//_maxRad: maximum radius
//returns:
//array of positions (z is always 0) [_plains,_roads,_water]
NWG_fnc_dtsMarkupArea = {
    //params ["_pos","_minRad","_maxRad"];
    _this call NWG_DOTS_AreaSpawnsearch
};

//Returns the index of the nearest dot to the given position
//params:
//_dots: array of dots
//_pos: position to compare
//returns:
//index of the nearest dot
NWG_fnc_dtsFindIndexOfNearest = {
    //params ["_dots","_pos"];
    _this call NWG_DOTS_FindIndexOfNearest
};

//Returns the index of the farthest dot to the given position
//params:
//_dots: array of dots
//_pos: position to compare
//returns:
//index of the farthest dot
NWG_fnc_dtsFindIndexOfFarthest = {
    //params ["_dots","_pos"];
    _this call NWG_DOTS_FindIndexOfFarthest
};

//Generates a set of random dots inside a circle
//params:
//_pos: center of the circle
//_rad: radius of the circle
//_count: number of dots to generate
//returns:
//array of positions (z is always 0)
NWG_fnc_dtsGenerateDotsCloud = {
    //params ["_pos","_rad","_count"];
    _this call NWG_DOTS_GenerateDotsCloud
};