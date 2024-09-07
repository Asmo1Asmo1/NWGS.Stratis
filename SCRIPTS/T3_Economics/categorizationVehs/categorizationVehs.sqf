#include "..\..\globalDefines.h"

//Cache (with known exceptions)
NWG_VCAT_vehTypeCache = createHashMapFromArray [
    ["B_AFV_Wheeled_01_cannon_F",LOOT_VEHC_TYPE_TANK],//Rhino is definetly too powerful for APCs
    ["B_AFV_Wheeled_01_up_cannon_F",LOOT_VEHC_TYPE_TANK]//Rhino is definetly too powerful for APCs
];

//Get vehicle type
NWG_VCAT_GetVehcType = {
    private _veh = _this;
    if (_veh isEqualType objNull) then {_veh = typeOf _veh};

    //Check cache
    private _cached = NWG_VCAT_vehTypeCache get _veh;
    if (!isNil "_cached") exitWith {_cached};

    //We will use the editor categories to determine the vehicle type
    private _vehcType = switch (getText (configFile >> "CfgVehicles" >> _veh >> "editorSubCategory")) do {
        case "EdSubcat_AAs":          {LOOT_VEHC_TYPE_AAIR};
        case "EdSubcat_APCs":         {LOOT_VEHC_TYPE_APCS};
        case "EdSubcat_Artillery":    {LOOT_VEHC_TYPE_ARTY};
        case "EdSubcat_Boats":        {LOOT_VEHC_TYPE_BOAT};
        case "EdSubcat_Cars":         {LOOT_VEHC_TYPE_CARS};
        case "EdSubcat_Drones":       {LOOT_VEHC_TYPE_DRON};
        case "EdSubcat_Helicopters":  {LOOT_VEHC_TYPE_HELI};
        case "EdSubcat_Planes":       {LOOT_VEHC_TYPE_PLAN};
        case "EdSubcat_Submersibles": {LOOT_VEHC_TYPE_SUBM};
        case "EdSubcat_Tanks":        {LOOT_VEHC_TYPE_TANK};
        default {
            (format ["NWG_VCAT_GetVehcType: Unknown vehicle type: '%1' with subcat: '%2'",
                _veh, getText (configFile >> "CfgVehicles" >> _veh >> "editorSubCategory")]) call NWG_fnc_error;
            LOOT_VEHC_TYPE_CARS//Default to cars
        };
    };

    //Cache and return
    NWG_VCAT_vehTypeCache set [_veh,_vehcType];
    _vehcType
};