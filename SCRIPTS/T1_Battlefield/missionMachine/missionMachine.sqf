#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_SER_Settings = createHashMapFromArray [
    ["AUTOSTART",true],//Start the mission machine once the scripts are compiled and game started
    ["AUTOSTART_IN_DEVBUILD",true],//Start even if we are in debug environment

    ["PLAYER_BASE_ROOT","PlayerBase"],//Name of pre-placed map object (value of Object:Init -> Variable name) (mandatory for mission machine to work)

    ["LOG_STATE_CHANGE",true],//Log every state change
    ["HEARTBEAT_RATE",1],//How often the mission machine should check for state changes

    ["MISSIONS_BLUEPRINT_PAGENAME","Abs%1"],//Template for where to find mission blueprints for the map
    ["MISSIONS_ESCAPE_BLUEPRINT_PAGENAME","Abs%1Escape"],//Template for where to find escape

    ["MISSIONS_UPDATE_NO_MISSIONS_LOG",true],  //Log error for no missions left
    ["MISSIONS_UPDATE_NO_MISSIONS_RESTART",false],//Go to RESET state if no missions left
    ["MISSIONS_UPDATE_NO_MISSIONS_RUN_ESCAPE",true],//Go to ESCAPE state if no missions left
    ["MISSIONS_UPDATE_NO_MISSIONS_EXIT",false],//Exit heartbeat cycle if no missions left

    ["MISSIONS_SELECT_DISCARD_REJECTED",true],//False - rejected missions go back to the missions list for next selection, True - they get discarded
    ["MISSIONS_SELECT_RESHUFFLE_REJECTED",false],//False - rejected missions simply added to the end of the missions list, True - list gets reshuffled

    ["PLAYER_BASE_RADIUS",70],//How far from base is counted as 'on the base' for players
    ["SERVER_RESTART_ON_ZERO_ONLINE_AFTER",300],//Delay in seconds how long do we wait for someone to join before restarting the server

    /*The rest see in the DATASETS/Server/MissionMachine/Settings.sqf */
    ["COMPLEX_SETTINGS_ADDRESS","DATASETS\Server\MissionMachine\Settings.sqf"],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Global flags
NWG_MIS_CurrentState = MSTATE_SCRIPTS_COMPILATION;
NWG_MIS_NewState = MSTATE_SCRIPTS_COMPILATION;
NWG_MIS_EscapeFlag = false;

//================================================================================================================
//================================================================================================================
//Fields
NWG_MIS_SER_cycleHandle = scriptNull;
NWG_MIS_SER_playerBase = objNull;
NWG_MIS_SER_playerBasePos = [];
NWG_MIS_SER_playerBaseNPCs = [];
NWG_MIS_SER_missionsList = [];
NWG_MIS_SER_selectionList = [];
NWG_MIS_SER_selected = [];

/*mission info property bag*/
NWG_MIS_SER_missionInfo = createHashMap;

