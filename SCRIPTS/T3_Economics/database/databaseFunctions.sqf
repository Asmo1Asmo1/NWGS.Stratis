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

