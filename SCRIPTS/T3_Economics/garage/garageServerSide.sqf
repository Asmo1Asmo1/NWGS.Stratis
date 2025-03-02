#include "..\..\globalDefines.h"
#include "garageDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_GRG_SER_Settings = createHashMapFromArray [
    ["SPAWN_PLATFORM_FUNC",{_this call NWG_fnc_spwnSpawnVehicleExact}],//Function to use for spawn on the platform. params ["_classname","_pos","_dir"]

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_GRG_SpawnPlatform = objNull;

//================================================================================================================
//================================================================================================================
//Setup spawn platform object
NWG_GRG_SER_SetSpawnPlatformObject = {
    // private _spawnPlatform = _this;
    NWG_GRG_SpawnPlatform = _this;
    publicVariable "NWG_GRG_SpawnPlatform";
};

//================================================================================================================
//================================================================================================================
//Vehicles processing
NWG_GRG_SER_DeleteVehicle = {
	// private _vehicle = _this;
	deleteVehicle _this;
};

NWG_GRG_SER_SpawnVehicleAtPlatform = {
	params ["_player","_fullItem"];
	private _vehicleClassname = _fullItem param [GR_CLASSNAME,""];
	if (_vehicleClassname isEqualTo "") exitWith {
		(format["NWG_GRG_SER_SpawnVehicleAtPlatform: Invalid full item '%1'",_fullItem]) call NWG_fnc_logError;
		false
	};

    private _platform = NWG_GRG_SpawnPlatform;
    if (isNil "_platform" || {!(_platform isEqualType objNull) || {isNull _platform}}) exitWith {
        (format["NWG_GRG_SER_SpawnVehicleAtPlatform: No platform found"]) call NWG_fnc_logError;
        false
    };

    private _spwnFunc = (NWG_GRG_SER_Settings get "SPAWN_PLATFORM_FUNC");
    if (isNil "_spwnFunc" || {!(_spwnFunc isEqualType {})}) exitWith {
        (format["NWG_GRG_SER_SpawnVehicleAtPlatform: Invalid spawn function defined"]) call NWG_fnc_logError;
        false
    };

	//Spawn vehicle
    private _pos = getPosASL _platform;
    private _dir = getDir _platform;
    private _vehicle = [_vehicleClassname,_pos,_dir] call _spwnFunc;
	if (_vehicle isEqualTo false) exitWith {
		(format["NWG_GRG_SER_SpawnVehicleAtPlatform: Failed to spawn vehicle '%1'",_vehicleClassname]) call NWG_fnc_logError;
		false
	};
	if (!(_vehicle isEqualType objNull) || {isNull _vehicle}) exitWith {
		(format["NWG_GRG_SER_SpawnVehicleAtPlatform: Spawned vehicle is null"]) call NWG_fnc_logError;
		false
	};

	//Setup vehicle ownership
	[_vehicle,_player] call NWG_fnc_vownPairVehAndPlayer;

	//Clear vehicle cargo
	_vehicle call NWG_fnc_clearContainerCargo;

	//Create AI crew for UAVs
	if (unitIsUAV _vehicle) then {
		(side (group _player)) createVehicleCrew _vehicle;
	};

	//Apply vehicle stats
	[_vehicle,_fullItem] call NWG_GRG_ApplyGarageArray;

	//return
	true
};
