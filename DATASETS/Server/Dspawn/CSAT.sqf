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
        ["O_Soldier_AAR_F",
        "O_support_AMG_F",
        "O_support_AMort_F",
        "O_Soldier_AHAT_F",
        "O_Soldier_AAA_F",
        "O_Soldier_AAT_F",
        "O_Soldier_AR_F",
        "O_medic_F",
        "O_engineer_F",
        "O_soldier_exp_F",
        "O_Soldier_GL_F",
        "O_support_GMG_F",
        "O_support_MG_F",
        "O_support_Mort_F",
        "O_soldier_mine_F",
        "O_recon_exp_F",
        "O_recon_JTAC_F",
        "O_recon_medic_F",
        "O_recon_F",
        "O_soldier_repair_F",
        "O_Soldier_F",
        "O_Soldier_lite_F",
        "O_soldier_UAV_F",
        "O_soldier_UAV_06_F",
        "O_soldier_UAV_06_medical_F",
        "O_Soldier_A_F"],

        /*Uncommon units (30% chance) (AT soldiers or heavy machinegunners for example)*/
        ["O_HeavyGunner_F",
        "O_Soldier_AT_F",
        "O_Soldier_LAT_F",
        "O_Soldier_SL_F",
        "O_Soldier_TL_F",
        "O_recon_LAT_F",
        "O_recon_TL_F",
        "O_spotter_F",
        "O_soldier_M_F",
        "O_Sharpshooter_F",
        "O_recon_M_F"],

        /*Rare units (10% chance) (AA soldiers or marksmans for example)*/
        ["O_Soldier_AA_F",
        "O_Soldier_HAT_F",
        "O_Pathfinder_F",
        "O_sniper_F",
        "O_ghillie_ard_F"]
    ],
    //=================================================
    //Paradrop vehicle(s) (used to imitate vehicles drop from the sky) (leave empty to disable for this faction)
    [
        "O_Heli_Transport_04_F"
    ],
    //=================================================
    //Groups descriptions (blueprints)
    [
        //=============================================
        /*INF - Infantry*/
        /*[Tier 1]*/
        //Air-defense team (1 Titan AA)
        [["INF","AA"],TIER_1,false,["O_Soldier_TL_F","O_Soldier_AA_F","O_Soldier_F"]],
        //Anti-armour team (RPG-42 Alamut)
        [["INF","AT"],TIER_1,false,["O_Soldier_TL_F",2,"O_Soldier_LAT_F","O_Soldier_F"]],
        //Fire team (Small)
        [["INF","REG"],TIER_1,false,["O_Soldier_TL_F","O_Soldier_AR_F",2,"O_Soldier_F"]],
        //Fire team (Small) (v2)
        [["INF","REG"],TIER_1,false,["O_Soldier_TL_F",3,"RANDOM"]],
        //Urban - Guard sentry
        [["INF","REG"],TIER_1,false,["O_soldierU_F","O_soldierU_A_F","O_soldierU_medic_F","O_SoldierU_GL_F"]],
        //Support team CLS
        [["INF","REG"],TIER_1,false,["O_Soldier_TL_F","O_Soldier_AR_F",2,"O_medic_F"]],
        //Support team Engineer
        [["INF","REG"],TIER_1,false,["O_Soldier_TL_F",2,"O_engineer_F","O_soldier_repair_F"]],
        //Support team EOD
        [["INF","REG"],TIER_1,false,["O_Soldier_TL_F","O_engineer_F",2,"O_soldier_exp_F"]],

        /*[Tier 2]*/
        //Air-defense team (3 Titan AA)
        [["INF","AA"],TIER_2,false,["O_Soldier_TL_F",3,"O_Soldier_AA_F","O_Soldier_AAA_F"]],
        //Anti-armour team (RPG-42 Alamut + Titan AT)
        [["INF","AT"],TIER_2,false,["O_Soldier_TL_F","O_Soldier_AT_F",2,"O_Soldier_LAT_F",2,"O_Soldier_AAT_F"]],
        //Fire team
        [["INF","REG"],TIER_2,false,["O_Soldier_TL_F","O_Soldier_AR_F","O_Soldier_GL_F","O_Soldier_LAT_F","O_Soldier_F"]],
        //Fire team (Light)
        [["INF","REG"],TIER_2,false,["O_Soldier_TL_F","O_Soldier_AR_F",2,"O_Soldier_F","O_Soldier_LAT_F"]],
        //Recon patrol
        [["INF","SPN"],TIER_2,false,["O_recon_TL_F","O_recon_M_F","O_recon_medic_F",2,"O_recon_F"]],
        //Sentry
        [["INF","REG"],TIER_2,false,["O_Soldier_GL_F","O_Soldier_F",3,"RANDOM"]],
        //Urban - Guard patrol
        [["INF","REG"],TIER_2,false,["O_soldierU_TL_F","O_soldierU_AR_F","O_SoldierU_GL_F","O_soldierU_LAT_F","O_soldierU_AA_F"]],
        //Support team Recon EOD
        [["INF","REG"],TIER_2,false,["O_recon_TL_F",2,"O_recon_exp_F","O_recon_F"]],

        /*[Tier 3]*/
        //Air-defense team (4 Titan AA)
        [["INF","AA"],TIER_3,false,["O_Soldier_TL_F",4,"O_Soldier_AA_F","O_Soldier_AAA_F"]],
        //Anti-armour team (Titan AT)
        [["INF","AT"],TIER_3,false,["O_Soldier_TL_F",3,"O_Soldier_AT_F",2,"O_Soldier_AAT_F"]],
        //Anti-armour HEAVY team (Vorona AT)
        [["INF","AT"],TIER_3,false,["O_Soldier_TL_F","O_Soldier_HAT_F","O_Soldier_AHAT_F","O_Soldier_AR_F","O_Soldier_AAR_F"]],
        //Assault squad
        [["INF","REG"],TIER_3,false,["O_Soldier_SL_F","O_Soldier_AR_F","O_HeavyGunner_F","O_Soldier_AAR_F","O_soldier_M_F","O_Sharpshooter_F","O_Soldier_LAT_F","O_medic_F"]],
        //Recon sentry
        [["INF","SPN"],TIER_3,false,["O_recon_TL_F",2,"O_recon_M_F",2,"O_recon_F"]],
        //Rifle squad
        [["INF","REG"],TIER_3,false,["O_Soldier_SL_F","O_Soldier_F","O_Soldier_LAT_F","O_soldier_M_F","O_Soldier_TL_F","O_Soldier_AR_F","O_Soldier_A_F","O_medic_F"]],
        //Weapons squad
        [["INF","REG"],TIER_3,false,["O_Soldier_SL_F","O_Soldier_AR_F","O_Soldier_GL_F","O_soldier_M_F","O_Soldier_AT_F","O_Soldier_AAT_F","O_Soldier_A_F","O_medic_F"]],
        //Viper team (Small)
        [["INF","SPN"],TIER_3,false,[2,"O_V_Soldier_hex_F","O_V_Soldier_LAT_hex_F"]],
        //Urban - Guard squad
        [["INF","REG"],TIER_3,false,["O_SoldierU_SL_F","O_soldierU_F","O_soldierU_LAT_F","O_soldierU_M_F","O_soldierU_TL_F","O_soldierU_AR_F","O_soldierU_A_F","O_soldierU_medic_F"]],

        /*[Tier 4]*/
        //Anti-armour HEAVY team (Vorona AT + RPG-42 Alamut)
        [["INF","AT"],TIER_4,false,["O_Soldier_TL_F","O_Soldier_HAT_F","O_Soldier_AHAT_F","O_Soldier_LAT_F","O_Soldier_AR_F","O_Soldier_AAR_F"]],
        //Recon squad
        [["INF","SPN"],TIER_4,false,["O_recon_TL_F","O_recon_M_F","O_recon_medic_F","O_recon_F","O_recon_LAT_F","O_recon_JTAC_F","O_recon_exp_F","O_Pathfinder_F"]],
        //Sniper team
        [["INF","SPN"],TIER_4,false,["O_sniper_F","O_spotter_F",3,"RANDOM"]],
        //Viper team
        [["INF","SPN"],TIER_4,false,["O_V_Soldier_TL_hex_F","O_V_Soldier_JTAC_hex_F","O_V_Soldier_M_hex_F","O_V_Soldier_Exp_hex_F","O_V_Soldier_LAT_hex_F","O_V_Soldier_Medic_hex_F"]],
        //Urban - Detachment
        [["INF","REG"],TIER_4,false,["O_SoldierU_SL_F","O_soldierU_A_F","O_soldierU_AAR_F","O_soldierU_AAA_F","O_soldierU_AAT_F","O_soldierU_AR_F","O_soldierU_medic_F","O_engineer_U_F","O_soldierU_exp_F","O_SoldierU_GL_F","O_Urban_HeavyGunner_F","O_soldierU_M_F","O_soldierU_AA_F","O_soldierU_AT_F","O_soldierU_repair_F","O_soldierU_F","O_soldierU_LAT_F","O_Urban_Sharpshooter_F","O_soldierU_TL_F"]],


        //=============================================
        /*VEH MOT - Motorized Vehicles (transport, unarmed)*/
        /*[Tier 1]*/
        //Ifrit unarmed (low crew)
        [
            ["VEH","MOT","REG"],TIER_1,
            ["O_MRAP_02_F"],
            [2,"O_Soldier_F"]
        ],
        //Qilin unarmed (low crew)
        [
            ["VEH","MOT","REG","PARADROPPABLE+"],TIER_1,
            ["O_LSV_02_unarmed_F"],
            [3,"O_Soldier_F"]
        ],

        /*[Tier 2]*/
        //Ifrit unarmed
        [
            ["VEH","MOT","REG","PARADROPPABLE+"],TIER_2,
            ["O_MRAP_02_F"],
            ["O_Soldier_F",4,"RANDOM"]
        ],
        //Qilin unarmed
        [
            ["VEH","MOT","REG","PARADROPPABLE+"],TIER_2,
            ["O_LSV_02_unarmed_F"],
            ["O_Soldier_F",6,"RANDOM"]
        ],
        //Tempest transport (mid load)
        [
            ["VEH","MOT","REG"],TIER_2,
            ["O_Truck_03_transport_F"],
            ["O_Soldier_F",7,"RANDOM"]
        ],
        //Tempest transport (covered) (mid load)
        [
            ["VEH","MOT","REG"],TIER_2,
            ["O_Truck_03_covered_F"],
            ["O_Soldier_F",7,"RANDOM"]
        ],

        /*[Tier 3]*/
        //Tempest transport
        [
            ["VEH","MOT","REG"],TIER_3,
            ["O_Truck_03_transport_F"],
            ["O_Soldier_F",13,"RANDOM"]
        ],
        //Tempest transport (covered)
        [
            ["VEH","MOT","REG"],TIER_3,
            ["O_Truck_03_covered_F"],
            ["O_Soldier_F",13,"RANDOM"]
        ],

        /*[Tier 4]*/
        //none


        //=============================================
        /*VEH MEC - Mechanized (armed) vehicles*/
        /*[Tier 1]*/
        //Qilin minigun (no passengers)
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_1,
            ["O_LSV_02_armed_F"],
            [2,"O_Soldier_F"]
        ],

        /*[Tier 2]*/
        //BTR-K Kamysh (no passengers)
        [
            ["VEH","MEC","AT"],TIER_2,
            ["O_APC_Tracked_02_cannon_F",[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]],false],
            [3,"O_crew_F"]
        ],
        //MSE-3 Marid (no passengers)
        [
            ["VEH","MEC","REG"],TIER_2,
            ["O_APC_Wheeled_02_rcws_v2_F",[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]],false],
            [2,"O_crew_F"]
        ],
        //Ifrit GMG
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_2,
            ["O_MRAP_02_gmg_F"],
            [2,"O_Soldier_F",3,"RANDOM"]
        ],
        //Ifrit HMG
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_2,
            ["O_MRAP_02_hmg_F"],
            [2,"O_Soldier_F",3,"RANDOM"]
        ],
        //Qilin AT
        [
            ["VEH","MEC","AT","PARADROPPABLE+"],TIER_2,
            ["O_LSV_02_AT_F"],
            [2,"O_Soldier_F",5,"RANDOM"]
        ],
        //Qilin minigun
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],TIER_2,
            ["O_LSV_02_armed_F"],
            [2,"O_Soldier_F",5,"RANDOM"]
        ],
        //Saif UAV
        [
            ["VEH","MEC","UAV","REG","PARADROPPABLE+"],TIER_2,
            ["O_UGV_01_rcws_F"],
            [2,"B_UAV_AI"]
        ],

        /*[Tier 3]*/
        //BTR-K Kamysh
        [
            ["VEH","MEC","AT"],TIER_3,
            ["O_APC_Tracked_02_cannon_F",[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]],false],
            [3,"O_crew_F",8,"RANDOM"]
        ],
        //MSE-3 Marid
        [
            ["VEH","MEC","REG"],TIER_3,
            ["O_APC_Wheeled_02_rcws_v2_F",[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]],false],
            [2,"O_crew_F",8,"RANDOM"]
        ],

        /*[Tier 4]*/
        //Qilin AT (Viper)
        [
            ["VEH","MEC","AT","PARADROPPABLE+"],TIER_4,
            ["O_LSV_02_AT_F",[["Arid",1],["Unarmed_Doors_Hide",1]],false],
            ["O_V_Soldier_TL_hex_F","O_V_Soldier_JTAC_hex_F","O_V_Soldier_M_hex_F","O_V_Soldier_LAT_hex_F","O_V_Soldier_Medic_hex_F","O_V_Soldier_hex_F","O_V_Soldier_Exp_hex_F"]
        ],

        //=============================================
        /*ARM - Armoured vehicles*/
        /*[Tier 1]*/
        //none

        /*[Tier 2]*/
        //none

        /*[Tier 3]*/
        //ZSU Tigris
        [
            ["ARM","MEC","AA"],TIER_3,
            ["O_APC_Tracked_02_AA_F",[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]],false],
            [3,"O_crew_F"]
        ],
        //2S9 Sochor - barrel artillery
        [
            ["ARM","MEC","ARTA"],TIER_3,
            ["O_MBT_02_arty_F",[["Hex",1],["showAmmobox",0.5,"showCanisters",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5,"showLog",0.5]],false],
            [3,"O_crew_F"]
        ],
        //T-100 Varsuk
        [
            ["ARM","MEC","AT"],TIER_3,
            ["O_MBT_02_cannon_F",[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showLog",0.5]],false],
            [3,"O_crew_F"]
        ],
        //T-140 Angara
        [
            ["ARM","MEC","AA","AT"],TIER_3,
            ["O_MBT_04_cannon_F",[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5]],false],
            [3,"O_crew_F"]
        ],

        /*[Tier 4]*/
        //T-100X Futura
        [
            ["ARM","MEC","AT"],TIER_4,
            ["O_MBT_02_railgun_F",[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showLog",0.5]],false],
            [3,"O_crew_F"]
        ],
        //T-140K Angara
        [
            ["ARM","MEC","AT"],TIER_4,
            ["O_MBT_04_command_F",[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5]],false],
            [3,"O_crew_F"]
        ],

        //=============================================
        /*AIR - Air vehicles*/
        /*[Tier 1]*/
        //Orca unarmed (low crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_1,
            ["O_Heli_Light_02_unarmed_F",[["Opfor",1],[]],false],
            [2,"O_helipilot_F",5,"RANDOM"]
        ],

        /*[Tier 2]*/
        //Ababil UAV (AT)
        [
            ["AIR","MEC","PLANE","UAV","AT","AIRSTRIKE+"],TIER_2,
            ["O_UAV_02_dynamicLoadout_F"],
            [2,"B_UAV_AI"]
        ],
        //Ababil UAV (AA)
        [
            ["AIR","MEC","PLANE","UAV","AA","AIRSTRIKE+"],TIER_2,
            ["O_UAV_02_dynamicLoadout_F",false,["PylonRack_1Rnd_Missile_AA_03_F","PylonRack_1Rnd_Missile_AA_03_F"]],
            [2,"B_UAV_AI"]
        ],
        //Ababil UAV (CAS)
        [
            ["AIR","MEC","PLANE","UAV","REG","AIRSTRIKE+"],TIER_2,
            ["O_UAV_02_dynamicLoadout_F",false,["PylonRack_19Rnd_Rocket_Skyfire","PylonRack_19Rnd_Rocket_Skyfire"]],
            [2,"B_UAV_AI"]
        ],
        //Taru (bench) (low crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_2,
            ["O_Heli_Transport_04_bench_F"],
            [2,"O_helipilot_F","O_helicrew_F",5,"RANDOM"]
        ],
        //Taru (transport) (low crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_2,
            ["O_Heli_Transport_04_covered_F"],
            [2,"O_helipilot_F","O_helicrew_F",8,"RANDOM"]
        ],
        //Orca (low crew)
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+","AIRSTRIKE+"],TIER_2,
            ["O_Heli_Light_02_dynamicLoadout_F",false,["PylonWeapon_2000Rnd_65x39_belt","PylonRack_12Rnd_missiles"]],
            [2,"O_helipilot_F",5,"RANDOM"]
        ],
        //Orca unarmed (max crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_2,
            ["O_Heli_Light_02_unarmed_F",[["Opfor",1],[]],false],
            [2,"O_helipilot_F",8,"RANDOM"]
        ],
        //To-199 Neophron
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],TIER_2,
            ["O_Plane_CAS_02_dynamicLoadout_F"],
            ["O_Fighter_Pilot_F"]
        ],
        //X-32 Xi'an (low crew)
        [
            ["AIR","MEC","PLANE","AT","PARA+","AIRSTRIKE+"],TIER_2,
            ["O_T_VTOL_02_infantry_dynamicLoadout_F",[["Hex",1],[]],false],
            [2,"O_T_Pilot_F",8,"RANDOM"]
        ],

        /*[Tier 3]*/
        //Taru (bench) (max crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_3,
            ["O_Heli_Transport_04_bench_F"],
            [2,"O_helipilot_F","O_helicrew_F",8,"RANDOM"]
        ],
        //Taru (transport) (max crew)
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],TIER_3,
            ["O_Heli_Transport_04_covered_F"],
            [2,"O_helipilot_F","O_helicrew_F",16,"RANDOM"]
        ],
        //Orca (max crew)
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+","AIRSTRIKE+"],TIER_3,
            ["O_Heli_Light_02_dynamicLoadout_F",false,["PylonWeapon_2000Rnd_65x39_belt","PylonRack_12Rnd_missiles"]],
            [2,"O_helipilot_F",8,"RANDOM"]
        ],
        //To-201 Shikra
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],TIER_3,
            ["O_Plane_Fighter_02_F",false,["PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AGM_KH25_x1","PylonMissile_Missile_AGM_KH25_x1","PylonMissile_Bomb_KAB250_x1","PylonMissile_Bomb_KAB250_x1","PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AA_R77_x1","PylonMissile_Missile_AA_R77_x1","PylonMissile_Missile_AA_R77_INT_x1","PylonMissile_Missile_AA_R77_INT_x1","PylonMissile_Bomb_KAB250_x1"]],
            ["O_Fighter_Pilot_F"]
        ],
        //X-32 Xi'an
        [
            ["AIR","MEC","PLANE","AT","PARA+","AIRSTRIKE+"],TIER_3,
            ["O_T_VTOL_02_infantry_dynamicLoadout_F",[["Hex",1],[]],false],
            [2,"O_T_Pilot_F",16,"RANDOM"]
        ],

        /*[Tier 4]*/
        //Kajman
        [
            ["AIR","MEC","HELI","AT","LAND+","PARA+","AIRSTRIKE+"],TIER_4,
            ["O_Heli_Attack_02_dynamicLoadout_F"],
            [2,"O_helipilot_F",8,"RANDOM"]
        ],
        //Kajman (AA variant) (no passengers)
        [
            ["AIR","MEC","HELI","AA","AT","AIRSTRIKE+"],TIER_4,
            ["O_Heli_Attack_02_dynamicLoadout_F",false,["PylonRack_1Rnd_Missile_AA_03_F","PylonRack_4Rnd_LG_scalpel","PylonRack_4Rnd_LG_scalpel","PylonRack_1Rnd_Missile_AA_03_F"]],
            [2,"O_helipilot_F"]
        ],
        //To-201 Shikra Stealth
        [
            ["AIR","MEC","PLANE","AA","AIRSTRIKE+"],TIER_4,
            ["O_Plane_Fighter_02_Stealth_F",[["CamoGreyHex",1],[]],["","","","","","","PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AA_R73_x1","PylonMissile_Missile_AA_R77_x1","PylonMissile_Missile_AA_R77_x1","PylonMissile_Missile_AA_R77_INT_x1","PylonMissile_Missile_AA_R77_INT_x1","PylonMissile_1Rnd_BombCluster_02_cap_F"]],
            ["O_Fighter_Pilot_F"]
        ],

        //=============================================
        /*BOATS - Sea boats*/
        //Assault boat (low crew)
        [
            ["BOAT","MOT","REG"],TIER_1,
            ["O_Boat_Transport_01_F"],
            ["O_Soldier_F",2,"RANDOM"]
        ],
        //Assault boat
        [
            ["BOAT","MOT","REG"],TIER_2,
            ["O_Boat_Transport_01_F"],
            ["O_Soldier_F",4,"RANDOM"]
        ],
        //Speed boat
        [
            ["BOAT","MEC","REG"],TIER_3,
            ["O_Boat_Armed_01_hmg_F"],
            [3,"O_Soldier_F"]
        ]
    ]
]
