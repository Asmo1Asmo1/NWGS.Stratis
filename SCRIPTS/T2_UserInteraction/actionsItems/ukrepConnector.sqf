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

	//return
	_buildResult isNotEqualTo false
};