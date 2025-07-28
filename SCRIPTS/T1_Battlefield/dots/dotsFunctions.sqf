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

//Markups the reinforcement belts, shuffles and groups them by type
//params:
//_pos: center of the area
//_doInf: (optional) should infantry be marked
//_doVeh: (optional) should vehicles be marked
//_doBoat: (optional) should boats be marked
//_doAir: (optional) should air be marked
//returns:
//array of positions [_inf,_veh,_boats,_air]
NWG_fnc_dtsMarkupReinforcement = {
    //params ["_pos",["_doInf",true],["_doVeh",true],["_doBoat",true],["_doAir",true]];
    _this call NWG_DOTS_MarkupReinforcementGrouped
};

//Returns a position for a waypoint
//params:
//_pos: position to search around
//_rad: radius to search
//_type: type of waypoint, can be of "ground"|"water"|"shore"|"air"
//returns:
//position for a waypoint or 'false' if no position was found
NWG_fnc_dtsFindDotForWaypoint = {
    //params ["_pos","_rad","_type"];
    _this call NWG_DOTS_FindDotForWaypoint
};

//Generates a simple patrol route based on the trigger area
//params:
//_trigger: trigger area ([_triggerPos,_triggerRad])
//_type: type of patrol, can be of "ground"|"water"|"air"
//_patrolLength: length of the patrol route to generate
//returns:
//array of positions OR 'false' if no positions were found
NWG_fnc_dtsGenerateSimplePatrol = {
    //params ["_trigger","_type","_patrolLength"];
    _this call NWG_DOTS_GenerateSimplePatrol
};

//Markups an area with dots
//params:
//_pos: center of the area
//_minRad: radius from center
//_maxRad: maximum radius
//_doPlains: (optional) should plains be marked
//_doRoads: (optional) should roads be marked
//_doWater: (optional) should water be marked
//_settingsMultiplier: (optional) multiplier for the default settings (default: 1) (higher values will result in less dots but faster execution)
//returns:
//array of positions (z is always 0) [_plains,_roads,_water]
NWG_fnc_dtsMarkupArea = {
    // params ["_pos","_minRad","_maxRad",["_doPlains",true],["_doRoads",true],["_doWater",true],["_settingsMultiplier",1]];
    _this call NWG_DOTS_AreaSpawnsearch
};

//Returns the midpoint of the given dots
//params:
//_dots: array of dots
//returns:
//position of the midpoint (z is always 0)
NWG_fnc_dtsFindMidpoint = {
    // private _dots = _this;
    _this call NWG_DOTS_FindMidpoint
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

//Generates a circle of dots
//params:
//_pos: center of the circle
//_rad: radius of the circle
//_count: number of dots to generate
//returns:
//array of positions (z is always 0)
NWG_fnc_dtsGenerateDotsCircle = {
    //params ["_pos","_rad","_count"];
    _this call NWG_DOTS_GenerateDotsCircle
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

//Returns random configured air height for air spawn points
//returns:
//number
NWG_fnc_dtsGetAirHeight = {
    (selectRandom (NWG_DOTS_Settings get "AREA_AIR_HEIGHT"))
};

//Returns lowest configured air height for air spawn points
//returns:
//number
NWG_fnc_dtsGetAirHeightMin = {
    (selectMin (NWG_DOTS_Settings get "AREA_AIR_HEIGHT"))
};