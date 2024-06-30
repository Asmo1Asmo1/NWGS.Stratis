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

//===============================================
// NATO faction
private _faction = [
    //===========================================
    //Passenger container (used to fill 'RANDOM' slots - usually passenger seats in vehicles)
    [
        /*Common units (60% chance)*/
        ["B_Soldier_A_F",
        "B_soldier_AAR_F",
        "B_support_AMG_F",
        "B_support_AMort_F",
        "B_soldier_AAA_F",
        "B_soldier_AAT_F",
        "B_soldier_AR_F",
        "B_medic_F",
        "B_engineer_F",
        "B_soldier_exp_F",
        "B_Soldier_GL_F",
        "B_support_GMG_F",
        "B_support_MG_F",
        "B_support_Mort_F",
        "B_soldier_mine_F",
        "B_Soldier_F",
        "B_Soldier_TL_F",
        "B_Patrol_Medic_F",
        "B_Patrol_Engineer_F",
        "B_Patrol_Soldier_TL_F",
        "B_Patrol_Soldier_UAV_F"],

        /*Uncommon units (30% chance) (AT soldiers or heavy machinegunners for example)*/
        ["B_soldier_M_F",
        "B_officer_F",
        "B_soldier_repair_F",
        "B_soldier_LAT_F",
        "B_soldier_LAT2_F",
        "B_Soldier_lite_F",
        "B_Soldier_SL_F",
        "B_HeavyGunner_F",
        "B_Patrol_Soldier_AR_F",
        "B_Patrol_HeavyGunner_F",
        "B_Patrol_Soldier_MG_F",
        "B_Patrol_Soldier_AT_F"],

        /*Rare units (10% chance) (AA soldiers or marksmans for example)*/
        ["B_soldier_AT_F",
        "B_Sharpshooter_F",
        "B_soldier_AA_F",
        "B_Patrol_Soldier_M_F",
        "B_Patrol_Soldier_A_F"]
    ],
    //===========================================
    //Paradrop vehicle(s) (used to imitate vehicles drop from the sky) (leave empty to disable for this faction)
    [
        "B_T_VTOL_01_vehicle_F"
    ],
    //===========================================
    //Groups descriptions (blueprints)
    [
        //=======================================
        /*INF - Infantry*/
        //Air-defense team
        [["INF","AA"],1,false,["B_Soldier_TL_F",3,"B_soldier_AA_F","B_soldier_AAA_F"]],
        //Anti-armour team
        [["INF","AT"],1,false,["B_Soldier_TL_F",3,"B_soldier_AT_F","B_soldier_AAT_F"]],
        //Assault squad
        [["INF","REG"],1,false,["B_Soldier_SL_F","B_soldier_AR_F","B_HeavyGunner_F","B_soldier_AAR_F","B_soldier_M_F","B_Sharpshooter_F","B_soldier_LAT_F","B_medic_F"]],
        //Fire team
        [["INF","REG"],1,false,["B_Soldier_TL_F","B_soldier_AR_F","B_Soldier_GL_F","B_soldier_LAT_F","B_Soldier_F"]],
        //Fire team (Light)
        [["INF","REG"],1,false,["B_Soldier_TL_F","B_soldier_AR_F",2,"B_Soldier_F","B_soldier_LAT2_F"]],
        //Recon patrol
        [["INF","SPN"],2,false,["B_recon_TL_F","B_recon_M_F","B_recon_medic_F",2,"B_recon_F"]],
        //Recon sentry
        [["INF","SPN"],2,false,[2,"B_recon_M_F",3,"B_recon_F"]],
        //Recon squad
        [["INF","SPN"],2,false,["B_recon_TL_F","B_recon_M_F","B_recon_medic_F","B_recon_F","B_recon_LAT_F","B_recon_JTAC_F","B_recon_exp_F","B_Recon_Sharpshooter_F"]],
        //Recon team
        [["INF","SPN"],2,false,["B_recon_TL_F","B_recon_M_F","B_recon_medic_F","B_recon_LAT_F","B_recon_JTAC_F","B_recon_exp_F"]],
        //Rifle squad
        [["INF","REG"],1,false,["B_Soldier_SL_F","B_Soldier_F","B_soldier_LAT_F","B_soldier_M_F","B_Soldier_TL_F","B_soldier_AR_F","B_Soldier_A_F","B_medic_F"]],
        //Sentry
        [["INF","REG"],1,false,["B_Soldier_GL_F","B_Soldier_F",3,"RANDOM"]],
        //Sniper team
        [["INF","SPN"],2,false,["B_sniper_F","B_spotter_F",3,"RANDOM"]],
        //Weapons squad
        [["INF","REG"],1,false,["B_Soldier_SL_F","B_soldier_AR_F","B_Soldier_GL_F","B_soldier_M_F","B_soldier_AT_F","B_soldier_AAT_F","B_Soldier_A_F","B_medic_F"]],
        //Gendarmerie patrol
        [["INF","REG","GENDARME"],1,false,[2,"B_GEN_Commander_F",3,"B_GEN_Soldier_F"],{[_this,NWG_DSPAWNFACTION_NATO_GendarmerieLoadouts] call NWG_fnc_dsAcHelperDressUnits}],
        //Gendarmerie speznaz
        [["INF","SPN","GENDARME"],2,false,[6,"B_GEN_Soldier_F"],{[_this,NWG_DSPAWNFACTION_NATO_GendarmerieSpeznazLoadouts] call NWG_fnc_dsAcHelperDressUnits}],

        //=======================================
        /*VEH - Vehicles*/
        /*VEH MOT - Motorized (transport, unarmed) vehicles*/
        //HEMMT transport
        [
            ["VEH","MOT","REG"],1,
            ["B_Truck_01_transport_F"],
            ["B_Soldier_F",17,"RANDOM"]
        ],
        //HEMMT transport (covered)
        [
            ["VEH","MOT","REG"],1,
            ["B_Truck_01_covered_F"],
            ["B_Soldier_F",17,"RANDOM"]
        ],
        //Hunter transport
        [
            ["VEH","MOT","REG"],1,
            ["B_MRAP_01_F"],
            ["B_Soldier_F",3,"RANDOM"]
        ],
        //Prowler transport
        [
            ["VEH","MOT","REG","PARADROPPABLE+"],1,
            ["B_LSV_01_unarmed_F"],
            ["B_Soldier_F",6,"RANDOM"]
        ],
        //Prowler transport (SPN group)
        [
            ["VEH","MOT","SPN","PARADROPPABLE+"],2,
            ["B_LSV_01_unarmed_F",[["Sand",1],["HideDoor1",1,"HideDoor2",1,"HideDoor3",1,"HideDoor4",1]],false],
            ["B_recon_TL_F","B_recon_M_F","B_recon_medic_F",2,"B_recon_F"]
        ],

        /*VEH MEC - Mechanized (armed) vehicles*/
        //Hunter
        [
            ["VEH","MEC","REG"],1,
            ["B_MRAP_01_gmg_F"],
            [2,"B_Soldier_F",2,"RANDOM"]
        ],
        [
            ["VEH","MEC","REG"],1,
            ["B_MRAP_01_hmg_F"],
            [2,"B_Soldier_F",2,"RANDOM"]
        ],
        //Prawler
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],1,
            ["B_LSV_01_AT_F"],
            [3,"B_Soldier_F",2,"RANDOM"]
        ],
        [
            ["VEH","MEC","REG","PARADROPPABLE+"],1,
            ["B_LSV_01_armed_F"],
            [3,"B_Soldier_F",2,"RANDOM"]
        ],
        //Marshall
        [
            ["VEH","MEC","AT","PARADROPPABLE+"],2,
            ["B_APC_Wheeled_01_cannon_F",[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]],false],
            [3,"B_crew_F",8,"RANDOM"]
        ],
        //Bobcat
        [
            ["VEH","MEC","REG"],2,
            ["B_APC_Tracked_01_CRV_F",[["Sand",1],["showAmmobox",0.5,"showWheels",0.5,"showCamonetHull",0.5,"showBags",0.5]],false],
            [3,"B_crew_F"]
        ],
        //Panther
        [
            ["VEH","MEC","REG"],2,
            ["B_APC_Tracked_01_rcws_F",[["Sand",1],["showCamonetHull",0.5,"showBags",0.5]],false],
            [3,"B_crew_F",8,"RANDOM"]
        ],
        //HEMMT mobile AA
        [
            ["VEH","MEC","AA"],3,
            ["B_Truck_01_flatbed_F"],
            ["B_Soldier_F"],
            //Additional code:
            {
                // params ["_group","_vehicle","_units"]
                //Attach Spartan AA system
                [
                    _this,
                    "B_SAM_System_01_F",
                    [[-0.00012207,-1.99898,0.959962],[[-5.25924e-006,0.999999,-0.00159716],[0.000130184,0.00159716,0.999999]]]
                ] call NWG_fnc_dsAcHelperAttachTurret;
            }
        ],
        //Stomper UAV
        [
            ["VEH","MEC","UAV","REG"],1,
            ["B_UGV_01_rcws_F"],
            [2,"B_UAV_AI"]
        ],
        //Gendarmerie patrol
        [
            ["VEH","MOT","REG","GENDARME"],2,
            ["B_GEN_Offroad_01_covered_F",[["Gendarmerie",1],["hidePolice",0,"HideServices",1,"HideCover",0.5,"StartBeaconLight",0.5,"HideRoofRack",0.5,"HideLoudSpeakers",0,"HideAntennas",1,"HideBeacon",0,"HideSpotlight",0,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0,"HideConstruction",1,"BeaconsStart",0.5]],false],
            ["B_GEN_Commander_F",2,"B_GEN_Soldier_F"],
            {[_this,NWG_DSPAWNFACTION_NATO_GendarmerieLoadouts] call NWG_fnc_dsAcHelperDressUnits}
        ],
        //Gendarmerie speznaz party van
        [
            ["VEH","MOT","REG","GENDARME"],2,
            ["B_GEN_Van_02_transport_F",[["Gendarmerie",1],["Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0.5,"ladder_hide",0.5,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",0,"roof_rack_hide",0.5,"LED_lights_hide",0,"sidesteps_hide",1,"rearsteps_hide",1,"side_protective_frame_hide",0,"front_protective_frame_hide",0,"beacon_front_hide",0,"beacon_rear_hide",0]],false],
            [10,"B_GEN_Soldier_F"],
            {[_this,NWG_DSPAWNFACTION_NATO_GendarmerieSpeznazLoadouts] call NWG_fnc_dsAcHelperDressUnits}
        ],

        //=======================================
        /*ARM - Armoured vehicles*/
        //ZSU
        [
            ["ARM","MEC","AA"],2,
            ["B_APC_Tracked_01_AA_F",[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5,"showBags",0.5]],false],
            [3,"B_crew_F"]
        ],
        //Rhino
        [
            ["ARM","MEC","AT"],2,
            ["B_AFV_Wheeled_01_cannon_F",[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]],false],
            [3,"B_crew_F"]
        ],
        //Rhino UP
        [
            ["ARM","MEC","AT"],3,
            ["B_AFV_Wheeled_01_up_cannon_F",[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]],false],
            [3,"B_crew_F"]
        ],
        //Slammer
        [
            ["ARM","MEC","AT"],2,
            ["B_MBT_01_cannon_F",[["Sand",1],["showBags",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5]],false],
            [3,"B_crew_F",6,"RANDOM"]
        ],
        //Slammer UP
        [
            ["ARM","MEC","AT"],3,
            ["B_MBT_01_TUSK_F",[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5,"showBags",0.5]],false],
            [3,"B_crew_F",6,"RANDOM"]
        ],
        //M4 Scorcher - barrel artillery
        [
            ["ARM","MEC","ARTA"],2,
            ["B_MBT_01_arty_F",[["Sand",1],["showCanisters",0.5,"showCamonetTurret",0.5,"showAmmobox",0.5,"showCamonetHull",0.5]],false],
            [3,"B_crew_F"]
        ],
        //M5 Sandstorm - MLRS artillery
        [
            ["ARM","MEC","ARTA"],3,
            ["B_MBT_01_mlrs_F",[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5]],false],
            [2,"B_crew_F"]
        ],

        //=======================================
        /*AIR - Air vehicles*/
        //Greyhawk UAV
        [
            ["AIR","MEC","PLANE","UAV","AT"],2,
            ["B_UAV_02_dynamicLoadout_F"],
            [2,"B_UAV_AI"]
        ],
        [
            ["AIR","MEC","PLANE","UAV","AA"],2,
            ["B_UAV_02_dynamicLoadout_F",false,["PylonRack_1Rnd_AAA_missiles","PylonRack_1Rnd_AAA_missiles"]],
            [2,"B_UAV_AI"]
        ],
        //Sentinel UAV
        [
            ["AIR","MEC","PLANE","UAV","AT"],2,
            ["B_UAV_05_F",false,["PylonMissile_Missile_AGM_02_x2","PylonMissile_Missile_AGM_02_x2"]],
            [2,"B_UAV_AI"]
        ],
        //Pawnee
        [
            ["AIR","MEC","HELI","REG","AIRSTRIKE+"],2,
            ["B_Heli_Light_01_dynamicLoadout_F"],
            [2,"B_Helipilot_F"]
        ],
        //Blackfoot
        [
            ["AIR","MEC","HELI","AA","AT"],3,
            ["B_Heli_Attack_01_dynamicLoadout_F"],
            [2,"B_Helipilot_F"]
        ],
        //Huron
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+"],1,
            ["B_Heli_Transport_03_F"],
            [2,"B_Helipilot_F",2,"B_helicrew_F",16,"RANDOM"]
        ],
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],1,
            ["B_Heli_Transport_03_unarmed_F"],
            [2,"B_Helipilot_F",18,"RANDOM"]
        ],
        //Hummingbird
        [
            ["AIR","MOT","HELI","REG","LAND+","PARA+"],1,
            ["B_Heli_Light_01_F"],
            [2,"B_Helipilot_F",6,"RANDOM"]
        ],
        //Ghosthawk
        [
            ["AIR","MEC","HELI","REG","LAND+","PARA+"],1,
            ["B_Heli_Transport_01_F"],
            [2,"B_Helipilot_F",2,"B_helicrew_F",8,"RANDOM"]
        ],
        //A-164 (A-10)
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],2,
            ["B_Plane_CAS_01_dynamicLoadout_F"],
            ["B_Fighter_Pilot_F"]
        ],
        //Black wasp
        [
            ["AIR","MEC","PLANE","AA","AT","AIRSTRIKE+"],3,
            ["B_Plane_Fighter_01_F",false,["PylonRack_Missile_AMRAAM_D_x1","PylonRack_Missile_AMRAAM_D_x1","PylonRack_Missile_AGM_02_x2","PylonRack_Missile_AGM_02_x2","PylonMissile_Missile_BIM9X_x1","PylonMissile_Missile_BIM9X_x1","PylonMissile_Missile_AMRAAM_D_INT_x1","PylonMissile_Missile_AMRAAM_D_INT_x1","PylonMissile_Missile_AMRAAM_D_INT_x1","PylonMissile_Missile_AMRAAM_D_INT_x1","PylonMissile_Bomb_GBU12_x1","PylonMissile_Bomb_GBU12_x1"]],
            ["B_Fighter_Pilot_F"]
        ],

        //=======================================
        /*BOATS - Sea boats*/
        //Assault boat
        [
            ["BOAT","MOT","REG"],1,
            ["B_Boat_Transport_01_F"],
            ["B_Soldier_F",4,"RANDOM"]
        ],
        //Speed boat
        [
            ["BOAT","MEC","REG"],2,
            ["B_Boat_Armed_01_minigun_F"],
            [3,"B_Soldier_F"]
        ],
        //Police boat
        [
            ["BOAT","MOT","REG"],1,
            ["C_Boat_Civil_01_police_F",[["Police",1],["hidePolice",0,"HideRescueSigns",1,"HidePoliceSigns",0]],false],
            ["B_GEN_Commander_F",2,"B_GEN_Soldier_F"],
            {[_this,NWG_DSPAWNFACTION_NATO_GendarmerieLoadouts] call NWG_fnc_dsAcHelperDressUnits}
        ]
    ]
];


