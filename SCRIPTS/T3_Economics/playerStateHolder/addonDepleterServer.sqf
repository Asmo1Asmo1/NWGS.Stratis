#include "..\..\globalDefines.h"
/*
    Addon to deplete player loot, additionalWeapon and loadout on respawn and disconnect if far from base
    This module uses inner methods of 'playerStateHolderServer' module without precautions and/or functions
    Handle with care
*/

//================================================================================================================
//Settings
NWG_PSH_DPL_Settings = createHashMapFromArray [
    ["DEPLETE_ON_RESPAWN",true],//Deplete loot on respawn
    ["DEPLETE_ON_DISCONNECT",true],//Deplete loot on disconnect

    ["BASE_PROXIMITY_CHECK_ENABLED",true],//Check if player was on base (if set to false, values will be depleted regardless of player's location)
    ["BASE_PROXIMITY_CHECK_DEFAULT_VALUE",true],//Default value for the base proximity check if proximity check was enabled but could not be done

    ["LOADOUT_STATE_NAME","loadout"],//Name of the loadout state
    ["LOADOUT_DEFAULT",[[],[],[],["U_OG_Guerilla1_1",[]],[],[],"","",[],["","","","","",""]]],//Default loadout
    ["LOADOUT_DEPLETE_POKES",3],//Number of pokes to do in player's loadout (may overlap, so it is 1..N)
    ["LOADOUT_DEPLETED_LOC_KEY","#DPL_LOADOUT_DEPLETED#"],//Localization key for the loadout depleted message

    ["ADD_WEAPON_STATE_NAME","add_weapon"],//Name of the additional weapon state
    ["ADD_WEAPON_DEFAULT",[]],//Default additional weapon state
    ["ADD_WEAPON_LOOSE_CHANCE",0.5],//Chance to lose additional weapon on deplete
    ["ADD_WEAPON_DEPLETED_LOC_KEY","#DPL_ADD_WEAPON_DEPLETED#"],//Localization key for the additional weapon depleted message

    ["LOOT_STATE_NAME","loot_storage"],//Name of the loot state
    ["LOOT_DEFAULT",LOOT_ITEM_DEFAULT_CHART],//Default loot state
    ["LOOT_DEPLETE_MULTIPLIER",0.5],//Multiplier for the loot deplete
    ["LOOT_DEPLETED_LOC_KEY","#DPL_LOOT_DEPLETED#"],//Localization key for the loot depleted message

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["EntityRespawned", {
        // params ["_newEntity", "_oldEntity"];
        _this call NWG_PSH_DPL_OnRespawn;
    }];

    addMissionEventHandler ["HandleDisconnect",{
        // params ["_unit", "_id", "_uid", "_name"];
        _this call NWG_PSH_DPL_OnDisconnected;
        //Fix AI replacing player
        false
    }];
};

//================================================================================================================
//Event handlers
NWG_PSH_DPL_OnRespawn = {
    params [["_player",objNull],["_corpse",objNull]];

    //Checks
    if !(NWG_PSH_DPL_Settings get "DEPLETE_ON_RESPAWN") exitWith {};//Deplete is disabled
    if (isNull _player) exitWith {};
    if !(_player isKindOf "Man") exitWith {};
    if !(isPlayer _player) exitWith {};

    //Base proximity check
    if (_corpse call NWG_PSH_DPL_WasOnBase) exitWith {
        //Player was on base, do not deplete, just re-apply known states
        _player call NWG_fnc_pshOnPlayerJoined;
    };

    //Get unit steamID
    private _steamID = _player call NWG_PSH_SER_GetPlayerId;
    if (isNil "_steamID" || {_steamID isEqualTo false}) exitWith {
        (format ["NWG_PSH_DPL_OnRespawn: Player steamID not found for player: '%1'",(name _player)]) call NWG_fnc_logError;
    };

    //Deplete
    [_steamID,true,_player] call NWG_PSH_DPL_Deplete;

    //Re-apply known states (now depleted)
    _player call NWG_fnc_pshOnPlayerJoined;
};

NWG_PSH_DPL_OnDisconnected = {
    // params ["_unit", "_id", "_uid", "_name"];
    params [["_corpse",objNull],"",["_steamID",""]];

    //Checks
    if !(NWG_PSH_DPL_Settings get "DEPLETE_ON_DISCONNECT") exitWith {};//Deplete is disabled
    if (_steamID isEqualTo "") exitWith {
        (format ["NWG_PSH_DPL_OnDisconnected: Player steamID not provided for player: '%1'",(name _corpse)]) call NWG_fnc_logError;
    };

    //Base proximity check
    if (_corpse call NWG_PSH_DPL_WasOnBase) exitWith {};//Player disconnected while on base, do not deplete

    //Deplete
    [_steamID,false,objNull] call NWG_PSH_DPL_Deplete;
};

