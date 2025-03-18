#include "..\..\globalDefines.h"
/*
    Connector between quests and missionMachine modules
*/

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_QST_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_QST_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
    if (_newState != MSTATE_BUILD_QUESTS) exitWith {};
    if (call NWG_fnc_mmIsEscapeLevel) exitWith {call NWG_fnc_qstClearAll};//Clear all quests if this is a last escape level

    /*Mission building quests state - Create new quest*/
    //Get all mission objects and occupied map buildings
    (call NWG_fnc_mmGetMissionObjects) params [["_bldgs",[]],["_furns",[]],["_decos",[]],["_units",[]],["_vehcs",[]]/*,"_trrts","_mines"*/];
    private _occupiedBuildings = call NWG_fnc_shGetOccupiedBuildings;
    private _questObjects = [(_bldgs + _occupiedBuildings),_furns,_decos,_units,_vehcs];

    //Create new quest
    private _ok = _questObjects call NWG_fnc_qstCreateNew;
    if (!_ok) then {
        format ["NWG_QST_MMC_OnMissionStateChanged: Failed to create new quest for mission '%1'",(call NWG_fnc_mmGetMissionName)] call NWG_fnc_logError;
    };
};

//================================================================================================================
call _Init;