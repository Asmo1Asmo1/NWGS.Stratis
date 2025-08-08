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
NWG_QST_lastQuestTypes = [];

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
        //First filter by selectBy
        private _possibleTargets = (_missionObjects select _objCat) select _selectBy;
        if ((count _possibleTargets) == 0) exitWith {};
        //Then filter by general criteria
        _possibleTargets = _possibleTargets select {
            !isNull _x && {
            !isSimpleObject _x && {
            ((getPosASL _x)#2) >= 0}}
        };
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
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "HACK_DATA_TARGETS")};
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
    /*Electronics quest*/
    if (QST_TYPE_ELECTRONICS in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "ELECTRONICS_ITEMS_OBJECTS")};
        [QST_TYPE_ELECTRONICS,OBJ_CAT_DECO,_selectBy] call _fillDice;
    };
    /*Weapon quest*/
    if (QST_TYPE_WEAPON in _enabledQuests) then {
        /*This one is special - we need to select most expensive weapon from what the mission has*/
        private _getPriceFunc = NWG_QST_Settings get "FUNC_GET_ITEM_PRICE";
        private _mostContainer = objNull;
        private _mostWeapon = "";
        private _mostPrice = 0;
        private ["_container","_price"];
        {
            _container = _x;
            {
                _price = _x call _getPriceFunc;
                if (_price > _mostPrice) then {
                    _mostContainer = _container;
                    _mostWeapon = _x;
                    _mostPrice = _price;
                };
            } forEach (weaponCargo _x);
        } forEach ((_missionObjects#OBJ_CAT_DECO) select {
            !isSimpleObject _x && {
            _x canAdd "Antibiotic"}
        });
        if (isNull _mostContainer) exitWith {};//Nothing found
        for "_i" from 1 to (_diceWeights select QST_TYPE_WEAPON) do {
            _dice pushBack [QST_TYPE_WEAPON,_mostContainer,_mostWeapon];
        };
    };
    /*Wounded quest*/
    if (QST_TYPE_WOUNDED in _enabledQuests) then {
        /*We need to find a unit that will be replaced with a wounded civilian*/
        private _possibleTargets = (_missionObjects#OBJ_CAT_UNIT) select {
            isNull (objectParent _x) && {/*Only on-foot units*/
            ((getPosASL _x)#2) >= 0}/*Exclude units underwater*/
        };
        if ((count _possibleTargets) == 0) exitWith {};
        private _target = selectRandom _possibleTargets;
        for "_i" from 1 to (_diceWeights select QST_TYPE_WOUNDED) do {
            _dice pushBack [QST_TYPE_WOUNDED,_target,""];
        };
    };
    /*Infection quest*/
    if (QST_TYPE_INFECTION in _enabledQuests) then {
        private _possibleTargets = (_missionObjects#OBJ_CAT_UNIT) select {(typeOf _x) in (NWG_QST_Settings get "INFECTED_TARGETS")};
        if ((count _possibleTargets) == 0) exitWith {};
        for "_i" from 1 to (_diceWeights select QST_TYPE_INFECTION) do {
            _dice pushBack [QST_TYPE_INFECTION,_possibleTargets,""];
        };
    };
    /*Burn down quest*/
    if (QST_TYPE_BURNDOWN in _enabledQuests) then {
        /*Find supply boxes even if they are simple objects - we'll replace them later*/
        private _possibleTargets = (_missionObjects#OBJ_CAT_DECO) select {
            !isNull _x && {
            ((getPosASL _x)#2) >= 0 && {
            (typeOf _x) in (NWG_QST_Settings get "BURNDOWN_TARGETS")}}
        };
        if ((count _possibleTargets) == 0) exitWith {};
        private _target = selectRandom _possibleTargets;
        for "_i" from 1 to (_diceWeights select QST_TYPE_BURNDOWN) do {
            _dice pushBack [QST_TYPE_BURNDOWN,_target,(typeOf _target)];
        };
    };
    /*Tools quest*/
    if (QST_TYPE_TOOLS in _enabledQuests) then {
        private _selectBy = {(typeOf _x) in (NWG_QST_Settings get "TOOLS_ITEMS_OBJECTS")};
        [QST_TYPE_TOOLS,OBJ_CAT_DECO,_selectBy] call _fillDice;
    };

    //Check dice
    if ((count _dice) == 0) exitWith {
        "NWG_QST_SER_CreateNew: Could not create any quests" call NWG_fnc_logError;
        call NWG_QST_SER_ClearAll;//Clear any remaining quest data
        false;
    };

    //Remove last quest type(s) to not repeat it second time in a row
    if ((count _dice) > 1 && {(count NWG_QST_lastQuestTypes) > 0}) then {
        private _toKeep = _dice select {!((_x#QST_DATA_TYPE) in NWG_QST_lastQuestTypes)};
        if ((count _toKeep) > 0) then {_dice = _toKeep};//Replace dice with filtered results
    };

    //Roll the dice
    _dice = _dice call NWG_fnc_arrayShuffle;//Works better than selectRandom
    (_dice select 0) params ["_questType","_targetObj","_targetClassname"];
    _dice resize 0;//Clear the dice

    //Remember last quest type(s)
    NWG_QST_lastQuestTypes pushBack _questType;
    if ((count NWG_QST_lastQuestTypes) > (NWG_QST_Settings get "QUETS_IGNORE_LAST")) then {
        reverse NWG_QST_lastQuestTypes;
        NWG_QST_lastQuestTypes resize (NWG_QST_Settings get "QUETS_IGNORE_LAST");
        reverse NWG_QST_lastQuestTypes;
    };

    //Run type-specific logic
    switch (_questType) do {
        case QST_TYPE_INTERROGATE: {
            //Make sure target can not be killed, only wounded
            _targetObj removeAllEventHandlers "HandleDamage";//Remove any other logic that may have been added
            _targetObj addEventHandler ["HandleDamage",{_this call NWG_QST_SER_OnWounded}];//Handle damage (+increases 'brake' counter)
            //Set initial 'brake' counter
            private _toBreak = round (random (NWG_QST_Settings get "INTERROGATE_BREAK_LIMIT"));
            _targetObj setVariable ["QST_toBreak",_toBreak,true];
            //Setup interrogate target for current and JIP players
            [_targetObj,"NWG_QST_CLI_OnInterrogateCreated",[]] call NWG_fnc_rqAddCommand;
            //Setup failure
            _targetObj addEventHandler ["Killed",{
                params ["_targetObj"/*,"_killer","_instigator","_useEffects"*/];
                if (NWG_QST_State isEqualTo QST_STATE_IN_PROGRESS) then {call NWG_QST_SER_OnQuestFailed};
                _targetObj removeEventHandler [_thisEvent,_thisEventHandler];
            }];
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
        case QST_TYPE_WOUNDED: {
            //Replace unit with a wounded civilian
            _targetObj = _targetObj call NWG_QST_SER_ReplaceWithWoundedCivilian;
            _targetClassname = (typeOf _targetObj);

            //Setup command for current and JIP players
            [_targetObj,"NWG_QST_CLI_OnWoundedCreated",[]] call NWG_fnc_rqAddCommand;
            //Setup failure
            _targetObj addEventHandler ["Killed",{
                params ["_targetObj"/*,"_killer","_instigator","_useEffects"*/];
                if (NWG_QST_State isEqualTo QST_STATE_IN_PROGRESS) then {call NWG_QST_SER_OnQuestFailed};
                _targetObj removeEventHandler [_thisEvent,_thisEventHandler];
            }];
        };
        case QST_TYPE_INFECTION: {
            //Track player's actions towards infected
            private _infectedUnits = _targetObj;
            _infectedUnits call NWG_QST_SER_OnInfectionCreated;
            //Re-write variables
            _targetObj = selectRandom _infectedUnits;
            _targetClassname = (typeOf _targetObj);
        };
        case QST_TYPE_BURNDOWN: {
            //Replace with interactable object if simple
            if (isSimpleObject _targetObj) then {
                private _pos = getPosASL _targetObj;
                private _dir = getDir _targetObj;
                deleteVehicle _targetObj;
                private _newObj = createVehicle [_targetClassname,_pos,[],0,"CAN_COLLIDE"];
                _newObj setDir _dir;
                _newObj setPosASL _pos;
                _newObj call NWG_fnc_clearContainerCargoGlobal;//Remove any cargo
                _targetObj = _newObj;
            };

            //Set initial state
            _targetObj setVariable ["QST_isBurned",false,true];
            //Setup burning for current and JIP players
            [_targetObj,"NWG_QST_CLI_OnBurnCreated",[]] call NWG_fnc_rqAddCommand;
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
NWG_QST_SER_OnQuestFailed = {
    if (NWG_QST_State != QST_STATE_IN_PROGRESS) exitWith {
        (format ["NWG_QST_SER_OnQuestFailed: Quest is not in progress: '%1'",NWG_QST_State]) call NWG_fnc_logError;
    };
    NWG_QST_State = QST_STATE_FAILED;
    publicVariable "NWG_QST_State";
};

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

NWG_QST_SER_OnQuestClose = {
    params ["_player","_reward"];
    if !(NWG_QST_State in [QST_STATE_IN_PROGRESS,QST_STATE_DONE,QST_STATE_FAILED]) exitWith {
        (format ["NWG_QST_SER_OnQuestClose: Quest state unexpected: '%1'",NWG_QST_State]) call NWG_fnc_logError;
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
            (format ["NWG_QST_SER_OnQuestClose: No quest type found"]) call NWG_fnc_logError;
        };
        private _locKey = (NWG_QST_Settings get "LOC_QUEST_CLOSED") param [_questType,""];
        if (_locKey isEqualTo "") exitWith {
            (format ["NWG_QST_SER_OnQuestClose: No localization key found for quest type: '%1'",_questType]) call NWG_fnc_logError;
        };
        if (_locKey isEqualTo false) exitWith {};//Chat message disabled for this quest type
        private _winnerStr = if (_playerName isNotEqualTo QST_UNKNOWN_WINNER)
            then {_playerName}
            else {NWG_QST_Settings get "LOC_UNKONW_WINNER"};
        [_locKey,_winnerStr] call NWG_fnc_sideChatAll;
    };

    //Reward players
    if (_reward isEqualTo false || {NWG_QST_State isEqualTo QST_STATE_FAILED}) exitWith {};//No reward or failed quest
    private _funcRewardPlayer = NWG_QST_Settings get "FUNC_REWARD_PLAYER";
    private _funcRewardablePlayer = NWG_QST_Settings get "FUNC_REWARDABLE_PLAYER";
    {
        [_x,_reward] call _funcRewardPlayer;
    } forEach ((units (group _player)) select {_x call _funcRewardablePlayer});
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
NWG_QST_SER_nextDamageAt = 0;
NWG_QST_SER_OnWounded = {
    // params ["_unit","_selection","_damage","_source","_projectile","_hitIndex","_instigator","_hitPoint"];
    params ["_unit","_sel","_dmg"];

    switch (true) do {
        case (!alive _unit): {};//Bypass for dead units
        case (_dmg < 0.1): {_dmg = 0};//Drop minor damage
        case (_sel isNotEqualTo ""): {_dmg = _dmg min 0.75};//Clamp damage for non-body hits
        case (time < NWG_QST_SER_nextDamageAt): {_dmg = _dmg min 0.75};//Repeated damage
        default {
            NWG_QST_SER_nextDamageAt = time + 0.25;
            private _isWounded = (incapacitatedState _unit) isNotEqualTo "";
            private _isTied = _unit getVariable ["QST_isTied",false];
            private _toBreak = _unit getVariable ["QST_toBreak",0];
            private _isDead = _toBreak <= (NWG_QST_Settings get "INTERROGATE_KILL_LIMIT");

            switch (true) do {
                case (_isDead): {
                    /*Unit is dead - disable actions and pass full damage*/
                    _unit setVariable ["QST_isTied",-1,true];//Invalid value so that actions conditions are not met
                    _unit removeEventHandler [_thisEvent,_thisEventHandler];//Remove event handler
                    _dmg = 1;//Pass full damage
                };
                case (!_isWounded && !_isTied): {
                    /*Unit is standing - put them on the ground*/
                    _unit setUnconscious true;//Put on the ground
                    _unit setVariable ["QST_toBreak",(_toBreak - 1),true];//Decrease 'brake' counter
                    _dmg = _dmg max 0.75;//Clamp damage
                };
                case (_isWounded || _isTied): {
                    /*Unit is wounded or tied up*/
                    _unit setVariable ["QST_toBreak",(_toBreak - 1),true];//Decrease 'brake' counter
                    _dmg = _dmg max 0.75;//Clamp damage
                };
                default {_dmg = _dmg max 0.75};//Clamp damage
            };
        };
    };

    _dmg
};

/*Replace with wounded civilian*/
NWG_QST_SER_ReplaceWithWoundedCivilian = {
    private _targetObj = _this;

    //Get random unit type from config (exempt from 'BIS_fnc_moduleCivilianPresence')
    private _cfg = configFile >> "CfgVehicles" >> "ModuleCivilianPresence_F" >> "UnitTypes";
    private _cfgUnitTypes = _cfg >> worldName;
    if (isNull _cfgUnitTypes) then { _cfgUnitTypes = _cfg >> "other" };
    private _unitType = selectRandom (getArray _cfgUnitTypes);
    if (isNil "_unitType") exitWith {
        (format ["NWG_QST_SER_CreateNew: No unit type found for quest type: '%1'",_questType]) call NWG_fnc_logError;
        false;
    };

    //Replace selected unit with a wounded civilian
    private _wounded = createAgent [_unitType,_targetObj,[],0,"CAN_COLLIDE"];
    private _pos = getPosASL _targetObj;
    private _dir = getDir _targetObj;
    deleteVehicle _targetObj;
    _wounded setDir _dir;

    //Apply wounded state
    _wounded setDamage 0.5;
    _wounded playMoveNow "Acts_ExecutionVictim_Loop";

    //Compensate position shifting because of animation
    _wounded setPosASL (_pos vectorAdd [((sin _dir) * -0.7),((cos _dir) * -0.7),0]);

    //return
    _wounded
};

/*Infection utils*/
NWG_QST_SER_OnInfectionCreated = {
    private _infectedUnits = _this;

    //Set initial state
    NWG_QST_InfectionData = [(count _infectedUnits),/*healed:*/0,/*killed:*/0];
    publicVariable "NWG_QST_InfectionData";

    //Setup event handlers
    {
        _x setVariable ["QST_isHealed",false];
        _x addEventHandler ["HandleHeal",{_this call NWG_QST_SER_OnInfectionHealed; false}];
        _x addEventHandler ["Killed",{_this call NWG_QST_SER_OnInfectionKilled}];
    } forEach _infectedUnits;
};
NWG_QST_SER_OnInfectionHealed = {
    // params ["_infectedUnit","_healer","_isMedic"];
    private _infectedUnit = _this#0;
    if (!alive _infectedUnit) exitWith {};//Bypass for dead units
    if (_infectedUnit getVariable ["QST_isHealed",false]) exitWith {};//Already healed
    //Update states
    _infectedUnit setVariable ["QST_isHealed",true];
    NWG_QST_InfectionData set [1,((NWG_QST_InfectionData select 1) + 1)];//Increment healed counter
    publicVariable "NWG_QST_InfectionData";
    //Remove event handler
    _infectedUnit removeEventHandler [_thisEvent,_thisEventHandler];
};
NWG_QST_SER_OnInfectionKilled = {
    // params ["_targetObj","_killer","_instigator","_useEffects"];
    private _infectedUnit = _this#0;
    //Check if previously healed
    if (_infectedUnit getVariable ["QST_isHealed",false]) then {
        NWG_QST_InfectionData set [1,((NWG_QST_InfectionData select 1) - 1)];//Decrement healed counter if previously healed
    };
    //Update states
    NWG_QST_InfectionData set [2,((NWG_QST_InfectionData select 2) + 1)];//Increment killed counter
    publicVariable "NWG_QST_InfectionData";
    //Remove event handler
    _infectedUnit removeEventHandler [_thisEvent,_thisEventHandler];//Remove event handler
};
