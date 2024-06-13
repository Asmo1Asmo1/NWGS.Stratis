#include "..\..\globalDefines.h"
#include "yellowKingDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_YK_Settings = createHashMapFromArray [
    ["ENABLE_ON_START",false],//Defines wether or not the entire system is enabled on mission start
    ["KING_SIDE",west],//The side which kills will count and groups/reinforcements used, basically the side YK is plays for
    ["REACT_TO_PLAYERS_ONLY",false],//Should we handle kills made by players only or include enemy AI units as well
    ["SHOW_DEBUG_MESSAGES",true],//Show debug messages in systemChat

    ["DEFAULT_REINF_FACTION","NATO"],//The default faction to use for reinforcements if no faction saved to state holder

    ["HUNT_ALARM",true],//Should we alarm hunters when a kill happens
    ["HUNT_ALARM_RADIUS",1000],//The radius in which hunters will be alarmed
    ["HUNT_MERGE_LONERS",true],//Should we merge loner groups into bigger ones
    ["HUNT_RADIUS",500],//Radius at which hunters will be sent to attack the target

    ["SPECIAL_AIRSTRIKE_ENABLED",true],//Is airstrike allowed
    ["SPECIAL_ARTA_ENABLED",true],//Is artillery strike allowed
    ["SPECIAL_MORTAR_ENABLED",true],//Is mortar strike allowed
    ["SPECIAL_VEHDEMOLITION_ENABLED",true],//Is vehicle demolition allowed
    ["SPECIAL_INFSTORM_ENABLED",false],//Is infantry building storm allowed
    ["SPECIAL_VEHREPAIR_ENABLED",true],//Is vehicle repair allowed

    ["SPECIAL_VEHDEMOLITION_RADIUS",500],//Radius at which groups will be sent to do vehdemolition
    ["SPECIAL_INFSTORM_RADIUS",500],//Radius at which groups will be sent to do infstorm

    ["STATISTICS_ENABLED",true],//If true, the system will keep track of statistics
    ["STATISTICS_TO_RPT",true],//If true, the statistics will be dumped to rpt
    ["STATISTICS_TO_PROFILENAMESPACE",false],//If true, the statistics will be saved to profileNamespace

    ["DIFFICULTY_REACTION_TIME",[60,120]],//Min and max time between actions and reactions (will be defined randomly between the two)
    ["DIFFICULTY_REACTION_IMMEDIATE_ON_KILLCOUNT",10],//Number of kills to immediately react to (skips all the wait remaining)
    ["DIFFICULTY_CURVE",[0,1,0,1,2,1,2,0,1,1,2,0,1,2,2,1,0]],//Yellow King difficulty curve
    ["DIFFUCULTY_PRESETS",[
        /*Easy*/
            [/*_minReact*/1, /*_ingoreChance*/0.3, /*_maxMoves*/2, /*_maxReinfs*/0, /*_maxSpecials*/1],
        /*Medium*/
            [/*_minReact*/2, /*_ingoreChance*/0.2, /*_maxMoves*/3, /*_maxReinfs*/1, /*_maxSpecials*/2],
        /*Hard*/
            [/*_minReact*/3, /*_ingoreChance*/0.1, /*_maxMoves*/4, /*_maxReinfs*/2, /*_maxSpecials*/3]
    ]],//YellowKing difficulty presets

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Fields
/* main flags */
NWG_YK_Enabled = false;
NWG_YK_Status = STATUS_DISABLED;
/* counters */
NWG_YK_killCount = 0;
NWG_YK_killCountTotal = 0;
/* reinforcements spawning */
NWG_YK_reinfSide = nil;
NWG_YK_reinfFaction = nil;
NWG_YK_reinfMap = nil;

//======================================================================================================
//======================================================================================================
//Init
private _Init = {
    //Be the first system to react to something being killed
    [EVENT_ON_OBJECT_KILLED,{_this call NWG_YK_OnKilled},/*_setFirst:*/true] call NWG_fnc_subscribeToServerEvent;

    //Check if we're in production - disable debug messages
    if !(is3DENPreview || {is3DENMultiplayer})
        then {NWG_YK_Settings set ["SHOW_DEBUG_MESSAGES",false]};

    //Init difficulty curve
    NWG_YK_difficultyCurve = (NWG_YK_Settings get "DIFFICULTY_CURVE")+[];//Shallow copy

    //Check auto-enable
    if (NWG_YK_Settings get "ENABLE_ON_START") then {call NWG_YK_Enable};
};

