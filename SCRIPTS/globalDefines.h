//Map object types
#define OBJ_TYPE_BLDG  "BLDG"  // Building
#define OBJ_TYPE_FURN  "FURN"  // Furniture
#define OBJ_TYPE_DECO  "DECO"  // Decorative
#define OBJ_TYPE_UNIT  "UNIT"  // Unit
#define OBJ_TYPE_VEHC  "VEHC"  // Vehicle
#define OBJ_TYPE_TRRT  "TRRT"  // Turret
#define OBJ_TYPE_MINE  "MINE"  // Mine

//Server events (arguments for NWG_fnc_subscribeToServerEvent and NWG_fnc_raiseServerEvent)
#define EVENT_ON_OBJECT_KILLED "OnObjectKilled" //Called by 'undertaker' subsystem when an object is killed.                params ["_obj","_objType","_actualKiller","_isPlayerKiller"];
#define EVENT_ON_DSPAWN_GROUP_SPAWNED "OnDynamicSpawnGroupSpawned" //Called by 'dspawn' subsystem when a group is spawned.  params ["_group","_vehicle","_units","_tags","_tier"];
#define EVENT_ON_UKREP_OBJECT_DECORATED "OnUkrepObjectDecorated" //Called by 'ukrep' subsystem when composition is placed around object.     params ["_obj","_objType","_ukrepResult"]; _ukrepResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
#define EVENT_ON_MISSION_STATE_CHANGED "OnMissionStateChanged" //Called by 'mission' subsystem when mission state is changed.     params ["_oldState","_newState"];

//Client events (arguments for NWG_fnc_subscribeToClientEvent and NWG_fnc_raiseClientEvent)
#define EVENT_ON_LOADOUT_CHANGED "OnLoadoutChanged" //Called by 'inventoryManager' subsystem when a loadout is changed.     params ["_loadOut","_flattenLoadOut"];

//Battlefield states (arguments for NWG_fnc_shGetState and NWG_fnc_shSetState)
#define BST_OCCUPIED_BUILDINGS "OccupiedBuildings"
#define BST_ENEMY_FACTION "EnemyFaction"
#define BST_TRIGGER "Trigger"
#define BST_REINFMAP "ReinfMap"

//Mission stages
/* initialization */
#define MSTATE_SCRIPTS_COMPILATION -3
#define MSTATE_DISABLED -2
#define MSTATE_MACHINE_STARTUP -1
/* world build */
#define MSTATE_BASE_INIT 0
/* missions list */
#define MSTATE_LIST_INIT 1
/* player input expect */
#define MSTATE_READY 2
/* mission build */
#define MSTATE_BUILD_UKREP 3
#define MSTATE_BUILD_DSPAWN 4
#define MSTATE_BUILD_ECONOMY 5
#define MSTATE_BUILD_QUESTS 6
/* mission playflow */
#define MSTATE_FIGHT_READY 7
#define MSTATE_FIGHT_INFILTRATION 8
#define MSTATE_FIGHT_ACTIVE 9
#define MSTATE_FIGHT_OUT 10
#define MSTATE_FIGHT_EXHAUSTED 11
#define MSTATE_FIGHT_ABANDONED 12
/* mission end */
#define MSTATE_CLEANUP 13
#define MSTATE_RESET 14
#define MSTATE_SERVER_RESTART 15