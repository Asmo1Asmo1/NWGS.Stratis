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

    ["TIME_BLEEDING_TIME",900],//Start bleeding with this amount of 'time left'
    ["TIME_DAMAGE_DEPLETES",10],//How much time is subtracted when damage received in wounded state

    ["SELF_HEAL_INITIAL_CHANCE",100],//Initial success chance of 'self-heal' action
    ["SELF_HEAL_CHANCE_DECREASE",10],//Amount by which success chance of 'self-heal' action decreased by every attempt
    ["SELF_HEAL_ACTION_PRIORITY",13],//Priority of 'self-heal' action
    ["SELF_HEAL_ACTION_DURATION",8],//Duration of 'self-heal' action

    ["RESPAWN_ACTION_PRIORITY",12],//Priority of 'respawn' action
    ["RESPAWN_ACTION_DURATION",5],//Duration of 'respawn' action

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

    player call NWG_MED_CLI_InitPlayer;
};

NWG_MED_CLI_InitPlayer = {
    // private _player = _this;

    [_this,false] call NWG_MED_CLI_MarkWounded;
    [_this,SUBSTATE_NONE] call NWG_MED_CLI_SetSubstate;
    [_this,(NWG_MED_CLI_Settings get "TIME_BLEEDING_TIME")] call NWG_MED_CLI_SetTime;

    call NWG_MED_CLI_ReloadChances;//Reload chances
    call NWG_MED_CLI_SA_ReloadSelfHealChance;//Reload self-heal chance

    call NWG_MED_CLI_SA_AddSelfActions;//Add self actions
};

