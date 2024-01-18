#include "..\..\globalDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_YK_Settings = createHashMapFromArray [
    ["ENABLED",true],//Defines wether or not the entire system is enabled
    ["KING_SIDE",west],//The side which kills will count and groups/reinforcements used, basically the side YK is plays for
    ["REACTION_TIME",[60,120]],//Min and max time between actions and reactions (will be defined randomly between the two)
    ["REACTION_IMMEDIATE_ON_KILLCOUNT",25],//Number of kills to immediately react to (skips all the wait remaining)
    ["REACT_TO_PLAYERS_ONLY",false],//Should we handle kills made by AI units and players or players only

    ["SHOW_DEBUG_MESSAGE",true],//Show debug message in systemChat

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
};

//======================================================================================================
//======================================================================================================
//Reaction system
NWG_YK_killsToCount = [OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT];
NWG_YK_killCount = 0;
NWG_YK_OnKilled = {
    params ["_object","_objType","_actualKiller","_isPlayerKiller"];

    //Check arguments
    if (isNull _object || {isNull _actualKiller || {!alive _actualKiller || {!(_objType in NWG_YK_killsToCount)}}}) exitWith {};//Invalid input
    if (!_isPlayerKiller && {(NWG_YK_Settings get "REACT_TO_PLAYERS_ONLY")}) exitWith {};//If we only want to react to player kills

    //Check side of the victim
    private _objGroup = if (_objType isEqualTo OBJ_TYPE_UNIT) then {group _object} else {assignedGroup _object};
    if (isNull _objGroup || {(side _objGroup) isNotEqualTo (NWG_YK_Settings get "KING_SIDE")}) exitWith {};//Not a kill of interest

    //Setup the reaction
    NWG_YK_killCount = NWG_YK_killCount + 1;
    NWG_YK_reactList pushBackUnique _actualKiller;
    if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat (format ["NWG_YK: %1 killed %2",name _actualKiller,name _object])};
    if (isNull NWG_YK_reactHandle || {scriptDone NWG_YK_reactHandle}) then {
        (NWG_YK_Settings get "REACTION_TIME") params ["_minTime","_maxTime"];
        NWG_YK_reactTime = (floor (random (_maxTime - _minTime))) + _minTime;
        NWG_YK_reactHandle = [] spawn NWG_YK_React;
    };
};

NWG_YK_reactList = [];
NWG_YK_reactTime = 0;
NWG_YK_reactHandle = scriptNull;
NWG_YK_React = {
    //Wait for the reaction time to pass or the kill count to reach the threshold
    waitUntil {
        sleep 1;
        (time > NWG_YK_reactTime || {NWG_YK_killCount > (NWG_YK_Settings get "REACTION_IMMEDIATE_ON_KILLCOUNT")})
    };

    //Gather the targets (and abort if there are none)
    private _targets = ((NWG_YK_reactList select {alive _x}) apply {vehicle _x}) select {alive _x};
    if ((count _targets) == 0) exitWith {
        NWG_YK_reactList resize 0;
        NWG_YK_reactTime = 0;
        NWG_YK_killCount = 0;
        if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat "NWG_YK: No targets found"};
    };//Exit on no targets
    _targets = _targets arrayIntersect _targets;//Remove duplicates
    _targets = _targets call NWG_fnc_arrayShuffle;//Shuffle

    //Gather the existing hunters
    private _hunters = call NWG_YK_HUNT_GetHunters;
    if ((count _hunters) > 0) then {
        _hunters call NWG_YK_HUNT_AlarmHunters;
        _hunters call NWG_YK_HUNT_MergeLoners;
    };

    //Get the difficulty settings
    (call NWG_YK_GetDifficulty) params [
        "_ignoreChance",
        "_reinfChance",
        "_reinfCount"
    ];

    //Process the targets
    //do
    {
        //Roll ignore chance
        if ((random 1) <= _ignoreChance) then {
            if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat (format ["NWG_YK: Ignoring %1",name _x])};
            continue
        };

        //Prepare variables
        private _target = _x;
        private _targetType = _target call NWG_YK_GetTargetType;
        private _dice = [];

        //Fill the dice
        if ([_hunters,_targetType] call NWG_YK_HUNT_DoWeHaveHunterFor) then {_dice pushBack "HUNT"};
        if (_reinfCount > 0 && {(random 1) <= _reinfChance}) then {_dice pushBack "REINF"};
        if (_dice isEqualTo []) then {continue};//There's nothing we can do napoleon meme

        //Roll the dice
        switch (selectRandom _dice) do {
            case "HUNT": {
                [_hunters,_target,_targetType] call NWG_YK_HUNT_SendHunterFor;
                if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat (format ["NWG_YK: Sending hunter for %1",name _target])};
            };
            case "REINF": {
                [_target,_targetType] call NWG_YK_REINF_SendReinforcements;
                _reinfCount = _reinfCount - 1;
                if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat (format ["NWG_YK: Sending reinforcements for %1",name _target])};
            };
            default {
                private _msg = format ["NWG_YK_React: Unknown dice roll for %1",_dice];
                if (NWG_YK_Settings get "SHOW_DEBUG_MESSAGE") then {systemChat _msg};
                _msg call NWG_fnc_logError;
            };
        };
    } forEach _targets;

    NWG_YK_reactList resize 0;
    NWG_YK_reactTime = 0;
    NWG_YK_killCount = 0;
};