//======================================================================================================
//======================================================================================================
//Enable/Disable/Configure
NWG_YK_Enable = {
    if (NWG_YK_Enabled) exitWith {false};//Already enabled
    call NWG_YK_ShiftDifficultyCurve;//Shift the difficulty curve
    call NWG_YK_STAT_OnEnable;//Statistics
    NWG_YK_killCount = 0;//Reset the kill count
    NWG_YK_killCountTotal = 0;//Reset the total kill count
    NWG_YK_Enabled = true;
    NWG_YK_Status = STATUS_READY;
    true
};
NWG_YK_Disable = {
    if !(NWG_YK_Enabled) exitWith {false};//Already disabled
    if (!isNull NWG_YK_reactHandle || {!scriptDone NWG_YK_reactHandle})
        then {terminate NWG_YK_reactHandle};//Terminate the reaction script
    call NWG_YK_STAT_OnDisable;//Statistics
    NWG_YK_Enabled = false;
    NWG_YK_Status = STATUS_DISABLED;
    true
};
NWG_YK_Configure = {
    params ["_kingSide","_reinfSide","_reinfFaction","_reinfMap"];
    if !(isNil "_kingSide") then {NWG_YK_Settings set ["KING_SIDE",_kingSide]};
    if !(isNil "_reinfSide") then {NWG_YK_reinfSide = _reinfSide};
    if !(isNil "_reinfFaction") then {NWG_YK_reinfFaction = _reinfFaction};
    if !(isNil "_reinfMap") then {NWG_YK_reinfMap = _reinfMap};
};

//======================================================================================================
//======================================================================================================
//Reaction system
NWG_YK_killsToCount = [OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT];
NWG_YK_OnKilled = {
    params ["_object","_objType","_actualKiller","_isPlayerKiller"];

    //Check
    if !(NWG_YK_Enabled) exitWith {};//System is disabled
    if (isNull _object || {isNull _actualKiller || {!alive _actualKiller}}) exitWith {};//Unprocessable kill
    if (!(_objType in NWG_YK_killsToCount)) exitWith {};//Not a kill of interest
    if (!_isPlayerKiller && {(NWG_YK_Settings get "REACT_TO_PLAYERS_ONLY")}) exitWith {};//If we only want to react to player kills

    private _objGroup = if (_objType isEqualTo OBJ_TYPE_UNIT) then {group _object} else {assignedGroup _object};
    if (isNull _objGroup || {(side _objGroup) isNotEqualTo (NWG_YK_Settings get "KING_SIDE")}) exitWith {};//Not a kill of interest
    if ((side (group _actualKiller)) isEqualTo (NWG_YK_Settings get "KING_SIDE")) exitWith {};//Friendly fire. TODO: Add traitors punishment?

    //Setup reaction
    NWG_YK_killCount = NWG_YK_killCount + 1;
    NWG_YK_killCountTotal = NWG_YK_killCountTotal + 1;
    NWG_YK_reactList pushBackUnique _actualKiller;
    if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGES") then {systemChat (format ["NWG_YK: %1 killed %2",(name _actualKiller),(name _object)])};
    if (isNull NWG_YK_reactHandle || {scriptDone NWG_YK_reactHandle}) then {
        NWG_YK_reactTime = time + ((NWG_YK_Settings get "DIFFICULTY_REACTION_TIME") call NWG_fnc_randomRangeInt);
        NWG_YK_reactHandle = [] spawn NWG_YK_React;
        NWG_YK_Status = STATUS_PREPARING;
    };
};

