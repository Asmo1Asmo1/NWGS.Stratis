//Object types (objects on map, used in 'ukrep' subsystem for example)
#define OBJ_TYPE_BLDG  "BLDG"  // Building
#define OBJ_TYPE_FURN  "FURN"  // Furniture
#define OBJ_TYPE_DECO  "DECO"  // Decorative
#define OBJ_TYPE_UNIT  "UNIT"  // Unit
#define OBJ_TYPE_VEHC  "VEHC"  // Vehicle
#define OBJ_TYPE_TRRT  "TRRT"  // Turret
#define OBJ_TYPE_MINE  "MINE"  // Mine

#define OBJ_CAT_BLDG 0
#define OBJ_CAT_FURN 1
#define OBJ_CAT_DECO 2
#define OBJ_CAT_UNIT 3
#define OBJ_CAT_VEHC 4
#define OBJ_CAT_TRRT 5
#define OBJ_CAT_MINE 6

#define OBJ_DEFAULT_CHART [[],[],[],[],[],[],[]]

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

//Default wallet amount
#define WLT_DEFAULT_MONEY 20250

//Server events (arguments for NWG_fnc_subscribeToServerEvent and NWG_fnc_raiseServerEvent)
#define EVENT_ON_OBJECT_KILLED "OnObjectKilled" //Called by 'undertaker' subsystem when an object is killed.                params ["_obj","_objType","_actualKiller","_isPlayerKiller"];
#define EVENT_ON_DSPAWN_GROUP_SPAWNED "OnDynamicSpawnGroupSpawned" //Called by 'dspawn' subsystem when a group is spawned.  params ["_group","_vehicle","_units","_tags","_tier","_faction"];
#define EVENT_ON_UKREP_OBJECT_DECORATED "OnUkrepObjectDecorated" //Called by 'ukrep' subsystem when composition is placed around object.     params ["_obj","_objType","_ukrepResult"]; _ukrepResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
#define EVENT_ON_MISSION_STATE_CHANGED "OnMissionStateChanged" //Called by 'missionMachine' subsystem when mission state is changed.     params ["_oldState","_newState"];

//Client events (arguments for NWG_fnc_subscribeToClientEvent and NWG_fnc_raiseClientEvent)
#define EVENT_ON_LOADOUT_CHANGED "OnLoadoutChanged" //Called by 'inventoryManager' subsystem when a loadout is changed.     params ["_loadOut","_flattenLoadOut"];
#define EVENT_ON_LOOT_CHANGED "OnLootChanged" //Called by 'lootStorage' subsystem when a loot is changed.     params ["_loot"];
#define EVENT_ON_MONEY_CHANGED "OnMoneyChanged" //Called by 'wallet' subsystem when a money is changed.     params ["_oldMoney","_newMoney","_delta"];
#define EVENT_ON_PROGRESS_CHANGED "OnProgressChanged" //Called by 'progress' subsystem when a progress is changed.     params ["_type","_amount","_total"];
#define EVENT_ON_GARAGE_CHANGED "OnGarageChanged" //Called by 'garage' subsystem when a garage is changed.     params ["_garageArray"];

//Mission states
/* initialization */
#define MSTATE_SCRIPTS_COMPILATION -3
#define MSTATE_DISABLED -2
#define MSTATE_MACHINE_STARTUP -1
/* base build */
#define MSTATE_BASE_UKREP 0
#define MSTATE_BASE_ECONOMY 1
#define MSTATE_BASE_QUESTS 2
/* missions list */
#define MSTATE_LIST_INIT 3
#define MSTATE_LIST_CHECK 4
/* player input expect */
#define MSTATE_READY 5
#define MSTATE_VOTING 6
/* mission build */
#define MSTATE_BUILD_CONFIG 7
#define MSTATE_BUILD_UKREP 8
#define MSTATE_BUILD_ECONOMY 9
#define MSTATE_BUILD_DSPAWN 10
#define MSTATE_BUILD_QUESTS 11
/* mission playflow */
#define MSTATE_FIGHT_SETUP 12
#define MSTATE_FIGHT_READY 13
#define MSTATE_FIGHT_INFILTRATION 14
#define MSTATE_FIGHT_ACTIVE 15
#define MSTATE_FIGHT_EXHAUSTED 16
/* mission end */
#define MSTATE_COMPLETED 17
#define MSTATE_CLEANUP 18
#define MSTATE_RESET 19
#define MSTATE_SERVER_RESTART 20
/* escape phase */
#define MSTATE_ESCAPE_SETUP 21
#define MSTATE_ESCAPE_ACTIVE 22
#define MSTATE_ESCAPE_FAILED 23
#define MSTATE_ESCAPE_COMPLETED 24


//Mission factions
#define MISSION_FACTION_NATO "NATO"
#define MISSION_FACTION_AAF "AAF"

//NPCs
#define NPC_TAXI "TAXI"
#define NPC_MECH "MECH"
#define NPC_TRDR "TRDR"
#define NPC_MEDC "MEDC"
#define NPC_COMM "COMM"
#define NPC_ROOF "ROOF"

//Progress
#define P__EXP 0 /*Experience*/
#define P__LVL 1 /*Player Level*/
#define P_TAXI 2 /*Progress with Taxi*/
#define P_TRDR 3 /*Progress with Trader*/
#define P_COMM 4 /*Progress with Commander*/

#define P_DEFAULT_CHART [0,0,0,0,0]

/*Quest Types*/
#define QST_TYPE_VEH_STEAL 0
#define QST_TYPE_INTERROGATE 1
#define QST_TYPE_HACK_DATA 2
#define QST_TYPE_DESTROY 3
#define QST_TYPE_INTEL 4
#define QST_TYPE_INFECTION 5
#define QST_TYPE_WOUNDED 6
#define QST_TYPE_MED_SUPPLY 7
#define QST_TYPE_WEAPON 8
#define QST_TYPE_ELECTRONICS 9
#define QST_TYPE_BURNDOWN 10
#define QST_TYPE_TOOLS 11

/*Quest States*/
#define QST_STATE_UNASSIGNED 0
#define QST_STATE_IN_PROGRESS 1
#define QST_STATE_FAILED 2
#define QST_STATE_DONE 3
#define QST_STATE_CLOSED 4

/*Quest Results*/
#define QST_RESULT_BD_END -1
#define QST_RESULT_UNDONE 0
#define QST_RESULT_GD_END 1

/*Quest Data structure*/
#define QST_DATA_TYPE 0
#define QST_DATA_NPC 1
#define QST_DATA_TARGET_OBJECT 2
#define QST_DATA_TARGET_CLASSNAME 3
#define QST_DATA_REWARD 4
#define QST_DATA_MARKER 5

/*Quest Reward Per Item structure*/
#define QST_REWARD_PER_ITEM_PERCENTAGE 0
#define QST_REWARD_PER_ITEM_PRICE_MAP 1

/*Unknown Winner*/
#define QST_UNKNOWN_WINNER "UNKWN"