/*temp object holders between states*/
NWG_MIS_SER_playerBaseDecoration = [];
NWG_MIS_SER_missionObjects = [];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Check if we should start
    if (!(NWG_MIS_SER_Settings get "AUTOSTART") || {
        (is3DENPreview || is3DENMultiplayer) && !(NWG_MIS_SER_Settings get "AUTOSTART_IN_DEVBUILD")})
        exitWith {MSTATE_DISABLED call NWG_MIS_SER_ChangeState};// <- Exit by settings
    if (isNull (call NWG_MIS_SER_FindPlayerBaseRoot))
        exitWith {MSTATE_DISABLED call NWG_MIS_SER_ChangeState};// <- Exit if no player base root object found on the map

    //Get complex additional settings
    private _addSettings = call ((NWG_MIS_SER_Settings get "COMPLEX_SETTINGS_ADDRESS") call NWG_fnc_compile);
    if (isNil "_addSettings") exitWith {
        "NWG_MIS_SER: Failed to get complex settings - exiting." call NWG_fnc_logError;
        MSTATE_DISABLED call NWG_MIS_SER_ChangeState;
    };// <- Exit if failed to get settings
    {NWG_MIS_SER_Settings set [_x#0,_x#1]} forEach _addSettings;//Merge settings

    //Start
    NWG_MIS_SER_cycleHandle = [] spawn NWG_MIS_SER_Cycle;
};

//================================================================================================================
//================================================================================================================
//Mission machine heartbeat
NWG_MIS_SER_Cycle = {
    private _exit = false;

    waitUntil {
        /*Every heartbeat...*/
        sleep (NWG_MIS_SER_Settings get "HEARTBEAT_RATE");

        /*Update flags and fire events on a first iteration of a new state*/
        if (NWG_MIS_CurrentState isNotEqualTo NWG_MIS_NewState) then {
            //State changed
            private _oldState = NWG_MIS_CurrentState;
            private _newState = NWG_MIS_NewState;
            [_oldState,_newState] call NWG_MIS_SER_OnStateChanged;
            NWG_MIS_CurrentState = _newState;
        };

        /*Do things and calculate next state to switch to*/
        switch (NWG_MIS_CurrentState) do {
            /* initialization */
            case MSTATE_SCRIPTS_COMPILATION: {MSTATE_MACHINE_STARTUP call NWG_MIS_SER_ChangeState};
            case MSTATE_DISABLED: {_exit = true};//Exit
            case MSTATE_MACHINE_STARTUP: {call NWG_MIS_SER_NextState};

            /* world build */
            case MSTATE_WORLD_BUILD: {
                //TODO: Configure the world (time, weather, dynamic simulation, etc.)
                call NWG_MIS_SER_NextState;
            };

            /* base build */
            case MSTATE_BASE_UKREP: {
                private _buildResult = call NWG_MIS_SER_BuildPlayerBase;
                if (_buildResult isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the player base - exiting." call NWG_fnc_logError; _exit = true};//Exit
                _buildResult params ["_root","_objects"];
                NWG_MIS_SER_playerBase = _root;//Save base root object
                NWG_MIS_SER_playerBasePos = getPosASL _root;//Save base position
                NWG_MIS_SER_playerBaseNPCs = _objects param [UKREP_RESULT_UNITS,[]];//Save base NPCs
                NWG_MIS_SER_playerBaseDecoration = _objects;//Save base objects
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BASE_ECONOMY: {
                //TODO: Add base economy
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BASE_QUESTS: {
                //TODO: Add base quests
                NWG_MIS_SER_playerBaseDecoration resize 0;//Release base objects
                call NWG_MIS_SER_NextState;
            };


            /* missions list */
            case MSTATE_LIST_INIT: {
                private _pageName = format [(NWG_MIS_SER_Settings get "MISSIONS_BLUEPRINT_PAGENAME"),(call NWG_fnc_wcGetWorldName)];
                private _missionsList = _pageName call NWG_MIS_SER_GenerateMissionsList;
                if (_missionsList isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to generate missions list - exiting." call NWG_fnc_logError; _exit = true};//Exit
                if ((count _missionsList) == 0) exitWith
                    {"NWG_MIS_SER_Cycle: No missions found for the map at INIT phase - exiting." call NWG_fnc_logError; _exit = true};//Exit
                NWG_MIS_SER_missionsList = _missionsList;//Save the list
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_LIST_UPDATE: {
                private _selectionList = NWG_MIS_SER_missionsList call NWG_MIS_SER_GenerateSelection;
                if (_selectionList isEqualTo []) exitWith {
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_LOG")
                        then {"NWG_MIS_SER_Cycle: Not enough missions at UPDATE phase" call NWG_fnc_logError};
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_RESTART")
                        then {MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState};//Restart server if no missions left
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_EXIT")
                        then {_exit = true};//Exit
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_RUN_ESCAPE")
                        then {MSTATE_ESCAPE_SETUP call NWG_MIS_SER_ChangeState};//Run escape if no missions left
                    if (NWG_MIS_CurrentState isEqualTo MSTATE_LIST_UPDATE && !_exit)
                        then {"NWG_MIS_SER_Cycle: Not enough missions at UPDATE phase and no action taken." call NWG_fnc_logError};//Log at least
                };

                NWG_MIS_SER_selectionList = _selectionList;//Save the selection
                call NWG_MIS_SER_NextState;
            };

            /* player input expect */
            case MSTATE_READY: {
                switch (count NWG_MIS_SER_selectionList) do {
                    case 1: {
                        //Only one mission available (either there was only one mission preset or player made a selection)
                        private _selected = NWG_MIS_SER_selectionList deleteAt 0;//Get the selected mission
                        (_selected#SELECTION_NAME) remoteExec ["NWG_fnc_mmSelectionConfirmed",0];//Send selection made signal to all the clients
                        NWG_MIS_SER_missionInfo = [_selected,NWG_MIS_SER_missionInfo] call NWG_MIS_SER_GenerateMissionInfo;//(Re)Generate mission info
                        call NWG_MIS_SER_NextState;//<-- Move to the next state
                    };
                    case 0: {
                        //No missions available
                        "NWG_MIS_SER_Cycle: No mission selection at READY phase. Must be some kind of error - exiting." call NWG_fnc_logError;
                        _exit = true;//Exit
                    };
                    default {
                        //Waiting for player input
                    };
                }
            };

            /* mission build */
            case MSTATE_BUILD_UKREP: {
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_BuildMission_Markers;//Place markers
                private _ukrep  = NWG_MIS_SER_missionInfo call NWG_MIS_SER_BuildMission_Ukrep;//Build mission
                if (_ukrep isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the mission UKREP - exiting." call NWG_fnc_logError; _exit = true};//Exit

                //Escape injection
                if (NWG_MIS_EscapeFlag) then {
                    //[_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
                    private _escapeVehicle = (_ukrep#UKREP_RESULT_VEHCS) param [0,objNull];
                    if (isNull _escapeVehicle || {!alive _escapeVehicle}) exitWith
                        {"NWG_MIS_SER_Cycle: Escape vehicle not found or dead - exiting." call NWG_fnc_logError; _exit = true};//Exit
                    _escapeVehicle allowDamage false;
                    NWG_MIS_SER_missionInfo set ["EscapeVehicle",_escapeVehicle];
                };

                NWG_MIS_SER_missionObjects = _ukrep;//Save mission objects
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_ECONOMY: {
                //TODO: Fill boxes and vehicles with loot using ECONOMY
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_DSPAWN: {
                private _ok = [NWG_MIS_SER_missionInfo,NWG_MIS_SER_missionObjects] call NWG_MIS_SER_BuildMission_Dspawn;
                if (_ok isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to the mission DSPAWN - exiting." call NWG_fnc_logError; _exit = true};//Exit
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_QUESTS: {
                //TODO: Generate side quests using QUESTS
                NWG_MIS_SER_missionObjects resize 0;//Release mission objects
                call NWG_MIS_SER_NextState;
            };

            /* mission playflow */
            case MSTATE_FIGHT_SETUP: {
                //Mission is being prepared for players to engage
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetup;
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;//Update mission info
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_FIGHT_READY: {
                //Mission is ready for players to engage
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;//Update mission info

                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get "IsRestartCondition"): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsEscape"): {
                        //Players are escaping the island (endgame) (we check that first just in case players somehow managed to shoot an enemy by that time)
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetupExhaustion;//Setup exhaustion
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_AttackPlayerBase;//Attack the player base
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_EscapeStarted;//Send signal to the clients
                        MSTATE_ESCAPE_ACTIVE call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsEngaged"): {
                        //Players are fighting the enemy
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetupExhaustion;//Setup exhaustion
                        MSTATE_FIGHT_ACTIVE call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsInfiltrated"): {
                        //Players entered the mission area
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetupExhaustion;//Setup exhaustion
                        MSTATE_FIGHT_INFILTRATION call NWG_MIS_SER_ChangeState;
                    };
                    default {/*Do nothing*/};
                };
            };
            case MSTATE_FIGHT_INFILTRATION: {
                //Players entered the mission area
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;
                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get "IsRestartCondition"): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsEngaged"): {
                        //Players are fighting the enemy
                        MSTATE_FIGHT_ACTIVE call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsExhausted"): {
                        //Players have exhausted the mission
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightTeardown;
                        MSTATE_FIGHT_EXHAUSTED call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get "IsAllPlayersOnBase"): {
                        //Players are back on the base (after sneaking into the mission area and out without a fight)
                        MSTATE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    default {/*Do nothing*/};
                };
            };
            case MSTATE_FIGHT_ACTIVE: {
                //Players are fighting the enemy
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;
                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get "IsRestartCondition"): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get "IsExhausted"): {
                        //Players have exhausted the mission
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightTeardown;
                        MSTATE_FIGHT_EXHAUSTED call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get "IsAllPlayersOnBase" && {NWG_MIS_SER_missionInfo get "IsInfiltrated"}): {
                        //Players are back on the base after visiting the mission area at least once
                        MSTATE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    default {/*Do nothing*/};
                };
            };
            case MSTATE_FIGHT_EXHAUSTED: {
                //Players have exhausted the mission
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;
                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get "IsRestartCondition"): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get "IsAllPlayersOnBase" && {NWG_MIS_SER_missionInfo get "IsInfiltrated"}): {
                        //Players are back on the base after visiting the mission area at least once
                        MSTATE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    default {/*Do nothing*/};
                };
            };

            /* mission end */
            case MSTATE_COMPLETED: {
                //Mission is completed
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightTeardown;
                (NWG_MIS_SER_missionInfo get "Name") remoteExec ["NWG_fnc_mmMissionCompleted",0];//Send selection made signal to all the clients
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_CLEANUP: {
                //Cleanup the mission
                [] call NWG_fnc_gcDeleteMission;
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_MarkMissionDone;//Mark mission as done on the map
                (call NWG_fnc_shGetOccupiedBuildings) resize 0;//Release occupied buildings
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_RESET: {
                //Reset the mission
                MSTATE_LIST_UPDATE call NWG_MIS_SER_ChangeState;//<- Go back to the mission selection
            };
            case MSTATE_SERVER_RESTART: {
                //Restart the server
                call NWG_MIS_SER_ServerRestart;
                _exit = true;//Exit
            };

            /* escape phase */
            case MSTATE_ESCAPE_SETUP: {
                //Gather escape missions
                private _pageName = format [(NWG_MIS_SER_Settings get "MISSIONS_ESCAPE_BLUEPRINT_PAGENAME"),(call NWG_fnc_wcGetWorldName)];
                private _missionsList = _pageName call NWG_MIS_SER_GenerateMissionsList;
                if (_missionsList isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to generate escape missions list - exiting." call NWG_fnc_logError; MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState};//Exit
                if ((count _missionsList) == 0) exitWith
                    {"NWG_MIS_SER_Cycle: No missions found for the escape - exiting." call NWG_fnc_logError; MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState};//Exit
                NWG_MIS_SER_missionsList = _missionsList;//Save the list
                //Generate escape selection
                private _selectionList = NWG_MIS_SER_missionsList call NWG_MIS_SER_GenerateSelection;
                if (_selectionList isEqualTo []) exitWith
                    {"NWG_MIS_SER_Cycle: No escape missions available - exiting." call NWG_fnc_logError; MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState};//Exit
                NWG_MIS_SER_selectionList = _selectionList;//Save the selection
                //Give players a choice
                NWG_MIS_EscapeFlag = true;
                MSTATE_READY call NWG_MIS_SER_ChangeState;//<- Go to the player input expect (select escape route just like regular mission)
            };
            case MSTATE_ESCAPE_ACTIVE: {
                //Players are escaping the island
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;
                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get "IsRestartCondition"): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get "IsExhausted"): {
                        //Players have failed to escape in time
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightTeardown;
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get "IsAllPlayersInEscapeVehicle"): {
                        //Players have escaped the island
                        MSTATE_ESCAPE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    default {
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_EscapeTick;//Tick the escape mission
                    };
                };
            };
            case MSTATE_ESCAPE_COMPLETED: {
                call NWG_MIS_SER_EscapeCompleted;//Escape is completed
                MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
            };

            /* unknown */
            default {
                (format ["NWG_MIS_SER_Cycle: Unknown mission state '%1'",NWG_MIS_CurrentState]) call NWG_fnc_logError;
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
    //Setup new state
    NWG_MIS_NewState = _this;

    //Raise one last event on disabled
    if (_this isEqualTo MSTATE_DISABLED)
        then {[NWG_MIS_CurrentState,_this] call NWG_MIS_SER_OnStateChanged};
};

NWG_MIS_SER_NextState = {
    //Set new state based on the current one
    NWG_MIS_NewState = (NWG_MIS_CurrentState + 1);
};

NWG_MIS_SER_OnStateChanged = {
    params ["_oldState","_newState"];

    //Log
    if (NWG_MIS_SER_Settings get "LOG_STATE_CHANGE") then {
        diag_log formatText ["  [MISSION INFO] #### Mission state changed from: %1 to: %2",
            (_oldState call NWG_MIS_SER_GetStateName),
            (_newState call NWG_MIS_SER_GetStateName)
        ];
    };

    //Raise event
    [EVENT_ON_MISSION_STATE_CHANGED,[_oldState,_newState]] call NWG_fnc_raiseServerEvent;

    //Update global flag for the clients
    publicVariable "NWG_MIS_CurrentState";
};

NWG_MIS_SER_GetStateName = {
    // private _state = _this;
    //return
    switch (_this) do {
        case MSTATE_SCRIPTS_COMPILATION: {"SCRIPTS_COMPILATION"};
        case MSTATE_DISABLED:        {"DISABLED"};
        case MSTATE_MACHINE_STARTUP: {"MACHINE_STARTUP"};
        case MSTATE_WORLD_BUILD:    {"WORLD_BUILD"};
        case MSTATE_BASE_UKREP:     {"BASE_UKREP"};
        case MSTATE_BASE_ECONOMY:   {"BASE_ECONOMY"};
        case MSTATE_BASE_QUESTS:    {"BASE_QUESTS"};
        case MSTATE_LIST_INIT:   {"LIST_INIT"};
        case MSTATE_LIST_UPDATE: {"LIST_UPDATE"};
        case MSTATE_READY: {"READY"};
        case MSTATE_BUILD_UKREP:   {"BUILD_UKREP"};
        case MSTATE_BUILD_ECONOMY: {"BUILD_ECONOMY"};
        case MSTATE_BUILD_DSPAWN:  {"BUILD_DSPAWN"};
        case MSTATE_BUILD_QUESTS:  {"BUILD_QUESTS"};
        case MSTATE_FIGHT_SETUP: {"FIGHT_SETUP"};
        case MSTATE_FIGHT_READY: {"FIGHT_READY"};
        case MSTATE_FIGHT_INFILTRATION: {"FIGHT_INFILTRATION"};
        case MSTATE_FIGHT_ACTIVE:       {"FIGHT_ACTIVE"};
        case MSTATE_FIGHT_EXHAUSTED: {"FIGHT_EXHAUSTED"};
        case MSTATE_COMPLETED: {"COMPLETED"};
        case MSTATE_CLEANUP: {"CLEANUP"};
        case MSTATE_RESET:   {"RESET"};
        case MSTATE_SERVER_RESTART: {"SERVER_RESTART"};
        case MSTATE_ESCAPE_SETUP: {"ESCAPE_SETUP"};
        case MSTATE_ESCAPE_ACTIVE: {"ESCAPE_ACTIVE"};
        case MSTATE_ESCAPE_COMPLETED: {"ESCAPE_COMPLETED"};
        default {"UNKNOWN"};
    }
};

//================================================================================================================
//================================================================================================================
//Player Base building
NWG_MIS_SER_FindPlayerBaseRoot = {
    missionNamespace getVariable [(NWG_MIS_SER_Settings get "PLAYER_BASE_ROOT"),objNull]
};

NWG_MIS_SER_BuildPlayerBase = {
    //1. Find a root object on the map
    private _playerBaseRoot = call NWG_MIS_SER_FindPlayerBaseRoot;//Pre-defined root object on the map
    if (isNull _playerBaseRoot) exitWith {
        (format ["NWG_MIS_SER_BuildPlayerBase: Object '%1' not found on the map! Unable to build a player base",(NWG_MIS_SER_Settings get "PLAYER_BASE_ROOT")]) call NWG_fnc_logError;
        false// <- Exit if no root object found
    };

    //2. Build a base around it
    private _pageName = NWG_MIS_SER_Settings get "PLAYER_BASE_BLUEPRINT";
    private _buildResult = [
        _pageName,
        _playerBaseRoot,
        /*rootType:*/"",
        /*blueprintFilter:*/"",
        /*chances:*/[],
        /*faction:*/"",
        /*groupRules:*/[/*membership:*/"AGENT",/*dynamic simulation:*/true],
        /*adaptToGround:*/true,
        /*suppressEvent*/true
    ] call NWG_fnc_ukrpBuildAroundObject;
    if (_buildResult isEqualTo false || {(flatten _buildResult) isEqualTo []}) exitWith {
        (format ["NWG_MIS_SER_BuildPlayerBase: Failed to build a player base around object '%1' using blueprint '%2'",(NWG_MIS_SER_Settings get "PLAYER_BASE_ROOT"),_pageName]) call NWG_fnc_logError;
        false// <- Exit if failed to build a base
    };

    //3. Configure the base objects
    //_buildResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    call {
        //3.1 Disable damage for every object
        _playerBaseRoot allowDamage false;
        {_x allowDamage false} forEach (flatten _buildResult);

        //3.2 Lock every vehicle
        {_x lock true} forEach (_buildResult param [UKREP_RESULT_VEHCS,[]]);

        //3.3 Clear and lock inventory of every object that has it
        {
            clearWeaponCargoGlobal _x;
            clearMagazineCargoGlobal _x;
            clearItemCargoGlobal _x;
            clearBackpackCargoGlobal _x;
            [_x,true] remoteExecCall ["lockInventory",0,_x];//Lock it JIP compatible
        } forEach ((flatten _buildResult) select {
            !(_x isKindOf "Man") && {
            !(isSimpleObject _x) && {
            _x canAdd "FirstAidKit"}}
        });

        //3.4 Configure base NPCs
        private _npcSettings = NWG_MIS_SER_Settings get "PLAYER_BASE_NPC_SETTINGS";
        {
            //Setup dynamic simulation regardless of the group rules for each agent
            _x enableDynamicSimulation true;

            //Check if NPC settings are defined for this type
            if !((typeOf _x) in _npcSettings) then {
                (format ["NWG_MIS_SER_BuildPlayerBase: NPC settings for '%1' not found in the settings!",typeOf _x]) call NWG_fnc_logError;
                continue
            };

            //Configure NPC
            (_npcSettings get (typeOf _x)) params ["_disarm","_anim","_addAction"];

            //Remove weapons
            if (_disarm) then {removeAllWeapons _x};

            //Set animation
            if (_anim isNotEqualTo false) then {
                _anim = if (_anim isEqualType "")
                    then {_anim}
                    else {selectRandom _anim};
                [_x,_anim] remoteExecCall ["NWG_fnc_playAnimRemote",0,_x];//Make it JIP compatible + ensure unscheduled environment
                _x disableAI "ANIM";//Fix AI switching out of the animation (works even for agents)
            };

            //Add action
            if (_addAction isNotEqualTo false) then {
                _x addAction _addAction;//TODO: Conditions, distance and JIP compatibility
            };
        } forEach (_buildResult param [UKREP_RESULT_UNITS,[]]);
    };

    //4. Report to garbage collector that these objects are not to be deleted
    (flatten _buildResult) call NWG_fnc_gcAddOriginalObjects;

    //5. Place markers
    private _markers = call {
        private _i = 0;
        private _markerSize = NWG_MIS_SER_Settings get "PLAYER_BASE_MARKERS_SIZE";
        private ["_markerName","_marker"];
        (NWG_MIS_SER_Settings get "PLAYER_BASE_MARKERS") apply {
            _markerName = format ["playerBase_%1",_i]; _i = _i + 1;
            _marker = createMarker [_markerName,_playerBaseRoot];
            _marker setMarkerShape "icon";
            _marker setMarkerType _x;
            _marker setMarkerSize [_markerSize,_markerSize];
            _markerName
        }
    };

    //6. Report to garbage collector that these markers are not to be deleted
    _markers call NWG_fnc_gcAddOriginalMarkers;

    //7. Return result
    [_playerBaseRoot,_buildResult]
};

//================================================================================================================
//================================================================================================================
//Missions list generation
NWG_MIS_SER_GenerateMissionsList = {
    private _pageName = _this;

    //1. Get all missions available for this map
    private _blueprints = _pageName call NWG_fnc_ukrpGetCataloguePage;
    if (_blueprints isEqualTo false || {(count _blueprints) == 0}) exitWith {
        (format ["NWG_MIS_SER_GenerateMissionsList: Failed to get missions list for page '%1'",_pageName]) call NWG_fnc_logError;
        false// <- Exit if no missions found
    };

    //2. Shuffle and filter
    _blueprints = _blueprints + [];//Shallow copy
    _blueprints = _blueprints call NWG_fnc_arrayShuffle;//Shuffle
    _blueprints = _blueprints call NWG_fnc_arrayShuffle;//Shuffle again (why not?)
    private _missionsList = [];
    private _minDistance = NWG_MIS_SER_Settings get "MISSIONS_LIST_MIN_DISTANCE";
    private ["_pos","_i"];
    //forEach blueprint container:
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    {
        _pos = _x#2;
        _i = _missionsList findIf {(_pos distance2D (_x#2)) <= _minDistance};
        if (_i == -1) then {_missionsList pushBack _x};
    } forEach _blueprints;

    //3. Return
    _missionsList
};

NWG_MIS_SER_GenerateSelection = {
    private _missionsList = _this;

    //1. Get settings
    private _missionPresets = NWG_MIS_SER_Settings get "MISSIONS_PRESETS";
    private _selectionCount = count _missionPresets;

    //2. Check if we have enough missions to select from
    if ((count _missionsList) < _selectionCount) exitWith {
        (format ["NWG_MIS_SER_GenerateSelection: Not enough missions to select from! missions count: %1, selection count: %2",(count _missionsList),_selectionCount]) call NWG_fnc_logError;
        []
    };

    //3. Generate selection list
    //By that stage we already have a randomized list of missions with unique positions, so we can just take the first N elements
    private _selectionList = [];
    for "_i" from 0 to (_selectionCount-1) do {
        private _ukrep = _missionsList deleteAt 0;
        private _settings = _missionPresets select _i;
        //_ukrep: [UkrepType,UkrepName,ABSPos,[0,0,0],Radius,0,Payload,Blueprint]
        _ukrep params ["_","_name","_pos","_","_rad"];
        _name = (_name splitString "_") param [0,"Unknown"];//Extract mission name 'Name_var01' -> 'Name'
        _selectionList pushBack [_name,_pos,_rad,_ukrep,_settings];
    };

    //4. Return
    _selectionList
};

//================================================================================================================
//================================================================================================================
//Missions selection process
NWG_MIS_SER_OnSelectionOptionsRequest = {
    private _caller = remoteExecutedOwner;
    if (isDedicated && _caller <=  0)
        exitWith {format ["NWG_MIS_SER_OnSelectionOptionsRequest: Caller can not be identified! callerID:%1",_caller] call NWG_fnc_logError};
    if (NWG_MIS_CurrentState isNotEqualTo MSTATE_READY)
        exitWith {format ["NWG_MIS_SER_OnSelectionOptionsRequest: Invalid state for selection options request! state: %1",(NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName)] call NWG_fnc_logError};
    if ((count NWG_MIS_SER_selectionList) == 0)
        exitWith {"NWG_MIS_SER_OnSelectionOptionsRequest: No missions available for selection!" call NWG_fnc_logError};

    //Repack selection list for client
    private _options = NWG_MIS_SER_selectionList apply {[
            _x#SELECTION_NAME,
            _x#SELECTION_POS,
            ((_x#SELECTION_SETTINGS) getOrDefault ["PresetName","Unknown"]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["MapMarker","mil_dot"]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["MapMarkerColor","ColorBlack"]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["MapMarkerSize",1]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["MapOutlineAlpha",0.5]),
            if (NWG_MIS_SER_Settings get "MISSIONS_OUTLINE_USE_ACTUAL_RAD")
                then {_x#SELECTION_RAD}
                else {((_x#SELECTION_SETTINGS) getOrDefault ["MapOutlineRadius",100])}
    ]};

    //Send options to the client
    _options remoteExec ["NWG_fnc_mmSendSelectionOptions",_caller];
};

NWG_MIS_SER_OnSelectionMade = {
    private _selectionIndex = _this;

    //Checks
    if (NWG_MIS_CurrentState isNotEqualTo MSTATE_READY)
        exitWith {format ["NWG_MIS_SER_OnSelectionMade: Invalid state for selection made! state:%1",(NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName)] call NWG_fnc_logError};
    if ((count NWG_MIS_SER_selectionList) == 0)
        exitWith {"NWG_MIS_SER_OnSelectionMade: No missions available for selection!" call NWG_fnc_logError};
    if (_selectionIndex < 0 || _selectionIndex >= (count NWG_MIS_SER_selectionList))
        exitWith {format ["NWG_MIS_SER_OnSelectionMade: Invalid selection. index:'%1' selection count:'%2'",_selectionIndex,(count NWG_MIS_SER_selectionList)] call NWG_fnc_logError};

    //Extract selected mission
    private _selected = NWG_MIS_SER_selectionList deleteAt _selectionIndex;

    //Process rejected missions if any
    //selection: [_name,_pos,_rad,->_ukrep<-,_settings]
    if ((count NWG_MIS_SER_selectionList) > 0) then {
        private _rejected = NWG_MIS_SER_selectionList apply {_x#SELECTION_BLUEPRINT};
        NWG_MIS_SER_selectionList resize 0;
        if (NWG_MIS_SER_Settings get "MISSIONS_SELECT_DISCARD_REJECTED") exitWith {};//Discard rejected missions
        {NWG_MIS_SER_missionsList pushBack _x} forEach _rejected;//Return rejected missions back to the list
        if (NWG_MIS_SER_Settings get "MISSIONS_SELECT_RESHUFFLE_REJECTED") then {NWG_MIS_SER_missionsList call NWG_fnc_arrayShuffle};//Reshuffle the list
    };

    //Selection list must contain only one element to proceed
    NWG_MIS_SER_selectionList pushBack _selected;

    //The rest will be handled by the heartbeat cycle
};

//================================================================================================================
//================================================================================================================
//Mission info - property bag of current mission
NWG_MIS_SER_GenerateMissionInfo = {
    params ["_selectedMission",["_missionInfo",createHashMap]];

    //1. Extract mission info from selected mission
    _selectedMission params ["_name","_pos","_rad","_blueprint","_settings"];
    _missionInfo set ["Name",_name];
    _missionInfo set ["Position",_pos];
    _missionInfo set ["Radius",_rad];
    _missionInfo set ["Blueprint",_blueprint];
    _missionInfo set ["Settings",_settings];

    //2. Extract some to the upper level to make it easier to use
    _missionInfo set ["Marker",(_settings getOrDefault ["MapMarker","mil_dot"])];
    _missionInfo set ["MarkerColor",(_settings getOrDefault ["MapMarkerColor","ColorBlack"])];
    _missionInfo set ["MarkerSize",(_settings getOrDefault ["MapMarkerSize",1])];
    _missionInfo set ["OutlineAlpha",(_settings getOrDefault ["MapOutlineAlpha",0.5])];
    _missionInfo set ["OutlineRadius",(
        if (NWG_MIS_SER_Settings get "MISSIONS_OUTLINE_USE_ACTUAL_RAD")
            then {_rad}
            else {(_settings getOrDefault ["MapOutlineRadius",100])}
    )];
    _missionInfo set ["ExhaustAfter",(_settings getOrDefault ["ExhaustAfter",900])];

    //3. Extract values from mission machine and settings
    private _enemySide = NWG_MIS_SER_Settings get "MISSIONS_ENEMY_SIDE";
    private _enemyFaction = NWG_MIS_SER_Settings get "MISSIONS_ENEMY_FACTION";
    _missionInfo set ["EnemySide",_enemySide];
    _missionInfo set ["EnemyFaction",_enemyFaction];

    //4. Escape addition
    _missionInfo set ["EscapeVehicle",objNull];

    //5. Return
    _missionInfo
};

//================================================================================================================
//================================================================================================================
//Mission building
NWG_MIS_SER_BuildMission_Markers = {
    // private _missionInfo = _this;
    private _pos = _this get "Position";
    private _rad = _this get "Radius";

    private _markerType   = _this get "Marker";
    private _markerColor  = _this get "MarkerColor";
    private _markerSize   = _this get "MarkerSize";
    private _outlineAlpha = _this get "OutlineAlpha";
    private _outlineRad   = _this get "OutlineRadius";

    //Create background outline
    private _outline = createMarker ["MIS_BuildMission_Outline",_pos];
    _outline setMarkerSize [_outlineRad,_outlineRad];
    _outline setMarkerShape "ELLIPSE";
    _outline setMarkerColor _markerColor;
    _outline setMarkerAlpha _outlineAlpha;

    //Create mission marker
    private _marker = createMarker ["MIS_BuildMission_Marker",_pos];
    _marker setMarkerType _markerType;
    _marker setMarkerSize [_markerSize,_markerSize];
    _marker setMarkerColor _markerColor;
};

NWG_MIS_SER_BuildMission_Ukrep = {
    // private _missionInfo = _this;

    //Cache map buildings in the area
    private _mapEmptyBldgs = ((_this get "Position") nearObjects (_this get "Radius")) select {_x call NWG_fnc_ocIsBuilding};

    //Build the mission by the blueprint
    private _fractalSteps = (_this get "Settings") getOrDefault ["UkrepFractalSteps",[]];
    private _faction = _this get "EnemyFaction";
    private _mapBldgsLimit = (_this get "Settings") getOrDefault ["UkrepMapBldgsLimit",10];
    private _overrides = createHashMapFromArray [
        ["RootBlueprint",(_this get "Blueprint")],
        ["GroupsMembership",(_this get "EnemySide")]
    ];
    private _bldResult = [_fractalSteps,_faction,_mapBldgsLimit,_overrides] call NWG_fnc_ukrpBuildFractalABS;

    //Find any map buildings that were left unused
    private _occupiedBldgs = call NWG_fnc_shGetOccupiedBuildings;
    private _emptyBldgPageName = NWG_MIS_SER_Settings get "MISSIONS_EMPTY_BLDG_PAGENAME";
    private _emptyBldgsLimit = (_this get "Settings") getOrDefault ["UkrepMapBldgsEmptyLimit",5];
    _mapEmptyBldgs = _mapEmptyBldgs select {
        !(_x in _occupiedBldgs) && {
        [_x,OBJ_TYPE_BLDG,_emptyBldgPageName] call NWG_fnc_ukrpHasRelSetup}
    };
    if ((count _mapEmptyBldgs) > _emptyBldgsLimit) then {_mapEmptyBldgs call NWG_fnc_arrayShuffle; _mapEmptyBldgs resize _emptyBldgsLimit};//Shuffle and limit

    //Fill unused buildings with 'empty' decor (partial, low object number decorations just for the looks)
    {
        private _emptResult = [_emptyBldgPageName,_x,OBJ_TYPE_BLDG] call NWG_fnc_ukrpBuildAroundObject;
        if (_emptResult isEqualTo false) then {continue};//Skip if failed to build
        {(_bldResult#_forEachIndex) append _x} forEach _emptResult;
    } forEach _mapEmptyBldgs;

    //Return the result
    _bldResult
};

NWG_MIS_SER_BuildMission_Dspawn = {
    params ["_missionInfo","_ukrepObjects"];

    //Unpack data
    private _missionPos = _missionInfo get "Position";
    private _missionRad = _missionInfo get "Radius";
    private _settings   = _missionInfo get "Settings";

    //Calculate the DSPAWN area to patrol
    private _radiusMult = _settings getOrDefault ["DspawnRadiusMult",1.5];
    private _radiusMin  = _settings getOrDefault ["DspawnRadiusMin",150];
    private _radiusMax  = _settings getOrDefault ["DspawnRadiusMax",200];
    _missionRad = _missionRad * _radiusMult;
    _missionRad = (_missionRad max _radiusMin) min _radiusMax;//Clamp
    _missionInfo set ["Dspawn_Area",[_missionPos,_missionRad]];//Save for future use

    //Calculate the DSPAWN reinforcment map
    //["_pos",["_doInf",true],["_doVeh",true],["_doBoat",true],["_doAir",true]] call NWG_fnc_dtsMarkupReinforcement
    private _reinfMap = [_missionPos,true,true,true,true] call NWG_fnc_dtsMarkupReinforcement;
    _missionInfo set ["Dspawn_ReinforcementMap",_reinfMap];//Save for future use

    //Calculate groups to spawn count
    private _groupsMult = _settings getOrDefault ["DspawnGroupsMult",1];
    private _groupsMin  = _settings getOrDefault ["DspawnGroupsMin",2];
    private _groupsMax  = _settings getOrDefault ["DspawnGroupsMax",5];
    // _ukrepObjects params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    private _ukrepGroups = ((_ukrepObjects#3) + (_ukrepObjects#4) + (_ukrepObjects#5)) apply {group _x};
    _ukrepGroups = _ukrepGroups arrayIntersect _ukrepGroups;//Remove duplicates
    private _groupsCount = round ((count _ukrepGroups) * _groupsMult);
    _groupsMin = if (_groupsMin isEqualType [])
        then {selectRandom _groupsMin}
        else {_groupsMin};
    _groupsMax = if (_groupsMax isEqualType [])
        then {selectRandom _groupsMax}
        else {_groupsMax};
    _groupsCount = (_groupsCount max _groupsMin) min _groupsMax;//Clamp

    private _faction = _missionInfo get "EnemyFaction";
    private _side = _missionInfo get "EnemySide";

    //populate and return the result
    [[_missionPos,_missionRad],_groupsCount,_faction,[],_side] call NWG_fnc_dsPopulateTrigger
};

//================================================================================================================
//================================================================================================================
//Fight stages
NWG_MIS_SER_FightSetup = {
    // private _missionInfo = _this;

    //Configure and enable the YellowKing system
    // params ["_kingSide","_reinfSide","_reinfFaction","_reinfMap"];
    [
        (_this get "EnemySide"),
        (_this get "EnemySide"),
        (_this get "EnemyFaction"),
        (_this get "Dspawn_ReinforcementMap")
    ] call NWG_fnc_ykConfigure;

    private _ok = call NWG_fnc_ykEnable;
    if (!_ok) then {"NWG_MIS_SER_FightSetup: Failed to enable the YellowKing system. Is it enabled already?" call NWG_fnc_logError};

    //Update mission info with default values
    _this set ["PlayersOnline",-1];
    _this set ["PlayersOnMission",-1];
    _this set ["PlayersOnBase",-1];

    _this set ["LastPlayerOnlineAt",-1];
    _this set ["IsRestartCondition",false];
    _this set ["IsAllPlayersOnBase",false];
    _this set ["IsInfiltrated",false];
    _this set ["IsEngaged",false];
    _this set ["IsExhausted",false];
    _this set ["WillExhaustAt",-1];
    _this set ["IsEscape",false];
    _this set ["IsAllPlayersInEscapeVehicle",false];

    //return
    _this
};

NWG_MIS_SER_FightSetupExhaustion = {
    // private _missionInfo = _this;
    private _curTime = round time;
    private _exhaustAfter = _this get "ExhaustAfter";
    _this set ["WillExhaustAt",(_curTime + _exhaustAfter)];
    //return
    _this
};

NWG_MIS_SER_FightUpdateMissionInfo = {
    private _info = _this;
    private _players = call NWG_fnc_getPlayersOrOccupiedVehicles;//It's ok to count 6 people in a heli as one player - doesn't make much difference in our case
    private _curTime = round time;

    //1. Update player counters
    private _playersOnline = (count _players);
    private _playersOnMission = call {
        private _missionPos = _info get "Position";
        private _missionRad = _info get "Radius";
        {(_x distance2D _missionPos) <= _missionRad} count _players
    };
    private _playersOnBase = call {
        private _basePos = NWG_MIS_SER_playerBasePos;
        private _baseRad = NWG_MIS_SER_Settings get "PLAYER_BASE_RADIUS";
        {(_x distance2D _basePos) <= _baseRad} count _players
    };

    _info set ["PlayersOnline",_playersOnline];
    _info set ["PlayersOnMission",_playersOnMission];
    _info set ["PlayersOnBase",_playersOnBase];

    //2. Server restart condition (may be on-off)
    if (_playersOnline > 0) then {
        _info set ["LastPlayerOnlineAt",_curTime];
        _info set ["IsRestartCondition",false];
    } else {
        private _lastOnline = _info get "LastPlayerOnlineAt";
        private _restartDelay = NWG_MIS_SER_Settings get "SERVER_RESTART_ON_ZERO_ONLINE_AFTER";
        private _restartAt = _lastOnline + _restartDelay;
        _info set ["IsRestartCondition",(_curTime >= _restartAt)];
    };

    //3. All players on base condition (may be on-off)
    _info set ["IsAllPlayersOnBase",(_playersOnBase == _playersOnline && {_playersOnline > 0})];

    //4. Mission infiltration condition (one time switch on)
    if !(_info get "IsInfiltrated") then {
        _info set ["IsInfiltrated",(_playersOnMission > 0)];//Set 'Active' if at least one player is in the mission area
    };

    //5. Mission engage condition (one time switch on)
    if !(_info get "IsEngaged") then {
        _info set ["IsEngaged",((call NWG_fnc_ykGetTotalKillcount) > 0)];//Set 'Active' if YK detected at least one kill (doesn't matter where players are)
    };

    //6. Mission exhausted condition (one time switch on that is setup by FightSetupExhaustion)
    if (!(_info get "IsExhausted") && {(_info get "WillExhaustAt") > 0}) then {
        _info set ["IsExhausted",(_curTime >= (_info get "WillExhaustAt"))];
    };

    //7. Escape addition
    if (NWG_MIS_EscapeFlag) then {
        if !(_info get "IsEscape") then {_info set ["IsEscape",true]};//Force escape right away
        if (_playersOnline == 0) exitWith {_info set ["IsAllPlayersInEscapeVehicle",false]};//No players online - no need to check
        private _escapeVehicle = _info get "EscapeVehicle";
        private _playersOnline = count (call NWG_fnc_getPlayersAll);//Get all player units
        _info set ["IsAllPlayersInEscapeVehicle",(_playersOnline == ({isPlayer _x} count (crew _escapeVehicle)))];
    };

    //8. Return
    _info
};

NWG_MIS_SER_FightTeardown = {
    // private _missionInfo = _this;

    //Disable the YellowKing system
    call NWG_fnc_ykDisable;//It's ok to call it more than once

    //return
    _this
};

//================================================================================================================
//================================================================================================================
//Mission completion
NWG_MIS_SER_MarkMissionDone = {
    // private _missionInfo = _this;
    private _pos = _this get "Position";
    private _outlineRad = _this get "OutlineRadius";

    //Create background outline marker
    private _missionName = format ["MIS_%1_Done",(count NWG_MIS_SER_missionsList)];//A little hack to get a unique marker name
    private _marker = createMarker [_missionName,_pos];
    _marker setMarkerSize [_outlineRad,_outlineRad];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerColor (NWG_MIS_SER_Settings get "MISSIONS_DONE_COLOR");
    _marker setMarkerAlpha (NWG_MIS_SER_Settings get "MISSIONS_DONE_ALPHA");

    //Save it to not be deleted
    [_marker] call NWG_fnc_gcAddOriginalMarkers;
};

//================================================================================================================
//================================================================================================================
//Escape sequence
NWG_MIS_SER_AttackPlayerBase = {
    // private _missionInfo = _this;

    //Put base NPSc into 'surrender' animation
    private _npcs = NWG_MIS_SER_playerBaseNPCs;
    {
        [_x,"Acts_JetsMarshallingStop_loop"] remoteExecCall ["NWG_fnc_playAnimRemote",0,_x];//Make it JIP compatible + ensure unscheduled environment
        _x disableAI "ANIM";//Fix AI switching out of the animation (works even for agents)
    } forEach _npcs;

    //Send enemy reinforcements to the player base
    private _basePos = NWG_MIS_SER_playerBasePos;
    private _groupsCount = selectRandom (NWG_MIS_SER_Settings get "ESCAPE_BASEATTACK_GROUPSCOUNT");
    private _faction = _this get "EnemyFaction";
    private _side = _this get "EnemySide";
    [_basePos,_groupsCount,_faction,[],_side] call NWG_fnc_dsSendReinforcements;
};

NWG_MIS_SER_EscapeStarted = {
    // private _missionInfo = _this;
    //Just play some tunes when the fighting starts
    _this spawn {
        private _missionInfo = _this;
        waitUntil {sleep 1; _missionInfo getOrDefault ["IsEngaged",false]};//Wait until the fight starts
        private _music = selectRandom (NWG_MIS_SER_Settings get "ESCAPE_MUSIC");
        _music remoteExec ["NWG_fnc_mmPlayMusic",0];
    };
};

NWG_MIS_SER_EscapeTick = {
    // private _missionInfo = _this;
    private _curTime = round time;
    private _endAt = _this get "WillExhaustAt";
    private _secondsLeft = (round (_endAt - _curTime)) max 0;
    _secondsLeft call NWG_fnc_sideChatAll;
};

NWG_MIS_SER_EscapeCompleted = {
    0 remoteExec ["NWG_fnc_mmEscapeCompleted",0];
};

//================================================================================================================
//================================================================================================================
//Server restart
NWG_MIS_SER_ServerRestart = {
    //TODO: Add an actual server restart code here
    systemChat "Server restart initiated!";
};

//================================================================================================================
//================================================================================================================
call _Init;