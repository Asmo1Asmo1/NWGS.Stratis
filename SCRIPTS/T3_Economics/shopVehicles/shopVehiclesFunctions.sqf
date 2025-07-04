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

//Add N dynamic items to shop from inner catalogue
//params: _count - number of items to add
NWG_fnc_vshopAddDynamicItems = {
    // private _count = _this;
    _this call NWG_VSHOP_SER_AddDynamicItemsFromCatalogue;
};

//Upload items price chart to server
//params: items chart
//returns: boolean - true if success, false if failed
NWG_fnc_vshopUploadPrices = {
	// private _itemsChart = _this;
	_this call NWG_VSHOP_SER_UploadPrices;
};

//Download items price chart from server
//params: none
//returns: items chart
NWG_fnc_vshopDownloadPrices = {
	call NWG_VSHOP_SER_DownloadPrices
};

//Evaluate vehicle price
//params: _vehClassname - string
//returns: price - number
NWG_fnc_vshopEvaluateVehPrice = {
    // private _vehClassname = _this;
    (_this call NWG_fnc_vcatGetUnifiedClassname) call NWG_VSHOP_SER_EvaluateVeh
};

/*Other systems->Client*/
//Open shop
NWG_fnc_vshopOpenPlatformShop = {
	call NWG_VSHOP_CLI_OpenPlatformShop;
};

//Open custom shop
//params:
// - _interface - interface to use (must contain IDC_SHOPUI_PLAYERMONEYTEXT, IDC_SHOPUI_SHOPDROPDOWN and IDC_SHOPUI_SHOPLIST)
// - _callback - function to call when player bought vehicle (params: _vehicleClassname)
//note: this type of shop supports buying vehicles only, not selling
NWG_fnc_vshopOpenCustomShop = {
    // params ["_interface","_callback"];
	call NWG_VSHOP_CLI_OpenCustomShop;
};

//Refund vehicle price (use in case of error)
//params: _vehicleClassname - string
NWG_fnc_vshopRefund = {
	// private _vehicleClassname = _this;
	_this call NWG_VSHOP_CLI_TRA_Refund;
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
