/*
    Annotation:
    Catalogue page structure follows the format
    [
        [PASSENGERS],
        [PARADROP_VEHICLES],
        [GROUP_DESCRIPTIONS]
    ]

    Group description follows the format:
    [
        ["TAGS"], TIER,
        ["VEH_CLASSNAME",[APPEARANCE](optional),[PYLONS](optional)], //or 'false' if no vehicle
        ["UNIT_CLASSNAMES"],
        {ADDITIONAL_CODE}(optional)
    ]

    Note: Every number value in appearance means 0-1 probability, you can set it to 0.5 to get 50/50 chance for each item
    Note: UNIT_CLASSNAMES uses a shortened format, example: [2,"aaa","bbb",3,"ccc"] that will be uncompacted into ["aaa","aaa","bbb","ccc","ccc","ccc"]
    Note: ADDITIONAL_CODE will recieve 'params ["_group","_vehicle","_units"]'
*/

#define TIER_1 1
#define TIER_2 2
#define TIER_3 3
#define TIER_4 4

//=====================================================
// AAF faction

[
    //=================================================
    //Passenger container (used to fill 'RANDOM' slots - usually passenger seats in vehicles)
    [
        /*Common units (60% chance)*/
        ["I_Soldier_A_F",
        "I_Soldier_AAR_F",
        "I_support_AMG_F",
        "I_support_AMort_F",
        "I_Soldier_AAA_F",
        "I_Soldier_AAT_F",
        "I_Soldier_AR_F",
        "I_medic_F",
        "I_engineer_F",
        "I_Soldier_exp_F",
        "I_Soldier_GL_F",
        "I_support_GMG_F",
        "I_support_MG_F",
        "I_support_Mort_F",
        "I_soldier_mine_F",
        "I_Soldier_repair_F",
        "I_soldier_F",
        "I_Soldier_lite_F",
        "I_soldier_UAV_F",
        "I_soldier_UAV_06_F",
        "I_soldier_UAV_06_medical_F"],

        /*Uncommon units (30% chance) (AT soldiers or heavy machinegunners for example)*/
        ["I_Soldier_M_F",
        "I_Soldier_M_F",
        "I_officer_F",
        "I_Soldier_LAT_F",
        "I_Soldier_LAT_F",
        "I_Soldier_LAT2_F",
        "I_Soldier_LAT2_F",
        "I_Soldier_SL_F",
        "I_Soldier_TL_F",
        "I_Spotter_F",
        "I_G_Sharpshooter_F"],

        /*Rare units (10% chance) (AA soldiers or marksmans for example)*/
        ["I_Soldier_AA_F",
        "I_Soldier_AA_F",
        "I_Soldier_AT_F",
        "I_Soldier_AT_F",
        "I_Sniper_F",
        "I_ghillie_lsh_F",
        "I_ghillie_sard_F"]
    ],
    //=================================================
    //Paradrop vehicle(s) (used to imitate vehicles drop from the sky) (leave empty to disable for this faction)
    [
        "I_Heli_Transport_02_F"
    ],
    //=================================================
    //Groups descriptions (blueprints)
    [
        //=============================================
        /*INF - Infantry*/
        /*[Tier 1]*/
        //Air-defense team
        [["INF","AA"],TIER_1,false,["I_Soldier_TL_F","I_Soldier_AA_F","I_soldier_F"]],
        //Anti-armour team (NLAW)
        [["INF","AT"],TIER_1,false,["I_Soldier_TL_F",2,"I_Soldier_LAT_F","I_soldier_F"]],
        //Fire team (Small)
        [["INF","REG"],TIER_1,false,["I_Soldier_TL_F","I_Soldier_AR_F",2,"I_soldier_F"]],
        //Fire team (Small) (v2)
        [["INF","REG"],TIER_1,false,["I_Soldier_TL_F",3,"RANDOM"]],

        /*[Tier 2]*/
        //Air-defense team
        [["INF","AA"],TIER_2,false,["I_Soldier_TL_F",3,"I_Soldier_AA_F","I_Soldier_AAA_F"]],
        //Anti-armour team (NLAW+Titan)
        [["INF","AT"],TIER_2,false,["I_Soldier_TL_F","I_Soldier_AT_F",2,"I_Soldier_LAT_F",2,"I_Soldier_AAT_F"]],
        //Fire team
        [["INF","REG"],TIER_2,false,["I_Soldier_TL_F","I_Soldier_AR_F","I_Soldier_GL_F","I_Soldier_LAT_F","I_soldier_F"]],
        //Fire team (Light)
        [["INF","REG"],TIER_2,false,["I_Soldier_TL_F","I_Soldier_AR_F",2,"I_soldier_F","I_Soldier_LAT2_F"]],
        //Support team Engineer
        [["INF","REG"],TIER_2,false,["I_Soldier_TL_F",2,"I_engineer_F","I_Soldier_repair_F"]],
        //Support team EOD
        [["INF","REG"],TIER_2,false,["I_Soldier_TL_F","I_engineer_F",2,"I_Soldier_exp_F"]],
        //Sentry
        [["INF","REG"],TIER_2,false,["I_Soldier_GL_F","I_soldier_F",3,"RANDOM"]],
        //'Recon' team
        [["INF","SPN"],TIER_2,false,[3,"I_Spotter_F",3,"RANDOM"]],

        /*[Tier 3]*/
        //Air-defense team (v2)
        [["INF","AA"],TIER_3,false,["I_Soldier_TL_F",4,"I_Soldier_AA_F","I_Soldier_AAA_F"]],
        //Anti-armour team (Titan launchers)
        [["INF","AT"],TIER_3,false,["I_Soldier_TL_F",3,"I_Soldier_AT_F",2,"I_Soldier_AAT_F"]],
        //Assault squad
        [["INF","REG"],TIER_3,false,["I_Soldier_SL_F",2,"I_Soldier_AR_F","I_Soldier_AAR_F","I_Soldier_M_F","I_G_Sharpshooter_F","I_Soldier_LAT_F","I_medic_F"]],
        //Rifle squad
        [["INF","REG"],TIER_3,false,["I_Soldier_SL_F","I_soldier_F","I_Soldier_LAT_F","I_Soldier_M_F","I_Soldier_TL_F","I_Soldier_AR_F","I_Soldier_A_F","I_medic_F"]],
        //Weapons squad
        [["INF","REG"],TIER_3,false,["I_Soldier_SL_F","I_Soldier_AR_F","I_Soldier_GL_F","I_Soldier_M_F","I_Soldier_AT_F","I_Soldier_AAT_F","I_Soldier_A_F","I_medic_F"]],
        //'Recon' team
        [["INF","SPN"],TIER_3,false,[3,"I_Spotter_F","I_ghillie_sard_F","I_soldier_UAV_F","I_Soldier_AA_F","I_Soldier_AT_F"]],

        /*[Tier 4]*/
        //Sniper team
        [["INF","SPN"],TIER_4,false,["I_Sniper_F","I_Spotter_F",3,"RANDOM"]],
        //'Recon' team
        [["INF","SPN"],TIER_4,false,[3,"I_Spotter_F",2,"I_ghillie_sard_F","I_soldier_UAV_F","I_Soldier_AA_F","I_Soldier_AT_F"]],


        //=============================================
        /*VEH MOT - Motorized Vehicles (transport, unarmed)*/
        /*[Tier 1]*/
        //Quad bike
        [
            ["VEH","MOT","REG"],TIER_1,
            ["I_Quadbike_01_F"],
            ["I_soldier_F",1,"RANDOM"]
        ],
        //Strider unarmed (low crew)
        [
            ["VEH","MOT","REG"],TIER_1,
            ["I_MRAP_03_F"],
            [2,"I_soldier_F"]
        ],

        /*[Tier 2]*/
        //Zamak transport (mid load)
        [
            ["VEH","MOT","REG"],TIER_2,
            ["I_Truck_02_transport_F"],
            ["I_soldier_F",8,"RANDOM"]
        ],
        //Zamak transport (covered) (mid load)
        [
            ["VEH","MOT","REG"],TIER_2,
            ["I_Truck_02_covered_F"],
            ["I_soldier_F",8,"RANDOM"]
        ],
        //Strider unarmed
        [
            ["VEH","MOT","REG","PARADROPPABLE+"],TIER_2,
            ["I_MRAP_03_F"],
            [2,"I_soldier_F",2,"RANDOM"]
        ],

        /*[Tier 3]*/
        //Zamak transport (max load)
        [
            ["VEH","MOT","REG"],TIER_3,
            ["I_Truck_02_transport_F"],
            ["I_soldier_F",16,"RANDOM"]
        ],
        //Zamak transport (covered) (max load)
        [
            ["VEH","MOT","REG"],TIER_3,
            ["I_Truck_02_covered_F"],
            ["I_soldier_F",16,"RANDOM"]
        ],

        /*[Tier 4]*/
        //none


        //=============================================
        /*VEH MEC - Mechanized (armed) vehicles*/
        /*[Tier 1]*/
        //none

        /*[Tier 2]*/
        //Strider GMG
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_2,
            ["I_MRAP_03_gmg_F"],
            [3,"I_soldier_F"]
        ],
        //Strider HMG
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_2,
            ["I_MRAP_03_hmg_F"],
            [3,"I_soldier_F"]
        ],
        //Gorgon (no passengers)
        [
            ["VEH","MEC","AT","PARADROPPABLE+"],TIER_2,
            ["I_APC_Wheeled_03_cannon_F",[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]],false],
            [3,"I_crew_F"]
        ],
        //Mora (no passengers)
        [
            ["VEH","MEC","AT"],TIER_2,
            ["I_APC_tracked_03_cannon_F",[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]],false],
            [3,"I_crew_F"]
        ],
        //Stomper UAV
        [
            ["VEH","MEC","UAV","REG"],TIER_2,
            ["I_UGV_01_rcws_F"],
            [2,"B_UAV_AI"]
        ],

        /*[Tier 3]*/
        //Gorgon
        [
            ["VEH","MEC","AT","PARADROPPABLE+"],TIER_3,
            ["I_APC_Wheeled_03_cannon_F",[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]],false],
            [3,"I_crew_F",8,"RANDOM"]
        ],
        //Mora
        [
            ["VEH","MEC","AT"],TIER_3,
            ["I_APC_tracked_03_cannon_F",[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]],false],
            [3,"I_crew_F",7,"RANDOM"]
        ],
        //Zamak MRL - artillery
        [
            ["VEH","MEC","ARTA"],TIER_3,
            ["I_Truck_02_MRL_F"],
            [2,"I_soldier_F"]
        ],

        /*[Tier 4]*/
        //none


        //=============================================
        /*ARM - Armoured vehicles*/
        /*[Tier 1]*/
        //none

        /*[Tier 2]*/
        //none

        /*[Tier 3]*/
        //NYX AA
        [
            ["ARM","MEC","AA"],TIER_3,
            ["I_LT_01_AA_F",[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]],false],
            [2,"I_crew_F"]
        ],
        //NYX AT
        [
            ["ARM","MEC","AT"],TIER_3,
            ["I_LT_01_AT_F",[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]],false],
            [2,"I_crew_F"]
        ],
        //NYX Autocannon
        [
            ["ARM","MEC","REG"],TIER_3,
            ["I_LT_01_cannon_F",[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]],false],
            [2,"I_crew_F"]
        ],

        /*[Tier 4]*/
        //Kuma
        [
            ["ARM","MEC","AT"],TIER_4,
            ["I_MBT_03_cannon_F",[["Indep_01",1],["HideTurret",0.5,"HideHull",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5]],false],
            [3,"I_crew_F"]
        ],


        //=============================================
        /*AIR - Air vehicles*/
        /*[Tier 1]*/
        //Hellcat (unarmed) (low crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_1,
            ["I_Heli_light_03_unarmed_F",[["Indep",1],[]],false],
            [2,"I_helipilot_F",3,"RANDOM"]
        ],

        /*[Tier 2]*/
        //Ababil UAV
        [
            ["AIR","MEC","PLANE","UAV","AT","AIRSTRIKE+"],TIER_2,
            ["I_UAV_02_dynamicLoadout_F"],
            [2,"B_UAV_AI"]
        ],
        [
            ["AIR","MEC","PLANE","UAV","AA","AIRSTRIKE+"],TIER_2,
            ["I_UAV_02_dynamicLoadout_F",false,["PylonRack_1Rnd_AAA_missiles","PylonRack_1Rnd_AAA_missiles"]],
            [2,"B_UAV_AI"]
        ],
        //Mohawk (low crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_2,
            ["I_Heli_Transport_02_F"],
            [2,"I_helipilot_F",6,"RANDOM"]
        ],
        //Hellcat (armed) (low crew)
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+","AIRSTRIKE+"],TIER_2,
            ["I_Heli_light_03_dynamicLoadout_F"],
            [2,"I_helipilot_F",3,"RANDOM"]
        ],
        //Hellcat (unarmed)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_2,
            ["I_Heli_light_03_unarmed_F",[["Indep",1],[]],false],
            [2,"I_helipilot_F",6,"RANDOM"]
        ],
        //Buzzard
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],TIER_2,
            ["I_Plane_Fighter_03_dynamicLoadout_F"],
            ["I_Fighter_Pilot_F"]
        ],

        /*[Tier 3]*/
        //Mohawk (max crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_3,
            ["I_Heli_Transport_02_F"],
            [2,"I_helipilot_F",16,"RANDOM"]
        ],
        //Hellcat (armed) (max crew)
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+","AIRSTRIKE+"],TIER_3,
            ["I_Heli_light_03_dynamicLoadout_F"],
            [2,"I_helipilot_F",6,"RANDOM"]
        ],
        //Hellcat (AA|AT pylons)
        [
            ["AIR","MEC","HELI","AA","AT","AIRSTRIKE+"],TIER_3,
            ["I_Heli_light_03_dynamicLoadout_F",false,["PylonRack_4Rnd_LG_scalpel","PylonRack_1Rnd_AAA_missiles"]],
            [2,"I_helipilot_F"]
        ],
        //Gryphon
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],TIER_3,
            ["I_Plane_Fighter_04_F"],
            ["I_Fighter_Pilot_F"]
        ],

        /*[Tier 4]*/
        //Gryphon white
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],TIER_4,
            ["I_Plane_Fighter_04_F",[["DigitalCamoGrey",1],[]],["PylonRack_Missile_AMRAAM_C_x1","PylonRack_Missile_AMRAAM_C_x1","PylonRack_Missile_BIM9X_x1","PylonRack_Missile_BIM9X_x1","PylonRack_Missile_AGM_02_x2","PylonRack_Missile_AGM_02_x2"]],
            ["I_Fighter_Pilot_F"]
        ],

        //=============================================
        /*BOATS - Sea boats*/
        //Assault boat (low crew)
        [
            ["BOAT","MOT","REG"],TIER_1,
            ["I_Boat_Transport_01_F"],
            ["I_soldier_F",2,"RANDOM"]
        ],
        //Assault boat
        [
            ["BOAT","MOT","REG"],TIER_2,
            ["I_Boat_Transport_01_F"],
            ["I_soldier_F",4,"RANDOM"]
        ],
        //Speed boat
        [
            ["BOAT","MEC","REG"],TIER_3,
            ["I_Boat_Armed_01_minigun_F"],
            [3,"I_soldier_F"]
        ]
    ]
]
