/*
    Some settings of the mission are too complex, so instead we separate them into a new file for better management.
*/
[
    //==================================================================================================
    // Player Base settings
    ["PLAYER_BASE_ROOT","PlayerBase"],//Name of pre-placed map object (value of Object:Init -> Variable name) (mandatory for mission machine to work)
    ["PLAYER_BASE_BLUEPRINT","PlayerBase"],//Blueprint(s) page to build the base with using ukrep subsystem
    ["PLAYER_BASE_MARKERS",["o_unknown","loc_Tourism"]],//Markers to be placed at the player base position
    ["PLAYER_BASE_MARKERS_SIZE",1.25],//Size of the markers
    ["PLAYER_BASE_NPC_SETTINGS", createHashMapFromArray [
        /*TAXI*/["B_G_Story_Guerilla_01_F",[/*disarm:*/false,/*anim:*/"InBaseMoves_Lean1",/*addAction:*/false]],
        /*MECH*/["I_G_Story_Protagonist_F",[/*disarm:*/true,/*anim:*/["HubBriefing_ext_Contact","HubBriefing_loop","Acts_Explaining_EW_Idle01"],/*addAction:*/false]],
        /*TRDR*/["I_G_resistanceLeader_F" ,[/*disarm:*/true,/*anim:*/["HubSittingChairUA_idle2","HubSittingChairUA_idle3"],/*addAction:*/false]],
        /*MEDC*/["I_C_Soldier_Camo_F",[/*disarm:*/true,/*anim:*/"Acts_Gallery_Visitor_02",/*addAction:*/false]],
        /*COMM*/["I_E_Soldier_MP_F"  ,[/*disarm:*/false,/*anim:*/["Acts_millerCamp_A","Acts_millerCamp_C","acts_millerIdle"],/*addAction:*/["Select mission",{call NWG_MIS_CLI_RequestMissionSelection}]]],
        /*ROOF*/["B_G_Captain_Ivan_F",[/*disarm:*/false,/*anim:*/false,/*addAction:*/false]]
    ]],

    //==================================================================================================
    // Mission settings
    ["MISSIONS_LIST_MIN_DISTANCE",100],//Min distance between missions to be added to the list (example: several variants of the same mission, only one will be added by distance rule)
    ["MISSIONS_ENEMY_SIDE",west],//Side of the enemy groups
    ["MISSIONS_ENEMY_FACTION","NATO"],//Faction of enemy groups (how we will add more factions? let's postpone this question until need arises)
    ["MISSIONS_OUTLINE_ALPHA",0.5],//Alpha value of the mission outline marker
    ["MISSIONS_BUILD_MAPOBJECTS_LIMIT",10],//How many original map objects could be used for mission ukrep building

    ["MISSIONS_DIFFICULTY",[
        createHashMapFromArray [
            ["Name","#MIS_DIF_EASY#"],
            ["SelectionMarker","mil_objective"],
            ["SelectionMarker_Color","ColorOrange"],
            ["UkrepFractalSteps",[
                /*root:*/[/*pageName:*/nil,   /*blueprintName:*/"",/*chances:*/[]],
                /*bldg:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",/*chances:*/[
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
                /*furn:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",[
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
            ["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
            ["DspawnRadiusMin",150],
            ["DspawnRadiusMax",200],
            ["DspawnGroupsMult",1],//Multiply number of ukrep groups by X to get dspawn groups
            ["DspawnGroupsMin",2],
            ["DspawnGroupsMax",5]
        ],
        createHashMapFromArray [
            ["Name","#MIS_DIF_NORMAL#"],
            ["SelectionMarker","mil_objective"],
            ["SelectionMarker_Color","ColorRed"],
            ["UkrepFractalSteps",[
                /*root:*/[/*pageName:*/nil,   /*blueprintName:*/"",/*chances:*/[]],
                /*bldg:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",/*chances:*/[
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
                /*furn:*/[/*pageName:*/"AUTO",/*blueprintName:*/"",[
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
            ["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
            ["DspawnRadiusMin",150],
            ["DspawnRadiusMax",200],
            ["DspawnGroupsMult",2],//Multiply number of ukrep groups by X to get dspawn groups
            ["DspawnGroupsMin",3],
            ["DspawnGroupsMax",8]
        ]
    ]],

    ["",0]
]