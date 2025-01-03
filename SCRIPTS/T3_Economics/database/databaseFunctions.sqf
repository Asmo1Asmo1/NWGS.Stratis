/*==== Players ====*/
//Get new player record
//params: _playerID
//returns: boolean - true if success, false if failed
NWG_fnc_dbCreatePlayer = {
	// private _playerID = _this;
	_this call NWG_DB_PL_CreateWithId;
};

//Update player record
//params: _playerID, _playerState
//returns: boolean - true if success, false if failed
NWG_fnc_dbUpdatePlayer = {
	// params ["_playerID","_playerState"];
	_this call NWG_DB_PL_UpdateById;
};

//Get player record
//params: _playerID
//returns: _playerRecord OR 'false' if failed or not found
NWG_fnc_dbGetPlayer = {
	// private _playerID = _this;
	_this call NWG_DB_PL_GetById;
};

/*==== Items ====*/
//Load items prices
//params: none
//returns: items chart OR false if failed
NWG_fnc_dbLoadItemPrices = {
	call NWG_DB_PRC_LoadItemPrices;
};

//Save items prices
//params: items chart
//returns: boolean - true if success, false if failed
NWG_fnc_dbSaveItemPrices = {
	// private _itemsChart = _this;
	_this call NWG_DB_PRC_SaveItemPrices;
};

/*==== Vehicles ====*/
//Load vehicles prices
//params: none
//returns: vehicles chart OR false if failed
NWG_fnc_dbLoadVehiclePrices = {
	call NWG_DB_PRC_LoadVehiclePrices;
};

//Save vehicles prices
//params: vehicles chart
//returns: boolean - true if success, false if failed
NWG_fnc_dbSaveVehiclePrices = {
	// private _vehiclesChart = _this;
	_this call NWG_DB_PRC_SaveVehiclePrices;
};

