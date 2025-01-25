/*Other systems->Client*/
//Open shop
NWG_fnc_mshopOpenShop = {
	call NWG_MSHOP_CLI_OpenShop;
};

/*Client<->Server*/
//Request shop values from server
//params:
// - player - Object
NWG_fnc_mshopShopValuesRequest = {
	// private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		(format["NWG_fnc_mshopShopValuesRequest: Invalid player object"]) call NWG_fnc_logError;
	};
	if (isNull _this) exitWith {
		(format["NWG_fnc_mshopShopValuesRequest: Player object is null"]) call NWG_fnc_logError;
	};

	if (isServer)
		then {_this call NWG_MSHOP_SER_OnShopRequest}
		else {_this remoteExec ["NWG_fnc_mshopShopValuesRequest",2]};
};

//Shop values response from server
//params:
// - values - Array
NWG_fnc_mshopShopValuesResponse = {
	// private _prices = _this;
	_this call NWG_MSHOP_CLI_OnServerResponse;
};

//On item bought - request to spawn it from client to server
//params:
// - player - Object
// - itemName - String
// - pos - Array
// - moneySpent - Number
NWG_fnc_mshopOnItemBought = {
	// params ["_player","_itemName","_pos","_moneySpent"];
	if (isServer)
		then {_this call NWG_MSHOP_SER_OnItemBought}
		else {_this remoteExec ["NWG_fnc_mshopOnItemBought",2]};
};

//On vehicle bought - request to spawn it from client to server
//params:
// - player - Object
// - vehicleClassname - String
// - pos - Array
NWG_fnc_mshopOnVehicleBought = {
	// params ["_player","_vehicleClassname","_pos"];
	if (isServer)
		then {_this call NWG_MSHOP_SER_OnVehicleBought}
		else {_this remoteExec ["NWG_fnc_mshopOnVehicleBought",2]};
};
