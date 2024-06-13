#include "..\..\globalDefines.h"
#include "medicineDefines.h"
//================================================================================================================
//================================================================================================================
//Settings
NWG_MED_CLI_Settings = createHashMapFromArray [
    ["ALLOWDAMAGE_ON_INIT",true],//Set this to true if you added 'player allowDamage false' in 'initPlayerLocal'

    ["INVULNERABILITY_ON_START",5],//Seconds to ignore damage after mission start
    ["INVULNERABILITY_ON_EJECTION",3],//Seconds to ignore damage while ejecting burning vehicle
    ["INVULNERABILITY_ON_WOUNDED",3],//Seconds to ignore damage when getting wounded
    ["INVULNERABILITY_ON_RESPAWN",5],//Seconds to ignore damage on respawn
    ["INVULNERABILITY_ON_REVIVE",2],//Seconds to ignore damage on revive

    ["TIME_BLEEDING_TIME",900],//Start bleeding with this amount of 'time left'
    ["TIME_DAMAGE_DEPLETES",6],//How much time is subtracted when damage received in wounded state

    ["SELF_HEAL_INITIAL_CHANCE",100],//Initial success chance of 'self-heal' action
    ["SELF_HEAL_CHANCE_DECREASE",10],//Amount by which success chance of 'self-heal' action decreased by every attempt
    ["SELF_HEAL_CHANCE_BOOST_ON_LAST_FAK",20],//Amount by which success chance of 'self-heal' action increased on last FAK
    ["SELF_HEAL_ACTION_PRIORITY",13],//Priority of 'self-heal' action
    ["SELF_HEAL_ACTION_DURATION",8],//Duration of 'self-heal' action

    ["RESPAWN_ACTION_PRIORITY",12],//Priority of 'respawn' action
    ["RESPAWN_ACTION_DURATION",5],//Duration of 'respawn' action

    ["HEAL_WITH_FAK_CHANCE",50],//Chance to heal another unit using only FAK
    ["HEAL_CHANCE_BOOST_ON_LAST_FAK",20],//Amount by which success chance of 'heal' action increased on last FAK
    ["HEAL_ACTION_PRIORITY",20],//Priority of 'heal' action
    ["HEAL_ACTION_DURATION",8],//Duration of 'heal' action
    ["HEAL_ACTION_AUTOSHOW",true],//If true - will automatically show on screen in suggestive manner

    ["DRAG_ACTION_PRIORITY",19],//Priority of 'drag' action

    ["CARRY_ACTION_PRIORITY",18],//Priority of 'carry' action
    ["CARRY_ACTION_DURATION",4],//Duration of 'carry' action

    ["RELEASE_ACTION_PRIORITY",17],//Priority of 'release' action
    ["VEH_LOADIN_ACTION_PRIORITY",21],//Priority of 'veh load' action

    ["VANILLA_HEAL_100HP",true],//If true - any vanilla heal action on player will remove all the damage

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Defines
#define FAKKIT "FirstAidKit"
#define MEDKIT "Medikit"

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_START");
    player addEventHandler ["HandleDamage",{_this call NWG_MED_CLI_OnDamage}];
    if (NWG_MED_CLI_Settings get "ALLOWDAMAGE_ON_INIT") then {player allowDamage true};

    NWG_MED_CLI_respawnPoint = getPosASL player;
    player addEventHandler ["Respawn",{_this call NWG_MED_CLI_OnRespawn}];

    [EVENT_ON_LOADOUT_CHANGED,{_this call NWG_MED_CLI_OnInventoryChanged}] call NWG_fnc_subscribeToClientEvent;

    player addEventHandler ["GetInMan",{_this call NWG_MED_CLI_OnVehGetIn}];
    player addEventHandler ["GetOutMan",{_this call NWG_MED_CLI_OnVehGetOut}];
    player addEventHandler ["HandleHeal",{_this call NWG_MED_CLI_OnVanillaHeal}];

    player call NWG_MED_CLI_InitPlayer;
};

NWG_MED_CLI_InitPlayer = {
    // private _player = _this;
    call NWG_MED_CLI_ReloadStates;//Reload states
    call NWG_MED_CLI_ReloadChances;//Reload chances
    call NWG_MED_CLI_SA_ReloadSelfHealChance;//Reload self-heal chance
    call NWG_MED_CLI_ReloadActions;//Reload actions
};

NWG_MED_CLI_ReloadStates = {
    [player,false] call NWG_MED_COM_MarkWounded;
    [player,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;
    [player,(NWG_MED_CLI_Settings get "TIME_BLEEDING_TIME")] call NWG_MED_COM_SetTime;
};

//================================================================================================================
//================================================================================================================
//Vanilla Heal handling
NWG_MED_CLI_OnVanillaHeal = {
    // params ["_player","_healer","_isMedic"];
    //1. Preferably, do not use 'exitWith' inside vanilla event handlers at all - Arma has a history of that breaking things
    //2. This entire event is broken and we use suggested workaround, see: https://community.bistudio.com/wiki/Arma_3:_Event_Handlers#HandleHeal
    if (NWG_MED_CLI_Settings get "VANILLA_HEAL_100HP") then {
        _this spawn {
            private _player = _this#0;
            private _healStartDmg = damage _player;
            private _timeout = time + 5;//NASA teached me this
            waitUntil {
                sleep 0.1;
                (((damage _player) != _healStartDmg) || {time > _timeout})
            };
            if (alive _player && {(damage _player) <= _healStartDmg})
                then {_player setDamage 0};
        };
    };
};

//================================================================================================================
//================================================================================================================
//Damage handling
NWG_MED_CLI_nextDamageAllowedAt = 0;
NWG_MED_CLI_OnDamage = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    private _dmg = _this#2;
    if (_dmg < 0.1) then {_dmg = 0};//Filter out small damage

    if (_dmg >= 0.9 && {(_this#1) isEqualTo ""}) then {
        private _unit = _this#0;
        switch (true) do {
            case (!alive _unit): {};
            case (!alive (vehicle _unit)): {_this call NWG_MED_CLI_OnVehicleDestroy};
            case (time < NWG_MED_CLI_nextDamageAllowedAt): {};
            case (_unit call NWG_MED_COM_IsWounded): {_this call NWG_MED_CLI_OnDamageWhileWounded};
            default {_this call NWG_MED_CLI_OnDamageWhileHealthy};
        };
    };

    (_dmg min 0.9)
};

NWG_MED_CLI_OnVehicleDestroy = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];

    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_EJECTION");
    moveOut _unit;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    [_damager,_unit,BLAME_VEH_KO] call NWG_fnc_medBlame;
};

