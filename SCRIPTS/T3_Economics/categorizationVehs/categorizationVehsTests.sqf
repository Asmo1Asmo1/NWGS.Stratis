#include "..\..\globalDefines.h"

//================================================================================================================
//Vehicles editor category
NWG_VCAT_testClassnames = [
"B_Plane_CAS_01_dynamicLoadout_F",
"B_Heli_Light_01_dynamicLoadout_F",
"B_Heli_Attack_01_dynamicLoadout_F",
"B_APC_Wheeled_01_cannon_F",
"B_T_APC_Wheeled_01_cannon_F",
"B_G_Boat_Transport_01_F",
"B_Boat_Transport_01_F",
"B_T_Boat_Transport_01_F",
"B_Heli_Transport_03_F",
"B_Heli_Transport_03_unarmed_F",
"B_APC_Tracked_01_CRV_F",
"B_T_APC_Tracked_01_CRV_F",
"B_Plane_Fighter_01_F",
"B_Plane_Fighter_01_Stealth_F",
"B_G_Van_01_fuel_F",
"B_Truck_01_mover_F",
"B_Truck_01_ammo_F",
"B_Truck_01_box_F",
"B_Truck_01_cargo_F",
"B_Truck_01_flatbed_F",
"B_Truck_01_fuel_F",
"B_Truck_01_medical_F",
"B_Truck_01_Repair_F",
"B_Truck_01_transport_F",
"B_Truck_01_covered_F",
"B_MRAP_01_F",
"B_MRAP_01_gmg_F",
"B_MRAP_01_hmg_F",
"B_APC_Tracked_01_AA_F",
"B_T_APC_Tracked_01_AA_F",
"B_APC_Tracked_01_rcws_F",
"B_T_APC_Tracked_01_rcws_F",
"B_MBT_01_cannon_F",
"B_T_MBT_01_cannon_F",
"B_MBT_01_TUSK_F",
"B_T_MBT_01_TUSK_F",
"B_MBT_01_arty_F",
"B_T_MBT_01_arty_F",
"B_MBT_01_mlrs_F",
"B_T_MBT_01_mlrs_F",
"B_Heli_Light_01_F",
"B_G_Offroad_01_F",
"B_GEN_Offroad_01_gen_F",
"B_G_Offroad_01_AT_F",
"B_GEN_Offroad_01_comms_F",
"B_GEN_Offroad_01_covered_F",
"B_G_Offroad_01_armed_F",
"B_G_Offroad_01_repair_F",
"B_LSV_01_AT_F",
"B_LSV_01_armed_F",
"B_CTRG_LSV_01_light_F",
"B_LSV_01_unarmed_F",
"B_G_Quadbike_01_F",
"B_Quadbike_01_F",
"B_Lifeboat",
"B_T_Lifeboat",
"B_AFV_Wheeled_01_cannon_F",
"B_T_AFV_Wheeled_01_cannon_F",
"B_AFV_Wheeled_01_up_cannon_F",
"B_T_AFV_Wheeled_01_up_cannon_F",
"B_SDV_01_F",
"B_Boat_Armed_01_minigun_F",
"B_T_Boat_Armed_01_minigun_F",
"B_G_Van_01_transport_F",
"B_UGV_01_F",
"B_UGV_01_rcws_F",
"B_Heli_Transport_01_F",
"B_CTRG_Heli_Transport_01_sand_F",
"B_CTRG_Heli_Transport_01_tropic_F",
"B_T_VTOL_01_armed_F",
"B_T_VTOL_01_infantry_F",
"B_T_VTOL_01_vehicle_F",
"B_G_Van_02_vehicle_F",
"B_GEN_Van_02_vehicle_F",
"B_G_Van_02_transport_F",
"B_GEN_Van_02_transport_F"
];

// call NWG_VCAT_GetEditorCategories
NWG_VCAT_GetEditorCategories = {
	private _result = [];
	//forEach classname
	private _cfg = configNull;
	{
		_cfg = configFile >> "CfgVehicles" >> _x;
		_result pushBack [
			(getText(_cfg >> "editorCategory")),
			(getText(_cfg >> "editorSubCategory")),
			_x
		];
	} forEach NWG_VCAT_testClassnames;

	_result sort true;
	_result call NWG_fnc_testDumpToRptAndClipboard;
	_result
};

