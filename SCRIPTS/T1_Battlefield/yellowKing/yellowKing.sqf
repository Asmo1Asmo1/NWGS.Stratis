#include "..\..\globalDefines.h"
#include "yellowKingDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_YK_Settings = createHashMapFromArray [
    /*Main settings*/
    ["ENABLE_ON_START",false],//Defines wether or not the entire system is enabled on mission start
    ["KING_SIDE",west],//The side which kills will count and groups/reinforcements used, basically the side YK is plays for
    ["REACT_TO_TYPES_KILLED",[OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT]],//Types of objects to react to
    ["REACT_TO_PLAYERS_ONLY",false],//Should we handle kills made by players only or include enemy AI units as well
    ["SHOW_DEBUG_MESSAGES",true],//Show debug messages in systemChat (is auto disabled in non-dev environments)

    /*Groups moving*/
    ["HUNT_INF_MOVE_RADIUS",1000],//Radius at which hunters will be sent to attack the target
    ["HUNT_VEH_MOVE_RADIUS",3000],//Radius at which hunters will be sent to attack the target
    ["HUNT_AIR_MOVE_RADIUS",100000],//Radius at which hunters will be sent to attack the target
    ["HUNT_BOAT_MOVE_RADIUS",100000],//Radius at which hunters will be sent to attack the target

    /*Active specials*/
    ["SPECIAL_AIRSTRIKE_ENABLED",true],//Is airstrike allowed
    ["SPECIAL_AIRSTRIKE_RADIUS",100000],//Radius at which groups will be sent to do airstrike
    ["SPECIAL_ARTA_ENABLED",true],//Is artillery strike allowed
    ["SPECIAL_ARTA_RADIUS",100000],//Radius at which groups will be ordered to do artillery strike
    ["SPECIAL_VEHDEMOLITION_ENABLED",true],//Is vehicle demolition allowed
    ["SPECIAL_VEHDEMOLITION_RADIUS",500],//Radius at which groups will be sent to do vehdemolition
    ["SPECIAL_INFSTORM_ENABLED",true],//Is infantry building storm allowed
    ["SPECIAL_INFSTORM_RADIUS",500],//Radius at which groups will be sent to do infstorm

    /*Passive specials*/
    ["SPECIAL_ALARMING_ENABLED",true],//Is alarming of nearby hunters allowed
    ["SPECIAL_ALARMING_RADIUS",500],//Radius at which groups will be alarmed
    ["SPECIAL_VEHREPAIR_ENABLED",true],//Is vehicle repair allowed
    ["SPECIAL_LONEMERGE_ENABLED",true],//Is lone group merge allowed
    ["SPECIAL_VEHCAPTURE_ENABLED",true],//Is vehicle capture allowed
    ["SPECIAL_VEHFLEE_ENABLED",true],//Is vehicle flee allowed

    /*Statistics*/
    ["STATISTICS_ENABLED",true],//If true, the system will keep track of statistics and output them to the RPT log
    ["STATISTICS_ADVANCED_COMBAT",true],//If true, additional statistics will be outputted for advanced combat (must be enabled on advanced combat side as well)

    /*Reaction*/
    ["REACTION_COOLDOWN",[60,90]],//Min and max time before the next reaction can be started  (will be defined randomly between the two)
    ["REACTION_TIME",[10,60]],//Min and max time between actions and reactions (will be defined randomly between the two)
    ["REACTION_IMMEDIATE_ON_KILLCOUNT",10],//Number of kills to immediately react to (skips remaining reaction time, but not cooldown)

    /*Difficulty curve*/
    ["DIFFICULTY_CURVE",[0,1,0,1,2,1,2,0,1,1,2,0,1,2,2,1,0]],//Yellow King difficulty curve
    ["DIFFUCULTY_PRESETS",[
        /*Easy*/
            [/*_minReact*/1, /*_maxIgnores*/1, /*_maxMoves*/2, /*_maxReinfs*/0, /*_maxSpecials*/1],
        /*Medium*/
            [/*_minReact*/2, /*_maxIgnores*/1, /*_maxMoves*/3, /*_maxReinfs*/1, /*_maxSpecials*/2],
        /*Hard*/
            [/*_minReact*/3, /*_maxIgnores*/0, /*_maxMoves*/4, /*_maxReinfs*/2, /*_maxSpecials*/3]
    ]],//YellowKing difficulty presets

    /*Berserk mode*/
    ["BERSEK_MODE_COOLDOWN",90],//Mandatory cooldown before next berserk round can start (stacks with the difficulty cooldown)

    /*Dice weights*/
    ["DICE_WEIGHTS",createHashMapFromArray [
        [DICE_IGNORE,       3],
        [DICE_MOVE,         3],
        [DICE_REINF,        4],
        [SPECIAL_AIRSTRIKE, 6],
        [SPECIAL_ARTA,      6],
        [SPECIAL_VEHDEM,    6],
        [SPECIAL_INFSTORM,  6]
    ]],

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Fields
/* main flag */
NWG_YK_Enabled = false;
/* berserk mode */
NWG_YK_BerserkMode = false;
NWG_YK_BerserkSelectBy = {true};
/* counters */
NWG_YK_killCount = 0;
NWG_YK_killCountTotal = 0;
/* difficulty */
NWG_YK_difficultyCurve = [];

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
    true
};
NWG_YK_Disable = {
    if !(NWG_YK_Enabled) exitWith {false};//Already disabled
    if (!isNull NWG_YK_reactHandle || {!scriptDone NWG_YK_reactHandle})
        then {terminate NWG_YK_reactHandle};//Terminate the reaction script
    call NWG_YK_STAT_OnDisable;//Statistics
    NWG_YK_BerserkMode = false;//Disable berserk mode
    NWG_YK_BerserkSelectBy = {true};//Drop the selectBy predicate
    NWG_YK_Enabled = false;
    true
};
NWG_YK_Configure = {
    params ["_kingSide"];
    if !(isNil "_kingSide") then {NWG_YK_Settings set ["KING_SIDE",_kingSide]};
};

