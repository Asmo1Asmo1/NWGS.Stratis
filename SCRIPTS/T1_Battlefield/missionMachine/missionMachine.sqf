#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MIS_SER_Settings = createHashMapFromArray [
    ["AUTOSTART",true],//Start the mission machine once the scripts are compiled and game started
    ["AUTOSTART_IN_DEVBUILD",true],//Start even if we are in debug environment

    ["LOG_STATE_CHANGE",true],//Log every state change
    ["HEARTBEAT_RATE",1],//How often the mission machine should check for state changes

    ["MISSIONS_UPDATE_NO_MISSIONS_LOG",true],  //Log error for no missions left
    ["MISSIONS_UPDATE_NO_MISSIONS_RESET",true],//Go to RESET state if no missions left
    ["MISSIONS_UPDATE_NO_MISSIONS_EXIT",false],//Exit heartbeat cycle if no missions left

    ["MISSIONS_SELECT_DISCARD_REJECTED",false],//False - rejected missions go back to the missions list for next selection, True - they get discarded
    ["MISSIONS_SELECT_RESHUFFLE_REJECTED",false],//False - rejected missions simply added to the end of the missions list, True - list gets reshuffled

    /*The rest see in the DATASETS/Server/MissionMachine/Settings.sqf */
    ["COMPLEX_SETTINGS_ADDRESS","DATASETS\Server\MissionMachine\Settings.sqf"],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Global flag
NWG_MIS_CurrentState = MSTATE_SCRIPTS_COMPILATION;

//================================================================================================================
//================================================================================================================
//Fields
NWG_MIS_SER_cycleHandle = scriptNull;
NWG_MIS_SER_playerBase = objNull;
NWG_MIS_SER_playerBaseDecoration = [];
NWG_MIS_SER_missionsList = [];
NWG_MIS_SER_selectionList = [];
NWG_MIS_SER_selected = [];