NWG_YK_reactList = [];
NWG_YK_reactTime = 0;
NWG_YK_reactHandle = scriptNull;
NWG_YK_React = {
    //0. Wait for the reaction time to pass or the kill count to reach the immediate reaction limit
    waitUntil {
        sleep 1;
        (time >= NWG_YK_reactTime || {NWG_YK_killCount > (NWG_YK_Settings get "DIFFICULTY_REACTION_IMMEDIATE_ON_KILLCOUNT")})
    };
    private _onExit = {
        NWG_YK_reactList resize 0;
        NWG_YK_reactTime = 0;
        NWG_YK_killCount = 0;
        NWG_YK_Status = STATUS_READY;
    };
    /*Statistics and status*/
    [STAT_REACTION_COUNT,1] call NWG_YK_STAT_Increment;
    NWG_YK_Status = STATUS_ACTING;

    //1. Get raw targets to react to
    private _targets = NWG_YK_reactList select {alive _x};
    if ((count _targets) == 0) exitWith _onExit;//No targets to react to

    //2. Get difficulty settings
    (call NWG_YK_GetDifficultyPreset) params ["_minReact","_ignoreChance","_movesLeft","_reinfsLeft","_speciaslLeft"];

    //3. Process and convert the targets
    /*Apply min reaction count*/
    if ((count _targets) < _minReact) then {
        while {(count _targets) < _minReact} do {_targets append _targets};
        _targets resize _minReact;
    };
    private _initialCount = (count _targets);//Statistics
    _targets = _targets select {(random 1) >= _ignoreChance};//Apply ignore chance
    _targets = _targets call NWG_YK_ConvertToTargetData;//Convert to target data
    /*Statistics*/
    [STAT_TARGETS_ACQUIRED,_initialCount] call NWG_YK_STAT_Increment;
    [STAT_TARGETS_IGNORED,(_initialCount - (count _targets))] call NWG_YK_STAT_Increment; _initialCount = nil;
    if ((count _targets) == 0) exitWith _onExit;//No targets to react to

    //4. Gather the hunters
    private _hunters = call NWG_YK_HUNT_GetHunters;
    if (NWG_YK_Settings get "HUNT_MERGE_LONERS") then {
        _hunters = _hunters call NWG_YK_HUNT_MergeLoners;
    };
    if (NWG_YK_Settings get "SPECIAL_VEHREPAIR_ENABLED") then {
        private _toRepair = _hunters select {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHREPAIR};
        if ((count _toRepair) == 0) exitWith {};
        _hunters = _hunters - _toRepair;
        _toRepair call NWG_YK_SPEC_SendToRepair;
    };

    //5. Bring the action
    //forEach target
    {
        //Unpack data
        _x params ["_targetObj","_targetType","_targetPos"/*,"_targetBuilding"*/];

        //Alarm nearby hunters
        if (NWG_YK_Settings get "HUNT_ALARM") then {[_hunters,_targetPos] call NWG_YK_HUNT_Alarm};

        //Fill the dice
        private _dice = [];
        if (_movesLeft > 0) then {
            private _i = [_hunters,_targetType,_targetPos] call NWG_YK_HUNT_SelectHunterFor;
            if (_i != -1) then {_dice pushBack [DICE_MOVE,_i]};
        };
        if (_reinfsLeft > 0) then {
            _dice pushBack [DICE_REINF];
        };
        if (_speciaslLeft > 0) then {
            private _specials = [_hunters,_x] call NWG_YK_SPEC_SelectSpecialsForTarget;//Notice that we pass the entire target record
            if ((count _specials) > 0) then {_dice pushBack [DICE_SPEC,_specials]};
        };
        if (_dice isEqualTo []) then {continue};//There is nothing we can do.. | Napoleon Meme

        //Roll the dice (Need for Speed IV Soundtrack - Roll The Dice) https://www.youtube.com/watch?v=ZgmQK1wVPzg
        (selectRandom _dice) params ["_diceType","_diceArg"];

        //Act
        switch (_diceType) do {
            case DICE_MOVE : {
                [_hunters,_diceArg,_targetPos] call NWG_YK_HUNT_MoveHunter;
                _movesLeft = _movesLeft - 1;
                /*Statistics*/
                [STAT_GROUPS_MOVED,1] call NWG_YK_STAT_Increment;
            };
            case DICE_REINF: {
                [_targetType,_targetPos] call NWG_YK_REINF_SendReinforcements;
                _reinfsLeft = _reinfsLeft - 1;
                /*Statistics*/
                [STAT_REINFS_SENT,1] call NWG_YK_STAT_Increment;
            };
            case DICE_SPEC : {
                private _special = (selectRandom _diceArg);
                [_hunters,_special] call NWG_YK_SPEC_UseSpecial;
                _speciaslLeft = _speciaslLeft - 1;
                /*Statistics*/
                [STAT_SPECIALS_USED,1] call NWG_YK_STAT_Increment;
                switch (_special#0) do {
                    case SPECIAL_AIRSTRIKE:      {[STAT_SPEC_AIRSTRIKE,1] call NWG_YK_STAT_Increment};
                    case SPECIAL_ARTA:           {[STAT_SPEC_ARTA,     1] call NWG_YK_STAT_Increment};
                    case SPECIAL_MORTAR:         {[STAT_SPEC_MORTAR,   1] call NWG_YK_STAT_Increment};
                    case SPECIAL_VEHDEMOLITION:  {[STAT_SPEC_VEHDEMOLITION,1] call NWG_YK_STAT_Increment};
                    case SPECIAL_INFSTORM:       {[STAT_SPEC_INFSTORM, 1] call NWG_YK_STAT_Increment};
                    case SPECIAL_VEHREPAIR:      {[STAT_SPEC_VEHREPAIR,1] call NWG_YK_STAT_Increment};
                };
            };
        };
    } forEach _targets;

    //6. Reset
    call _onExit;
};