//======================================================================================================
//======================================================================================================
//Berserk mode
NWG_YK_GoBerserk = {
    params [["_selectBy",{true}]];
    if !(NWG_YK_Enabled) exitWith {
        "NWG_YK_GoBerserk: YK is disabled" call NWG_fnc_logError;
        false
    };
    if (NWG_YK_BerserkMode) exitWith {
        "NWG_YK_GoBerserk: Berserk mode is already active" call NWG_fnc_logError;
        false
    };

    NWG_YK_BerserkMode = true;
    NWG_YK_BerserkSelectBy = _selectBy;
    if (!isNull NWG_YK_reactHandle || {!scriptDone NWG_YK_reactHandle})
        then {terminate NWG_YK_reactHandle};//Terminate the current reaction script
    [] spawn NWG_YK_BerserkReload;//Start chain reaction
    true
};
NWG_YK_BerserkReload = {
    sleep (NWG_YK_Settings get "BERSEK_MODE_COOLDOWN");//Mandatory cooldown
    if (!NWG_YK_Enabled || !NWG_YK_BerserkMode) exitWith {};//YK was disabled while we were waiting

    //Setup reaction
    {
        NWG_YK_reactList pushBackUnique _x;//Unique because we keep filling it with players who do damage in 'NWG_YK_OnKilled'
    } forEach ((call NWG_fnc_getPlayersAll) select NWG_YK_BerserkSelectBy);
    NWG_YK_reactTime = time + ((NWG_YK_Settings get "REACTION_TIME") call NWG_fnc_randomRangeInt);
    NWG_YK_reactHandle = [] spawn NWG_YK_React;
};

//======================================================================================================
//======================================================================================================
//Difficulty settings
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
//Reaction system
NWG_YK_OnKilled = {
    params ["_object","_objType","_actualKiller","_isPlayerKiller"];

    //Checks
    if !(NWG_YK_Enabled) exitWith {};//System is disabled
    if (isNull _object || {isNull _actualKiller || {!alive _actualKiller}}) exitWith {};//Unprocessable kill
    if (!(_objType in (NWG_YK_Settings get "REACT_TO_TYPES_KILLED"))) exitWith {};//Not a kill of interest
    if (!_isPlayerKiller && {(NWG_YK_Settings get "REACT_TO_PLAYERS_ONLY")}) exitWith {};//If we only want to react to player kills

    private _objGroup = if (_objType isEqualTo OBJ_TYPE_UNIT) then {group _object} else {assignedGroup _object};
    if (isNull _objGroup || {(side _objGroup) isNotEqualTo (NWG_YK_Settings get "KING_SIDE")}) exitWith {};//Not a kill of interest
    if ((side (group _actualKiller)) isEqualTo (NWG_YK_Settings get "KING_SIDE")) exitWith {};//Friendly fire. TODO: Add traitors punishment?

    //Record the kill
    NWG_YK_killCount = NWG_YK_killCount + 1;
    NWG_YK_killCountTotal = NWG_YK_killCountTotal + 1;
    if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGES") then {systemChat (format ["NWG_YK: %1 killed %2",(name _actualKiller),(name _object)])};

    //Setup reaction
    NWG_YK_reactList pushBackUnique _actualKiller;
    if (NWG_YK_BerserkMode) exitWith {};//System is in berserk mode - no further action needed
    if (isNull NWG_YK_reactHandle || {scriptDone NWG_YK_reactHandle}) then {
        NWG_YK_reactTime = time + ((NWG_YK_Settings get "REACTION_TIME") call NWG_fnc_randomRangeInt);
        NWG_YK_reactHandle = [] spawn NWG_YK_React;
    };
};