//===============================================
//Additional code data
//Gendarmerie:
NWG_DSPAWNFACTION_NATO_GendarmerieLoadouts = [
    /*protector*/[["SMG_05_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_9x21_Mag_SMG_02",2,30]]],["V_TacVest_gen_F",[["30Rnd_9x21_Mag_SMG_02",3,30],["16Rnd_9x21_Mag",2,16],["SmokeShell",1,1]]],nil,nil,nil,nil,nil],
    /*protector*/[["SMG_05_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_9x21_Mag_SMG_02",2,30]]],["V_TacVest_gen_F",[["30Rnd_9x21_Mag_SMG_02",3,30],["16Rnd_9x21_Mag",2,16],["SmokeShell",1,1]]],nil,nil,nil,nil,nil],
    /*sting    */[["SMG_02_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_9x21_Mag_SMG_02",3,30]]],["V_TacVest_gen_F",[["16Rnd_9x21_Mag",2,16],["SmokeShell",1,1],["30Rnd_9x21_Mag_SMG_02",5,30]]],nil,nil,nil,nil,nil],
    /*sting    */[["SMG_02_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_9x21_Mag_SMG_02",3,30]]],["V_TacVest_gen_F",[["16Rnd_9x21_Mag",2,16],["SmokeShell",1,1],["30Rnd_9x21_Mag_SMG_02",5,30]]],nil,nil,nil,nil,nil],
    /*pdw2000  */[["hgun_PDW2000_F","","acc_flashlight","",["30Rnd_9x21_Mag",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_9x21_Mag",3,30]]],["V_TacVest_gen_F",[["SmokeShell",2,1],["30Rnd_9x21_Mag",8,30]]],nil,nil,nil,nil,nil],
    /*P90      */[["SMG_03C_TR_black","","acc_flashlight","",["50Rnd_570x28_SMG_03",50],[],""],[],nil,[nil,[["FirstAidKit",2],["16Rnd_9x21_Mag",2,16],["50Rnd_570x28_SMG_03",1,50]]],["V_TacVest_gen_F",[["SmokeShell",2,1],["50Rnd_570x28_SMG_03",4,50]]],nil,nil,nil,nil,nil],
    /*spar     */[["arifle_SPAR_01_blk_F","","acc_flashlight","",["30Rnd_556x45_Stanag",30],[],""],nil,nil,[nil,[["FirstAidKit",1],["30Rnd_556x45_Stanag",3,30]]],["V_TacVest_gen_F",[["16Rnd_9x21_Mag",2,16],["SmokeShell",1,1],["30Rnd_556x45_Stanag",7,30]]],nil,nil,nil,nil,nil],
    /*Katiba   */[["arifle_Katiba_F","","acc_flashlight","",["30Rnd_65x39_caseless_green",30],[],""],[],nil,[nil,[["FirstAidKit",2],["16Rnd_9x21_Mag",2,16],["30Rnd_65x39_caseless_green",1,30]]],["V_TacVest_gen_F",[["SmokeShell",2,1],["30Rnd_65x39_caseless_green",7,30],["HandGrenade",2,1]]],nil,nil,nil,nil,nil],
    /*LIM mgun */[["LMG_03_F","","acc_flashlight","",["200Rnd_556x45_Box_F",200],[],""],nil,nil,[nil,[["FirstAidKit",2],["16Rnd_9x21_Mag",2,16]]],["V_TacVest_gen_F",[["SmokeShell",2,1],["200Rnd_556x45_Box_F",2,200]]],nil,nil,nil,nil,nil]
];
//Gendarmerie Speznaz:
NWG_DSPAWNFACTION_NATO_GendarmerieSpeznazLoadouts = [
    /*sturm01*/[["arifle_Katiba_F","","acc_flashlight","",["30Rnd_65x39_caseless_green",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",1],["30Rnd_65x39_caseless_green",2,30]]],["V_TacVest_blk_POLICE",[["FirstAidKit",1],["SmokeShell",4,1],["30Rnd_65x39_caseless_green",7,30]]],[],"H_PASGT_basic_black_F","G_Aviator",[],nil],
    /*sturm01*/[["arifle_Katiba_F","","acc_flashlight","",["30Rnd_65x39_caseless_green",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",1],["30Rnd_65x39_caseless_green",2,30]]],["V_TacVest_blk_POLICE",[["FirstAidKit",1],["SmokeShell",4,1],["30Rnd_65x39_caseless_green",7,30]]],[],"H_PASGT_basic_black_F","G_Aviator",[],nil],
    /*sturm02*/[["SMG_02_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["30Rnd_9x21_Mag_SMG_02",1,30]]],["V_TacVest_blk_POLICE",[["SmokeShell",3,1],["30Rnd_9x21_Mag_SMG_02",7,30]]],[],"H_PASGT_basic_black_F","G_Tactical_Clear",[],nil],
    /*sturm02*/[["SMG_02_F","","acc_flashlight","",["30Rnd_9x21_Mag_SMG_02",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["30Rnd_9x21_Mag_SMG_02",1,30]]],["V_TacVest_blk_POLICE",[["SmokeShell",3,1],["30Rnd_9x21_Mag_SMG_02",7,30]]],[],"H_PASGT_basic_black_F","G_Tactical_Clear",[],nil],
    /*sturm03*/[["arifle_SPAR_01_blk_F","","acc_flashlight","",["30Rnd_556x45_Stanag",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["30Rnd_556x45_Stanag",1,30]]],["V_TacVest_blk_POLICE",[["SmokeShell",3,1],["30Rnd_556x45_Stanag",8,30]]],[],"H_PASGT_basic_black_F","G_Balaclava_blk",[],nil],
    /*sturm03*/[["arifle_SPAR_01_blk_F","","acc_flashlight","",["30Rnd_556x45_Stanag",30],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["30Rnd_556x45_Stanag",1,30]]],["V_TacVest_blk_POLICE",[["SmokeShell",3,1],["30Rnd_556x45_Stanag",8,30]]],[],"H_PASGT_basic_black_F","G_Balaclava_blk",[],nil],
    /*strumGL*/[["arifle_Katiba_GL_F","","acc_flashlight","",["30Rnd_65x39_caseless_green",30],["1Rnd_HE_Grenade_shell",1],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2]]],["V_TacVest_blk_POLICE",[["SmokeShell",1,1],["1Rnd_HE_Grenade_shell",5,1],["30Rnd_65x39_caseless_green",3,30],["1Rnd_Smoke_Grenade_shell",5,1],["UGL_FlareWhite_F",5,1]]],["B_Messenger_Black_F",[["1Rnd_HE_Grenade_shell",5,1],["UGL_FlareWhite_F",5,1],["1Rnd_Smoke_Grenade_shell",5,1],["30Rnd_65x39_caseless_green",5,30]]],"H_PASGT_basic_black_F","G_Combat",[],nil],
    /*medic01*/[["SMG_03C_black","","acc_flashlight","",["50Rnd_570x28_SMG_03",50],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["50Rnd_570x28_SMG_03",1,50]]],["V_TacVestIR_blk",[["Medikit",1],["FirstAidKit",2],["SmokeShell",2,1],["50Rnd_570x28_SMG_03",3,50]]],[],"H_PASGT_basic_black_F","",[],nil],
    /*marksmn*/[["arifle_SPAR_03_blk_F","muzzle_snds_B","","optic_SOS",["20Rnd_762x51_Mag",20],[],"bipod_01_F_blk"],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",2],["20Rnd_762x51_Mag",1,20]]],["V_TacVest_blk_POLICE",[["SmokeShell",3,1],["20Rnd_762x51_Mag",3,20],["16Rnd_9x21_Mag",3,16]]],["B_Messenger_Black_F",[["20Rnd_762x51_Mag",5,20]]],"H_PASGT_basic_black_F","G_Balaclava_blk",[],nil],
    /*mgunner*/[["LMG_03_F","","acc_flashlight","",["200Rnd_556x45_Box_F",200],[],""],[],["hgun_P07_blk_F","","","",["16Rnd_9x21_Mag",16],[],""],["U_B_GEN_Commander_F",[["FirstAidKit",1]]],["V_TacVest_blk_POLICE",[["FirstAidKit",1],["SmokeShell",4,1],["200Rnd_556x45_Box_F",1,200]]],["B_Messenger_Black_F",[["200Rnd_556x45_Box_F",3,200]]],"H_PASGT_basic_black_F","G_Balaclava_blk",[],nil]
];

//return
_faction