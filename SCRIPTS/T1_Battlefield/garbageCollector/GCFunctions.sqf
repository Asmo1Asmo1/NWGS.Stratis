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