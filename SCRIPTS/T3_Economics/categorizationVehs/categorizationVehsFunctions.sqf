//Gets NWGS LOOT_VEHC_TYPE (see SCRIPTS\globalDefines.h)
//note: should be applied to vehicles only
//params: _veh - vehicle to get type of (string for classname or object)
//returns: string - NWGS LOOT_VEHC_TYPE (LOOT_VEHC_TYPE_AAIR|LOOT_VEHC_TYPE_APCS|LOOT_VEHC_TYPE_ARTY|LOOT_VEHC_TYPE_BOAT|LOOT_VEHC_TYPE_CARS|LOOT_VEHC_TYPE_DRON|LOOT_VEHC_TYPE_HELI|LOOT_VEHC_TYPE_PLAN|LOOT_VEHC_TYPE_SUBM|LOOT_VEHC_TYPE_TANK)
NWG_fnc_vcatGetVehcType = {
    _this call NWG_VCAT_GetVehcType
};

//Returns unified classname for the vehicle
//unified classname: Base classname of the vehicle for BLUFOR side (so OPFOR quad bike will return B_Quadbike_01_F)
//params: _classname - classname of vehicle to process
//returns: string - unified classname or input itself if already unified or could not be unified
NWG_fnc_vcatGetUnifiedClassname = {
    _this call NWG_VCAT_GetUnifiedClassname
};