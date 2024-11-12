#include "..\..\globalDefines.h"
/*
    Connector between lootMission and dspawn battlefield system to fill spawned vehciles with loot
*/

//================================================================================================================
//Init
private _Init = {
	[EVENT_ON_DSPAWN_GROUP_SPAWNED,{_this call NWG_LM_DSC_OnGroupSpawned}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//On group spawned
NWG_LM_DSC_OnGroupSpawned = {
	// params ["_group","_vehicle","_units","_tags","_tier","_faction"];
	params ["","_vehicle","","","","_faction"];
	if (_vehicle isEqualTo false) exitWith {};//Ignore if vehicle is not spawned
	if !(_vehicle isEqualType objNull) exitWith {};//Ignore if vehicle is not spawned

	//Get mission faction
	private _mFaction = call NWG_fnc_mmGetMissionFaction;
	if (_faction isNotEqualTo _mFaction) exitWith {};//Ignore if faction of the group differs

	//Fill vehicle
	[_mFaction,[_vehicle]] call NWG_fnc_lmFillVehicles;
};

//================================================================================================================
call _Init;