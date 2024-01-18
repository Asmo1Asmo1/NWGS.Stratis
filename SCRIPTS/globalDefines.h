//Map object types
#define OBJ_TYPE_BLDG  "BLDG"  // Building
#define OBJ_TYPE_FURN  "FURN"  // Furniture
#define OBJ_TYPE_DECO  "DECO"  // Decorative
#define OBJ_TYPE_UNIT  "UNIT"  // Unit
#define OBJ_TYPE_VEHC  "VEHC"  // Vehicle
#define OBJ_TYPE_TRRT  "TRRT"  // Turret
#define OBJ_TYPE_MINE  "MINE"  // Mine

//Server events (arguments for eventSystemFunctions)
#define EVENT_ON_OBJECT_KILLED "OnObjectKilled" //Called by 'undertaker' subsystem when an object is killed. params ["_obj","_objType","_actualKiller","_isPlayerKiller"];

//Battlefield states (arguments for NWG_fnc_shGetState and NWG_fnc_shSetState)
#define BST_OCCUPIED_BUILDINGS "OccupiedBuildings"
#define BST_ENEMY_FACTION "EnemyFaction"