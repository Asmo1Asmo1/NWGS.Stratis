/*Other systems->Server*/
//Setup spawn platform object (object that new vehicles will spawn on)
//params: _spawnPlatform - object
NWG_fnc_grgSetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_grgSetSpawnPlatformObject: Invalid spawn platform" call NWG_fnc_logError;
    };
    if (isNull _this) exitWith {
        "NWG_fnc_grgSetSpawnPlatformObject: Spawn platform is null" call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_GRG_SER_SetSpawnPlatformObject}
        else {_this remoteExec ["NWG_fnc_grgSetSpawnPlatformObject",2]};
};

//Get garage array of this player
NWG_fnc_grgGetGarageArray = {
    // private _player = _this;
    if !(_this isEqualType objNull) exitWith {
        (format ["NWG_fnc_grgGetGarageArray: Invalid player object"]) call NWG_fnc_logError;
        []
    };
    if (isNull _this) exitWith {
        (format ["NWG_fnc_grgGetGarageArray: Player object is null"]) call NWG_fnc_logError;
        []
    };

    _this call NWG_GRG_GetGarageArray;
};

//Set garage array of this player
NWG_fnc_grgSetGarageArray = {
    params ["_player","_garageArray"];
    if !(_player isEqualType objNull) exitWith {
        (format ["NWG_fnc_grgSetGarageArray: Invalid player object"]) call NWG_fnc_logError;
    };
    if (isNull _player) exitWith {
        (format ["NWG_fnc_grgSetGarageArray: Player object is null"]) call NWG_fnc_logError;
    };

    _this call NWG_GRG_SetGarageArray;
};

/*Other systems->Client*/
//Open garage
NWG_fnc_grgOpen = {
	call NWG_GRG_CLI_OpenGaragePlatform;
};

/*Client<->Server*/
//Kindly ask server to delete this vehicle
NWG_fnc_grgDeleteVehicle = {
    // private _vehicle = _this;
    if !(_this isEqualType objNull) exitWith {
        (format ["NWG_fnc_grgDeleteVehicle: Invalid vehicle object"]) call NWG_fnc_logError;
    };
    if (isNull _this) exitWith {
        (format ["NWG_fnc_grgDeleteVehicle: Vehicle is null"]) call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_GRG_SER_DeleteVehicle}
        else {_this remoteExec ["NWG_fnc_grgDeleteVehicle",2]};
};

//Kindly ask server to spawn vehicle at a platform and apply garage values
NWG_fnc_grgSpawnVehicle = {
    params ["_player","_fullItem"];
    if !(_player isEqualType objNull) exitWith {
        (format ["NWG_fnc_grgSpawnVehicle: Invalid player object"]) call NWG_fnc_logError;
    };
    if (isNull _player) exitWith {
        (format ["NWG_fnc_grgSpawnVehicle: Player object is null"]) call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_GRG_SER_SpawnVehicleAtPlatform}
        else {_this remoteExec ["NWG_fnc_grgSpawnVehicle",2]};
};
