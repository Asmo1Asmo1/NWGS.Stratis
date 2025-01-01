#include "..\..\secrets.h"

NWG_ADM_GetId = {
	private _name = toLower _this;
	private _allPlayers = call NWG_fnc_getPlayersAll;
	private _match = _allPlayers select {_name in (toLower (name _x))};
	switch (count _match) do {
		case 0: {"Player not found"};
		case 1: {[(getPlayerUID (_match#0)),(name (_match#0))]};
		default {"Multiple players found"};
	}
};

NWG_ADM_Kick = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#kick %1",(str _this)]);
};
NWG_ADM_Ban = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#exec ban %1",(str _this)]);
};
NWG_ADM_Unban = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#exec unban %1",(str _this)]);
};

