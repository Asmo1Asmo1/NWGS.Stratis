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

//Checks if player can close quest
//params: _npcName - name of the NPC quest is assigned to
//returns: boolean - true if player can close quest, false otherwise
NWG_fnc_qstCanCloseQuest = {
    // private _npcName = _this;
    _this call NWG_QST_CLI_CanCloseQuest
};

//Closes quest
//params: _npcName - name of the NPC quest is assigned to
//returns: nothing
NWG_fnc_qstCloseQuest = {
    // private _npcName = _this;
    _this call NWG_QST_CLI_CloseQuest
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

NWG_fnc_qstOnUntieWoundedDone = {
	// private _targetObj = _this;
    if (!hasInterface) exitWith {};
    if (isNil "NWG_QST_CLI_OnUntieWoundedDone") exitWith {};
    _this call NWG_QST_CLI_OnUntieWoundedDone;
};