NWG_MED_CLI_OnDamageWhileHealthy = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];

    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_WOUNDED");//Ignore damage for a while
    _unit setUnconscious true;
    _unit setCaptive true;
    [_unit,true] call NWG_MED_COM_MarkWounded;
    [_unit,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;//Will be updated in bleeding cycle

    //Fix for turrets and vehicles
    switch (true) do {
        case (isNull (vehicle _unit) || {(vehicle _unit) isEqualTo _unit}): {/*Do nothing*/};
        case ((vehicle _unit) isKindOf "StaticWeapon"): {moveOut _unit};//Fix stucking inside static weapon
        default {_unit playActionNow "Unconscious"};//Fix animation in vehicle
    };

    call NWG_MED_CLI_BLEEDING_StartBleeding;
    call NWG_MED_CLI_ReloadActions;//Reload actions

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    [_damager,_unit,BLAME_WOUND] call NWG_fnc_medBlame;
};

NWG_MED_CLI_OnDamageWhileWounded = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];
    NWG_MED_CLI_nextDamageAllowedAt = time + 1;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    if (isNull _damager) exitWith {};

    [_unit,false] call NWG_MED_COM_SetPatched;
    _damager call NWG_MED_CLI_BLEEDING_SetLastDamager;
};

NWG_MED_CLI_DefineDamager = {
    params [["_damager",objNull],["_instigator",objNull]];
    private _suspect = if (!isNull _instigator) then {_instigator} else {_damager};

    switch (true) do {
        case (isNull _suspect):                  {objNull};
        case (_suspect isKindOf "Man"):          {_suspect};
        case (unitIsUAV _suspect):               {((UAVControl _suspect) param [0,objNull])};
        case (_suspect isKindOf "StaticWeapon"): {(gunner _suspect)};
        case (!isNull (driver _suspect)):        {(driver _suspect)};
        default                                  {objNull};
    }
};

//================================================================================================================
//================================================================================================================
//Bleeding cycle
NWG_MED_CLI_BLEEDING_isBleeding = false;
NWG_MED_CLI_BLEEDING_lastDamager = objNull;
NWG_MED_CLI_BLEEDING_cycleHandle = scriptNull;

NWG_MED_CLI_BLEEDING_SetLastDamager = {NWG_MED_CLI_BLEEDING_lastDamager = _this};//Crude Property

NWG_MED_CLI_BLEEDING_StartBleeding = {
    if (NWG_MED_CLI_BLEEDING_isBleeding) exitWith {};//Prevent double start
    NWG_MED_CLI_BLEEDING_lastDamager = objNull;
    [player,(NWG_MED_CLI_Settings get "TIME_BLEEDING_TIME")] call NWG_MED_COM_SetTime;
    [player,false] call NWG_MED_COM_SetPatched;
    call NWG_MED_CLI_BLEEDING_PostProcessEnable;
    NWG_MED_CLI_BLEEDING_cycleHandle = [] spawn NWG_MED_CLI_BLEEDING_Cycle;
    NWG_MED_CLI_BLEEDING_isBleeding = true;
};

NWG_MED_CLI_BLEEDING_StopBleeding = {
    if (!NWG_MED_CLI_BLEEDING_isBleeding) exitWith {};//Prevent double stop
    terminate NWG_MED_CLI_BLEEDING_cycleHandle;
    call NWG_MED_CLI_BLEEDING_PostProcessDisable;
    hintSilent "";//Clear hint
    NWG_MED_CLI_BLEEDING_lastDamager = objNull;
    NWG_MED_CLI_BLEEDING_isBleeding = false;
};