//================================================================================================================
//Base proximity check
NWG_PSH_DPL_WasOnBase = {
    private _corpse = _this;
    if !(NWG_PSH_DPL_Settings get "BASE_PROXIMITY_CHECK_ENABLED") exitWith {
        false
    };
    if (isNil "_corpse" || {isNull _corpse}) exitWith {
        "NWG_PSH_DPL_WasOnBase: Corpse is nil/null. Fallback to default value" call NWG_fnc_logError;
        NWG_PSH_DPL_Settings get "BASE_PROXIMITY_CHECK_DEFAULT_VALUE"
    };

    //return
    _corpse call NWG_fnc_mmIsUnitInBase
};

//================================================================================================================
//Deplete logic
NWG_PSH_DPL_Deplete = {
    params ["_steamID","_notify","_playerObj"];

    //Get current known player state
    private _playerState = NWG_PSH_SER_playerStateCache get _steamID;
    if (isNil "_playerState") exitWith {
        (format ["NWG_PSH_DPL_Deplete: Player state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };
    private ["_stateName","_state","_defaultState"];

    //Deplete loadout
    _stateName = (NWG_PSH_DPL_Settings get "LOADOUT_STATE_NAME");
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _loadout = _state + [];//Shallow copy
        private _defaultLoadout = NWG_PSH_DPL_Settings get "LOADOUT_DEFAULT";
        private _isPoked = false;//Flag that loadout was affected

        private ["_pokeAt","_cur","_def"];
        for "_i" from 1 to (NWG_PSH_DPL_Settings get "LOADOUT_DEPLETE_POKES") do {
            _pokeAt = floor (random (count _loadout));
            _cur = _loadout select _pokeAt;
            _def = _defaultLoadout select _pokeAt;
            if (_cur isEqualTo _def) then {continue};
            _loadout set [_pokeAt,_def];
            _isPoked = true;
        };

        if (_isPoked)
            then {_playerState set [_stateName,_loadout]};
        if (_isPoked && {_notify && {!isNull _playerObj}})
            then {(NWG_PSH_DPL_Settings get "LOADOUT_DEPLETED_LOC_KEY") remoteExec ["NWG_fnc_systemChatMe",_playerObj]};
    } else {
        (format ["NWG_PSH_DPL_Deplete: Loadout state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };

    //Deplete additional weapon
    _stateName = (NWG_PSH_DPL_Settings get "ADD_WEAPON_STATE_NAME");
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _addWeapon = _state;
        private _defaultAddWeapon = NWG_PSH_DPL_Settings get "ADD_WEAPON_DEFAULT";
        if (_addWeapon isEqualTo _defaultAddWeapon) exitWith {};//No additional weapon recorded
        if ((random 1) > (NWG_PSH_DPL_Settings get "ADD_WEAPON_LOOSE_CHANCE")) exitWith {};//Lucky

        _playerState set [_stateName,_defaultAddWeapon];
        if (_notify && {!isNull _playerObj})
            then {(NWG_PSH_DPL_Settings get "ADD_WEAPON_DEPLETED_LOC_KEY") remoteExec ["NWG_fnc_systemChatMe",_playerObj]};
    } else {
        (format ["NWG_PSH_DPL_Deplete: Additional weapon state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };

    //Deplete loot
    _stateName = (NWG_PSH_DPL_Settings get "LOOT_STATE_NAME");
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _loot = _state;
        private _defaultLoot = NWG_PSH_DPL_Settings get "LOOT_DEFAULT";
        if (_loot isEqualTo _defaultLoot) exitWith {};//No loot recorded

        private _multiplier = NWG_PSH_DPL_Settings get "LOOT_DEPLETE_MULTIPLIER";
        _loot = [_loot,_multiplier,/*notify:*/false] call NWG_fnc_lsDepleteLoot;
        _playerState set [_stateName,_loot];
        if (_notify && {!isNull _playerObj}) then {
            private _message = [(NWG_PSH_DPL_Settings get "LOOT_DEPLETED_LOC_KEY"),((1 - _multiplier) * 100)];
            _message remoteExec ["NWG_fnc_systemChatMe",_playerObj];
        };
    } else {
        (format ["NWG_PSH_DPL_Deplete: Loot state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };
};

//================================================================================================================
call _Init;
