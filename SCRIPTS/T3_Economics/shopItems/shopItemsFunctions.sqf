#include "..\..\globalDefines.h"

/*Other systems->Client*/
//Open shop
NWG_fnc_ishopOpenShop = {
	call NWG_ISHOP_CLI_OpenShop;
};

/*Other systems->Server*/
//Get persistent items
//params: none
//returns: items chart
NWG_fnc_ishopGetPersistentItems = {
	//return
	NWG_ISHOP_SER_Settings getOrDefault ["SHOP_PERSISTENT_ITEMS",LOOT_ITEM_DEFAULT_CHART]
};

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

//Evaluate item price
//note: sanitizes item classname for weapons and backpacks
//params: _itemClassname - string
//returns: price - number
NWG_fnc_ishopEvaluateItemPrice = {
	// private _itemClassname = _this;
	if (isNil "NWG_fnc_icatGetItemType") exitWith {_this call NWG_ISHOP_SER_EvaluateItem};
	switch (_this call NWG_fnc_icatGetItemType) do {
		case LOOT_ITEM_TYPE_CLTH: {(_this call NWG_fnc_icatGetBaseBackpack) call NWG_ISHOP_SER_EvaluateItem};
		case LOOT_ITEM_TYPE_WEAP: {(_this call NWG_fnc_icatGetBaseWeapon)   call NWG_ISHOP_SER_EvaluateItem};
		default {_this call NWG_ISHOP_SER_EvaluateItem};
	}
};

//Evaluate items price as well as return additional price data
//note: sanitizes item classname for weapons and backpacks
//params: _itemClassname - string
//returns:
// - _price - number - current price
// - _defaultPrice - number - default price
// - _ratio - number - ratio of current price to default price (e.g. 1.5 means 150% of default price)
NWG_fnc_ishopEvaluateItemPriceFull = {
	// private _itemClassname = _this;
	if (isNil "NWG_fnc_icatGetItemType") exitWith {_this call NWG_ISHOP_SER_EvaluateItemFull};
	switch (_this call NWG_fnc_icatGetItemType) do {
		case LOOT_ITEM_TYPE_CLTH: {(_this call NWG_fnc_icatGetBaseBackpack) call NWG_ISHOP_SER_EvaluateItemFull};
		case LOOT_ITEM_TYPE_WEAP: {(_this call NWG_fnc_icatGetBaseWeapon)   call NWG_ISHOP_SER_EvaluateItemFull};
		default {_this call NWG_ISHOP_SER_EvaluateItemFull};
	}
};

//Set new price for item
//note: economics is hard, so try not to overuse this
//note: sanitizes item classname for weapons and backpacks
//params:
// - _itemClassname - string
// - _newPrice - number
//returns: boolean - true if success, false if failed
NWG_fnc_ishopSetItemPrice = {
	params ["_itemClassname","_newPrice"];
	if (isNil "NWG_fnc_icatGetItemType") exitWith {_this call NWG_ISHOP_SER_SetItemPrice};
	_itemClassname = switch (_itemClassname call NWG_fnc_icatGetItemType) do {
		case LOOT_ITEM_TYPE_CLTH: {_itemClassname call NWG_fnc_icatGetBaseBackpack};
		case LOOT_ITEM_TYPE_WEAP: {_itemClassname call NWG_fnc_icatGetBaseWeapon};
		default {_itemClassname};
	};
	[_itemClassname,_newPrice] call NWG_ISHOP_SER_SetItemPrice;
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
