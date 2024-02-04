//=============================================================================
/*Server -> GC*/
//Deletes the entire mission, leaves only original objects and markers
//note: it is better to use 'spawn' to call this function for it may be slow (a lot of objects to delete)
//params:
// _callback: (optional) the code to call after the mission is deleted
NWG_fnc_gcDeleteMission = {
    // params [["_callback",{}]];
    _this call NWG_GC_DeleteMission
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