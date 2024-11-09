/*
    Some settings of the mission are too complex, so instead we separate them into a new file for better management.
*/
[
    //==================================================================================================
    // Player Base settings
    ["PLAYER_BASE_BLUEPRINT","PlayerBase"],//Blueprint(s) page to build the base with using ukrep subsystem
    ["PLAYER_BASE_MARKERS",["o_unknown","loc_Tourism"]],//Markers to be placed at the player base position
    ["PLAYER_BASE_MARKERS_SIZE",1.25],//Size of the markers
    ["PLAYER_BASE_NPC_SETTINGS", createHashMapFromArray [
        /*TAXI*/["B_G_Story_Guerilla_01_F",[/*disarm:*/false,/*anim:*/"InBaseMoves_Lean1",/*addAction:*/false]],
        /*MECH*/["I_G_Story_Protagonist_F",[/*disarm:*/true,/*anim:*/["HubBriefing_ext_Contact","HubBriefing_loop","Acts_Explaining_EW_Idle01"],["#VSHOP_ACTION_TITLE#",{call NWG_fnc_vshopOpenPlatformShop}]]],
        /*TRDR*/["I_G_resistanceLeader_F" ,[/*disarm:*/true,/*anim:*/["HubSittingChairUA_idle2","HubSittingChairUA_idle3"],/*addAction:*/["#ISHOP_ACTION_TITLE#",{call NWG_fnc_ishopOpenShop}]]],
        /*MEDC*/["I_C_Soldier_Camo_F",[/*disarm:*/true,/*anim:*/"Acts_Gallery_Visitor_02",/*addAction:*/false]],
        /*COMM*/["I_E_Soldier_MP_F"  ,[/*disarm:*/false,/*anim:*/["Acts_millerCamp_A","Acts_millerCamp_C","acts_millerIdle"],/*addAction:*/["#MIS_ACTION_TITLE#",{call NWG_MIS_CLI_RequestMissionSelection}]]],
        /*ROOF*/["B_G_Captain_Ivan_F",[/*disarm:*/false,/*anim:*/false,/*addAction:*/false]]
    ]],

    //==================================================================================================
    // Mission settings
    ["MISSIONS_LIST_MIN_DISTANCE",100],//Min distance between missions to be added to the list (example: several variants of the same mission, only one will be added by distance rule)
    ["MISSIONS_OUTLINE_USE_ACTUAL_RAD",false],//If true - an actual radius of a mission will be used for map outline radius (may be misleading)
    ["MISSIONS_ENEMY_SIDE",west],//Side of the enemy groups (will it be always the same?)
    ["MISSIONS_ENEMY_FACTION","NATO"],//Faction of enemy groups (how will we add more factions? postponed question)
    ["MISSIONS_EMPTY_BLDG_PAGENAME","BldgEmpty"],//Pagename with blueprints to fill empty buildings with
    ["MISSIONS_DONE_COLOR","ColorGreen"],//Color to mark missions on the map as done
    ["MISSIONS_DONE_ALPHA",0.6],//Alpha value of 'done' map mark

    ["MISSIONS_PRESETS",[
        createHashMapFromArray [
            ["PresetName","#MIS_DIF_EASY#"],
            ["Difficulty","EASY"],
            ["MapMarker","mil_objective"],
            ["MapMarkerColor","ColorOrange"],
            ["MapMarkerSize",1.25],
            ["MapOutlineAlpha",0.6],
            ["MapOutlineRadius",100],
            ["UkrepFractalSteps",[
                /*root:*/[/*pageName:*/nil,   /*chances:*/[],   /*groupRules:*/[nil,nil,/*disablePath:*/false]],
                /*bldg:*/[/*pageName:*/"AUTO",/*chances:*/[
                    /*OBJ_TYPE_BLDG:*/1,
                    /*OBJ_TYPE_FURN:*/1,
                    /*OBJ_TYPE_DECO:*/1,
                    /*OBJ_TYPE_UNIT:*/(
                        createHashMapFromArray [
                            ["MinPercentage",0.10],
                            ["MaxPercentage",0.55],
                            ["MinCount",0],
                            ["MaxCount",10]
                        ]
                    ),
                    /*OBJ_TYPE_VEHC:*/[0.0,1.0],
                    /*OBJ_TYPE_TRRT:*/(
                        createHashMapFromArray [
                            ["MinPercentage",0.3],
                            ["MaxPercentage",0.8],
                            ["MinCount",0],
                            ["MaxCount",3]
                        ]
                    ),
                    /*OBJ_TYPE_MINE:*/1]],
                /*furn:*/[/*pageName:*/"AUTO",/*chances:*/[
                    /*OBJ_TYPE_BLDG:*/1,
                    /*OBJ_TYPE_FURN:*/1,
                    /*OBJ_TYPE_DECO:*/(
                        createHashMapFromArray [
                            ["IgnoreList",["Land_PCSet_01_case_F","Land_PCSet_01_keyboard_F","Land_PCSet_01_screen_F","Land_PCSet_Intel_01_F","Land_PCSet_Intel_02_F","Land_FlatTV_01_F"]],
                            ["MinPercentage",0.25],
                            ["MaxPercentage",0.65],
                            ["MinCount",2]
                        ]
                    ),
                    /*OBJ_TYPE_UNIT:*/1,
                    /*OBJ_TYPE_VEHC:*/1,
                    /*OBJ_TYPE_TRRT:*/1,
                    /*OBJ_TYPE_MINE:*/1
                ]]
            ]],
            ["UkrepMapBldgsLimit",7],//How many buildings in the mission area to decorate properly
            ["UkrepMapBldgsEmptyLimit",5],//How many leftover empty buildings to fill with partial, low object number decorations
            ["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
            ["DspawnRadiusMin",150],
            ["DspawnRadiusMax",250],
            ["DspawnGroupsMult",1],//Multiply number of ukrep groups by X to get dspawn groups
            ["DspawnGroupsMin",[2,3]],
            ["DspawnGroupsMax",[5,6]],
            ["ExhaustAfter",900],//Seconds after mission is exhausted (no more units will be spawned)
            ["",0]
        ],
        createHashMapFromArray [
            ["PresetName","#MIS_DIF_NORMAL#"],
            ["Difficulty","NORM"],
            ["MapMarker","mil_objective"],
            ["MapMarkerColor","ColorRed"],
            ["MapMarkerSize",1.25],
            ["MapOutlineAlpha",0.6],
            ["MapOutlineRadius",150],
            ["UkrepFractalSteps",[
                /*root:*/[/*pageName:*/nil,   /*chances:*/[],   /*groupRules:*/[nil,nil,/*disablePath:*/false]],
                /*bldg:*/[/*pageName:*/"AUTO",/*chances:*/[
                    /*OBJ_TYPE_BLDG:*/1,
                    /*OBJ_TYPE_FURN:*/1,
                    /*OBJ_TYPE_DECO:*/1,
                    /*OBJ_TYPE_UNIT:*/(
                        createHashMapFromArray [
                            ["MinPercentage",0.30],
                            ["MaxPercentage",0.75],
                            ["MinCount",1],
                            ["MaxCount",20]
                        ]
                    ),
                    /*OBJ_TYPE_VEHC:*/[0.0,1.0],
                    /*OBJ_TYPE_TRRT:*/(
                        createHashMapFromArray [
                            ["MinPercentage",0.5],
                            ["MaxPercentage",1.0],
                            ["MinCount",1],
                            ["MaxCount",3]
                        ]
                    ),
                    /*OBJ_TYPE_MINE:*/1]],
                /*furn:*/[/*pageName:*/"AUTO",/*chances:*/[
                    /*OBJ_TYPE_BLDG:*/1,
                    /*OBJ_TYPE_FURN:*/1,
                    /*OBJ_TYPE_DECO:*/(
                        createHashMapFromArray [
                            ["IgnoreList",["Land_PCSet_01_case_F","Land_PCSet_01_keyboard_F","Land_PCSet_01_screen_F","Land_PCSet_Intel_01_F","Land_PCSet_Intel_02_F","Land_FlatTV_01_F"]],
                            ["MinPercentage",0.45],
                            ["MaxPercentage",0.85],
                            ["MinCount",2]
                        ]
                    ),
                    /*OBJ_TYPE_UNIT:*/1,
                    /*OBJ_TYPE_VEHC:*/1,
                    /*OBJ_TYPE_TRRT:*/1,
                    /*OBJ_TYPE_MINE:*/1
                ]]
            ]],
            ["UkrepMapBldgsLimit",9],//How many buildings in the mission area to decorate properly
            ["UkrepMapBldgsEmptyLimit",3],//How many leftover empty buildings to fill with partial, low object number decorations
            ["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
            ["DspawnRadiusMin",150],
            ["DspawnRadiusMax",250],
            ["DspawnGroupsMult",2],//Multiply number of ukrep groups by X to get dspawn groups
            ["DspawnGroupsMin",[3,4]],
            ["DspawnGroupsMax",[8,9]],
            ["ExhaustAfter",1800],//Seconds after mission is exhausted (no more units will be spawned)
            ["",0]
        ]
    ]],

    //==================================================================================================
    // Escape endgame
    ["ESCAPE_MUSIC",["LeadTrack01_F_Mark","LeadTrack01_F_Heli","LeadTrack04_F_EXP","MainTheme_F_Tank","LeadTrack01_F_6th_Anniversary_Remix"]],
    ["ESCAPE_BASEATTACK_GROUPSCOUNT",[5,6,7,8]],

    ["",0]
]