/*Any->Client*/
//Request vote to ban player
//params:
// _targetName - string - name of the player to ban
//returns:
// bool - true if vote was requested and sent to server, false otherwise
NWG_fnc_voteBan = {
	// private _targetName = _this;
	_this call NWG_VOTE_BAN_CLI_VoteBan;
};

/*Client->Server*/
NWG_fnc_voteBanRequest = {
	// params ["_requesterName","_targetName"];
	_this call NWG_VOTE_BAN_SER_OnVoteBanRequest;
};