#include "..\..\globalDefines.h"
#include "medicineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MED_SER_Settings = createHashMapFromArray [
    ["BLAME_REPORT_SELFDAMAGE",true],//If true, self-inflicted damage will be reported as well (e.g.: True: 'Joe hit Joe', False: 'Joe is hit')

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Blame handler
NWG_MED_SER_OnBlame = {
    params ["_activeUnit","_passiveUnit","_blame"];
    //Checks
    if (isNull _passiveUnit) exitWith {
        (format ["NWG_MED_SER_OnBlame: Passive unit is null. Args: '%1'",_this]) call NWG_fnc_logError;
    };
    if (_activeUnit isEqualTo _passiveUnit && {!(NWG_MED_SER_Settings get "BLAME_REPORT_SELFDAMAGE")}) then {
        _activeUnit = objNull;
    };

    //Handle
    switch (_blame) do {
        case BLAME_VEH_KO: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_VEH_KO_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_VEH_KO_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case BLAME_WOUND: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_WOUND_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_WOUND_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case BLAME_KILL: {
            if (isNull _activeUnit)
                then {["#MED_BLAME_KILL_NOBODYS#",(name _passiveUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_BLAME_KILL_DAMAGER#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        default {
            (format ["NWG_MED_SER_OnBlame: Unknown blame type '%1'",_blame]) call NWG_fnc_logError;
        };
    };
};

//================================================================================================================
//================================================================================================================
//Action handler
NWG_MED_SER_OnMedAction = {
    params ["_activeUnit","_passiveUnit","_action"];
    //Checks
    if (!alive _activeUnit || {_passiveUnit isEqualType objNull && {!alive _passiveUnit}}) exitWith {
        //Also checks for objNull ('alive objNull' returns false)
        (format ["NWG_MED_SER_OnMedAction: Active or passive unit is invalid. Args: %1",_this]) call NWG_fnc_logError;
    };

    //Handle
    switch (_action) do {
        case ACTION_PATCH: {
            if (_passiveUnit call NWG_MED_COM_IsPatched) exitWith {};//Already patched
            [_passiveUnit,true] call NWG_MED_COM_SetPatched;

            if (_activeUnit isEqualTo _passiveUnit)
                then {["#MED_ACTION_SELF_HEAL_PATCHED#",(name _activeUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_ACTION_HEAL_PATCHED#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case ACTION_HEAL_SUCCESS;
        case ACTION_HEAL_PARTIAL: {
            if !(_passiveUnit call NWG_MED_COM_IsWounded) exitWith {};//Already healed
            [_passiveUnit,false] call NWG_MED_COM_MarkWounded;
            if (_action isEqualTo ACTION_HEAL_SUCCESS)
                then {_passiveUnit setDamage 0};//Fully heal the unit (the difference between this and partial)
            if (_activeUnit isEqualTo _passiveUnit)
                then {["#MED_ACTION_SELF_HEAL_SUCCESS#",(name _activeUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_ACTION_HEAL_SUCCESS#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case ACTION_HEAL_FAILURE: {
            if (_activeUnit isEqualTo _passiveUnit)
                then {["#MED_ACTION_SELF_HEAL_FAILURE#",(name _activeUnit)] call NWG_fnc_systemChatAll}
                else {["#MED_ACTION_HEAL_FAILURE#",(name _activeUnit),(name _passiveUnit)] call NWG_fnc_systemChatAll};
        };
        case ACTION_DRAG: {
            if (!isNull (attachedTo _passiveUnit)) exitWith {};//Already being dragged
            _passiveUnit attachTo [_activeUnit,[0,1,0.1]];
            _passiveUnit setVectorDirAndUp [[0,1,0],[0,0,1]];
            [_passiveUnit,"Acts_Waking_Up_Player"] call NWG_fnc_playAnim;
            [_passiveUnit,SUBSTATE_DRAG] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_CARRY: {
            if (!isNull (attachedTo _passiveUnit)) exitWith {};//Already being carried
            _passiveUnit attachTo [_activeUnit,[0.15,0.15,0.1]];
            [_passiveUnit,"AinjPfalMstpSnonWrflDf_carried_dead"] call NWG_fnc_playAnim;
            [_passiveUnit,SUBSTATE_CARR] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_RELEASE: {
            if (isNull (attachedTo _passiveUnit)) exitWith {};//Already released
            detach _passiveUnit;
            _passiveUnit setDir ((getDir _passiveUnit) + 180);//Fix unit direction
            [_passiveUnit,"UnconsciousFaceUp"] call NWG_fnc_playAnim;
            [_passiveUnit,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_VEHLOAD: {
            _passiveUnit params ["_unit","_vehicle"];//The only action that passes two arguments
            if (isNull (attachedTo _unit)) exitWith {};//Already released
            if (!alive _unit) exitWith {};//Unit is dead
            if (!alive _vehicle) exitWith {};//Vehicle is dead
            detach _unit;

            private _allSeats = ((fullCrew [_vehicle,"",true]) select {
                isNull (_x#0) && { /*Empty seat*/
                (_x#2) >= 0} /*Cargo index valid*/
            }) apply {
                _x#2 /*Cargo index*/
            };
            reverse _allSeats;//Prefer the last seat

            if ((count _allSeats) > 0) then {
                /*Load into available seat*/
                private _seat = _allSeats select 0;
                [_unit,_vehicle,_seat] call NWG_fnc_medLoadIntoVehicle;
            } else {
                /*Place on the ground like in 'ACTION_RELEASE'*/
                _unit setDir ((getDir _unit) + 180);
                [_unit,"UnconsciousFaceUp"] call NWG_fnc_playAnim;
                [_unit,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
            };
        };
        default {
            "NWG_MED_SER_OnMedAction: Unknown action type" call NWG_fnc_logError;
        };
    };
};