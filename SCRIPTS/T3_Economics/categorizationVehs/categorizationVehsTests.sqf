#include "..\..\globalDefines.h"

//================================================================================================================
//Test cases
NWG_VCAT_testCases = [
["B_MBT_01_cannon_F",LOOT_VEHC_TYPE_TANK],
["B_Plane_CAS_01_dynamicLoadout_F",LOOT_VEHC_TYPE_PLAN],
["B_Heli_Light_01_dynamicLoadout_F",LOOT_VEHC_TYPE_HELI],
["B_Heli_Attack_01_dynamicLoadout_F",LOOT_VEHC_TYPE_HELI],
["B_APC_Wheeled_01_cannon_F",LOOT_VEHC_TYPE_APCS],
["B_Boat_Transport_01_F",LOOT_VEHC_TYPE_BOAT],
["B_Heli_Transport_03_F",LOOT_VEHC_TYPE_HELI],
["B_APC_Tracked_01_CRV_F",LOOT_VEHC_TYPE_APCS],
["B_Plane_Fighter_01_F",LOOT_VEHC_TYPE_PLAN],
["B_Truck_01_mover_F",LOOT_VEHC_TYPE_CARS],
["B_MRAP_01_F",LOOT_VEHC_TYPE_CARS],
["B_APC_Tracked_01_AA_F",LOOT_VEHC_TYPE_AAIR],
["B_APC_Tracked_01_rcws_F",LOOT_VEHC_TYPE_APCS],
["B_MBT_01_arty_F",LOOT_VEHC_TYPE_ARTY],
["B_MBT_01_mlrs_F",LOOT_VEHC_TYPE_ARTY],
["B_Heli_Light_01_F",LOOT_VEHC_TYPE_HELI],
["B_LSV_01_AT_F",LOOT_VEHC_TYPE_CARS],
["B_Quadbike_01_F",LOOT_VEHC_TYPE_CARS],
["B_Lifeboat",LOOT_VEHC_TYPE_BOAT],
["B_AFV_Wheeled_01_cannon_F",LOOT_VEHC_TYPE_TANK],//Exception - Rhino is too powerful for APCs
["B_AFV_Wheeled_01_up_cannon_F",LOOT_VEHC_TYPE_TANK],//Exception - Rhino is too powerful for APCs
["B_SDV_01_F",LOOT_VEHC_TYPE_SUBM],
["B_Boat_Armed_01_minigun_F",LOOT_VEHC_TYPE_BOAT],
["B_UGV_01_F",LOOT_VEHC_TYPE_DRON],
["B_Heli_Transport_01_F",LOOT_VEHC_TYPE_HELI]
];

//================================================================================================================
//Vehicles editor categories
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
    } forEach (NWG_VCAT_testCases apply {_x#0});

    _result sort true;
    _result call NWG_fnc_testDumpToRptAndClipboard;
    _result
};

/*
["","EdSubcat_AAs","B_APC_Tracked_01_AA_F"]
["","EdSubcat_APCs","B_AFV_Wheeled_01_cannon_F"]
["","EdSubcat_APCs","B_AFV_Wheeled_01_up_cannon_F"]
["","EdSubcat_APCs","B_APC_Tracked_01_CRV_F"]
["","EdSubcat_APCs","B_APC_Tracked_01_rcws_F"]
["","EdSubcat_APCs","B_APC_Wheeled_01_cannon_F"]
["","EdSubcat_Artillery","B_MBT_01_arty_F"]
["","EdSubcat_Artillery","B_MBT_01_mlrs_F"]
["","EdSubcat_Boats","B_Boat_Armed_01_minigun_F"]
["","EdSubcat_Boats","B_Boat_Transport_01_F"]
["","EdSubcat_Boats","B_Lifeboat"]
["","EdSubcat_Cars","B_LSV_01_AT_F"]
["","EdSubcat_Cars","B_MRAP_01_F"]
["","EdSubcat_Cars","B_Quadbike_01_F"]
["","EdSubcat_Cars","B_Truck_01_mover_F"]
["","EdSubcat_Drones","B_UGV_01_F"]
["","EdSubcat_Helicopters","B_Heli_Attack_01_dynamicLoadout_F"]
["","EdSubcat_Helicopters","B_Heli_Light_01_dynamicLoadout_F"]
["","EdSubcat_Helicopters","B_Heli_Light_01_F"]
["","EdSubcat_Helicopters","B_Heli_Transport_01_F"]
["","EdSubcat_Helicopters","B_Heli_Transport_03_F"]
["","EdSubcat_Planes","B_Plane_CAS_01_dynamicLoadout_F"]
["","EdSubcat_Planes","B_Plane_Fighter_01_F"]
["","EdSubcat_Submersibles","B_SDV_01_F"]
["","EdSubcat_Tanks","B_MBT_01_cannon_F"]
*/

//================================================================================================================
//Vehicles loot type
// call NWG_VCAT_GetVehcType_Test
NWG_VCAT_GetVehcType_Test = {
    private _errors = [];
    {
        _x params ["_input","_expected"];
        private _actual = _input call NWG_VCAT_GetVehcType;
        if (_actual isNotEqualTo _expected) then {
            _errors pushBack format ["NWG_VCAT_GetVehcType_Test: Vehicle %1 has incorrect type. Expected %2, actual %3",_input,_expected,_actual];
        };
    } forEach NWG_VCAT_testCases;
    if (_errors isNotEqualTo []) exitWith {
        _errors call NWG_fnc_testDumpToRptAndClipboard;
        _errors
    };
    "All tests passed"
};