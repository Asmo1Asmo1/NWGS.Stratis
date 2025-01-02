#include "..\..\globalDefines.h"

NWG_AI_UC_CampDeploy = {
	// private _playerObject = _this;

	private _buildResult = [
		"RelCamps",
		_this,
		/*rootType:*/OBJ_TYPE_UNIT,
		/*blueprintFilter:*/"",
		/*chances:*/[],
		/*faction:*/"",
		/*groupRules:*/[/*membership:*/"AGENT",/*dynamic simulation:*/true],
		/*adaptToGround:*/true,
		/*suppressEvent*/true
	] call NWG_fnc_ukrpBuildAroundObject;
	if (_buildResult isEqualTo false) exitWith {false};

	/*Taxi connector inject*/
	// [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
	private _campFire = (_buildResult select OBJ_CAT_DECO) select {(typeOf _x) isEqualTo "Land_Campfire_F"};
	if (_campFire isEqualTo []) exitWith {
		"NWG_AI_UC_CampDeploy: Could not find campfire object" call NWG_fnc_logError;
		true/*Still return 'true' because this functionality is optional*/
	};
	_campFire = _campFire select 0;
	_campFire spawn NWG_AI_TC_SetupCampFire;//Setup campfire in a separate coroutine

	//return
	true
};