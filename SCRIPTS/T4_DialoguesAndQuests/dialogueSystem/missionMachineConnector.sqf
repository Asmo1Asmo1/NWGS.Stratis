#include "..\..\globalDefines.h"
/*
    Connector between dialogueSystem and missionMachine modules
*/

//================================================================================================================
//Settings
NWG_DLG_MMC_Settings = createHashMapFromArray [
    /*Unit classname to npc name relation*/
    ["B_G_Story_Guerilla_01_F",NPC_TAXI],
    ["I_G_Story_Protagonist_F",NPC_MECH],
    ["I_G_resistanceLeader_F", NPC_TRDR],
    ["I_C_Soldier_Camo_F",     NPC_MEDC],
    ["I_E_Soldier_MP_F",       NPC_COMM],
    ["B_G_Captain_Ivan_F",     NPC_ROOF],

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_DLG_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On mission state changed
NWG_DLG_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];
    if (_newState != MSTATE_BASE_QUESTS) exitWith {};

    /*Base building quests state - Initialize dialogue module*/
    //Get player base decorations
    //returns: [obj,[array]]
    // - obj - persistent player base or objNull if there are none
    // - array - decorations in format ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"] or
    (call NWG_fnc_mmGetPlayerBase) params ["","_baseDecor"];
    if (isNil "_baseDecor" || {!(_baseDecor isEqualType [])}) exitWith {
        "NWG_DLG_MMC_OnMissionStateChanged: Invalid base decor" call NWG_fnc_logError;
    };
    private _baseNpcs = _baseDecor param [OBJ_CAT_UNIT,[]];
    if ((count _baseNpcs) == 0) exitWith {
        "NWG_DLG_MMC_OnMissionStateChanged: No NPCs found in base decor" call NWG_fnc_logError;
    };

    //Assign npc marks
    {
        private _npcName = NWG_DLG_MMC_Settings get (typeOf _x);
        if (!isNil "_npcName")
            then {[_x,_npcName] call NWG_fnc_dlgSetNpcName}
            else {format ["NWG_DLG_MMC_OnMissionStateChanged: NPC name not found in NWG_DLG_MMC_Settings: %1",(typeOf _x)] call NWG_fnc_logError};
    } forEach _baseNpcs;
};

//================================================================================================================
call _Init;