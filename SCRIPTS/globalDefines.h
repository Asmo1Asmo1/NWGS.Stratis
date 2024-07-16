//Object types
#define OBJ_TYPE_BLDG  "BLDG"  // Building
#define OBJ_TYPE_FURN  "FURN"  // Furniture
#define OBJ_TYPE_DECO  "DECO"  // Decorative
#define OBJ_TYPE_UNIT  "UNIT"  // Unit
#define OBJ_TYPE_VEHC  "VEHC"  // Vehicle
#define OBJ_TYPE_TRRT  "TRRT"  // Turret
#define OBJ_TYPE_MINE  "MINE"  // Mine

//Items types
#define ITEM_TYPE_CLTH "CLTH" // Clothing
#define ITEM_TYPE_WEPN "WEPN"  // Weapon
#define ITEM_TYPE_ITEM "ITEM"  // Item
#define ITEM_TYPE_AMMO "AMMO"  // Ammo

//Server events (arguments for NWG_fnc_subscribeToServerEvent and NWG_fnc_raiseServerEvent)
#define EVENT_ON_OBJECT_KILLED "OnObjectKilled" //Called by 'undertaker' subsystem when an object is killed.                params ["_obj","_objType","_actualKiller","_isPlayerKiller"];
#define EVENT_ON_DSPAWN_GROUP_SPAWNED "OnDynamicSpawnGroupSpawned" //Called by 'dspawn' subsystem when a group is spawned.  params ["_group","_vehicle","_units","_tags","_tier"];
#define EVENT_ON_UKREP_OBJECT_DECORATED "OnUkrepObjectDecorated" //Called by 'ukrep' subsystem when composition is placed around object.     params ["_obj","_objType","_ukrepResult"]; _ukrepResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
#define EVENT_ON_MISSION_STATE_CHANGED "OnMissionStateChanged" //Called by 'missionMachine' subsystem when mission state is changed.     params ["_oldState","_newState"];

//Client events (arguments for NWG_fnc_subscribeToClientEvent and NWG_fnc_raiseClientEvent)
#define EVENT_ON_LOADOUT_CHANGED "OnLoadoutChanged" //Called by 'inventoryManager' subsystem when a loadout is changed.     params ["_loadOut","_flattenLoadOut"];