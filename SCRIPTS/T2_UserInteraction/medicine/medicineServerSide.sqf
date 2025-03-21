#include "..\..\globalDefines.h"
#include "medicineDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_MED_SER_Settings = createHashMapFromArray [
    ["BLAME_REPORT_SELFDAMAGE",false],//If true, self-inflicted damage will be reported as well (e.g.: True: 'Joe hit Joe', False: 'Joe is hit')
    ["ACTION_HEAL_FAILURE_PLACE_GARBAGE",true],//If true, the server will place medical garbage near the wounded on heal failure
    ["ACTION_HEAL_FAILURE_PLAY_ANIM",true],//If true, the wounded will be forced to play additional animation on heal failure

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

    //Additional handling
    _passiveUnit call NWG_MED_SER_CheckDetachNeeded;
};

//================================================================================================================
//================================================================================================================
//Action handler
NWG_MED_SER_OnMedAction = {
    params ["_activeUnit","_passiveUnit","_action"];
    //Checks
    private _activeValid = !isNull _activeUnit && {alive _activeUnit};
    private _passiveValid = if (_passiveUnit isEqualType objNull)
        then {!isNull _passiveUnit && {alive _passiveUnit}}
        else {(_passiveUnit findIf {isNull _x || {!alive _x}}) == -1};
    if (!_activeValid || !_passiveValid) exitWith {
        (format ["NWG_MED_SER_OnMedAction: Invalid arguments. Args: %1",_this]) call NWG_fnc_logError;
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
            _passiveUnit call NWG_MED_SER_GarbageAndAnim;//Place garbage and play animation
        };
        case ACTION_DRAG: {
            if (!isNull (attachedTo _passiveUnit)) exitWith {};//Already being dragged
            _passiveUnit attachTo [_activeUnit,[0,1,0.1]];
            _passiveUnit setVectorDirAndUp [[0,1,0],[0,0,1]];
            [_passiveUnit,"Acts_Waking_Up_Player"] call NWG_fnc_playAnimGlobal;
            [_passiveUnit,SUBSTATE_DRAG] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_CARRY: {
            if (!isNull (attachedTo _passiveUnit)) exitWith {};//Already being carried
            _passiveUnit attachTo [_activeUnit,[0.15,0.15,0.1]];
            [_passiveUnit,"AinjPfalMstpSnonWrflDf_carried_dead"] call NWG_fnc_playAnimGlobal;
            [_passiveUnit,SUBSTATE_CARR] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_RELEASE: {
            if (isNull (attachedTo _passiveUnit)) exitWith {};//Already released
            detach _passiveUnit;
            _passiveUnit call NWG_fnc_medFlipUnit;//Fix unit direction
            [_passiveUnit,"UnconsciousFaceUp"] call NWG_fnc_playAnimGlobal;
            [_passiveUnit,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
        };
        case ACTION_VEHLOAD: {
            _passiveUnit params ["_unit","_vehicle"];//The only action that passes two arguments
            if (isNull (attachedTo _unit)) exitWith {};//Already released
            detach _unit;

            private _abort = {
                /*Place on the ground like in 'ACTION_RELEASE'*/
                _unit call NWG_fnc_medFlipUnit;
                [_unit,"UnconsciousFaceUp"] call NWG_fnc_playAnimGlobal;
                [_unit,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
            };

            if (!alive _vehicle || {_vehicle isEqualTo _activeUnit}) exitWith {call _abort};
            if (((crew _vehicle) findIf {
                alive _x && {
                (incapacitatedState _x) isEqualTo "" && {
                (side (group _x)) isNotEqualTo (side (group _activeUnit))}}
            }) != -1) exitWith {call _abort};//Occupied by enemy
            private _fullCrew = _vehicle call NWG_fnc_getFullCrew;
            if (_fullCrew isEqualTo []) exitWith {call _abort};//Invalid vehicle
            private _cargoSeats = [];
            private _restSeats = [];
            {
                if (alive (_x#0)) then {continue};//Skip occupied seats
                if ((_x#1) isEqualTo "driver") then {continue};//Skip driver
                if ((_x#2) >= 0)
                    then {_cargoSeats pushBack _x}
                    else {_restSeats pushBack _x};
            } forEach _fullCrew;
            if !("Offroad_02" in (typeOf _vehicle)) then {
                reverse _cargoSeats;
                reverse _restSeats;
            };//Exception for one particularly nasty vehicle that may have last seats invalid resulting in wounded unit to drop on the ground

            _fullCrew = _cargoSeats + _restSeats;
            if (_fullCrew isEqualTo []) exitWith {call _abort};//No available seats

            /*Load into vehicle*/
            [_unit,_vehicle,_fullCrew] call NWG_fnc_medLoadIntoVehicle;
            [_unit,SUBSTATE_INVH] call NWG_MED_COM_SetSubstate;
        };
        default {
            "NWG_MED_SER_OnMedAction: Unknown action type" call NWG_fnc_logError;
        };
    };
};

//================================================================================================================
//================================================================================================================
//Garbage and animations
NWG_MED_SER_medGarbage = [
    "MedicalGarbage_01_Packaging_F",
    "MedicalGarbage_01_FirstAidKit_F",
    "MedicalGarbage_01_Bandage_F",
    "MedicalGarbage_01_1x1_v3_F",
    "MedicalGarbage_01_1x1_v2_F",
    "MedicalGarbage_01_1x1_v1_F"
];
NWG_MED_SER_woundedAnims = [
    "UnconsciousReviveArms_A",
    "UnconsciousReviveArms_B",
    "UnconsciousReviveArms_C",
    "UnconsciousReviveBody_A",
    "UnconsciousReviveBody_B",
    "UnconsciousReviveLegs_A",
    "UnconsciousReviveLegs_B"
];

NWG_MED_SER_GarbageAndAnim = {
    private _unit = _this;
    //Checks
    if (isNull _unit || {!(alive _unit)}) exitWith {};//Invalid unit
    if ((vehicle _unit) isNotEqualTo _unit) exitWith {};//Only for infantry
    if (((getPosWorld _unit)#2) < 0) exitWith {};//Underwater

    //Place random garbage
    if (NWG_MED_SER_Settings get "ACTION_HEAL_FAILURE_PLACE_GARBAGE") then {
        private _classname = [NWG_MED_SER_medGarbage,"NWG_MED_SER_medGarbage"] call NWG_fnc_selectRandomGuaranteed;
        private _garbage = createVehicle [_classname,_unit,[],1,"CAN_COLLIDE"];
        _garbage call NWG_fnc_gcReportTrash;
    };

    //Play random animation
    if (NWG_MED_SER_Settings get "ACTION_HEAL_FAILURE_PLAY_ANIM") then {
        private _animname = [NWG_MED_SER_woundedAnims,"NWG_MED_SER_woundedAnims"] call NWG_fnc_selectRandomGuaranteed;
        [_unit,_animname] call NWG_fnc_medPlayAnim;
    };
};

//================================================================================================================
//================================================================================================================
//Detaching units
NWG_MED_SER_CheckDetachNeeded = {
    // private _unit = _this;
    if (isNull _this) exitWith {};//Invalid unit
    if !(_this isKindOf "Man") exitWith {};//Only for infantry
    if !(_this call NWG_MED_COM_HasStates) exitWith {};//Not a part of medicine system (so could not drag anyone)

    //If this unit is being dragged/carried by someone
    if (!isNull (attachedTo _this)) exitWith {
        /*Get dragger info*/
        private _dragger = attachedTo _this;
        if !(_dragger isKindOf "Man") exitWith {};
        if !(_dragger call NWG_MED_COM_HasStates) exitWith {};
        /*Handle this unit*/
        detach _this;
        if (alive _this) then {
            _this call NWG_fnc_medFlipUnit;
            [_this,"UnconsciousFaceUp"] call NWG_fnc_playAnimGlobal;
            [_this,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
        };
        /*Handle dragger*/
        _dragger call NWG_fnc_medAbortDragAndCarry;
    };

    //If this unit is dragging someone
    if ((count (attachedObjects _this)) > 0) exitWith {
        /*Get dragged info*/
        private _dragged = (attachedObjects _this) select {_x isKindOf "Man" && {_x call NWG_MED_COM_HasStates}};
        if ((count _dragged) == 0) exitWith {};
        /*Handle dragged unit(s)*/
        {
            detach _x;
            if (alive _x) then {
                _x call NWG_fnc_medFlipUnit;
                [_x,"UnconsciousFaceUp"] call NWG_fnc_playAnimGlobal;
                [_x,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
            };
        } forEach _dragged;
        /*Handle this unit*/
        if (alive _this && {!(_this call NWG_MED_COM_IsWounded)})
            then {_this call NWG_fnc_medAbortDragAndCarry};
    };
};

//Add handlers to catch mission events
addMissionEventHandler ["HandleDisconnect",{
    // params ["_unit", "_id", "_uid", "_name"];
    (_this#0) call NWG_MED_SER_CheckDetachNeeded;
    //Fix AI replacing player
    false
}];
addMissionEventHandler ["EntityRespawned",{
    // params ["_newEntity","_oldEntity"];
    (_this#1) call NWG_MED_SER_CheckDetachNeeded;
}];