/*Utils*/
NWG_YK_difficultyCurve = [0,1,0,1,2,1,2,0,1,1,2,0,1,2,2,1,0];
NWG_YK_difficultySettings = [
    //Easy
    [/*_ingoreChance*/0.7,/*_reinfChance*/0.2,/*_reinfCount*/1],
    //Medium
    [/*_ingoreChance*/0.4,/*_reinfChance*/0.5,/*_reinfCount*/1],
    //Hard
    [/*_ingoreChance*/0.1,/*_reinfChance*/0.8,/*_reinfCount*/2]
];
NWG_YK_GetDifficulty = {
    private _diff = NWG_YK_difficultyCurve deleteAt 0;
    NWG_YK_difficultyCurve pushBack _diff;
    //return
    NWG_YK_difficultySettings select _diff
};

NWG_YK_GetTargetType = {
    // private _target = _this;
    switch (true) do {
        case (_this isKindOf "Man"): {"INF"};
        case (_this isKindOf "StaticWeapon"): {"INF"};//Static weapons are not actually infantry, but they are not vehicles either
        case (_this isKindOf "Air"): {if (_this isKindOf "ParachuteBase") then {"INF"} else {"AIR"}};//Parachutes give false positives for "Air"
        case (_this isKindOf "Tank" || {_this isKindOf "Wheeled_APC_F"}) : {"ARM"};
        case (_this isKindOf "Ship"): {"BOAT"};
        default {"VEH"};
    }
};

//======================================================================================================
//======================================================================================================
//Hunters logic
#define HUNT_GROUP 0
#define HUNT_TAGS 1
NWG_YK_HUNT_GetHunters = {
    private _kingSide = NWG_YK_Settings get "KING_SIDE";
    private _hunters = allGroups select {
        !isNull _x && {
            (side _x) isEqualTo _kingSide && {
                ({alive _x} count (units _x)) > 0 && {
                    (units _x) findIf {isPlayer _x} == -1}}}
    };
    _hunters = _hunters apply {[_x,(_x call NWG_fnc_dsGetOrGenerateTags)]};//Get dspawn tags for each group
    _hunters = _hunters call NWG_fnc_arrayShuffle;//Shuffle

    //return
    _hunters
};

