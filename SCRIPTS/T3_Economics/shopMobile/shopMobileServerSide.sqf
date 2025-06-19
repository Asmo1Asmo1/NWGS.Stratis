/*
	Mobile shop
	This is the only shop where we know items roster at compile time
	And thus can minimize network traffic between server and client
	On server:
	- We have pre-defined roster of items and their prices
	- We also know their categories
	- And their effects
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_MSHOP_SER_Settings =  createHashMapFromArray [
	/*Default prices*/
	["DEFAULT_PRICES",createHashMapFromArray [
		/*Drones*/
		["C0I0",1000],//Scout drone
		["C0I1",1100],//Suicide drone (HE 44)
		["C0I2",1200],//Suicide drone (HEAT 55)
		["C0I3",1300],//Suicide drone (HEAT 75)
		["C0I4",1500],//Mine drone
		["C0I5",2500],//EMI drone
		["C0I6",2500],//Bomber drone
		["C0I7",50000],//Ababil

		/*Mortars*/
		["C1I0",1000],//Single strike
		["C1I1",1500],//Double tap
		["C1I2",2000],//Three in a row
		["C1I3",5000],//Barrage
		["C1I4",1500],//Illumination shells
		["C1I5",1500],//Smoke shells

		/*Infantry support*/
		["C2I0",8000],//Team (2)
		["C2I1",10000],//Squad (3)
		["C2I2",15000],//Company (5)
		["C2I3",20000] //Fire team (8)
	]],

	/*Price increase settings*//*params ["_itemIncrease","_catIncrease","_allIncrease"]*//*Applied consecutively*/
	["PRICE_INCREASE_SETTINGS",createHashMapFromArray [
		["C0I0",[100,500,0]],//Scout drone
		["C0I1",[200,500,0]],//Suicide drone (HE 44)
		["C0I2",[200,500,0]],//Suicide drone (HEAT 55)
		["C0I3",[200,500,0]],//Suicide drone (HEAT 75)
		["C0I4",[200,500,0]],//Mine drone
		["C0I5",[500,500,0]],//EMI drone
		["C0I6",[500,500,0]],//Bomber drone
		["C0I7",[5000,500,0]],//Ababil

		/*Mortars*/
		["C1I0",[100,500,0]],//Single strike
		["C1I1",[200,500,0]],//Double tap
		["C1I2",[300,500,0]],//Three in a row
		["C1I3",[1000,1000,0]],//Barrage
		["C1I4",[200,100,0]],//Illumination shells
		["C1I5",[200,100,0]],//Smoke shells

		/*Infantry support*/
		["C2I0",[0,1000,0]],//Team (2)
		["C2I1",[0,2000,0]],//Squad (3)
		["C2I2",[0,3000,0]],//Company (5)
		["C2I3",[0,4000,0]] //Fire team (8)
	]],

	/*Marker settings*//*params ["_markerType","_markerColor"]*/
	["MARKER_SETTINGS",createHashMapFromArray [
		["C0I0",false],//Scout drone
		["C0I1",false],//Suicide drone (HE 44)
		["C0I2",false],//Suicide drone (HEAT 55)
		["C0I3",false],//Suicide drone (HEAT 75)
		["C0I4",false],//Mine drone
		["C0I5",false],//EMI drone
		["C0I6",false],//Bomber drone
		["C0I7",false],//Ababil

		["C1I0",["hd_destroy_noShadow","ColorBlack"]],//Single strike
		["C1I1",["hd_destroy_noShadow","ColorBlack"]],//Double tap
		["C1I2",["hd_destroy_noShadow","ColorRed"]],  //Three in a row
		["C1I3",["hd_objective_noShadow","ColorRed"]],//Barrage
		["C1I4",["hd_destroy_noShadow","ColorWhite"]],//Illumination shells
		["C1I5",["hd_destroy_noShadow","ColorGrey"]], //Smoke shells

		["C2I0",["hd_join_noShadow","ColorBlack"]],//Team (2)
		["C2I1",["hd_join_noShadow","ColorBlack"]],//Squad (3)
		["C2I2",["hd_join_noShadow","ColorBlack"]],//Company (5)
		["C2I3",["hd_join_noShadow","ColorBlack"]] //Fire team (8)
	]],
	["MARKER_PRESERVE_COUNT",5],//How many markers to preserve at the same time (older ones will be deleted)

	/*Support levels*/
	["SUPPORT_LEVELS",createHashMapFromArray [
		["C0I0",1],//Scout drone
		["C0I1",2],//Suicide drone (HE 44)
		["C0I2",2],//Suicide drone (HEAT 55)
		["C0I3",2],//Suicide drone (HEAT 75)
		["C0I4",3],//Mine drone
		["C0I5",4],//EMI drone
		["C0I6",4],//Bomber drone
		["C0I7",5],//Ababil

		["C1I0",1],//Single strike
		["C1I1",2],//Double tap
		["C1I2",3],//Three in a row
		["C1I3",4],//Barrage
		["C1I4",1],//Illumination shells
		["C1I5",1],//Smoke shells

		["C2I0",1],//Team (2)
		["C2I1",2],//Squad (3)
		["C2I2",3],//Company (5)
		["C2I3",4] //Fire team (8)
	]],

	/*Function connectors*/
	["FUNC_SPAWN_DRONE",{_this call NWG_MSHOP_DSC_SpawnGroup}],    //params: ["_player","_itemName","_targetPos"]; returns: _drone object OR false in case of error
	["FUNC_SPAWN_INF_GROUP",{_this call NWG_MSHOP_DSC_SpawnGroup}],//params: ["_player","_itemName","_targetPos"]; returns: _units array OR false in case of error
	["FUNC_SPAWN_VEHICLE",{_this call NWG_MSHOP_DSC_SpawnVehicle}],//params: ["_player","_itemName","_targetPos"]; returns: _vehicle object OR false in case of error

	/*Drone actions settings*/
	["MINE_DEPLOY_HEIGHT",1],//Height at which mine will be deployed
	["MINE_DEPLOY_COUNT",3],
	["MINE_DEPLOY_DRONE_DELETE_DELAY",5],
	["EMI_RADIUS",25],
	["EMI_TARGETS",["engine","turret","gun","light","rotor"]],//Vehicle parts targeted by EMI impulse
	["EMI_DAMAGE_MIN",0.25],//Minimum damage to be inflicted by EMI impulse
	["EMI_DAMAGE_MAX",0.97],//Maximum damage to be inflicted by EMI impulse
	["BOMBER_DELETE_CHECK_INTERVAL",15],//Server-side check interval for bomber drones
	["BOMBER_DELETE_DELAY",5],//Delay since last shot before deleting the vehicle

	/*Mortar settings*//*params ["_ammoType","_radius","_count","_beforeDelay","_inBetweenDelay","_altitude","_velocity"]*/
	["MORTAR_SETTINGS",createHashMapFromArray [
		["C1I0",["Sh_82mm_AMOS",30, 1,  [5,15], 0,     250,15]],//Single strike
		["C1I1",["Sh_82mm_AMOS",30, 2,  [7,17],[0.5,3],250,15]],//Double tap
		["C1I2",["Sh_82mm_AMOS",35, 3,  [9,19],[0.5,3],250,15]],//Three in a row
		["C1I3",["Sh_82mm_AMOS",40, 8,  [9,20],[0.5,3],250,15]],//Barrage
		["C1I4",["F_40mm_CIR",40, 16, [5,15],[0.5,8],[150,200],15,"a3\missions_f_beta\data\sounds\Showcase_Night\flaregun_4.wss"]],//Illumination shells
		["C1I5",["Smoke_82mm_AMOS_White",30,[4,8],[5,15],[0.5,3],250,15]]//Smoke shells
	]],

	/*Units settings*/
	["UNITS_AA_UNIT","O_G_Soldier_unarmed_F"],//Unit that will be dressed as AA operator

	/*Vehicle settings*/
	["VEHICLE_MARKER_SETTING",["hd_end_noShadow","ColorBlack"]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_MSHOP_SER_priceMap = createHashMap;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	call NWG_MSHOP_SER_InitPriceMap;
};

