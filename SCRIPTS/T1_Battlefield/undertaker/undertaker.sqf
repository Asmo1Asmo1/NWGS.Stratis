#include "..\..\globalDefines.h"

//================================================================================================================
//Settings
NWG_UNDTKR_Settings = createHashMapFromArray [
    ["REMEMBER_PLAYER_DAMAGE_FOR_SECONDS",120],//For how long to remember last damage to a vehicle made by player (for 'who killed that vehicle' check)
    ["SHOW_DEBUG_MESSAGE",false],//Show debug message in systemChat

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["EntityCreated",{_this call NWG_UNDTKR_OnCreated}];
    addMissionEventHandler ["EntityKilled",{_this call NWG_UNDTKR_OnKilled}];
};

//==============================================================================================================
//Event handlers
NWG_UNDTKR_OnCreated = {
    params [["_object",objNull]];
    if (isNull _object) exitWith {};

    if (_object call NWG_fnc_ocIsVehicle) then {
        _object addMPEventHandler ["MPHit",{if (isServer) then {_this call NWG_UNDTKR_OnVehHit}}]
    };
};

NWG_UNDTKR_OnVehHit = {
    params [["_vehicle",objNull],["_killer",objNull],"_NaN",["_instigator",objNull]];
    if (isNull _vehicle) exitWith {};

    private _damager = [_killer,_instigator] call NWG_UNDTKR_DefineKiller;
    if (alive _damager && {_damager isKindOf "Man" && {isPlayer _damager}}) then {
        _vehicle setVariable ["NWG_UNDTKR_lastPlayerDamager",[time,_damager]];
    };
};

NWG_UNDTKR_OnKilled = {
	params [["_obj",objNull],["_killer",objNull],["_instigator",objNull]/*,"_useEffects"*/];
    if (isNull _obj) exitWith {};//There's nothing we can do about it, so don't even log errors
    if ("_UAV_AI" in (typeOf _obj)) exitWith {};//Ignore UAV invisible pilots (they crash the game if deleted)

    private _objType = _obj call NWG_fnc_ocGetObjectType;
    private _actualKiller = [_killer,_instigator] call NWG_UNDTKR_DefineKiller;
    private _isPlayerKiller = alive _actualKiller && {(_actualKiller isKindOf "Man") && {isPlayer _actualKiller}};

    //Re-check for vehicles
    if (!_isPlayerKiller && {_objType isEqualTo OBJ_TYPE_VEHC}) then {
        if (isNil {_obj getVariable "NWG_UNDTKR_lastPlayerDamager"}) exitWith {};//No player damage was dealt to this vehicle
        (_obj getVariable "NWG_UNDTKR_lastPlayerDamager") params ["_time","_damager"];
        if ((time - _time) > (NWG_UNDTKR_Settings get "REMEMBER_PLAYER_DAMAGE_FOR_SECONDS")) exitWith {};//Last player damage was dealt more than N seconds ago
        if (!alive _damager) exitWith {};//Last player damager is dead or disconnected
        _actualKiller = _damager;
        _isPlayerKiller = true;
    };

    //Debug
    if (NWG_UNDTKR_Settings get "SHOW_DEBUG_MESSAGE") then {
        private _msg = format ["NWG_UNDTKR_OnKilled: %1 (%2) was killed by %3 (isPlayer: %4)",_obj,_objType,_actualKiller,_isPlayerKiller];
        systemChat _msg;
        diag_log _msg;
    };

    //Raise event
    [EVENT_ON_OBJECT_KILLED,[_obj,_objType,_actualKiller,_isPlayerKiller]] call NWG_fnc_raiseServerEvent;
};

//==============================================================================================================
//Utils
NWG_UNDTKR_DefineKiller = {
    //Supposed to work with EH "HandleDamage" or "EntityKilled", where _killer and _instigator are present
    params [["_killer",objNull],["_instigator",objNull]];

    private _suspect = switch (true) do {
        case (!isNull _instigator): {_instigator};
        case (!isNull _killer): {_killer};
        default {objNull};
    };

    //return
    switch (true) do {
        case (isNull _suspect):                   {objNull};//Nobody, huh?! The fairy fucking godmother did it! Out-fucking-standing!
        case (_suspect isKindOf "Man"):           {_suspect};
        case (unitIsUAV _suspect):                {((UAVControl _suspect) param [0,objNull])};
        case (_suspect isKindOf "StaticWeapon"):  {(gunner _suspect)};
        case (_suspect call NWG_fnc_ocIsVehicle): {(driver _suspect)};
        default                                   {objNull};
    }
};

//Init
call _Init;