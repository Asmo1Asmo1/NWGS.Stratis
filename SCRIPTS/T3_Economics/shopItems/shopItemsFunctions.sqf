/*Other systems->Client*/
//Open shop
NWG_fnc_ishopOpenShop = {
	call NWG_ISHOP_CLI_OpenShop;
};

/*Other systems->Server*/
//Add items to dynamic shop items
//params:
// - _items - array of items to add
//returns: nothing
NWG_fnc_ishopAddDynamicItems = {
	// private _items = _this;
	_this call NWG_ISHOP_SER_AddDynamicItemsExternal;
};

//Upload items price chart to server
//params: items chart
//returns: boolean - true if success, false if failed
NWG_fnc_ishopUploadPrices = {
	// private _itemsChart = _this;
	_this call NWG_ISHOP_SER_UploadPrices;
};

//Download items price chart from server
//params: none
//returns: items chart
NWG_fnc_ishopDownloadPrices = {
	call NWG_ISHOP_SER_DownloadPrices
};

/*Other systems->Server*/
//Evaluate item price
//params: _itemClassname - string
//returns: price - number
NWG_fnc_ishopEvaluateItemPrice = {
	// private _itemClassname = _this;
	(_this call NWG_ISHOP_SER_EvaluateItem)
};

/*Client<->Server*/
//Request shop values from server
NWG_fnc_ishopShopValuesRequest = {
	// private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		(format["NWG_fnc_ishopShopValuesRequest: Invalid player object"]) call NWG_fnc_logError;
	};
	if (isNull _this) exitWith {
		(format["NWG_fnc_ishopShopValuesRequest: Player object is null"]) call NWG_fnc_logError;
	};

	if (isServer)
		then {_this call NWG_ISHOP_SER_OnShopRequest}
		else {_this remoteExec ["NWG_fnc_ishopShopValuesRequest",2]};
};

//Shop values response from server
NWG_fnc_ishopShopValuesResponse = {
	// params ["_playerLoot","_shopItems","_allItems","_allPrices"];
	_this call NWG_ISHOP_CLI_OnServerResponse;
};

//Report transaction to server
NWG_fnc_ishopReportTransaction = {
	// params ["_itemsSoldToPlayer","_itemsBoughtFromPlayer"];
	if (isServer)
		then {_this call NWG_ISHOP_SER_OnTransaction}
		else {_this remoteExec ["NWG_fnc_ishopReportTransaction",2]};
};