/*
["","EdSubcat_AAs","B_APC_Tracked_01_AA_F"]
["","EdSubcat_AAs","B_T_APC_Tracked_01_AA_F"]
["","EdSubcat_APCs","B_AFV_Wheeled_01_cannon_F"]
["","EdSubcat_APCs","B_AFV_Wheeled_01_up_cannon_F"]
["","EdSubcat_APCs","B_APC_Tracked_01_CRV_F"]
["","EdSubcat_APCs","B_APC_Tracked_01_rcws_F"]
["","EdSubcat_APCs","B_APC_Wheeled_01_cannon_F"]
["","EdSubcat_APCs","B_T_AFV_Wheeled_01_cannon_F"]
["","EdSubcat_APCs","B_T_AFV_Wheeled_01_up_cannon_F"]
["","EdSubcat_APCs","B_T_APC_Tracked_01_CRV_F"]
["","EdSubcat_APCs","B_T_APC_Tracked_01_rcws_F"]
["","EdSubcat_APCs","B_T_APC_Wheeled_01_cannon_F"]
["","EdSubcat_Artillery","B_MBT_01_arty_F"]
["","EdSubcat_Artillery","B_MBT_01_mlrs_F"]
["","EdSubcat_Artillery","B_T_MBT_01_arty_F"]
["","EdSubcat_Artillery","B_T_MBT_01_mlrs_F"]
["","EdSubcat_Boats","B_Boat_Armed_01_minigun_F"]
["","EdSubcat_Boats","B_Boat_Transport_01_F"]
["","EdSubcat_Boats","B_G_Boat_Transport_01_F"]
["","EdSubcat_Boats","B_Lifeboat"]
["","EdSubcat_Boats","B_T_Boat_Armed_01_minigun_F"]
["","EdSubcat_Boats","B_T_Boat_Transport_01_F"]
["","EdSubcat_Boats","B_T_Lifeboat"]
["","EdSubcat_Cars","B_CTRG_LSV_01_light_F"]
["","EdSubcat_Cars","B_G_Offroad_01_armed_F"]
["","EdSubcat_Cars","B_G_Offroad_01_AT_F"]
["","EdSubcat_Cars","B_G_Offroad_01_F"]
["","EdSubcat_Cars","B_G_Offroad_01_repair_F"]
["","EdSubcat_Cars","B_G_Quadbike_01_F"]
["","EdSubcat_Cars","B_G_Van_01_fuel_F"]
["","EdSubcat_Cars","B_G_Van_01_transport_F"]
["","EdSubcat_Cars","B_G_Van_02_transport_F"]
["","EdSubcat_Cars","B_G_Van_02_vehicle_F"]
["","EdSubcat_Cars","B_GEN_Offroad_01_comms_F"]
["","EdSubcat_Cars","B_GEN_Offroad_01_covered_F"]
["","EdSubcat_Cars","B_GEN_Offroad_01_gen_F"]
["","EdSubcat_Cars","B_GEN_Van_02_transport_F"]
["","EdSubcat_Cars","B_GEN_Van_02_vehicle_F"]
["","EdSubcat_Cars","B_LSV_01_armed_F"]
["","EdSubcat_Cars","B_LSV_01_AT_F"]
["","EdSubcat_Cars","B_LSV_01_unarmed_F"]
["","EdSubcat_Cars","B_MRAP_01_F"]
["","EdSubcat_Cars","B_MRAP_01_gmg_F"]
["","EdSubcat_Cars","B_MRAP_01_hmg_F"]
["","EdSubcat_Cars","B_Quadbike_01_F"]
["","EdSubcat_Cars","B_Truck_01_ammo_F"]
["","EdSubcat_Cars","B_Truck_01_box_F"]
["","EdSubcat_Cars","B_Truck_01_cargo_F"]
["","EdSubcat_Cars","B_Truck_01_covered_F"]
["","EdSubcat_Cars","B_Truck_01_flatbed_F"]
["","EdSubcat_Cars","B_Truck_01_fuel_F"]
["","EdSubcat_Cars","B_Truck_01_medical_F"]
["","EdSubcat_Cars","B_Truck_01_mover_F"]
["","EdSubcat_Cars","B_Truck_01_Repair_F"]
["","EdSubcat_Cars","B_Truck_01_transport_F"]
["","EdSubcat_Drones","B_UGV_01_F"]
["","EdSubcat_Drones","B_UGV_01_rcws_F"]
["","EdSubcat_Helicopters","B_CTRG_Heli_Transport_01_sand_F"]
["","EdSubcat_Helicopters","B_CTRG_Heli_Transport_01_tropic_F"]
["","EdSubcat_Helicopters","B_Heli_Attack_01_dynamicLoadout_F"]
["","EdSubcat_Helicopters","B_Heli_Light_01_dynamicLoadout_F"]
["","EdSubcat_Helicopters","B_Heli_Light_01_F"]
["","EdSubcat_Helicopters","B_Heli_Transport_01_F"]
["","EdSubcat_Helicopters","B_Heli_Transport_03_F"]
["","EdSubcat_Helicopters","B_Heli_Transport_03_unarmed_F"]
["","EdSubcat_Planes","B_Plane_CAS_01_dynamicLoadout_F"]
["","EdSubcat_Planes","B_Plane_Fighter_01_F"]
["","EdSubcat_Planes","B_Plane_Fighter_01_Stealth_F"]
["","EdSubcat_Planes","B_T_VTOL_01_armed_F"]
["","EdSubcat_Planes","B_T_VTOL_01_infantry_F"]
["","EdSubcat_Planes","B_T_VTOL_01_vehicle_F"]
["","EdSubcat_Submersibles","B_SDV_01_F"]
["","EdSubcat_Tanks","B_MBT_01_cannon_F"]
["","EdSubcat_Tanks","B_MBT_01_TUSK_F"]
["","EdSubcat_Tanks","B_T_MBT_01_cannon_F"]
["","EdSubcat_Tanks","B_T_MBT_01_TUSK_F"]
*/