//======================================================================================================
//======================================================================================================
//Difficulty settings
NWG_YK_difficultyCurve = [];
NWG_YK_ShiftDifficultyCurve = {
    NWG_YK_difficultyCurve = NWG_YK_difficultyCurve call NWG_fnc_arrayRandomShift;
};
NWG_YK_GetDifficultyPreset = {
    private _i = NWG_YK_difficultyCurve deleteAt 0;//Pop
    NWG_YK_difficultyCurve pushBack _i;//Push back
    private _presets = NWG_YK_Settings get "DIFFUCULTY_PRESETS";
    //return
    (_presets select _i)
};

//======================================================================================================
//======================================================================================================
//Targets logic
NWG_YK_ConvertToTargetData = {
    private _targets = _this;
    if ((count _targets) == 0) exitWith {[]};
    _targets = (_targets apply {vehicle _x}) select {alive _x};//Convert to vehicles

    private ["_type","_pos","_bldg"];
    _targets = _targets apply {
        _type = _x call NWG_fnc_acGetTargetType;
        _pos  = getPosASL _x;
        _bldg = if (_type isEqualTo TARGET_TYPE_INF) then {_x call NWG_fnc_acGetBuildingTargetIn} else {objNull};
        [_x,_type,_pos,_bldg]
    };

    //return
    _targets
};

//======================================================================================================
//======================================================================================================
//Hunters logic
/*Info gathering*/
NWG_YK_HUNT_GetHunters = {
    private _kingSide = NWG_YK_Settings get "KING_SIDE";
    private _groups = (groups _kingSide) select {
        !isNull _x && {
        alive (leader _x) && {
        (units _x) findIf {isPlayer _x} == -1}}
    };

    //return
    _groups call NWG_YK_HUNT_ConvertToHunters
};

/*Utils*/
NWG_YK_HUNT_ConvertToHunters = {
    // private _groups = _this;
    private ["_posistion","_aliveCount","_parentSystem","_tags","_special"];
    _this apply {
        _posistion = getPosASL (vehicle (leader _x));
        _aliveCount = {alive _x} count (units _x);
        _parentSystem = _x call NWG_YK_HUNT_GetParentSystem;
        _tags = if (_parentSystem isEqualTo PARENT_SYSTEM_DSPAWN) then {_x call NWG_fnc_dsGetTags} else {[]};
        _special = [_x,_parentSystem,_tags] call NWG_YK_HUNT_GetGroupSpecial;
        [_x,_posistion,_aliveCount,_parentSystem,_tags,_special]
    }
};

NWG_YK_HUNT_GetParentSystem = {
    // private _group = _this;
    switch (true) do {
        case (_this call NWG_fnc_dsIsDspawnGroup) : {PARENT_SYSTEM_DSPAWN};
        case (_this call NWG_fnc_ukrpIsUkrepGroup): {PARENT_SYSTEM_UKREP};
        default {_this call NWG_fnc_dsAdoptGroup;    PARENT_SYSTEM_DSPAWN};//Adopt the group and return dspawn
    }
};

NWG_YK_HUNT_GetGroupSpecial = {
    params ["_group","_parentSystem","_tags"];

    switch (_parentSystem) do {
        case PARENT_SYSTEM_DSPAWN: {
            switch (true) do {
                case ("AIRSTRIKE+" in _tags && {_group call NWG_fnc_acCanDoAirstrike})       : {SPECIAL_AIRSTRIKE};
                case ("VEH"  in _tags       && {_group call NWG_fnc_acNeedsRepair})          : {SPECIAL_VEHREPAIR};
                case ("ARTA" in _tags       && {_group call NWG_fnc_acCanDoArtilleryStrike}) : {SPECIAL_ARTA};
                case ("VEH"  in _tags       && {_group call NWG_fnc_acCanDoVehDemolition})   : {SPECIAL_VEHDEMOLITION};
                case ("INF"  in _tags       && {_group call NWG_fnc_acCanDoInfBuildingStorm}): {SPECIAL_INFSTORM};
                default {SPECIAL_NONE};
            }
        };
        case PARENT_SYSTEM_UKREP: {
            switch (true) do {
                case (_group call NWG_fnc_acCanDoArtilleryStrike): {SPECIAL_ARTA};
                case (_group call NWG_fnc_acCanDoMortarStrike)   : {SPECIAL_MORTAR};
                default {SPECIAL_NONE};
            }
        };
        default {SPECIAL_NONE};
    }
};