NWG_MED_CLI_BLEEDING_Cycle = {
    private _nextUpdateAt = 0;
    waitUntil {
        //Small cycle
        if (isNull player || {!alive player}) exitWith {
            /*Disconnected*/
            true
        };
        if !(player call NWG_MED_COM_IsWounded) exitWith {
            /*Healed*/
            [] spawn NWG_MED_CLI_OnRevive;//'spawn' to 'terminate' bleeding not from within itself
            true
        };

        //Big cycle time?
        if (time < _nextUpdateAt) exitWith {sleep 0.1; false};//Go to new small cycle
        _nextUpdateAt = time + 1;

        //Check and update substate
        private _substate = player call NWG_MED_COM_CalculateSubstate;
        if (_substate isEqualTo SUBSTATE_INVH && {!alive (vehicle player)}) then {
            //Fix (im)possible stucking inside burning vehicle
            player moveOut (vehicle player);
            _substate = SUBSTATE_NONE;
        };
        if ((player call NWG_MED_COM_GetSubstate) isNotEqualTo _substate) then {
            [player,_substate] call NWG_MED_COM_SetSubstate;
        };

        //Get time left
        private _timeLeft = player call NWG_MED_COM_GetTime;

        //Deplete by damage
        private _damager = NWG_MED_CLI_BLEEDING_lastDamager;
        private _depleteByDamage = if (!isNull _damager) then {
            NWG_MED_CLI_BLEEDING_lastDamager = objNull;//Reset last damager
            (NWG_MED_CLI_Settings get "TIME_DAMAGE_DEPLETES")
        } else {0};
        _timeLeft = _timeLeft - _depleteByDamage;

        //Deplete by bleeding
        private _depleteByTime = 1;
        if !(player call NWG_MED_COM_IsPatched) then {_depleteByTime = 2};//Increase if unit not patched
        if !(_substate in [SUBSTATE_INVH,SUBSTATE_DOWN]) then {_depleteByTime = _depleteByTime * 2};//Increase if unit is not still
        _timeLeft = _timeLeft - _depleteByTime;

        //Check if we're still alive
        if (_timeLeft <= 0) exitWith {
            /*Time ran out*/
            if (!isNull _damager) then {[_damager,player,BLAME_KILL] call NWG_fnc_medBlame};//Blame the last damager
            call NWG_MED_CLI_Respawn;
            true;//Exit cycle
        };
        [player,_timeLeft] call NWG_MED_COM_SetTime;

        //Calculate closest player
        private _allValidPlayers = (call NWG_fnc_getPlayersAll) select {
            alive _x && {
            _x isNotEqualTo player && {
            !(_x call NWG_MED_COM_IsWounded) && {
            (side (group _x)) isEqualTo (side (group player))}}}
        };
        private _closestPlayer = if ((count _allValidPlayers) > 0) then {
            _allValidPlayers = _allValidPlayers apply {[(_x distance player),_x]};
            _allValidPlayers sort true;
            (_allValidPlayers#0)#1
        } else {objNull};

        //Output info to the UI
        private _title = switch (_depleteByTime) do {
            case 1: {"#MED_CLI_BLEEDING_UI_TITLE_LOW#"  call NWG_fnc_localize};
            case 2: {"#MED_CLI_BLEEDING_UI_TITLE_MID#"  call NWG_fnc_localize};
            case 4: {"#MED_CLI_BLEEDING_UI_TITLE_HIGH#" call NWG_fnc_localize};
            default {""};//Shouldn't happen
        };
        private _timeInfo = format [
            ("#MED_CLI_BLEEDING_UI_TIMELEFT#" call NWG_fnc_localize),
            _timeLeft,
            (_depleteByDamage + _depleteByTime)
        ];
        private _closeInfo = if (!isNull _closestPlayer)
            then {format [("#MED_CLI_BLEEDING_UI_CLOSEST_PLAYER#" call NWG_fnc_localize),(name _closestPlayer),(_closestPlayer distance player)]}
            else {"#MED_CLI_BLEEDING_UI_NO_CLOSEST#" call NWG_fnc_localize};
        hintSilent ([_title,_timeInfo,_closeInfo] joinString "\n");

        //Repeat
        sleep 0.1;//Big cycle will still run every second, but smaller cycle will fire every 0.1 seconds
        false
    };
};

/*Post-process bleeding visuals*/
NWG_MED_CLI_BLEEDING_postProcessHandles = [];
NWG_MED_CLI_BLEEDING_PostProcessEnable = {
    private _ppHandles = [];
    private _create = {
        params ["_name","_priority"];
        private _handle = -1;
        while {_handle = ppEffectCreate [_name,_priority]; _handle < 0} do {_priority = _priority + 1};
        _handle
    };

    _ppHandles pushBack (["ColorCorrections",1500] call _create);
    _ppHandles pushBack (["ColorCorrections",1501] call _create);
    _ppHandles pushBack (["DynamicBlur",401] call _create);

    (_ppHandles#0) ppEffectAdjust [1,1,0.15,[0.3,0.3,0.3,0],[0.3,0.3,0.3,0.3],[1,1,1,1]];
	(_ppHandles#1) ppEffectAdjust [1,1,0,[0.15,0,0,1],[1.0,0.5,0.5,1],[0.587,0.199,0.114,0],[1,1,0,0,0,0.2,1]];
	(_ppHandles#2) ppEffectAdjust [0];
    _ppHandles ppEffectCommit 0;
    _ppHandles ppEffectEnable true;
	{_x ppEffectForceInNVG true} forEach _ppHandles;

    NWG_MED_CLI_BLEEDING_postProcessHandles = _ppHandles;
};

NWG_MED_CLI_BLEEDING_PostProcessDisable = {
    private _ppHandles = NWG_MED_CLI_BLEEDING_postProcessHandles;
    NWG_MED_CLI_BLEEDING_postProcessHandles = [];

    //Graceful disable. Step 1: Fade out
    (_ppHandles#0) ppEffectAdjust [1,1,0,[1,1,1,0],[0,0,0,1],[0,0,0,0]];
	(_ppHandles#1) ppEffectAdjust [1,1,0,[1,1,1,0],[0,0,0,1],[0,0,0,0]];
	(_ppHandles#2) ppEffectAdjust [0];
    _ppHandles ppEffectCommit 1;

    //Graceful disable. Step 2: Disable
    _ppHandles spawn {
        sleep 1.25;
        _this ppEffectEnable false;
        ppEffectDestroy _this;
    };
};

//================================================================================================================
//================================================================================================================
//Revive
NWG_MED_CLI_OnRevive = {
    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_REVIVE");//Ignore damage for a while
    call NWG_MED_CLI_BLEEDING_StopBleeding;//Stop bleeding if it's still active
    player setCaptive false;//Reset captive state
    player setUnconscious false;//Reset unconscious state
    call NWG_MED_CLI_ReloadStates;//Reload states
    if ((vehicle player) isEqualTo player) then {[player,"amovppnemstpsraswrfldnon"] call NWG_fnc_playAnim};//Reset anim
    call NWG_MED_CLI_ReloadActions;//Reload actions
};

//================================================================================================================
//================================================================================================================
//Respawn
NWG_MED_CLI_Respawn = {
    player setDamage 1;
};

/*This will be called on every respawn, including 'NWG_MED_CLI_Respawn', bugs, instakills, drowning, etc.*/
NWG_MED_CLI_respawnPoint = [];
NWG_MED_CLI_OnRespawn = {
    // params ["_player","_corpse"];
    params ["_player"];

    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_RESPAWN");//Ignore damage for a while
    _player setPosASL NWG_MED_CLI_respawnPoint;//Teleport to the respawn point
    call NWG_MED_CLI_BLEEDING_StopBleeding;//Stop bleeding if it's still active
    _player setCaptive false;//Reset captive state
    _player setUnconscious false;//Reset unconscious state
    _player call NWG_MED_CLI_InitPlayer;//Re-init player
};

//================================================================================================================
//================================================================================================================
//Action utils
/*Chances logic*/
NWG_MED_CLI_chanceSequence = [0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100];
NWG_MED_CLI_ReloadChances = {NWG_MED_CLI_chanceSequence = NWG_MED_CLI_chanceSequence call NWG_fnc_arrayShuffle};
NWG_MED_CLI_GetChance = {
    private _c = NWG_MED_CLI_chanceSequence deleteAt 0;
    NWG_MED_CLI_chanceSequence pushBack _c;
    _c
};

/*Med items logic*/
NWG_MED_CLI_hasFAKkit = false;
NWG_MED_CLI_hasMedkit = false;
NWG_MED_CLI_OnInventoryChanged = {
    // params ["_loadOut","_flattenLoadOut"];
    params ["","_flattenLoadOut"];
    NWG_MED_CLI_hasFAKkit = FAKKIT in _flattenLoadOut;
    NWG_MED_CLI_hasMedkit = MEDKIT in _flattenLoadOut;
    [player,NWG_MED_CLI_hasMedkit] call NWG_MED_COM_MarkMedic;//Update medic status
};

/*Add actions utils*/
NWG_MED_CLI_AddSimpleAction = {
    params ["_title","_priority","_condition","_action"];
    player addAction [
        (_title call NWG_fnc_localize),// title
        _action,    // Action script
        nil,        // Arguments
        _priority,  // Priority
        false,      // ShowWindow
        true,       // HideOnUse
        "",         // Shortcut
        _condition, // Condition
        -1          // Radius
    ]
};

NWG_MED_CLI_AddHoldAction = {
    params ["_title","_icon","_priority","_duration","_condition","_onStarted","_onInterrupted","_onCompleted",["_showWhileWounded",false],["_autoShow",false]];
    [
        player,                         // Object the action is attached to
        (_title call NWG_fnc_localize), // Title of the action
        _icon,                          // Idle icon shown on screen
        _icon,                          // Progress icon shown on screen
        _condition,                     // Condition for the action to be shown
        _condition,                     // Condition for the action to progress
        _onStarted,                     // Code executed when action starts
        {},                             // Code executed on every progress tick
        _onCompleted,                   // Code executed on completion
        _onInterrupted,                 // Code executed on interrupted
        [],                             // Arguments passed to the scripts as _this select 3
        _duration,                      // Action duration in seconds
        _priority,                      // Priority
        false,                          // Remove on completion
        _showWhileWounded,              // Show in unconscious state
        _autoShow                       // Auto show on screen
    ] call BIS_fnc_holdActionAdd
};

/*Reload actions*/
NWG_MED_CLI_ReloadActions = {
    //Drop previous locks
    NWG_MED_CLI_UA_healTarget = objNull;
    NWG_MED_CLI_UA_draggedUnit = objNull;
    NWG_MED_CLI_UA_carriedUnit = objNull;

    //Remove previous actions
    //We store actions on the player to gracefully handle start of the game and respawn (where old actions die along with the player instance)
    private _prevActions = player getVariable ["NWG_MED_CLI_actions",[]];
    {player removeAction _x} forEach _prevActions;//Remove all previous actions

    //Add new actions
    private _newActions = switch (true) do {
        case (player call NWG_MED_COM_IsWounded): {call NWG_MED_CLI_SA_AddSelfActions};//Add self actions if wounded
        case ((vehicle player) isEqualTo player): {call NWG_MED_CLI_UA_AddUnitsActions};//Add units actions if on foot
        default {[]}//Do nothing if healthy and in vehicle (save some fps)
    };
    player setVariable ["NWG_MED_CLI_actions",_newActions];
};

NWG_MED_CLI_OnVehGetIn = {
    // params ["_unit","_role","_vehicle","_turret"];
    _this call NWG_MED_CLI_UA_OnVehGetIn;//First, call unit action 'Veh load in', otherwise we loose it cause locks are dropped
    call NWG_MED_CLI_ReloadActions;
};

NWG_MED_CLI_OnVehGetOut = {
    // params ["_unit","_role","_vehicle","_turret","_isEject"];
    call NWG_MED_CLI_ReloadActions;
};

//================================================================================================================
//================================================================================================================
//Self actions
NWG_MED_CLI_SA_AddSelfActions = {
    private _actions = [];

    /*Self heal*/
    _actions pushBack ([
        "#MED_ACTION_SELF_HEAL_TITLE#",/*_title*/
        "a3\ui_f\data\igui\cfg\holdactions\holdaction_revive_ca.paa",/*_icon*/
        (NWG_MED_CLI_Settings get "SELF_HEAL_ACTION_PRIORITY"),/*_priority*/
        (NWG_MED_CLI_Settings get "SELF_HEAL_ACTION_DURATION"),/*_duration*/
        "(call NWG_MED_CLI_SA_SelfHealCondition)",/*_condition*/
        {call NWG_MED_CLI_SA_OnSelfHealStarted},/*_onStarted*/
        {call NWG_MED_CLI_SA_OnSelfHealInterrupted},/*_onInterrupted*/
        {call NWG_MED_CLI_SA_OnSelfHealCompleted},/*_onCompleted*/
        true/*_showWhileWounded*/
    ] call NWG_MED_CLI_AddHoldAction);

    /*Respawn*/
    _actions pushBack ([
        "#MED_ACTION_RESPAWN_TITLE#",/*_title*/
        "a3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa",/*_icon*/
        (NWG_MED_CLI_Settings get "RESPAWN_ACTION_PRIORITY"),/*_priority*/
        (NWG_MED_CLI_Settings get "RESPAWN_ACTION_DURATION"),/*_duration*/
        "(call NWG_MED_CLI_SA_RespawnCondition)",/*_condition*/
        {},/*_onStarted*/
        {},/*_onInterrupted*/
        {call NWG_MED_CLI_SA_OnRespawnCompleted},/*_onCompleted*/
        true/*_showWhileWounded*/
    ] call NWG_MED_CLI_AddHoldAction);

    /*Crawl*/
    if (!NWG_MED_CLI_SA_CrawlAdded) then {
        [] spawn NWG_MED_CLI_SA_AddCrawl;
        NWG_MED_CLI_SA_CrawlAdded = true;
    };

    _actions
};

/*Self heal*/
NWG_MED_CLI_SA_selfHealSuccessChance = 100;
NWG_MED_CLI_SA_ReloadSelfHealChance = {NWG_MED_CLI_SA_selfHealSuccessChance = NWG_MED_CLI_Settings get "SELF_HEAL_INITIAL_CHANCE"};

NWG_MED_CLI_SA_SelfHealCondition = {
    player call NWG_MED_COM_IsWounded && {
    NWG_MED_CLI_hasFAKkit && {
    (player call NWG_MED_COM_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_INVH,SUBSTATE_HEAL]}}/*SUBSTATE_HEAL because otherwise action disappears when started*/
};
NWG_MED_CLI_SA_OnSelfHealStarted = {
    [player,SUBSTATE_HEAL] call NWG_MED_COM_SetSubstate;//Set substate to HEAL

    //Show message
    private _fakCount = FAKKIT call NWG_fnc_invGetItemCount;
    private _myChance = (str NWG_MED_CLI_SA_selfHealSuccessChance)+"%";//Fix template unable to have '%' symbol
    ["#MED_ACTION_SELF_HEAL_HINT#",_fakCount,_myChance] call NWG_fnc_systemChatMe;

    //Play anim
    if ((vehicle player) isEqualTo player) then {
        [player,"ainvppnemstpslaywnondnon_medic"] call NWG_fnc_playAnim;
        player playMove "UnconsciousFaceDown";
    };
};
NWG_MED_CLI_SA_OnSelfHealInterrupted = {
    [player,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;//Reset substate
};
NWG_MED_CLI_SA_OnSelfHealCompleted = {
    [player,SUBSTATE_NONE] call NWG_MED_COM_SetSubstate;//Reset substate

    //Consume First Aid Kit
    if ((FAKKIT call NWG_fnc_invRemoveItem) isEqualTo false) exitWith {
        "NWG_MED_CLI_SA_OnSelfHealCompleted: Failed to consume FAK" call NWG_fnc_logError;
        [player,player,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
    };
    NWG_MED_CLI_hasFAKkit = FAKKIT call NWG_fnc_invHasItem;//Update FAK presence (it SHOULD update on consume, but let's double-check)

    //Get success chance for self-revive
    private _myChance = NWG_MED_CLI_SA_selfHealSuccessChance;//Get chance
    if (_myChance > 0 && {!NWG_MED_CLI_hasFAKkit}) then {
        _myChance = _myChance + (NWG_MED_CLI_Settings get "SELF_HEAL_CHANCE_BOOST_ON_LAST_FAK");//Boost chance if it was the last FAK
        //No, we do not show this to player - it's a hidden bonus that they should not know about
    };

    //Try to revive self
    if (_myChance > 0 && {(call NWG_MED_CLI_GetChance) <= _myChance}) then {
        /*Success*/
        [player,player,ACTION_HEAL_PARTIAL] call NWG_fnc_medReportMedAction;
        private _nextChance = _myChance - (NWG_MED_CLI_Settings get "SELF_HEAL_CHANCE_DECREASE");//Decrease success chance for the next attempt
        NWG_MED_CLI_SA_selfHealSuccessChance = _nextChance max 0;
    } else {
        /*Failure*/
        if !(player call NWG_MED_COM_IsPatched) then {[player,player,ACTION_PATCH] call NWG_fnc_medReportMedAction};//At least patch the player
        [player,player,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
    };
};

/*Respawn*/
NWG_MED_CLI_SA_RespawnCondition = {
    player call NWG_MED_COM_IsWounded && {
    (player call NWG_MED_COM_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_INVH]}
};
NWG_MED_CLI_SA_OnRespawnCompleted = {
    call NWG_MED_CLI_Respawn;
};

/*Crawl*/
NWG_MED_CLI_SA_CrawlAdded = false;//This must be done one time only
NWG_MED_CLI_SA_AddCrawl = {
    private _gameDisplay = objNull;
    waitUntil {_gameDisplay = findDisplay 46; !isNull _gameDisplay};

    _gameDisplay displayAddEventHandler ["KeyDown",{
        // params ["_eventName","_keyCode","_shift","_ctrl","_alt"];
        params ["","_keyCode"];
        if (
            _keyCode in (actionKeys "MoveForward") && {
            player call NWG_MED_COM_IsWounded && {
            (player call NWG_MED_COM_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_CRWL] && {
            (vehicle player) isEqualTo player}}}
        ) then {
            [player,SUBSTATE_CRWL] call NWG_MED_COM_SetSubstate;
            player playMoveNow "AmovPpneMrunSnonWnonDf";
            player setCaptive false;
        };

        false/*Never intercept*/
    }];

    _gameDisplay displayAddEventHandler ["KeyUp", {
        // params ["_eventName","_keyCode","_shift","_ctrl","_alt"];
        params ["","_keyCode"];
        if (
            _keyCode in (actionKeys "MoveForward") && {
            player call NWG_MED_COM_IsWounded && {
            (player call NWG_MED_COM_GetSubstate) isEqualTo SUBSTATE_CRWL && {
            (vehicle player) isEqualTo player}}}
        ) then {
            [player,SUBSTATE_DOWN] call NWG_MED_COM_SetSubstate;
            player playActionNow "Unconscious";
            player setCaptive true;
        };

        false/*Never intercept*/
    }];
};

//================================================================================================================
//================================================================================================================
//Units actions
NWG_MED_CLI_UA_AddUnitsActions = {
    private _actions = [];

    /*Heal*/
    _actions pushBack ([
        "#MED_ACTION_HEAL_TITLE#",/*_title*/
        "a3\ui_f\data\igui\cfg\holdactions\holdaction_revivemedic_ca.paa",/*_icon*/
        (NWG_MED_CLI_Settings get "HEAL_ACTION_PRIORITY"),/*_priority*/
        (NWG_MED_CLI_Settings get "HEAL_ACTION_DURATION"),/*_duration*/
        "(call NWG_MED_CLI_UA_HealCondition)",/*_condition*/
        {call NWG_MED_CLI_UA_OnHealStarted},/*_onStarted*/
        {call NWG_MED_CLI_UA_OnHealInterrupted},/*_onInterrupted*/
        {call NWG_MED_CLI_UA_OnHealCompleted},/*_onCompleted*/
        false,/*_showWhileWounded*/
        (NWG_MED_CLI_Settings get "HEAL_ACTION_AUTOSHOW")/*_autoShow*/
    ] call NWG_MED_CLI_AddHoldAction);

    /*Drag*/
    _actions pushBack ([
        "#MED_ACTION_DRAG_TITLE#",/*_title*/
        (NWG_MED_CLI_Settings get "DRAG_ACTION_PRIORITY"),/*_priority*/
        "(call NWG_MED_CLI_UA_DragCondition)",/*_condition*/
        {call NWG_MED_CLI_UA_DragAction}/*_action*/
    ] call NWG_MED_CLI_AddSimpleAction);

    /*Carry*/
    _actions pushBack ([
        "#MED_ACTION_CARRY_TITLE#",/*_title*/
        (NWG_MED_CLI_Settings get "CARRY_ACTION_PRIORITY"),/*_priority*/
        "(call NWG_MED_CLI_UA_CarryCondition)",/*_condition*/
        {call NWG_MED_CLI_UA_CarryAction}/*_action*/
    ] call NWG_MED_CLI_AddSimpleAction);

    /*Anim abuse check*/
    if (!NWG_MED_CLI_UA_animChangeAssigned) then {
        player addEventHandler ["AnimChanged",{_this call NWG_MED_CLI_UA_OnAnimChange}];//Tested: Persistent after respawn
        NWG_MED_CLI_UA_animChangeAssigned = true;
    };

    /*Release*/
    _actions pushBack ([
        "#MED_ACTION_RELEASE_TITLE#",/*_title*/
        (NWG_MED_CLI_Settings get "RELEASE_ACTION_PRIORITY"),/*_priority*/
        "(call NWG_MED_CLI_UA_ReleaseCondition)",/*_condition*/
        {call NWG_MED_CLI_UA_ReleaseAction}/*_action*/
    ] call NWG_MED_CLI_AddSimpleAction);

    /*Vehicle load*/
    _actions pushBack ([
        "#MED_ACTION_VEH_LOADIN_TITLE#",/*_title*/
        (NWG_MED_CLI_Settings get "VEH_LOADIN_ACTION_PRIORITY"),/*_priority*/
        "(call NWG_MED_CLI_UA_VehLoadCondition)",/*_condition*/
        {call NWG_MED_CLI_UA_VehLoadAction}/*_action*/
    ] call NWG_MED_CLI_AddSimpleAction);

    /*Vehicle load on vehicle get in*/
    //Moved to: 'NWG_MED_CLI_OnVehGetIn'

    _actions
};

/*Heal*/
NWG_MED_CLI_UA_healTarget = objNull;//Unit that we started healing on
NWG_MED_CLI_UA_HealCondition = {
    /*NWG_fnc_radarGetUnitInFront also checks if player is alive and on foot, so we can omit it here*/
    !isNull (call NWG_fnc_radarGetUnitInFront) && {
    isNull NWG_MED_CLI_UA_draggedUnit && {
    isNull NWG_MED_CLI_UA_carriedUnit && {
    !(player call NWG_MED_COM_IsWounded) && {
    (NWG_MED_CLI_hasFAKkit || NWG_MED_CLI_hasMedkit) && {
    (call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_IsWounded && {
    ((call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_GetSubstate) isEqualTo SUBSTATE_DOWN}}}}}}
};
NWG_MED_CLI_UA_OnHealStarted = {
    NWG_MED_CLI_UA_healTarget = call NWG_fnc_radarGetUnitInFront;//Lock unit

    //Show different message based on 'medic' status
    //FAK and Medkit presence for medic, FAK count and chance for non-medic
    if (player call NWG_MED_COM_IsMedic) then {
        private _hasMedkit = if (NWG_MED_CLI_hasMedkit) then {"#MED_HAS_MEDKIT#"} else {"#MED_NO_MEDKIT#"};
        private _fakCount = FAKKIT call NWG_fnc_invGetItemCount;
        ["#MED_ACTION_HEAL_MED_HINT#",_hasMedkit,_fakCount] call NWG_fnc_systemChatMe;
    } else {
        private _fakCount = FAKKIT call NWG_fnc_invGetItemCount;
        private _myChance = (str (NWG_MED_CLI_Settings get "HEAL_WITH_FAK_CHANCE"))+"%";//Fix template unable to have '%' symbol
        ["#MED_ACTION_HEAL_FAK_HINT#",_fakCount,_myChance] call NWG_fnc_systemChatMe;
    };

    //Play anim
    player playActionNow "MedicOther";
};
NWG_MED_CLI_UA_OnHealInterrupted = {
    NWG_MED_CLI_UA_healTarget = objNull;//Drop lock
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if (player call NWG_MED_COM_IsWounded) exitWith {};//Game logic will handle this
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
};
NWG_MED_CLI_UA_OnHealCompleted = {
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
    private _healTarget = NWG_MED_CLI_UA_healTarget;
    NWG_MED_CLI_UA_healTarget = objNull;//Drop lock
    if (
        isNull _healTarget || {
        _healTarget isNotEqualTo (call NWG_fnc_radarGetUnitInFront) || {
        !(_healTarget call NWG_MED_COM_IsWounded)}}
    ) exitWith {};//Abort on target loss

    if (player call NWG_MED_COM_IsMedic)
        then {_healTarget call NWG_MED_CLI_UA_OnHealCompleted_MED}
        else {_healTarget call NWG_MED_CLI_UA_OnHealCompleted_FAK};
};
NWG_MED_CLI_UA_OnHealCompleted_MED = {
    private _healTarget = _this;

    switch (true) do {
        /*Full heal by consuming FAK*/
        case (NWG_MED_CLI_hasFAKkit && NWG_MED_CLI_hasMedkit): {
            if ((FAKKIT call NWG_fnc_invRemoveItem) isEqualTo false) exitWith {
                "NWG_MED_CLI_UA_OnHealCompleted_MED: Failed to consume FAK" call NWG_fnc_logError;
                [player,_healTarget,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
            };
            NWG_MED_CLI_hasFAKkit = FAKKIT call NWG_fnc_invHasItem;//Update FAK presence
            [player,_healTarget,ACTION_HEAL_SUCCESS] call NWG_fnc_medReportMedAction;
        };
        /*Partial heal if no FAK - additional healing by medkit will be required*/
        case (NWG_MED_CLI_hasMedkit): {
            [player,_healTarget,ACTION_HEAL_PARTIAL] call NWG_fnc_medReportMedAction;
        };
        /*Error case where we somehow landed here while not having a medkit*/
        case (NWG_MED_CLI_hasFAKkit): {
            "NWG_MED_CLI_UA_OnHealCompleted_MED: Unexpected no medkit case. Fallback to heal by FAK" call NWG_fnc_logError;
            _healTarget call NWG_MED_CLI_UA_OnHealCompleted_FAK;
        };
        /*Error. A bad one*/
        default {
            "NWG_MED_CLI_UA_OnHealCompleted_MED: Unexpected no medkit and no FAK case" call NWG_fnc_logError;
            [player,_healTarget,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
        };
    };
};
NWG_MED_CLI_UA_OnHealCompleted_FAK = {
    private _healTarget = _this;

    //Consume First Aid Kit
    if ((FAKKIT call NWG_fnc_invRemoveItem) isEqualTo false) exitWith {
        "NWG_MED_CLI_UA_OnHealCompleted_FAK: Failed to consume FAK" call NWG_fnc_logError;
        [player,_healTarget,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
    };
    NWG_MED_CLI_hasFAKkit = FAKKIT call NWG_fnc_invHasItem;//Update FAK presence

    //Get success chance
    private _myChance = NWG_MED_CLI_Settings get "HEAL_WITH_FAK_CHANCE";//Get chance
    if (!NWG_MED_CLI_hasFAKkit) then {
        _myChance = _myChance + (NWG_MED_CLI_Settings get "HEAL_CHANCE_BOOST_ON_LAST_FAK");//Boost chance if it was the last FAK
        //No, we do not show this to player - it's a hidden bonus that they should not know about
    };

    //Try to revive
    if (_myChance > 0 && {(call NWG_MED_CLI_GetChance) <= _myChance}) then {
        /*Success*/
        [player,_healTarget,ACTION_HEAL_PARTIAL] call NWG_fnc_medReportMedAction;
    } else {
        /*Failure*/
        if !(_healTarget call NWG_MED_COM_IsPatched) then {[player,_healTarget,ACTION_PATCH] call NWG_fnc_medReportMedAction};//At least patch the target
        [player,_healTarget,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
    };
};
NWG_MED_CLI_UA_ResetAnimation = {
    if (isNull player || {!alive player}) exitWith {};//Prevent errors
    if ((vehicle player) isNotEqualTo player) exitWith {};//Don't do animation reset in vehicles

    private _anim = switch (animationState player) do {
        case "ainvppnemstpslaywrfldnon_medicother";
        case "ainvppnemstpslaywrfldnon_medicdummyend": {"AmovPpneMstpSrasWrflDnon"};
        default {"amovPknlMstpSrasWrflDnon"};
    };
    [player,_anim] call NWG_fnc_playAnim;
};

/*Drag*/
NWG_MED_CLI_UA_draggedUnit = objNull;//Unit that we are dragging
NWG_MED_CLI_UA_DragCondition = {
    /*NWG_fnc_radarGetUnitInFront also checks if player is alive and on foot, so we can omit it here*/
    !isNull (call NWG_fnc_radarGetUnitInFront) && {
    isNull NWG_MED_CLI_UA_draggedUnit && {
    isNull NWG_MED_CLI_UA_carriedUnit && {
    !(player call NWG_MED_COM_IsWounded) && {
    (call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_IsWounded && {
    ((call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_GetSubstate) isEqualTo SUBSTATE_DOWN}}}}}
};
NWG_MED_CLI_UA_DragAction = {
    private _targetUnit = (call NWG_fnc_radarGetUnitInFront);//Omit all checks - rely on condition
    NWG_MED_CLI_UA_draggedUnit = _targetUnit;//Lock unit
    [player,_targetUnit,ACTION_DRAG] call NWG_fnc_medReportMedAction;
    player playActionNow "grabDrag";
};

/*Carry*/
NWG_MED_CLI_UA_carriedUnit = objNull;//Unit that we are carrying
NWG_MED_CLI_UA_CarryCondition = {
    /*We either carry dragged unit, or unit on the ground*/
    if (!isNull NWG_MED_CLI_UA_draggedUnit) then {
        isNull NWG_MED_CLI_UA_carriedUnit && {
        alive NWG_MED_CLI_UA_draggedUnit && {
        !(player call NWG_MED_COM_IsWounded)}}
    } else {
        !isNull (call NWG_fnc_radarGetUnitInFront) && {
        isNull NWG_MED_CLI_UA_draggedUnit && {
        isNull NWG_MED_CLI_UA_carriedUnit && {
        !(player call NWG_MED_COM_IsWounded) && {
        (call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_IsWounded && {
        ((call NWG_fnc_radarGetUnitInFront) call NWG_MED_COM_GetSubstate) isEqualTo SUBSTATE_DOWN}}}}}
    };
};
NWG_MED_CLI_UA_CarryAction = {
    private ["_targetUnit","_isDragToCarry"];
    if (!isNull NWG_MED_CLI_UA_draggedUnit) then {
        _targetUnit = NWG_MED_CLI_UA_draggedUnit;
        _isDragToCarry = true;
    } else {
        _targetUnit = (call NWG_fnc_radarGetUnitInFront);//Omit all checks - rely on condition
        _isDragToCarry = false;
    };

    [_targetUnit,_isDragToCarry] spawn {
        params ["_targetUnit","_isDragToCarry"];
        NWG_MED_CLI_UA_carriedUnit = _targetUnit;//Lock unit in advance (anim is long and we don't want to be interrupted)
        private _abortCondition = {
            isNull player || {
            !alive player || {
            isNull _targetUnit || {
            !alive _targetUnit || {
            isNull NWG_MED_CLI_UA_carriedUnit || { /*Lock was dropped by release*/
            _targetUnit isNotEqualTo NWG_MED_CLI_UA_carriedUnit || { /*Should not happen, but just in case*/
            player call NWG_MED_COM_IsWounded || {
            !(_targetUnit call NWG_MED_COM_IsWounded) || {
            (_targetUnit call NWG_MED_COM_GetSubstate) isNotEqualTo SUBSTATE_DOWN}}}}}}}}
        };
        private _abort = {
            if (isNull player || {!alive player}) exitWith {};//Prevent errors
            if (player call NWG_MED_COM_IsWounded) exitWith {};//Game logic will handle this
            if (isNull NWG_MED_CLI_UA_carriedUnit) exitWith {};//Released during animation
            NWG_MED_CLI_UA_carriedUnit = objNull;//Drop the lock on abort
            call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
        };

        if (_isDragToCarry) then {
            /*Drop the body first*/
            call NWG_MED_CLI_UA_ReleaseAction;
            NWG_MED_CLI_UA_carriedUnit = _targetUnit;//Re-lock unit (keep preventing other actions)
            sleep 0.5;//Minor delay to ensure server has processed the action
        };
        if (call _abortCondition) exitWith _abort;

        //Run 'Place on shoulders' animation
        [player,"acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon"] call NWG_fnc_playAnim;
        sleep (NWG_MED_CLI_Settings get "CARRY_ACTION_DURATION");//Customizable duration
        if (call _abortCondition) exitWith _abort;

        //Finalize 'Carry'
        // NWG_MED_CLI_UA_carriedUnit = _targetUnit;//Unit is already locked
        [player,"acinpercmstpsraswrfldnon"] call NWG_fnc_playAnim;//Skip remaining animation
        [player,_targetUnit,ACTION_CARRY] call NWG_fnc_medReportMedAction;
    };
};

/*Anim abuse check*/
NWG_MED_CLI_UA_animChangeAssigned = false;
NWG_MED_CLI_UA_OnAnimChange = {
    // params ["_unit","_anim"];
    params ["","_anim"];

    /*Drag to Carry via anim*/
    if (_anim isEqualTo "acinpercmstpsraswrfldnon" && {!isNull NWG_MED_CLI_UA_draggedUnit && {call NWG_MED_CLI_UA_CarryCondition}}) exitWith {
        [player,""] call NWG_fnc_playAnim;
        call NWG_MED_CLI_UA_CarryAction;
    };

    /*Carry to Release via anim*/
    if (_anim isEqualTo "amovpercmstpslowwrfldnon" && {!isNull NWG_MED_CLI_UA_carriedUnit}) exitWith {
        call NWG_MED_CLI_UA_ReleaseAction;
    };
};

/*Release*/
NWG_MED_CLI_UA_ReleaseCondition = {
    !isNull NWG_MED_CLI_UA_draggedUnit || {
    !isNull NWG_MED_CLI_UA_carriedUnit}
};
NWG_MED_CLI_UA_ReleaseAction = {
    private _targetUnit = if (!isNull NWG_MED_CLI_UA_draggedUnit)
        then {NWG_MED_CLI_UA_draggedUnit}
        else {NWG_MED_CLI_UA_carriedUnit};

    NWG_MED_CLI_UA_draggedUnit = objNull;//Unlock unit
    NWG_MED_CLI_UA_carriedUnit = objNull;//Unlock unit
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
    [player,_targetUnit,ACTION_RELEASE] call NWG_fnc_medReportMedAction;
};
NWG_MED_CLI_UA_ForceRelease = {
    NWG_MED_CLI_UA_draggedUnit = objNull;//Unlock unit
    NWG_MED_CLI_UA_carriedUnit = objNull;//Unlock unit
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
};

/*Vehicle load*/
NWG_MED_CLI_UA_VehLoadCondition = {
    !(isNull NWG_MED_CLI_UA_draggedUnit && {isNull NWG_MED_CLI_UA_carriedUnit}) && {
    !isNull (call NWG_fnc_radarGetVehAround)}
};
NWG_MED_CLI_UA_VehLoadAction = {
    private _targetUnit = if (!isNull NWG_MED_CLI_UA_draggedUnit)
        then {NWG_MED_CLI_UA_draggedUnit}
        else {NWG_MED_CLI_UA_carriedUnit};
    private _targetVeh = (call NWG_fnc_radarGetVehAround);//Omit all checks - rely on condition

    NWG_MED_CLI_UA_draggedUnit = objNull;//Unlock unit (unit is still attached to player, but that will be handled by server)
    NWG_MED_CLI_UA_carriedUnit = objNull;//Unlock unit
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
    [player,[_targetUnit,_targetVeh],ACTION_VEHLOAD] call NWG_fnc_medReportMedAction;
};

/*Vehicle load on vehicle in ('na kolenki' abuse legalize)*/
NWG_MED_CLI_UA_OnVehGetIn = {
    // params ["_unit","_role","_vehicle","_turret"];
    params ["","","_targetVeh"];
    if (isNull _targetVeh) exitWith {};//Not a vehicle
    if (isNull NWG_MED_CLI_UA_draggedUnit && {isNull NWG_MED_CLI_UA_carriedUnit}) exitWith {};//No unit to load

    private _targetUnit = if (!isNull NWG_MED_CLI_UA_draggedUnit)
        then {NWG_MED_CLI_UA_draggedUnit}
        else {NWG_MED_CLI_UA_carriedUnit};

    NWG_MED_CLI_UA_draggedUnit = objNull;//Unlock unit (unit is still attached to player, but that will be handled by server)
    NWG_MED_CLI_UA_carriedUnit = objNull;//Unlock unit
    call NWG_MED_CLI_UA_ResetAnimation;//Reset animation
    [player,[_targetUnit,_targetVeh],ACTION_VEHLOAD] call NWG_fnc_medReportMedAction;
};

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;