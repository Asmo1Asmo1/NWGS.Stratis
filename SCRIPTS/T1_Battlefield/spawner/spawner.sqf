//================================================================================================================
//================================================================================================================
//Spawn utils
NWG_SPWN_GetSafePrespawnPos = {
    private _safepos = localNamespace getVariable ["NWG_tempSafePos",(
        if (isServer) then {[0,0,100]} else {[0,25,100]}
    )];

    if ((_safepos#2) < 5000) then {_safepos set [2,((_safepos#2) + 25)]} else {_safepos set [2,100]};
    localNamespace setVariable ["NWG_tempSafePos",_safepos];
    if (surfaceIsWater _safepos) then {_safepos = ASLToATL _safepos};
    //return
    _safepos
};

//================================================================================================================
//================================================================================================================
//Vehicle utils
NWG_SPWN_GetOriginalCrew = {
    // private _classname = _this;

    private _vehCfg = configFile >> "CfgVehicles" >> _this;
    private _crewUnit = getText (_vehCfg >> "crew");
    private _crewCount = {
        round getNumber (_x >> "dontCreateAI") < 1 &&
       ((_x == _vehCfg && { round getNumber (_x >> "hasDriver") > 0 }) ||
       (_x != _vehCfg && { round getNumber (_x >> "hasGunner") > 0 }))
    } count ([_this, configNull] call BIS_fnc_getTurrets);

    private _origCrew = [];
    _origCrew resize _crewCount;
    //return
    _origCrew apply {_crewUnit}
};

NWG_SPWN_GetVehicleAppearance = {
    // private _vehicle = _this;
    (_this call BIS_fnc_getVehicleCustomization)
};

NWG_SPWN_SetVehicleAppearance = {
    params ["_vehicle","_appearance"];
    ([_vehicle]+_appearance) call BIS_fnc_initVehicle;
};

NWG_SPWN_GetVehiclePylons = {
    // private _vehicle = _this;
    (getPylonMagazines _this)
};

NWG_SPWN_SetVehiclePylons = {
    params ["_vehicle","_pylons"];

    private _currentPylons = getPylonMagazines _vehicle;
    private _pylonPaths = configProperties [configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"];
    _pylonPaths = _pylonPaths apply {getArray (_x >> "turret")};

    for "_i" from 0 to ((count _currentPylons)-1) do {
        _vehicle removeWeaponGlobal getText (configFile >> "CfgMagazines" >> (_currentPylons#_i) >> "pylonWeapon");
    };

    for "_i" from 0 to ((count _pylons)-1) do {
        _vehicle setPylonLoadout [(_i+1),(_pylons#_i),true,(_pylonPaths#_i)];
    };
};