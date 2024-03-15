#include "..\..\globalDefines.h"
#include "yellowKingDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_YK_Settings = createHashMapFromArray [
    ["ENABLED",true],//Defines wether or not the entire system is enabled
    ["KING_SIDE",west],//The side which kills will count and groups/reinforcements used, basically the side YK is plays for
    ["REACTION_TIME",[60,120]],//Min and max time between actions and reactions (will be defined randomly between the two)
    ["REACTION_IMMEDIATE_ON_KILLCOUNT",25],//Number of kills to immediately react to (skips all the wait remaining)
    ["REACT_TO_PLAYERS_ONLY",false],//Should we handle kills made by players only or include enemy AI units as well

    ["DEFAULT_REINF_FACTION","NATO"],//The default faction to use for reinforcements if no faction saved to state holder
    ["SHOW_DEBUG_MESSAGES",true],//Show debug messages in systemChat

    ["HUNT_ALARM",true],//Should we alarm hunters when a kill happens
    ["HUNT_ALARM_RADIUS",1000],//The radius in which hunters will be alarmed
    ["HUNT_MERGE_LONERS",true],//Should we merge loner groups into bigger ones
    ["HUNT_RADIUS",500],//Radius at which hunters will be sent to attack the target

    ["SPECIAL_AIRSTRIKE_ENABLED",true],//Is airstrike allowed
    ["SPECIAL_ARTA_ENABLED",true],//Is artillery strike allowed
    ["SPECIAL_MORTAR_ENABLED",true],//Is mortar strike allowed
    ["SPECIAL_VEHDEMOLITION_ENABLED",true],//Is vehicle demolition allowed
    ["SPECIAL_INFSTORM_ENABLED",true],//Is infantry building storm allowed
    ["SPECIAL_VEHREPAIR_ENABLED",true],//Is vehicle repair allowed

    ["SPECIAL_VEHDEMOLITION_RADIUS",500],//Radius at which groups will be sent to do vehdemolition
    ["SPECIAL_INFSTORM_RADIUS",500],//Radius at which groups will be sent to do infstorm

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Init
private _Init = {
    //Be the first system to react to something being killed
    [EVENT_ON_OBJECT_KILLED,{_this call NWG_YK_OnKilled},/*_setFirst:*/true] call NWG_fnc_subscribeToServerEvent;

    //Shift the difficulty curve
    NWG_YK_difficultyCurve call NWG_fnc_arrayRandomShift;

    //Check if we're in production - disable debug messages
    if !(is3DENPreview || {is3DENMultiplayer}) then {
        NWG_YK_Settings set ["SHOW_DEBUG_MESSAGES",false];
    };
};

//======================================================================================================
//======================================================================================================
//Enabling/Disabling

NWG_YK_Enable = {NWG_YK_Settings set ["ENABLED",true]};
NWG_YK_Disable = {NWG_YK_Settings set ["ENABLED",false]};

//======================================================================================================
//======================================================================================================
//Reaction system
NWG_YK_killsToCount = [OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT];
NWG_YK_killCount = 0;
NWG_YK_OnKilled = {
    params ["_object","_objType","_actualKiller","_isPlayerKiller"];

    //Check
    if !(NWG_YK_Settings get "ENABLED") exitWith {};//System is disabled
    if (isNull _object || {isNull _actualKiller || {!alive _actualKiller}}) exitWith {};//Unprocessable kill
    if (!(_objType in NWG_YK_killsToCount)) exitWith {};//Not a kill of interest
    if (!_isPlayerKiller && {(NWG_YK_Settings get "REACT_TO_PLAYERS_ONLY")}) exitWith {};//If we only want to react to player kills

    private _objGroup = if (_objType isEqualTo OBJ_TYPE_UNIT) then {group _object} else {assignedGroup _object};
    if (isNull _objGroup || {(side _objGroup) isNotEqualTo (NWG_YK_Settings get "KING_SIDE")}) exitWith {};//Not a kill of interest
    if ((side (group _actualKiller)) isEqualTo (NWG_YK_Settings get "KING_SIDE")) exitWith {};//Friendly fire. TODO: Add traitors punishment?

    //Setup reaction
    NWG_YK_killCount = NWG_YK_killCount + 1;
    NWG_YK_reactList pushBackUnique _actualKiller;
    if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGES") then {systemChat (format ["NWG_YK: %1 killed %2",(name _actualKiller),(name _object)])};
    if (isNull NWG_YK_reactHandle || {scriptDone NWG_YK_reactHandle}) then {
        NWG_YK_reactTime = time + ((NWG_YK_Settings get "REACTION_TIME") call NWG_fnc_randomRangeInt);
        NWG_YK_reactHandle = [] spawn NWG_YK_React;
    };
};

