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

    ["MISSION_STATE_CHECK_ENABLED",true],//Check if mission state is one of 'combat' states to deplete
    ["BASE_PROXIMITY_CHECK_ENABLED",true],//Check if player was far from base to deplete
    ["DEBUG_LOG_CHECKS",true],//Log every check result

    ["PROGRESS_STATE_NAME","progress"],//Name of the progress state

    ["LOADOUT_STATE_NAME","loadout"],//Name of the loadout state
    ["LOADOUT_DEFAULT",[[],[],[],["U_OG_Guerilla1_1",[]],[],[],"","",[],["","","","","",""]]],//Default loadout
    ["LOADOUT_DEPLETED_LOC_KEY","#DPL_LOADOUT_DEPLETED#"],//Localization key for the loadout depleted message

    ["ADD_WEAPON_STATE_NAME","add_weapon"],//Name of the additional weapon state
    ["ADD_WEAPON_DEFAULT",[]],//Default additional weapon state
    ["ADD_WEAPON_DEPLETED_LOC_KEY","#DPL_ADD_WEAPON_DEPLETED#"],//Localization key for the additional weapon depleted message

    ["LOOT_STATE_NAME","loot_storage"],//Name of the loot state
    ["LOOT_DEFAULT",LOOT_ITEM_DEFAULT_CHART],//Default loot state
    ["LOOT_SELL_MULTIPLIER",0.1],//Multiplier for the depleted loot sell price
    ["LOOT_DEPLETED_LOC_KEY","#DPL_LOOT_DEPLETED#"],//Localization key for the loot depleted message

    ["WALLET_STATE_NAME","wallet"],//Name of the wallet state

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

    //Deplete check
    if !([_corpse,"Resp"] call NWG_PSH_DPL_ShouldDeplete) exitWith {
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

    //Deplete check
    if !([_corpse,"Disc"] call NWG_PSH_DPL_ShouldDeplete) exitWith {};//Player disconnected while on base, do not deplete

    //Deplete
    [_steamID,false,objNull] call NWG_PSH_DPL_Deplete;
};

