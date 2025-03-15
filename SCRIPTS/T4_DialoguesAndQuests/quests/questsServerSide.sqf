#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
/*Moved to questsSettings.sqf*/

//================================================================================================================
//================================================================================================================
//Fields
/*Global Variables*/
NWG_QST_State = QST_STATE_UNASSIGNED;
NWG_QST_Data = [];
NWG_QST_WinnerName = "";

/*Local Variables*/
NWG_QST_lastQuestType = -1;

//================================================================================================================
//================================================================================================================
//Quest creation
NWG_QST_SER_CreateNew = {
    private _missionObjects = _this;
    private _enabledQuests = NWG_QST_Settings get "QUEST_ENABLED";
    private _diceWeights = NWG_QST_Settings get "QUEST_DICE_WEIGHTS";
    private _dice = [];

    //Prepare dice fill script
    private _fillDice = {
        params ["_questType","_objCat","_selectBy"];
        private _possibleTargets = (_missionObjects select _objCat) select _selectBy;
        if ((count _possibleTargets) == 0) exitWith {};
        private _target = selectRandom _possibleTargets;
        for "_i" from 1 to (_diceWeights select _questType) do {
            _dice pushBack [_questType,_target,(typeOf _target)];
        };
    };

    //Fill the dice
    /*Steal vehicle quest*/
    if (QST_TYPE_VEH_STEAL in _enabledQuests) then {
        private _selectBy = {
            !(unitIsUAV _x) && {
            (count (crew _x)) == 0 && {
            !(_x isKindOf "Ship") && {
            !(_x isKindOf "Plane")}}}
        };
        [QST_TYPE_VEH_STEAL,OBJ_CAT_VEHC,_selectBy] call _fillDice;
    };
    /*Interrogate officer quest*/
    if (QST_TYPE_INTERROGATE in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "INTERROGATE_TARGETS")};
        [QST_TYPE_INTERROGATE,OBJ_CAT_UNIT,_selectBy] call _fillDice;
    };
    /*Hack data quest*/
    if (QST_TYPE_HACK_DATA in _enabledQuests) then {
        private _selectBy = {
            (typeOf _x) in (NWG_QST_Settings get "HACK_DATA_TARGETS") && {
            !(isSimpleObject _x)}
        };
        [QST_TYPE_HACK_DATA,OBJ_CAT_DECO,_selectBy] call _fillDice;
    };
    /*Destroy object quest*/
    if (QST_TYPE_DESTROY in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "DESTROY_TARGETS")};
        [QST_TYPE_DESTROY,OBJ_CAT_BLDG,_selectBy] call _fillDice;
    };
    /*Intel quest*/
    if (QST_TYPE_INTEL in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "INTEL_ITEMS_OBJECTS")};
        [QST_TYPE_INTEL,OBJ_CAT_DECO,_selectBy] call _fillDice;
    };
    /*Med supply quest*/
    if (QST_TYPE_MED_SUPPLY in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "MED_SUPPLY_ITEMS_OBJECTS")};
        [QST_TYPE_MED_SUPPLY,OBJ_CAT_DECO,_selectBy] call _fillDice;
    };

    //Check dice
    if ((count _dice) == 0) exitWith {
        "NWG_QST_SER_CreateNew: Could not create any quests" call NWG_fnc_logError;
        call NWG_QST_SER_ClearAll;//Clear any remaining quest data
        false;
    };

    //Remove last quest type to not repeat it second time in a row
    if ((count _dice) > 1 && {NWG_QST_lastQuestType >= 0}) then {
        private _lastQuestType = NWG_QST_lastQuestType;
        private _toRemove = [];
        {
            if ((_x select QST_DATA_TYPE) == _lastQuestType) then {_toRemove pushBack (_dice deleteAt _forEachIndex)};
        } forEachReversed _dice;
        if ((count _dice) == 0) then {_dice append _toRemove};//That was the only quest available - undo deletion
    };

    //Roll the dice
    _dice = _dice call NWG_fnc_arrayShuffle;//Works better than selectRandom
    (_dice select 0) params ["_questType","_targetObj","_targetClassname"];
    _dice resize 0;//Clear the dice
    NWG_QST_lastQuestType = _questType;//Save last quest type

    //Run type-specific logic
    switch (_questType) do {
        case QST_TYPE_INTERROGATE: {
            //Make sure target can not be killed, only wounded
            _targetObj removeAllEventHandlers "HandleDamage";//Remove any other logic that may have been added
            _targetObj addEventHandler ["HandleDamage",{_this call NWG_QST_SER_OnWounded}];//Handle damage (+increases 'brake' counter)
            //Set initial 'brake' counter
            private _toBreak = round (random (NWG_QST_Settings get "INTERROGATE_BREAK_LIMIT"));
            _targetObj setVariable ["QST_toBreak",_toBreak,true];
            //Add action to interrogate target
            private _title = NWG_QST_Settings get "INTERROGATE_TITLE";
            private _icon = NWG_QST_Settings get "INTERROGATE_ICON";
            [_targetObj,_title,_icon,{_this call NWG_QST_CLI_OnInterrogateDone},{call NWG_QST_CLI_OnInterrogateStart}] call NWG_fnc_addHoldActionGlobal;
        };
        case QST_TYPE_HACK_DATA: {
            //Set initial state
            _targetObj setVariable ["QST_isHacked",false,true];
            //Setup hacking for current and JIP players
            [_targetObj,"NWG_QST_CLI_OnHackCreated",[]] call NWG_fnc_rqAddCommand;
        };
        case QST_TYPE_DESTROY: {
            //Add 'Killed' EH to register player who did it
            _targetObj addEventHandler ["Killed",{
                params ["_targetObj","_killer","_instigator"/*,"_useEffects"*/];
                ([_killer,_instigator] call NWG_QST_SER_DefinePlayerKiller) call NWG_QST_SER_OnQuestDone;
                _targetObj removeEventHandler [_thisEvent,_thisEventHandler];
            }];
        };
        default {};//Do nothing
    };

    //Get quest NPC
    private _npc = (NWG_QST_Settings get "QUEST_GIVERS") param [_questType,""];
    if (_npc isEqualTo "") exitWith {
        (format ["NWG_QST_SER_CreateNew: No NPC assigned to quest type: '%1'",_questType]) call NWG_fnc_logError;
        false;
    };

    //Get quest reward
    private _reward = (NWG_QST_Settings get "QUEST_REWARDS") param [_questType,false];
    private _multiplier = call (NWG_QST_Settings get "FUNC_GET_REWARD_MULTIPLIER");
    _reward = switch (true) do {
        case (_reward isEqualType 1): {
            /*Number type - apply multiplier*/
            _reward * _multiplier
        };
        case (_reward isEqualType {}): {
            /*Code type - reward depends on target classname*/
            [_targetClassname,_multiplier] call _reward
        };
        case (_reward isEqualType ""): {
            /*String type - Reward is defined 'per item' and this is items collection name from settings*/
            private _items = NWG_QST_Settings get _reward;
            private _itemPriceMult = _multiplier call (NWG_QST_Settings get "FUNC_GET_ITEM_PRICE_MULT");
            private _getPriceFunc = NWG_QST_Settings get "FUNC_GET_ITEM_PRICE";
            private _priceMap = createHashMapFromArray (_items apply {[_x,(round ((_x call _getPriceFunc) * _itemPriceMult))]});
            [
                /*QST_REWARD_PER_ITEM_PERCENTAGE:*/(round (_itemPriceMult*100)),
                /*QST_REWARD_PER_ITEM_PRICE_MAP:*/_priceMap
            ]
        };
        default {
            (format ["NWG_QST_SER_CreateNew: Unknown reward type: '%1' for quest type: '%2'",_reward,_questType]) call NWG_fnc_logError;
            NWG_QST_Settings get "QUEST_DEFAULT_REWARD"
        };
    };

    //Create quest marker
    private _marker = _targetObj call {
        // private _object = _this;
        private _markerName = format ["NWG_QST_Marker_%1",(round time)];//Hack to get a unique marker name
        private _marker = createMarkerLocal [_markerName,_this];
        _marker setMarkerShapeLocal "icon";
        _marker setMarkerTypeLocal (NWG_QST_Settings get "MARKER_TYPE");
        _marker setMarkerColorLocal (NWG_QST_Settings get "MARKER_COLOR");
        _marker setMarkerSize [(NWG_QST_Settings get "MARKER_SIZE"),(NWG_QST_Settings get "MARKER_SIZE")];
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
    private _locKey = (NWG_QST_Settings get "LOC_QUEST_DONE") param [_questType,""];
    if (_locKey isEqualTo "") exitWith {
        (format ["NWG_QST_SER_OnQuestDone: No localization key found for quest type: '%1'",_questType]) call NWG_fnc_logError;
    };
    if (_locKey isEqualTo false) exitWith {};//Chat message disabled for this quest type
    private _winnerStr = if (_playerName isNotEqualTo QST_UNKNOWN_WINNER)
        then {_playerName}
        else {NWG_QST_Settings get "LOC_UNKONW_WINNER"};
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

    //Notify clients (in separate scope to avoid breaking rewarding in case of errors)
    call {
        private _questType = NWG_QST_Data param [QST_DATA_TYPE,-1];
        if (_questType isEqualTo -1) exitWith {
            (format ["NWG_QST_SER_OnQuestClosed: No quest type found"]) call NWG_fnc_logError;
        };
        private _locKey = (NWG_QST_Settings get "LOC_QUEST_CLOSED") param [_questType,""];
        if (_locKey isEqualTo "") exitWith {
            (format ["NWG_QST_SER_OnQuestClosed: No localization key found for quest type: '%1'",_questType]) call NWG_fnc_logError;
        };
        if (_locKey isEqualTo false) exitWith {};//Chat message disabled for this quest type
        private _winnerStr = if (_playerName isNotEqualTo QST_UNKNOWN_WINNER)
            then {_playerName}
            else {NWG_QST_Settings get "LOC_UNKONW_WINNER"};
        [_locKey,_winnerStr] call NWG_fnc_sideChatAll;
    };

    //Reward players
    private _funcRewardPlayer = NWG_QST_Settings get "FUNC_REWARD_PLAYER";
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

/*Copy of NWG_ACP_OnWounded with some changes*/
NWG_QST_SER_OnWounded = {
    // params ["_unit","_selection","_damage","_source","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","_sel","_dmg"];
    _dmg = _dmg min 0.75;//Clamp damage

    switch (true) do {
        case (!alive _unit): {};//Bypass for dead units
        case (_dmg < 0.1): {_dmg = 0};//Drop minor damage
        case (_sel isNotEqualTo ""): {};//Bypass non-body hits

        /*If already wounded*/
        case ((incapacitatedState _unit) isNotEqualTo ""): {
            /*Decrease 'brake' counter*/
            private _toBreak = _unit getVariable ["QST_toBreak",0];
            if (_toBreak > 0) then {_unit setVariable ["QST_toBreak",(_toBreak - 1),true]};
        };

        /*Else - wound unit*/
        default {
            /*Wound the unit*/
            _unit setUnconscious true;

            /*Decrease 'brake' counter*/
            private _toBreak = _unit getVariable ["QST_toBreak",0];
            if (_toBreak > 0) then {_unit setVariable ["QST_toBreak",(_toBreak - 1),true]};
        };
    };

    _dmg
};