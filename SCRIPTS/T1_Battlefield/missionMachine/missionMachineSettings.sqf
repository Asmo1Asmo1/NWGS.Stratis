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
	// Mission selection
	/*Missions blueprints*/
	["MISSIONS_BLUEPRINT_PAGENAME","Abs%1"],//Template for where to find mission blueprints for the map
	["MISSIONS_ESCAPE_BLUEPRINT_PAGENAME","Abs%1Escape"],//Template for where to find final escape blueprint
	["MISSIONS_LIST_MIN_DISTANCE",50],//Min distance between missions to be added to the list (example: several variants of the same mission, only one will be added by distance rule)

	/*Missions list update*/
	["MISSIONS_UPDATE_NO_MISSIONS_RESTART",true],//Go to RESTART state if no missions left
	["MISSIONS_UPDATE_NO_MISSIONS_RUN_ESCAPE",false],//Auto-run escape if no missions left
	["MISSIONS_UPDATE_NO_MISSIONS_EXIT",false],//Exit heartbeat cycle if no missions left (not recommended, will look like server stuck)

	/*Missions post-selection*/
	["MISSIONS_SELECT_DISCARD_REJECTED",false],//True - rejected missions get discarded, False - rejected missions go back to the missions list for next selection
	["MISSIONS_SELECT_RESHUFFLE_LIST",true],//True - missions list gets reshuffled post-selection, False - missions list stays in the same order

	//==================================================================================================
	// Mission levels and tiers (defines number of levels and tiers matrix) (the last level is always escape)
	["MISSION_LEVELS_AND_TIERS",[
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

	//==================================================================================================
	// Mission settings
	["MISSIONS_USE_ACTUAL_BLUEPRINT_RAD",false],//If true - an actual radius of a blueprint will be used for map outline, dspawn, buildings, etc.
	["MISSIONS_ENEMY_SIDE",west],//Side of the enemy groups (will it be always the same?)
	["MISSIONS_ENEMY_FACTION","NATO"],//Faction of enemy groups (how will we add more factions? postponed question)
	["MISSIONS_EMPTY_BLDG_PAGENAME","BldgEmpty"],//Pagename with blueprints to fill empty buildings with
	["MISSIONS_DONE_COLOR","ColorGreen"],//Color to mark missions on the map as done
	["MISSIONS_DONE_ALPHA",0.6],//Alpha value of 'done' map mark
	["MISSIONS_PRESETS",[
		createHashMapFromArray [
			["PresetName","#MIS_DIF_EASY#"],
			["Difficulty","EASY"],
			["Radius",110],
			["MapMarker","mil_objective"],
			["MapMarkerColor","ColorOrange"],
			["MapMarkerSize",1.25],
			["MapOutlineAlpha",0.6],
			["UkrepFractalSteps",[
				/*root:*/[/*pageName:*/nil,   /*chances:*/[],   /*groupRules:*/[nil,nil,/*disablePath:*/false]],
				/*bldg:*/[/*pageName:*/"AUTO",/*chances:*/[
					/*OBJ_TYPE_BLDG:*/1,
					/*OBJ_TYPE_FURN:*/1,
					/*OBJ_TYPE_DECO:*/1,
					/*OBJ_TYPE_UNIT:*/(
						createHashMapFromArray [
							["MinPercentage",0.10],
							["MaxPercentage",0.55],
							["MinCount",0],
							["MaxCount",10]
						]
					),
					/*OBJ_TYPE_VEHC:*/[0.0,1.0],
					/*OBJ_TYPE_TRRT:*/(
						createHashMapFromArray [
							["MinPercentage",0.3],
							["MaxPercentage",0.8],
							["MinCount",0],
							["MaxCount",3]
						]
					),
					/*OBJ_TYPE_MINE:*/1]],
				/*furn:*/[/*pageName:*/"AUTO",/*chances:*/[
					/*OBJ_TYPE_BLDG:*/1,
					/*OBJ_TYPE_FURN:*/1,
					/*OBJ_TYPE_DECO:*/(
						createHashMapFromArray [
							["IgnoreList",["Land_PCSet_01_case_F","Land_PCSet_01_keyboard_F","Land_PCSet_01_screen_F","Land_PCSet_Intel_01_F","Land_PCSet_Intel_02_F","Land_FlatTV_01_F"]],
							["MinPercentage",0.25],
							["MaxPercentage",0.65],
							["MinCount",2]
						]
					),
					/*OBJ_TYPE_UNIT:*/1,
					/*OBJ_TYPE_VEHC:*/1,
					/*OBJ_TYPE_TRRT:*/1,
					/*OBJ_TYPE_MINE:*/1
				]]
			]],
			["UkrepMapBldgsLimit",8],//How many buildings in the mission area to decorate properly
			["UkrepMapBldgsEmptyLimit",8],//How many leftover empty buildings to fill with partial, low object number decorations
			["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
			["DspawnRadiusMin",150],
			["DspawnRadiusMax",250],
			["DspawnGroupsMult",1],//Multiply number of ukrep groups by X to get dspawn groups
			["DspawnGroupsMin",[2,3]],
			["DspawnGroupsMax",[5,6]],
			["ExhaustAfter",900],//Seconds after mission is exhausted (no more units will be spawned)
			["",0]
		],
		createHashMapFromArray [
			["PresetName","#MIS_DIF_NORMAL#"],
			["Difficulty","NORM"],
			["Radius",160],
			["MapMarker","mil_objective"],
			["MapMarkerColor","ColorRed"],
			["MapMarkerSize",1.25],
			["MapOutlineAlpha",0.6],
			["UkrepFractalSteps",[
				/*root:*/[/*pageName:*/nil,   /*chances:*/[],   /*groupRules:*/[nil,nil,/*disablePath:*/false]],
				/*bldg:*/[/*pageName:*/"AUTO",/*chances:*/[
					/*OBJ_TYPE_BLDG:*/1,
					/*OBJ_TYPE_FURN:*/1,
					/*OBJ_TYPE_DECO:*/1,
					/*OBJ_TYPE_UNIT:*/(
						createHashMapFromArray [
							["MinPercentage",0.30],
							["MaxPercentage",0.75],
							["MinCount",1],
							["MaxCount",20]
						]
					),
					/*OBJ_TYPE_VEHC:*/[0.0,1.0],
					/*OBJ_TYPE_TRRT:*/(
						createHashMapFromArray [
							["MinPercentage",0.5],
							["MaxPercentage",1.0],
							["MinCount",1],
							["MaxCount",3]
						]
					),
					/*OBJ_TYPE_MINE:*/1]],
				/*furn:*/[/*pageName:*/"AUTO",/*chances:*/[
					/*OBJ_TYPE_BLDG:*/1,
					/*OBJ_TYPE_FURN:*/1,
					/*OBJ_TYPE_DECO:*/(
						createHashMapFromArray [
							["IgnoreList",["Land_PCSet_01_case_F","Land_PCSet_01_keyboard_F","Land_PCSet_01_screen_F","Land_PCSet_Intel_01_F","Land_PCSet_Intel_02_F","Land_FlatTV_01_F"]],
							["MinPercentage",0.45],
							["MaxPercentage",0.85],
							["MinCount",2]
						]
					),
					/*OBJ_TYPE_UNIT:*/1,
					/*OBJ_TYPE_VEHC:*/1,
					/*OBJ_TYPE_TRRT:*/1,
					/*OBJ_TYPE_MINE:*/1
				]]
			]],
			["UkrepMapBldgsLimit",10],//How many buildings in the mission area to decorate properly
			["UkrepMapBldgsEmptyLimit",6],//How many leftover empty buildings to fill with partial, low object number decorations
			["DspawnRadiusMult",1.5],//Multiply ukrep radius by X to get dspawn radius (trigger)
			["DspawnRadiusMin",150],
			["DspawnRadiusMax",250],
			["DspawnGroupsMult",2],//Multiply number of ukrep groups by X to get dspawn groups
			["DspawnGroupsMin",[3,4]],
			["DspawnGroupsMax",[8,9]],
			["ExhaustAfter",1800],//Seconds after mission is exhausted (no more units will be spawned)
			["",0]
		]
	]],

	//==================================================================================================
	// Escape endgame
	["ESCAPE_MUSIC",["LeadTrack01_F_Mark","LeadTrack01_F_Heli","LeadTrack04_F_EXP","MainTheme_F_Tank","LeadTrack01_F_6th_Anniversary_Remix"]],
	["ESCAPE_BASEATTACK_GROUPSCOUNT",[5,6,7,8]],

	["",0]
];