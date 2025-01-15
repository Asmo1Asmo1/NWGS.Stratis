//================================================================================================================
//================================================================================================================
//Defines
#define DSPAWN_FACTION "ShopMobile"
#define RESULT_TYPE_LAST_SPAWNED 1

//================================================================================================================
//================================================================================================================
//Settings
NWG_MSHOP_DSC_Settings = createHashMapFromArray [
	["RADIUS_DRONE",[450,550]],
	["RADIUS_UNITS",[100,200]],

	["PARADROP_VEHICLE_CLASSNAME","B_T_VTOL_01_vehicle_F"],//Vehicle that will be used to imitate paradrop

	["",0]
];

//================================================================================================================
//================================================================================================================
//Group spawning
NWG_MSHOP_DSC_SpawnGroup = {
    params ["_player","_itemName","_targetPos"];
    if (!canSuspend) then {"NWG_MSHOP_DSC_SpawnGroup: Must be called from 'spawn' or 'remoteExec'" call NWG_fnc_logError};

	//Get item category
	private _cat = _itemName select [0,2];
	if !(_cat in ["C0","C2"]) exitWith {
		(format ["NWG_MSHOP_DSC_SpawnGroup: Invalid category: '%1'",_itemName]) call NWG_fnc_logError;
		false
	};

	//Define category-specific values
	// private _membership = switch (_cat) do {
	// 	case "C0": {side _player};//Side for drones
	// 	case "C2": {group _player};//Group for units
	// UPD: Joining to player's group (non-local for server) breaks things. Units die in the air and/or shoot each other if from different faction.
	// };
	private _membership = side (group _player);/*Fix for infantry support (PART 1)*//*Fix for renegade player*/
	private _spawnRadius = switch (_cat) do {
		case "C0": {NWG_MSHOP_DSC_Settings get "RADIUS_DRONE"};
		case "C2": {NWG_MSHOP_DSC_Settings get "RADIUS_UNITS"};
	};
	if (_spawnRadius isEqualType [])
		then {_spawnRadius = _spawnRadius call NWG_fnc_randomRangeFloat};

	//Spawn group
	private _spawnResult = [
		_targetPos,			/*Position*/
		_spawnRadius,		/*Radius*/
		"ShopMobile",		/*Faction*/
		[[_itemName],[],[]],/*Filter*/
		_membership,		/*Side or group*/
		true				/*Skip finalize*/
	] call NWG_fnc_dsSpawnSingleGroup;
	if (isNil "_spawnResult" || {_spawnResult isEqualTo false}) exitWith {
		(format ["NWG_MSHOP_DSC_SpawnGroup: Failed to spawn group with args: '%1'",_this]) call NWG_fnc_logError;
		false
	};
	_spawnResult params ["_group","_vehicle","_units"];

	/*Fix for infantry support (PART 2)*/
	if (_cat isEqualTo "C2") then {
		private _leader = leader (group _player);//Fix for non-leader player buying units
		if (isNull _leader || {!isPlayer _leader}) exitWith {(format ["NWG_MSHOP_DSC_SpawnGroup: Failed to get player's leader for player '%1'",(name _player)]) call NWG_fnc_logError};
		{_x setCaptive true} forEach _units;//Fix units firing at each other
		_units remoteExec ["NWG_MSHOP_DSC_AdoptUnits",_leader];
	};

	//return
	switch (_cat) do {
		case "C0": {_vehicle};
		case "C2": {_units};
	}
};

//================================================================================================================
//================================================================================================================
//Vehicle spawning
NWG_MSHOP_DSC_SpawnVehicle = {
	params ["_player","_vehicleClassname","_targetPos"];
	if (!canSuspend) then {"NWG_MSHOP_DSC_SpawnVehicle: Must be called from 'spawn' or 'remoteExec'" call NWG_fnc_logError};

	//Spawn vehicle
	private _vehicle = [
		_vehicleClassname,/*Classname*/
		_targetPos,/*Position*/
		(random 360),/*Direction*/
		false,/*Appearance*/
		false,/*Pylons*/
		true/*Defer reveal*/
	] call NWG_fnc_spwnSpawnVehicleAround;
	if (isNil "_vehicle" || {isNull _vehicle || {_vehicle isEqualTo false}}) exitWith {
		(format ["NWG_MSHOP_DSC_SpawnVehicle: Failed to spawn vehicle with args: '%1'",_this]) call NWG_fnc_logError;
		false
	};

	//Imitate paradrop
	private _paradropBy = NWG_MSHOP_DSC_Settings get "PARADROP_VEHICLE_CLASSNAME";
	[_vehicle,_paradropBy] call NWG_fnc_dsImitateParadrop;

	//return
	_vehicle
};
