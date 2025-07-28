//=============================================================================
/*Server -> GC*/
//Adds provided objects to the oroginal objects list (GC will handle them as if they are original objects of the map and will not delete them)
//params:
// _objects: array of objects to add
NWG_fnc_gcAddOriginalObjects = {
    // private _objects = _this;
    _this call NWG_GC_AddToOriginalObjects
};

//Checks if that object is in the original objects list
//params:
// _object: the object to check
//returns: true if the object is in the original objects list, false otherwise
NWG_fnc_gcIsOriginalObject = {
    // private _object = _this;
    _this in NWG_GC_originalObjects
};

//Adds provided markers to the oroginal markers list (GC will handle them as if they are original markers of the map and will not delete them)
//params:
// _markers: array of markers to add
NWG_fnc_gcAddOriginalMarkers = {
    // private _markers = _this;
    _this call NWG_GC_AddToOriginalMarkers
};

//Deletes the entire mission except the original objects and markers (both originally defined and added by the functions above)
//note: it is better to use 'spawn' to call this function for it may be slow (a lot of objects to delete)
//params:
// _callback: (optional) the code to call after the mission is deleted
NWG_fnc_gcDeleteMission = {
    // params [["_callback",{}]];
    _this call NWG_GC_DeleteMission
};

//Deletes group along with all its units and vehicles
//params:
// _group: the group to delete
NWG_fnc_gcDeleteGroup = {
    // private _group = _this;
    _this call NWG_GC_DeleteGroup
};

//Deletes unit according to 'in vehicle' logic
//params:
// _unit: the unit to delete
NWG_fnc_gcDeleteUnit = {
    // private _unit = _this;
    _this call NWG_GC_DeleteUnit
};

//=============================================================================
/*Server -> Units*/

//Forces the client to delete all user defined markers
NWG_fnc_gcDeleteUserMarkers = {
    {deleteMarker _x} forEach (allMapMarkers select {"_USER_DEFINED" in _x});
};

//=============================================================================
/*Units -> Server*/

//Reports a trash object to the server to be handled
//params:
// _this: the trash object
NWG_fnc_gcReportTrash = {
    // private _trashObject = _this;
    _this call NWG_GC_OnReportTrash
};