//================================================================================================================
//Main check
NWG_PSH_DPL_ShouldDeplete = {
    params ["_unit","_event"];
    if (isNil "_unit" || {isNull _unit}) exitWith {
        "NWG_PSH_DPL_ShouldDeplete: Unit is nil/null. Fallback to false" call NWG_fnc_logError;
        false
    };

    private _baseCheck = call {
        if !(NWG_PSH_DPL_Settings get "BASE_PROXIMITY_CHECK_ENABLED") exitWith {[true,0]};
        if (isNil "NWG_MIS_SER_playerBase") exitWith {
            "NWG_PSH_DPL_ShouldDeplete: Player base is nil. Skipping base proximity check" call NWG_fnc_logError;
            [true,-1]
        };
        private _base = NWG_MIS_SER_playerBase;
        if !(_base isEqualType objNull) exitWith {
            "NWG_PSH_DPL_ShouldDeplete: Player base is not an object. Skipping base proximity check" call NWG_fnc_logError;
            [true,-1]
        };
        if (isNull _base) exitWith {
            "NWG_PSH_DPL_ShouldDeplete: Player base is null. Skipping base proximity check" call NWG_fnc_logError;
            [true,-1]
        };
        private _distance = round (_unit distance _base);
        [(_distance <= 100),_distance]
    };
    _baseCheck params ["_isOnBase","_distanceToBase"];

    private _missionStateCheck = call {
        if !(NWG_PSH_DPL_Settings get "MISSION_STATE_CHECK_ENABLED") exitWith {[true,-1]};
        if (isNil "NWG_MIS_CurrentState") exitWith {
            "NWG_PSH_DPL_ShouldDeplete: Mission state is nil. Skipping mission state check" call NWG_fnc_logError;
            [true,-1]
        };
        private _currentState = NWG_MIS_CurrentState;
        if !(_currentState isEqualType 0) exitWith {
            "NWG_PSH_DPL_ShouldDeplete: Mission state is not a number. Skipping mission state check" call NWG_fnc_logError;
            [true,-1]
        };

        if (_currentState == MSTATE_SERVER_RESTART) exitWith {[true,_currentState]};//Server restart is not a combat state
        [(_currentState <= MSTATE_VOTING),_currentState]
    };
    _missionStateCheck params ["_isSafeState","_currentState"];

    private _shouldDeplete = if (_isOnBase || _isSafeState) then {false} else {true};
    if (NWG_PSH_DPL_Settings get "DEBUG_LOG_CHECKS") then {
        (format ["NWG_PSH_DPL_ShouldDeplete: Unit: '%1'. On: '%2'. BaseCheck: [%3] (dist: '%4'). MissionStateCheck: [%5] (state: '%6'). Depleting: '%7'",
            (name _unit),
            _event,
            (if (_isOnBase) then {"+"} else {"-"}),
            _distanceToBase,
            (if (_isSafeState) then {"+"} else {"-"}),
            (_currentState call NWG_MIS_SER_GetStateName),
            _shouldDeplete
        ]) call NWG_fnc_logInfo;
    };

    //return
    _shouldDeplete
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
    private ["_stateName","_state"];

    //Get progress state (for depletion multipliers)
    _stateName = NWG_PSH_DPL_Settings get "PROGRESS_STATE_NAME";
    _state = _playerState get _stateName;
    if (isNil "_state") exitWith {
        (format ["NWG_PSH_DPL_Deplete: Progress state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };
    _state params ["","","_taxi","_trdr"];//params ["_exp","_texp","_taxi","_trdr","_comm"];
    if (isNil "_taxi") exitWith {
        (format ["NWG_PSH_DPL_Deplete: Progress state TAXI not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };
    if (isNil "_trdr") exitWith {
        (format ["NWG_PSH_DPL_Deplete: Progress state TRDR not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };


    //Deplete loadout
    _stateName = NWG_PSH_DPL_Settings get "LOADOUT_STATE_NAME";
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _loadout = _state + [];//Shallow copy
        private _defaultLoadout = NWG_PSH_DPL_Settings get "LOADOUT_DEFAULT";
        if (_loadout isEqualTo _defaultLoadout) exitWith {};//No loadout changes in compare to default

        private _insuranceCount = _taxi;
        if (_insuranceCount < 0 || {_insuranceCount > 10}) exitWith {
            (format ["NWG_PSH_DPL_Deplete: Invalid insurance count '%1' for player: '%2' with steamID: '%3'",_insuranceCount,(name _playerObj),_steamID]) call NWG_fnc_logError;
        };

        private _isDepleted = false;
        private _pokeAt = [0,1,2,3,4,5,6,7,8,9];//Indicies in loadout to poke
        _pokeAt = _pokeAt call NWG_fnc_arrayShuffle;
        _pokeAt resize (10 - _insuranceCount);
        private ["_cur","_def"];
        {
            _cur = _loadout select _x;
            _def = _defaultLoadout select _x;
            if (_cur isNotEqualTo _def) then {
                _loadout set [_x,_def];
                _isDepleted = true;
            };
        } forEach _pokeAt;
        if (!_isDepleted) exitWith {};//No depletion done

        _playerState set [_stateName,_loadout];
        if (_notify && {!isNull _playerObj}) then {
            private _percent = (10 - _insuranceCount) * 10;
            private _message = [(NWG_PSH_DPL_Settings get "LOADOUT_DEPLETED_LOC_KEY"),_percent];
            _message remoteExec ["NWG_fnc_systemChatMe",_playerObj];
        };
    } else {
        (format ["NWG_PSH_DPL_Deplete: Loadout state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };

    //Deplete additional weapon
    _stateName = NWG_PSH_DPL_Settings get "ADD_WEAPON_STATE_NAME";
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _addWeapon = _state;
        private _defaultAddWeapon = NWG_PSH_DPL_Settings get "ADD_WEAPON_DEFAULT";
        if (_addWeapon isEqualTo _defaultAddWeapon) exitWith {};//No additional on player

        private _insuranceChance = _taxi / 10;
        if (_insuranceChance < 0 || {_insuranceChance > 1}) exitWith {
            (format ["NWG_PSH_DPL_Deplete: Invalid insurance chance '%1' for player: '%2' with steamID: '%3'",_insuranceChance,(name _playerObj),_steamID]) call NWG_fnc_logError;
        };
        if ((random 1) <= _insuranceChance) exitWith {};//Lucky

        _playerState set [_stateName,_defaultAddWeapon];
        if (_notify && {!isNull _playerObj}) then {
            private _message = NWG_PSH_DPL_Settings get "ADD_WEAPON_DEPLETED_LOC_KEY";
            _message remoteExec ["NWG_fnc_systemChatMe",_playerObj];
        };
    } else {
        (format ["NWG_PSH_DPL_Deplete: Additional weapon state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };

    //Deplete loot
    _stateName = NWG_PSH_DPL_Settings get "LOOT_STATE_NAME";
    _state = _playerState get _stateName;
    if (!isNil "_state") then {
        private _loot = _state + [];//Shallow copy
        if (_loot isEqualTo (NWG_PSH_DPL_Settings get "LOOT_DEFAULT")) exitWith {};//No loot stored

        private _insuranceMultiplier = _trdr / 10;
        if (_insuranceMultiplier < 0 || {_insuranceMultiplier > 1}) exitWith {
            (format ["NWG_PSH_DPL_Deplete: Invalid insurance multiplier '%1' for player: '%2' with steamID: '%3'",_insuranceMultiplier,(name _playerObj),_steamID]) call NWG_fnc_logError;
        };

        private _toSellAll = [];
        private ["_items","_i","_toKeep","_toSell"];
        {
            _items = (_x call NWG_fnc_unCompactStringArray) call NWG_fnc_arrayShuffle;
            _i = floor ((count _items) * _insuranceMultiplier);
            _toKeep = _items select [0,_i];
            _toSell = _items select [_i];
            _loot set [_forEachIndex,(_toKeep call NWG_fnc_compactStringArray)];
            _toSellAll append _toSell;
        } forEach _loot;
        if (count _toSellAll == 0) exitWith {};//No loot to sell

        _playerState set [_stateName,_loot];
        if (_notify && {!isNull _playerObj}) then {
            private _percent = (10 - _trdr) * 10;
            private _message = [(NWG_PSH_DPL_Settings get "LOOT_DEPLETED_LOC_KEY"),_percent];
            _message remoteExec ["NWG_fnc_systemChatMe",_playerObj];
        };

        /*Sell depleted loot*/
        private _sellPrice = 0;
        {
            _sellPrice = _sellPrice + (_x call NWG_ISHOP_SER_EvaluateItem);//Inner method of 'shopItemsServerSide.sqf'
        } forEach _toSellAll;
        _sellPrice = round (_sellPrice * (NWG_PSH_DPL_Settings get "LOOT_SELL_MULTIPLIER"));
        if (_sellPrice <= 0) exitWith {};//No money earned

        _stateName = NWG_PSH_DPL_Settings get "WALLET_STATE_NAME";
        _state = _playerState get _stateName;
        if (isNil "_state") exitWith {
            (format ["NWG_PSH_DPL_Deplete: Wallet state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
        };
        _playerState set [_stateName,(_state + _sellPrice)];
        if (_notify && {!isNull _playerObj}) then {
            [_playerObj,_sellPrice] remoteExec ["NWG_WLT_NotifyMoneyChange",_playerObj];//Use inner method of 'walletClient.sqf' to notify player properly
        };
    } else {
        (format ["NWG_PSH_DPL_Deplete: Loot state not found for player: '%1' with steamID: '%2'",(name _playerObj),_steamID]) call NWG_fnc_logError;
    };
};

//================================================================================================================
call _Init;
