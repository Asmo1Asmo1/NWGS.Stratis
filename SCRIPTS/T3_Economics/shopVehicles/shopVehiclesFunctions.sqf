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

/*Other systems->Client*/
//Open shop
NWG_fnc_vshopOpenPlatformShop = {
	call NWG_VSHOP_CLI_OpenPlatformShop;
};

/*Client<->Server*/
//Request shop values from server
NWG_fnc_vshopShopValuesRequest = {
	params ["_player","_ownedVehicles"];
	if !(_player isEqualType objNull) exitWith {
		(format["NWG_fnc_vshopShopValuesRequest: Invalid player object"]) call NWG_fnc_logError;
	};
	if (isNull _player) exitWith {
		(format["NWG_fnc_vshopShopValuesRequest: Player object is null"]) call NWG_fnc_logError;
	};

	if (isServer)
		then {_this call NWG_VSHOP_SER_OnShopRequest}
		else {_this remoteExec ["NWG_fnc_vshopShopValuesRequest",2]};
};

//Shop values response from server
NWG_fnc_vshopShopValuesResponse = {
	// params ["_shopItems","_allItems","_allPrices"];
	_this call NWG_VSHOP_CLI_OnServerResponse;
};

//Server adds spawned vehicle to player's sell pool
NWG_fnc_vshopAddVehicleToSellPool = {
	// private _vehicle = _this;
	_this call NWG_VSHOP_CLI_AddVehicleToSellPool;
};

/*Client->Server*/
//Kindly ask server to delete this vehicle
NWG_fnc_vshopDeleteVehicle = {
    // private _vehicle = _this;
    if !(_this isEqualType objNull) exitWith {
        (format ["NWG_fnc_vshopDeleteVehicle: Invalid vehicle object"]) call NWG_fnc_logError;
    };
    if (isNull _this) exitWith {
        (format ["NWG_fnc_vshopDeleteVehicle: Vehicle is null"]) call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_VSHOP_SER_DeleteVehicle}
        else {_this remoteExec ["NWG_fnc_vshopDeleteVehicle",2]};
};

//Kindly ask server to spawn vehicle at platform
NWG_fnc_vshopSpawnVehicleAtPlatform = {
    params ["_player","_vehicleClassname"];
    if !(_player isEqualType objNull) exitWith {
        (format ["NWG_fnc_vshopSpawnVehicleAtPlatform: Invalid player object"]) call NWG_fnc_logError;
    };
    if (isNull _player) exitWith {
        (format ["NWG_fnc_vshopSpawnVehicleAtPlatform: Player object is null"]) call NWG_fnc_logError;
    };
    if !(_vehicleClassname isEqualType "") exitWith {
        (format ["NWG_fnc_vshopSpawnVehicleAtPlatform: Invalid vehicle classname"]) call NWG_fnc_logError;
    };
    if (_vehicleClassname isEqualTo "") exitWith {
        (format ["NWG_fnc_vshopSpawnVehicleAtPlatform: Vehicle classname is empty"]) call NWG_fnc_logError;
    };

    if (isServer)
        then {_this call NWG_VSHOP_SER_SpawnVehicleAtPlatform}
        else {_this remoteExec ["NWG_fnc_vshopSpawnVehicleAtPlatform",2]};
};

//Report transaction
NWG_fnc_vshopReportTransaction = {
	// params ["_itemsSoldToPlayer","_itemsBoughtFromPlayer"];

    if (isServer)
        then {_this call NWG_VSHOP_SER_OnTransaction}
        else {_this remoteExec ["NWG_fnc_vshopReportTransaction",2]};
};
