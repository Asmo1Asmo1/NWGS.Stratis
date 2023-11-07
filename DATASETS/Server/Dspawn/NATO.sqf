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
[
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
        "B_Soldier_TL_F"],

        /*Uncommon units (30% chance) (AT soldiers or heavy machinegunners for example)*/
        ["B_soldier_M_F",
        "B_officer_F",
        "B_soldier_repair_F",
        "B_soldier_LAT_F",
        "B_soldier_LAT2_F",
        "B_Soldier_lite_F",
        "B_Soldier_SL_F",
        "B_HeavyGunner_F"],

        /*Rare units (10% chance) (AA soldiers or marksmans for example)*/
        ["B_soldier_AT_F",
        "B_Sharpshooter_F",
        "B_soldier_AA_F"]
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
            ["B_APC_Tracked_01_CRV_F",[["Sand",1],["showAmmobox",1,"showWheels",1,"showCamonetHull",1,"showBags",1]],false],
            [3,"B_crew_F"]
        ],
        //Panther
        [
            ["VEH","MEC","REG"],1,
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
                private _offsets = [[-0.00012207,-1.99898,0.959962],[[-5.25924e-006,0.999999,-0.00159716],[0.000130184,0.00159716,0.999999]]];
                (_this + ["B_SAM_System_01_F",_offsets]) call NWG_DSPAWN_AC_AttachTurret;
            }
        ],
        //Stomper UAV
        [
            ["VEH","MEC","UAV","REG"],1,
            ["B_UGV_01_rcws_F"],
            [2,"B_UAV_AI"]
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
        ]
    ]
]