//Get steam ID by player name
// params
// 	name - player name
// returns either
// 	[steam ID, player name] - array of two elements
// 	or
// 	"Player not found" - string
// 	"Multiple players found" - string
NWG_fnc_admGetId = {
	// private _name = _this;
	_this call NWG_ADM_GetId
};

//Kick player
// params
// 	steam ID - string
NWG_fnc_admKick = {
	// private _steamId = _this;
	_this call NWG_ADM_Kick
};

//Ban player
// params
// 	steam ID - string
NWG_fnc_admBan = {
	// private _steamId = _this;
	_this call NWG_ADM_Ban
};

//Unban player
// params
// 	steam ID - string
NWG_fnc_admUnban = {
	// private _steamId = _this;
	_this call NWG_ADM_Unban
};
