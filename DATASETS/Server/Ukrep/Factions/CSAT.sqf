createHashMapFromArray [

//========================================================================================================
/*  ==== UNITS ====     */

[
    "B_Soldier_VR_F",/*Blue VR unit (common units)*/
    [
        "O_Soldier_A_F",
        "O_Soldier_AAR_F",
        "O_support_AMG_F",
        "O_support_AMort_F",
        "O_Soldier_AHAT_F",
        "O_Soldier_AR_F",
        "O_medic_F",
        "O_engineer_F",
        "O_soldier_exp_F",
        "O_Soldier_GL_F",
        "O_soldier_mine_F",
        "O_Soldier_AAA_F",
        "O_Soldier_AAT_F",
        "O_soldier_repair_F",
        "O_Soldier_F",
        "O_Soldier_lite_F",
        "O_Soldier_SL_F",
        "O_Soldier_TL_F",
        "O_soldier_UAV_F",
        "O_recon_exp_F",
        "O_recon_JTAC_F",
        "O_recon_medic_F",
        "O_recon_F",
        "O_recon_TL_F",
        "O_soldierU_A_F",
        "O_soldierU_AAR_F",
        "O_soldierU_AAA_F",
        "O_soldierU_AAT_F",
        "O_soldierU_medic_F",
        "O_soldierU_AR_F",
        "O_engineer_U_F",
        "O_soldierU_exp_F",
        "O_SoldierU_GL_F",
        "O_soldierU_repair_F",
        "O_soldierU_F",
        "O_SoldierU_SL_F",
        "O_soldierU_TL_F"
    ]
],

[
    "I_Soldier_VR_F",/*Green VR unit (high ground units)*/
    [
        "O_Soldier_AR_F",
        "O_HeavyGunner_F",
        "O_soldier_M_F",
        "O_Soldier_AA_F",
        "O_Soldier_AT_F",
        "O_Soldier_LAT_F",
        "O_Soldier_HAT_F",
        "O_Sharpshooter_F",
        "O_recon_M_F",
        "O_Pathfinder_F",
        "O_recon_LAT_F",
        "O_sniper_F",
        "O_ghillie_ard_F",
        "O_ghillie_sard_F",
        "O_spotter_F",
        "O_Urban_HeavyGunner_F",
        "O_soldierU_M_F",
        "O_soldierU_AA_F",
        "O_soldierU_AT_F",
        "O_soldierU_LAT_F",
        "O_Urban_Sharpshooter_F"
    ]
],

[
    "C_Soldier_VR_F",/*Purple VR unit (officers)*/
    [
        "O_officer_F",
        "O_Officer_Parade_F",
        "O_Officer_Parade_Veteran_F",
        "O_Story_CEO_F",
        "O_Story_Colonel_F",
        "O_A_soldier_F",
        "O_A_soldier_TL_F"
    ]
],

/*Divers*/
["B_diver_F",       "O_diver_F"],
["B_diver_exp_F",   "O_diver_exp_F"],
["B_diver_TL_F",    "O_diver_TL_F"],

//========================================================================================================
/*  ==== VEHICLES ====     */

[
    "Land_VR_Target_MRAP_01_F",/*Small VR vehicle*/
    [
        ["O_MRAP_02_F",     [/*crew:*/["O_Soldier_F"]]],
        ["O_MRAP_02_gmg_F", [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_MRAP_02_hmg_F", [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_LSV_02_AT_F",   [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_LSV_02_armed_F",[/*crew:*/[2,"O_Soldier_F"]]],
        ["O_LSV_02_unarmed_F",[/*crew:*/["O_Soldier_F"]]],
        ["O_Quadbike_01_F", [/*crew:*/[]]],
        ["O_UGV_01_rcws_F", [/*crew:*/[2,"B_UAV_AI"]]]
    ]
],

[
    "Land_VR_Target_APC_Wheeled_01_F",/*Medium VR vehicle*/
    [
        ["O_APC_Tracked_02_cannon_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Tracked_02_cannon_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Tracked_02_cannon_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Tracked_02_cannon_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showBags",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Wheeled_02_rcws_v2_F",  [/*crew:*/[2,"O_crew_F"],/*appearance:*/[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Wheeled_02_rcws_v2_F",  [/*crew:*/[2,"O_crew_F"],/*appearance:*/[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Wheeled_02_rcws_v2_F",  [/*crew:*/[2,"O_crew_F"],/*appearance:*/[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Wheeled_02_rcws_v2_F",  [/*crew:*/[2,"O_crew_F"],/*appearance:*/[["Hex",1],["showBags",0.5,"showCanisters",0.5,"showTools",0.5,"showCamonetHull",0.5,"showSLATHull",0.5]]]],
        ["O_Truck_03_device_F",         [/*crew:*/[]]],
        ["O_Truck_03_device_F",         [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_ammo_F",           [/*crew:*/[]]],
        ["O_Truck_03_ammo_F",           [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_fuel_F",           [/*crew:*/[]]],
        ["O_Truck_03_fuel_F",           [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_medical_F",        [/*crew:*/[]]],
        ["O_Truck_03_medical_F",        [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_repair_F",         [/*crew:*/[]]],
        ["O_Truck_03_repair_F",         [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_transport_F",      [/*crew:*/[]]],
        ["O_Truck_03_transport_F",      [/*crew:*/[2,"O_Soldier_F"]]],
        ["O_Truck_03_covered_F",        [/*crew:*/[]]],
        ["O_Truck_03_covered_F",        [/*crew:*/[2,"O_Soldier_F"]]],
        ["Land_Pod_Heli_Transport_04_medevac_F",[/*crew:*/[]]],
        ["Land_Pod_Heli_Transport_04_medevac_F",[/*crew:*/[]]],
        ["Land_Pod_Heli_Transport_04_covered_F",[/*crew:*/[]]],
        ["Land_Pod_Heli_Transport_04_covered_F",[/*crew:*/[]]]
    ]
],

[
    "Land_VR_Target_MBT_01_cannon_F",/*Large VR vehicle*/
    [
        ["O_APC_Tracked_02_AA_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["O_APC_Tracked_02_AA_F",   [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showTracks",0.5,"showCamonetHull",0.5,"showCamonetTurret",0.5,"showSLATHull",0.5]]]],
        ["O_MBT_02_arty_F",         [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showAmmobox",0.5,"showCanisters",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5,"showLog",0.5]]]],
        ["O_MBT_02_arty_F",         [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showAmmobox",0.5,"showCanisters",0.5,"showCamonetTurret",0.5,"showCamonetHull",0.5,"showLog",0.5]]]],
        ["O_MBT_02_cannon_F",       [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showLog",0.5]]]],
        ["O_MBT_02_railgun_F",      [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5,"showLog",0.5]]]],
        ["O_MBT_04_cannon_F",       [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5]]]],
        ["O_MBT_04_command_F",      [/*crew:*/[3,"O_crew_F"],/*appearance:*/[["Hex",1],["showCamonetHull",0.5,"showCamonetTurret",0.5]]]]
    ]
],

//========================================================================================================
/*  ==== HELICOPTERS ==== */
[
    "B_Heli_Transport_03_unarmed_F",/*Unarmed black huron*/
    [
        ["O_Heli_Transport_04_F",           [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_F",           [/*crew:*/[]]],
        ["O_Heli_Transport_04_ammo_F",      [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_ammo_F",      [/*crew:*/[]]],
        ["O_Heli_Transport_04_bench_F",     [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_bench_F",     [/*crew:*/[]]],
        ["O_Heli_Transport_04_box_F",       [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_box_F",       [/*crew:*/[]]],
        ["O_Heli_Transport_04_fuel_F",      [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_fuel_F",      [/*crew:*/[]]],
        ["O_Heli_Transport_04_medevac_F",   [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_medevac_F",   [/*crew:*/[]]],
        ["O_Heli_Transport_04_repair_F",    [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_repair_F",    [/*crew:*/[]]],
        ["O_Heli_Transport_04_covered_F",   [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Transport_04_covered_F",   [/*crew:*/[]]],
        ["O_Heli_Attack_02_dynamicLoadout_F",   [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Attack_02_dynamicLoadout_F",   [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Light_02_dynamicLoadout_F",    [/*crew:*/[2,"O_helipilot_F"]]],
        ["O_Heli_Light_02_dynamicLoadout_F",    [/*crew:*/[]]],
        ["O_Heli_Light_02_unarmed_F",           [/*crew:*/[2,"O_helipilot_F"],/*appearance:*/[["Opfor",1],[]]]],
        ["O_Heli_Light_02_unarmed_F",           [/*crew:*/[],/*appearance:*/[["Opfor",1],[]]]],
        ["O_Heli_Light_02_unarmed_F",           [/*crew:*/[2,"O_helipilot_F"],/*appearance:*/[["Opfor",1],[]]]],
        ["O_Heli_Light_02_unarmed_F",           [/*crew:*/[],/*appearance:*/[["Opfor",1],[]]]],
        ["O_T_VTOL_02_infantry_dynamicLoadout_F",[/*crew:*/[2,"O_helipilot_F"],/*appearance:*/[["Hex",1],[]]]],
        ["O_T_VTOL_02_infantry_dynamicLoadout_F",[/*crew:*/[],/*appearance:*/[["Hex",1],[]]]],
        ["O_T_VTOL_02_vehicle_dynamicLoadout_F",[/*crew:*/[2,"O_helipilot_F"],/*appearance:*/[["Hex",1],[]]]],
        ["O_T_VTOL_02_vehicle_dynamicLoadout_F",[/*crew:*/[],/*appearance:*/[["Hex",1],[]]]]
    ]
],

//========================================================================================================
/*  ==== BOATS ==== */
["B_Boat_Armed_01_minigun_F", "O_Boat_Armed_01_hmg_F"],
["B_Boat_Transport_01_F",     "O_Boat_Transport_01_F"],
/*  ==== SUBMARINES ==== */
["B_SDV_01_F", "O_SDV_01_F"],

//========================================================================================================
/*  ====   TURRETS    ====*/

[
    "B_HMG_01_high_F",/*Standing turret*/
    [
        "O_HMG_01_high_F",
        "O_GMG_01_high_F",
        "O_G_HMG_02_high_F"
    ]
],

[
    "B_HMG_01_F",/*Crouch turret*/
    [
        "O_HMG_01_F",
        "O_GMG_01_F",
        "O_G_HMG_02_F",
        ["O_HMG_01_A_F",["B_UAV_AI"]],
        ["O_GMG_01_A_F",["B_UAV_AI"]]
    ]
],

[
    "B_static_AA_F",/*Launcher turret*/
    [
        "O_static_AA_F",
        "O_static_AT_F",
        "O_Mortar_01_F",
        "O_Mortar_01_F"
    ]
],

[
    "B_Mortar_01_F",/*Mortar*/
    "O_Mortar_01_F"
],

//========================================================================================================
/*  ==== OBJECTS    ====*/

/*Loot boxes*/
[
    "Land_VR_Shape_01_cube_1m_F",/*VR cube (boxes)*/
    [
        /*Loot crates*/
        ["Box_East_Wps_F",      /*payload:*/2],
        ["Box_East_Wps_F",      /*payload:*/2],
        ["Box_East_Wps_F",      /*payload:*/2],
        ["Box_East_Ammo_F",     /*payload:*/2],
        ["Box_East_AmmoOrd_F",  /*payload:*/2],
        ["Box_East_Grenades_F", /*payload:*/2],
        ["Box_East_Support_F",  /*payload:*/2],
        /*Props*/
        ["Land_MetalBarrel_F",      /*payload:*/0],
        ["FlexibleTank_01_forest_F",/*payload:*/0],
        ["TrashBagHolder_01_F",     /*payload:*/0],
        ["Land_PaperBox_01_small_closed_brown_F",/*payload:*/0]
    ]
],

/*Nets*/
["CamoNet_BLUFOR_F",        "CamoNet_OPFOR_F"],
["CamoNet_BLUFOR_open_F",   "CamoNet_OPFOR_open_F"],
["CamoNet_BLUFOR_big_F",    "CamoNet_OPFOR_big_F"],

/*Tents*/
["Land_ConnectorTent_01_NATO_open_F",   "Land_ConnectorTent_01_CSAT_brownhex_open_F"],
["Land_ConnectorTent_01_NATO_cross_F",  "Land_ConnectorTent_01_CSAT_brownhex_cross_F"],
["Land_ConnectorTent_01_NATO_closed_F", "Land_ConnectorTent_01_CSAT_brownhex_closed_F"],
[
    "Land_MedicalTent_01_NATO_generic_inner_F",
    [
        ["Land_DeconTent_01_CSAT_brownhex_F",                /*payload:*/1],
        ["Land_MedicalTent_01_CSAT_brownhex_generic_inner_F",/*payload:*/1],
        ["Land_MedicalTent_01_CSAT_brownhex_generic_open_F", /*payload:*/1],
        ["Land_MedicalTent_01_CSAT_brownhex_generic_outer_F",/*payload:*/1]
    ]
],
/*Military buildings*/
["Land_Cargo_House_V3_F",   "Land_Cargo_House_V1_F"],
["Land_Cargo_HQ_V3_F",      "Land_Cargo_HQ_V1_F"],
["CargoPlaftorm_01_brown_F","CargoPlaftorm_01_green_F"],
["Land_Cargo_Patrol_V3_F",  "Land_Cargo_Patrol_V1_F"],
["Land_Cargo_Tower_V3_F",   "Land_Cargo_Tower_V1_F"],

/*Faction-specific supply crates*/
["Box_NATO_WpsLaunch_F",    "Box_East_WpsLaunch_F"],
["Box_NATO_WpsSpecial_F",   "Box_East_WpsSpecial_F"],
["Box_NATO_Uniforms_F",     "Box_CSAT_Uniforms_F"],
["Box_NATO_Equip_F",        "Box_CSAT_Equip_F"],
["B_CargoNet_01_ammo_F",    "O_CargoNet_01_ammo_F"],
["B_supplyCrate_F",         "O_supplyCrate_F"],
["Box_NATO_AmmoVeh_F",      "Box_East_AmmoVeh_F"],

/*Flags*/
["Banner_01_NATO_F","Banner_01_CSAT_F"],
["Flag_NATO_F",     "Flag_CSAT_F"],

/*Underwater equipment*/
["Item_U_B_Wetsuit",    "Item_U_O_Wetsuit"],
["Vest_V_RebreatherB",  "Vest_V_RebreatherIR"],

/*Electronics (dynamic)*/
["Item_Laserdesignator","Item_Laserdesignator_02"],
["Item_NVGoggles",      ["Item_O_NVGoggles_hex_F","Item_O_NVGoggles_urb_F"]],
["Item_B_UavTerminal",  "Item_O_UavTerminal"],

/*Electronics (static)*/
["Land_PortableSolarPanel_01_sand_F",       "Land_PortableSolarPanel_01_olive_F"],
["Land_PortableSolarPanel_01_folded_sand_F","Land_PortableSolarPanel_01_folded_olive_F"],
["SatelliteAntenna_01_Mounted_Sand_F",      "SatelliteAntenna_01_Mounted_Black_F"],
["SatelliteAntenna_01_Small_Mounted_Sand_F","SatelliteAntenna_01_Small_Mounted_Black_F"],
["OmniDirectionalAntenna_01_sand_F",        "OmniDirectionalAntenna_01_black_F"],
["Land_PortableWeatherStation_01_sand_F",   "Land_PortableWeatherStation_01_olive_F"],
["Land_BatteryPack_01_battery_sand_F",      "Land_BatteryPack_01_battery_black_F"],
["Land_BatteryPack_01_closed_sand_F",       "Land_BatteryPack_01_closed_black_F"],
["Land_BatteryPack_01_open_sand_F",         "Land_BatteryPack_01_open_black_F"],
["Land_Computer_01_sand_F",                 "Land_Computer_01_black_F"],
["Land_TripodScreen_01_dual_v1_sand_F",     "Land_TripodScreen_01_dual_v1_black_F"],
["Land_TripodScreen_01_dual_v2_sand_F",     "Land_TripodScreen_01_dual_v2_black_F"],
["Land_IPPhone_01_sand_F",                  "Land_IPPhone_01_black_F"],
["Land_laptop_03_closed_sand_F",            "Land_laptop_03_closed_black_F"],
["Land_Laptop_03_sand_F",                   "Land_Laptop_03_black_F"],
["Land_TripodScreen_01_large_sand_F",       "Land_TripodScreen_01_large_black_F"],
["Land_MultiScreenComputer_01_sand_F",      "Land_MultiScreenComputer_01_black_F"],
["Land_MultiScreenComputer_01_closed_sand_F","Land_MultiScreenComputer_01_closed_black_F"],
["Land_PortableGenerator_01_sand_F",        "Land_PortableGenerator_01_black_F"],
["Land_PortableServer_01_sand_F",           "Land_PortableServer_01_black_F"],
["Land_PortableServer_01_cover_sand_F",     "Land_PortableServer_01_cover_black_F"],
["Land_Router_01_sand_F",                   "Land_Router_01_black_F"],
["Land_SolarPanel_04_sand_F",               "Land_SolarPanel_04_black_F"],
["Land_Tablet_02_sand_F",                   "Land_Tablet_02_black_F"],
["SatelliteAntenna_01_Sand_F",              "SatelliteAntenna_01_Black_F"],
["SatelliteAntenna_01_Small_Sand_F",        "SatelliteAntenna_01_Small_Black_F"],
["Land_PortableLight_02_double_sand_F",     "Land_PortableLight_02_double_black_F"],
["Land_PortableLight_02_folded_sand_F",     "Land_PortableLight_02_folded_black_F"],
["Land_PortableLight_02_quad_sand_F",       "Land_PortableLight_02_quad_black_F"],
["Land_PortableLight_02_single_sand_F",     "Land_PortableLight_02_single_black_F"],
["Land_PortableLight_02_single_folded_sand_F","Land_PortableLight_02_single_folded_black_F"],
["WaterPump_01_sand_F",                     "WaterPump_01_forest_F"],

/*Military*/
["Land_BattlefieldCross_01_NATO_F", "Land_BattlefieldCross_01_CSAT_F"],
["FoldedFlag_01_US_F",              "FoldedFlag_01_Altis_F"],
["Land_DeskChair_01_sand_F",        "Land_DeskChair_01_black_F"],
["Land_PortableCabinet_01_4drawers_sand_F", "Land_PortableCabinet_01_4drawers_black_F"],
["Land_PortableCabinet_01_7drawers_sand_F", "Land_PortableCabinet_01_7drawers_black_F"],
["Land_PortableCabinet_01_bookcase_sand_F", "Land_PortableCabinet_01_bookcase_black_F"],
["Land_PortableCabinet_01_closed_sand_F",   "Land_PortableCabinet_01_closed_black_F"],
["Land_PortableCabinet_01_lid_sand_F",      "Land_PortableCabinet_01_lid_black_F"],
["Land_PortableDesk_01_sand_F",             "Land_PortableDesk_01_black_F"],
["Land_PortableDesk_01_panel_sand_F",       "Land_PortableDesk_01_panel_black_F"],

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