//================================================================================================================
//================================================================================================================
//Voting
NWG_VOTE_BAN_CLI_VoteBan = {
	private _targetName = _this;

	//Check if another vote is running
	if (call NWG_fnc_voteIsRunning) exitWith {false};//Another vote is running

	//Check if there is such player
	private _i = (call NWG_fnc_getPlayersAll) findIf {(name _x) isEqualTo _targetName};
	if (_i == -1) exitWith {false};//No such player

	//Request vote
	[(name player),_targetName] remoteExec ["NWG_fnc_voteBanRequest",2];
	true
};
