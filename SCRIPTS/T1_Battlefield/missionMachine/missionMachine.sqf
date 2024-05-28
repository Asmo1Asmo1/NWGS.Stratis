#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_SER_Settings = createHashMapFromArray [
    ["AUTOSTART",true],//Start the mission machine once the scripts are compiled and game started
    ["AUTOSTART_IN_DEVBUILD",true],//Start even if we are in debug environment

    ["LOG_STATE_CHANGE",true],//Log every state change
    ["HEARTBEAT_RATE",1],//How often the mission machine should check for state changes

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MIS_SER_currentState = MSTATE_SCRIPTS_COMPILATION;
NWG_MIS_SER_cycleHandle = scriptNull;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Check if we should start
    if (!(NWG_MIS_SER_Settings get "AUTOSTART") || {
        (is3DENPreview || is3DENMultiplayer) && !(NWG_MIS_SER_Settings get "AUTOSTART_IN_DEVBUILD")}
    ) exitWith {MSTATE_DISABLED call NWG_MIS_SER_ChangeState};// <- Exit without starting

    //Start
    NWG_MIS_SER_cycleHandle = [] spawn NWG_MIS_SER_Cycle;
};

//================================================================================================================
//================================================================================================================
//Mission machine heartbeat
NWG_MIS_SER_Cycle = {
    private _exit = false;

    waitUntil {
        sleep (NWG_MIS_SER_Settings get "HEARTBEAT_RATE");

        switch (NWG_MIS_SER_currentState) do {
            /* initialization */
            case MSTATE_SCRIPTS_COMPILATION: {MSTATE_MACHINE_STARTUP call NWG_MIS_SER_ChangeState};//Move to the next state
            case MSTATE_DISABLED: {_exit = true};//Exit
            case MSTATE_MACHINE_STARTUP: {MSTATE_BASE_INIT call NWG_MIS_SER_ChangeState};//Move to the next state

            /* world build */
            case MSTATE_BASE_INIT: {
                //TODO: Build the base
            };

            /* missions list */
            case MSTATE_LIST_INIT: {
                //TODO: Build the list of missions
            };

            /* player input expect */
            case MSTATE_READY: {
                //TODO: Wait for player input
            };

            /* mission build */
            case MSTATE_BUILD_UKREP: {
                //TODO: Build the mission using UKREP
            };
            case MSTATE_BUILD_DSPAWN: {
                //TODO: Spawn patrols using DSPAWN
            };
            case MSTATE_BUILD_ECONOMY: {
                //TODO: Fill boxes and vehicles with loot using ECONOMY
            };
            case MSTATE_BUILD_QUESTS: {
                //TODO: Generate side quests using QUESTS
            };

            /* mission playflow */
            case MSTATE_FIGHT_READY: {
                //Mission is ready for players to engage
                //TODO: Check if mission progessed to the next stage
            };
            case MSTATE_FIGHT_INFILTRATION: {
                //Players entered the mission area
                //TODO: Check if mission progessed to the next stage
            };
            case MSTATE_FIGHT_ACTIVE: {
                //Players are fighting with the enemy
                //TODO: Check if mission progessed to the next stage
            };
            case MSTATE_FIGHT_OUT: {
                //Players have left the mission area
                //TODO: Check if mission progessed to the next stage
            };
            case MSTATE_FIGHT_EXHAUSTED: {
                //Players have exhausted the mission
                //TODO: Check if mission progessed to the next stage
            };
            case MSTATE_FIGHT_ABANDONED: {
                //Enemy forces have abandoned the mission
                //TODO: Check if mission progessed to the next stage
            };

            /* mission end */
            case MSTATE_CLEANUP: {
                //Cleanup the mission
                //TODO: Cleanup the mission
            };
            case MSTATE_RESET: {
                //Reset the mission
                //TODO: Reset the mission
            };
            case MSTATE_SERVER_RESTART: {
                //Restart the server
                //TODO: Restart the server
            };

            /* unknown */
            default {
                (format ["NWG_MIS_SER_Cycle: Unknown mission state '%1'",NWG_MIS_SER_currentState]) call NWG_fnc_logError;
                _exit = true;//Exit
            };
        };

        //Check if we should exit
        if (_exit) exitWith {true};

        //Go to the next cycle
        false
    };
};

//================================================================================================================
//================================================================================================================
//State change tracking
NWG_MIS_SER_ChangeState = {
    //Set new state
    private _newState = _this;
    private _oldState = NWG_MIS_SER_currentState;
    NWG_MIS_SER_currentState = _newState;

    //Log
    if (NWG_MIS_SER_Settings get "LOG_STATE_CHANGE") then {
        diag_log formatText ["  [MISSION INFO] #### Mission state changed from: %1 to: %2",
            (_oldState call NWG_MIS_SER_GetStateName),
            (_newState call NWG_MIS_SER_GetStateName)
        ];
    };

    //Raise event
    [EVENT_ON_MISSION_STATE_CHANGED,[_oldState,_newState]] call NWG_fnc_raiseServerEvent;
};

NWG_MIS_SER_GetStateName = {
    // private _state = _this;
    //return
    switch (_this) do {
        case MSTATE_SCRIPTS_COMPILATION: {"SCRIPTS_COMPILATION"};
        case MSTATE_DISABLED:        {"DISABLED"};
        case MSTATE_MACHINE_STARTUP: {"MACHINE_STARTUP"};
        case MSTATE_BASE_INIT: {"BASE_INIT"};
        case MSTATE_LIST_INIT: {"LIST_INIT"};
        case MSTATE_READY: {"READY"};
        case MSTATE_BUILD_UKREP: {"BUILD_UKREP"};
        case MSTATE_BUILD_DSPAWN: {"BUILD_DSPAWN"};
        case MSTATE_BUILD_ECONOMY: {"BUILD_ECONOMY"};
        case MSTATE_BUILD_QUESTS: {"BUILD_QUESTS"};
        case MSTATE_FIGHT_READY: {"FIGHT_READY"};
        case MSTATE_FIGHT_INFILTRATION: {"FIGHT_INFILTRATION"};
        case MSTATE_FIGHT_ACTIVE: {"FIGHT_ACTIVE"};
        case MSTATE_FIGHT_OUT: {"FIGHT_OUT"};
        case MSTATE_FIGHT_EXHAUSTED: {"FIGHT_EXHAUSTED"};
        case MSTATE_FIGHT_ABANDONED: {"FIGHT_ABANDONED"};
        case MSTATE_CLEANUP: {"CLEANUP"};
        case MSTATE_RESET: {"RESET"};
        case MSTATE_SERVER_RESTART: {"SERVER_RESTART"};
        default {"UNKNOWN"};
    }
};

//================================================================================================================
//================================================================================================================
call _Init;