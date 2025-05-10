/*Any -> Server*/
//Creates new quest
//params: _missionObjects - array of objects as [_bldgs,_furns,_decos,_units,_vehcs] (_turrets and _mines are ommitted and not used)
//returns: boolean - true if quest was created successfully, false otherwise
NWG_fnc_qstCreateNew = {
	// private _missionObjects = _this;
    _this call NWG_QST_SER_CreateNew
};

//Clears all quests data
//params: none
//returns: nothing
NWG_fnc_qstClearAll = {
    call NWG_QST_SER_ClearAll
};

/*Server -> Client*/
//Notifies client about new quest
//params: _questData - array of quest data as [_questType,_npc,_targetObj,_targetClassname,_reward,_marker]
//returns: nothing
NWG_fnc_qstOnQuestCreated = {
    // private _questData = _this;
    if (!hasInterface) exitWith {};//Only clients can receive this notification
    _this call NWG_QST_CLI_OnQuestCreated;
};

/*Any -> Client*/
//Checks if NPC has active quest assigned
//params: _npcName - name of the NPC quest is assigned to
//returns: boolean - true if NPC has active quest assigned, false otherwise
NWG_fnc_qstHasQuest = {
    // private _npcName = _this;
    _this call NWG_QST_CLI_IsQuestActiveForNpc
};

//Attempts to close quest
//note: in case of good/bad ending will assign reward and report to server
//params: _npcName - name of the NPC quest is assigned to
//returns: close result: 0 - quest is not done, 1 - good ending, -1 - bad ending, FALSE - error occurred
NWG_fnc_qstTryCloseQuest = {
    // private _npcName = _this;
    _this call NWG_QST_CLI_TryCloseQuest
};

//Returns quest data
//params: none
//returns: array of quest data as [_questType,_npc,_targetObj,_targetClassname,_reward,_marker] OR false if quest is not active
NWG_fnc_qstGetQuestData = {
    call NWG_QST_CLI_GetQuestData
};

/*Client -> Server*/
//Informs server that quest is done
//params: _player - player object
//returns: nothing
NWG_fnc_qstOnQuestDone = {
    // private _player = _this;
    _this call NWG_QST_SER_OnQuestDone
};

//Informs server that quest is closed
//params:
// - _player - player object
// - _reward - reward amount
//returns: nothing
NWG_fnc_qstOnQuestClosed = {
    // params ["_player","_reward"];
    _this call NWG_QST_SER_OnQuestClosed
};

/*Utils*/
NWG_fnc_qstOnHackDone = {
	// private _targetObj = _this;
    if (!hasInterface) exitWith {};
    if (isNil "NWG_QST_CLI_OnHackDone") exitWith {};
    _this call NWG_QST_CLI_OnHackDone;
};

NWG_fnc_qstOnInterrogateTied = {
	params ["_targetObj","_player"];
    if (isNull _targetObj || {!alive _targetObj}) exitWith {
        (format ["NWG_fnc_qstOnInterrogateTied: Invalid target object: '%1'",_targetObj]) call NWG_fnc_logError;
    };
    if !(local _targetObj) exitWith {
        _this remoteExec ["NWG_fnc_qstOnInterrogateTied",_targetObj];//Run where target is local
    };

    //Check unconscious state
    private _isWounded = (incapacitatedState _targetObj) isNotEqualTo "";
    if (_isWounded) then {
        _targetObj setUnconscious false;
        _targetObj switchMove [""];
    };

    //Position target where player is looking
    private _playerPos = getPosASL _player;
    private _playerDir = getDir _player;
    private _forwardX = (sin _playerDir) * 0.3;
    private _forwardY = (cos _playerDir) * 0.3;
    _targetObj setPosASL [
        (_playerPos#0) + _forwardX,
        (_playerPos#1) + _forwardY,
        (_playerPos#2)
    ];
    _targetObj setDir _playerDir;

    //Play animation
    _targetObj disableAI "ALL";
    _targetObj playMoveNow "Acts_ExecutionVictim_Loop";
};

NWG_fnc_qstOnInterrogateAction = {
	params ["_targetObj","_animFlag"];
    if (isNull _targetObj || {!alive _targetObj}) exitWith {
        (format ["NWG_fnc_qstOnInterrogateAction: Invalid target object: '%1'",_targetObj]) call NWG_fnc_logError;
    };
    if !(local _targetObj) exitWith {
        _targetObj remoteExec ["NWG_fnc_qstOnInterrogateAction",_targetObj];//Run where target is local
    };

    //Play animation
    private _anim = ["Acts_ExecutionVictim_Backhand","Acts_ExecutionVictim_Forehand"] select _animFlag;
    _targetObj playMoveNow _anim;//Immediate animation
    _targetObj playMove "Acts_ExecutionVictim_Loop";//Fallback to loop
};

NWG_fnc_qstOnUntieWoundedDone = {
	// private _targetObj = _this;
    if (!hasInterface) exitWith {};
    if (isNil "NWG_QST_CLI_OnUntieWoundedDone") exitWith {};
    _this call NWG_QST_CLI_OnUntieWoundedDone;
};