#include "..\..\globalDefines.h"
#include "tutorialDefines.h"
/*
    Connector between tutorial and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_TUT_MMC_Settings = createHashMapFromArray [
    /*Object type to tutorial step mapping*/
    ["OBJ_TO_STEP",[
/*STEP_01_TAXI*/"B_G_Story_Guerilla_01_F",
/*STEP_02_TRDR*/"I_G_resistanceLeader_F",
/*STEP_03_STRG*/"B_supplyCrate_F",
/*STEP_04_COMM*/"Land_IPPhone_01_olive_F",/*Fix task marker floating into the sky for wtf reason*/
/*STEP_05_TAXI*/"B_G_Story_Guerilla_01_F"
    ]],

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_TUT_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_TUT_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
    if (_newState != MSTATE_BASE_QUESTS) exitWith {};

    //Get base objects
    private _baseDeco = ((call NWG_fnc_mmGetPlayerBase) param [1,[]]) param [OBJ_CAT_DECO,[]];
    private _baseNPCs = call NWG_fnc_mmGetPlayerBaseNPCs;
    private _baseObjects = _baseDeco + _baseNPCs;

    //Extract objects for tutorial
    private _result = [];
    private _cur = "";
    private _i = -1;
    {
        _cur = _x;
        _i = _baseObjects findIf {(typeOf _x) isEqualTo _cur};
        if (_i != -1)
            then {_result pushBack (_baseObjects#_i)}
            else {(format ["NWG_TUT_MMC_OnMissionStateChanged: Object '%1' not found in base objects",_cur]) call NWG_fnc_logError};
    } forEach (NWG_TUT_MMC_Settings get "OBJ_TO_STEP");

    //Set tutorial objects
    _result call NWG_fnc_tutSetTutorialObjects;
};

//================================================================================================================
call _Init;