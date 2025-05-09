createHashMapFromArray [

//========================================================================================================
/*  ==== UNITS ====     */

[
    "B_Soldier_VR_F",/*Blue VR unit (common units)*/
    [
        "I_Soldier_A_F",
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
        "I_Soldier_SL_F",
        "I_Soldier_TL_F",
        "I_soldier_UAV_F",
        "I_soldier_UAV_06_F",
        "I_soldier_UAV_06_medical_F"
    ]
],

[
    "I_Soldier_VR_F",/*Green VR unit (high ground units)*/
    [
        "I_Soldier_AR_F",
        "I_Soldier_GL_F",
        "I_Soldier_M_F",
        "I_Soldier_AA_F",
        "I_Soldier_AA_F",
        "I_Soldier_AT_F",
        "I_Soldier_AT_F",
        "I_Soldier_LAT_F",
        "I_Soldier_LAT_F",
        "I_Soldier_LAT2_F",
        "I_Soldier_LAT2_F",
        "I_Sniper_F",
        "I_ghillie_ard_F",
        "I_ghillie_lsh_F",
        "I_ghillie_sard_F",
        "I_Spotter_F",
        "I_Soldier_TL_F",
        "I_G_Sharpshooter_F"
    ]
],

[
    "C_Soldier_VR_F",/*Purple VR unit (officers)*/
    [
        "I_officer_F",
        "I_Officer_Parade_F",
        "I_Officer_Parade_Veteran_F",
        "I_Story_Colonel_F",
        "I_Captain_Hladas_F",
        "I_Story_Officer_01_F"
    ]
],

/*Divers*/
["B_diver_F",       "I_diver_F"],
["B_diver_exp_F",   "I_diver_exp_F"],
["B_diver_TL_F",    "I_diver_TL_F"],

//========================================================================================================
/*  ==== VEHICLES ====     */

[
    "Land_VR_Target_MRAP_01_F",/*Small VR vehicle*/
    [
        ["I_LT_01_AA_F",    [/*crew:*/[2,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["I_Quadbike_01_F", [/*crew:*/[]]],
        ["I_MRAP_03_F",     [/*crew:*/[2,"I_soldier_F"]]],
        ["I_MRAP_03_gmg_F", [/*crew:*/[3,"I_soldier_F"]]],
        ["I_MRAP_03_hmg_F", [/*crew:*/[3,"I_soldier_F"]]],
        ["I_UGV_01_F",      [/*crew:*/[]]],
        ["I_UGV_01_rcws_F", [/*crew:*/[2,"B_UAV_AI"]]],
        ["I_LT_01_AT_F",    [/*crew:*/[2,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["I_LT_01_scout_F", [/*crew:*/[2,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["I_LT_01_cannon_F",[/*crew:*/[2,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showTools",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]]
    ]
],

[
    "Land_VR_Target_APC_Wheeled_01_F",/*Medium VR vehicle*/
    [
        ["I_APC_Wheeled_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]]]],
        ["I_APC_Wheeled_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]]]],
        ["I_APC_Wheeled_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]]]],
        ["I_APC_Wheeled_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]]]],
        ["I_APC_tracked_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["I_APC_tracked_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["I_APC_tracked_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["I_APC_tracked_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["I_Truck_02_MRL_F",            [/*crew:*/[2,"I_soldier_F"]]],
        ["I_Truck_02_MRL_F",            [/*crew:*/[2,"I_soldier_F"]]],
        ["I_Truck_02_MRL_F",            [/*crew:*/[2,"I_soldier_F"]]],
        ["I_Truck_02_MRL_F",            [/*crew:*/[2,"I_soldier_F"]]],
        ["I_Truck_02_ammo_F",           [/*crew:*/[]]],
        ["I_Truck_02_ammo_F",           [/*crew:*/["I_soldier_F"]]],
        ["I_Truck_02_fuel_F",           [/*crew:*/[]]],
        ["I_Truck_02_fuel_F",           [/*crew:*/["I_soldier_F"]]],
        ["I_Truck_02_medical_F",        [/*crew:*/[]]],
        ["I_Truck_02_medical_F",        [/*crew:*/["I_soldier_F"]]],
        ["I_Truck_02_box_F",            [/*crew:*/[]]],
        ["I_Truck_02_box_F",            [/*crew:*/["I_soldier_F"]]],
        ["I_Truck_02_transport_F",      [/*crew:*/[]]],
        ["I_Truck_02_transport_F",      [/*crew:*/[5,"I_soldier_F"]]],
        ["I_Truck_02_covered_F",        [/*crew:*/[]]],
        ["I_Truck_02_covered_F",        [/*crew:*/[5,"I_soldier_F"]]]
    ]
],

[
    "Land_VR_Target_MBT_01_cannon_F",/*Large VR vehicle*/
    [
        ["I_APC_Wheeled_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep",1],["showCamonetHull",0.5,"showBags",0.5,"showBags2",0.5,"showTools",0.5,"showSLATHull",0.5]]]],
        ["I_APC_tracked_03_cannon_F",   [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["showBags",0,"showBags2",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showTools",0.5,"showSLATHull",0.5,"showSLATTurret",0.5]]]],
        ["I_Truck_02_MRL_F",            [/*crew:*/[2,"I_soldier_F"]]],
        ["I_MBT_03_cannon_F",           [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["HideTurret",0.5,"HideHull",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5]]]],
        ["I_MBT_03_cannon_F",           [/*crew:*/[3,"I_crew_F"],/*appearance:*/[["Indep_01",1],["HideTurret",0.5,"HideHull",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5]]]]
    ]
],

//========================================================================================================
/*  ==== HELICOPTERS ==== */
[
    "B_Heli_Transport_03_unarmed_F",/*Unarmed black huron*/
    [
        ["I_Heli_Transport_02_F",               [/*crew:*/[2,"I_helipilot_F"]]],
        ["I_Heli_Transport_02_F",               [/*crew:*/[]]],
        ["I_Heli_light_03_dynamicLoadout_F",    [/*crew:*/[2,"I_helipilot_F"]]],
        ["I_Heli_light_03_dynamicLoadout_F",    [/*crew:*/[]]],
        ["I_Heli_light_03_unarmed_F",           [/*crew:*/[2,"I_helipilot_F"],/*appearance:*/[["Indep",1],[]]]],
        ["I_Heli_light_03_unarmed_F",           [/*crew:*/[],/*appearance:*/[["Indep",1],[]]]]
    ]
],

//========================================================================================================
/*  ==== BOATS ==== */
["B_Boat_Armed_01_minigun_F", "I_Boat_Armed_01_minigun_F"],
["B_Boat_Transport_01_F",     "I_Boat_Transport_01_F"],
/*  ==== SUBMARINES ==== */
["B_SDV_01_F", "I_SDV_01_F"],

//========================================================================================================
/*  ====   TURRETS    ====*/

[
    "B_HMG_01_high_F",/*Standing turret*/
    [
        "I_HMG_02_high_F",
        "I_HMG_01_high_F",
        "I_GMG_01_high_F"
    ]
],

[
    "B_HMG_01_F",/*Crouch turret*/
    [
        "I_HMG_02_F",
        "I_HMG_01_F",
        "I_GMG_01_F",
        ["I_HMG_01_A_F",["B_UAV_AI"]],
        ["I_GMG_01_A_F",["B_UAV_AI"]]
    ]
],

[
    "B_static_AA_F",/*Launcher turret*/
    [
        "I_static_AA_F",
        "I_static_AT_F",
        "I_Mortar_01_F",
        "I_Mortar_01_F"
    ]
],

[
    "B_Mortar_01_F",/*Mortar*/
    "I_Mortar_01_F"
],

//========================================================================================================
/*  ==== OBJECTS    ====*/

/*Loot boxes*/
[
    "Land_VR_Shape_01_cube_1m_F",/*VR cube (boxes)*/
    [
        /*Loot crates*/
        ["Box_IND_Wps_F",      /*payload:*/2],
        ["Box_IND_Wps_F",      /*payload:*/2],
        ["Box_IND_Wps_F",      /*payload:*/2],
        ["Box_IND_Ammo_F",     /*payload:*/2],
        ["Box_IND_AmmoOrd_F",  /*payload:*/2],
        ["Box_IND_Grenades_F", /*payload:*/2],
        ["Box_IND_Support_F",  /*payload:*/2],
        /*Props*/
        ["Land_MetalBarrel_F",      /*payload:*/0],
        ["FlexibleTank_01_forest_F",/*payload:*/0],
        ["TrashBagHolder_01_F",     /*payload:*/0],
        ["Land_PaperBox_01_small_closed_brown_F",/*payload:*/0]
    ]
],

/*Nets*/
["CamoNet_BLUFOR_F",        "CamoNet_INDP_F"],
["CamoNet_BLUFOR_open_F",   "CamoNet_INDP_open_F"],
["CamoNet_BLUFOR_big_F",    "CamoNet_INDP_big_F"],

/*Tents*/
[
    "Land_MedicalTent_01_NATO_generic_inner_F",/*Tent (tents)*/
    [
        ["Land_DeconTent_01_AAF_F",                /*payload:*/1],
        ["Land_MedicalTent_01_aaf_generic_inner_F",/*payload:*/1],
        ["Land_MedicalTent_01_aaf_generic_open_F", /*payload:*/1],
        ["Land_MedicalTent_01_aaf_generic_outer_F",/*payload:*/1]
    ]
],
["Land_ConnectorTent_01_NATO_open_F",   "Land_ConnectorTent_01_AAF_open_F"],
["Land_ConnectorTent_01_NATO_cross_F",  "Land_ConnectorTent_01_AAF_cross_F"],
["Land_ConnectorTent_01_NATO_closed_F", "Land_ConnectorTent_01_AAF_closed_F"],

/*Military buildings*/
["Land_Cargo_House_V3_F",   "Land_Cargo_House_V1_F"],
["Land_Cargo_HQ_V3_F",      "Land_Cargo_HQ_V1_F"],
["CargoPlaftorm_01_brown_F","CargoPlaftorm_01_green_F"],
["Land_Cargo_Patrol_V3_F",  "Land_Cargo_Patrol_V1_F"],
["Land_Cargo_Tower_V3_F",   "Land_Cargo_Tower_V1_F"],

/*Faction-specific supply crates*/
["Box_NATO_WpsLaunch_F",    "Box_IND_WpsLaunch_F"],
["Box_NATO_WpsSpecial_F",   "Box_IND_WpsSpecial_F"],
["Box_NATO_Uniforms_F",     "Box_AAF_Uniforms_F"],
["Box_NATO_Equip_F",        "Box_AAF_Equip_F"],
["B_CargoNet_01_ammo_F",    "I_CargoNet_01_ammo_F"],
["B_supplyCrate_F",         "I_supplyCrate_F"],
["Box_NATO_AmmoVeh_F",      "Box_IND_AmmoVeh_F"],

/*Flags*/
["Banner_01_NATO_F","Banner_01_AAF_F"],
["Flag_NATO_F",     "Flag_AAF_F"],

/*Underwater equipment*/
["Item_U_B_Wetsuit",    "Item_U_I_Wetsuit"],
["Vest_V_RebreatherB",  "Vest_V_RebreatherIA"],

/*Electronics (dynamic)*/
["Item_Laserdesignator",["Item_Laserdesignator_03","Item_Laserdesignator_01_khk_F"]],
["Item_NVGoggles",      "Item_NVGoggles_INDEP"],
["Item_B_UavTerminal",  "Item_I_UavTerminal"],

/*Electronics (static)*/
["Land_PortableSolarPanel_01_sand_F",       "Land_PortableSolarPanel_01_olive_F"],
["Land_PortableSolarPanel_01_folded_sand_F","Land_PortableSolarPanel_01_folded_olive_F"],
["SatelliteAntenna_01_Mounted_Sand_F",      "SatelliteAntenna_01_Mounted_Olive_F"],
["OmniDirectionalAntenna_01_sand_F",        "OmniDirectionalAntenna_01_olive_F"],
["Land_PortableWeatherStation_01_sand_F",   "Land_PortableWeatherStation_01_olive_F"],
["Land_BatteryPack_01_battery_sand_F",      "Land_BatteryPack_01_battery_olive_F"],
["Land_BatteryPack_01_closed_sand_F",       "Land_BatteryPack_01_closed_olive_F"],
["Land_BatteryPack_01_open_sand_F",         "Land_BatteryPack_01_open_olive_F"],
["Land_Computer_01_sand_F",                 "Land_Computer_01_olive_F"],
["Land_TripodScreen_01_dual_v1_sand_F",     "Land_TripodScreen_01_dual_v1_F"],
["Land_TripodScreen_01_dual_v2_sand_F",     "Land_TripodScreen_01_dual_v2_F"],
["Land_IPPhone_01_sand_F",                  "Land_IPPhone_01_olive_F"],
["Land_laptop_03_closed_sand_F",            "Land_laptop_03_closed_olive_F"],
["Land_Laptop_03_sand_F",                   "Land_Laptop_03_olive_F"],
["Land_TripodScreen_01_large_sand_F",       "Land_TripodScreen_01_large_F"],
["Land_MultiScreenComputer_01_sand_F",      "Land_MultiScreenComputer_01_olive_F"],
["Land_MultiScreenComputer_01_closed_sand_F",   "Land_MultiScreenComputer_01_closed_olive_F"],
["Land_PortableGenerator_01_sand_F",        "Land_PortableGenerator_01_F"],
["Land_PortableServer_01_sand_F",           "Land_PortableServer_01_olive_F"],
["Land_PortableServer_01_cover_sand_F",     "Land_PortableServer_01_cover_olive_F"],
["Land_Router_01_sand_F",                   "Land_Router_01_olive_F"],
["Land_SolarPanel_04_sand_F",               "Land_SolarPanel_04_olive_F"],
["Land_Tablet_02_sand_F",                   "Land_Tablet_02_F"],
["SatelliteAntenna_01_Sand_F",              "SatelliteAntenna_01_Olive_F"],
["SatelliteAntenna_01_Small_Sand_F",        "SatelliteAntenna_01_Small_Olive_F"],
["Land_PortableLight_02_double_sand_F",     "Land_PortableLight_02_double_olive_F"],
["Land_PortableLight_02_folded_sand_F",     "Land_PortableLight_02_folded_olive_F"],
["Land_PortableLight_02_quad_sand_F",       "Land_PortableLight_02_quad_olive_F"],
["Land_PortableLight_02_single_folded_sand_F",  "Land_PortableLight_02_single_folded_olive_F"],
["Land_PortableLight_02_single_sand_F",     "Land_PortableLight_02_single_olive_F"],
["WaterPump_01_sand_F",                     "WaterPump_01_forest_F"],

/*Military*/
["Land_BattlefieldCross_01_NATO_F", "Land_BattlefieldCross_01_AAF_F"],
["FoldedFlag_01_US_F",              "FoldedFlag_01_Altis_F"],
["Land_DeskChair_01_sand_F",        "Land_DeskChair_01_olive_F"],
["Land_PortableCabinet_01_4drawers_sand_F", "Land_PortableCabinet_01_4drawers_olive_F"],
["Land_PortableCabinet_01_7drawers_sand_F", "Land_PortableCabinet_01_7drawers_olive_F"],
["Land_PortableCabinet_01_bookcase_sand_F", "Land_PortableCabinet_01_bookcase_olive_F"],
["Land_PortableCabinet_01_closed_sand_F",   "Land_PortableCabinet_01_closed_olive_F"],
["Land_PortableCabinet_01_lid_sand_F",      "Land_PortableCabinet_01_lid_olive_F"],
["Land_PortableDesk_01_sand_F",             "Land_PortableDesk_01_olive_F"],
["Land_PortableDesk_01_panel_sand_F",       "Land_PortableDesk_01_panel_olive_F"],

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