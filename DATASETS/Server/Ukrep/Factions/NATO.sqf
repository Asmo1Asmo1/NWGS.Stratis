createHashMapFromArray [

//========================================================================================================
/*  ==== UNITS ====     */

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

//========================================================================================================
/*  ==== VEHICLES ====     */

[
    "Land_VR_Target_MRAP_01_F",/*Small VR vehicle*/
    [
        ["B_MRAP_01_F",     [/*crew:*/[2,"B_Soldier_F"]]],
        ["B_MRAP_01_gmg_F", [/*crew:*/[2,"B_Soldier_F"]]],
        ["B_MRAP_01_hmg_F", [/*crew:*/[2,"B_Soldier_F"]]],
        ["B_LSV_01_AT_F",   [/*crew:*/[3,"B_Soldier_F"]]],
        ["B_LSV_01_armed_F",[/*crew:*/[3,"B_Soldier_F"]]],
        ["B_LSV_01_unarmed_F",[/*crew:*/[2,"B_Soldier_F"]]]
    ]
],

[
    "Land_VR_Target_APC_Wheeled_01_F",/*Medium VR vehicle*/
    [
        ["B_APC_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["B_APC_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["B_APC_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["B_APC_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showBags",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["B_AFV_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_cannon_F",   [/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_up_cannon_F",[/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_up_cannon_F",[/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_up_cannon_F",[/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_AFV_Wheeled_01_up_cannon_F",[/*crew:*/[3,"B_crew_F"],/*appearance:*/[["Sand",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["B_Truck_01_mover_F",[/*crew:*/[]]],
        ["B_Truck_01_mover_F",[/*crew:*/["B_Soldier_F"]]],
        ["B_Truck_01_ammo_F", [/*crew:*/[]]],
        ["B_Truck_01_ammo_F", [/*crew:*/["B_Soldier_F"]]],
        ["B_Truck_01_box_F",  [/*crew:*/[]]],
        ["B_Truck_01_box_F",  [/*crew:*/["B_Soldier_F"]]],
        ["B_Truck_01_fuel_F", [/*crew:*/[]]],
        ["B_Truck_01_fuel_F", [/*crew:*/[2,"B_Soldier_F"]]]
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

//========================================================================================================
/*  ==== HELICOPTERS ==== */
[
    "B_Heli_Transport_03_unarmed_F",/*Unarmed black huron*/
    [
        ["B_Heli_Light_01_dynamicLoadout_F",    [/*crew:*/[2,"B_Helipilot_F"]]],
        ["B_Heli_Light_01_dynamicLoadout_F",    [/*crew:*/[]]],
        ["B_Heli_Attack_01_dynamicLoadout_F",   [/*crew:*/[2,"B_Helipilot_F"]]],
        ["B_Heli_Attack_01_dynamicLoadout_F",   [/*crew:*/[]]],
        ["B_Heli_Transport_03_F",               [/*crew:*/[2,"B_Helipilot_F",2,"B_helicrew_F"]]],
        ["B_Heli_Transport_03_F",               [/*crew:*/[]]],
        ["B_Heli_Transport_03_unarmed_F",       [/*crew:*/[2,"B_Helipilot_F"]]],
        ["B_Heli_Transport_03_unarmed_F",       [/*crew:*/[]]],
        ["B_Heli_Light_01_F",                   [/*crew:*/[2,"B_Helipilot_F"]]],
        ["B_Heli_Light_01_F",                   [/*crew:*/[]]],
        ["B_Heli_Transport_01_F",               [/*crew:*/[2,"B_Helipilot_F",2,"B_helicrew_F"]]],
        ["B_Heli_Transport_01_F",               [/*crew:*/[]]],
        ["B_Heli_Transport_01_pylons_F",        [/*crew:*/[]]]
    ]
],

//========================================================================================================
/*  ====   TURRETS    ====*/

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
        "B_static_AT_F",
        "B_Mortar_01_F",
        "B_Mortar_01_F"
    ]
],

//========================================================================================================
/*  ==== OBJECTS    ====*/

[
    "Land_VR_Shape_01_cube_1m_F",/*VR cube (boxes)*/
    [
        /*Loot crates*/
        ["Box_NATO_Wps_F",      /*payload:*/2],
        ["Box_NATO_Wps_F",      /*payload:*/2],
        ["Box_NATO_Wps_F",      /*payload:*/2],
        ["Box_NATO_Ammo_F",     /*payload:*/2],
        ["Box_NATO_AmmoOrd_F",  /*payload:*/2],
        ["Box_NATO_Grenades_F", /*payload:*/2],
        ["Box_NATO_Support_F",  /*payload:*/2],
        /*Props*/
        ["Land_MetalBarrel_F",      /*payload:*/0],
        ["FlexibleTank_01_forest_F",/*payload:*/0],
        ["TrashBagHolder_01_F",     /*payload:*/0],
        ["Land_PaperBox_01_small_closed_brown_F",/*payload:*/0]
    ]
],

[
    "Land_MedicalTent_01_NATO_generic_inner_F",/*Tent (tents)*/
    [
        ["Land_DeconTent_01_NATO_F",                /*payload:*/1],
        ["Land_MedicalTent_01_NATO_generic_inner_F",/*payload:*/1],
        ["Land_MedicalTent_01_NATO_generic_open_F", /*payload:*/1],
        ["Land_MedicalTent_01_NATO_generic_outer_F",/*payload:*/1]
    ]
],

//========================================================================================================
/*  ==== CIVILIAN VEHICLES  ====*/
[
    "C_Offroad_01_F",/*Offroad*/
    [
        ["C_Offroad_01_F",          [/*crew:*/[],/*appearance:*/[["Red",0.5,"Beige",0.5,"White",0.5,"Blue",0.5,"Darkred",0.5,"Bluecustom",0.5,"IDAP",0.5,"Green",0.5,"ParkRanger",0.5],["HideDoor1",0,"HideDoor2",0,"HideDoor3",0.4,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0.5,"HideConstruction",0.5,"hidePolice",1,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]] ]],
        ["C_Offroad_01_F",          [/*crew:*/[],/*appearance:*/[["Red",0.5,"Beige",0.5,"White",0.5,"Blue",0.5,"Darkred",0.5,"Bluecustom",0.5,"IDAP",0.5,"Green",0.5,"ParkRanger",0.5],["HideDoor1",1,"HideDoor2",1,"HideDoor3",0.6,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0.5,"HideConstruction",0.5,"hidePolice",1,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]] ]],
        ["C_Offroad_01_covered_F",  [/*crew:*/[],/*appearance:*/[["Green",0.5,"Black",0.5,"ParkRanger",0.5],["hidePolice",1,"HideServices",1,"HideCover",0,"StartBeaconLight",0,"HideRoofRack",1,"HideLoudSpeakers",1,"HideAntennas",1,"HideBeacon",1,"HideSpotlight",1,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0,"HideConstruction",0,"BeaconsStart",0]] ]],
        ["C_Offroad_01_covered_F",  [/*crew:*/[],/*appearance:*/[["Green",0.5,"Black",0.5,"ParkRanger",0.5],["hidePolice",1,"HideServices",0,"HideCover",1,"StartBeaconLight",0,"HideRoofRack",1,"HideLoudSpeakers",1,"HideAntennas",1,"HideBeacon",1,"HideSpotlight",1,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",1,"HideConstruction",0,"BeaconsStart",0]] ]],
        ["C_SUV_01_F",              [/*crew:*/[],/*appearance:*/[["Red",0.5,"Black",0.5,"Grey",0.5,"Orange",0.5],[]] ]],
        ["C_SUV_01_F",              [/*crew:*/[],/*appearance:*/[["Red",0.5,"Black",0.5,"Grey",0.5,"Orange",0.5],[]] ]],
        ["C_Hatchback_01_F",            [/*crew:*/[],/*appearance:*/[["Beige",0.5,"Green",0.5,"Blue",0.5,"Bluecustom",0.5,"Beigecustom",0.5,"Yellow",0.5,"Grey",0.5,"Black",0.5,"Dark",0.5],[]] ]],
        ["C_Hatchback_01_sport_F",      [/*crew:*/[],/*appearance:*/[["Red",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Beige",0.5,"Green",0.5,"Grey",0.5],[]] ]],
        ["C_Offroad_02_unarmed_F",      [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Green",0.5,"Orange",0.5,"Red",0.5,"White",0.5,"Brown",0.5,"Olive",0.5,"IDAP",0.5],["hideLeftDoor",0,"hideRightDoor",0,"hideRearDoor",0,"hideBullbar",0.5,"hideFenders",0.5,"hideHeadSupportRear",0,"hideHeadSupportFront",0,"hideRollcage",0.5,"hideSeatsRear",0.5,"hideSpareWheel",0.5]] ]],
        ["C_Offroad_02_unarmed_F",      [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Green",0.5,"Orange",0.5,"Red",0.5,"White",0.5,"Brown",0.5,"Olive",0.5,"IDAP",0.5],["hideLeftDoor",1,"hideRightDoor",1,"hideRearDoor",0.5,"hideBullbar",0.5,"hideFenders",0.5,"hideHeadSupportRear",1,"hideHeadSupportFront",1,"hideRollcage",0.5,"hideSeatsRear",0.5,"hideSpareWheel",0.5]] ]]
    ]
],
[
    "C_Quadbike_01_F",/*Quad bike*/
    [
        ["C_Quadbike_01_F",     [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Red",0.5,"White",0.5,"Olive",0.5,"LDF",0.5,"ParkRanger",0.5],[]] ]]
    ]
],
[
    "C_Kart_01_F",/*Kart*/
    [
        ["C_Kart_01_F",         [/*crew:*/[],/*appearance:*/[["Fuel",0.5,"Bluking",0.5,"Redstone",0.5,"Vrana",0.5,"Green",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Yellow",0.5,"Black",0.5,"Red",0.5],[]] ]]
    ]
],
[
    "C_Truck_02_box_F",/*Zamak Orange Box*//*One zamak to rule them all - universal 'replace with everything' vehicle*/
    [
        ["C_Van_01_fuel_F",     [/*crew:*/[],/*appearance:*/[["Black",0.5,"White",0.5,"Red",0.5,"Black_v2",0.5,"White_v2",0.5,"Red_v2",0.5],[]] ]],
            ["C_Van_01_box_F",      [/*crew:*/[],/*appearance:*/[["Black",0.5,"White",0.5,"Red",0.5],[]] ]],
            ["C_Van_01_transport_F",[/*crew:*/[],/*appearance:*/[["Black",0.5,"White",0.5,"Red",0.5,"Brown",0.5,"Olive",0.5],[]] ]],
            ["C_Tractor_01_F",      [/*crew:*/[],/*appearance:*/[["Green",0.5,"Red",0.5,"Blue",0.5],[]] ]],
        ["C_Offroad_01_F",          [/*crew:*/[],/*appearance:*/[["Red",0.5,"Beige",0.5,"White",0.5,"Blue",0.5,"Darkred",0.5,"Bluecustom",0.5,"IDAP",0.5,"Green",0.5,"ParkRanger",0.5],["HideDoor1",0,"HideDoor2",0,"HideDoor3",0.4,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0.5,"HideConstruction",0.5,"hidePolice",1,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]] ]],
            ["C_Offroad_01_F",          [/*crew:*/[],/*appearance:*/[["Red",0.5,"Beige",0.5,"White",0.5,"Blue",0.5,"Darkred",0.5,"Bluecustom",0.5,"IDAP",0.5,"Green",0.5,"ParkRanger",0.5],["HideDoor1",1,"HideDoor2",1,"HideDoor3",0.6,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0.5,"HideConstruction",0.5,"hidePolice",1,"HideServices",1,"BeaconsStart",0,"BeaconsServicesStart",0]] ]],
            ["C_Offroad_01_covered_F",  [/*crew:*/[],/*appearance:*/[["Green",0.5,"Black",0.5,"ParkRanger",0.5],["hidePolice",1,"HideServices",1,"HideCover",0,"StartBeaconLight",0,"HideRoofRack",1,"HideLoudSpeakers",1,"HideAntennas",1,"HideBeacon",1,"HideSpotlight",1,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",0,"HideConstruction",0,"BeaconsStart",0]] ]],
            ["C_Offroad_01_covered_F",  [/*crew:*/[],/*appearance:*/[["Green",0.5,"Black",0.5,"ParkRanger",0.5],["hidePolice",1,"HideServices",0,"HideCover",1,"StartBeaconLight",0,"HideRoofRack",1,"HideLoudSpeakers",1,"HideAntennas",1,"HideBeacon",1,"HideSpotlight",1,"HideDoor3",0,"OpenDoor3",0,"HideDoor1",0,"HideDoor2",0,"HideBackpacks",1,"HideBumper1",1,"HideBumper2",1,"HideConstruction",0,"BeaconsStart",0]] ]],
            ["C_SUV_01_F",              [/*crew:*/[],/*appearance:*/[["Red",0.5,"Black",0.5,"Grey",0.5,"Orange",0.5],[]] ]],
            ["C_SUV_01_F",              [/*crew:*/[],/*appearance:*/[["Red",0.5,"Black",0.5,"Grey",0.5,"Orange",0.5],[]] ]],
            ["C_Hatchback_01_F",            [/*crew:*/[],/*appearance:*/[["Beige",0.5,"Green",0.5,"Blue",0.5,"Bluecustom",0.5,"Beigecustom",0.5,"Yellow",0.5,"Grey",0.5,"Black",0.5,"Dark",0.5],[]] ]],
            ["C_Hatchback_01_sport_F",      [/*crew:*/[],/*appearance:*/[["Red",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Beige",0.5,"Green",0.5,"Grey",0.5],[]] ]],
            ["C_Offroad_02_unarmed_F",      [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Green",0.5,"Orange",0.5,"Red",0.5,"White",0.5,"Brown",0.5,"Olive",0.5,"IDAP",0.5],["hideLeftDoor",0,"hideRightDoor",0,"hideRearDoor",0,"hideBullbar",0.5,"hideFenders",0.5,"hideHeadSupportRear",0,"hideHeadSupportFront",0,"hideRollcage",0.5,"hideSeatsRear",0.5,"hideSpareWheel",0.5]] ]],
            ["C_Offroad_02_unarmed_F",      [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Green",0.5,"Orange",0.5,"Red",0.5,"White",0.5,"Brown",0.5,"Olive",0.5,"IDAP",0.5],["hideLeftDoor",1,"hideRightDoor",1,"hideRearDoor",0.5,"hideBullbar",0.5,"hideFenders",0.5,"hideHeadSupportRear",1,"hideHeadSupportFront",1,"hideRollcage",0.5,"hideSeatsRear",0.5,"hideSpareWheel",0.5]] ]],
        ["C_Quadbike_01_F",     [/*crew:*/[],/*appearance:*/[["Black",0.5,"Blue",0.5,"Red",0.5,"White",0.5,"Olive",0.5,"LDF",0.5,"ParkRanger",0.5],[]] ]],
        ["C_Van_02_vehicle_F",          [/*crew:*/[],/*appearance:*/[["IDAP",0.5,"Redstone",0.5,"CivService",0.5,"Syndikat",0.5,"Daltgreen",0.5,"Vrana",0.5,"BluePearl",0.5,"Fuel",0.5,"BattleBus",0.5,"Green",0.5,"Black",0.5,"Red",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Swifd",0.5,"AAN",0.5,"LDF",0.5,"Astra",0.5,"Benzyna",0.5],["Enable_Cargo",0,"Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0,"ladder_hide",1,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",1,"roof_rack_hide",1,"LED_lights_hide",1,"sidesteps_hide",1,"rearsteps_hide",0,"side_protective_frame_hide",1,"front_protective_frame_hide",1,"beacon_front_hide",1,"beacon_rear_hide",1]] ]],
            ["C_Van_02_transport_F",        [/*crew:*/[],/*appearance:*/[["IDAP",0.5,"CivService",0.5,"Syndikat",0.5,"Daltgreen",0.5,"Vrana",0.5,"BluePearl",0.5,"Fuel",0.5,"BattleBus",0.5,"Green",0.5,"Black",0.5,"Red",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Swifd",0.5,"AAN",0.5,"LDF",0.5,"LDF_MP",0.5],["Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0,"ladder_hide",1,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",1,"roof_rack_hide",1,"LED_lights_hide",1,"sidesteps_hide",1,"rearsteps_hide",1,"side_protective_frame_hide",0,"front_protective_frame_hide",1,"beacon_front_hide",1,"beacon_rear_hide",1]] ]],
            ["C_Van_02_service_F",          [/*crew:*/[],/*appearance:*/[["IDAP",0.5,"Redstone",0.5,"CivService",0.5,"Syndikat",0.5,"Daltgreen",0.5,"Vrana",0.5,"BluePearl",0.5,"Fuel",0.5,"BattleBus",0.5,"Green",0.5,"Black",0.5,"Red",0.5,"Blue",0.5,"Orange",0.5,"White",0.5,"Swifd",0.5,"AAN",0.5,"Benzyna",0.5],["Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0,"ladder_hide",0,"spare_tyre_holder_hide",0,"spare_tyre_hide",0,"reflective_tape_hide",0,"roof_rack_hide",0,"LED_lights_hide",0,"sidesteps_hide",1,"rearsteps_hide",1,"side_protective_frame_hide",0,"front_protective_frame_hide",0,"beacon_front_hide",0,"beacon_rear_hide",0]] ]],
            ["C_Van_02_medevac_F",          [/*crew:*/[],/*appearance:*/[["IdapAmbulance",0.5,"CivAmbulance",0.5,"LDFAmbulance",0.5],["Door_1_source",0,"Door_2_source",0,"Door_3_source",0,"Door_4_source",0,"Hide_Door_1_source",0,"Hide_Door_2_source",0,"Hide_Door_3_source",0,"Hide_Door_4_source",0,"lights_em_hide",0,"ladder_hide",1,"spare_tyre_holder_hide",1,"spare_tyre_hide",1,"reflective_tape_hide",0,"roof_rack_hide",1,"LED_lights_hide",0,"sidesteps_hide",0,"rearsteps_hide",1,"side_protective_frame_hide",1,"front_protective_frame_hide",1,"beacon_front_hide",0,"beacon_rear_hide",0]] ]],
        ["C_Truck_02_fuel_F",       [/*crew:*/[],/*appearance:*/[["Orange",0.5,"Blue",0.5,"IDAP",0.5],[]] ]],
            ["C_Truck_02_box_F",        [/*crew:*/[],/*appearance:*/[["OrangeOrange",0.5,"OrangeGreen",0.5,"BlueOrange",0.5,"BlueGreen",0.5],[]] ]],
            ["C_Truck_02_transport_F",  [/*crew:*/[],/*appearance:*/[["Orange",0.5,"Blue",0.5,"IDAP",0.5],[]] ]],
            ["C_Truck_02_covered_F",    [/*crew:*/[],/*appearance:*/[["OrangeBlue",0.5,"OrangeOlive",0.5,"BlueBlue",0.5,"BlueOlive",0.5,"IDAP",0.5],[]] ]]
    ]
],
[
    "C_Boat_Civil_01_F",/*Boat*/
    [
        ["C_Boat_Civil_01_F",           [/*crew:*/[],/*appearance:*/[["Civilian",0.75,"Rescue",0.25,"Police",0],["hidePolice",1,"HideRescueSigns",0.75,"HidePoliceSigns",1]] ]],
        ["C_Boat_Civil_01_F",           [/*crew:*/[],/*appearance:*/[["Civilian",0.75,"Rescue",0.25,"Police",0],["hidePolice",1,"HideRescueSigns",0.75,"HidePoliceSigns",1]] ]],
        ["C_Rubberboat",                [/*crew:*/[],/*appearance:*/[["Black",0.25,"Hex",0,"Rescue",0.25,"Civilian",0.5,"Digital",0],[]] ]],
        ["C_Boat_Transport_02_F",       [/*crew:*/[],/*appearance:*/[["Black",0.5,"Civilian",0.5],[]] ]],
        ["C_Scooter_Transport_01_F",    [/*crew:*/[],/*appearance:*/[["White",0.5,"Black",0.5,"Blue",0.5,"Grey",0.5,"Lime",0.5,"Red",0.5,"Yellow",0.5],[]] ]]
    ]
]
];