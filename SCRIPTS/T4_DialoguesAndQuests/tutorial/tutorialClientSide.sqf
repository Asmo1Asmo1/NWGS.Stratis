#include "tutorialDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_TUT_CLI_Settings = createHashMapFromArray [
	["SKIP_IN_DEV_BUILD",true],//Skip tutorial in dev build

	/*Dialogue roots*/
	["DIALOGUE_INITIAL_ROOT","%1_00"],
	["DIALOGUE_TUTOR_ROOTS",[
/*STEP_01_TAXI*/"%1_TUTOR01_00",
/*STEP_02_TRDR*/"%1_TUTOR02_00",
/*STEP_03_STRG*/"%1_TUTOR03_00",
/*STEP_04_COMM*/"%1_TUTOR04_00",
/*STEP_05_TAXI*/"%1_TUTOR05_00"
	]],

	/*Task titles*/
	["TASK_TITLES",[
/*STEP_01_TAXI*/"#TUT_TASK_TITLE_01#",
/*STEP_02_TRDR*/"#TUT_TASK_TITLE_02#",
/*STEP_03_STRG*/"#TUT_TASK_TITLE_03#",
/*STEP_04_COMM*/"#TUT_TASK_TITLE_04#",
/*STEP_05_TAXI*/"#TUT_TASK_TITLE_01#"
	]],

	/*External functions*/
	["FUNC_GET_PLAYER_LEVEL",{
		if (isNil "NWG_fnc_pGetPlayerLevel") exitWith {-1};
		player call NWG_fnc_pGetPlayerLevel
	}],
	["FUNC_IS_STORAGE_OPEN",{
		call NWG_fnc_lsIsStorageOpen
	}],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
/*Global Variable - we get it from server*/
// NWG_TUT_TutorialObjects = [];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Check dev build
	private _skipInDevBuild = NWG_TUT_CLI_Settings get "SKIP_IN_DEV_BUILD";
	private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
	if (_skipInDevBuild && _isDevBuild) exitWith {};//Skip tutorial in dev build

	//Wait for initialization to complete
	private _timeoutAt = time + 180;
	private _getLvlFunc = NWG_TUT_CLI_Settings get "FUNC_GET_PLAYER_LEVEL";
	private _playerLvl = -1;
	waitUntil {
		sleep 2;
		if (time > _timeoutAt) exitWith {true};//Timeout reached
		if (isNull (findDisplay 46)) exitWith {false};//Game display not found
		if (isNil "NWG_TUT_TutorialObjects") exitWith {false};//Tutorial objects did not arrive yet
		_playerLvl = call _getLvlFunc;
		if (_playerLvl < 0) exitWith {false};//Player level has not been assigned yet
		true
	};
	if (time > _timeoutAt) exitWith {
		"NWG_TUT_Init: Timeout reached" call NWG_fnc_logError;
	};

	//Determine if tutorial should start
	if (_playerLvl >= 1) exitWith {};//Player is level 1 or higher, skip tutorial
	"NWG_TUT_Init: Starting tutorial" call NWG_fnc_logInfo;
	call NWG_TUT_NextStep;
};

//================================================================================================================
//================================================================================================================
//Tutorial steps
NWG_TUT_currentStep = -1;
NWG_TUT_NextStep = {
	private _step = NWG_TUT_currentStep + 1;
	NWG_TUT_currentStep = _step;

	private _object = NWG_TUT_TutorialObjects param [_step,objNull];
	private _dialogueRoot = (NWG_TUT_CLI_Settings get "DIALOGUE_TUTOR_ROOTS") param [_step,""];

	switch (_step) do {
		case STEP_01_TAXI;
		case STEP_02_TRDR: {
			call NWG_TUT_CloseTask;
			_dialogueRoot call NWG_fnc_dlgSetRoot;
			[_object,_step] call NWG_TUT_CreateTask;
		};
		case STEP_03_STRG: {
			call NWG_TUT_CloseTask;
			_dialogueRoot call NWG_fnc_dlgSetRoot;
			[_object,_step] call NWG_TUT_CreateTask;
			//Special case - wait for storage to be opened and then closed
			player addEventHandler ["InventoryOpened",{
				if (call (NWG_TUT_CLI_Settings get "FUNC_IS_STORAGE_OPEN")) then {
					player addEventHandler ["InventoryClosed",{
						call NWG_TUT_NextStep;
						player removeEventHandler [_thisEvent, _thisEventHandler];
					}];
					player removeEventHandler [_thisEvent, _thisEventHandler];
				};
			}];
		};
		case STEP_04_COMM;
		case STEP_05_TAXI: {
			call NWG_TUT_CloseTask;
			_dialogueRoot call NWG_fnc_dlgSetRoot;
			[_object,_step] call NWG_TUT_CreateTask;
		};
		default {
			"NWG_TUT_NextStep: Tutorial ended" call NWG_fnc_logInfo;
			(NWG_TUT_CLI_Settings get "DIALOGUE_INITIAL_ROOT") call NWG_fnc_dlgSetRoot;
			call NWG_TUT_CloseTask;
		};
	};
};

//================================================================================================================
//================================================================================================================
//Task utils
NWG_TUT_currentTask = taskNull;
NWG_TUT_CreateTask = {
	params ["_object","_step"];
	private _taskTitle = (NWG_TUT_CLI_Settings get "TASK_TITLES") param [_step,""];
	_taskTitle = _taskTitle call NWG_fnc_localize;
	private _task = player createSimpleTask [_taskTitle];
	_task setSimpleTaskTarget [_object,true];
	_task setSimpleTaskDescription ["",_taskTitle,""];
	_task setTaskState "CREATED";
	_task setSimpleTaskAlwaysVisible true;
	_task setTaskState "ASSIGNED";
	["TaskAssigned", ["",_taskTitle]] call BIS_fnc_showNotification;
	NWG_TUT_currentTask = _task;
};
NWG_TUT_CloseTask = {
	if (isNull NWG_TUT_currentTask) exitWith {};
	player removeSimpleTask NWG_TUT_currentTask;
	NWG_TUT_currentTask = taskNull;
};

//================================================================================================================
//================================================================================================================
[] spawn _Init;