#include "..\..\globalDefines.h"
/*
    Connector between progress and missionMachine to reward players for completing missions
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_PRG_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed (regular priority)
NWG_PRG_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
	if !(_newState in [MSTATE_COMPLETED,MSTATE_ESCAPE_COMPLETED]) exitWith {};

    private _players = if (_newState == MSTATE_COMPLETED)
        then {(call NWG_fnc_getPlayersAll) select {_x call NWG_fnc_mmWasPlayerOnMission}}
        else {(call NWG_fnc_getPlayersAll) select {_x call NWG_fnc_mmIsPlayerInEscapeVehicle}};

	{
        [_x,P__EXP,1] call NWG_fnc_pAddPlayerProgress;//Add experience
        [_x,P_TEXP,1] call NWG_fnc_pAddPlayerProgress;//Add total experience (level up)
    } forEach _players;
};

//================================================================================================================
call _Init;