//================================================================================================================
//================================================================================================================
//State management
NWG_MED_CLI_IsWounded = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {false};
    _this getVariable ["NWG_MED_CLI_wounded",false]
};
NWG_MED_CLI_MarkWounded = {
    params ["_unit","_wounded"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_wounded",_wounded,true];
};

NWG_MED_CLI_GetSubstate = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {SUBSTATE_NONE};
    _this getVariable ["NWG_MED_CLI_substate",SUBSTATE_NONE]
};
NWG_MED_CLI_SetSubstate = {
    params ["_unit","_substate"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_substate",_substate,true];
};
NWG_MED_CLI_CalculateSubstate = {
    // private _unit = _this;

    /*Check cases that we can get from the engine*/
    if (isNull _this || {!alive _this})     exitWith {SUBSTATE_NONE};//Invalid unit
    if ((vehicle _this) isNotEqualTo _this) exitWith {SUBSTATE_INVH};//Inside vehicle
    if ((alive _this) != (isAwake _this))   exitWith {SUBSTATE_RAGD};//Ragdolling. See: https://community.bistudio.com/wiki/isAwake

    /*Check cases where we must rely on our state changing logic*/
    private _curSubstate = _this call NWG_MED_CLI_GetSubstate;
    if (!isNull (attachedTo _this)) exitWith {if (_curSubstate isEqualTo SUBSTATE_CARR) then {SUBSTATE_CARR} else {SUBSTATE_DRAG}};
    if (_curSubstate in [SUBSTATE_CRWL,SUBSTATE_HEAL]) exitWith {_curSubstate};//These rely solely on our state changing logic

    SUBSTATE_DOWN
};

NWG_MED_CLI_GetTime = {
    // private _unit = _this;
    if (isNull _this || {!alive _this}) exitWith {0};
    _this getVariable ["NWG_MED_CLI_time",0]
};
NWG_MED_CLI_SetTime = {
    params ["_unit","_time"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    _unit setVariable ["NWG_MED_CLI_time",_time];
};
NWG_MED_CLI_DecreaseTime = {
    params ["_unit","_timeSubtraction"];
    if (isNull _unit || {!alive _unit}) exitWith {};
    private _time = _unit getVariable ["NWG_MED_CLI_time",0];
    _time = _time - _timeSubtraction;
    _unit setVariable ["NWG_MED_CLI_time",_time];
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
            case (_unit call NWG_MED_CLI_IsWounded): {_this call NWG_MED_CLI_OnDamageWhileWounded};
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
    NWG_MED_CLI_nextDamageAllowedAt = time + (NWG_MED_CLI_Settings get "INVULNERABILITY_ON_WOUNDED");

    _unit setUnconscious true;
    _unit setCaptive true;
    [_unit,true] call NWG_MED_CLI_MarkWounded;

    private _veh = vehicle _unit;
    switch (true) do {
        case (isNull _veh || {_veh isEqualTo _unit}): {/*Do nothing*/};
        case (_veh isKindOf "StaticWeapon"): {moveOut _unit};//Fix stucking inside static weapon
        default {_unit playActionNow "Unconscious"};//Fix animation in vehicle
    };

    [_unit,SUBSTATE_NONE] call NWG_MED_CLI_SetSubstate;//Will be updated in bleeding cycle
    call NWG_MED_CLI_BLEEDING_StartBleeding;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    [_damager,_unit,BLAME_WOUND] call NWG_fnc_medBlame;
};

NWG_MED_CLI_OnDamageWhileWounded = {
    // params ["_unit","_selection","_dmg","_damager","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","","","_damager","","","_instigator"];
    NWG_MED_CLI_nextDamageAllowedAt = time + 1;

    _damager = [_damager,_instigator] call NWG_MED_CLI_DefineDamager;
    if (isNull _damager) exitWith {};

    private _timeToDeplete = NWG_MED_CLI_Settings get "TIME_DAMAGE_DEPLETES";
    if (_timeToDeplete <= 0) exitWith {};

    false call NWG_MED_CLI_BLEEDING_SetPatched;
    _damager call NWG_MED_CLI_BLEEDING_SetLastDamager;
    [_unit,_timeToDeplete] call NWG_MED_CLI_DecreaseTime;
};

NWG_MED_CLI_DefineDamager = {
    params [["_damager",objNull],["_instigator",objNull]];
    private _suspect = if (!isNull _instigator) then {_instigator} else {_damager};

    switch (true) do {
        case (isNull _suspect):                   {objNull};
        case (_suspect isKindOf "Man"):           {_suspect};
        case (unitIsUAV _suspect):                {((UAVControl _suspect) param [0,objNull])};
        case (_suspect isKindOf "StaticWeapon"):  {(gunner _suspect)};
        case (_suspect call NWG_fnc_ocIsVehicle): {(driver _suspect)};
        default                                   {objNull};
    }
};

//================================================================================================================
//================================================================================================================
//Bleeding cycle
NWG_MED_CLI_BLEEDING_isBleeding = false;
NWG_MED_CLI_BLEEDING_isPatched = false;
NWG_MED_CLI_BLEEDING_lastDamager = objNull;
NWG_MED_CLI_BLEEDING_cycleHandle = scriptNull;

NWG_MED_CLI_BLEEDING_SetPatched = {NWG_MED_CLI_BLEEDING_isPatched = _this};
NWG_MED_CLI_BLEEDING_SetLastDamager = {NWG_MED_CLI_BLEEDING_lastDamager = _this};

NWG_MED_CLI_BLEEDING_StartBleeding = {
    if (NWG_MED_CLI_BLEEDING_isBleeding) exitWith {};//Prevent double start
    NWG_MED_CLI_BLEEDING_isPatched = false;
    NWG_MED_CLI_BLEEDING_lastDamager = objNull;
    private _startTime = NWG_MED_CLI_Settings get "TIME_BLEEDING_TIME";
    [player,_startTime] call NWG_MED_CLI_SetTime;
    call NWG_MED_CLI_BLEEDING_PostProcessEnable;
    NWG_MED_CLI_BLEEDING_cycleHandle = [] spawn NWG_MED_CLI_BLEEDING_Cycle;
    NWG_MED_CLI_BLEEDING_isBleeding = true;
};

NWG_MED_CLI_BLEEDING_StopBleeding = {
    if (!NWG_MED_CLI_BLEEDING_isBleeding) exitWith {};//Prevent double stop
    terminate NWG_MED_CLI_BLEEDING_cycleHandle;
    call NWG_MED_CLI_BLEEDING_PostProcessDisable;
    hintSilent "";//Clear hint
    NWG_MED_CLI_BLEEDING_isPatched = false;
    NWG_MED_CLI_BLEEDING_lastDamager = objNull;
    NWG_MED_CLI_BLEEDING_isBleeding = false;
};

NWG_MED_CLI_BLEEDING_Cycle = {
    private _abortCondition = {isNull player || {!alive player}};

    waitUntil {
        if (call _abortCondition) exitWith {true};

        //Check and update substate
        private _substate = player call NWG_MED_CLI_CalculateSubstate;
        if (_substate isEqualTo SUBSTATE_INVH && {!alive (vehicle player)}) then {
            //Fix (im)possible stucking inside burning vehicle
            player moveOut (vehicle player);
            _substate = SUBSTATE_DOWN;
        };
        if ((player call NWG_MED_CLI_GetSubstate) isNotEqualTo _substate) then {
            [player,_substate] call NWG_MED_CLI_SetSubstate;
        };

        //Check time left
        private _timeLeft = player call NWG_MED_CLI_GetTime;
        if (_timeLeft <= 0) exitWith {
            /*Someone decreased our time while we were doing 'sleep'*/
            if (!isNull NWG_MED_CLI_BLEEDING_lastDamager) then {[NWG_MED_CLI_BLEEDING_lastDamager,player,BLAME_KILL] call NWG_fnc_medBlame};
            call NWG_MED_CLI_Respawn;
            true;//Exit cycle
        };

        //Deplete time
        private _timeToDeplete = 1;
        if !(NWG_MED_CLI_BLEEDING_isPatched) then {_timeToDeplete = 2};//Increase if unit not patched
        if !(_substate in [SUBSTATE_INVH,SUBSTATE_DOWN]) then {_timeToDeplete = _timeToDeplete * 2};//Increase if unit is not still
        _timeLeft = _timeLeft - _timeToDeplete;
        if (_timeLeft <= 0) exitWith {
            /*Our time ran out naturally*/
            call NWG_MED_CLI_Respawn;
            true;//Exit cycle
        };
        [player,_timeToDeplete] call NWG_MED_CLI_DecreaseTime;

        //Calculate closest player
        private _allValidPlayers = (call NWG_fnc_getPlayersAll) select {
            alive _x && {
            _x isNotEqualTo player && {
            !(_x call NWG_MED_CLI_IsWounded) && {
            (side (group _x)) isEqualTo (side (group player))}}}
        };
        private _closestPlayer = if ((count _allValidPlayers) > 0) then {
            _allValidPlayers = _allValidPlayers apply {[(_x distance player),_x]};
            _allValidPlayers sort true;
            (_allValidPlayers#0)#1
        } else {objNull};

        //Output info to the UI
        private _template = [];
        _template pushBack (switch (_timeToDeplete) do {
            case 1: {"#MED_CLI_BLEEDING_UI_TITLE_LOW#"};
            case 2: {"#MED_CLI_BLEEDING_UI_TITLE_MID#"};
            case 4: {"#MED_CLI_BLEEDING_UI_TITLE_HIGH#"};
            default {""};//Shouldn't happen
        });
        _template pushBack "#MED_CLI_BLEEDING_UI_TIMELEFT#";
        _template pushBack (if (!isNull _closestPlayer)
            then {"#MED_CLI_BLEEDING_UI_CLOSEST_PLAYER#"}
            else {"#MED_CLI_BLEEDING_UI_NO_CLOSEST#"});
        _template = (_template apply {_x call NWG_fnc_localize}) joinString "\n";
        private _output = if (!isNull _closestPlayer)
            then {format [_template,_timeLeft,_timeToDeplete,(name _closestPlayer),(_closestPlayer distance player)]}
            else {format [_template,_timeLeft,_timeToDeplete]};
        hintSilent _output;

        //Repeat
        sleep 1;
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
//Respawn
NWG_MED_CLI_Respawn = {
    player setDamage 1;
};

/*This will be called on every respawn, including graceful respawn, bugs, instakills, drowning, etc.*/
NWG_MED_CLI_respawnPoint = [];
NWG_MED_CLI_OnRespawn = {
    params ["_player","_corpse"];

    _player setPosASL NWG_MED_CLI_respawnPoint;//Teleport to the respawn point
    call NWG_MED_CLI_BLEEDING_StopBleeding;//Stop bleeding if it's still active
    _player setCaptive false;//Reset captive state
    _player setUnconscious false;//Reset unconscious state
    _player call NWG_MED_CLI_InitPlayer;
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
    params ["_title","_icon","_priority","_duration","_condition","_conditionHold","_onStarted","_onInterrupted","_onCompleted",["_showWhileWounded",false],["_autoShow",false]];
    [
        player,                         // Object the action is attached to
        (_title call NWG_fnc_localize), // Title of the action
        _icon,                          // Idle icon shown on screen
        _icon,                          // Progress icon shown on screen
        _condition,                     // Condition for the action to be shown
        _conditionHold,                 // Condition for the action to progress
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

//================================================================================================================
//================================================================================================================
//Self actions
NWG_MED_CLI_SA_AddSelfActions = {
    /*Self heal*/
    [
        "#MED_ACTION_SELF_HEAL_TITLE#",/*_title*/
        "a3\ui_f\data\igui\cfg\holdactions\holdaction_revive_ca.paa",/*_icon*/
        (NWG_MED_CLI_Settings get "SELF_HEAL_ACTION_PRIORITY"),/*_priority*/
        (NWG_MED_CLI_Settings get "SELF_HEAL_ACTION_DURATION"),/*_duration*/
        "(call NWG_MED_CLI_SA_SelfHealCondition)",/*_condition*/
        "true",/*_conditionHold*/
        {call NWG_MED_CLI_SA_OnSelfHealStarted},/*_onStarted*/
        {},/*_onInterrupted*/
        {call NWG_MED_CLI_SA_OnSelfHealCompleted},/*_onCompleted*/
        true/*_showWhileWounded*/
    ] call NWG_MED_CLI_AddHoldAction;

    /*Respawn*/
        [
        "#MED_ACTION_RESPAWN_TITLE#",/*_title*/
        "a3\ui_f\data\igui\cfg\holdactions\holdaction_forcerespawn_ca.paa",/*_icon*/
        (NWG_MED_CLI_Settings get "RESPAWN_ACTION_PRIORITY"),/*_priority*/
        (NWG_MED_CLI_Settings get "RESPAWN_ACTION_DURATION"),/*_duration*/
        "(call NWG_MED_CLI_SA_RespawnCondition)",/*_condition*/
        "true",/*_conditionHold*/
        {},/*_onStarted*/
        {},/*_onInterrupted*/
        {call NWG_MED_CLI_SA_OnRespawnCompleted},/*_onCompleted*/
        true/*_showWhileWounded*/
    ] call NWG_MED_CLI_AddHoldAction;

    /*Crawl*/
    if (!NWG_MED_CLI_SA_CrawlAdded) then {
        [] spawn NWG_MED_CLI_SA_AddCrawl;
        NWG_MED_CLI_SA_CrawlAdded = true;
    };
};

/*Self heal*/
NWG_MED_CLI_SA_selfHealSuccessChance = 100;
NWG_MED_CLI_SA_ReloadSelfHealChance = {NWG_MED_CLI_SA_selfHealSuccessChance = NWG_MED_CLI_Settings get "SELF_HEAL_INITIAL_CHANCE"};

NWG_MED_CLI_SA_SelfHealCondition = {
    player call NWG_MED_CLI_IsWounded && {
    NWG_MED_CLI_hasFAKkit && {
    (player call NWG_MED_CLI_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_INVH]}}
};
NWG_MED_CLI_SA_OnSelfHealStarted = {
    //Show message
    private _successChance = (str NWG_MED_CLI_SA_selfHealSuccessChance)+"%";//Fix template unable to have '%' symbol
    ["#MED_ACTION_SELF_HEAL_HINT#",_successChance] call NWG_fnc_systemChatMe;

    //Play anim
    if ((vehicle player) isEqualTo player) then {
        [player,"ainvppnemstpslaywnondnon_medic"] call NWG_fnc_playAnim;
        player playMove "UnconsciousFaceDown";
    };
};
NWG_MED_CLI_SA_OnSelfHealCompleted = {
    //Consume First Aid Kit
    private _spendFakOk = FAKKIT call NWG_fnc_invRemoveItem;
    if (!_spendFakOk) exitWith {
        "NWG_MED_CLI_SA_OnSelfHealCompleted: Failed to consume FAK" call NWG_fnc_logError;
        [player,player,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction;
    };

    //Patch player if needed
    if (!NWG_MED_CLI_BLEEDING_isPatched) then {
        [player,player,ACTION_PATCH] call NWG_fnc_medReportMedAction;
    };

    //Get success chance for self-revive
    private _myChance = NWG_MED_CLI_SA_selfHealSuccessChance;//Get chance
    NWG_MED_CLI_SA_selfHealSuccessChance = NWG_MED_CLI_SA_selfHealSuccessChance - (NWG_MED_CLI_Settings get "SELF_HEAL_CHANCE_DECREASE");//Decrease success chance for next attempt

    //Try to revive
    if ((random 100) <= _myChance)
        then {[player,player,ACTION_HEAL_SUCCESS] call NWG_fnc_medReportMedAction}
        else {[player,player,ACTION_HEAL_FAILURE] call NWG_fnc_medReportMedAction};
};

/*Respawn*/
NWG_MED_CLI_SA_RespawnCondition = {
    player call NWG_MED_CLI_IsWounded && {
    (player call NWG_MED_CLI_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_INVH]}
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
            !isNull player && {
            alive player && {
            player call NWG_MED_CLI_IsWounded && {
            (player call NWG_MED_CLI_GetSubstate) in [SUBSTATE_DOWN,SUBSTATE_CRWL] && {
            (vehicle player) isEqualTo player}}}}}
        ) then {
            [player,SUBSTATE_CRWL] call NWG_MED_CLI_SetSubstate;
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
            !isNull player && {
            alive player && {
            player call NWG_MED_CLI_IsWounded && {
            (player call NWG_MED_CLI_GetSubstate) isEqualTo SUBSTATE_CRWL && {
            (vehicle player) isEqualTo player}}}}}
        ) then {
            [player,SUBSTATE_DOWN] call NWG_MED_CLI_SetSubstate;
            player playActionNow "Unconscious";
            player setCaptive true;
        };

        false/*Never intercept*/
    }];
};

//================================================================================================================
//================================================================================================================
//Units actions

//================================================================================================================
//================================================================================================================
//Post-compilation init
call _Init;