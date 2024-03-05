//===================================================================
//ClientSide -> ServerSide
NWG_fnc_markSetGroupColor = {
    // private _group = _this;
    if (isServer)
        then {_this call NWG_MARKERS_OnGroupColorRequest}
        else {_this remoteExec ["NWG_fnc_markSetGroupColor",2]};
};