NWG_YK_reactList = [];
NWG_YK_reactTime = 0;
NWG_YK_reactHandle = scriptNull;
NWG_YK_React = {
    //0. Wait for the reaction time to pass or the kill count to reach the immediate reaction limit
    waitUntil {
        sleep 1;
        (time >= NWG_YK_reactTime || {NWG_YK_killCount > (NWG_YK_Settings get "REACTION_IMMEDIATE_ON_KILLCOUNT")})
    };
    private _onExit = {
        NWG_YK_reactList resize 0;
        NWG_YK_reactTime = 0;
        NWG_YK_killCount = 0;
    };

    //1. Check if we have any targets to react to
    if ((NWG_YK_reactList findIf {alive _x}) == -1) exitWith _onExit;//No targets to react to

    //2. Get difficulty settings
    (call NWG_YK_GetDifficulty) params ["_ingoreChance","_movesLeft","_reinfsLeft","_speciaslLeft"];

    //3. Gather targets
    private _targets = [NWG_YK_reactList,_ingoreChance] call NWG_YK_ConvertToTargets;
    if ((count _targets) == 0) exitWith _onExit;//No targets to react to

    //4. Gather hunters
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

    //5. Process the targets
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
            if (_i == -1) exitWith {};//Couldn't find a hunter to move
            _dice pushBack [DICE_MOVE,_i];
        };
        if (_reinfsLeft > 0) then {
            _dice pushBack [DICE_REINF];
        };
        if (_speciaslLeft > 0) then {
            private _specials = [_hunters,_x] call NWG_YK_SPEC_SelectSpecialsForTarget;//Notice that we pass the entire target record
            if ((count _specials) == 0) exitWith {};//No specials to use
            _dice pushBack [DICE_SPEC,_specials];
        };
        if (_dice isEqualTo []) then {continue};//There is nothing we can do.. | Napoleon Meme

        //Roll the dice (Need for Speed IV Soundtrack - Roll The Dice) https://www.youtube.com/watch?v=ZgmQK1wVPzg
        (selectRandom _dice) params ["_diceType","_diceArg"];

        //Act
        switch (_diceType) do {
            case DICE_MOVE : {[_hunters,_diceArg,_targetPos] call NWG_YK_HUNT_MoveHunter;     _movesLeft    = _movesLeft - 1};
            case DICE_REINF: {[_targetType,_targetPos] call NWG_YK_REINF_SendReinforcements;  _reinfsLeft   = _reinfsLeft - 1};
            case DICE_SPEC : {[_hunters,(selectRandom _diceArg)] call NWG_YK_SPEC_UseSpecial; _speciaslLeft = _speciaslLeft - 1};
        };
    } forEach _targets;

    //6. Reset
    call _onExit;
};

//======================================================================================================
//======================================================================================================
//Difficulty settings
NWG_YK_difficultyCurve = [0,1,0,1,2,1,2,0,1,1,2,0,1,2,2,1,0];//Compiled with the help of chatGPT
NWG_YK_difficultySettings = [
/*Easy*/
    [/*_ingoreChance*/0.4, /*_maxMoves*/2, /*_maxReinfs*/0, /*_maxSpecials*/1],
/*Medium*/
    [/*_ingoreChance*/0.3, /*_maxMoves*/3, /*_maxReinfs*/1, /*_maxSpecials*/2],
/*Hard*/
    [/*_ingoreChance*/0.2, /*_maxMoves*/4, /*_maxReinfs*/2, /*_maxSpecials*/3]
];
NWG_YK_GetDifficulty = {
    private _i = NWG_YK_difficultyCurve deleteAt 0;
    NWG_YK_difficultyCurve pushBack _i;
    //return
    (NWG_YK_difficultySettings select _i)
};

//======================================================================================================
//======================================================================================================
//Targets logic
NWG_YK_ConvertToTargets = {
    params ["_units","_ignoreChance"];
    _units = _units select {alive _x && {(random 1) >= _ignoreChance}};
    if ((count _units) == 0) exitWith {[]};

    private _targets = _units apply {vehicle _x};//Convert to vehicles
    _targets = _targets arrayIntersect _targets;//Remove duplicates

    private ["_type","_position","_building"];
    _targets = _targets apply {
        _type = _x call NWG_YK_GetTargetType;
        _position = getPosASL _x;
        _building = if (_type isEqualTo TARGET_TYPE_INF) then {_x call NWG_YK_GetBuildingTargetIn} else {objNull};
        [_x,_type,_position,_building]
    };

    //return
    _targets
};

/*Utils*/
NWG_YK_GetTargetType = {
    // private _target = _this;
    switch (true) do {
        case (_this isKindOf "Man"): {TARGET_TYPE_INF};
        case (_this isKindOf "StaticWeapon"): {TARGET_TYPE_INF};//Static weapons are not actually infantry, but they are not vehicles either
        case (_this isKindOf "Air"): {
            if (_this isKindOf "ParachuteBase")/*Parachutes give false positives for "Air"*/
                then {TARGET_TYPE_INF}
                else {TARGET_TYPE_AIR}
        };
        case (_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}) : {TARGET_TYPE_ARM};
        case (_this isKindOf "Ship"): {TARGET_TYPE_BOAT};
        default {TARGET_TYPE_VEH};
    }
};

NWG_YK_GetBuildingTargetIn = {
    // private _target = _this;
    private _raycastFrom = getPosWorld _this;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _result = (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_this,objNull,true,-1,"FIRE","VIEW",true]));
    _result = _result select {_x isEqualType objNull && {!isNull _x && {_x call NWG_fnc_ocIsBuilding}}};
    _result param [0,objNull]
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
    private _faction = BST_ENEMY_FACTION call NWG_fnc_shGetState;
    if (isNil "_faction") then {_faction = NWG_YK_Settings get "DEFAULT_REINF_FACTION"};
    private _filter = switch (_targetType) do {
        case TARGET_TYPE_ARM: {[["AT"],[],[]]};//Whitelist AT groups
        case TARGET_TYPE_AIR: {[["AA"],[],[]]};//Whitelist AA groups
        default {[]};//No filter
    };
    private _side = NWG_YK_Settings get "KING_SIDE";
    private _reinfMap = BST_REINFMAP call NWG_fnc_shGetState;
    if (isNil "_reinfMap") then {_reinfMap = []};
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
//Init
call _Init;