NWG_MSHOP_SER_InitPriceMap = {
	private _defaultPrices = NWG_MSHOP_SER_Settings get "DEFAULT_PRICES";
	private _priceMap = NWG_MSHOP_SER_priceMap;
	{_priceMap set [_x,_y]} forEach _defaultPrices;
};

//================================================================================================================
//================================================================================================================
//Shop
NWG_MSHOP_SER_OnShopRequest = {
	private _player = _this;
	private _result = [];
	{
		_result pushBack _x;
		_result pushBack _y;
		_result pushBack ((NWG_MSHOP_SER_Settings get "SUPPORT_LEVELS") get _x);
	} forEach NWG_MSHOP_SER_priceMap;

	_result remoteExec ["NWG_fnc_mshopShopValuesResponse",_player];
};

//================================================================================================================
//================================================================================================================
//Item request
NWG_MSHOP_SER_OnItemBought = {
	params ["_player","_itemName","_pos",["_moneySpent",0]];

	//Check player just in case
	if (isNull _player) exitWith {
		(format ["NWG_MSHOP_SER_OnItemBought: Player is null: '%1'",_player]) call NWG_fnc_logError;
		false
	};

	//Place marker
	private _markerSettings = (NWG_MSHOP_SER_Settings get "MARKER_SETTINGS") get _itemName;
	if (!isNil "_markerSettings" && {_markerSettings isNotEqualTo false}) then {
		_markerSettings params ["_markerType","_markerColor"];
		[_pos,_markerType,_markerColor] call NWG_MSHOP_SER_PlaceMarker;
	};

	//Spawn item
	private _cat = _itemName select [0,2];
	private _ok = switch (_cat) do {
		case "C0": {_this call NWG_MSHOP_SER_SpawnDrone};
		case "C1": {_this call NWG_MSHOP_SER_FireMortar};
		case "C2": {_this call NWG_MSHOP_SER_SpawnInfSupport};
	};
	if (isNil "_ok" || {_ok isEqualTo false}) exitWith {
		(format ["NWG_MSHOP_SER_OnItemBought: Could not spawn item with args: '%1'",_this]) call NWG_fnc_logError;
		[_player,_moneySpent] call NWG_fnc_wltAddPlayerMoney;//Return money
		false
	};

	//Increase prices
	private _priceIncreaseSettings = (NWG_MSHOP_SER_Settings get "PRICE_INCREASE_SETTINGS") get _itemName;
	if (isNil "_priceIncreaseSettings") exitWith {
		(format ["NWG_MSHOP_SER_OnItemBought: No price increase settings found for item: '%1'",_itemName]) call NWG_fnc_logError;
		false
	};
	_priceIncreaseSettings params [["_itemIncrease",0],["_catIncrease",0],["_allIncrease",0]];
	if (_itemIncrease > 0) then {
		private _price = (NWG_MSHOP_SER_priceMap get _itemName) + _itemIncrease;
		NWG_MSHOP_SER_priceMap set [_itemName,_price];
	};
	if (_catIncrease > 0) then {
		private _cat = _itemName select [0,2];
		{
			if (_cat in _x) then {NWG_MSHOP_SER_priceMap set [_x,(_y + _catIncrease)]};
		} forEach NWG_MSHOP_SER_priceMap;
	};
	if (_allIncrease > 0) then {
		{
			NWG_MSHOP_SER_priceMap set [_x,(_y + _allIncrease)]
		} forEach NWG_MSHOP_SER_priceMap;
	};

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Drones
NWG_MSHOP_SER_SpawnDrone = {
	// params ["_player","_itemName","_pos"];
	params ["_player","_itemName"];

	//Spawn drone
	private _drone = _this call (NWG_MSHOP_SER_Settings get "FUNC_SPAWN_DRONE");
	if (isNil "_drone" || {_drone isEqualTo false}) exitWith {
		(format ["NWG_MSHOP_SER_SpawnDrone: Could not spawn drone with args: '%1'",_this]) call NWG_fnc_logError;
		false
	};

	//Execute drone specific code (if any)
	switch (_itemName) do {
		//Suicide drone - attach shell to the drone and make it go boom on impact
		case "C0I1";
		case "C0I2";
		case "C0I3": {
			//Define drone-specific values
			private ["_shellModel","_shellType","_attachPos","_dirAndUp"];
			switch (_itemName) do {
				case "C0I1": /*HE 44*/ {
					_shellModel = "\a3\Weapons_F_Tank\Launchers\MRAWS\rocket_MRAWS_HE_F_item.p3d";
					_shellType = "R_MRAAWS_HE_F";
					_attachPos = [0,-0.125,-0.12];
					_dirAndUp = [[3.82137e-15,4.37114e-08,1],[8.74228e-08,1,-4.37114e-08]];
				};
				case "C0I2": /*HEAT 55*/ {
					_shellModel = "\a3\Weapons_F_Tank\Launchers\MRAWS\rocket_MRAWS_HEAT55_F_item.p3d";
					_shellType = "R_MRAAWS_HEAT55_F";
					_attachPos = [0,0.125,-0.12];
					_dirAndUp = [[-1,4.37114e-08,-8.74228e-08],[8.74228e-08,-3.82137e-15,-1]];
				};
				case "C0I3": /*HEAT 75*/ {
					_shellModel = "\a3\Weapons_F_Tank\Launchers\MRAWS\rocket_MRAWS_HEAT_F_item.p3d";
					_shellType = "R_MRAAWS_HEAT_F";
					_attachPos = [0,0.125,-0.12];
					_dirAndUp = [[-1,4.37114e-08,-8.74228e-08],[8.74228e-08,-3.82137e-15,-1]];
				};
			};

			//Save for later use
			_drone setVariable ["NWG_MSHOP_shellType",_shellType];//Save locally
			_drone setVariable ["NWG_MSHOP_shellType",_shellType,2];//Save on server
			_drone setVariable ["NWG_MSHOP_owner",_player];//Save locally
			_drone setVariable ["NWG_MSHOP_owner",_player,2];//Save on server

			//Create visible shell
			private _visualObj = createSimpleObject [_shellModel,(getPosASL _drone)];
			_visualObj attachTo [_drone,_attachPos];
			_visualObj setVectorDirAndUp _dirAndUp;

			//Disable regular drone functionality
			_drone setAutonomous false;
			_drone enableUAVWaypoints false;
			{_drone removeWeapon _x} forEach weapons _drone;

			//Setup destruction logic
			_drone addMPEventHandler ["MPHit", {
				// params ["_unit","_causedBy","_damage","_instigator"];
				params ["_drone"];
				if (isServer) then {
					_drone removeMPEventHandler [_thisEvent,_thisEventHandler];//Delete event handler
					{deleteVehicle _x} forEach (attachedObjects _drone);//Delete visual object
					private _shellType = _drone getVariable ["NWG_MSHOP_shellType",""];//Extract shell type
					private _owner = _drone getVariable ["NWG_MSHOP_owner",objNull];//Extract owner
					private _charge = createVehicle [_shellType,_drone,[],0,"CAN_COLLIDE"];//Create charge
					_charge setShotParents [_owner, _owner];//Set charge ownership
					_charge setVectorDirAndUp [vectorDir _drone, vectorUp _drone];//Set charge direction
					_charge setVelocity (velocity _drone);//Set charge velocity
					_drone setDamage 1;//Destroy drone
				};
			}];
		};

		//Mine deployment drone - deploy AT mine
		case "C0I4": {
			//Save for later use
			_drone setVariable ["NWG_owner",_player];//Save locally
			_drone setVariable ["NWG_owner",_player,2];//Save on server

			//Replace container with mine deployment (kinda)
			_drone animateSource ["Utility_drone",0];
			_drone animateSource ["Antimine_drone",1];

			//Create visible attachments
			private _mineCount = NWG_MSHOP_SER_Settings get "MINE_DEPLOY_COUNT";
			private _attachTo = [0,0.025,0.035];
			private _attachStep = -0.075;
			private ["_visualObj"];
			for "_i" from 0 to (_mineCount-1) do {
				_visualObj = createSimpleObject ["\A3\Weapons_f\Explosives\mine_at",(getPosASL _drone)];
				_visualObj attachTo [_drone,(_attachTo vectorAdd [0,0,(_attachStep*_i)])];
				_visualObj setVectorDirAndUp [[1,4.37114e-08,-8.74228e-08],[-8.74228e-08,-8.74228e-08,1]];
			};

			//Disable regular drone functionality
			_drone setAutonomous false;
			_drone enableUAVWaypoints false;
			{_drone removeWeapon _x} forEach weapons _drone;

			//Setup destruction logic
			_drone addMPEventHandler ["MPKilled", {
				// params ["_unit", "_killer", "_instigator", "_useEffects"];
				params ["_drone"];
				removeAllActions _drone;
				if (isServer) then {
					_drone removeMPEventHandler [_thisEvent,_thisEventHandler];//Delete event handler
					{deleteVehicle _x} forEach (attachedObjects _drone);//Delete visual object
				};
			}];

			//Setup Mine deployment logic
			[_drone,"#MSHOP_C0I4_ActionTitle#",{_this remoteExec ["NWG_MSHOP_MineDeployment_Action",2]}] remoteExec ["NWG_fnc_addAction",0];
		};

		//Thunder EMI drone - create lightning with EMI effect
		case "C0I5": {
			//Save for later use
			_drone setVariable ["NWG_owner",_player];//Save locally (note different 'owner' variable notation - it is for 'NWG_fnc_moduleLightning'
			_drone setVariable ["NWG_owner",_player,2];//Save on server

			//Create visible attachment
			private _visualObj = createSimpleObject ["\a3\Weapons_F_Enoch\Pistols\ESD_01\ESD_01_F",(getPosASL _drone)];
			_visualObj attachTo [_drone,[0.023,-0.125,0.12]];
			_visualObj setVectorDirAndUp [[1,4.37114e-08,-8.74228e-08],[-8.74228e-08,-8.74228e-08,1]];

			//Disable regular drone functionality
			_drone setAutonomous false;
			_drone enableUAVWaypoints false;
			{_drone removeWeapon _x} forEach weapons _drone;

			//Setup destruction logic
			_drone addMPEventHandler ["MPKilled", {
				// params ["_unit", "_killer", "_instigator", "_useEffects"];
				params ["_drone"];
				removeAllActions _drone;
				if (isServer) then {
					_drone removeMPEventHandler [_thisEvent,_thisEventHandler];//Delete event handler
					{deleteVehicle _x} forEach (attachedObjects _drone);//Delete visual object
				};
			}];

			//Setup EMI logic
			[_drone,"#MSHOP_C0I5_ActionTitle#",{_this remoteExec ["NWG_MSHOP_EmiDrone_Action",2]}] remoteExec ["NWG_fnc_addAction",0];
		};

		//Bomber and Ababil drones - delete once they're used their ammo
		case "C0I6";
		case "C0I7": {
			_drone setVariable ["NWG_MSHOP_owner",_player];//Save locally
			_drone setVariable ["NWG_MSHOP_owner",_player,2];//Save on server

			_drone addEventHandler ["Fired",{_this call NWG_MSHOP_BomberDrone_FiredDeletion}];//Setup fired-based deletion (+ projectile ownership)
			_drone call NWG_MSHOP_BomberDrone_TimerDeletion;//Setup delay-based deletion (in case fired event will not work)
		};

		default {};//Do nothing
	};

	//Set drone ownership
	_player connectTerminalToUAV _drone;

	//return
	true
};

NWG_MSHOP_MineDeployment_Action = {
	// params ["_target", "_caller", "_actionId", "_arguments"];
	params ["_drone"];
	private _owner = _drone getVariable ["NWG_owner",objNull];
	private _mineDeployHeight = NWG_MSHOP_SER_Settings get "MINE_DEPLOY_HEIGHT";

	//Get lowest mock mine attached to the drone
	private _mineMocks = (attachedObjects _drone);
	if ((count _mineMocks) == 0) exitWith {};
	reverse _mineMocks;//Get last added mine
	private _mineFakeObj = _mineMocks deleteAt 0;
	if (isNil "_mineFakeObj") then {
		"NWG_MSHOP_MineDeployment_Action: No mine fake object" call NWG_fnc_logError;
		_mineFakeObj = objNull;
	};

	//Get placement position
	private _thisASL = if (!isNull _mineFakeObj)
		then {getPosASL _mineFakeObj}
		else {getPosASL _drone};
	private _raycast = lineIntersectsSurfaces [_thisASL,(_thisASL vectorAdd [0,0,-_mineDeployHeight]),_drone,_mineFakeObj,true,1,"GEOM","NONE"];
	if ((count _raycast) == 0) exitWith {
		if (isNull _owner || {!alive _owner}) exitWith {};
		"#MSHOP_C0I4_ActionTooHigh#" remoteExec ["NWG_fnc_systemChatMe",_owner];
	};

	//Delete mock mine
	if (!isNull _mineFakeObj) then {
		detach _mineFakeObj;
		deleteVehicle _mineFakeObj;
	};

	//Create real
	(_raycast select 0) params ["_intersectPos","_intersectNormal"];
	private _mine = createMine ["ATMine",(ASLToAGL _intersectPos),[],0];
	_mine setVectorUp _intersectNormal;
	if (!isNull _owner) then {
		_mine setShotParents [_owner,_owner];
	};

	//Delete drone if no mines are left
	if ((count _mineMocks) <= 0) then {
		_drone spawn {
			// private _drone = _this;
			sleep (NWG_MSHOP_SER_Settings get "MINE_DEPLOY_DRONE_DELETE_DELAY");
			deleteVehicle _this;
		};
	};
};

NWG_MSHOP_EmiDrone_Action = {
	// params ["_target", "_caller", "_actionId", "_arguments"];
	params ["_drone"];
	private _radius = NWG_MSHOP_SER_Settings get "EMI_RADIUS";
	private _minDamage = NWG_MSHOP_SER_Settings get "EMI_DAMAGE_MIN";
	private _maxDamage = NWG_MSHOP_SER_Settings get "EMI_DAMAGE_MAX";

	//Disable nearby lights
	{
		private _hitIndexArray = [];
		for "_i" from 0 to (count ((getAllHitPointsDamage _x) param [0,[]]) -1) do {
			_hitIndexArray pushBack _i;
			_hitIndexArray pushBack _maxDamage;
		};
		[_x,_hitIndexArray] call NWG_fnc_setHitIndex;
	} forEach (nearestObjects [_drone,["Lamps_base_F","PowerLines_base_F","PowerLines_Small_base_F"],_radius]);

	//Harm nearby vehicles
	private _droneOwner = _drone getVariable ["NWG_owner",objNull];
	private _targetedParts = NWG_MSHOP_SER_Settings get "EMI_TARGETS";
	private ["_vehicle","_parts","_damages","_hitIndexArray","_curPart","_newDmg"];
	{
		_vehicle = _x;
		(getAllHitPointsDamage _vehicle) params [["_parts",[]],"",["_damages",[]]];
		_hitIndexArray = [];

		for "_i" from 0 to ((count _parts) - 1) do {
			//Get part of the vehicle and check if it's targeted
			_curPart = _parts select _i;
			if ((_targetedParts findIf {_x in _curPart}) == -1) then {continue};

			//Calculate new damage to this part
			_newDmg = [(_damages#_i),1.2] call NWG_fnc_randomRangeFloat;//1.2 to increase chances of higher damage
			_newDmg = (_newDmg max _minDamage) min _maxDamage;//Clamp to settings

			//Add to hitIndex array
			_hitIndexArray pushBack _i;
			_hitIndexArray pushBack _newDmg;
		};

		//Apply new damage
		[_vehicle,_hitIndexArray,_droneOwner] call NWG_fnc_setHitIndex;
	} forEach (_drone nearEntities [["Car","Tank","Helicopter","Plane","Ship"],_radius] select {alive _x && {_x isNotEqualTo _drone}});

	//Play light and sound effects
	_drone call NWG_fnc_moduleLightning;
	_drone setDamage 1;
};

NWG_MSHOP_BomberDrone_FiredDeletion = {
	// params ["_unit","_weapon","_muzzle","_mode","_ammo","_magazine","_projectile","_gunner"];
	params ["_drone","_weapon","","","","","_projectile"];

	//Check if drone is still alive
	if (!alive _drone) exitWith {};

	//Check weapon validity
	_weapon = toLower _weapon;
	if ("laser" in _weapon || {"flare" in _weapon}) exitWith {};//Ignore lasers and flares

	//Setup projectile ownership
	private _owner = _drone getVariable ["NWG_MSHOP_owner",objNull];
	if (!isNull _owner) then {
		[_projectile,_owner] spawn {
			params ["_projectile","_owner"];
			sleep 1;
			if (alive _projectile) then {_projectile setShotParents [_owner,_owner]};
		};
	};

	//Check if drone still has some ammo left
	private _hasMags = ((magazinesAmmo [_drone,false]) findIf {(_x#1 > 0) && {!("Laser" in _x#0)}}) != -1;
	if (_hasMags) exitWith {};//Drone still has some ammo left - do nothing

	//Start counting down delay
	[_drone,_projectile] spawn {
		params ["_drone","_projectile"];

		waitUntil {sleep 0.5; !alive _projectile};//Wait until projectile is hit
		sleep (NWG_MSHOP_SER_Settings get "BOMBER_DELETE_DELAY");
		if (!alive _drone) exitWith {};
		"NWG_MSHOP_BomberDrone_FiredDeletion: Deleting drone" call NWG_fnc_logInfo;
		objNull remoteControl _drone;
		deleteVehicle _drone;
	};
};

NWG_MSHOP_BomberDrone_deletionHandle = scriptNull;
NWG_MSHOP_BomberDrone_deletionQueue = [];
NWG_MSHOP_BomberDrone_TimerDeletion = {
	// private _drone = _this;
	NWG_MSHOP_BomberDrone_deletionQueue pushBack _this;
	if (isNull NWG_MSHOP_BomberDrone_deletionHandle || {scriptDone NWG_MSHOP_BomberDrone_deletionHandle}) then {
		NWG_MSHOP_BomberDrone_deletionHandle = [] spawn NWG_MSHOP_BomberDrone_TimerDeletion_Core;
	};
};
NWG_MSHOP_BomberDrone_TimerDeletion_Core = {
	waitUntil {
		//Wait for delay
		sleep (NWG_MSHOP_SER_Settings get "BOMBER_DELETE_CHECK_INTERVAL");

		//Check all drones
		{
			//Check if drone is still alive
			if (!alive _x) then {
				NWG_MSHOP_BomberDrone_deletionQueue deleteAt _forEachIndex;
				continue;
			};

			//Check if drone is marked for deletion
			if (_x getVariable ["NWG_MSHOP_markedForDeletion",false]) then {
				"NWG_MSHOP_BomberDrone_TimerDeletion_Core: Deleting drone" call NWG_fnc_logInfo;
				NWG_MSHOP_BomberDrone_deletionQueue deleteAt _forEachIndex;
				objNull remoteControl _x;
				deleteVehicle _x;
				continue;
			};

			//Check if drone has any ammo left - mark for deletion on next iteration
			private _hasMags = ((magazinesAmmo [_x,false]) findIf {(_x#1 > 0) && {!("Laser" in _x#0)}}) != -1;
			if (!_hasMags) then {
				_x setVariable ["NWG_MSHOP_markedForDeletion",true];
			};
		} forEachReversed NWG_MSHOP_BomberDrone_deletionQueue;

		//Exit condition
		(count NWG_MSHOP_BomberDrone_deletionQueue) == 0
	};
};

//================================================================================================================
//================================================================================================================
//Mortar fire
//Rework of 'BIS_fnc_fireSupportVirtual'
NWG_MSHOP_SER_FireMortar = {
	params ["_player","_itemName","_pos"];

	private _mortarSettings = (NWG_MSHOP_SER_Settings get "MORTAR_SETTINGS") get _itemName;
	if (isNil "_mortarSettings") exitWith {
		(format ["NWG_MSHOP_SER_FireMortar: No settings found for item: '%1'",_itemName]) call NWG_fnc_logError;
		false
	};

	[_player,_mortarSettings,_pos] spawn {
		params ["_player","_mortarSettings","_pos"];
		_mortarSettings params ["_ammoType","_radius","_count","_beforeDelay","_inBetweenDelay","_altitude","_velocity","_sound"];

		//Prepare settings read function ([min,max] -> single value)
		private _toSingleValueInt = {
			if (_this isEqualType 1) then {_this} else {_this call NWG_fnc_randomRangeInt};
		};
		private _toSingleValueFloat = {
			if (_this isEqualType 1) then {_this} else {_this call NWG_fnc_randomRangeFloat};
		};

		//Delay before first shot
		sleep (_beforeDelay call _toSingleValueFloat);

		//Fire loop
		private _fireCount = _count call _toSingleValueInt;
		private ["_firePos","_shell"];
		while {_fireCount > 0} do {
			_firePos = _pos getPos [((sqrt random 1) * _radius),(random 360)];
			_firePos set [2,(_altitude call _toSingleValueFloat)];
			_shell = _ammoType createVehicle _firePos;
			_shell setVectorUp [0,0,(if (_velocity > 0) then {-1} else {1})];
			_shell setVelocity [0,0,-_velocity];
			if (!isNil "_sound" && {_sound isNotEqualTo ""})
				then {playSound3D [_sound,_shell]};
			if (!isNull _player)
				then {_shell setShotParents [_player,_player]};

			_fireCount = _fireCount - 1;
			sleep (_inBetweenDelay call _toSingleValueFloat);
		};
	};

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Infantry support
NWG_MSHOP_SER_SpawnInfSupport = {
	params ["_player","_itemName","_targetPos"];

	//Spawn group
	private _units = _this call (NWG_MSHOP_SER_Settings get "FUNC_SPAWN_INF_GROUP");
	if (isNil "_units" || {!(_units isEqualType []) || {(count _units) == 0}}) exitWith {
		(format ["NWG_MSHOP_SER_SpawnInfSupport: Failed to spawn group with args: '%1'",_this]) call NWG_fnc_logError;
		false
	};

	//Dress AA unit(s)
	private _aaUnit = NWG_MSHOP_SER_Settings get "UNITS_AA_UNIT";
	{
		private _newLoadout = [
			["SMG_03C_TR_black","","","",["50Rnd_570x28_SMG_03",50],[],""],
			["launch_I_Titan_F","","","",["Titan_AA",1],[],""],
			nil,nil,nil,
			["B_Kitbag_rgr",[["Titan_AA",2,1],["50Rnd_570x28_SMG_03",3,50]]]
			,nil,nil,nil,nil
		];
		[_x,_newLoadout] call NWG_fnc_setUnitLoadout;
	} forEach (_units select {(typeOf _x) isEqualTo _aaUnit});

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Vehicle request
NWG_MSHOP_SER_OnVehicleBought = {
	params ["_player","_vehicleClassname","_pos"];

	//Place marker
	(NWG_MSHOP_SER_Settings get "VEHICLE_MARKER_SETTING") params ["_markerType","_markerColor"];
	[_pos,_markerType,_markerColor] call NWG_MSHOP_SER_PlaceMarker;

	//Spawn vehicle
	private _vehicle = _this call (NWG_MSHOP_SER_Settings get "FUNC_SPAWN_VEHICLE");
	if (isNil "_vehicle" || {_vehicle isEqualTo false || {isNull _vehicle}}) exitWith {
		(format ["NWG_MSHOP_SER_OnVehicleBought: Failed to spawn vehicle with args: '%1'",_this]) call NWG_fnc_logError;
		false
	};

	//Connect vehicle to player
	(group _player) addVehicle _vehicle;
	[_vehicle,_player] call NWG_fnc_vownSetOwner;

	//Clear vehicle cargo
	_vehicle call NWG_fnc_clearContainerCargo;

	//Create AI crew for UAVs
	if (unitIsUAV _vehicle) then {
		(side (group _player)) createVehicleCrew _vehicle;
	};

	//return
	true
};

//================================================================================================================
//================================================================================================================
//Markers logic
NWG_MSHOP_SER_placedMarkers = [];
NWG_MSHOP_SER_PlaceMarker = {
	params ["_pos","_markerType","_markerColor"];

	//Create marker
	private _markerName = format ["NWG_MSHOP_SER_marker_%1",time];
	private _marker = createMarkerLocal [_markerName,_pos];
    _marker setMarkerShapeLocal "icon";
    _marker setMarkerTypeLocal _markerType;
    _marker setMarkerColor _markerColor;//Set color + make global, see: https://community.bistudio.com/wiki/createMarker

	//Add to list
	NWG_MSHOP_SER_placedMarkers pushBack _marker;

	//Remove outdated
	private _preserveCount = NWG_MSHOP_SER_Settings get "MARKER_PRESERVE_COUNT";
	if (_preserveCount < 1) then {
		(format ["NWG_MSHOP_SER_PlaceMarker: MARKER_PRESERVE_COUNT is less than 1: '%1', fix your settings",_preserveCount]) call NWG_fnc_logError;
		_preserveCount = 1;
	};
	while {(count NWG_MSHOP_SER_placedMarkers) > _preserveCount} do {
		deleteMarker (NWG_MSHOP_SER_placedMarkers deleteAt 0);
	};
};

//================================================================================================================
//================================================================================================================
call _Init;