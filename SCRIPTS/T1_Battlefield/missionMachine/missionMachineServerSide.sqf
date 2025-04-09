#include "..\..\globalDefines.h"
#include "..\..\secrets.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
/*Moved to missionMachineSettings.sqf for there are just too many of them*/

//================================================================================================================
//================================================================================================================
//Global flags (propagated to clients)
NWG_MIS_CurrentState = MSTATE_SCRIPTS_COMPILATION;
NWG_MIS_UnlockedLevels = [];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MIS_SER_cycleHandle = scriptNull;
NWG_MIS_SER_playerBase = objNull;
NWG_MIS_SER_playerBaseNPCs = [];
NWG_MIS_SER_missionsList = [];
NWG_MIS_SER_escapeMissionsList = [];
NWG_MIS_SER_lastLevel = -1;
NWG_MIS_SER_selected = [];

/*Temp storage for the next state before it's applied*/
NWG_MIS_SER_newState = MSTATE_SCRIPTS_COMPILATION;

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

    //Check if player base root object is present on the map at the moment
    if (isNull (call NWG_MIS_SER_FindPlayerBaseRoot)) then {
        "Expecting player base root object" call NWG_MIS_SER_Log;
    };

    //Start
    NWG_MIS_SER_cycleHandle = [] spawn NWG_MIS_SER_Cycle;
};

//================================================================================================================
//================================================================================================================
//Utils
NWG_MIS_SER_Log = {
    // private _message = _this;
    diag_log text (format ["  [MISSION INFO] #### %1",_this]);
};

