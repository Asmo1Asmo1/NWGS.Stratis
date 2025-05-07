//================================================================================================================
//Settings
NWG_KOSTYLI_Settings = createHashMapFromArray [
	["LOG_WHEN_TRIGGERED",true],

	["UNIT_UNSTUCK_ENABLED",true],
	["UNIT_UNSTUCK_ANIMATIONS",["acinpknlmstpsraswrfldnon"]],
	["UNIT_UNSTUCK_TO_ANIMATION","amovPknlMstpSrasWrflDnon"],
	["UNIT_UNSTUCK_TIME",5],

	["UNDG_HOLDER_DELETION_ENABLED",true],
	["UNDG_HOLDER_DELETION_TIME",5],
	["UNDG_HOLDER_DELETION_IF_LOWER",-0.5],

	["VEH_UNSTUCK_ENABLED",true],
	["VEH_UNSTUCK_INTERVAL",3],

	["",0]
];

//================================================================================================================
//Init
private _Init = {
	addMissionEventHandler ["EntityCreated",{_this call NWG_KOSTYLI_OnCreated}];
	addMissionEventHandler ["EntityKilled",{_this call NWG_KOSTYLI_OnKilled}];
};

//================================================================================================================
//Event handlers
NWG_KOSTYLI_OnCreated = {
	params [["_object",objNull]];
	if (isNull _object) exitWith {};

	if (_object isKindOf "Man") exitWith {
		if (NWG_KOSTYLI_Settings get "UNIT_UNSTUCK_ENABLED") then {
			_object call NWG_KOSTYLI_CheckUnitUnstuck;
		};
	};

	if ((["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {_object isKindOf _x}) > 0) exitWith {
		if (NWG_KOSTYLI_Settings get "VEH_UNSTUCK_ENABLED") then {
			_object call NWG_KOSTYLI_AddToVehUnstuck;
		};
	};
};

NWG_KOSTYLI_OnKilled = {
	// params [["_obj",objNull],["_killer",objNull],["_instigator",objNull]/*,"_useEffects"*/];
	params [["_object",objNull]];
	if (isNull _object) exitWith {};
	if !(_object isKindOf "Man") exitWith {};

	if (NWG_KOSTYLI_Settings get "UNDG_HOLDER_DELETION_ENABLED" && {isNull (objectParent _object)}) then {
		_object call NWG_KOSTYLI_CheckHolder;
	};
};

//================================================================================================================
//Unstuck units animation
NWG_KOSTYLI_unitUnstuckList = [];
NWG_KOSTYLI_unitUnstuckCore = scriptNull;
NWG_KOSTYLI_CheckUnitUnstuck = {
	// private _unit = _this;
	NWG_KOSTYLI_unitUnstuckList pushBack [_this,(time + (NWG_KOSTYLI_Settings get "UNIT_UNSTUCK_TIME"))];
	if (isNull NWG_KOSTYLI_unitUnstuckCore || {scriptDone NWG_KOSTYLI_unitUnstuckCore}) then {
		NWG_KOSTYLI_unitUnstuckCore = [] spawn NWG_KOSTYLI_CheckUnitUnstuck_Core;
	};
};
NWG_KOSTYLI_CheckUnitUnstuck_Core = {
	private _stuckAnimations = NWG_KOSTYLI_Settings get "UNIT_UNSTUCK_ANIMATIONS";
	private _toAnimation = NWG_KOSTYLI_Settings get "UNIT_UNSTUCK_TO_ANIMATION";
	private _log = NWG_KOSTYLI_Settings get "LOG_WHEN_TRIGGERED";
	waitUntil {
		sleep 0.5;
		if ((count NWG_KOSTYLI_unitUnstuckList) == 0) exitWith {true};
		{
			_x params ["_unit","_time"];
			if (isNull _unit || {!alive _unit}) then {NWG_KOSTYLI_unitUnstuckList deleteAt _forEachIndex; continue};//Drop deleted objects
			if (time < _time) then {continue};//Time has not come yet
			NWG_KOSTYLI_unitUnstuckList deleteAt _forEachIndex;//Delete object from queue

			if ((vehicle _unit) isNotEqualTo _unit) then {continue};//Skip units in vehicles
			if !((animationState _unit) in _stuckAnimations) then {continue};//Unstuck not required

			[_unit,_toAnimation] call NWG_fnc_playAnimGlobal;//Play unstuck animation
			if (_log) then {(format ["NWG_KOSTYLI_CheckUnitUnstuck_Core: Unstuck animation triggered for '%1'",_unit]) call NWG_fnc_logInfo};//Log
		} forEachReversed NWG_KOSTYLI_unitUnstuckList;
		false//Go to new iteration
	};
};

//================================================================================================================
//Delete weapon holders gone underground
NWG_KOSTYLI_holderCheckList = [];
NWG_KOSTYLI_holderCheckCore = scriptNull;
NWG_KOSTYLI_CheckHolder = {
	// private _unit = _this;
	NWG_KOSTYLI_holderCheckList pushBack [_this,(time + (NWG_KOSTYLI_Settings get "UNDG_HOLDER_DELETION_TIME"))];
	if (isNull NWG_KOSTYLI_holderCheckCore || {scriptDone NWG_KOSTYLI_holderCheckCore}) then {
		NWG_KOSTYLI_holderCheckCore = [] spawn NWG_KOSTYLI_CheckHolder_Core;
	};
};
NWG_KOSTYLI_CheckHolder_Core = {
	private _threshold = NWG_KOSTYLI_Settings get "UNDG_HOLDER_DELETION_IF_LOWER";
	private _log = NWG_KOSTYLI_Settings get "LOG_WHEN_TRIGGERED";
	waitUntil {
		sleep 0.5;
		if ((count NWG_KOSTYLI_holderCheckList) == 0) exitWith {true};
		{
			_x params ["_unit","_time"];
			if (isNull _unit) then {NWG_KOSTYLI_holderCheckList deleteAt _forEachIndex; continue};//Drop deleted objects
			if (time < _time) then {continue};//Time has not come yet
			NWG_KOSTYLI_holderCheckList deleteAt _forEachIndex;//Delete object from queue
			if (!isNull (objectParent _unit)) then {continue};//Skip units in vehicles

			private _holders = (getCorpseWeaponholders _unit) select {!isNull _x};
			if ((count _holders) == 0) then {continue};//No holders found

			{
				deleteVehicle _x;
				if (_log) then {(format ["NWG_KOSTYLI_CheckHolder_Core: Holder deleted for '%1'",_unit]) call NWG_fnc_logInfo};//Log
			} forEach (_holders select {((getPosATL _x)#2) <= _threshold});
		} forEachReversed NWG_KOSTYLI_holderCheckList;
		false//Go to new iteration
	};
};

//================================================================================================================
//Veh unstuck logic
NWG_KOSTYLI_vehUnstuckList = [];
NWG_KOSTYLI_vehUnstuckCore = scriptNull;
NWG_KOSTYLI_AddToVehUnstuck = {
	// private _vehicle = _this;
	if (isNull _this || {!alive _this}) exitWith {};//Prevent adding dead targets
	if (unitIsUAV _this) exitWith {};//UAVs are not supported
	NWG_KOSTYLI_vehUnstuckList pushBackUnique _this;
	if (isNull NWG_KOSTYLI_vehUnstuckCore || {scriptDone NWG_KOSTYLI_vehUnstuckCore}) then {
		NWG_KOSTYLI_vehUnstuckCore = [] spawn NWG_KOSTYLI_VehUnstuck_Core;
	};
};

NWG_KOSTYLI_VehUnstuck_Core = {
	private ["_crew","_group","_oldPos","_newPos","_cnt"];
	private _updatePos = {
		params ["_target","_newPos"];
		_target setVariable ["NWG_KOSTYLI_unstuckPos",_newPos];
		_target setVariable ["NWG_KOSTYLI_unstuckCnt",0];
	};

	//Pre-validity checks
	sleep (NWG_KOSTYLI_Settings get "VEH_UNSTUCK_INTERVAL");
	{
		if (isNull _x || {
			!alive _x || {
			unitIsUAV _x || {
			_x call NWG_fnc_gcIsOriginalObject}}}
		) then {
			NWG_KOSTYLI_vehUnstuckList deleteAt _forEachIndex;
		};
	} forEachReversed NWG_KOSTYLI_vehUnstuckList;

	//Main loop
	waitUntil {
		//Wait
		sleep (NWG_KOSTYLI_Settings get "VEH_UNSTUCK_INTERVAL");

		//Process list
		{
			//Validity checks
			if (isNull _x || {!alive _x}) then {NWG_KOSTYLI_vehUnstuckList deleteAt _forEachIndex; continue};//Remove dead targets

			//Crew checks
			_crew = crew _x;
			if ((count _crew) == 0) then {continue};//Skip empty targets (target may be occupied later by AI)
			if ((_crew findIf {alive _x && {isPlayer _x}}) != -1) then {NWG_KOSTYLI_vehUnstuckList deleteAt _forEachIndex; continue};//Remove targets occupied by players

			//Group checks
			_group = group _x;
			if (isNull _group) then {continue};//Skip targets without group
			if ((count (waypoints _group)) < 2) then {continue};//Skip targets without waypoints assigned

			//Movement checks
			_oldPos = _x getVariable "NWG_KOSTYLI_unstuckPos";
			_newPos = getPosASL _x;
			if (isNil "_oldPos") then {[_x,_newPos] call _updatePos; continue};//Save first position
			if ((_newPos distance _oldPos) > 1) then {[_x,_newPos] call _updatePos; continue};//Target is moving

			//Count unstuck attempts
			_cnt = _x getVariable ["NWG_KOSTYLI_unstuckCnt",0];
			_x setVariable ["NWG_KOSTYLI_unstuckCnt",(_cnt + 1)];
			if (_cnt == 0) then {continue};

			//Reload crew (sometimes helps to 'clear' their brains)
			if ((_cnt % 3) == 0) then {
				private _veh = _x;
				private _crew = (crew _x) select {alive _x};
				_group leaveVehicle _veh;
				{_x disableCollisionWith _veh; _x moveOut _veh} forEach _crew;
				_veh engineOn true;
				_group addVehicle _veh;
				{_x moveInAny _veh; _x enableCollisionWith _veh} forEach _crew;
			};

			//'Unflip' vehicle if it's stuck for good
			if ((_cnt % 5) == 0) then {
				[_x] call BIS_fnc_unflipVehicle;
			};
		} forEachReversed NWG_KOSTYLI_vehUnstuckList;

		//Go to new iteration if there are still targets to unstuck
		(count NWG_KOSTYLI_vehUnstuckList) == 0
	};
};

//================================================================================================================
call _Init;