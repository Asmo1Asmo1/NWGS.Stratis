//================================================================================================================
//Hint show all task icons with their names
//Author: Sa-Matra
//see: https://discord.com/channels/105462288051380224/105462984087728128/1228359976343306310
// call NWG_INVUI_HintAllTaskIcons
NWG_INVUI_HintAllTaskIcons = {
    private _compose = [];
    {
        _compose pushBack (composeText [formatText [if(_forEachIndex % 2 == 0) then {"%2 %1"} else {"%1 %2"}
            ,configName _x
            ,image getText(_x >> "icon")
        ]] setAttributes [
            "align", if(_forEachIndex % 2 == 0) then {"left"} else {"right"}
        ]);
        if(_forEachIndex % 2 == 1) then {_compose pushBack lineBreak};
    } forEach ("true" configClasses (configFile >> "CfgTaskTypes"));
    hint composeText _compose;
};

//Dump all task icons to choose from
// call NWG_INVUI_GetAllTaskIcons
NWG_INVUI_GetAllTaskIcons = {
    private _icons = ("true" configClasses (configFile >> "CfgTaskTypes"))
        apply {[getText(_x >> "displayName"),getText(_x >> "icon")]};
    _icons call NWG_fnc_testDumpToRptAndClipboard;
};

/*
["airdrop","\A3\ui_f_orange\data\cfgTaskTypes\airdrop_ca.paa"]
["help","\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa"]
["meet","\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"]
["documents","\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa"]
["whiteboard","\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa"]
["use","\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"]
*/

//Get all sounds from CfgSound (configfile >> "CfgSounds" >> "WoundedGuyB_07") <- "WoundedGuyB_07" is the sound file name
// call NWG_INVUI_GetAllSounds
NWG_INVUI_GetAllSounds = {
    private _sounds = ("true" configClasses (configFile >> "CfgSounds")) apply {configName _x};
    _sounds call NWG_fnc_testDumpToRptAndClipboard;
};

//Good sounds:
/*
    "rearm"
    "click"
    "ClickSoft"
    "Scared_Animal2"
    "WeaponRestedOn"
    "WeaponRestedOff"
    "assemble_target"
    "surrender_fall"
    "surrender_stand_up"
    "Place_Flag"
*/
/*
    Can we use it later?
    "Orange_Choice_Select"//Paper
    "Orange_Leaflet_Investigate_01"//Paper
    "Orange_Leaflet_Investigate_02"//Paper
    "Orange_Leaflet_Investigate_03"//Paper
    "Orange_Access_FM"//Computer
    "Orange_Read_Article"//Computer
    "Orange_Start_Sim"//Computer
    "Orange_Lights_On"//Switch
    "Orange_Lights_Off"//Switch
*/

/*
    Money candidate sounds:
    "FD_Target_PopUp_Small_F"
    "soundExpand"
    "soundCollapse"
    "click"
    "ClickSoft"
    "WeaponRestedOn"
    "WeaponRestedOff"
*/