NWG_MIS_SER_InterpolateFloat = {
    params ["_range","_level"];
    _range params ["_min","_max"];
    _level = _level max 0;
    private _maxLevel = ((count (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS")) - 1) max 1;
    //return
    _min + (((_max - _min) / _maxLevel) * _level)
};

NWG_MIS_SER_InterpolateInt = {
    // params ["_range","_level"];
    round (_this call NWG_MIS_SER_InterpolateFloat)
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
        if (NWG_MIS_CurrentState isNotEqualTo NWG_MIS_SER_newState) then {
            //State changed
            private _oldState = NWG_MIS_CurrentState;
            private _newState = NWG_MIS_SER_newState;
            [_oldState,_newState] call NWG_MIS_SER_OnStateChanged;
            NWG_MIS_CurrentState = _newState;
            publicVariable "NWG_MIS_CurrentState";
        };

        /*Fix NPCs position*//*Yeah, that's dirty, but until we find a better solution...*/
        call NWG_MIS_SER_FixNpcPosition;

        /*Do things and calculate next state to switch to*/
        switch (NWG_MIS_CurrentState) do {
            /* initialization */
            case MSTATE_SCRIPTS_COMPILATION: {MSTATE_MACHINE_STARTUP call NWG_MIS_SER_ChangeState};
            case MSTATE_DISABLED: {_exit = true};//Exit
            case MSTATE_MACHINE_STARTUP: {
                if (isNull (call NWG_MIS_SER_FindPlayerBaseRoot)) exitWith {};
                "Player base root object found - starting mission machine" call NWG_MIS_SER_Log;
                call NWG_MIS_SER_NextState
            };

            /* base build */
            case MSTATE_BASE_UKREP: {
                private _buildResult = call NWG_MIS_SER_BuildPlayerBase;
                if (_buildResult isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the player base - exiting." call NWG_fnc_logError; _exit = true};//Exit
                _buildResult params ["_root","_objects"];
                NWG_MIS_SER_playerBase = _root;//Save base root object
                NWG_MIS_SER_playerBaseDecoration = _objects;//Save base objects
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BASE_ECONOMY: {
                //EVENT_ON_MISSION_STATE_CHANGED subscriber(s) did the job. We do nothing.
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BASE_QUESTS: {
                //EVENT_ON_MISSION_STATE_CHANGED subscriber(s) did the job. We do nothing.
                NWG_MIS_SER_playerBaseDecoration resize 0;//Release base objects
                call NWG_MIS_SER_NextState;
            };


            /* missions list */
            case MSTATE_LIST_INIT: {
                /*Generate missions list*/
                private _pageName = format [(NWG_MIS_SER_Settings get "BLUEPRINTS_MISSIONS_PAGENAME"),(call NWG_fnc_wcGetWorldName)];
                private _missionsList = _pageName call NWG_MIS_SER_GenerateMissionsList;
                if (_missionsList isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to generate missions list - exiting." call NWG_fnc_logError; _exit = true};//Exit
                if ((count _missionsList) == 0) exitWith
                    {"NWG_MIS_SER_Cycle: No missions found for the map at INIT phase - exiting." call NWG_fnc_logError; _exit = true};//Exit
                NWG_MIS_SER_missionsList = _missionsList;//Save the list

                /*Generate escape missions list*/
                private _escapePageName = format [(NWG_MIS_SER_Settings get "BLUEPRINTS_ESCAPE_PAGENAME"),(call NWG_fnc_wcGetWorldName)];
                private _escapeMissionsList = _escapePageName call NWG_MIS_SER_GenerateMissionsList;
                if (_escapeMissionsList isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to generate escape missions list - exiting." call NWG_fnc_logError; _exit = true};//Exit
                if ((count _escapeMissionsList) == 0) exitWith
                    {"NWG_MIS_SER_Cycle: No escape missions found for the map at INIT phase - exiting." call NWG_fnc_logError; _exit = true};//Exit
                NWG_MIS_SER_escapeMissionsList = _escapeMissionsList;//Save the list

                call NWG_MIS_SER_NextState;
            };
            case MSTATE_LIST_CHECK: {
                //Update unlocked levels
                call NWG_MIS_SER_UpdateUnlockedLevels;

                //Check if we have enough missions to run
                if ((count NWG_MIS_SER_missionsList) == 0) exitWith {
                    "Empty missions list at LIST_CHECK phase" call NWG_MIS_SER_Log;
                    if (NWG_MIS_SER_Settings get "MLIST_CHECK_NO_MISSIONS_RESTART") exitWith
                        {MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState};//Restart server if no missions left
                    if (NWG_MIS_SER_Settings get "MLIST_CHECK_NO_MISSIONS_RUN_ESCAPE") exitWith
                        {call NWG_MIS_SER_AutoRunEscape; MSTATE_BUILD_CONFIG call NWG_MIS_SER_ChangeState};//Run escape if no missions left
                    if (NWG_MIS_SER_Settings get "MLIST_CHECK_NO_MISSIONS_EXIT") exitWith
                        {_exit = true};//Exit the cycle
                    //else
                    "NWG_MIS_SER_Cycle: Empty missions list at LIST_CHECK phase and no action taken." call NWG_fnc_logError;//Log at least
                };

                call NWG_MIS_SER_NextState;
            };

            /* player input expect */
            case MSTATE_READY: {
                //Update mission info to check restart condition and players on base
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;

                //Check restart condition - restart if players left after completing at least one level
                if (NWG_MIS_SER_lastLevel >= 0 && {NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION}) exitWith {
                    "No players online - restarting the server." call NWG_MIS_SER_Log;
                    MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
                };

                //Check mission selection
                if (NWG_MIS_SER_selected isEqualTo []) exitWith {};//Wait for selection

                //Check if all players are on the base
                if !(NWG_MIS_SER_missionInfo get MINFO_IS_ALL_PLAYERS_ON_BASE) exitWith {
                    "#MIS_NOT_ALL_PLAYERS_ON_BASE#" call NWG_fnc_systemChatAll;
                    NWG_MIS_SER_selected = [];//Reset selection
                };

                //Check if may skip voting
                if ((count (call NWG_fnc_getPlayersAll)) <= 1) exitWith {
                    "Only one player online - skipping voting" call NWG_MIS_SER_Log;
                    MSTATE_BUILD_CONFIG call NWG_MIS_SER_ChangeState;
                };

                //Start voting
                if (call NWG_fnc_voteIsRunning) exitWith {
                    "#MIS_VOTE_WAITING#" call NWG_fnc_systemChatAll;
                };//Wait for another voting to finish
                private _anchor = NWG_MIS_SER_playerBase;
                private _title = [
                    "#MIS_VOTE_TITLE#",
                    NWG_MIS_SER_selected param [SELECTION_NAME,""],
                    ((NWG_MIS_SER_selected param [SELECTION_LEVEL,-2]) + 1),/*UI level is 1-N+1*/
                    NWG_MIS_SER_selected param [SELECTION_FACTION,""],
                    NWG_MIS_SER_selected param [SELECTION_TIME_STR,""],
                    NWG_MIS_SER_selected param [SELECTION_WEATHER_STR,""]
                ];
                private _ok = [_anchor,_title] call NWG_fnc_voteRequestServer;
                if (!_ok) exitWith {
                    "NWG_MIS_SER_Cycle: Failed to start voting" call NWG_fnc_logError;
                    "#MIS_VOTE_CANNOT_START#" call NWG_fnc_systemChatAll;
                };

                call NWG_MIS_SER_NextState;
            };
            case MSTATE_VOTING: {
                //Confirm mission selection by voting
                if (call NWG_fnc_voteIsRunning) exitWith {};//Wait for voting to finish

                private _result = call NWG_fnc_voteGetResult;
                if (_result isEqualTo false) exitWith {
                    "NWG_MIS_SER_Cycle: Failed to get voting result" call NWG_fnc_logError;
                    "#MIS_VOTE_ERROR#" call NWG_fnc_systemChatAll;
                };
                if (_result < 0) exitWith {
                    //Players voted against the mission
                    "#MIS_VOTE_AGAINST#" call NWG_fnc_systemChatAll;
                    NWG_MIS_SER_selected = [];//Reset selection
                    MSTATE_READY call NWG_MIS_SER_ChangeState;//Return to the ready state
                };
                //Players voted in favor of the mission or vote is undefined (still treat it as a vote in favor, fuck indecisiveness)
                call NWG_MIS_SER_NextState;
            };

            /* mission build */
            case MSTATE_BUILD_CONFIG: {
                //Default 'WasOnMission' flag to false for all the players
                [(call NWG_fnc_getPlayersAll),false] call NWG_MIS_SER_SetWasOnMission;

                //Configure global variables
                private _selection = NWG_MIS_SER_selected;
                private _level = _selection#SELECTION_LEVEL;
                private _index = _selection#SELECTION_INDEX;
                private _isEscape = _level call NWG_MIS_SER_IsEscapeLvl;
                NWG_MIS_SER_selected = [];//Reset selection
                NWG_MIS_SER_lastLevel = _level;//Save last level
                private _selectedMission = if (_isEscape)
                    then {NWG_MIS_SER_escapeMissionsList select _index}
                    else {NWG_MIS_SER_missionsList deleteAt _index};
                if (!_isEscape) then {NWG_MIS_SER_missionsList = NWG_MIS_SER_missionsList call NWG_fnc_arrayShuffle};//Re-shuffle missions list

                //Configure mission info
                NWG_MIS_SER_missionInfo = [_selection,_selectedMission,_isEscape,NWG_MIS_SER_missionInfo] call NWG_MIS_SER_GenerateMissionInfo;

                //Configure daytime and weather
                [(_selection select SELECTION_TIME),(_selection select SELECTION_WEATHER)] call NWG_fnc_wcSetDaytimeAndWeather;

                //Display mission briefing
                _selection remoteExec ["NWG_fnc_mmMissionBriefing",0];

                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_UKREP: {
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_BuildMission_Markers;//Place markers
                private _ukrep  = NWG_MIS_SER_missionInfo call NWG_MIS_SER_BuildMission_Ukrep;//Build mission
                if (_ukrep isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the mission UKREP - exiting." call NWG_fnc_logError; _exit = true};//Exit

                //Escape injection
                if (NWG_MIS_SER_missionInfo get MINFO_IS_ESCAPE) then {
                    //[_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
                    private _escapeVehicle = (_ukrep#OBJ_CAT_VEHC) param [0,objNull];
                    if (isNull _escapeVehicle || {!alive _escapeVehicle}) exitWith
                        {"NWG_MIS_SER_Cycle: Escape vehicle not found or dead - exiting." call NWG_fnc_logError; _exit = true};//Exit
                    _escapeVehicle allowDamage false;
                    NWG_MIS_SER_missionInfo set [MINFO_ESCAPE_VEHICLE,_escapeVehicle];
                    NWG_MIS_SER_missionInfo set [MINFO_ESCAPE_VEHICLE_POS,(getPosASL _escapeVehicle)];
                };

                NWG_MIS_SER_missionObjects = _ukrep;//Save mission objects
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_ECONOMY: {
                //EVENT_ON_MISSION_STATE_CHANGED subscriber(s) did the job. We do nothing.
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_DSPAWN: {
                private _ok = NWG_MIS_SER_missionInfo call NWG_MIS_SER_BuildMission_Dspawn;
                if (_ok isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to the mission DSPAWN - exiting." call NWG_fnc_logError; _exit = true};//Exit
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_BUILD_QUESTS: {
                //EVENT_ON_MISSION_STATE_CHANGED subscriber(s) did the job. We do nothing.
                NWG_MIS_SER_missionObjects resize 0;//Release mission objects
                call NWG_MIS_SER_NextState;
            };

            /* mission playflow */
            case MSTATE_FIGHT_SETUP: {
                //Mission is being prepared for players to engage
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetup;//Init mission info
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;//Update mission info

                if (NWG_MIS_SER_missionInfo get MINFO_IS_ESCAPE)
                    then {MSTATE_ESCAPE_SETUP call NWG_MIS_SER_ChangeState}/*goto escape setup*/
                    else {call NWG_MIS_SER_NextState};
            };
            case MSTATE_FIGHT_READY: {
                //Mission is ready for players to engage
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;//Update mission info

                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ENGAGED): {
                        //Players are fighting the enemy
                        NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightSetupExhaustion;//Setup exhaustion
                        MSTATE_FIGHT_ACTIVE call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_INFILTRATED): {
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
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ENGAGED): {
                        //Players are fighting the enemy
                        MSTATE_FIGHT_ACTIVE call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_EXHAUSTED): {
                        //Players have exhausted the mission
                        call NWG_MIS_SER_FightEscalate;//<-- Remaining units will attack players by cooldown
                        MSTATE_FIGHT_EXHAUSTED call NWG_MIS_SER_ChangeState;
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ALL_PLAYERS_ON_BASE): {
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
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_EXHAUSTED): {
                        //Players have exhausted the mission
                        call NWG_MIS_SER_FightEscalate;//<-- Remaining units will attack players by cooldown
                        MSTATE_FIGHT_EXHAUSTED call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ALL_PLAYERS_ON_BASE && {NWG_MIS_SER_missionInfo get MINFO_IS_INFILTRATED}): {
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
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ALL_PLAYERS_ON_BASE && {NWG_MIS_SER_missionInfo get MINFO_IS_INFILTRATED}): {
                        //Players are back on the base after visiting the mission area at least once
                        MSTATE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    default {/*Do nothing*/};
                };
            };

            /* mission end */
            case MSTATE_COMPLETED: {
                //Mission is completed
                call NWG_MIS_SER_FightTeardown;//<-- Disable the YellowKing system
                (NWG_MIS_SER_missionInfo get MINFO_NAME) remoteExec ["NWG_fnc_mmMissionCompleted",0];//Send mission completed signal to all the clients
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_CLEANUP: {
                //Cleanup the mission
                [] call NWG_fnc_gcDeleteMission;
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_MarkMissionDone;//Mark mission as done on the map
                call NWG_fnc_shClearOccupiedBuildings;//Release occupied buildings
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_RESET: {
                //Reset the mission
                MSTATE_LIST_CHECK call NWG_MIS_SER_ChangeState;//<- Go back to the mission selection
            };
            case MSTATE_SERVER_RESTART: {
                //Restart the server
                "#MIS_RESTART_MESSAGE#" call NWG_fnc_sideChatAll;
                sleep 3;//Give some time for the message to be displayed
                call NWG_MIS_SER_ServerRestart;
                _exit = true;//Exit
            };

            /* escape phase */
            case MSTATE_ESCAPE_SETUP: {
                //Prepare escape mission
                private _curTime = round time;
                private _exhaustAfter = NWG_MIS_SER_Settings get "ESCAPE_TIME_LIMIT";
                NWG_MIS_SER_missionInfo set [MINFO_WILL_EXHAUST_AT,(_curTime + _exhaustAfter)];//Setup escape time limit
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_OnEscapeStarted;//Escape specific logic
                call NWG_MIS_SER_NextState;
            };
            case MSTATE_ESCAPE_ACTIVE: {
                //Players are escaping the island
                NWG_MIS_SER_missionInfo call NWG_MIS_SER_FightUpdateMissionInfo;
                switch (true) do {
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_RESTART_CONDITION): {
                        //No players online for a while
                        MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_ALL_PLAYERS_IN_ESCAPE_VEHICLE): {
                        //Players have escaped the island
                        MSTATE_ESCAPE_COMPLETED call NWG_MIS_SER_ChangeState;//<-- Mission is completed
                    };
                    case (NWG_MIS_SER_missionInfo get MINFO_IS_EXHAUSTED): {
                        //Players have failed to escape in time
                        call NWG_MIS_SER_FightTeardown;//<-- Disable the YellowKing system
                        MSTATE_ESCAPE_FAILED call NWG_MIS_SER_ChangeState
                    };
                    default {/*Do nothing*/};
                };
            };
            case MSTATE_ESCAPE_FAILED: {
                //Players have failed to escape in time
                false remoteExec ["NWG_fnc_mmEscapeCompleted",0];
                MSTATE_SERVER_RESTART call NWG_MIS_SER_ChangeState
            };
            case MSTATE_ESCAPE_COMPLETED: {
                sleep 3;//Give some time for event handlers to finish (rewards, save to state holder, etc)
                true remoteExec ["NWG_fnc_mmEscapeCompleted",0];
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
    NWG_MIS_SER_newState = _this;

    //Raise one last event on disabled
    if (_this isEqualTo MSTATE_DISABLED)
        then {[NWG_MIS_CurrentState,_this] call NWG_MIS_SER_OnStateChanged};
};

NWG_MIS_SER_NextState = {
    //Set new state based on the current one
    NWG_MIS_SER_newState = (NWG_MIS_CurrentState + 1);
};

NWG_MIS_SER_OnStateChanged = {
    params ["_oldState","_newState"];

    //Log
    if (NWG_MIS_SER_Settings get "LOG_STATE_CHANGE") then {
        format ["Mission state changed from: %1 to: %2",
            (_oldState call NWG_MIS_SER_GetStateName),
            (_newState call NWG_MIS_SER_GetStateName)
        ] call NWG_MIS_SER_Log;
    };

    //Raise event
    [EVENT_ON_MISSION_STATE_CHANGED,[_oldState,_newState]] call NWG_fnc_raiseServerEvent;
};

NWG_MIS_SER_GetStateName = {
    // private _state = _this;
    //return
    switch (_this) do {
        case MSTATE_SCRIPTS_COMPILATION: {"SCRIPTS_COMPILATION"};
        case MSTATE_DISABLED:            {"DISABLED"};
        case MSTATE_MACHINE_STARTUP:     {"MACHINE_STARTUP"};
        case MSTATE_BASE_UKREP:     {"BASE_UKREP"};
        case MSTATE_BASE_ECONOMY:   {"BASE_ECONOMY"};
        case MSTATE_BASE_QUESTS:    {"BASE_QUESTS"};
        case MSTATE_LIST_INIT:   {"LIST_INIT"};
        case MSTATE_LIST_CHECK:  {"LIST_CHECK"};
        case MSTATE_READY:         {"READY"};
        case MSTATE_VOTING:        {"VOTING"};
        case MSTATE_BUILD_CONFIG:  {"BUILD_CONFIG"};
        case MSTATE_BUILD_UKREP:   {"BUILD_UKREP"};
        case MSTATE_BUILD_ECONOMY: {"BUILD_ECONOMY"};
        case MSTATE_BUILD_DSPAWN:  {"BUILD_DSPAWN"};
        case MSTATE_BUILD_QUESTS:  {"BUILD_QUESTS"};
        case MSTATE_FIGHT_SETUP:        {"FIGHT_SETUP"};
        case MSTATE_FIGHT_READY:        {"FIGHT_READY"};
        case MSTATE_FIGHT_INFILTRATION: {"FIGHT_INFILTRATION"};
        case MSTATE_FIGHT_ACTIVE:       {"FIGHT_ACTIVE"};
        case MSTATE_FIGHT_EXHAUSTED:    {"FIGHT_EXHAUSTED"};
        case MSTATE_COMPLETED:  {"COMPLETED"};
        case MSTATE_CLEANUP:    {"CLEANUP"};
        case MSTATE_RESET:      {"RESET"};
        case MSTATE_SERVER_RESTART: {"SERVER_RESTART"};
        case MSTATE_ESCAPE_SETUP:       {"ESCAPE_SETUP"};
        case MSTATE_ESCAPE_ACTIVE:      {"ESCAPE_ACTIVE"};
        case MSTATE_ESCAPE_FAILED:      {"ESCAPE_FAILED"};
        case MSTATE_ESCAPE_COMPLETED:   {"ESCAPE_COMPLETED"};
        default {"UNKNOWN"};
    }
};

//================================================================================================================
//================================================================================================================
//Unlocked levels logic
NWG_MIS_SER_UpdateUnlockedLevels = {
    //Get all levels
    private _newUnlockedLevels = (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS") apply {false};
    private _lastLevel = NWG_MIS_SER_lastLevel;

    //Exclude last (escape) level if last level played was not the second highest
    if (_lastLevel < ((count _newUnlockedLevels)-2)) then {
        _newUnlockedLevels deleteAt ((count _newUnlockedLevels)-1);//Exclude last level
    };

    //Re-scan unlocked levels
    private _curUnlockedLevels = NWG_MIS_UnlockedLevels;
    {_newUnlockedLevels set [_forEachIndex,_x]} forEach _curUnlockedLevels;
    if (_newUnlockedLevels isEqualTo _curUnlockedLevels) exitWith {false};//No changes

    //Update unlocked levels
    NWG_MIS_UnlockedLevels = _newUnlockedLevels;
    publicVariable "NWG_MIS_UnlockedLevels";
    true
};

NWG_MIS_SER_OnUnlockLevelRequest = {
    private _level = _this;
    if (NWG_MIS_CurrentState isNotEqualTo MSTATE_READY) exitWith {
        (format ["NWG_MIS_SER_OnUnlockLevel: Invalid state for unlock level request. state:'%1'",(NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName)]) call NWG_fnc_logError;
        false/*for testing*/
    };

    //Check level argument
    private _unlockedLevels = NWG_MIS_UnlockedLevels;
    if (_level < 0 || _level >= (count _unlockedLevels)) exitWith {
        (format ["NWG_MIS_SER_OnUnlockLevel: Invalid level. level:'%1' levels count:'%2'",_level,(count _unlockedLevels)]) call NWG_fnc_logError;
        false/*for testing*/
    };
    if (_unlockedLevels param [_level,false]) exitWith {
        (format ["NWG_MIS_SER_OnUnlockLevel: Level '%1' is already unlocked",_level]) call NWG_fnc_logError;
        false/*for testing*/
    };

    //Add to unlocked levels
    _unlockedLevels set [_level,true];
    NWG_MIS_UnlockedLevels = _unlockedLevels;
    publicVariable "NWG_MIS_UnlockedLevels";

    //return
    true/*for testing*/
};

//================================================================================================================
//================================================================================================================
//Was on mission flag (global, propagated to all clients)
NWG_MIS_SER_SetWasOnMission = {
    params ["_players","_setFlag"];
    {_x setVariable ["NWG_MIS_WasOnMission",_setFlag,true]} forEach (_players select {(_x getVariable ["NWG_MIS_WasOnMission",false]) isNotEqualTo _setFlag});
};
NWG_MIS_SER_GetWasOnMission = {
    // private _player = _this;
    _this getVariable ["NWG_MIS_WasOnMission",false]
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
    private _buildResultFlatten = if (_buildResult isNotEqualTo false)
        then {flatten _buildResult}
        else {[]};
    if (_buildResult isEqualTo false || {_buildResultFlatten isEqualTo []}) exitWith {
        (format ["NWG_MIS_SER_BuildPlayerBase: Failed to build a player base around object '%1' using blueprint '%2'",(NWG_MIS_SER_Settings get "PLAYER_BASE_ROOT"),_pageName]) call NWG_fnc_logError;
        false// <- Exit if failed to build a base
    };

    //3. Configure the base objects
    //_buildResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    call {
        //3.1 Disable damage for every object
        _playerBaseRoot allowDamage false;
        {_x allowDamage false} forEach _buildResultFlatten;

        //3.2 Lock every vehicle
        {_x lock true} forEach (_buildResult param [OBJ_CAT_VEHC,[]]);

        //3.3 Clear and lock inventory of every object that has it
        {
            _x call NWG_fnc_clearContainerCargo;
            [_x,true] remoteExecCall ["lockInventory",0,_x];//Lock it JIP compatible
        } forEach (_buildResultFlatten select {
            !(_x isKindOf "Man") && {
            !(isSimpleObject _x) && {
            _x canAdd "FirstAidKit"}}
        });

        //3.4 Configure base NPCs
        private _baseNpcs = _buildResult param [OBJ_CAT_UNIT,[]];
        private _npcSettings = NWG_MIS_SER_Settings get "PLAYER_BASE_NPC_SETTINGS";
        private _addActionQueue = [];
        {
            //Basic settings
            _x enableDynamicSimulation true;
            _x setCaptive true;

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
                [_x,_anim] call NWG_fnc_playAnim;
                [_x,"NWG_fnc_playAnim",[_anim]] call NWG_fnc_rqAddCommand;
                _x disableAI "ANIM";//Fix AI switching out of the animation (works even for agents)
            };

            //Queue add action for each NPC in READY state
            if (_addAction isNotEqualTo false) then {
                _addAction params [["_title",""],["_script",{}]];
                _addActionQueue pushBack [_x,_title,_script];
            };
        } forEach _baseNpcs;

        //3.5 Assign actions to NPCs (with delay)
        if ((count _addActionQueue) > 0) then {
            _addActionQueue spawn {
                // private _addActionQueue = _this;
                waitUntil {sleep 0.1; NWG_MIS_CurrentState >= MSTATE_READY};
                {_x call NWG_fnc_addActionGlobal} forEach _this;
            };
        };

        //3.6 Setup NPCs for position fixing
        {_x setVariable ["NWG_baseNpcOrigPos",(getPosASL _x)]} forEach _baseNpcs;
        NWG_MIS_SER_playerBaseNPCs = _baseNpcs;
    };

    //4. Report to garbage collector that these objects are not to be deleted
    [_playerBaseRoot] call NWG_fnc_gcAddOriginalObjects;
    _buildResultFlatten call NWG_fnc_gcAddOriginalObjects;

    //5. Place markers
    private _markers = call {
        private _i = 0;
        private _markerSize = NWG_MIS_SER_Settings get "PLAYER_BASE_MARKERS_SIZE";
        private ["_markerName","_marker"];
        (NWG_MIS_SER_Settings get "PLAYER_BASE_MARKERS") apply {
            _markerName = format ["playerBase_%1",_i]; _i = _i + 1;
            _marker = createMarkerLocal [_markerName,_playerBaseRoot];
            _marker setMarkerShapeLocal "icon";
            _marker setMarkerTypeLocal _x;
            _marker setMarkerSize [_markerSize,_markerSize];
            _markerName
        }
    };

    //6. Report to garbage collector that these markers are not to be deleted
    _markers call NWG_fnc_gcAddOriginalMarkers;

    //7. Return result
    [_playerBaseRoot,_buildResult]
};

NWG_MIS_SER_FixNpcPosition = {
    private ["_posOrig","_posCur"];
    {
        _posOrig = _x getVariable "NWG_baseNpcOrigPos";
        _posCur = getPosASL _x;
        if ((_posOrig distance _posCur) > 0.25) then {_x setPosASL _posOrig};
    } forEach NWG_MIS_SER_playerBaseNPCs;
};

//================================================================================================================
//================================================================================================================
//Missions list generation
NWG_MIS_SER_GenerateMissionsList = {
    private _pageName = _this;

    //Get all missions available for this map
    private _blueprints = _pageName call NWG_fnc_ukrpGetCataloguePage;
    if (_blueprints isEqualTo false || {(count _blueprints) == 0}) exitWith {
        (format ["NWG_MIS_SER_GenerateMissionsList: Failed to get missions list for page '%1'",_pageName]) call NWG_fnc_logError;
        false// <- Exit if no missions found
    };

    //Shuffle and filter by distance
    _blueprints = _blueprints + [];//Shallow copy
    _blueprints = _blueprints call NWG_fnc_arrayShuffle;//Shuffle
    _blueprints = _blueprints call NWG_fnc_arrayShuffle;//Shuffle again (why not?)
    private _missionsList = [];
    private _minDistance = NWG_MIS_SER_Settings get "MLIST_MIN_DISTANCE";
    private ["_pos","_i"];
    //forEach blueprint container:
    //["ABS","UkrepName",[ABSPos],0,Radius,0,[Payload],[Blueprint]]
    {
        _pos = _x#2;
        _i = _missionsList findIf {(_pos distance2D (_x#2)) <= _minDistance};
        if (_i == -1) then {_missionsList pushBack _x};
    } forEach _blueprints;

    //Repack into mission list structure
    private _nameParts = [];
    _missionsList = _missionsList apply {
        _nameParts = ((_x#BPCONTAINER_NAME) splitString "_");
        //repack as:
        [
            /*MLIST_NAME:*/(_nameParts param [BPCNAME_NAME,"Unknown"]),
            /*MLIST_TIER:*/(parseNumber (_nameParts param [BPCNAME_TIER,"0"])),
            /*MLIST_POS:*/(_x#BPCONTAINER_POS),
            /*MLIST_BLUEPRINT:*/(_x#BPCONTAINER_BLUEPRINT)
        ]
    };

    //return
    _missionsList
};

//================================================================================================================
//================================================================================================================
//Missions selection process (client->server interaction not affected by heartbeat cycle)
NWG_MIS_SER_OnSelectionRequest = {
    private _level = _this;
    private _caller = remoteExecutedOwner;
    if (isDedicated && _caller <=  0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Caller can not be identified! callerID:%1",_caller]) call NWG_fnc_logError;
        false
    };
    if (NWG_MIS_CurrentState isNotEqualTo MSTATE_READY) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Invalid state for selection request. state:'%1'",(NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName)]) call NWG_fnc_logError;
        false
    };

    //Check if level was unlocked and is valid
    private _levels = (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS");
    if (_level < 0 || _level >= (count _levels)) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Invalid level. level:'%1' levels count:'%2'",_level,(count _levels)]) call NWG_fnc_logError;
        false
    };
    if !(NWG_MIS_UnlockedLevels param [_level,false]) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Level '%1' is not unlocked",_level]) call NWG_fnc_logError;
        false
    };

    //Get missions list
    private _missionsList = if (_level call NWG_MIS_SER_IsEscapeLvl)
        then {NWG_MIS_SER_escapeMissionsList}
        else {NWG_MIS_SER_missionsList};
    if ((count _missionsList) == 0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: No missions found for level: '%1'",_level]) call NWG_fnc_logError;
        false
    };

    //Get enemy factions
    private _enemyFactions = (NWG_MIS_SER_Settings get "ENEMY_FACTIONS") + [];//Shallow copy
    _enemyFactions = _enemyFactions call NWG_fnc_arrayShuffle;//Shuffle
    if ((count _enemyFactions) == 0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: No enemy factions found!"]) call NWG_fnc_logError;
        false
    };

    //Get mission tiers by level
    private _tiers = _levels param [_level,[]];
    if ((count _tiers) == 0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: No tiers found for level: '%1'",_level]) call NWG_fnc_logError;
        false
    };
    private _minTier = 100;
    private _maxTier = -100;
    {
        if (_x < _minTier) then {_minTier = _x};
        if (_x > _maxTier) then {_maxTier = _x};
    } forEach _tiers;

    //Define selection count
    private _selectionCount = ((count _missionsList) min (count _enemyFactions)) min (NWG_MIS_SER_Settings get "ENEMY_PER_SELECTION");
    if (_selectionCount == 0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Selection count is zero! missions count: '%1', enemy factions count: '%2', max selection count: '%3'",(count _missionsList),(count _enemyFactions),(NWG_MIS_SER_Settings get "ENEMY_PER_SELECTION")]) call NWG_fnc_logError;
        false
    };

    //Try to select enough missions to match the selection count
    private _selectedIndexes = [];
    private _attempts = 100;
    while {_attempts > 0} do {
        _attempts = _attempts - 1;

        //Select missions that match the tier range
        {
            if ((_x#MLIST_TIER) >= _minTier && {(_x#MLIST_TIER) <= _maxTier}) then {_selectedIndexes pushBack _forEachIndex};
        } forEach _missionsList;
        if ((count _selectedIndexes) == _selectionCount) exitWith {};//Found exact count
        if ((count _selectedIndexes) > _selectionCount) exitWith {_selectedIndexes resize _selectionCount};//Found a bit more than needed

        //Not enough missions matched the tier range, try again with expanded tier range
        _selectedIndexes resize 0;
        switch (true) do {
            case (_minTier > 0): {_minTier = _minTier - 1};//Lower min tier (first priority)
            case (_maxTier < (NWG_MIS_SER_Settings get "MAX_TIER")): {_maxTier = _maxTier + 1};//Raise max tier (second priority)
            default {_attempts = 0};//Exit loop (nowhere else to increase tier range)
        };
    };
    if ((count _selectedIndexes) == 0) exitWith {
        (format ["NWG_MIS_SER_OnSelectionRequest: Failed to generate selection even one selection. _selectionCount: '%1' _selectedIndexes count: '%2'",_selectionCount,(count _selectedIndexes)]) call NWG_fnc_logError;
        false
    };

    //Repack selection list (currently mission indexes) into appropriate structure
    private _mRad = [(NWG_MIS_SER_Settings get "MISSION_RADIUS_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;
    private _selectionList = [];
    {
        private _mission = _missionsList#_x;
        private _faction = _enemyFactions#_forEachIndex;//Already shuffled
        private _color = (NWG_MIS_SER_Settings get "ENEMY_COLORS") getOrDefault [_faction,"ColorBlack"];
        (call NWG_fnc_wcGetRndDaytime) params ["_time","_timeStr"];
        (call NWG_fnc_wcGetRndWeather) params ["_weather","_weatherStr"];

        _selectionList pushBack [
            /*SELECTION_NAME:*/_mission#MLIST_NAME,
            /*SELECTION_LEVEL:*/_level,
            /*SELECTION_INDEX:*/_x,
            /*SELECTION_POS:*/_mission#MLIST_POS,
            /*SELECTION_RAD:*/_mRad,
            /*SELECTION_FACTION:*/_faction,
            /*SELECTION_COLOR:*/_color,
            /*SELECTION_TIME:*/_time,
            /*SELECTION_TIME_STR:*/_timeStr,
            /*SELECTION_WEATHER:*/_weather,
            /*SELECTION_WEATHER_STR:*/_weatherStr
        ];
    } forEach _selectedIndexes;

    //return
    _selectionList remoteExec ["NWG_fnc_mmSelectionResponse",_caller];
    _selectionList/*for testing*/
};

NWG_MIS_SER_OnSelectionMade = {
    // private _selection = _this;
    if (NWG_MIS_CurrentState isNotEqualTo MSTATE_READY)
        exitWith {(format ["NWG_MIS_SER_OnSelectionMade: Invalid state for selection made. state:'%1'",(NWG_MIS_CurrentState call NWG_MIS_SER_GetStateName)]) call NWG_fnc_logError};

    NWG_MIS_SER_selected = _this;//Write into global variable
    //The rest will be handled by heartbeat cycle...
};

//================================================================================================================
//================================================================================================================
//Mission info - property bag of current mission
NWG_MIS_SER_GenerateMissionInfo = {
    params ["_selection","_selectedMission","_isEscape",["_missionInfo",createHashMap]];
    private _level = _selection select SELECTION_LEVEL;
    private _tiers = (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS") param [_level,[]];

    //Basic info
    _missionInfo set [MINFO_NAME,(_selection select SELECTION_NAME)];
    _missionInfo set [MINFO_LEVEL,_level];
    _missionInfo set [MINFO_TIERS,_tiers];
    _missionInfo set [MINFO_POSITION,(_selection select SELECTION_POS)];
    _missionInfo set [MINFO_RADIUS,(_selection select SELECTION_RAD)];

    //Enemy info
    _missionInfo set [MINFO_ENEMY_SIDE,(NWG_MIS_SER_Settings get "ENEMY_SIDE")];
    _missionInfo set [MINFO_ENEMY_FACTION,(_selection select SELECTION_FACTION)];
    _missionInfo set [MINFO_ENEMY_COLOR,(_selection select SELECTION_COLOR)];

    //Blueprint
    _missionInfo set [MINFO_BLUEPRINT,(_selectedMission select MLIST_BLUEPRINT)];

    //Exhaust after
    private _exhaustAfter = [
        (NWG_MIS_SER_Settings get "MISSION_EXHAUST_MIN_MAX"),
        (_selection select SELECTION_LEVEL)
    ] call NWG_MIS_SER_InterpolateInt;
    _missionInfo set [MINFO_EXHAUST_AFTER,_exhaustAfter];

    //Escape
    _missionInfo set [MINFO_IS_ESCAPE,_isEscape];
    _missionInfo set [MINFO_ESCAPE_VEHICLE,objNull];//Will be set later
    _missionInfo set [MINFO_ESCAPE_VEHICLE_POS,[0,0,0]];//Will be set later

    //return
    _missionInfo
};

//================================================================================================================
//================================================================================================================
//Mission building
NWG_MIS_SER_BuildMission_Markers = {
    // private _missionInfo = _this;
    private _pos = _this get MINFO_POSITION;
    private _markerType   = NWG_MIS_SER_Settings get "MAP_MIS_MARKER_TYPE";
    private _markerColor  = _this get MINFO_ENEMY_COLOR;
    private _markerSize   = NWG_MIS_SER_Settings get "MAP_MIS_MARKER_SIZE";
    private _outlineAlpha = NWG_MIS_SER_Settings get "MAP_MIS_OUTLINE_ALPHA";
    private _outlineRad   = _this get MINFO_RADIUS;

    //Create background outline
    private _outline = createMarkerLocal ["MIS_BuildMission_Outline",_pos];
    _outline setMarkerSizeLocal [_outlineRad,_outlineRad];
    _outline setMarkerShapeLocal "ELLIPSE";
    _outline setMarkerColorLocal _markerColor;
    _outline setMarkerAlpha _outlineAlpha;

    //Create mission marker
    private _marker = createMarkerLocal ["MIS_BuildMission_Marker",_pos];
    _marker setMarkerTypeLocal _markerType;
    _marker setMarkerSizeLocal [_markerSize,_markerSize];
    _marker setMarkerColor _markerColor;
};

NWG_MIS_SER_BuildMission_Ukrep = {
    // private _missionInfo = _this;

    //Cache map buildings in the area
    private _mapBldgs = ((_this get MINFO_POSITION) nearObjects (_this get MINFO_RADIUS)) select {_x call NWG_fnc_ocIsBuilding};

    //Configure fractal steps
    private _fractalSteps = NWG_MIS_SER_Settings get "UKREP_FRACTAL_STEPS";
    private _level = _this get MINFO_LEVEL;

    private _unitRules = (((_fractalSteps#FRACTAL_STEP_BLDG)#FRACTAL_CHANCES)#OBJ_CAT_UNIT);
    _unitRules set ["MinPercentage",([(NWG_MIS_SER_Settings get "UKREP_UNIT_MIN_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _unitRules set ["MaxPercentage",([(NWG_MIS_SER_Settings get "UKREP_UNIT_MAX_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _unitRules set ["MinCount",([(NWG_MIS_SER_Settings get "UKREP_UNIT_MIN_COUNT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt)];
    _unitRules set ["MaxCount",([(NWG_MIS_SER_Settings get "UKREP_UNIT_MAX_COUNT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt)];

    private _trrtRules = (((_fractalSteps#FRACTAL_STEP_BLDG)#FRACTAL_CHANCES)#OBJ_CAT_TRRT);
    _trrtRules set ["MinPercentage",([(NWG_MIS_SER_Settings get "UKREP_TRRT_MIN_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _trrtRules set ["MaxPercentage",([(NWG_MIS_SER_Settings get "UKREP_TRRT_MAX_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _trrtRules set ["MinCount",([(NWG_MIS_SER_Settings get "UKREP_TRRT_MIN_COUNT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt)];
    _trrtRules set ["MaxCount",([(NWG_MIS_SER_Settings get "UKREP_TRRT_MAX_COUNT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt)];

    private _furnRules = (((_fractalSteps#FRACTAL_STEP_FURN)#FRACTAL_CHANCES)#OBJ_CAT_DECO);
    _furnRules set ["MinPercentage",([(NWG_MIS_SER_Settings get "UKREP_FURN_DECO_MIN_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _furnRules set ["MaxPercentage",([(NWG_MIS_SER_Settings get "UKREP_FURN_DECO_MAX_PERC_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateFloat)];
    _furnRules set ["MinCount",([(NWG_MIS_SER_Settings get "UKREP_FURN_DECO_MIN_COUNT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt)];

    //Build the mission by the blueprint
    private _faction = _this get MINFO_ENEMY_FACTION;
    private _overrides = createHashMapFromArray [
        ["RootBlueprint",(_this get MINFO_BLUEPRINT)],
        ["GroupsMembership",(_this get MINFO_ENEMY_SIDE)]
    ];
    private _bldResult = [_fractalSteps,_faction,_overrides] call NWG_fnc_ukrpBuildFractalABS;
    if (isNil "_bldResult" || {_bldResult isEqualTo false}) exitWith {
        (format ["NWG_MIS_SER_BuildMission_Ukrep: Failed to build the mission! faction:'%1'",_faction]) call NWG_fnc_logError;
        false
    };

    //Decorate existing map buildings
    private _mapBldgsLimit = [(NWG_MIS_SER_Settings get "UKREP_MAP_BLDG_LIMIT_FULL_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;
    private _toDecorate = _mapBldgs select {
        !(isObjectHidden _x) && {
        [_x,OBJ_TYPE_BLDG,"AUTO"] call NWG_fnc_ukrpHasRelSetup}
    };
    if ((count _toDecorate) > _mapBldgsLimit) then {
        _toDecorate = _toDecorate call NWG_fnc_arrayShuffle;
        _toDecorate resize _mapBldgsLimit;
    };
    if ((count _toDecorate) > 0) then {
        _mapBldgs = _mapBldgs - _toDecorate;
        private _decResult = [_toDecorate,_fractalSteps,_faction,_overrides] call NWG_fnc_ukrpDecorateFractalBuildings;
        if (_decResult isEqualTo false) exitWith {};//Skip if failed to decorate
        {(_bldResult#_forEachIndex) append _x} forEach _decResult;
    };

    //Decorate empty buildings
    private _emptyBldgPageName = NWG_MIS_SER_Settings get "BLUEPRINTS_EMPTY_BLDG_PAGENAME";
    private _emptyBldgsLimit = [(NWG_MIS_SER_Settings get "UKREP_MAP_BLDG_LIMIT_EMPT_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;
    _toDecorate = _mapBldgs select {
        !(isObjectHidden _x) && {
        [_x,OBJ_TYPE_BLDG,_emptyBldgPageName] call NWG_fnc_ukrpHasRelSetup}
    };
    if ((count _toDecorate) > _emptyBldgsLimit) then {
        _toDecorate = _toDecorate call NWG_fnc_arrayShuffle;
        _toDecorate resize _emptyBldgsLimit;
    };
    {
        private _emptResult = [_emptyBldgPageName,_x,OBJ_TYPE_BLDG] call NWG_fnc_ukrpBuildAroundObject;//Build
        if (_emptResult isEqualTo false) then {continue};//Skip if failed to build
        {(_bldResult#_forEachIndex) append _x} forEach _emptResult;//Append to final result
    } forEach _toDecorate;

    //Return the result
    _bldResult
};

NWG_MIS_SER_BuildMission_Dspawn = {
    // private _missionInfo = _this;

    //Unpack data
    private _missionPos = _this get MINFO_POSITION;
    private _missionRad = _this get MINFO_RADIUS;
    private _level   = _this get MINFO_LEVEL;
    private _tiers   = _this get MINFO_TIERS;
    private _faction = _this get MINFO_ENEMY_FACTION;
    private _side = _this get MINFO_ENEMY_SIDE;

    //Calculate the DSPAWN reinforcment map
    //["_pos",["_doInf",true],["_doVeh",true],["_doBoat",true],["_doAir",true]] call NWG_fnc_dtsMarkupReinforcement
    private _reinfMap = [_missionPos,true,true,true,true] call NWG_fnc_dtsMarkupReinforcement;

    //Configure DSPAWN for all future 'xxxCfg' functions calls (trigger population and reinforcements)
    private _ok = [_side,_faction,_tiers,_reinfMap] call NWG_fnc_dsConfigure;
    if (!_ok) then {format ["NWG_MIS_SER_BuildMission_Dspawn: Failed to configure DSPAWN! faction:'%1' side:'%2'",_faction,_side] call NWG_fnc_logError};

    //Calculate count of groups to populate trigger with
    private _groupsCount = [(NWG_MIS_SER_Settings get "DSPAWN_GROUPS_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;

    //populate and return the result
    [[_missionPos,_missionRad],_groupsCount] call NWG_fnc_dsPopulateTriggerCfg
};

//================================================================================================================
//================================================================================================================
//Fight stages
NWG_MIS_SER_FightSetup = {
    // private _missionInfo = _this;

    //Configure and enable the YellowKing system
    // params ["_kingSide"];
    [(_this get MINFO_ENEMY_SIDE)] call NWG_fnc_ykConfigure;
    private _ok = call NWG_fnc_ykEnable;
    if (!_ok) then {"NWG_MIS_SER_FightSetup: Failed to enable the YellowKing system. Is it enabled already?" call NWG_fnc_logError};

    //Update mission info with default values
    _this set [MINFO_LAST_ONLINE_AT,-1];
    _this set [MINFO_IS_RESTART_CONDITION,false];
    _this set [MINFO_IS_ALL_PLAYERS_ON_BASE,false];
    _this set [MINFO_IS_INFILTRATED,false];
    _this set [MINFO_IS_ENGAGED,false];
    _this set [MINFO_IS_EXHAUSTED,false];
    _this set [MINFO_WILL_EXHAUST_AT,-1];
    _this set [MINFO_IS_ALL_PLAYERS_IN_ESCAPE_VEHICLE,false];

    //return
    _this
};

NWG_MIS_SER_FightSetupExhaustion = {
    // private _missionInfo = _this;
    private _curTime = round time;
    private _exhaustAfter = _this get MINFO_EXHAUST_AFTER;
    _this set [MINFO_WILL_EXHAUST_AT,(_curTime + _exhaustAfter)];
    //return
    _this
};

NWG_MIS_SER_FightUpdateMissionInfo = {
    private _info = _this;
    private _curTime = round time;

    //1. Get players
    private _playersOnline = call NWG_fnc_getPlayersAll;
    private _playersOnlineCount = (count _playersOnline);
    private _playersOnMission = call {
        private _missionPos = _info getOrDefault [MINFO_POSITION,[0,0,0]];
        private _missionRad = _info getOrDefault [MINFO_RADIUS,0];
        _playersOnline select {(_x distance2D _missionPos) <= _missionRad}
    };
    private _playersOnBase = call {
        private _baseRad = NWG_MIS_SER_Settings get "PLAYER_BASE_RADIUS";
        _playersOnline select {(_x distance2D NWG_MIS_SER_playerBase) <= _baseRad}
    };

    //2. Mark players that are in the mission area
    [_playersOnMission,true] call NWG_MIS_SER_SetWasOnMission;

    //3. Server restart condition (may be on-off)
    if (_playersOnlineCount > 0) then {
        _info set [MINFO_LAST_ONLINE_AT,_curTime];
        _info set [MINFO_IS_RESTART_CONDITION,false];
    } else {
        private _lastOnline = _info getOrDefault [MINFO_LAST_ONLINE_AT,0];
        private _restartDelay = NWG_MIS_SER_Settings get "SERVER_RESTART_ON_ZERO_ONLINE_AFTER";
        private _restartAt = _lastOnline + _restartDelay;
        _info set [MINFO_IS_RESTART_CONDITION,(_curTime >= _restartAt)];
    };

    //4. All players on base condition (may be on-off)
    _info set [MINFO_IS_ALL_PLAYERS_ON_BASE,(_playersOnlineCount > 0 && {(count _playersOnBase) == _playersOnlineCount})];

    //5. Mission infiltration condition (one time switch on)
    if !(_info getOrDefault [MINFO_IS_INFILTRATED,false]) then {
        _info set [MINFO_IS_INFILTRATED,((count _playersOnMission) > 0)];//Set 'Active' if at least one player is in the mission area
    };

    //6. Mission engage condition (one time switch on)
    if !(_info getOrDefault [MINFO_IS_ENGAGED,false]) then {
        _info set [MINFO_IS_ENGAGED,((call NWG_fnc_ykGetTotalKillcount) > 0)];//Set 'Active' if YK detected at least one kill (doesn't matter where players are)
    };

    //7. Mission exhausted condition (one time switch on that is setup by FightSetupExhaustion)
    if (!(_info getOrDefault [MINFO_IS_EXHAUSTED,false]) && {(_info getOrDefault [MINFO_WILL_EXHAUST_AT,0]) > 0}) then {
        _info set [MINFO_IS_EXHAUSTED,(_curTime >= (_info getOrDefault [MINFO_WILL_EXHAUST_AT,0]))];
    };

    //8. Escape addition
    if (_info getOrDefault [MINFO_IS_ESCAPE,false]) then {
        if (_playersOnlineCount == 0) exitWith {_info set [MINFO_IS_ALL_PLAYERS_IN_ESCAPE_VEHICLE,false]};//No players online - no need to check
        private _escapeVehicle = _info getOrDefault [MINFO_ESCAPE_VEHICLE,objNull];
        private _escapeVehiclePos = _info getOrDefault [MINFO_ESCAPE_VEHICLE_POS,[0,0,0]];
        private _isInVehicle = _playersOnlineCount == ({isPlayer _x} count (crew _escapeVehicle));
        private _isVehicleMoved = (_escapeVehicle distance2D _escapeVehiclePos) > 1000;
        _info set [MINFO_IS_ALL_PLAYERS_IN_ESCAPE_VEHICLE,(_isInVehicle && _isVehicleMoved)];
    };

    //9. Return
    _info
};

NWG_MIS_SER_FightEscalate = {
    //Trigger berserk mode - stop reinforcements but make units attack players by cooldown
    private _selectBy = {_x call NWG_MIS_SER_GetWasOnMission};//Attack players that were on a mission
    [_selectBy] call NWG_fnc_ykGoBerserk;
};

NWG_MIS_SER_FightTeardown = {
    //Disable the YellowKing system
    call NWG_fnc_ykDisable;//It's ok to call it more than once
};

//================================================================================================================
//================================================================================================================
//Mission completion
NWG_MIS_SER_MarkMissionDone = {
    // private _missionInfo = _this;
    private _pos = _this get MINFO_POSITION;
    private _missionName = format ["MIS_%1_Done",(round time)];//A little hack to get a unique marker name

    //Create background outline marker
    private _outlineName = format ["%1_Outline",_missionName];
    private _outlineRad = _this get MINFO_RADIUS;
    private _outline = createMarkerLocal [_outlineName,_pos];
    _outline setMarkerShapeLocal "ELLIPSE";
    _outline setMarkerSizeLocal [_outlineRad,_outlineRad];
    _outline setMarkerColorLocal (NWG_MIS_SER_Settings get "MAP_DONE_COLOR");
    _outline setMarkerAlpha (NWG_MIS_SER_Settings get "MAP_DONE_ALPHA");

    //Create visible marker with missions counter
    private _markerName = _missionName;
    private _markerSize = NWG_MIS_SER_Settings get "MAP_DONE_SIZE";
    private _marker = createMarkerLocal [_markerName,_pos];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal (NWG_MIS_SER_Settings get "MAP_DONE_TYPE");
    _marker setMarkerSizeLocal [_markerSize,_markerSize];
    _marker setMarkerColorLocal (NWG_MIS_SER_Settings get "MAP_DONE_COLOR");
    private _curLevel = (_this get MINFO_LEVEL) + 1;//Start from '1' for visual representation
    private _maxLevel = (count (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS"))-1;
    _marker setMarkerText (format [" %1 / %2 ",_curLevel,_maxLevel]);

    //GC ignore
    [_outline,_marker] call NWG_fnc_gcAddOriginalMarkers;
};

//================================================================================================================
//================================================================================================================
//Escape sequence
NWG_MIS_SER_IsEscapeLvl = {
    // private _level = _this;
    _this == ((count (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS"))-1);
};

NWG_MIS_SER_AutoRunEscape = {
    private _level = ((count (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS"))-1);
    private _missionIndex = floor (random (count NWG_MIS_SER_escapeMissionsList));
    private _mission = NWG_MIS_SER_escapeMissionsList param [_missionIndex,[]];
    if (_mission isEqualTo []) exitWith {
        "NWG_MIS_SER_AutoRunEscape: No missions found for auto-run" call NWG_fnc_logError;
        false
    };

    private _enemyFaction = (((NWG_MIS_SER_Settings get "ENEMY_FACTIONS")+[]) call NWG_fnc_arrayShuffle) deleteAt 0;
    if (isNil "_enemyFaction") exitWith {
        "NWG_MIS_SER_AutoRunEscape: No enemy faction found" call NWG_fnc_logError;
        false
    };

    private _tiers = (NWG_MIS_SER_Settings get "LEVELS_AND_TIERS") param [_level,[]];
    if ((count _tiers) == 0) exitWith {
        (format ["NWG_MIS_SER_AutoRunEscape: No tiers found for level: '%1'",_level]) call NWG_fnc_logError;
        false
    };

    private _mRad = [(NWG_MIS_SER_Settings get "MISSION_RADIUS_MIN_MAX"),_level] call NWG_MIS_SER_InterpolateInt;
    private _color = (NWG_MIS_SER_Settings get "ENEMY_COLORS") getOrDefault [_enemyFaction,"ColorBlack"];
    (call NWG_fnc_wcGetRndDaytime) params ["_time","_timeStr"];
    (call NWG_fnc_wcGetRndWeather) params ["_weather","_weatherStr"];

    NWG_MIS_SER_selected = [
        /*SELECTION_NAME:*/_mission#MLIST_NAME,
        /*SELECTION_LEVEL:*/_level,
        /*SELECTION_INDEX:*/_missionIndex,
        /*SELECTION_POS:*/_mission#MLIST_POS,
        /*SELECTION_RAD:*/_mRad,
        /*SELECTION_FACTION:*/_enemyFaction,
        /*SELECTION_COLOR:*/_color,
        /*SELECTION_TIME:*/_time,
        /*SELECTION_TIME_STR:*/_timeStr,
        /*SELECTION_WEATHER:*/_weather,
        /*SELECTION_WEATHER_STR:*/_weatherStr
    ];

    //The rest will be handled by heartbeat cycle...
    true
};

NWG_MIS_SER_OnEscapeStarted = {
    // private _missionInfo = _this;

    //Put base NPSc into 'surrender' animation
    private _npcs = NWG_MIS_SER_playerBaseNPCs;
    {
        [_x,"Acts_JetsMarshallingStop_loop"] remoteExecCall ["NWG_fnc_playAnim",0,_x];//Make it JIP compatible + ensure unscheduled environment
        _x disableAI "ANIM";//Fix AI switching out of the animation (works even for agents)
    } forEach _npcs;

    //Attack player base
    private _basePos = getPosASL NWG_MIS_SER_playerBase;
    private _groupsCount = selectRandom (NWG_MIS_SER_Settings get "ESCAPE_BASEATTACK_GROUPSCOUNT");
    private _faction = _this get MINFO_ENEMY_FACTION;
    private _side = _this get MINFO_ENEMY_SIDE;
    [_basePos,_groupsCount,_faction,[],_side] call NWG_fnc_dsSendReinforcements;

    //Send timer to clients
    private _secondsLeft = NWG_MIS_SER_Settings get "ESCAPE_TIME_LIMIT";
    _secondsLeft remoteExec ["NWG_fnc_mmEscapeStarted",0];

    //Play some tunes when the fighting starts
    _this spawn {
        private _missionInfo = _this;
        waitUntil {sleep 1; _missionInfo getOrDefault [MINFO_IS_ENGAGED,false]};//Wait until the fight starts
        private _music = selectRandom (NWG_MIS_SER_Settings get "ESCAPE_MUSIC");
        _music remoteExec ["NWG_fnc_mmPlayMusic",0];
    };
};

//================================================================================================================
//================================================================================================================
//Server restart
NWG_MIS_SER_ServerRestart = {
    "NWG_MIS_SER_ServerRestart: Server restart initiated" call NWG_fnc_logInfo;
    SERVER_COMMAND_PASSWORD serverCommand "#shutdown";
};

//================================================================================================================
//================================================================================================================
call _Init;