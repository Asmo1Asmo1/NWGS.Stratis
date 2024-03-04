//Checks if the given group is spawned by 'ukrep' subsystem
//params:
// _group - group to check
//returns:
// boolean
NWG_fnc_ukrpIsUkrepGroup = {
    // private _group = _this;
    _this getVariable ["NWG_UKREP_ownership",false]
};