#define ADOPT_MAX_ATTEMPTS 100
#define ADOPT_DELAY 1

NWG_MSHOP_DSC_AdoptUnits = {
	private _units = _this;
	if (isNil "_units" || {(count _units) == 0}) exitWith {};
	if (canSuspend) then {sleep ADOPT_DELAY};
	private ["_conditionDone","_adoptionAction","_operationName"];

	//Adopt units into player's group
	_conditionDone = {local _this && {_this in (units (group player))}};
	_adoptionAction = {[_this] joinSilent (group player)};
	_operationName = "Move into player's group";
	_units = [_units,_adoptionAction,_conditionDone,_operationName] call NWG_MSHOP_DSC_AdoptionCore;
	if (count _units == 0) exitWith {};

	//Restore captive state
	_conditionDone = {!captive _this && {(side _this) isEqualTo (side (group player))}};
	_adoptionAction = {_this setCaptive false; [_this] joinSilent (group player)};
	_operationName = "Restore captive state";
	_units = [_units,_adoptionAction,_conditionDone,_operationName] call NWG_MSHOP_DSC_AdoptionCore;
};

NWG_MSHOP_DSC_AdoptionCore = {
	params ["_unitsArray","_adoptionAction","_conditionDone","_operationName"];
	private _attempts = ADOPT_MAX_ATTEMPTS;
	private _resultArray = [];

	waitUntil {
		_attempts = _attempts - 1;
		if (_attempts <= 0) exitWith {true};
		if (canSuspend) then {sleep ADOPT_DELAY};

		//iterate through units
		{
			//Check if unit is dead - remove from list
			if (!alive _x) then {
				_unitsArray deleteAt _forEachIndex;
				continue;
			};
			//Check condition done
			if (_x call _conditionDone) then {
				_resultArray pushBack _x;
				_unitsArray deleteAt _forEachIndex;
				continue;
			};
			//Apply action
			_x call _adoptionAction;
		} forEachReversed _unitsArray;

		//Exit when done
		(count _unitsArray) == 0
	};
	if (_attempts <= 0) then {
		(format ["NWG_MSHOP_DSC_AdoptionCore: Attempts limit reached on '%1' operation",_operationName]) call NWG_fnc_logError;
	};

	//return
	_resultArray
};