/*Management logic*/
NWG_YK_HUNT_Alarm = {
    params ["_hunters","_targetPos"];
    private _radius = NWG_YK_Settings get "HUNT_ALARM_RADIUS";
    //do
    {
        (_x#HUNTER_GROUP) setCombatMode "RED";
        (_x#HUNTER_GROUP) setBehaviourStrong "AWARE";
    } forEach (_hunters select {((_x#HUNTER_POSITION) distance2D _targetPos) <= _radius && {(behaviour (leader (_x#HUNTER_GROUP))) isEqualTo "SAFE"}});
};

NWG_YK_HUNT_MergeLoners = {
    // private _hunters = _this;

    //Find all loners
    private _loners = _this select {
        _x#HUNTER_ALIVE_COUNT == 1 && {
        _x#HUNTER_PARENT_SYSTEM isEqualTo PARENT_SYSTEM_DSPAWN && {
        "INF" in (_x#HUNTER_TAGS)}}
    };
    if ((count _loners) == 0) exitWith {_this};//No loners to merge

    //Find all adopters
    private _adopters = _this select {
        _x#HUNTER_ALIVE_COUNT > 1 && {
        (("INF" in (_x#HUNTER_TAGS)) || ((_x#HUNTER_TAGS) isEqualTo []))}
    };
    if ((count _adopters) == 0 && {(count _loners) == 1}) exitWith {_this};//Can't merge a single loner to itself

    //Calculate the group to merge with
    private _lonersMidpoint = (_loners apply {_x#HUNTER_POSITION}) call NWG_fnc_dtsFindMidpoint;
    private _extractClosest = {
        // private _array = _this;
        private _closest = -1;
        private _dist = 0;
        private _minDist = 100000;
        {
            _dist = (_x#HUNTER_POSITION) distance2D _lonersMidpoint;
            if (_dist < _minDist) then {
                _minDist = _dist;
                _closest = _forEachIndex;
            };
        } forEach _this;
        _this deleteAt _closest
    };
    private _toMergeWith = if ((count _adopters) == 0)
        then {_loners   call _extractClosest} //Merge loners to a single group among themselves
        else {_adopters call _extractClosest};//Merge loners to one of the adopters

    //Merge
    {(units (_x#HUNTER_GROUP)) joinSilent (_toMergeWith#HUNTER_GROUP)} forEach _loners;

    //Repack
    private _temp = _this - _loners;
    _this resize 0;
    _this append _temp;
    _this
};

NWG_YK_HUNT_SelectHunterFor = {
    params ["_hunters","_targetType","_targetPos"];
    if ((count _hunters) == 0) exitWith {-1};//No hunters

    private _radius = NWG_YK_Settings get "HUNT_RADIUS";
    private _typeCondition = switch (_targetType) do {
        case TARGET_TYPE_INF: {{true}};//Any hunter will do
        case TARGET_TYPE_VEH: {{true}};//Same as above
        case TARGET_TYPE_ARM: {{"AT" in (_this#HUNTER_TAGS)}};//Only AT hunters can handle armor
        case TARGET_TYPE_AIR: {{"AA" in (_this#HUNTER_TAGS)}};//Only AA hunters can handle air
        case TARGET_TYPE_BOAT: {{"BOAT" in (_this#HUNTER_TAGS) || {("AIR" in (_this#HUNTER_TAGS)) && ("MEC" in (_this#HUNTER_TAGS))}}};
        default {{false}};//Should never happen
    };

    //return
    _hunters findIf {
        (_x#HUNTER_PARENT_SYSTEM) isEqualTo PARENT_SYSTEM_DSPAWN && {
        (_x call _typeCondition) && {
        ((_x#HUNTER_POSITION) distance2D _targetPos) <= _radius}}
    }
};

NWG_YK_HUNT_MoveHunter = {
    params ["_hunters","_index","_targetPos"];
    private _hunter = _hunters deleteAt _index;
    [(_hunter#HUNTER_GROUP),_targetPos] call NWG_fnc_dsSendToAttack;
};

//======================================================================================================
//======================================================================================================
//Reinforesments logic
NWG_YK_REINF_SendReinforcements = {
    params ["_targetType","_targetPos"];

    private _filter = switch (_targetType) do {
        case TARGET_TYPE_ARM: {[["AT"],[],[]]};//Whitelist AT groups
        case TARGET_TYPE_AIR: {[["AA"],[],[]]};//Whitelist AA groups
        default {[]};//No filter
    };

    private _faction = if !(isNil "NWG_YK_reinfFaction")
        then {NWG_YK_reinfFaction}
        else {NWG_YK_Settings get "DEFAULT_REINF_FACTION"};
    private _side = if !(isNil "NWG_YK_reinfSide")
        then {NWG_YK_reinfSide}
        else {NWG_YK_Settings get "KING_SIDE"};//Default to king's side
    private _reinfMap = if !(isNil "NWG_YK_reinfMap")
        then {NWG_YK_reinfMap}
        else {[]};

    [_targetPos,1,_faction,_filter,_side,_reinfMap] spawn NWG_fnc_dsSendReinforcements;
};

//======================================================================================================
//======================================================================================================
//Specials logic
NWG_YK_SPEC_SendToRepair = {
    // private _hunters = _this;
    private _ok = true;
    {
        _ok = (_x#HUNTER_GROUP) call NWG_fnc_acSendToVehRepair;
        if (isNil "_ok" || {_ok isNotEqualTo true}) then {
            format ["NWG_YK_SPEC_SendToRepair: Failed to send '%1' to repair. Result:%2",_x,_ok] call NWG_fnc_logError;
        };
    } forEach _this;
};

NWG_YK_SPEC_SelectSpecialsForTarget = {
    params ["_hunters","_target"];
    private _result = [];

    //Check if target is of AIR type - not much we can do about it with only exception is when it is parked
    if (((_target#TARGET_TYPE) isEqualTo TARGET_TYPE_AIR) && {(abs ((getPos (_target#TARGET_OBJECT))#2)) > 5}) exitWith {_result};

    //Airstrike
    if (NWG_YK_Settings get "SPECIAL_AIRSTRIKE_ENABLED") then {
        private _actualTarget = if (!isNull (_target#TARGET_BUILDING)) then {_target#TARGET_BUILDING} else {_target#TARGET_OBJECT};
        private _i = _hunters findIf {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_AIRSTRIKE};
        if (_i == -1) exitWith {};
        private _numberOfStrikes = selectRandom [1,1,2,3];
        _result pushBack [SPECIAL_AIRSTRIKE,_i,_actualTarget,_numberOfStrikes];
    };

    //Artillery strike
    if (NWG_YK_Settings get "SPECIAL_ARTA_ENABLED") then {
        private _actualTarget = if (!isNull (_target#TARGET_BUILDING)) then {_target#TARGET_BUILDING} else {_target#TARGET_OBJECT};
        private _i = _hunters findIf {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_ARTA && {[(_x#HUNTER_GROUP),_actualTarget] call NWG_fnc_acCanDoArtilleryStrikeOnTarget}};
        if (_i == -1) exitWith {};
        private _precise = !isNull (_target#TARGET_BUILDING) || {(_target#TARGET_TYPE) isEqualTo TARGET_TYPE_ARM};
        _result pushBack [SPECIAL_ARTA,_i,_actualTarget,_precise];
    };

    //Mortar strike
    if (NWG_YK_Settings get "SPECIAL_MORTAR_ENABLED") then {
        private _actualTarget = if (!isNull (_target#TARGET_BUILDING)) then {_target#TARGET_BUILDING} else {_target#TARGET_OBJECT};
        private _i = _hunters findIf {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_MORTAR && {[(_x#HUNTER_GROUP),_actualTarget] call NWG_fnc_acCanDoMortarStrikeOnTarget}};
        if (_i == -1) exitWith {};
        private _precise = !isNull (_target#TARGET_BUILDING) || {(_target#TARGET_TYPE) isEqualTo TARGET_TYPE_ARM};
        _result pushBack [SPECIAL_MORTAR,_i,_actualTarget,_precise];
    };

    //Vehicle demolition
    if (NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_ENABLED") then {
        if (isNull (_target#TARGET_BUILDING)) exitWith {};//Only buildings can be demolished
        private _actualTarget = _target#TARGET_BUILDING;
        private _radius = NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_RADIUS";
        private _i = _hunters findIf {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHDEMOLITION && {((_x#HUNTER_POSITION) distance2D _actualTarget) <= _radius}};
        if (_i == -1) exitWith {};
        _result pushBack [SPECIAL_VEHDEMOLITION,_i,_actualTarget];
    };

    //Inf building storm
    if (NWG_YK_Settings get "SPECIAL_INFSTORM_ENABLED") then {
        if (isNull (_target#TARGET_BUILDING)) exitWith {};//Only buildings can be stormed
        private _actualTarget = _target#TARGET_BUILDING;
        private _radius = NWG_YK_Settings get "SPECIAL_INFSTORM_RADIUS";
        private _i = _hunters findIf {(_x#HUNTER_SPECIAL) isEqualTo SPECIAL_INFSTORM && {((_x#HUNTER_POSITION) distance2D _actualTarget) <= _radius}};
        if (_i == -1) exitWith {};
        _result pushBack [SPECIAL_INFSTORM,_i,_actualTarget];
    };
    halt;

    //return
    _result
};

NWG_YK_SPEC_UseSpecial = {
    params ["_hunters","_special"];
    _special params ["_specialType","_i","_actualTarget","_arg"];//Do not use default value for _arg to see the error if we misused it

    //Get the hunter
    private _hunter = _hunters deleteAt _i;
    if (isNil "_hunter") exitWith {
        format ["NWG_YK_SPEC_UseSpecial: Failed to get hunter at index %1. Special:%2",_i,_special] call NWG_fnc_logError;
    };
    private _group = _hunter#HUNTER_GROUP;

    //Use the special
    private _ok = switch (_specialType) do {
        case SPECIAL_AIRSTRIKE: {[_group,_actualTarget,_arg] call NWG_fnc_acSendToAirstrike};
        case SPECIAL_ARTA:      {[_group,_actualTarget,_arg] call NWG_fnc_acSendArtilleryStrike};
        case SPECIAL_MORTAR:    {[_group,_actualTarget,_arg] call NWG_fnc_acSendMortarStrike};
        case SPECIAL_VEHDEMOLITION:  {[_group,_actualTarget] call NWG_fnc_acSendToVehDemolition};
        case SPECIAL_INFSTORM:       {[_group,_actualTarget] call NWG_fnc_acSendToInfBuildingStorm};
        default {false};
    };
    if (isNil "_ok" || {_ok isNotEqualTo true}) then {
        format ["NWG_YK_SPEC_UseSpecial: Failed to use special '%1'. Result:%3",_special,_ok] call NWG_fnc_logError;
    };
};

//======================================================================================================
//======================================================================================================
//Statistics
NWG_YK_STAT_statistics = createHashMap;
NWG_YK_STAT_statisticsKeys = [
    STAT_ENABLED_AT,STAT_DISABLED_AT,STAT_TIME_WORKING,
    STAT_GROUPS_ON_ENABLE,STAT_UNITS_ON_ENABLE,
    STAT_GROUPS_ON_DISABLE,STAT_UNITS_ON_DISABLE,
    STAT_KILL_COUNT,STAT_REACTION_COUNT,
    STAT_TARGETS_ACQUIRED,STAT_TARGETS_IGNORED,
    STAT_GROUPS_MOVED,STAT_REINFS_SENT,STAT_SPECIALS_USED,
    STAT_SPEC_AIRSTRIKE,STAT_SPEC_ARTA,STAT_SPEC_MORTAR,STAT_SPEC_VEHDEMOLITION,STAT_SPEC_INFSTORM,STAT_SPEC_VEHREPAIR
];
NWG_YK_STAT_GetCurCounters = {
    private _curTime = round ((round time)/60);//Time in minutes
    private _groups  = groups (NWG_YK_Settings get "KING_SIDE");
    private _groupsCount = count _groups;
    private _unitsCount = 0;
    {_unitsCount = _unitsCount + ({alive _x} count (units _x))} forEach _groups;
    [_curTime,_groupsCount,_unitsCount]
};
NWG_YK_STAT_OnEnable = {
    if !(NWG_YK_Settings get "STATISTICS_ENABLED") exitWith {};

    //(Re)Fill initial values
    {NWG_YK_STAT_statistics set [_x,0]} forEach NWG_YK_STAT_statisticsKeys;

    //Fill values we start with
    (call NWG_YK_STAT_GetCurCounters) params ["_startTime","_groupsCount","_unitsCount"];
    [STAT_ENABLED_AT,_startTime] call NWG_YK_STAT_Set;
    [STAT_GROUPS_ON_ENABLE,_groupsCount] call NWG_YK_STAT_Set;
    [STAT_UNITS_ON_ENABLE,_unitsCount] call NWG_YK_STAT_Set;
};
NWG_YK_STAT_OnDisable = {
    if !(NWG_YK_Settings get "STATISTICS_ENABLED") exitWith {};

    //Fill values we end with
    (call NWG_YK_STAT_GetCurCounters) params ["_endTime","_groupsCount","_unitsCount"];
    [STAT_KILL_COUNT,NWG_YK_killCountTotal] call NWG_YK_STAT_Set;
    [STAT_DISABLED_AT,_endTime] call NWG_YK_STAT_Set;
    [STAT_TIME_WORKING,(_endTime - (NWG_YK_STAT_statistics get STAT_ENABLED_AT))] call NWG_YK_STAT_Set;
    [STAT_GROUPS_ON_DISABLE,_groupsCount] call NWG_YK_STAT_Set;
    [STAT_UNITS_ON_DISABLE,_unitsCount] call NWG_YK_STAT_Set;

    //Output
    call NWG_YK_STAT_Output;

    //We do not clear the statistics in case we will want to check it via console between the missions
};
NWG_YK_STAT_Set = {
    params ["_key","_value"];
    if !(NWG_YK_Settings get "STATISTICS_ENABLED") exitWith {};
    NWG_YK_STAT_statistics set [_key,_value];
};
NWG_YK_STAT_Increment = {
    params ["_key","_value"];
    if !(NWG_YK_Settings get "STATISTICS_ENABLED") exitWith {};
    private _curValue = NWG_YK_STAT_statistics getOrDefault [_key,0];
    NWG_YK_STAT_statistics set [_key,(_curValue + _value)];
};

NWG_YK_STAT_Output = {
    private _stat = NWG_YK_STAT_statistics;
    private _lines = [
        "Yellow King Statistics:",
        (format ["TIME  : Enabled at: '%1' | Disabled at: '%2' | Worked for: '%3' minutes",(_stat get STAT_ENABLED_AT),(_stat get STAT_DISABLED_AT),(_stat get STAT_TIME_WORKING)]),
        (format ["ON ENABLE:  Groups: '%1' | Units: '%2'",(_stat get STAT_GROUPS_ON_ENABLE),(_stat get STAT_UNITS_ON_ENABLE)]),
        (format ["ON DISABLE: Groups: '%1' | Units: '%2'",(_stat get STAT_GROUPS_ON_DISABLE),(_stat get STAT_UNITS_ON_DISABLE)]),
        (format ["KILLCOUNT: %1",(_stat get STAT_KILL_COUNT)]),
        (format ["REACTIONS: %1",(_stat get STAT_REACTION_COUNT)]),
        (format ["TARGETS: Acquired: %1    | Ignored: %2",(_stat get STAT_TARGETS_ACQUIRED),(_stat get STAT_TARGETS_IGNORED)]),
        (format ["GROUPS MOVED: %1",(_stat get STAT_GROUPS_MOVED)]),
        (format ["REINFORCEMENTS SENT: %1",(_stat get STAT_REINFS_SENT)]),
        (format ["SPECIALS USED: %1",(_stat get STAT_SPECIALS_USED)]),
        "COUNT PER SPECIAL:"
    ];
    if (NWG_YK_Settings get "SPECIAL_AIRSTRIKE_ENABLED") then {_lines pushBack (format ["AIRSTRIKE: %1",(_stat get STAT_SPEC_AIRSTRIKE)])};
    if (NWG_YK_Settings get "SPECIAL_ARTA_ENABLED")      then {_lines pushBack (format ["ARTA: %1",(_stat get STAT_SPEC_ARTA)])};
    if (NWG_YK_Settings get "SPECIAL_MORTAR_ENABLED")    then {_lines pushBack (format ["MORTAR: %1",(_stat get STAT_SPEC_MORTAR)])};
    if (NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_ENABLED") then {_lines pushBack (format ["VEHDEMOLITION: %1",(_stat get STAT_SPEC_VEHDEMOLITION)])};
    if (NWG_YK_Settings get "SPECIAL_INFSTORM_ENABLED")  then {_lines pushBack (format ["INFSTORM: %1",(_stat get STAT_SPEC_INFSTORM)])};
    if (NWG_YK_Settings get "SPECIAL_VEHREPAIR_ENABLED") then {_lines pushBack (format ["VEHREPAIR: %1",(_stat get STAT_SPEC_VEHREPAIR)])};

    if (NWG_YK_Settings get "STATISTICS_TO_RPT") then {
        diag_log text "==========[ YELLOW KING STATS ]===========";
        {diag_log (text _x)} forEach _lines;
        diag_log text "==========[        END        ]===========";
    };

    if (NWG_YK_Settings get "STATISTICS_TO_PROFILENAMESPACE") then {
        profileNamespace setVariable ["NWG_YK_STATISTICS",_lines];
        saveProfileNamespace;//Adds a lag
    };
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;