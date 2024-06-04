#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
#define NPC_TAXI "Taxi"
#define NPC_MECHANIC "Mechanic"
#define NPC_TRADER "Trader"
#define NPC_MEDIC "Medic"
#define NPC_COMMANDER "Commander"

NWG_MIS_SER_Settings = createHashMapFromArray [
    ["AUTOSTART",true],//Start the mission machine once the scripts are compiled and game started
    ["AUTOSTART_IN_DEVBUILD",true],//Start even if we are in debug environment

    ["LOG_STATE_CHANGE",true],//Log every state change
    ["HEARTBEAT_RATE",1],//How often the mission machine should check for state changes

    ["PLAYER_BASE_ROOT","PlayerBase"],//Name of pre-placed map object (value of Object:Init -> Variable name) (mandatory for mission machine to work)
    ["PLAYER_BASE_BLUEPRINT","PlayerBase"],//Blueprint(s) page to build the base with using ukrep subsystem
    ["PLAYER_BASE_MARKERS",["o_unknown","loc_Tourism"]],//Markers to be placed at the player base position
    ["PLAYER_BASE_MARKERS_SIZE",1.25],//Size of the markers

    ["PLAYER_BASE_NPC_SETTINGS", createHashMapFromArray [
        [
            "B_G_Story_Guerilla_01_F", [
            /*id:*/NPC_TAXI,
            /*disarm:*/false,
            /*anim:*/"InBaseMoves_Lean1",
            /*addAction:*/false]
        ],
        [
            "I_G_Story_Protagonist_F",
            [/*id:*/NPC_MECHANIC,
            /*disarm:*/true,
            /*anim:*/[
                "HubBriefing_ext_Contact",
                "HubBriefing_loop",
                "Acts_Explaining_EW_Idle01"
            ],
            /*addAction:*/false]
        ],
        [
            "I_G_resistanceLeader_F",
            [/*id:*/NPC_TRADER,
            /*disarm:*/true,
            /*anim:*/[
                "HubSittingChairUA_idle2",
                "HubSittingChairUA_idle3"
            ],
            /*addAction:*/false]
        ],
        [
            "I_C_Soldier_Camo_F",
            [/*id:*/NPC_MEDIC,
            /*disarm:*/true,
            /*anim:*/"Acts_Gallery_Visitor_02",
            /*addAction:*/false]
        ],
        [
            "I_E_Soldier_MP_F",
            [/*id:*/NPC_COMMANDER,
            /*disarm:*/false,
            /*anim:*/[
                "Acts_millerCamp_A",
                "Acts_millerCamp_C",
                "acts_millerIdle"
            ],
            /*addAction:*/["Hello! Yoba, Eto Ti?",{systemChat "Commander: Da, eto ya"}]]
        ],
        [
            "B_G_Captain_Ivan_F",
            [/*id:*/NPC_ROOF,
            /*disarm:*/false,
            /*anim:*/false,
            /*addAction:*/false]
        ]
    ]],

    ["MISSIONS_LIST_MIN_DISTANCE",100],//Min distance between missions to be added to the list (example: several variants of the same mission, only one will be added by distance rule)

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MIS_SER_currentState = MSTATE_SCRIPTS_COMPILATION;
NWG_MIS_SER_cycleHandle = scriptNull;
NWG_MIS_SER_playerBase = objNull;
NWG_MIS_SER_playerBaseDecoration = [];
NWG_MIS_SER_missionsList = [];

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
            case MSTATE_MACHINE_STARTUP: {MSTATE_BASE_UKREP call NWG_MIS_SER_ChangeState};//Move to the next state

            /* base build */
            case MSTATE_BASE_UKREP: {
                private _buildResult = call NWG_MIS_SER_BuildPlayerBase;
                if (_buildResult isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the player base - exiting." call NWG_fnc_logError; _exit = true};//Exit
                _buildResult params ["_root","_objects"];
                NWG_MIS_SER_playerBase = _root;//Save base root object
                NWG_MIS_SER_playerBaseDecoration = _objects;//Save base objects
                MSTATE_BASE_ECONOMY call NWG_MIS_SER_ChangeState;/*Move to the next state*/
            };
            case MSTATE_BASE_ECONOMY: {
                //TODO: Add base economy
                MSTATE_BASE_QUESTS call NWG_MIS_SER_ChangeState;//Move to the next state
            };
            case MSTATE_BASE_QUESTS: {
                //TODO: Add base quests
                MSTATE_LIST_INIT call NWG_MIS_SER_ChangeState;//Move to the next state
            };


            /* missions list */
            case MSTATE_LIST_INIT: {
                private _missionsList = call NWG_MIS_SER_GenerateMissionsList;
                if (_missionsList isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to generate missions list - exiting." call NWG_fnc_logError; _exit = true};//Exit
                if ((count _missionsList) == 0) exitWith
                    {"NWG_MIS_SER_Cycle: No missions found for the map at INIT phase - exiting." call NWG_fnc_logError; _exit = true};//Exit
                NWG_MIS_SER_missionsList = _missionsList;//Save the list
                MSTATE_LIST_UPDATE call NWG_MIS_SER_ChangeState;/*Move to the next state*/
            };
            case MSTATE_LIST_UPDATE: {
                //TODO: Update the list of missions
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
        case MSTATE_BASE_UKREP:     {"BASE_UKREP"};
        case MSTATE_BASE_ECONOMY:   {"BASE_ECONOMY"};
        case MSTATE_BASE_QUESTS:    {"BASE_QUESTS"};
        case MSTATE_LIST_INIT:   {"LIST_INIT"};
        case MSTATE_LIST_UPDATE: {"LIST_UPDATE"};
        case MSTATE_READY: {"READY"};
        case MSTATE_BUILD_UKREP:   {"BUILD_UKREP"};
        case MSTATE_BUILD_DSPAWN:  {"BUILD_DSPAWN"};
        case MSTATE_BUILD_ECONOMY: {"BUILD_ECONOMY"};
        case MSTATE_BUILD_QUESTS:  {"BUILD_QUESTS"};
        case MSTATE_FIGHT_READY: {"FIGHT_READY"};
        case MSTATE_FIGHT_INFILTRATION: {"FIGHT_INFILTRATION"};
        case MSTATE_FIGHT_ACTIVE:       {"FIGHT_ACTIVE"};
        case MSTATE_FIGHT_OUT:          {"FIGHT_OUT"};
        case MSTATE_FIGHT_EXHAUSTED: {"FIGHT_EXHAUSTED"};
        case MSTATE_FIGHT_ABANDONED: {"FIGHT_ABANDONED"};
        case MSTATE_CLEANUP: {"CLEANUP"};
        case MSTATE_RESET:   {"RESET"};
        case MSTATE_SERVER_RESTART: {"SERVER_RESTART"};
        default {"UNKNOWN"};
    }
};

//================================================================================================================
//================================================================================================================
//Player Base building
NWG_MIS_SER_BuildPlayerBase = {
    //1. Find a root object on the map
    private _playerBaseRootName = NWG_MIS_SER_Settings get "PLAYER_BASE_ROOT";
    private _playerBaseRoot = missionNamespace getVariable [_playerBaseRootName,objNull];//Pre-defined root object on the map
    if (isNull _playerBaseRoot) exitWith {
        (format ["NWG_MIS_SER_BuildPlayerBase: Object '%1' not found on the map! Unable to build a player base",_playerBaseRootName]) call NWG_fnc_logError;
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
        /*_adaptToGround:*/true
    ] call NWG_fnc_ukrpBuildAroundObject;
    if (_buildResult isEqualTo false || {(flatten _buildResult) isEqualTo []}) exitWith {
        (format ["NWG_MIS_SER_BuildPlayerBase: Failed to build a player base around object '%1' using blueprint '%2'",_playerBaseRootName,_pageName]) call NWG_fnc_logError;
        false// <- Exit if failed to build a base
    };

    //3. Configure the base objects
    //_buildResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    call {
        //3.1 Disable damage for every object
        _playerBaseRoot allowDamage false;
        {_x allowDamage false} forEach (flatten _buildResult);

        //3.2 Lock every vehicle
        {_x lock true} forEach (_buildResult param [4,[]]);

        //3.3 Clear and lock inventory of every object that has it
        {
            clearWeaponCargoGlobal _x;
            clearMagazineCargoGlobal _x;
            clearItemCargoGlobal _x;
            clearBackpackCargoGlobal _x;
            _x lockInventory true;
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
            (_npcSettings get (typeOf _x)) params ["_id","_disarm","_anim","_addAction"];
            [_x,_id] call NWG_MIS_SER_SetNpcId;
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
        } forEach (_buildResult param [3,[]]);
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
        }
    };

    //6. Report to garbage collector that these markers are not to be deleted
    _markers call NWG_fnc_gcAddOriginalMarkers;

    //7. Return result
    [_playerBaseRoot,_buildResult]
};

NWG_MIS_SER_SetNpcId = {
    params ["_npc","_id"];
    _npc setVariable ["NWG_MIS_SER_NPC_ID",_id];
};
NWG_MIS_SER_GetNpcId = {
    // private _npc = _this;
    _this getVariable ["NWG_MIS_SER_NPC_ID",""];
};

//================================================================================================================
//================================================================================================================
//Missions list generation
NWG_MIS_SER_GenerateMissionsList = {
    //1. Get all missions available for this map
    private _pageName = "Abs" + (toUpper worldName);
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

//================================================================================================================
//================================================================================================================
call _Init;