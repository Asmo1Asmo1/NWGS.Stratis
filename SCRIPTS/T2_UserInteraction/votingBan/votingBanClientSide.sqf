#include "votingBanDefines.h"

NWG_VOTEBAN_CLI_Settings = createHashMapFromArray [
	/*Settings*/
	["MIN_PLAYER_TO_START_VOTE",3],

	/*Localization*/
	["LOC_ALREADY_RUNNING","#VOTE_BAN_ALREADY_RUNNING#"],
	["LOC_NO_TARGET","#VOTE_BAN_NO_TARGET#"],
	["LOC_NOT_ENOUGH_PLAYERS","#VOTE_BAN_NOT_ENOUGH_PLAYERS#"],

	["",0]
];

NWG_VOTEBAN_CLI_Start = {
	params ["_targetName","_reqType"];

	//Check if another vote is running
	if (call NWG_fnc_voteIsRunning) exitWith {
		(NWG_VOTEBAN_CLI_Settings get "LOC_ALREADY_RUNNING") call NWG_fnc_systemChatMe;
		false
	};

	//Check if there is such player
	private _i = (call NWG_fnc_getPlayersAll) findIf {(name _x) isEqualTo _targetName};
	if (_i == -1) exitWith {
		[(NWG_VOTEBAN_CLI_Settings get "LOC_NO_TARGET"),_targetName] call NWG_fnc_systemChatMe;
		false
	};

	//Check if there are enough players on server to start a vote
	if ((count (call NWG_fnc_getPlayersAll)) < (NWG_VOTEBAN_CLI_Settings get "MIN_PLAYER_TO_START_VOTE")) exitWith {
		[(NWG_VOTEBAN_CLI_Settings get "LOC_NOT_ENOUGH_PLAYERS"),(NWG_VOTEBAN_CLI_Settings get "MIN_PLAYER_TO_START_VOTE")] call NWG_fnc_systemChatMe;
		false
	};

	//Request vote
	[(name player),_targetName,_reqType] remoteExec ["NWG_fnc_voteBanRequest",2];
	true
};
