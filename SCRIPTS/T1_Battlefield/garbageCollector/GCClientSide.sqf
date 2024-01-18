NWG_GC_reportedTrash = [];
NWG_GC_OnPlayerPut = {
    // params ["_unit", "_container", "_item"];
    private _container = _this#1;
    if (_container isKindOf "GroundWeaponHolder" && {!(_container in NWG_GC_reportedTrash)}) then {
        NWG_GC_reportedTrash = (NWG_GC_reportedTrash - [objNull]) + [_container];
        _container call NWG_fnc_gcReportTrash;
    };
};

player addEventHandler ["Put",{_this call NWG_GC_OnPlayerPut}];