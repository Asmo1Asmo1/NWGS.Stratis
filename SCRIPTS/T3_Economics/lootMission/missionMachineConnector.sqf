#include "..\..\globalDefines.h"
/*
    Connector between lootMission and missionMachine to provide mission objects for filling with loot
*/

//================================================================================================================
//Settings
NWG_LM_MMC_Settings = createHashMapFromArray [
	["ENRICHMENT_MIN_MAX",[-1,1]],//Loot enrichment

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

	private _enrichment = NWG_LM_MMC_Settings get "ENRICHMENT_MIN_MAX";
	_enrichment = _enrichment call NWG_fnc_mmInterpolateByLevelInt;
	private _ok = [_enrichment,_enrichment] call NWG_fnc_lmConfigureEnrichment;
	if (isNil "_ok" || _ok isNotEqualTo true) then {
		(format ["NWG_LM_MMC_ConfigureEnrichment: Failed to configure enrichment: '%1', result: %2",_enrichment,_ok]) call NWG_fnc_logError;
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
			["CIV",_civVehs] call NWG_fnc_lmFillVehicles;//Start with CIV to utilize faction caching for future requests
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
		};

		default {};
	};
};

//================================================================================================================
call _Init;
