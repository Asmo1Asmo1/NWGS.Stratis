//Checks if the given group is spawned by 'ukrep' subsystem
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_ukrpIsUkrepGroup = {
    // private _group = _this;
    _this getVariable ["NWG_UKREP_ownership",false]
};

//Gets building ID for an object
//params:
// _object - object to get building ID for (can be building, furniture, decoration)
//returns:
// string - building ID or 'false' if not found
NWG_fnc_ukrpGetBuildingID = {
    // private _object = _this;
    _this call NWG_UKREP_BID_GetID
};