NWG_MIS_SER_missionArea = [];
NWG_MIS_SER_missionObjects = [];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    //Check if we should start
    if (!(NWG_MIS_SER_Settings get "AUTOSTART") || {
        (is3DENPreview || is3DENMultiplayer) && !(NWG_MIS_SER_Settings get "AUTOSTART_IN_DEVBUILD")}
    ) exitWith {MSTATE_DISABLED call NWG_MIS_SER_ChangeState};// <- Exit without starting

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
        sleep (NWG_MIS_SER_Settings get "HEARTBEAT_RATE");

        switch (NWG_MIS_CurrentState) do {
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
                NWG_MIS_SER_playerBaseDecoration resize 0;//Release base objects
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
                MSTATE_LIST_UPDATE call NWG_MIS_SER_ChangeState;//Move to the next state
            };
            case MSTATE_LIST_UPDATE: {
                private _selectionList = NWG_MIS_SER_missionsList call NWG_MIS_SER_GenerateSelection;
                if (_selectionList isEqualTo []) exitWith {
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_LOG")
                        then {(format ["NWG_MIS_SER_Cycle: Not enough missions at UPDATE phase! Expected: %1, Found: %2",_selectionCount,(count NWG_MIS_SER_missionsList)]) call NWG_fnc_logError};
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_RESET")
                        then {MSTATE_RESET call NWG_MIS_SER_ChangeState};//Reset
                    if (NWG_MIS_SER_Settings get "MISSIONS_UPDATE_NO_MISSIONS_EXIT")
                        then {_exit = true};//Exit
                    if (NWG_MIS_CurrentState isEqualTo MSTATE_LIST_UPDATE && !_exit)
                        then {"NWG_MIS_SER_Cycle: Not enough missions at UPDATE phase and no action taken." call NWG_fnc_logError};//Log at least
                };

                NWG_MIS_SER_selectionList = _selectionList;//Save the selection
                MSTATE_READY call NWG_MIS_SER_ChangeState;//Move to the next state
            };

            /* player input expect */
            case MSTATE_READY: {
                switch (count NWG_MIS_SER_selectionList) do {
                    case 0: {
                        //Some wild situation
                        "NWG_MIS_SER_Cycle: No mission selection at READY phase. Must be some kind of error - exiting." call NWG_fnc_logError;
                        _exit = true;//Exit
                    };
                    case 1: {
                        //Only one mission available or selection is made - start it
                        NWG_MIS_SER_selected = NWG_MIS_SER_selectionList deleteAt 0;//Get the selected mission
                        (NWG_MIS_SER_selected#SELECTION_NAME) remoteExec ["NWG_fnc_mmSelectionConfirmed",0];//Send selection made signal to all the clients
                        MSTATE_BUILD_UKREP call NWG_MIS_SER_ChangeState;//Move to the next state
                    };
                    default {
                        //Wait for player input
                    };
                }
            };

            /* mission build */
            case MSTATE_BUILD_UKREP: {
                /*private _marker = */NWG_MIS_SER_selected call NWG_MIS_SER_BuildMission_Marker;//Place marker
                private _ukrep  = NWG_MIS_SER_selected call NWG_MIS_SER_BuildMission_Ukrep;//Build mission
                if (_ukrep isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to build the mission UKREP - exiting." call NWG_fnc_logError; _exit = true};//Exit

                NWG_MIS_SER_missionArea = [(NWG_MIS_SER_selected#SELECTION_POS),(NWG_MIS_SER_selected#SELECTION_RAD)];//Save mission area
                NWG_MIS_SER_missionObjects = _ukrep;//Save mission objects
                MSTATE_BUILD_DSPAWN call NWG_MIS_SER_ChangeState;//Move to the next state
            };
            case MSTATE_BUILD_DSPAWN: {
                private _ok = [NWG_MIS_SER_selected,NWG_MIS_SER_missionObjects] call NWG_MIS_SER_BuildMission_Dspawn;
                if (_ok isEqualTo false) exitWith
                    {"NWG_MIS_SER_Cycle: Failed to the mission DSPAWN - exiting." call NWG_fnc_logError; _exit = true};//Exit

                MSTATE_BUILD_ECONOMY call NWG_MIS_SER_ChangeState;//Move to the next state
            };
            case MSTATE_BUILD_ECONOMY: {
                //TODO: Fill boxes and vehicles with loot using ECONOMY
                MSTATE_BUILD_QUESTS call NWG_MIS_SER_ChangeState;//Move to the next state
            };
            case MSTATE_BUILD_QUESTS: {
                //TODO: Generate side quests using QUESTS
                NWG_MIS_SER_missionObjects resize 0;//Release mission objects
                MSTATE_FIGHT_READY call NWG_MIS_SER_ChangeState;//Move to the next state
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
    //Set new state
    private _newState = _this;
    private _oldState = NWG_MIS_CurrentState;
    NWG_MIS_CurrentState = _newState;

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
        /*adaptToGround:*/true,
        /*suppressEvent*/true
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
    //1. Get all missions available for this map
    private _pageName = "Abs" + (call NWG_fnc_wcGetWorldName);
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
    private _missionPresets = NWG_MIS_SER_Settings get "MISSIONS_SETTINGS";
    private _selectionCount = count _missionPresets;

    //2. Check if we have enough missions to select from
    if ((count _missionsList) < _selectionCount) exitWith {[]};

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
            _x#SELECTION_RAD,
            ((_x#SELECTION_SETTINGS) getOrDefault ["Name","Unknown"]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["SelectionMarker","mil_dot"]),
            ((_x#SELECTION_SETTINGS) getOrDefault ["SelectionMarker_Color","ColorBlack"])
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
//Mission building
NWG_MIS_SER_BuildMission_Marker = {
    // private _selectedMission = _this;
    private _pos = _this#SELECTION_POS;
    private _rad = _this#SELECTION_RAD;
    private _markerColor = (_this#SELECTION_SETTINGS) getOrDefault ["SelectionMarker_Color","ColorBlack"];

    //Create background outline marker
    _marker = createMarker ["MIS_BuildMission_Marker",_pos];
    _marker setMarkerSize [_rad,_rad];
    _marker setMarkerShape "ELLIPSE";
    _marker setMarkerColor _markerColor;
    _marker setMarkerAlpha (NWG_MIS_SER_Settings get "MISSIONS_OUTLINE_ALPHA");

    //return
    _marker
};

NWG_MIS_SER_BuildMission_Ukrep = {
    // private _selectedMission = _this;

    private _blueprint = _this#SELECTION_BLUEPRINT;
    // _blueprint = +_blueprint;//Deep copy to prevent changes in catalogues (is done internally inside the ukrep system)
    private _fractalSteps = _this#SELECTION_SETTINGS getOrDefault ["UkrepFractalSteps",[[]]];
    _fractalSteps = +_fractalSteps;//Deep copy to prevent changes in the settings
    (_fractalSteps#0) set [0,_blueprint];//Insert blueprint into the fractal root step

    private _faction = NWG_MIS_SER_Settings get "MISSIONS_ENEMY_FACTION";
    private _groupRules = [
        /*GRP_RULES_MEMBERSHIP:*/NWG_MIS_SER_Settings get "MISSIONS_ENEMY_SIDE",
        /*GRP_RULES_DYNASIM:*/true
    ];
    private _mapObjectsLimit = NWG_MIS_SER_Settings get "MISSIONS_BUILD_MAPOBJECTS_LIMIT";

    //build and return the result
    [_fractalSteps,_faction,_groupRules,_mapObjectsLimit] call NWG_fnc_ukrpBuildFractalABS
};

NWG_MIS_SER_BuildMission_Dspawn = {
    params ["_selectedMission","_ukrepObjects"];

    private _missionPos = _selectedMission#SELECTION_POS;
    private _missionRad = _selectedMission#SELECTION_RAD;
    private _settings   = _selectedMission#SELECTION_SETTINGS;

    private _radiusMult = _settings getOrDefault ["DspawnRadiusMult",1.5];
    private _radiusMin  = _settings getOrDefault ["DspawnRadiusMin",150];
    private _radiusMax  = _settings getOrDefault ["DspawnRadiusMax",200];
    private _groupsMult = _settings getOrDefault ["DspawnGroupsMult",1];
    private _groupsMin  = _settings getOrDefault ["DspawnGroupsMin",2];
    private _groupsMax  = _settings getOrDefault ["DspawnGroupsMax",5];

    _missionRad = _missionRad * _radiusMult;
    _missionRad = (_missionRad max _radiusMin) min _radiusMax;//Clamp

    // _ukrepObjects params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    private _ukrepGroups = ((_ukrepObjects#3) + (_ukrepObjects#4) + (_ukrepObjects#5)) apply {group _x};
    _ukrepGroups = _ukrepGroups arrayIntersect _ukrepGroups;//Remove duplicates
    private _groupsCount = count _ukrepGroups;

    _groupsCount = _groupsCount * _groupsMult;
    _groupsCount = (_groupsCount max _groupsMin) min _groupsMax;//Clamp

    private _trigger = [_missionPos,_missionRad];
    private _faction = NWG_MIS_SER_Settings get "MISSIONS_ENEMY_FACTION";
    private _side = NWG_MIS_SER_Settings get "MISSIONS_ENEMY_SIDE";

    //populate and return the result
    [_trigger,_groupsCount,_faction,[],_side] call NWG_fnc_dsPopulateTrigger
};

//================================================================================================================
//================================================================================================================
call _Init;