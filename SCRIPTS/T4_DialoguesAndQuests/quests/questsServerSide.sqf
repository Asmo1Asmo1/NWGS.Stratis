#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_QST_SER_Settings = createHashMapFromArray [
    /*Quest Settings*/
    ["QUEST_ENABLED",[
        QST_TYPE_VEH_STEAL
        // QST_TYPE_INTERROGATE,
        // QST_TYPE_HACK_DATA,
        // QST_TYPE_DESTROY,
        // QST_TYPE_INTEL,
        // QST_TYPE_INFECTION,
        // QST_TYPE_WOUNDED,
        // QST_TYPE_MED_SUPPLY,
        // QST_TYPE_TERMINAL,
        // QST_TYPE_WEAPON,
        // QST_TYPE_ELECTRONICS,
        // QST_TYPE_TOOLS
    ]],
    ["QUEST_GIVERS",[
        /*QST_TYPE_VEH_STEAL:*/ NPC_MECH,
        /*QST_TYPE_INTERROGATE:*/ NPC_COMM,
        /*QST_TYPE_HACK_DATA:*/ NPC_COMM,
        /*QST_TYPE_DESTROY:*/ NPC_COMM,
        /*QST_TYPE_INTEL:*/ NPC_COMM,
        /*QST_TYPE_INFECTION:*/ NPC_MECH,
        /*QST_TYPE_WOUNDED:*/ NPC_MECH,
        /*QST_TYPE_MED_SUPPLY:*/ NPC_MECH,
        /*QST_TYPE_TERMINAL:*/ NPC_ROOF,
        /*QST_TYPE_WEAPON:*/ NPC_ROOF,
        /*QST_TYPE_ELECTRONICS:*/ NPC_ROOF,
        /*QST_TYPE_TOOLS:*/ NPC_TAXI
    ]],
    ["QUEST_DICE_WEIGHTS",[
        /*QST_TYPE_VEH_STEAL:*/ 1,
        /*QST_TYPE_INTERROGATE:*/ 1,
        /*QST_TYPE_HACK_DATA:*/ 1,
        /*QST_TYPE_DESTROY:*/ 1,
        /*QST_TYPE_INTEL:*/ 1,
        /*QST_TYPE_INFECTION:*/ 2,
        /*QST_TYPE_WOUNDED:*/ 1,
        /*QST_TYPE_MED_SUPPLY:*/ 1,
        /*QST_TYPE_TERMINAL:*/ 1,
        /*QST_TYPE_WEAPON:*/ 1,
        /*QST_TYPE_ELECTRONICS:*/ 1,
        /*QST_TYPE_TOOLS:*/ 1
    ]],
    ["QUEST_REWARDS",[
        /*QST_TYPE_VEH_STEAL:*/ {
            params ["_targetClassname","_multiplier"];
            private _price = _targetClassname call NWG_fnc_vshopEvaluateVehPrice;
            private _reward = _price + (_price * (_multiplier * 0.05));//Apply 5% of multiplier
            _reward = (round (_reward / 100)) * 100;//Round to nearest 100
            _reward
        },
        /*QST_TYPE_INTERROGATE:*/ 1000,
        /*QST_TYPE_HACK_DATA:*/ 1000,
        /*QST_TYPE_DESTROY:*/ 1000,
        /*QST_TYPE_INTEL:*/ "TODO",
        /*QST_TYPE_INFECTION:*/ 1000,
        /*QST_TYPE_WOUNDED:*/ 1000,
        /*QST_TYPE_MED_SUPPLY:*/ "TODO",
        /*QST_TYPE_TERMINAL:*/ "TODO",
        /*QST_TYPE_WEAPON:*/ {0/*TODO*/},
        /*QST_TYPE_ELECTRONICS:*/ "TODO",
        /*QST_TYPE_TOOLS:*/ "TODO"
    ]],
    ["QUEST_DEFAULT_REWARD",1000],

    /*External functions*/
    ["FUNC_GET_REWARD_MULTIPLIER",{(call NWG_fnc_mmGetMissionLevel) + 1}],//Applies only to number or code type rewards
    ["FUNC_REWARD_PLAYER",{
        params ["_player","_reward"];
        [_player,P__EXP,1] call NWG_fnc_pAddPlayerProgress;//Add experience
        [_player,P_TEXP,1] call NWG_fnc_pAddPlayerProgress;//Add total experience (level up)
        [_player,_reward] call NWG_fnc_wltAddPlayerMoney;//Add money reward
    }],

    /*Marker Settings*/
    ["MARKER_TYPE","mil_warning"],
    ["MARKER_COLOR","ColorBlack"],
    ["MARKER_SIZE",0.75],

    /*Localization*/
    ["LOC_QUEST_DONE",[
        /*QST_TYPE_VEH_STEAL:*/ false,
        /*QST_TYPE_INTERROGATE:*/ false,
        /*QST_TYPE_HACK_DATA:*/ false,
        /*QST_TYPE_DESTROY:*/ "#QST_DESTROY_DONE#",
        /*QST_TYPE_INTEL:*/ false,
        /*QST_TYPE_INFECTION:*/ false,
        /*QST_TYPE_WOUNDED:*/ false,
        /*QST_TYPE_MED_SUPPLY:*/ false,
        /*QST_TYPE_TERMINAL:*/ false,
        /*QST_TYPE_WEAPON:*/ false,
        /*QST_TYPE_ELECTRONICS:*/ false,
        /*QST_TYPE_TOOLS:*/ false
    ]],
    ["LOC_QUEST_CLOSED",[
        /*QST_TYPE_VEH_STEAL:*/ "#QST_VEH_STEAL_CLOSED#",
        /*QST_TYPE_INTERROGATE:*/ false,
        /*QST_TYPE_HACK_DATA:*/ false,
        /*QST_TYPE_DESTROY:*/ "#QST_DESTROY_CLOSED#",
        /*QST_TYPE_INTEL:*/ false,
        /*QST_TYPE_INFECTION:*/ false,
        /*QST_TYPE_WOUNDED:*/ false,
        /*QST_TYPE_MED_SUPPLY:*/ false,
        /*QST_TYPE_TERMINAL:*/ false,
        /*QST_TYPE_WEAPON:*/ false,
        /*QST_TYPE_ELECTRONICS:*/ false,
        /*QST_TYPE_TOOLS:*/ false
    ]],
    ["LOC_UNKONW_WINNER","#QST_UNKONW_WINNER#"],

    /*Destroy object quest*/
    ["DESTROY_TARGETS",[
        "Land_Cargo_HQ_V1_F",
        "Land_Cargo_HQ_V2_F",
        "Land_Cargo_HQ_V3_F",
        "Land_Medevac_HQ_V1_F",
        "Land_Research_HQ_F",
        "Land_Cargo_Tower_V1_No1_F",
        "Land_Cargo_Tower_V1_No2_F",
        "Land_Cargo_Tower_V1_No3_F",
        "Land_Cargo_Tower_V1_No4_F",
        "Land_Cargo_Tower_V1_No5_F",
        "Land_Cargo_Tower_V1_No6_F",
        "Land_Cargo_Tower_V1_No7_F",
        "Land_Cargo_Tower_V1_F",
        "Land_Cargo_Tower_V2_F",
        "Land_Cargo_Tower_V3_F",
        "Land_Cargo_Tower_V4_F",
        "Land_TTowerBig_1_F",
        "Land_TTowerBig_2_F"
    ]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
/*Global Variables*/
NWG_QST_State = QST_STATE_UNASSIGNED;
NWG_QST_Data = [];
NWG_QST_WinnerName = "";

//================================================================================================================
//================================================================================================================
//Quest creation
NWG_QST_SER_CreateNew = {
    private _missionObjects = _this;
    private _enabledQuests = NWG_QST_SER_Settings get "QUEST_ENABLED";
    private _diceWeights = NWG_QST_SER_Settings get "QUEST_DICE_WEIGHTS";
    private _dice = [];

    //Fill the dice
    /*Steal vehicle quest*/
    if (QST_TYPE_VEH_STEAL in _enabledQuests) then {
        private _possibleTargets = (_missionObjects select OBJ_CAT_VEHC) select {
            !(unitIsUAV _x) && {
            (count (crew _x)) == 0 && {
            !(_x isKindOf "Ship") && {
            !(_x isKindOf "Plane")}}}
        };
        if ((count _possibleTargets) == 0) exitWith {};
        _possibleTargets = _possibleTargets call NWG_fnc_arrayShuffle;
        private _target = _possibleTargets select 0;
        for "_i" from 1 to (_diceWeights select QST_TYPE_VEH_STEAL) do {
            _dice pushBack [QST_TYPE_VEH_STEAL,_target,(typeOf _target)];
        };
    };
    /*Destroy object quest*/
    if (QST_TYPE_DESTROY in _enabledQuests) then {
        private _targetClassnames = NWG_QST_SER_Settings get "DESTROY_TARGETS";
        private _possibleTargets = (_missionObjects select OBJ_CAT_BLDG) select {(typeOf _x) in _targetClassnames};
        if ((count _possibleTargets) == 0) exitWith {};
        _possibleTargets = _possibleTargets call NWG_fnc_arrayShuffle;
        private _target = _possibleTargets select 0;
        for "_i" from 1 to (_diceWeights select QST_TYPE_DESTROY) do {
            _dice pushBack [QST_TYPE_DESTROY,_target,(typeOf _target)];
        };
    };

    //Check dice
    if ((count _dice) == 0) exitWith {
        "NWG_QST_SER_CreateNew: Could not create any quests" call NWG_fnc_logError;
        call NWG_QST_SER_ClearAll;//Clear any remaining quest data
        false;
    };

    //Roll the dice
    _dice = _dice call NWG_fnc_arrayShuffle;
    (_dice select 0) params ["_questType","_targetObj","_targetClassname"];
    _dice resize 0;//Clear the dice

    //Run type-specific logic
    switch (_questType) do {
        case QST_TYPE_DESTROY: {
            _targetObj addEventHandler ["Killed",{
                params ["_targetObj","_killer","_instigator"/*,"_useEffects"*/];
                ([_killer,_instigator] call NWG_QST_SER_DefinePlayerKiller) call NWG_QST_SER_OnQuestDone;
            }];
        };
        default {};//Do nothing
    };

    //Get quest NPC
    private _npc = (NWG_QST_SER_Settings get "QUEST_GIVERS") param [_questType,""];
    if (_npc isEqualTo "") exitWith {
        (format ["NWG_QST_SER_CreateNew: No NPC assigned to quest type: '%1'",_questType]) call NWG_fnc_logError;
        false;
    };

    //Get quest reward
    private _reward = (NWG_QST_SER_Settings get "QUEST_REWARDS") param [_questType,false];
    private _multiplier = call (NWG_QST_SER_Settings get "FUNC_GET_REWARD_MULTIPLIER");
    _reward = switch (true) do {
        case (_reward isEqualType 1): {
            /*Number type - apply multiplier*/
            _reward * _multiplier
        };
        case (_reward isEqualType ""): {
            /*String type - 'reward as a promise' (localization key) - actual reward will be calculated on client side*/
            _reward
        };
        case (_reward isEqualType {}): {
            /*Code type - reward depends on target classname*/
            [_targetClassname,_multiplier] call _reward
        };
        default {
            (format ["NWG_QST_SER_CreateNew: Unknown reward type: '%1' for quest type: '%2'",_reward,_questType]) call NWG_fnc_logError;
            NWG_QST_SER_Settings get "QUEST_DEFAULT_REWARD"
        };
    };

    //Create quest marker
    private _marker = _targetObj call {
        // private _object = _this;
        private _markerName = format ["NWG_QST_Marker_%1",(round time)];//Hack to get a unique marker name
        private _marker = createMarkerLocal [_markerName,_this];
        _marker setMarkerShapeLocal "icon";
        _marker setMarkerTypeLocal (NWG_QST_SER_Settings get "MARKER_TYPE");
        _marker setMarkerColorLocal (NWG_QST_SER_Settings get "MARKER_COLOR");
        _marker setMarkerSize [(NWG_QST_SER_Settings get "MARKER_SIZE"),(NWG_QST_SER_Settings get "MARKER_SIZE")];
        // _marker setMarkerText _text; //Done on Client Side for localization purposes
        _marker
    };

    //Propagate quest data to clients
    private _questData = [_questType,_npc,_targetObj,_targetClassname,_reward,_marker];
    NWG_QST_State = QST_STATE_IN_PROGRESS;
    NWG_QST_Data = _questData;
    NWG_QST_WinnerName = "";
    publicVariable "NWG_QST_State";
    publicVariable "NWG_QST_Data";
    publicVariable "NWG_QST_WinnerName";
    _questData remoteExec ["NWG_fnc_qstOnQuestCreated",0];

    //return
    true
};

//Clears all quests data
NWG_QST_SER_ClearAll = {
    NWG_QST_State = QST_STATE_UNASSIGNED;
    NWG_QST_Data = [];
    NWG_QST_WinnerName = "";
    publicVariable "NWG_QST_State";
    publicVariable "NWG_QST_Data";
    publicVariable "NWG_QST_WinnerName";
};

//================================================================================================================
//================================================================================================================
//Quest completion
NWG_QST_SER_OnQuestDone = {
    private _player = _this;
    if (NWG_QST_State != QST_STATE_IN_PROGRESS) exitWith {
        (format ["NWG_QST_SER_OnQuestDone: Quest is not in progress: '%1'",NWG_QST_State]) call NWG_fnc_logError;
    };

    //Get player str
    private _playerName = if (!isNull _player)
        then {name _player}
        else {QST_UNKNOWN_WINNER};

    //Update quest state
    NWG_QST_State = QST_STATE_DONE;
    NWG_QST_WinnerName = _playerName;
    publicVariable "NWG_QST_State";
    publicVariable "NWG_QST_WinnerName";

    //Notify clients
    private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
    if (_questType isEqualTo -1) exitWith {
        (format ["NWG_QST_SER_OnQuestDone: No quest type found"]) call NWG_fnc_logError;
    };
    private _locKey = (NWG_QST_SER_Settings get "LOC_QUEST_DONE") param [_questType,""];
    if (_locKey isEqualTo "") exitWith {
        (format ["NWG_QST_SER_OnQuestDone: No localization key found for quest type: '%1'",_questType]) call NWG_fnc_logError;
    };
    if (_locKey isEqualTo false) exitWith {};//Chat message disabled for this quest type
    private _winnerStr = if (_playerName isNotEqualTo QST_UNKNOWN_WINNER)
        then {_playerName}
        else {NWG_QST_SER_Settings get "LOC_UNKONW_WINNER"};
    [_locKey,_winnerStr] call NWG_fnc_sideChatAll;
};

NWG_QST_SER_OnQuestClosed = {
    params ["_player","_reward"];
    if !(NWG_QST_State in [QST_STATE_IN_PROGRESS,QST_STATE_DONE]) exitWith {
        (format ["NWG_QST_SER_OnQuestClosed: Quest is not in progress or done: '%1'",NWG_QST_State]) call NWG_fnc_logError;
    };

    //Get player str
    private _playerName = if (!isNull _player)
        then {name _player}
        else {QST_UNKNOWN_WINNER};

    //Update quest state
    NWG_QST_State = QST_STATE_CLOSED;
    NWG_QST_WinnerName = _playerName;
    publicVariable "NWG_QST_State";
    publicVariable "NWG_QST_WinnerName";

    //Run type-specific quest finalization logic
    private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
    switch (_questType) do {
        default {};//Do nothing
    };

    //Notify clients (in separate scope to avoid breaking rewarding in case of errors
    call {
        private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
        if (_questType isEqualTo -1) exitWith {
            (format ["NWG_QST_SER_OnQuestClosed: No quest type found"]) call NWG_fnc_logError;
        };
        private _locKey = (NWG_QST_SER_Settings get "LOC_QUEST_CLOSED") param [_questType,""];
        if (_locKey isEqualTo "") exitWith {
            (format ["NWG_QST_SER_OnQuestClosed: No localization key found for quest type: '%1'",_questType]) call NWG_fnc_logError;
        };
        if (_locKey isEqualTo false) exitWith {};//Chat message disabled for this quest type
        private _winnerStr = if (_playerName isNotEqualTo QST_UNKNOWN_WINNER)
            then {_playerName}
            else {NWG_QST_SER_Settings get "LOC_UNKONW_WINNER"};
        [_locKey,_winnerStr] call NWG_fnc_sideChatAll;
    };

    //Reward players
    private _funcRewardPlayer = NWG_QST_SER_Settings get "FUNC_REWARD_PLAYER";
    {
        [_x,_reward] call _funcRewardPlayer;
    } forEach ((units (group _player)) select {isPlayer _x});
};

//================================================================================================================
//================================================================================================================
//Quest utils
/*Copy of NWG_UNDTKR_DefineKiller with some changes*/
NWG_QST_SER_DefinePlayerKiller = {
    params [["_killer",objNull],["_instigator",objNull]];
    private _suspect = if (!isNull _instigator) then {_instigator} else {_killer};
    _suspect = switch (true) do {
        case (isNull _suspect):                   {objNull};
        case (_suspect isKindOf "Man"):           {_suspect};
        case (unitIsUAV _suspect):                {((UAVControl _suspect) param [0,objNull])};
        case (_suspect isKindOf "StaticWeapon"):  {(gunner _suspect)};
        case ((["Car","Tank","Helicopter","Plane","Ship"] findIf {_suspect isKindOf _x}) >= 0): {(driver _suspect)};
        default                                   {objNull};
    };
    if (!isNull _suspect && {!isPlayer _suspect}) then {
        _suspect = objNull;
    };

    _suspect
};