NWG_YK_HUNT_AlarmHunters = {
    // private _hunters = _this;
    //do
    {
        if ((behaviour (leader (_x#HUNT_GROUP))) isEqualTo "SAFE") then {
            (_x#HUNT_GROUP) setCombatMode "RED";
            (_x#HUNT_GROUP) setBehaviourStrong "AWARE";
        };
    } forEach _this;
};

NWG_YK_HUNT_MergeLoners = {
    // private _hunters = _this;

    //Quick check
    if ((_this findIf {"INF" in (_x#HUNT_TAGS) && {({alive _x} count (units (_x#HUNT_GROUP))) == 1}}) == -1) exitWith {};//No loners

    //Separate INF
    private _inf = _this select {"INF" in (_x#HUNT_TAGS)};
    private _temp = _this - _inf;

    //Merge INF loners
    private ["_i","_loner","_nearest","_nearestDist","_dist"];
    while {true} do {
        if ((count _inf) <= 1) exitWith {};
        _i = _inf findIf {({alive _x} count (units (_x#HUNT_GROUP))) == 1};
        if (_i == -1) exitWith {};

        _loner = _inf deleteAt _i;
        _nearest = [];
        _nearestDist = 999999999;
        {
            _dist = (leader (_loner#HUNT_GROUP)) distance (leader (_x#HUNT_GROUP));
            if (_dist < _nearestDist) then {
                _nearest = _x;
                _nearestDist = _dist;
            };
        } forEach _inf;
        if (_nearest isEqualTo []) exitWith {};
        ((units (_loner#HUNT_GROUP)) select {alive _x}) joinSilent (_nearest#HUNT_GROUP);
    };

    //Rejoin INF
    _temp append _inf;
    _temp call NWG_fnc_arrayShuffle;
    _this resize 0;
    _this append _temp;
};

NWG_YK_HUNT_DoWeHaveHunterFor = {
    params ["_hunters","_targetType"];
    if ((count _hunters) == 0) exitWith {false};//No hunters

    switch (_targetType) do {
        case "INF": {true};//We already know there is at least someone
        case "VEH": {true};//Same as above
        case "ARM": {(_hunters findIf {"AT" in (_x#HUNT_TAGS)}) != -1};//Do we have any AT hunters?
        case "AIR": {(_hunters findIf {"AA" in (_x#HUNT_TAGS)}) != -1};//Do we have any AA hunters?
        case "BOAT": {
            //Boat can be hunted only by air or another boat
            (_hunters findIf {
                "BOAT" in (_x#HUNT_TAGS) || {
                    "AIR" in (_x#HUNT_TAGS) && {
                        "MEC" in (_x#HUNT_TAGS)}}}) != -1
        };
    }
};

NWG_YK_HUNT_SendHunterFor = {
    params ["_hunters","_target","_targetType"];
    if ((count _hunters) == 0) exitWith {false};//No hunters
    private _targetPos = getPosASL _target;
    _targetPos set [2,0];

    //Find a suitable hunter for the target
    private _hunter = switch (_targetType) do {
        case "INF";
        case "VEH": {
            //Check if we can send a boat
            private _i = _hunters findIf {"BOAT" in (_x#HUNT_TAGS)};
            if (_i != -1 && {surfaceIsWater _targetPos ||
                {([_targetPos,(NWG_DSPAWN_Settings get "ATTACK_BOAT_UNLOAD_RADIUS"),"shore"] call NWG_fnc_dtsFindDotForWaypoint) isNotEqualTo false}})
                exitWith {_hunters deleteAt _i};

            //Send whoever
            _hunters deleteAt 0;
        };
        case "ARM": {
            //Send any AT group
            private _i = _hunters findIf {"AT" in (_x#HUNT_TAGS)};
            if (_i != -1) exitWith {_hunters deleteAt _i};
            _hunters deleteAt 0;
        };
        case "AIR": {
            //Send any AA group
            private _i = _hunters findIf {"AA" in (_x#HUNT_TAGS)};
            if (_i != -1) exitWith {_hunters deleteAt _i};
            _hunters deleteAt 0;
        };
        case "BOAT": {
            //Boat can be hunted only by air or another boat
            private _i = _hunters findIf {
                "BOAT" in (_x#HUNT_TAGS) || {
                    "AIR" in (_x#HUNT_TAGS) && {
                        "MEC" in (_x#HUNT_TAGS)}}};
            if (_i != -1) exitWith {_hunters deleteAt _i};
            _hunters deleteAt 0;
        };
    };

    //Send the hunter
    [(_hunter#HUNT_GROUP),_targetPos] call NWG_fnc_dsSendToAttack;
};

//======================================================================================================
//======================================================================================================
//Reinforesments logic
NWG_YK_REINF_SendReinforcements = {
    params ["_target","_targetType"];
    private _targetPos = getPosASL _target; _targetPos set [2,0];
    private _faction = BST_ENEMY_FACTION call NWG_fnc_shGetState;
    if (isNil "_faction") then {_faction = "NATO"};//Default to NATO

    private _filter = switch (_targetType) do {
        case "ARM": {[["AT"],[],[]]};//Whitelist AT groups
        case "AIR": {[["AA"],[],[]]};//Whitelist AA groups
        default {[]};//No filter
    };
    private _side = NWG_YK_Settings get "KING_SIDE";

    [_targetPos,1,_faction,_filter,_side] spawn NWG_fnc_dsSendReinforcements;
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;