NWG_YK_cooldownTime = 0;
NWG_YK_reactList = [];
NWG_YK_reactTime = 0;
NWG_YK_reactHandle = scriptNull;
NWG_YK_React = {
    //0. Wait
    /*Mandatory cooldown*/
    waitUntil {
        sleep 1;
        time >= NWG_YK_cooldownTime
    };
    NWG_YK_cooldownTime = time + ((NWG_YK_Settings get "REACTION_COOLDOWN") call NWG_fnc_randomRangeInt);//Set next cooldown time
    /*Reaction time*/
    waitUntil {
        sleep 1;
        (time >= NWG_YK_reactTime || {NWG_YK_killCount > (NWG_YK_Settings get "REACTION_IMMEDIATE_ON_KILLCOUNT")})
    };
    private _onExit = {
        NWG_YK_reactList resize 0;
        NWG_YK_killCount = 0;
        if (NWG_YK_BerserkMode) then {[] spawn NWG_YK_BerserkReload};//Go at it again
    };
    /*Statistics and status*/
    [STAT_REACTION_COUNT,1] call NWG_YK_STAT_Increment;

    //1. Get raw targets to react to
    private _targets = NWG_YK_reactList select {alive _x};
    if ((count _targets) == 0) exitWith _onExit;//No targets to react to

    //2. Get difficulty settings
    (call NWG_YK_GetDifficultyPreset) params ["_minReact","_ignoresLeft","_movesLeft","_reinfsLeft","_speciaslLeft"];
    if (NWG_YK_BerserkMode) then {_reinfsLeft = 0};//Berserk mode - no reinforcements
    private _isMoveDistanceRestrictions = !NWG_YK_BerserkMode;//Distance restrictions apply only in normal mode

    //3. Process and convert the targets
    /*Apply min reaction count*/
    if ((count _targets) < _minReact) then {
        while {(count _targets) < _minReact} do {_targets append _targets};
        _targets resize _minReact;
    };
    /*Convert to target data*/
    _targets = _targets call NWG_YK_ConvertToTargetData;
    if ((count _targets) == 0) exitWith _onExit;//No targets to react to
    /*Statistics*/
    [STAT_TARGETS_ACQUIRED,(count _targets)] call NWG_YK_STAT_Increment;

    //4. Gather the hunters
    private _hunters = call NWG_YK_GetHuntersData;

    //5. Run passive specials (will decrement the hunters array by moving them to repair or merge with another group)
    _hunters = [_hunters,_targets] call NWG_YK_RunPassiveSpecials;

    //6. Bring in the action
    //forEach target
    {
        //Fill the dice
        private _dice = [_x,_hunters,(_ignoresLeft > 0),(_movesLeft > 0),_isMoveDistanceRestrictions,(_reinfsLeft > 0),(_speciaslLeft > 0)] call NWG_YK_FillDice;
        if ((count _dice) == 0) then {continue};//There is nothing we can do.. | Napoleon Meme

        //Roll the dice (Need for Speed IV Soundtrack - Roll The Dice) https://www.youtube.com/watch?v=ZgmQK1wVPzg
        _dice = _dice call NWG_fnc_arrayShuffle;
        (selectRandom _dice) params ["_diceRoll","_hunterIndex","_addArg"];

        //Act accordingly
        switch (_diceRoll) do {
            case DICE_IGNORE: {
                _ignoresLeft = _ignoresLeft - 1;
                [STAT_TARGETS_IGNORED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case DICE_MOVE : {
                _movesLeft = _movesLeft - 1;
                [(_hunters deleteAt _hunterIndex),_x] call NWG_YK_MoveHunterTo;
                [STAT_GROUPS_MOVED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case DICE_REINF: {
                _reinfsLeft = _reinfsLeft - 1;
                _x call NWG_YK_SendReinforcements;
                [STAT_REINFS_SENT,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case SPECIAL_AIRSTRIKE: {
                _speciaslLeft = _speciaslLeft - 1;
                [(_hunters deleteAt _hunterIndex),_x,SPECIAL_AIRSTRIKE,_addArg] call NWG_YK_UseSpecial;
                [STAT_SPEC_AIRSTRIKE,1] call NWG_YK_STAT_Increment;/*Statistics*/
                [STAT_SPECIALS_USED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case SPECIAL_ARTA: {
                _speciaslLeft = _speciaslLeft - 1;
                [(_hunters deleteAt _hunterIndex),_x,SPECIAL_ARTA,_addArg] call NWG_YK_UseSpecial;
                [STAT_SPEC_ARTA,1] call NWG_YK_STAT_Increment;/*Statistics*/
                [STAT_SPECIALS_USED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case SPECIAL_VEHDEM: {
                _speciaslLeft = _speciaslLeft - 1;
                [(_hunters deleteAt _hunterIndex),_x,SPECIAL_VEHDEM,_addArg] call NWG_YK_UseSpecial;
                [STAT_SPEC_VEHDEM,1] call NWG_YK_STAT_Increment;/*Statistics*/
                [STAT_SPECIALS_USED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            case SPECIAL_INFSTORM: {
                _speciaslLeft = _speciaslLeft - 1;
                [(_hunters deleteAt _hunterIndex),_x,SPECIAL_INFSTORM,_addArg] call NWG_YK_UseSpecial;
                [STAT_SPEC_INFSTORM,1] call NWG_YK_STAT_Increment;/*Statistics*/
                [STAT_SPECIALS_USED,1] call NWG_YK_STAT_Increment;/*Statistics*/
            };
            default {
                (format ["NWG_YK_React: Unknown dice roll: '%1'",_diceRoll]) call NWG_fnc_logError;
            };
        };
    } forEach _targets;

    //7. Reset
    call _onExit;
};

//======================================================================================================
//======================================================================================================
//Targets acquisition
NWG_YK_ConvertToTargetData = {
    // private _targets = _this;
    ((_this apply {vehicle _x}) select {alive _x}) apply {
        switch (_x call NWG_fnc_acGetTargetType) do {
            case "INF": {
                //Infantry - Check if inside a building
                private _bldg = _x call NWG_fnc_acGetBuildingTargetIn;
                if (!isNull _bldg)
                    then {[TARGET_TYPE_BLDG,_bldg,(getPosASL _bldg)]}
                    else {[TARGET_TYPE_INF,_x,(getPosASL _x)]}
            };
            case "VEH": {
                //Vehicle
                [TARGET_TYPE_VEH,_x,(getPosASL _x)]
            };
            case "ARM": {
                //Armoured vehicle
                [TARGET_TYPE_ARM,_x,(getPosASL _x)]
            };
            case "AIR": {
                //Aircraft - Check if grounded
                if (((getPos _x)#2) > 5)
                    then {[TARGET_TYPE_AIR_FLY,_x,(getPosASL _x)]}
                    else {[TARGET_TYPE_AIR_GND,_x,(getPosASL _x)]}
            };
            case "BOAT": {
                //Boat
                [TARGET_TYPE_BOAT,_x,(getPosASL _x)]
            };
            default {
                format ["NWG_YK_ConvertToTargetData: Unknown target type: %1",(_x call NWG_fnc_acGetTargetType)] call NWG_fnc_logError;
                [TARGET_TYPE_VEH,_x,(getPosASL _x)]
            };
        }
    }
};

//======================================================================================================
//======================================================================================================
//Hunters acquisition
NWG_YK_GetHuntersData = {
    //Get raw groups of YK side
    private _groups = (groups (NWG_YK_Settings get "KING_SIDE")) select {
        !isNull _x && {
        alive (leader _x) && {
        ((units _x) findIf {isPlayer _x}) == -1 && {
        !(_x call NWG_fnc_acIsGroupBusy)}}}
    };
    if ((count _groups) == 0) exitWith {[]};
    _groups = _groups call NWG_fnc_arrayShuffle;

    //Convert to data records [_type,_special,_group,_position]
    private ["_parent","_tags"];
    _groups apply {
        _parent = _x call NWG_YK_GetGroupParent;
        _tags = if (_parent isEqualTo PARENT_DSPAWN) then {_x call NWG_fnc_dsGetTags} else {[]};
        [
            /*HUNTER_TYPE:*/([_x,_parent,_tags] call NWG_YK_GetGroupType),
            /*HUNTER_SPECIAL:*/([_x,_parent,_tags] call NWG_YK_GetGroupSpecial),
            /*HUNTER_GROUP:*/_x,
            /*HUNTER_POSITION:*/(getPosASL (vehicle (leader _x)))
        ]
    }
};

NWG_YK_GetGroupParent = {
    // private _group = _this;
    if (_this call NWG_fnc_dsIsDspawnGroup) exitWith {PARENT_DSPAWN};
    if (_this call NWG_fnc_ukrpIsUkrepGroup) exitWith {PARENT_UKREP};

    //else - adopt the group and return dspawn (to support zeus and editor added groups)
    _this call NWG_fnc_dsAdoptGroup;
    PARENT_DSPAWN
};

NWG_YK_GetGroupType = {
    params ["_group","_parent","_tags"];

    if (_parent isEqualTo PARENT_DSPAWN) exitWith {
        private _anti = 0;
        if ("AA" in _tags) then {_anti = _anti + 1};
        if ("AT" in _tags) then {_anti = _anti + 2};

        if ("INF" in _tags) exitWith {
            switch (_anti) do {
                case 1: {HUNTER_TYPE_INF_AA};
                case 2: {HUNTER_TYPE_INF_AT};
                case 3: {HUNTER_TYPE_INF_AAAT};
                default {HUNTER_TYPE_INF_AP};
            }
        };
        if ("VEH" in _tags || {"ARM" in _tags}) exitWith {
            switch (_anti) do {
                case 1: {HUNTER_TYPE_VEH_AA};
                case 2: {HUNTER_TYPE_VEH_AT};
                case 3: {HUNTER_TYPE_VEH_AAAT};
                default {HUNTER_TYPE_VEH_AP};
            }
        };
        if ("AIR" in _tags) exitWith {
            switch (_anti) do {
                case 1: {HUNTER_TYPE_AIR_AA};
                case 2: {HUNTER_TYPE_AIR_AT};
                case 3: {HUNTER_TYPE_AIR_AAAT};
                default {HUNTER_TYPE_AIR_AP};
            }
        };
        if ("BOAT" in _tags) exitWith {HUNTER_TYPE_BOAT};

        (format ["NWG_YK_GetGroupType: Unknown set of dspawn tags: '%1'",_tags]) call NWG_fnc_logError;
        HUNTER_TYPE_UNDEF
    };

    if (_parent isEqualTo PARENT_UKREP) exitWith {
        HUNTER_TYPE_UKREP
    };

    (format ["NWG_YK_GetGroupType: Unknown parent: '%1'",_parent]) call NWG_fnc_logError;
    HUNTER_TYPE_UNDEF
};

NWG_YK_GetGroupSpecial = {
    params ["_group","_parent","_tags"];

    if (_parent isEqualTo PARENT_DSPAWN) exitWith {
        /*Infantry specials*/
        if ("INF" in _tags) exitWith {
            if (({alive _x} count (units _group)) == 1) exitWith {SPECIAL_LONEMERGE};//Single unit - prioritize lonemerge
            if (_group call NWG_fnc_acCanDoInfVehCapture) exitWith {SPECIAL_VEHCAPTURE};//Group near vehicle - prioritize veh capture
            if (_group call NWG_fnc_acCanDoInfBuildingStorm) exitWith {SPECIAL_INFSTORM};//Any other inf special
            SPECIAL_NONE
        };

        /*Ground vehicle specials*/
        if ("VEH" in _tags || {"ARM" in _tags}) exitWith {
            if (_group call NWG_fnc_acCanDoVehRepair) exitWith {SPECIAL_VEHREPAIR};//Vehicle needs repair - prioritize veh repair
            if ("ARTA" in _tags && {_group call NWG_fnc_acCanDoArtilleryStrike}) exitWith {SPECIAL_ARTA};//Can artillery strike - prioritize arta
            if (_group call NWG_fnc_acCanDoVehFlee) exitWith {SPECIAL_VEHFLEE};//Should flee the battle - prioritize veh flee
            if (_group call NWG_fnc_acCanDoVehDemolition) exitWith {SPECIAL_VEHDEM};//Any other armed vehicle special
            SPECIAL_NONE
        };

        /*Air specials*/
        if ("AIRSTRIKE+" in _tags && {_group call NWG_fnc_acCanDoAirstrike}) exitWith {SPECIAL_AIRSTRIKE};

        SPECIAL_NONE
    };

    if (_parent isEqualTo PARENT_UKREP) exitWith {
        if (_group call NWG_fnc_acCanDoArtilleryStrike) exitWith {SPECIAL_ARTA};
        SPECIAL_NONE
    };

    (format ["NWG_YK_GetGroupSpecial: Unknown parent: '%1'",_parent]) call NWG_fnc_logError;
    SPECIAL_NONE
};

//======================================================================================================
//======================================================================================================
//Passive specials (logic that is not targeted against players and is not a part of the dice)
NWG_YK_RunPassiveSpecials = {
    params ["_hunters","_targets"];

    //Get settings
    private _alarmEnabled = NWG_YK_Settings get "SPECIAL_ALARMING_ENABLED";
    private _alarmRadius = NWG_YK_Settings get "SPECIAL_ALARMING_RADIUS";
    private _loneMergeEnabled = NWG_YK_Settings get "SPECIAL_LONEMERGE_ENABLED";
    private _vehRepairEnabled = NWG_YK_Settings get "SPECIAL_VEHREPAIR_ENABLED";
    private _vehCaptureEnabled = NWG_YK_Settings get "SPECIAL_VEHCAPTURE_ENABLED";
    private _vehFleeEnabled = NWG_YK_Settings get "SPECIAL_VEHFLEE_ENABLED";
    if (!_alarmEnabled && !_loneMergeEnabled && !_vehRepairEnabled && !_vehCaptureEnabled && !_vehFleeEnabled) exitWith {_hunters};//No passive specials enabled

    //Prepare scripts
    private _loners = [];
    private _vehRepairs = [];
    private _vehCaptures = [];
    private _vehFlees = [];
    private _alarmHunter = if (_alarmEnabled) then {{
        // private _hunterRecord = _this;
        private _hunterPos = _this select HUNTER_POSITION;
        if (_targets findIf {((_x#TARGET_POSITION) distance2D _hunterPos) <= _alarmRadius} == -1) exitWith {};
        (_this#HUNTER_GROUP) setCombatMode "RED";
        (_this#HUNTER_GROUP) setBehaviourStrong "AWARE";
    }} else {{}};
    private _extractLoner = if (_loneMergeEnabled) then {{
        // private _hunterRecord = _this;
        if ((_this#HUNTER_SPECIAL) isEqualTo SPECIAL_LONEMERGE)
            then {_loners pushBack _this; true}
            else {false}
    }} else {{false}};
    private _extractRepair = if (_vehRepairEnabled) then {{
        // private _hunterRecord = _this;
        if ((_this#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHREPAIR)
            then {_vehRepairs pushBack _this; true}
            else {false}
    }} else {{false}};
    private _extractCapture = if (_vehCaptureEnabled) then {{
        // private _hunterRecord = _this;
        if ((_this#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHCAPTURE)
            then {_vehCaptures pushBack _this; true}
            else {false}
    }} else {{false}};
    private _extractFlee = if (_vehFleeEnabled) then {{
        // private _hunterRecord = _this;
        if ((_this#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHFLEE)
            then {_vehFlees pushBack _this; true}
            else {false}
    }} else {{false}};

    //Alarm and extract groups to act upon
    {
        _x call _alarmHunter;
        if (_x call _extractLoner   || {
            _x call _extractRepair  || {
            _x call _extractCapture || {
            _x call _extractFlee}}}) then {_hunters deleteAt _forEachIndex};
    } forEachReversed _hunters;

    //Merge loners
    if ((count _loners) > 0) then {
        /*Statistics*/
        private _lonersCount = count _loners;

        /*Try merge with any other inf group*/
        private ["_lonerPos","_dist","_minDist","_closest"];
        {
            /*Find the closest inf group*/
            _lonerPos = _x#HUNTER_POSITION;
            _minDist = 100000;
            _closest = -1;
            {
                if !("INF" in (_x#HUNTER_TYPE)) then {continue};
                _dist = _lonerPos distance2D (_x#HUNTER_POSITION);
                if (_dist < _minDist) then {_minDist = _dist; _closest = _forEachIndex};
            } forEach _hunters;
            if (_closest == -1) exitWith {};//Not a single inf group found - no sense to continue

            /*Merge*/
            {[_x] joinSilent ((_hunters#_closest)#HUNTER_GROUP)} forEach (units (_x#HUNTER_GROUP));
            _loners deleteAt _forEachIndex;
        } forEachReversed _loners;

        /*Merge with each other*/
        if ((count _loners) > 1) then {
            private _adopter = _loners deleteAt 0;
            {{[_x] joinSilent (_adopter#HUNTER_GROUP)} forEach (units (_x#HUNTER_GROUP))} forEach _loners;
        };

        /*Statistics*/
        _lonersCount = _lonersCount - (count _loners);
        [STAT_SPEC_LONEMERGE,_lonersCount] call NWG_YK_STAT_Increment;
    };

    //Repair vehicles
    if ((count _vehRepairs) > 0) then {
        /*Statistics*/
        private _vehRepairsCount = count _vehRepairs;

        /*Send each vehicle to repair*/
        private _ok = true;
        {
            _ok = (_x#HUNTER_GROUP) call NWG_fnc_acSendToVehRepair;
            if (isNil "_ok" || {_ok isNotEqualTo true}) then {
                format ["NWG_YK_RunPassiveSpecials: Failed to send '%1' to repair. Result:%2",_x,_ok] call NWG_fnc_logError;
                _vehRepairsCount = _vehRepairsCount - 1;
            };
        } forEach _vehRepairs;

        /*Statistics*/
        [STAT_SPEC_VEHREPAIR,_vehRepairsCount] call NWG_YK_STAT_Increment;
    };

    //Capture vehicles
    if ((count _vehCaptures) > 0) then {
        /*Statistics*/
        private _vehCapturesCount = count _vehCaptures;

        /*Send each vehicle to capture*/
        private _ok = true;
        {
            _ok = (_x#HUNTER_GROUP) call NWG_fnc_acSendToInfVehCapture;
            if (isNil "_ok" || {_ok isNotEqualTo true}) then {
                format ["NWG_YK_RunPassiveSpecials: Failed to send '%1' to capture. Result:%2",_x,_ok] call NWG_fnc_logError;
                _vehCapturesCount = _vehCapturesCount - 1;
            };
        } forEach _vehCaptures;

        /*Statistics*/
        [STAT_SPEC_VEHCAPTURE,_vehCapturesCount] call NWG_YK_STAT_Increment;
    };

    //Flee vehicles
    if ((count _vehFlees) > 0) then {
        /*Statistics*/
        private _vehFleesCount = count _vehFlees;

        /*Send each vehicle to flee*/
        private _ok = true;
        {
            _ok = (_x#HUNTER_GROUP) call NWG_fnc_acSendToVehFlee;
            if (isNil "_ok" || {_ok isNotEqualTo true}) then {
                format ["NWG_YK_RunPassiveSpecials: Failed to send '%1' to flee. Result:%2",_x,_ok] call NWG_fnc_logError;
                _vehFleesCount = _vehFleesCount - 1;
            };
        } forEach _vehFlees;

        /*Statistics*/
        [STAT_SPEC_VEHFLEE,_vehFleesCount] call NWG_YK_STAT_Increment;
    };

    //return
    _hunters
};

//======================================================================================================
//======================================================================================================
//Fill the dice
NWG_YK_FillDice = {
    params ["_target","_hunters","_fillIgnore","_fillMove","_isMoveDistanceRestrictions","_fillReinf","_fillSpecials"];
    private _dice = [];

    /*Prepare dice fill with chances*/
    private _fillDice = {
        params ["_diceType","_hunterIndex","_addArg"];
        //Get weight
        private _weight = (NWG_YK_Settings get "DICE_WEIGHTS") get _diceType;
        if (isNil "_weight") then {
            (format ["NWG_YK_FillDice: Dice weight not set for type: '%1'. Fallback to 1",_diceType]) call NWG_fnc_logError;
            _weight = 1;
        };
        if (_weight < 1) then {
            (format ["NWG_YK_FillDice: Dice weight is less than 1 for type: '%1'. Fallback to 1",_diceType]) call NWG_fnc_logError;
            _weight = 1;
        };

        //Fill the dice according to the weight for future random selection
        for "_i" from 1 to _weight do {
            _dice pushBack [_diceType,_hunterIndex,_addArg];
        };
    };

    /*Fill with ignore*/
    if (_fillIgnore) then {
        [DICE_IGNORE,-1,false] call _fillDice;
    };

    /*Fill with move*/
    if (_fillMove) then {
        /*Define what hunter types can we send to deal with the target*/
        private ["_iValid","_vValid","_aValid","_bValid"];
        switch (_target#TARGET_TYPE) do {
            case TARGET_TYPE_BLDG;
            case TARGET_TYPE_INF: {
                _iValid = {true};//Any inf will do
                _vValid = {true};//Any veh will do
                _aValid = {(_this#HUNTER_TYPE) isEqualTo HUNTER_TYPE_AIR_AP};//Only air with anti-personnel
                _bValid = {([(_target#TARGET_POSITION),100,"shore"] call NWG_fnc_dtsFindDotForWaypoint) isNotEqualTo false};//Only if there is a water nearby
            };
            case TARGET_TYPE_VEH: {
                _iValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_INF_AT,HUNTER_TYPE_INF_AAAT]};//Only AT and AAAT
                _vValid = {true};//Any veh will do
                _aValid = {(_this#HUNTER_TYPE) isNotEqualTo HUNTER_TYPE_AIR_AA};//Anything except AA
                _bValid = {false};//No boats
            };
            case TARGET_TYPE_ARM: {
                _iValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_INF_AT,HUNTER_TYPE_INF_AAAT]};//Only AT and AAAT
                _vValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_VEH_AT,HUNTER_TYPE_VEH_AAAT]};//Only AT and AAAT
                _aValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_AIR_AT,HUNTER_TYPE_AIR_AAAT]};//Only AT and AAAT
                _bValid = {false};//No boats
            };
            case TARGET_TYPE_AIR_GND: {
                _iValid = {(_this#HUNTER_TYPE) isNotEqualTo HUNTER_TYPE_INF_AP};//Anything except AP
                _vValid = {true};//Any veh will do
                _aValid = {true};//Any air will do
                _bValid = {false};//No boats
            };
            case TARGET_TYPE_AIR_FLY: {
                _iValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_INF_AA,HUNTER_TYPE_INF_AAAT]};//Only AA and AAAT
                _vValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_VEH_AA,HUNTER_TYPE_VEH_AAAT]};//Only AA and AAAT
                _aValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_AIR_AA,HUNTER_TYPE_AIR_AAAT]};//Only AA and AAAT
                _bValid = {false};//No boats
            };
            case TARGET_TYPE_BOAT: {
                _iValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_INF_AT,HUNTER_TYPE_INF_AAAT]};//Only AT and AAAT
                _vValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_VEH_AT,HUNTER_TYPE_VEH_AAAT]};//Only AT and AAAT
                _aValid = {(_this#HUNTER_TYPE) in [HUNTER_TYPE_AIR_AT,HUNTER_TYPE_AIR_AAAT]};//Only AT and AAAT
                _bValid = {true};//Any water
            };
            default {
                (format ["NWG_YK_FillDice: Unknown target type: '%1'",_target#TARGET_TYPE]) call NWG_fnc_logError;
                _iValid = {false};
                _vValid = {false};
                _aValid = {false};
                _bValid = {false};
            };
        };

        /*Define distances that we can send hunters over*/
        private ["_iDistCheck","_vDistCheck","_aDistCheck","_bDistCheck"];
        if (_isMoveDistanceRestrictions) then {
            _iDistCheck = {((_this#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "HUNT_INF_MOVE_RADIUS")};
            _vDistCheck = {((_this#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "HUNT_VEH_MOVE_RADIUS")};
            _aDistCheck = {((_this#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "HUNT_AIR_MOVE_RADIUS")};
            _bDistCheck = {((_this#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "HUNT_BOAT_MOVE_RADIUS")};
        } else {
            _iDistCheck = {true};
            _vDistCheck = {true};
            _aDistCheck = {true};
            _bDistCheck = {true};
        };

        /*Find hunter index to send*/
        private _hunterIndex = _hunters findIf {
            if ((_x#HUNTER_TYPE) isEqualTo HUNTER_TYPE_UKREP) then {continueWith false};
            if ((_x#HUNTER_TYPE) isEqualTo HUNTER_TYPE_UNDEF) then {continueWith false};
            if ("INF"  in (_x#HUNTER_TYPE)) then {continueWith (_x call _iValid && {_x call _iDistCheck})};
            if ("VEH"  in (_x#HUNTER_TYPE)) then {continueWith (_x call _vValid && {_x call _vDistCheck})};
            if ("AIR"  in (_x#HUNTER_TYPE)) then {continueWith (_x call _aValid && {_x call _aDistCheck})};
            if ("BOAT" in (_x#HUNTER_TYPE)) then {continueWith (_x call _bValid && {_x call _bDistCheck})};
            false
        };

        /*Fill the dice*/
        if (_hunterIndex == -1) exitWith {};
        [DICE_MOVE,_hunterIndex,false] call _fillDice;
    };

    /*Fill with reinf*/
    if (_fillReinf) then {
        [DICE_REINF,-1,false] call _fillDice;
    };

    /*Fill with specials?*/
    if (!_fillSpecials) exitWith {_dice};
    if ((_target#TARGET_TYPE) isEqualTo TARGET_TYPE_AIR_FLY) exitWith {_dice};//There is no special against air targets

    /*Fill with specials*/
    private _i = -1;
    //Airstrike
    if (NWG_YK_Settings get "SPECIAL_AIRSTRIKE_ENABLED") then {
        _i = _hunters findIf {
            (_x#HUNTER_SPECIAL) isEqualTo SPECIAL_AIRSTRIKE && {
            ((_x#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "SPECIAL_AIRSTRIKE_RADIUS")}
        };
        if (_i != -1) then {
            private _numberOfStrikes = selectRandom [1,1,2,3];
            [SPECIAL_AIRSTRIKE,_i,_numberOfStrikes] call _fillDice;
        };
    };

    //Artillery strike
    if (NWG_YK_Settings get "SPECIAL_ARTA_ENABLED") then {
        _i = _hunters findIf {
            (_x#HUNTER_SPECIAL) isEqualTo SPECIAL_ARTA && {
            ((_x#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "SPECIAL_ARTA_RADIUS") && {
            [(_x#HUNTER_GROUP),(_target#TARGET_OBJECT)] call NWG_fnc_acCanDoArtilleryStrikeOnTarget}}
        };
        if (_i != -1) then {
            // private _precise = (_target#TARGET_TYPE) in [TARGET_TYPE_BLDG,TARGET_TYPE_ARM];
            [SPECIAL_ARTA,_i,false] call _fillDice;
        };
    };

    //Vehicle demolition
    if (NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_ENABLED" && {(_target#TARGET_TYPE) isEqualTo TARGET_TYPE_BLDG}) then {
        _i = _hunters findIf {
            (_x#HUNTER_SPECIAL) isEqualTo SPECIAL_VEHDEM && {
            ((_x#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_RADIUS")}
        };
        if (_i != -1) then {
            [SPECIAL_VEHDEM,_i,false] call _fillDice;
        };
    };

    //Inf building storm
    if (NWG_YK_Settings get "SPECIAL_INFSTORM_ENABLED" && {(_target#TARGET_TYPE) isEqualTo TARGET_TYPE_BLDG}) then {
        _i = _hunters findIf {
            (_x#HUNTER_SPECIAL) isEqualTo SPECIAL_INFSTORM && {
            ((_x#HUNTER_POSITION) distance2D (_target#TARGET_POSITION)) <= (NWG_YK_Settings get "SPECIAL_INFSTORM_RADIUS")}
        };
        if (_i != -1) then {
            [SPECIAL_INFSTORM,_i,false] call _fillDice;
        };
    };

    //return
    _dice
};

//======================================================================================================
//======================================================================================================
//Dice - Move
NWG_YK_MoveHunterTo = {
    params ["_hunter","_target"];
    if ((_target#TARGET_TYPE) in [TARGET_TYPE_BLDG,TARGET_TYPE_INF])
        then {[(_hunter#HUNTER_GROUP),(_target#TARGET_POSITION)] call NWG_fnc_dsSendToAttack}
        else {[(_hunter#HUNTER_GROUP),(_target#TARGET_OBJECT)] call NWG_fnc_dsSendToDestroy};
};

//======================================================================================================
//======================================================================================================
//Dice - Reinforcements
NWG_YK_SendReinforcements = {
    // private _target = _this;
    private _targetType = _this#TARGET_TYPE;
    private _targetPos  = _this#TARGET_POSITION;
    private _filter = switch (_targetType) do {
        case TARGET_TYPE_ARM: {[["AT"],[],[]]};//Whitelist AT groups
        case TARGET_TYPE_AIR_GND: {[["AA"],[],[]]};//Whitelist AA groups
        case TARGET_TYPE_AIR_FLY: {[["AA"],[],[]]};//Whitelist AA groups
        default {[]};//No filter
    };

    [_targetPos,1,_filter] spawn NWG_fnc_dsSendReinforcementsCfg;//We expect that the side and faction are already configured elsewhere
};

//======================================================================================================
//======================================================================================================
//Dice - Specials
NWG_YK_UseSpecial = {
    params ["_hunter","_target","_special","_arg"];
    private _group = _hunter#HUNTER_GROUP;
    private _targetObj = _target#TARGET_OBJECT;

    //Use the special
    private _ok = switch (_special) do {
        case SPECIAL_AIRSTRIKE: {[_group,_targetObj,_arg] call NWG_fnc_acSendToAirstrike};
        case SPECIAL_ARTA:      {[_group,_targetObj] call NWG_fnc_acSendArtilleryStrike};
        case SPECIAL_VEHDEM:    {[_group,_targetObj] call NWG_fnc_acSendToVehDemolition};
        case SPECIAL_INFSTORM:  {[_group,_targetObj] call NWG_fnc_acSendToInfBuildingStorm};
        default {
            (format ["NWG_YK_UseSpecial: Unknown special '%1'",_special]) call NWG_fnc_logError;
            false
        };
    };
    if (isNil "_ok" || {_ok isNotEqualTo true}) then {
        format ["NWG_YK_UseSpecial: Failed to use special '%1'. Result:%3",_special,_ok] call NWG_fnc_logError;
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
    STAT_SPEC_AIRSTRIKE,STAT_SPEC_ARTA,STAT_SPEC_VEHDEM,STAT_SPEC_INFSTORM,
    STAT_SPEC_VEHREPAIR,STAT_SPEC_LONEMERGE,STAT_SPEC_VEHCAPTURE,STAT_SPEC_VEHFLEE
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
    if (NWG_YK_Settings get "SPECIAL_VEHDEMOLITION_ENABLED") then {_lines pushBack (format ["VEHDEMOLITION: %1",(_stat get STAT_SPEC_VEHDEM)])};
    if (NWG_YK_Settings get "SPECIAL_INFSTORM_ENABLED")  then {_lines pushBack (format ["INFSTORM: %1",(_stat get STAT_SPEC_INFSTORM)])};
    if (NWG_YK_Settings get "SPECIAL_VEHREPAIR_ENABLED") then {_lines pushBack (format ["VEHREPAIR: %1",(_stat get STAT_SPEC_VEHREPAIR)])};
    if (NWG_YK_Settings get "SPECIAL_LONEMERGE_ENABLED") then {_lines pushBack (format ["LONEMERGE: %1",(_stat get STAT_SPEC_LONEMERGE)])};
    if (NWG_YK_Settings get "SPECIAL_VEHCAPTURE_ENABLED") then {_lines pushBack (format ["VEHCAPTURE: %1",(_stat get STAT_SPEC_VEHCAPTURE)])};
    if (NWG_YK_Settings get "SPECIAL_VEHFLEE_ENABLED") then {_lines pushBack (format ["VEHFLEE: %1",(_stat get STAT_SPEC_VEHFLEE)])};

    diag_log text "==========[ YELLOW KING STATS ]===========";
    {diag_log (text _x)} forEach _lines;
    if (NWG_YK_Settings get "STATISTICS_ADVANCED_COMBAT") then {
        call NWG_fnc_acPrintStatistics;
    };
    diag_log text "==========[        END        ]===========";
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;