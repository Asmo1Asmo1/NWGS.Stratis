//Gets NWGS LOOT_VEHC_TYPE (see SCRIPTS\globalDefines.h)
//note: should be applied to vehicles only
//params: _veh - vehicle to get type of (string for classname or object)
//returns: string - NWGS LOOT_VEHC_TYPE (LOOT_VEHC_TYPE_AAIR|LOOT_VEHC_TYPE_APCS|LOOT_VEHC_TYPE_ARTY|LOOT_VEHC_TYPE_BOAT|LOOT_VEHC_TYPE_CARS|LOOT_VEHC_TYPE_DRON|LOOT_VEHC_TYPE_HELI|LOOT_VEHC_TYPE_PLAN|LOOT_VEHC_TYPE_SUBM|LOOT_VEHC_TYPE_TANK)
NWG_fnc_vcatGetVehcType = {
    _this call NWG_VCAT_GetVehcType
};

//Returns base vehicle classname (if applicable) - vehicle without specializations for which input is a variation (inheritor) of
//note: this function is a rework of BIS_fnc_baseVehicle
//params: _classname - classname of vehicle to process
//returns: string - classname of base vehicle or input itself if not a vehicle or is already a base
NWG_fnc_vcatGetBaseVehicle = {
    _this call NWG_VCAT_GetBaseVehicle
};