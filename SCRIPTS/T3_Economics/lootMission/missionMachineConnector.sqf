#include "..\..\globalDefines.h"
/*
    Connector between lootMission and missionMachine to provide mission objects for filling with loot
*/

//================================================================================================================
//Settings
NWG_LM_MMC_Settings = createHashMapFromArray [
	["ENRICHMENT_MIN_MAX",[-1,1]],//Loot enrichment

	/*Civilian luggage looting*/
	["LUGGAGE_DECOS",[
		"Land_LuggageHeap_01_F",
		"Land_LuggageHeap_02_F",
		"Land_LuggageHeap_03_F",
		"Land_LuggageHeap_04_F",
		"Land_LuggageHeap_05_F"
	]],
	["LUGGAGE_CONTAINER","Box_IDAP_AmmoOrd_F"],//Invisible container to be placed inside luggage
	["LUGGAGE_ACTION_TITLE","#LS_ACTION_LUGGAGE_TITLE#"],//Action title
	["LUGGAGE_ACTION_ICON","a3\ui_f\data\igui\cfg\actions\take_ca.paa"],//Action icon

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
	[EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_LM_MMC_ConfigureEnrichment},/*setFirst:*/true] call NWG_fnc_subscribeToServerEvent;
    [EVENT_ON_MISSION_STATE_CHANGED,{_this call NWG_LM_MMC_OnMissionStateChanged}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//Enrichment configuration based on mission difficulty (high priority)
//It should fire first and quickly configure enrichment (global property) before other subscribers react
NWG_LM_MMC_ConfigureEnrichment = {
	// params ["_oldState","_newState"];
	params ["","_newState"];
	if (_newState != MSTATE_BUILD_ECONOMY) exitWith {};

	private _enrichment = (NWG_LM_MMC_Settings get "ENRICHMENT_MIN_MAX") call NWG_fnc_mmInterpolateByLevelInt;
	private _maxTier = 0;
	{if (_x > _maxTier) then {_maxTier = _x}} forEach (call NWG_fnc_mmGetMissionTiers);
	private _args = [_enrichment,_enrichment,_maxTier];
	private _ok = _args call NWG_fnc_lmConfigure;
	if (isNil "_ok" || _ok isNotEqualTo true) then {
		(format ["NWG_LM_MMC_ConfigureEnrichment: Failed to configure loot machine. args:'%1', result: %2",_args,_ok]) call NWG_fnc_logError;
	};
};

//================================================================================================================
//On mission state changed (regular priority)
NWG_LM_MMC_CatalogueCompiled = false;
NWG_LM_MMC_OnMissionStateChanged = {
    // params ["_oldState","_newState"];
    params ["","_newState"];

	switch (_newState) do {
		/*Base building economy state*/
		case MSTATE_BASE_ECONOMY: {
			NWG_LM_MMC_CatalogueCompiled = call NWG_fnc_lmCompileCatalogue;
			if (!NWG_LM_MMC_CatalogueCompiled) then {
				"NWG_LM_MMC_OnMissionStateChanged: Failed to compile loot catalogue, check logs and your NWG_LM_SER_Settings" call NWG_fnc_logError;
			};
		};

		/*Mission building economy state*/
		case MSTATE_BUILD_ECONOMY: {
			//Check if catalogue was compiled on a previous state
			if (!NWG_LM_MMC_CatalogueCompiled) exitWith {
				"NWG_LM_MMC_OnMissionStateChanged: Loot catalogue was not compiled, check logs and your NWG_LM_SER_Settings" call NWG_fnc_logError;
			};

			//Get mission values
			private _mFaction = call NWG_fnc_mmGetMissionFaction;
			private _mObjects = call NWG_fnc_mmGetMissionObjects;

			//Sort vehicles
			private _facVehs = [];
			private _civVehs = [];
			private _classname = "";
			{
				_classname = typeOf _x;
				switch (true) do {
					case ("Kart" in _classname): {/*Ignore karts*/};
					case ((_classname find "C") == 0): {_civVehs pushBack _x};//CIV vehicles start with "C", e.g. "C_Tractor_01_F"
					default {_facVehs pushBack _x};
				};
			} forEach (_mObjects#OBJ_CAT_VEHC);

			//Fill vehicles
			["CIV",_civVehs] call NWG_fnc_lmFillVehicles;
			[_mFaction,_facVehs] call NWG_fnc_lmFillVehicles;

			//Fill containers
			private _containers = [_mFaction,(_mObjects#OBJ_CAT_DECO)] call NWG_fnc_lmFillContainers;

			//Ensure underwater containers could be looted as well
			//We are using anonymous functions as they will be transfered over the network and this connector exists only on the server
			{
				private _script = {
					// params ["_target","_caller","_actionId","_arguments"];
					params ["_container","","_actionId"];
					if (!isNil "NWG_fnc_lsLootContainer")
						then {_container call NWG_fnc_lsLootContainer}
						else {"NWG_LM_MMC_OnMissionStateChanged: Loot container function undefined" call NWG_fnc_logError};
					_container removeAction _actionId;
				};
				[_x,"#LS_ACTION_LOOT_TITLE#",_script] call NWG_fnc_addActionGlobal;
			} forEach (_containers select {((getPosASL _x)#2) < 0});

			//Fill civilian luggage heaps
			private _luggageClasses = NWG_LM_MMC_Settings get "LUGGAGE_DECOS";
			private _luggageContainer = NWG_LM_MMC_Settings get "LUGGAGE_CONTAINER";
			private _actionTitle = NWG_LM_MMC_Settings get "LUGGAGE_ACTION_TITLE";
			private _actionIcon = NWG_LM_MMC_Settings get "LUGGAGE_ACTION_ICON";
			private _invisibleBoxes = [];
			{
				//Create invisible container inside
				private _box = createVehicle [_luggageContainer,_x,[],0,"CAN_COLLIDE"];
				_box allowDamage false;
				_box hideObjectGlobal true;
				_box setPosASL (getPosASL _x);
				_invisibleBoxes pushBack _box;

				//Connect with luggage object
				_x setVariable ["NWG_LM_MMC_Luggage",_box,true];

				//Add action to open it
				private _script = {
					// params ["_target","_caller","_actionId","_arguments"];
					private _box = (_this#0) getVariable ["NWG_LM_MMC_Luggage",objNull];
					if (!isNull _box) then {player action ["Gear",_box]};
				};
				[_x,_actionTitle,_actionIcon,_script] call NWG_fnc_addHoldActionGlobal;
			} forEach ((_mObjects#OBJ_CAT_DECO) select {(typeOf _x) in _luggageClasses});
			if ((count _invisibleBoxes) > 0) then {
				["CIV",_invisibleBoxes] call NWG_fnc_lmFillContainers;
			};
		};

		default {};
	};
};

//================================================================================================================
call _Init;
