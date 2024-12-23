#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
#define TOOLKIT "ToolKit"

//================================================================================================================
//================================================================================================================
//Settings
NWG_ENG_Settings = createHashMapFromArray [
    ["REPAIR_ACTION_ASSIGN",true],
    ["REPAIR_ACTION_TITLE","#ENG_REPAIR_TITLE#"],
    ["REPAIR_ACTION_ICON","a3\ui_f\data\igui\cfg\actions\repair_ca.paa"],
    ["REPAIR_ACTION_PRIORITY",20],
    ["REPAIR_ACTION_DURATION",12],
    ["REPAIR_MATRIX",[
        ["hull","body","hitera","glass","light", "" ],/*"" - all parts, must be last as it gives 'true' to any part*/
        [0.50,  0.50,  0.97,    0.97,   0.97,   0.33]
    ]],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_ENG_hasToolkit = false;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    [EVENT_ON_LOADOUT_CHANGED,{_this call NWG_ENG_OnInventoryChanged}] call NWG_fnc_subscribeToClientEvent;
    call NWG_ENG_AssignActions;
    player addEventHandler ["Respawn",{call NWG_ENG_AssignActions}];//Reassign actions on respawn
};

//================================================================================================================
//================================================================================================================
//Toolkit detection
NWG_ENG_OnInventoryChanged = {
    params ["","_flattenLoadOut"];
    NWG_ENG_hasToolkit = TOOLKIT in _flattenLoadOut;
};

//================================================================================================================
//================================================================================================================
//Actions assign
NWG_ENG_AssignActions = {
    //Prepare assignment
    private _assignAction = {
        params ["_title","_icon","_priority","_duration","_condition","_onStarted","_onInterrupted","_onCompleted"];
        [
            player,                         // Object the action is attached to
            (_title call NWG_fnc_localize), // Title of the action
            _icon,                          // Idle icon shown on screen
            _icon,                          // Progress icon shown on screen
            _condition,                     // Condition for the action to start
            _condition,                     // Condition for the action to progress
            _onStarted,                     // Code executed when action starts
            {},                             // Code executed on every progress tick
            _onCompleted,                   // Code executed on completion
            _onInterrupted,                 // Code executed on interrupted
            [],                             // Arguments passed to the scripts as _this select 3
            _duration,                      // Action duration in seconds
            _priority,                      // Priority
            false,                          // Remove on completion
            false,                          // Show in unconscious state
            true                            // Auto show on screen
        ] call BIS_fnc_holdActionAdd
    };

    //Assign actions
    private ["_title","_icon","_priority","_duration","_condition","_onStarted","_onInterrupted","_onCompleted"];

    /*Vehicle fix*/
    if (NWG_ENG_Settings get "REPAIR_ACTION_ASSIGN") then {
        //Hack-in short-circuit condition check for lowest down-to value (save some resources)
        (NWG_ENG_Settings get "REPAIR_MATRIX") params ["","_downToRules"];
        private _lowest = 1;
        {if (_x < _lowest) then {_lowest = _x}} forEach _downToRules;
        NWG_ENG_VehicleFix_lowestDownTo = _lowest;

        //Assign action
        _title = NWG_ENG_Settings get "REPAIR_ACTION_TITLE";
        _icon = NWG_ENG_Settings get "REPAIR_ACTION_ICON";
        _priority = NWG_ENG_Settings get "REPAIR_ACTION_PRIORITY";
        _duration = NWG_ENG_Settings get "REPAIR_ACTION_DURATION";
        _condition = "call NWG_ENG_VehicleFix_Condition";
        _onStarted = {call NWG_ENG_VehicleFix_OnStarted};
        _onInterrupted = {call NWG_ENG_VehicleFix_OnInterrupted};
        _onCompleted = {call NWG_ENG_VehicleFix_OnCompleted};
        [_title,_icon,_priority,_duration,_condition,_onStarted,_onInterrupted,_onCompleted] call _assignAction;
    };
};

NWG_ENG_ResetAnimation = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if ((vehicle player) isNotEqualTo player) exitWith {};//Don't do animation reset in vehicles
    player switchMove "";
};

//================================================================================================================
//================================================================================================================
//Vehicle fix (Repair action)
NWG_ENG_VehicleFix_lowestDownTo = 1;
NWG_ENG_VehicleFix_Condition = {
    //Simple checks
    if (!NWG_ENG_hasToolkit) exitWith {false};
    if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};

    //Short-circuit check for undamaged vehicles
    (getAllHitPointsDamage (call NWG_fnc_radarGetVehInFront)) params ["_vehParts","","_vehDamages"];
    if ((_vehDamages findIf {_x > NWG_ENG_VehicleFix_lowestDownTo}) == -1) exitWith {false};

    //Complex check for vehicle parts
    (NWG_ENG_Settings get "REPAIR_MATRIX") params ["_partsRules","_downToRules"];
    private _result = false;
    {
        if (_x > (_downToRules param [(_partsRules findIf {_x in (_vehParts#_forEachIndex)}),0])) exitWith {_result = true};
    } forEach _vehDamages;
    _result
};
NWG_ENG_VehicleFix_OnStarted = {
    player playMoveNow "Acts_carFixingWheel";
};
NWG_ENG_VehicleFix_OnInterrupted = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Game logic will handle this
    call NWG_ENG_ResetAnimation;
};
NWG_ENG_VehicleFix_OnCompleted = {
    call NWG_ENG_ResetAnimation;
    private _vehicle = call NWG_fnc_radarGetVehInFront;
    if (isNull _vehicle) exitWith {};

    (getAllHitPointsDamage (call NWG_fnc_radarGetVehInFront)) params ["_vehParts","","_vehDamages"];
    (NWG_ENG_Settings get "REPAIR_MATRIX") params ["_partsRules","_downToRules"];
    private _fixDownTo = 0;
    {
        _fixDownTo = _downToRules param [(_partsRules findIf {_x in (_vehParts#_forEachIndex)}),0];
        if (_x > _fixDownTo) then {_vehicle setHitIndex [_forEachIndex,_fixDownTo]};
    } forEach _vehDamages;
};

//================================================================================================================
//================================================================================================================
call _Init;