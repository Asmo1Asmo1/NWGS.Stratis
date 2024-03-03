#include "..\..\globalDefines.h"
/*Check globalDefines for a list of known states*/

//Returns the saved state of the mission
// params: state - string key
// returns: anything set before or nil if not set
NWG_fnc_shGetState = {
    // private _sate = _this;
    _this call NWG_STHLD_GetState
};

//Saves the state for the mission
// params:
//  state - string key
//  value - anything
NWG_fnc_shSetState = {
    params ["_state","_value"];
    _this call NWG_STHLD_SetState;
};

//===================================================================================================
/*Helper functions for a lazy programmer (that's me)*/

//Get the list of occupied buildings
NWG_fnc_shGetOccupiedBuildings = {
    private _occupiedBuildings = BST_OCCUPIED_BUILDINGS call NWG_fnc_shGetState;
    if (isNil "_occupiedBuildings") exitWith {[]};
    _occupiedBuildings
};

//Add a building to the list of occupied buildings
NWG_fnc_shAddOccupiedBuilding = {
    // private _building = _this;
    private _occupiedBuildings = BST_OCCUPIED_BUILDINGS call NWG_fnc_shGetState;
    if (isNil "_occupiedBuildings")
        then {[BST_OCCUPIED_BUILDINGS,[_this]] call NWG_fnc_shSetState}
        else {_occupiedBuildings pushBackUnique _this};
};