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
["default","\A3\ui_f\data\igui\cfg\simpleTasks\types\default_ca.paa"]
["armor","\A3\ui_f\data\igui\cfg\simpleTasks\types\armor_ca.paa"]
["attack","\A3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa"]
["backpack","\A3\ui_f\data\igui\cfg\simpleTasks\types\backpack_ca.paa"]
["boat","\A3\ui_f\data\igui\cfg\simpleTasks\types\boat_ca.paa"]
["box","\A3\ui_f\data\igui\cfg\simpleTasks\types\box_ca.paa"]
["car","\A3\ui_f\data\igui\cfg\simpleTasks\types\car_ca.paa"]
["container","\A3\ui_f\data\igui\cfg\simpleTasks\types\container_ca.paa"]
["danger","\A3\ui_f\data\igui\cfg\simpleTasks\types\danger_ca.paa"]
["defend","\A3\ui_f\data\igui\cfg\simpleTasks\types\defend_ca.paa"]
["destroy","\A3\ui_f\data\igui\cfg\simpleTasks\types\destroy_ca.paa"]
["documents","\A3\ui_f\data\igui\cfg\simpleTasks\types\documents_ca.paa"]
["download","\A3\ui_f\data\igui\cfg\simpleTasks\types\download_ca.paa"]
["exit","\A3\ui_f\data\igui\cfg\simpleTasks\types\exit_ca.paa"]
["getin","\A3\ui_f\data\igui\cfg\simpleTasks\types\getin_ca.paa"]
["getout","\A3\ui_f\data\igui\cfg\simpleTasks\types\getout_ca.paa"]
["heal","\A3\ui_f\data\igui\cfg\simpleTasks\types\heal_ca.paa"]
["heli","\A3\ui_f\data\igui\cfg\simpleTasks\types\heli_ca.paa"]
["help","\A3\ui_f\data\igui\cfg\simpleTasks\types\help_ca.paa"]
["intel","\A3\ui_f\data\igui\cfg\simpleTasks\types\intel_ca.paa"]
["interact","\A3\ui_f\data\igui\cfg\simpleTasks\types\interact_ca.paa"]
["kill","\A3\ui_f\data\igui\cfg\simpleTasks\types\kill_ca.paa"]
["land","\A3\ui_f\data\igui\cfg\simpleTasks\types\land_ca.paa"]
["listen","\A3\ui_f\data\igui\cfg\simpleTasks\types\listen_ca.paa"]
["map","\A3\ui_f\data\igui\cfg\simpleTasks\types\map_ca.paa"]
["meet","\A3\ui_f\data\igui\cfg\simpleTasks\types\meet_ca.paa"]
["mine","\A3\ui_f\data\igui\cfg\simpleTasks\types\mine_ca.paa"]
["move","\A3\ui_f\data\igui\cfg\simpleTasks\types\move_ca.paa"]
["move1","\A3\ui_f\data\igui\cfg\simpleTasks\types\move1_ca.paa"]
["move2","\A3\ui_f\data\igui\cfg\simpleTasks\types\move2_ca.paa"]
["move3","\A3\ui_f\data\igui\cfg\simpleTasks\types\move3_ca.paa"]
["move4","\A3\ui_f\data\igui\cfg\simpleTasks\types\move4_ca.paa"]
["move5","\A3\ui_f\data\igui\cfg\simpleTasks\types\move5_ca.paa"]
["navigate","\A3\ui_f\data\igui\cfg\simpleTasks\types\navigate_ca.paa"]
["plane","\A3\ui_f\data\igui\cfg\simpleTasks\types\plane_ca.paa"]
["radio","\A3\ui_f\data\igui\cfg\simpleTasks\types\radio_ca.paa"]
["rearm","\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa"]
["refuel","\A3\ui_f\data\igui\cfg\simpleTasks\types\refuel_ca.paa"]
["repair","\A3\ui_f\data\igui\cfg\simpleTasks\types\repair_ca.paa"]
["rifle","\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa"]
["run","\A3\ui_f\data\igui\cfg\simpleTasks\types\run_ca.paa"]
["scout","\A3\ui_f\data\igui\cfg\simpleTasks\types\scout_ca.paa"]
["search","\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa"]
["takeoff","\A3\ui_f\data\igui\cfg\simpleTasks\types\takeoff_ca.paa"]
["talk","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa"]
["talk1","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk1_ca.paa"]
["talk2","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk2_ca.paa"]
["talk3","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk3_ca.paa"]
["talk4","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk4_ca.paa"]
["talk5","\A3\ui_f\data\igui\cfg\simpleTasks\types\talk5_ca.paa"]
["target","\A3\ui_f\data\igui\cfg\simpleTasks\types\target_ca.paa"]
["truck","\A3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa"]
["unknown","\A3\ui_f\data\igui\cfg\simpleTasks\types\unknown_ca.paa"]
["upload","\A3\ui_f\data\igui\cfg\simpleTasks\types\upload_ca.paa"]
["use","\A3\ui_f\data\igui\cfg\simpleTasks\types\use_ca.paa"]
["wait","\A3\ui_f\data\igui\cfg\simpleTasks\types\wait_ca.paa"]
["walk","\A3\ui_f\data\igui\cfg\simpleTasks\types\walk_ca.paa"]
["whiteboard","\A3\ui_f\data\igui\cfg\simpleTasks\types\whiteboard_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\A_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\B_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\C_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\D_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\E_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\F_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\G_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\H_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\I_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\J_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\K_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\L_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\M_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\N_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\O_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\P_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\Q_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\R_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\S_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\T_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\U_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\V_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\W_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\X_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\Y_ca.paa"]
["","\A3\ui_f\data\igui\cfg\simpleTasks\letters\Z_ca.paa"]
["airdrop","\A3\ui_f_orange\data\cfgTaskTypes\airdrop_ca.paa"]
*/