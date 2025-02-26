#include "..\..\secrets.h"

NWG_VOTE_BAN_SER_Settings = createHashMapFromArray [
	/*Localization*/
	["VOTE_BAN_TITLE","#VOTE_BAN_TITLE#"],

	/*Settings*/
	["MIN_PLAYER_TO_START_VOTE",2],//Minimum count of players on server to start a ban vote

	["",0]
];

NWG_VOTE_BAN_SER_OnVoteBanRequest = {
	params ["_requesterName","_targetName"];

	//Get player objects
	private _allPlayers = call NWG_fnc_getPlayersAll;
	private _i = _allPlayers findIf {(name _x) isEqualTo _requesterName};
	if (_i == -1) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: No such player: '%1'",_requesterName]) call NWG_fnc_logError;
		false
	};
	private _requesterPlayer = _allPlayers select _i;
	_i = _allPlayers findIf {(name _x) isEqualTo _targetName};
	if (_i == -1) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: No such player: '%1'",_targetName]) call NWG_fnc_logError;
		false
	};
	private _targetPlayer = _allPlayers select _i;

	//Get steam IDs
	private _requesterId = getPlayerUID _requesterPlayer;
	if (isNil "_requesterId" || {_requesterId isEqualTo ""}) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Requester player has no steam id: '%1'",_requesterName]) call NWG_fnc_logError;
		false
	};
	private _targetId = getPlayerUID _targetPlayer;
	if (isNil "_targetId" || {_targetId isEqualTo ""}) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Target player has no steam id: '%1'",_targetName]) call NWG_fnc_logError;
		false
	};

	//Log voting attempt
	(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Ban vote requested by: '%1' (id:'%2') to ban: '%3' (id:'%4')",_requesterName,_requesterId,_targetName,_targetId]) call NWG_fnc_logInfo;
	//Check if another vote is running
	if (call NWG_fnc_voteIsRunning) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Another vote is running"]) call NWG_fnc_logError;
		false
	};

	//Check if there are enough players on server to start a vote
	if ((count _allPlayers) < (NWG_VOTE_BAN_SER_Settings get "MIN_PLAYER_TO_START_VOTE")) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Not enough players on server to start the vote"]) call NWG_fnc_logInfo;
		false
	};

	//Start voting
	private _title = NWG_VOTE_BAN_SER_Settings get "VOTE_BAN_TITLE";
	private _ok = [_targetPlayer,[_title,_targetName]] call NWG_fnc_voteRequestServer;
	if (!_ok) exitWith {
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Failed to start vote"]) call NWG_fnc_logError;
		false
	};

	//Wait for result in a separate thread
	[_targetName,_targetId] spawn {
		params ["_targetName","_targetId"];
		//Wait for vote to finish
		waitUntil {sleep 0.25; !(call NWG_fnc_voteIsRunning)};
		//Get vote result
		private _result = call NWG_fnc_voteGetResult;
		if (isNil "_result" || {_result isEqualTo false}) exitWith {
			(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Result invalid to ban player: '%1' (id:'%2')",_targetName,_targetId]) call NWG_fnc_logError;
		};
		if (_result < 1) exitWith {
			(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Players did not vote to ban player: '%1' (id:'%2')",_targetName,_targetId]) call NWG_fnc_logInfo;
		};
		//Ban player
		(format ["NWG_VOTE_BAN_SER_OnVoteBanRequest: Banning player: '%1' (id:'%2')",_targetName,_targetId]) call NWG_fnc_logInfo;
		SERVER_COMMAND_PASSWORD serverCommand (format ["#exec ban %1",(str _targetId)]);
	};

	//return
	true
};