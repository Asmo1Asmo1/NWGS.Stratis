#include "..\..\globalDefines.h"
#include "missionMachineDefines.h"

NWG_MIS_SER_Settings = createHashMapFromArray [
	//==================================================================================================
	// Main settings
	/*Autostart*/
	["AUTOSTART",true],//Start the mission machine once the scripts are compiled and game started
	["AUTOSTART_IN_DEVBUILD",true],//Start even if we are in debug environment
	["HEARTBEAT_RATE",1],//How often the mission machine should check for state changes

	/*Restart*/
	["SERVER_RESTART_ON_ZERO_ONLINE_AFTER",60],//Delay in seconds how long do we wait for someone to join before restarting the server

	/*Logging*/
	["LOG_STATE_CHANGE",true],//Log every state change

	//==================================================================================================
	// Player Base settings
	["PLAYER_BASE_ROOT","PlayerBase"],//Name of pre-placed map object (value of Object:Init -> Variable name) (mandatory for mission machine to work)
	["PLAYER_BASE_RADIUS",70],//How far from base is counted as 'on the base' for players
	["PLAYER_BASE_BLUEPRINT","PlayerBase"],//Blueprint(s) page to build the base with using ukrep subsystem
	["PLAYER_BASE_MARKERS",["o_unknown","loc_Tourism"]],//Markers to be placed at the player base position
	["PLAYER_BASE_MARKERS_SIZE",1.25],//Size of the markers
	["PLAYER_BASE_NPC_SETTINGS", createHashMapFromArray [
		/*TAXI*/["B_G_Story_Guerilla_01_F",[/*disarm:*/false,/*anim:*/"InBaseMoves_Lean1",/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]],
		/*MECH*/["I_G_Story_Protagonist_F",[/*disarm:*/true,/*anim:*/["HubBriefing_ext_Contact","HubBriefing_loop","Acts_Explaining_EW_Idle01"],/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]],
		/*TRDR*/["I_G_resistanceLeader_F" ,[/*disarm:*/true,/*anim:*/["HubSittingChairUA_idle2","HubSittingChairUA_idle3"],/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]],
		/*MEDC*/["I_C_Soldier_Camo_F",[/*disarm:*/true,/*anim:*/"Acts_Gallery_Visitor_02",/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]],
		/*COMM*/["I_E_Soldier_MP_F"  ,[/*disarm:*/false,/*anim:*/["Acts_millerCamp_A","Acts_millerCamp_C","acts_millerIdle"],/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]],
		/*ROOF*/["B_G_Captain_Ivan_F",[/*disarm:*/false,/*anim:*/false,/*addAction:*/["#DLG_OPEN_TITLE#",{_this call NWG_fnc_dlgOpenByNpc}]]]
	]],

	//==================================================================================================
	// Missions blueprints and selection
	/*Missions blueprints*/
	["BLUEPRINTS_MISSIONS_PAGENAME","Abs%1"],//Template for where to find mission blueprints for the map
	["BLUEPRINTS_ESCAPE_PAGENAME","Abs%1Escape"],//Template for where to find blueprints for final escape mission
	["BLUEPRINTS_EMPTY_BLDG_PAGENAME","BldgEmpty"],//Pagename with blueprints to fill empty buildings with

	/*Missions list init settings*/
	["MLIST_MIN_DISTANCE",150],//Min distance between missions to be added to the list (example: several variants of the same mission, only one will be added by distance rule)

	/*Missions list check settings*/
	["MLIST_CHECK_NO_MISSIONS_RESTART",true],//Go to RESTART state if no missions left (high priority)
	["MLIST_CHECK_NO_MISSIONS_RUN_ESCAPE",false],//Auto-run escape if no missions left (mid priority)
	["MLIST_CHECK_NO_MISSIONS_EXIT",false],//Exit heartbeat cycle if no missions left (not recommended, will look like server stuck) (low priority)

	//==================================================================================================
	// Voting settings
	["MVOTE_SKIP_FOR_ONE",true],//Skip voting if only one player is online
	["MVOTE_SHUFFLE_ON_AGAINST",true],//Shuffle missions on against vote (sort of like refusing to play this specific mission)

	//==================================================================================================
	// Mission levels and tiers (defines number of levels and tiers matrix) (the last level is always escape)
	["LEVELS_AND_TIERS",[
		/*Level 01*/[1],
		/*Level 02*/[1],
		/*Level 03*/[1],
		/*Level 04*/[1,2],
		/*Level 05*/[1,2],
		/*Level 06*/[1,2],
		/*Level 07*/[1,2,3],
		/*Level 08*/[1,2,3],
		/*Level 09*/[1,2,3],
		/*Level 10*/[1,2,3,4],
		/*Level 11*/[1,2,3,4],
		/*Level 12*/[2,3,4],
		/*Level 13*/[2,3,4],
		/*Level 14*/[2,3,4],
		/*Level 15*/[3,4],
		/*Level 16*/[3,4],
		/*Level 17 - ESCAPE*/[3,4]
	]],
	["MAX_TIER",4],

	//==================================================================================================
	// Enemy settings
	["ENEMY_FACTIONS",[MISSION_FACTION_NATO,MISSION_FACTION_AAF,MISSION_FACTION_CSAT]],//Factions to choose from (will be used to build mission selection list)
	["ENEMY_SIDE",west],//Side of the enemy groups (used to spawn enemy groups) (stays constant)
	["ENEMY_COLORS", createHashMapFromArray [
		[MISSION_FACTION_NATO,"ColorBlue"],
		[MISSION_FACTION_AAF,"ColorGUER"],
		[MISSION_FACTION_CSAT,"ColorRed"]
	]],
	["ENEMY_PER_SELECTION",3],//Max number of factions to use in selection

	//==================================================================================================
	// Map markers settings
	["MAP_MIS_MARKER_TYPE","mil_objective"],//Marker type for missions
	["MAP_MIS_MARKER_SIZE",1.25],//Marker size for missions
	["MAP_MIS_OUTLINE_ALPHA",0.6],//Alpha value of outline for missions

	["MAP_DONE_SIZE",1],//Marker size for missions
	["MAP_DONE_TYPE","waypoint"],//Marker type for marking missions as done
	["MAP_DONE_COLOR","ColorGreen"],//Color to mark missions on the map as done
	["MAP_DONE_ALPHA",0.6],//Alpha value of 'done' map mark
	["MAP_DONE_ADD_COUNTER",false],//Add counter to the 'done' map mark (e.g.: 1/16)
	["MAP_DONE_ADD_OUTLINE",false],//Add outline to the 'done' map mark (e.g.: Big green circle)

	//==================================================================================================
	// Mission settings
	["MISSION_RADIUS_MIN_MAX",[100,250]],//Min and max radius for missions by level
	["MISSION_EXHAUST_MIN_MAX",[600,2700]],//Min and max exhaust time for missions by level

	//==================================================================================================
	// Escape endgame settings
	["ESCAPE_TIME_LIMIT",1500],//Time limit for escape mission
	["ESCAPE_MUSIC",["LeadTrack01_F_Mark","LeadTrack01_F_Heli","LeadTrack04_F_EXP","MainTheme_F_Tank","LeadTrack01_F_6th_Anniversary_Remix"]],
	["ESCAPE_BASEATTACK_GROUPSCOUNT",[5,6,7,8]],

	//==================================================================================================
	// Ukrep settings
	["UKREP_FRACTAL_STEPS", [
		/*root:*/[/*pageName:*/nil,	  /*chances:*/[], /*groupRules:*/[nil,nil,/*disablePath:*/false]],
		/*bldg:*/[/*pageName:*/"AUTO",/*chances:*/[
			/*OBJ_TYPE_BLDG:*/1,
			/*OBJ_TYPE_FURN:*/1,
			/*OBJ_TYPE_DECO:*/1,
			/*OBJ_TYPE_UNIT:*/(
				createHashMapFromArray [
					["MinPercentage",nil],/*defined by level*/
					["MaxPercentage",nil],/*defined by level*/
					["MinCount",nil],/*defined by level*/
					["MaxCount",nil]/*defined by level*/
				]
			),
			/*OBJ_TYPE_VEHC:*/[0.0,1.0],
			/*OBJ_TYPE_TRRT:*/(
				createHashMapFromArray [
					["MinPercentage",nil],/*defined by level*/
					["MaxPercentage",nil],/*defined by level*/
					["MinCount",nil],/*defined by level*/
					["MaxCount",nil]/*defined by level*/
				]
			),
			/*OBJ_TYPE_MINE:*/1
		]],
		/*furn:*/[/*pageName:*/"AUTO",/*chances:*/[
			/*OBJ_TYPE_BLDG:*/1,
			/*OBJ_TYPE_FURN:*/1,
			/*OBJ_TYPE_DECO:*/(
				createHashMapFromArray [
					["IgnoreList",["Land_PCSet_01_case_F","Land_PCSet_01_keyboard_F","Land_PCSet_01_screen_F","Land_PCSet_Intel_01_F","Land_PCSet_Intel_02_F","Land_FlatTV_01_F"]],
					["MinPercentage",nil],/*defined by level*/
					["MaxPercentage",nil],/*defined by level*/
					["MinCount",nil]/*defined by level*/
				]
			),
			/*OBJ_TYPE_UNIT:*/1,
			/*OBJ_TYPE_VEHC:*/1,
			/*OBJ_TYPE_TRRT:*/1,
			/*OBJ_TYPE_MINE:*/1
		]]
	]],
	["UKREP_UNIT_MIN_PERC_MIN_MAX",[0.10,0.30]],
	["UKREP_UNIT_MAX_PERC_MIN_MAX",[0.55,0.75]],
	["UKREP_UNIT_MIN_COUNT_MIN_MAX",[0,1]],
	["UKREP_UNIT_MAX_COUNT_MIN_MAX",[10,20]],
	["UKREP_TRRT_MIN_PERC_MIN_MAX",[0.3,0.5]],
	["UKREP_TRRT_MAX_PERC_MIN_MAX",[0.8,1.0]],
	["UKREP_TRRT_MIN_COUNT_MIN_MAX",[0,1]],
	["UKREP_TRRT_MAX_COUNT_MIN_MAX",[3,4]],
	["UKREP_FURN_DECO_MIN_PERC_MIN_MAX",[0.25,0.45]],
	["UKREP_FURN_DECO_MAX_PERC_MIN_MAX",[0.65,0.85]],
	["UKREP_FURN_DECO_MIN_COUNT_MIN_MAX",[2,5]],

	["UKREP_MAP_BLDG_LIMIT_FULL_MIN_MAX",[4,12]],
	["UKREP_MAP_BLDG_LIMIT_EMPT_MIN_MAX",[4,8]],

	//==================================================================================================
	// Dspawn settings
	["DSPAWN_GROUPS_MIN_MAX",[3,18]],

	["",0]
];