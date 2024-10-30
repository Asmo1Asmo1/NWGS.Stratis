//Object types (objects on map, used in 'ukrep' subsystem for example)
#define OBJ_TYPE_BLDG  "BLDG"  // Building
#define OBJ_TYPE_FURN  "FURN"  // Furniture
#define OBJ_TYPE_DECO  "DECO"  // Decorative
#define OBJ_TYPE_UNIT  "UNIT"  // Unit
#define OBJ_TYPE_VEHC  "VEHC"  // Vehicle
#define OBJ_TYPE_TRRT  "TRRT"  // Turret
#define OBJ_TYPE_MINE  "MINE"  // Mine

//Loot items types
#define LOOT_ITEM_TYPE_CLTH "CLTH"  // Clothing
#define LOOT_ITEM_TYPE_WEAP "WEAP"  // Weapon
#define LOOT_ITEM_TYPE_ITEM "ITEM"  // Item
#define LOOT_ITEM_TYPE_AMMO "AMMO"  // Ammo

//Loot items categories
#define LOOT_ITEM_CAT_CLTH 0
#define LOOT_ITEM_CAT_WEAP 1
#define LOOT_ITEM_CAT_ITEM 2
#define LOOT_ITEM_CAT_AMMO 3

//Default items chart
#define LOOT_ITEM_DEFAULT_CHART [[],[],[],[]]

//Loot vehicles types
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

//Loot vehicles categories
#define LOOT_VEHC_CAT_AAIR 0
#define LOOT_VEHC_CAT_APCS 1
#define LOOT_VEHC_CAT_ARTY 2
#define LOOT_VEHC_CAT_BOAT 3
#define LOOT_VEHC_CAT_CARS 4
#define LOOT_VEHC_CAT_DRON 5
#define LOOT_VEHC_CAT_HELI 6
#define LOOT_VEHC_CAT_PLAN 7
#define LOOT_VEHC_CAT_SUBM 8
#define LOOT_VEHC_CAT_TANK 9

//Default vehicles chart
#define LOOT_VEHC_DEFAULT_CHART [[],[],[],[],[],[],[],[],[],[]]

//Server events (arguments for NWG_fnc_subscribeToServerEvent and NWG_fnc_raiseServerEvent)
#define EVENT_ON_OBJECT_KILLED "OnObjectKilled" //Called by 'undertaker' subsystem when an object is killed.                params ["_obj","_objType","_actualKiller","_isPlayerKiller"];
#define EVENT_ON_DSPAWN_GROUP_SPAWNED "OnDynamicSpawnGroupSpawned" //Called by 'dspawn' subsystem when a group is spawned.  params ["_group","_vehicle","_units","_tags","_tier"];
#define EVENT_ON_UKREP_OBJECT_DECORATED "OnUkrepObjectDecorated" //Called by 'ukrep' subsystem when composition is placed around object.     params ["_obj","_objType","_ukrepResult"]; _ukrepResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
#define EVENT_ON_MISSION_STATE_CHANGED "OnMissionStateChanged" //Called by 'missionMachine' subsystem when mission state is changed.     params ["_oldState","_newState"];

//Client events (arguments for NWG_fnc_subscribeToClientEvent and NWG_fnc_raiseClientEvent)
#define EVENT_ON_LOADOUT_CHANGED "OnLoadoutChanged" //Called by 'inventoryManager' subsystem when a loadout is changed.     params ["_loadOut","_flattenLoadOut"];

//Mission states
/* initialization */
#define MSTATE_SCRIPTS_COMPILATION -3
#define MSTATE_DISABLED -2
#define MSTATE_MACHINE_STARTUP -1
/* world build */
#define MSTATE_WORLD_BUILD 0
/* base build */
#define MSTATE_BASE_UKREP 1
#define MSTATE_BASE_ECONOMY 2
#define MSTATE_BASE_QUESTS 3
/* missions list */
#define MSTATE_LIST_INIT 4
#define MSTATE_LIST_UPDATE 5
/* player input expect */
#define MSTATE_READY 6
/* mission build */
#define MSTATE_BUILD_UKREP 7
#define MSTATE_BUILD_ECONOMY 8
#define MSTATE_BUILD_DSPAWN 9
#define MSTATE_BUILD_QUESTS 10
/* mission playflow */
#define MSTATE_FIGHT_SETUP 11
#define MSTATE_FIGHT_READY 12
#define MSTATE_FIGHT_INFILTRATION 13
#define MSTATE_FIGHT_ACTIVE 14
#define MSTATE_FIGHT_EXHAUSTED 15
/* mission end */
#define MSTATE_COMPLETED 16
#define MSTATE_CLEANUP 17
#define MSTATE_RESET 18
#define MSTATE_SERVER_RESTART 19
/* escape phase */
#define MSTATE_ESCAPE_SETUP 20
#define MSTATE_ESCAPE_ACTIVE 21
#define MSTATE_ESCAPE_COMPLETED 22