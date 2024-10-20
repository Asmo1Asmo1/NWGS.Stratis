#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
#define CACHED_CATEGORY 0
#define CACHED_INDEX 1
#define CHART_ITEMS 0
#define CHART_PRICES 1

#define LOOT_VEHC_TYPE_AAIR "AAIR"  // Anti-Air (EdSubcat_AAs)
#define LOOT_VEHC_TYPE_APCS "APCS"  // Armored Personnel Carriers (EdSubcat_APCs)
#define LOOT_VEHC_TYPE_ARTY "ARTY"  // Artillery (EdSubcat_Artillery)
#define LOOT_VEHC_TYPE_BOAT "BOAT"  // Boats (EdSubcat_Boats)
#define LOOT_VEHC_TYPE_CARS "CARS"  // Cars (EdSubcat_Cars)
#define LOOT_VEHC_TYPE_DRON "DRON"  // Drones (EdSubcat_Drones)
#define LOOT_VEHC_TYPE_HELI "HELI"  // Helicopters (EdSubcat_Helicopters)
#define LOOT_VEHC_TYPE_PLAN "PLAN"  // Planes (EdSubcat_Planes)
#define LOOT_VEHC_TYPE_SUBM "SUBM"  // Submersibles (EdSubcat_Submersibles)
#define LOOT_VEHC_TYPE_TANK "TANK"  // Tanks (EdSubcat_Tanks)

//================================================================================================================
//================================================================================================================
//Settings
NWG_VSHOP_SER_Settings = createHashMapFromArray [
    ["DEFAULT_PRICE_AAIR",50000],
    ["DEFAULT_PRICE_APCS",35000],
    ["DEFAULT_PRICE_ARTY",45000],
    ["DEFAULT_PRICE_BOAT",15000],
    ["DEFAULT_PRICE_CARS",5000],
    ["DEFAULT_PRICE_DRON",10000],
    ["DEFAULT_PRICE_HELI",40000],
    ["DEFAULT_PRICE_PLAN",60000],
    ["DEFAULT_PRICE_SUBM",30000],
    ["DEFAULT_PRICE_TANK",55000],

    //[activeFactor,passiveFactor,priceMin,priceMax]
    ["PRICE_AAIR_SETTINGS",[0.01,0.002,40000,80000]],
    ["PRICE_APCS_SETTINGS",[0.01,0.002,25000,50000]],
    ["PRICE_ARTY_SETTINGS",[0.01,0.002,35000,70000]],
    ["PRICE_BOAT_SETTINGS",[0.01,0.002,10000,25000]],
    ["PRICE_CARS_SETTINGS",[0.01,0.002,3000,10000]],
    ["PRICE_DRON_SETTINGS",[0.01,0.002,7000,20000]],
    ["PRICE_HELI_SETTINGS",[0.01,0.002,30000,60000]],
    ["PRICE_PLAN_SETTINGS",[0.01,0.002,45000,100000]],
    ["PRICE_SUBM_SETTINGS",[0.01,0.002,20000,50000]],
    ["PRICE_TANK_SETTINGS",[0.01,0.002,40000,90000]],

	//Items that are added to each shop interaction
	["SHOP_PERSISTENT_ITEMS",[
		[],/*AAIR*/
        [],/*APCS*/
        [],/*ARTY*/
        ["B_Boat_Transport_01_F","B_Boat_Armed_01_minigun_F"],/*BOAT*/
        ["B_G_Offroad_01_F","B_MRAP_01_F","B_LSV_01_unarmed_F","B_Quadbike_01_F"],/*CARS*/
        [],/*DRON*/
        ["B_Heli_Light_01_F"],/*HELI*/
        [],/*PLAN*/
        ["B_SDV_01_F"],/*SUBM*/
        []/*TANK*/
	]],
	["SHOP_CHECK_PERSISTENT_ITEMS",true],//Each interaction check validity of persistent items
	["SHOP_ADD_TO_DYNAMIC_ITEMS_CHANCE",1],//Chance that item will be added to dynamic items when bought from player
	["SHOP_REMOVE_FROM_DYNAMIC_ITEMS_CHANCE",0],//Chance that item will be removed from dynamic items when sold to player

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_VSHOP_SER_spawnPlatform = objNull;

//================================================================================================================
//================================================================================================================
//Setup spawn platform object
NWG_VSHOP_SER_SetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    NWG_VSHOP_SER_spawnPlatform = _this;
};