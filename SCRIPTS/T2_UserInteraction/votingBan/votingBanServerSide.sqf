#include "..\..\secrets.h"
#include "votingBanDefines.h"

NWG_VOTEBAN_SER_Settings = createHashMapFromArray [
	/*Settings*/
	["MIN_PLAYER_TO_START_VOTE",3],//Minimum count of players on server to start a ban vote

	/*Localization*/
	["VOTE_BAN_TITLE","#VOTE_BAN_TITLE#"],
	["VOTE_KICK_TITLE","#VOTE_KICK_TITLE#"],

	["",0]
];

NWG_VOTEBAN_SER_OnRequest = {
	params ["_requesterName","_targetName","_reqType"];

	//Get player objects
	private _allPlayers = call NWG_fnc_getPlayersAll;
	private _i = _allPlayers findIf {(name _x) isEqualTo _requesterName};
	if (_i == -1) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: No such requester player: '%1'",_requesterName]) call NWG_fnc_logError;
		false
	};
	private _requesterPlayer = _allPlayers select _i;
	_i = _allPlayers findIf {(name _x) isEqualTo _targetName};
	if (_i == -1) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: No such target player: '%1'",_targetName]) call NWG_fnc_logError;
		false
	};
	private _targetPlayer = _allPlayers select _i;

	//Get steam IDs
	private _requesterId = getPlayerUID _requesterPlayer;
	if (isNil "_requesterId" || {_requesterId isEqualTo ""}) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Requester player has no steam id: '%1'",_requesterName]) call NWG_fnc_logError;
		false
	};
	private _targetId = getPlayerUID _targetPlayer;
	if (isNil "_targetId" || {_targetId isEqualTo ""}) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Target player has no steam id: '%1'",_targetName]) call NWG_fnc_logError;
		false
	};

	//Determine request type
	private _reqTypeStr = "";
	private _reqTypeCommand = "";
	switch (_reqType) do {
		case REQ_BAN: {
			_reqTypeStr = "BAN";
			_reqTypeCommand = "#exec ban %1";
		};
		case REQ_KICK: {
			_reqTypeStr = "KICK";
			_reqTypeCommand = "#kick %1";
		};
		default {
			(format ["NWG_VOTEBAN_SER_OnRequest: Unknown request type: '%1'",_reqType]) call NWG_fnc_logError;
			false
		};
	};
	if (_reqTypeCommand isEqualTo "") exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Failed to determine request type"]) call NWG_fnc_logError;
		false
	};

	//Log voting attempt
	(format ["NWG_VOTEBAN_SER_OnRequest: '%1' vote requested by: '%2' (id:'%3') to '%4' (id:'%5')",_reqTypeStr,_requesterName,_requesterId,_targetName,_targetId]) call NWG_fnc_logInfo;
	//Check if another vote is running
	if (call NWG_fnc_voteIsRunning) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Another vote is running"]) call NWG_fnc_logError;
		false
	};

	//Check if there are enough players on server to start a vote
	if ((count _allPlayers) < (NWG_VOTEBAN_SER_Settings get "MIN_PLAYER_TO_START_VOTE")) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Not enough players on server to start the vote"]) call NWG_fnc_logInfo;
		false
	};

	//Start voting
	private _title = switch (_reqType) do {
		case REQ_BAN: {NWG_VOTEBAN_SER_Settings get "VOTE_BAN_TITLE"};
		case REQ_KICK: {NWG_VOTEBAN_SER_Settings get "VOTE_KICK_TITLE"};
		default {""};
	};
	private _ok = [_requesterPlayer,[_title,_targetName]] call NWG_fnc_voteRequestServer;
	if (!_ok) exitWith {
		(format ["NWG_VOTEBAN_SER_OnRequest: Failed to start vote"]) call NWG_fnc_logError;
		false
	};

	//Wait for result in a separate thread
	[_targetName,_targetId,_reqTypeStr,_reqTypeCommand] spawn {
		params ["_targetName","_targetId","_reqTypeStr","_reqTypeCommand"];
		//Wait for vote to finish
		waitUntil {sleep 0.25; !(call NWG_fnc_voteIsRunning)};
		//Get vote result
		private _result = call NWG_fnc_voteGetResult;
		if (isNil "_result" || {_result isEqualTo false}) exitWith {
			(format ["NWG_VOTEBAN_SER_OnRequest: Result invalid to '%1' player: '%2' (id:'%3')",_reqTypeStr,_targetName,_targetId]) call NWG_fnc_logError;
		};
		if (_result < 1) exitWith {
			(format ["NWG_VOTEBAN_SER_OnRequest: Players did not vote to '%1' player: '%2' (id:'%3')",_reqTypeStr,_targetName,_targetId]) call NWG_fnc_logInfo;
		};
		//Ban|Kick player
		(format ["NWG_VOTEBAN_SER_OnRequest: Executing '%1' command for player: '%2' (id:'%3')",_reqTypeStr,_targetName,_targetId]) call NWG_fnc_logInfo;
		SERVER_COMMAND_PASSWORD serverCommand (format [_reqTypeCommand,(str _targetId)]);
	};

	//return
	true
};