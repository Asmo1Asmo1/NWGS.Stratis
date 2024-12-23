#include "..\..\globalDefines.h"
/*
    Deplete player's loot on disconnect
*/

//================================================================================================================
//Settings
NWG_PSH_LDD_Settings = createHashMapFromArray [
    ["DEPLETE_ON_DISCONNECT",true],//Deplete loot on disconnect
    ["DEPLETE_MULTIPLIER",0.5],//Multiplier for the loot deplete on disconnect
    ["LOOT_STATE_NAME","loot_storage"],//Name of the loot state

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["HandleDisconnect",{
        // params ["_unit", "_id", "_uid", "_name"];
        _this call NWG_PSH_LDD_OnDisconnected;
        //Fix AI replacing player
        false
    }];
};

//================================================================================================================
//On disconnected
NWG_PSH_LDD_OnDisconnected = {
    // params ["_unit", "_id", "_uid", "_name"];
    params ["_unit","","_steamID",""];

    //Check if deplete is enabled
    if !(NWG_PSH_LDD_Settings get "DEPLETE_ON_DISCONNECT") exitWith {};//Deplete is disabled

    //Check that player was not on base
    private _onBase = if (!isNil "_unit" && {!isNull _unit})
        then {_unit call NWG_fnc_mmIsUnitInBase}
        else {
            (format ["NWG_PSH_LDD_OnDisconnected: Unit is nil/null for player: '%1'. Fallback to 'true' for base check.",_steamID]) call NWG_fnc_logError;
            true
        };
    if (_onBase) exitWith {};//Player was on base, do not deplete

    //Get current loot state
    private _loot = [_steamID,(NWG_PSH_LDD_Settings get "LOOT_STATE_NAME")] call NWG_fnc_pshGetState;
    if (_loot isEqualTo false) exitWith {
        (format ["NWG_PSH_LDD_OnDisconnected: Loot state not found for player: '%1'",_steamID]) call NWG_fnc_logError;
    };

    //Deplete loot
    private _multiplier = NWG_PSH_LDD_Settings get "DEPLETE_MULTIPLIER";
    _loot = [_loot,_multiplier,/*notify:*/false] call NWG_fnc_lsDepleteLoot;

    //Set new loot state
    private _ok = [_steamID,(NWG_PSH_LDD_Settings get "LOOT_STATE_NAME"),_loot] call NWG_fnc_pshSetState;
    if !(_ok) then {
        (format ["NWG_PSH_LDD_OnDisconnected: Failed to set new loot state for player: '%1'",_steamID]) call NWG_fnc_logError;
    };
};

//================================================================================================================
call _Init;
