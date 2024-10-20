/*Other systems->Server*/
//Setup spawn platform object (object that new vehicles will spawn on)
//params: _spawnPlatform - object
NWG_fnc_vshopSetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_vshopSetSpawnPlatformObject: Invalid spawn platform" call NWG_fnc_logError;
    };
    if (isNull _this) exitWith {
        "NWG_fnc_vshopSetSpawnPlatformObject: Spawn platform is null" call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_VSHOP_SER_SetSpawnPlatformObject}
        else {_this remoteExec ["NWG_fnc_vshopSetSpawnPlatformObject",2]};
};

