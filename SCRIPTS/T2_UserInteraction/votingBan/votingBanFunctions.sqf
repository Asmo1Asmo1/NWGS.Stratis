#include "votingBanDefines.h"

/*Any->Client*/
//Request vote to ban player
//params:
// _targetName - string - name of the player to ban
//returns:
// bool - true if vote was requested and sent to server, false otherwise
NWG_fnc_voteBan = {
	// private _targetName = _this;
	[_this,REQ_BAN] call NWG_VOTEBAN_CLI_Start;
};

//Request vote to kick player
//params:
// _targetName - string - name of the player to kick
//returns:
// bool - true if vote was requested and sent to server, false otherwise
NWG_fnc_voteKick = {
	// private _targetName = _this;
	[_this,REQ_KICK] call NWG_VOTEBAN_CLI_Start;
};

/*Client->Server*/
NWG_fnc_voteBanRequest = {
	// params ["_requesterName","_targetName","_reqType"];
	_this call NWG_VOTEBAN_SER_OnRequest;
};