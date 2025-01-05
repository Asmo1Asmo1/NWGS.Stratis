//================================================================================================================
//Settings
NWG_KOSTYLI_Settings = createHashMapFromArray [
	["LOG_WHEN_TRIGGERED",true],

	["UNSTUCK_ENABLED",true],
	["UNSTUCK_ANIMATIONS",["acinpknlmstpsraswrfldnon"]],
	["UNSTUCK_TO_ANIMATION","amovPknlMstpSrasWrflDnon"],
	["UNSTUCK_TIME",5],

	["HOLDER_ENABLED",true],
	["HOLDER_TIME",5],
	["HOLDER_DELETE_IF_LOWER_THAN",-0.5],

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
	if !(_object isKindOf "Man") exitWith {};

	if (NWG_KOSTYLI_Settings get "UNSTUCK_ENABLED") then {
		_object call NWG_KOSTYLI_CheckUnstuck;
	};
};

NWG_KOSTYLI_OnKilled = {
    // params [["_obj",objNull],["_killer",objNull],["_instigator",objNull]/*,"_useEffects"*/];
	params [["_object",objNull]];
    if (isNull _object) exitWith {};
	if !(_object isKindOf "Man") exitWith {};

	if (NWG_KOSTYLI_Settings get "HOLDER_ENABLED" && {isNull (objectParent _object)}) then {
		_object call NWG_KOSTYLI_CheckHolder;
	};
};

//================================================================================================================
//Unstuck units animation
NWG_KOSTYLI_unstuckQueue = [];
NWG_KOSTYLI_unstuckCore = scriptNull;
NWG_KOSTYLI_CheckUnstuck = {
    // private _unit = _this;
	NWG_KOSTYLI_unstuckQueue pushBack [_this,(time + (NWG_KOSTYLI_Settings get "UNSTUCK_TIME"))];
	if (isNull NWG_KOSTYLI_unstuckCore || {scriptDone NWG_KOSTYLI_unstuckCore}) then {
		NWG_KOSTYLI_unstuckCore = [] spawn NWG_KOSTYLI_CheckUnstuck_Core;
	};
};
NWG_KOSTYLI_CheckUnstuck_Core = {
	private _stuckAnimations = NWG_KOSTYLI_Settings get "UNSTUCK_ANIMATIONS";
	private _toAnimation = NWG_KOSTYLI_Settings get "UNSTUCK_TO_ANIMATION";
	private _log = NWG_KOSTYLI_Settings get "LOG_WHEN_TRIGGERED";
    waitUntil {
		sleep 0.5;
		if ((count NWG_KOSTYLI_unstuckQueue) == 0) exitWith {true};
		{
			_x params ["_unit","_time"];
			if (isNull _unit || {!alive _unit}) then {NWG_KOSTYLI_unstuckQueue deleteAt _forEachIndex; continue};//Drop deleted objects
			if (time < _time) then {continue};//Time has not come yet
			NWG_KOSTYLI_unstuckQueue deleteAt _forEachIndex;//Delete object from queue

			if ((vehicle _unit) isNotEqualTo _unit) then {continue};//Skip units in vehicles
			if !((animationState _unit) in _stuckAnimations) then {continue};//Unstuck not required

			[_unit,_toAnimation] call NWG_fnc_playAnimGlobal;//Play unstuck animation
			if (_log) then {(format ["NWG_KOSTYLI_CheckUnstuck_Core: Unstuck animation triggered for '%1'",_unit]) call NWG_fnc_logInfo};//Log
		} forEachReversed NWG_KOSTYLI_unstuckQueue;
		false//Go to new iteration
    };
};

//================================================================================================================
//Delete weapon holders gone underground
NWG_KOSTYLI_holderCheckQueue = [];
NWG_KOSTYLI_holderCore = scriptNull;
NWG_KOSTYLI_CheckHolder = {
    // private _unit = _this;
	NWG_KOSTYLI_holderCheckQueue pushBack [_this,(time + (NWG_KOSTYLI_Settings get "HOLDER_TIME"))];
	if (isNull NWG_KOSTYLI_holderCore || {scriptDone NWG_KOSTYLI_holderCore}) then {
		NWG_KOSTYLI_holderCore = [] spawn NWG_KOSTYLI_CheckHolder_Core;
	};
};
NWG_KOSTYLI_CheckHolder_Core = {
	private _threshold = NWG_KOSTYLI_Settings get "HOLDER_DELETE_IF_LOWER_THAN";
	private _log = NWG_KOSTYLI_Settings get "LOG_WHEN_TRIGGERED";
    waitUntil {
		sleep 0.5;
		if ((count NWG_KOSTYLI_holderCheckQueue) == 0) exitWith {true};
		{
			_x params ["_unit","_time"];
			if (isNull _unit) then {NWG_KOSTYLI_holderCheckQueue deleteAt _forEachIndex; continue};//Drop deleted objects
			if (time < _time) then {continue};//Time has not come yet
			NWG_KOSTYLI_holderCheckQueue deleteAt _forEachIndex;//Delete object from queue
			if (!isNull (objectParent _unit)) then {continue};//Skip units in vehicles

			private _holders = (getCorpseWeaponholders _unit) select {!isNull _x};
			if ((count _holders) == 0) then {continue};//No holders found

			{
				deleteVehicle _x;
				if (_log) then {(format ["NWG_KOSTYLI_CheckHolder_Core: Holder deleted for '%1'",_unit]) call NWG_fnc_logInfo};//Log
			} forEach (_holders select {((getPosATL _x)#2) <= _threshold});
		} forEachReversed NWG_KOSTYLI_holderCheckQueue;
		false//Go to new iteration
    };
};

//================================================================================================================
call _Init;