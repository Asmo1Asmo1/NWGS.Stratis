createHashMapFromArray [
[
    "B_Soldier_VR_F",/*Blue VR unit (common units)*/
    [
        "B_Soldier_A_F",
        "B_soldier_AAR_F",
        "B_support_AMG_F",
        "B_support_AMort_F",
        "B_soldier_AAA_F",
        "B_soldier_AAT_F",
        "B_medic_F",
        "B_engineer_F",
        "B_soldier_exp_F",
        "B_Soldier_GL_F",
        "B_support_GMG_F",
        "B_support_MG_F",
        "B_support_Mort_F",
        "B_soldier_mine_F",
        "B_soldier_repair_F",
        "B_Soldier_F",
        "B_Soldier_SL_F",
        "B_Soldier_TL_F",
        "B_soldier_UAV_F",
        "B_soldier_UAV_06_F",
        "B_soldier_UAV_06_medical_F",
        "B_soldier_UGV_02_Demining_F",
        "B_soldier_UGV_02_Science_F",
        "B_Patrol_Medic_F",
        "B_Patrol_Engineer_F",
        "B_Patrol_Soldier_TL_F",
        "B_Patrol_Soldier_UAV_F",
        "B_recon_exp_F",
        "B_recon_JTAC_F",
        "B_recon_medic_F",
        "B_recon_F",
        "B_Story_Protagonist_F",
        "B_Story_Pilot_F"
    ]
],

[
    "I_Soldier_VR_F",/*Green VR unit (high ground units)*/
    [
        "B_soldier_AR_F",
        "B_HeavyGunner_F",
        "B_soldier_M_F",
        "B_soldier_AA_F",
        "B_soldier_AT_F",
        "B_soldier_LAT_F",
        "B_soldier_LAT2_F",
        "B_Sharpshooter_F",
        "B_Patrol_Soldier_A_F",
        "B_Patrol_Soldier_AR_F",
        "B_Patrol_HeavyGunner_F",
        "B_Patrol_Soldier_MG_F",
        "B_Patrol_Soldier_M_F",
        "B_Patrol_Soldier_AT_F",
        "B_recon_M_F",
        "B_recon_LAT_F",
        "B_Recon_Sharpshooter_F",
        "B_sniper_F",
        "B_ghillie_ard_F",
        "B_ghillie_lsh_F",
        "B_ghillie_sard_F"
    ]
],

[
    "C_Soldier_VR_F",/*Purple VR unit (officers)*/
    [
        "B_Competitor_F",
        "B_officer_F",
        "B_Officer_Parade_F",
        "B_Officer_Parade_Veteran_F",
        "B_RangeMaster_F",
        "B_Soldier_lite_F",
        "B_recon_TL_F",
        "B_Captain_Pettka_F"
    ]
],

[
    "Land_VR_Shape_01_cube_1m_F",/*VR cube (boxes)*/
    [
        "Land_CampingChair_V2_F",
        "Land_CampingChair_V1_F",
        "Box_NATO_Ammo_F",
        "Box_NATO_Wps_F",
        "Box_NATO_AmmoOrd_F",
        "Box_NATO_Grenades_F",
        "Box_NATO_Support_F",
        "Land_MetalBarrel_F"
    ]
],

[
    "Land_VR_Target_MRAP_01_F",/*Small VR vehicle*/
    [
        ["B_MRAP_01_F",[]],
        ["B_MRAP_01_gmg_F", [/*crew:*/[2,"B_Soldier_F"]]],
        ["B_MRAP_01_hmg_F", [/*crew:*/[2,"B_Soldier_F"]]],
        ["B_LSV_01_AT_F",   [/*crew:*/[3,"B_Soldier_F"]]],
        ["B_LSV_01_armed_F",[/*crew:*/[3,"B_Soldier_F"]]],
        ["B_LSV_01_unarmed_F",[]]
    ]
],

[
    "Land_VR_Target_APC_Wheeled_01_F",/*Medium VR vehicle*/
    [
        ["B_APC_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["B_AFV_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_up_cannon_F",[/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_Truck_01_mover_F",[]]
    ]
],

[
    "Land_VR_Target_MBT_01_cannon_F",/*Large VR vehicle*/
    [
        ["B_APC_Tracked_01_AA_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5,"showBags",0.5]]]],
        ["B_APC_Tracked_01_CRV_F",  [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showAmmobox",0.5,"showWheels",0.5,"showCamonetHull",0.5,"showBags",0.5]]]],
        ["B_APC_Tracked_01_rcws_F", [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showBags",0.5]]]],
        ["B_MBT_01_arty_F",         [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCanisters",0.5,"showCamonetTurret",0.5,"showAmmobox",0.5,"showCamonetHull",0.5]]]],
        ["B_MBT_01_mlrs_F",         [/*crew:*/[2,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5]]]],
        ["B_MBT_01_cannon_F",       [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5]]]],
        ["B_MBT_01_TUSK_F",         [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetTurret",0.5,"showCamonetHull",0.5,"showBags",0.5]]]]
    ]
],

[
    "B_HMG_01_high_F",/*Standing turret*/
    [
        "B_HMG_01_high_F",
        "B_G_HMG_02_high_F",
        "B_GMG_01_high_F"
    ]
],

[
    "B_HMG_01_F",/*Crouch turret*/
    [
        "B_HMG_01_F",
        "B_GMG_01_F",
        ["B_HMG_01_A_F",["B_UAV_AI"]],
        ["B_GMG_01_A_F",["B_UAV_AI"]],
        ["B_Static_Designator_01_F",["B_UAV_AI"]]
    ]
],

[
    "B_static_AA_F",/*Launcher turret*/
    [
        "B_static_AA_F",
        "B_static_AT_F"
    ]
]
];