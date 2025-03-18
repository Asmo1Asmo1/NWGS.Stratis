#include "..\..\globalDefines.h"
/*
    Connector between shopVehicles and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_WLT_MMC_Settings = createHashMapFromArray [
    ["ESCAPE_REWARD",1000000],//Reward for completing escape mission
    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_WLT_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_WLT_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
    if (_newState != MSTATE_ESCAPE_COMPLETED) exitWith {};

    private _players = (call NWG_fnc_getPlayersAll) select {_x call NWG_fnc_mmIsPlayerInEscapeVehicle};
    private _reward = NWG_WLT_MMC_Settings get "ESCAPE_REWARD";
    {
        [_x,_reward] call NWG_fnc_wltAddPlayerMoney;
    } forEach _players;
};

//================================================================================================================
call _Init;