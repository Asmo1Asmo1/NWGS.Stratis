/*Other systems->Any*/
/*Functions that can be called from both server and client sides*/
//Set NPC name
//params:
// - _npc - npc object
// - _npcName - npc name
NWG_fnc_dlgSetNpcName = {
    params ["_npc","_npcName"];
    if !(_npc isEqualType objNull) exitWith {
        (format ["NWG_fnc_dlgSetNpcName: Invalid npc object: %1",_npc]) call NWG_fnc_logError;
    };
    if (isNull _npc) exitWith {
        (format ["NWG_fnc_dlgSetNpcName: NPC object is null: %1",_npc]) call NWG_fnc_logError;
    };
    _npc setVariable ["NWG_DLG_NpcName",_npcName,true];
};

//Get NPC name
//params:
// - _npc - npc object
//returns: npc name or "" if not found
NWG_fnc_dlgGetNpcName = {
    // private _npc = _this;
    _this getVariable ["NWG_DLG_NpcName",""];
};

//Get NPC name localized
//params:
// - _npc - npc object
//returns: npc name or "" if not found
NWG_fnc_dlgGetNpcNameLocalized = {
    // private _npc = _this;
    private _npcName = _this call NWG_fnc_dlgGetNpcName;
    if (_npcName isEqualTo "") exitWith {""};
    private _locKey = (NWG_DLG_CLI_Settings get "LOCALIZATION") getOrDefault [_npcName,""];
    if (_locKey isEqualTo "") exitWith {""};
    _locKey call NWG_fnc_localize;
};

/*Other systems->Client side*/
//Open dialogue by npc name
//params:
// - _npcName - npc name
NWG_fnc_dlgOpenByName = {
    // private _npcName = _this;
    _this call NWG_DLG_CLI_OpenDialogue;
};

//Open dialogue with npc object
//note: for this to work, npc name must be set using NWG_fnc_dlgSetNpcName
//note: despite single param, the 'params' syntax is used to make it compatible with 'addAction'
//params:
// - _npc - npc object
NWG_fnc_dlgOpenByNpc = {
    params ["_npc"];
    if (isNull _npc) exitWith {
        (format ["NWG_fnc_dlgOpenByNpc: NPC object is null: %1",_npc]) call NWG_fnc_logError;
    };
    private _npcName = _npc call NWG_fnc_dlgGetNpcName;
    if (_npcName isEqualTo "") exitWith {
        (format ["NWG_fnc_dlgOpenByNpc: NPC name not found: %1",_npc]) call NWG_fnc_logError;
    };
    _npcName call NWG_fnc_dlgOpenByName;
};

//Check if dialogue is open
//returns: true if dialogue is open, false otherwise
NWG_fnc_dlgIsOpen = {
    !(call NWG_DLG_CLI_IsUIClosed)
};
