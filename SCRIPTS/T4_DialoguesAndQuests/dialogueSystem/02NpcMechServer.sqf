/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
*/
NWG_DLG_MECH_PricesRequest = {
	params ["_vehArray","_player"];
	if (isNull _player) exitWith {};
	private _prices = _vehArray apply {_x call NWG_fnc_vshopEvaluateVehPrice};
	[_vehArray,_prices] remoteExec ["NWG_DLG_MECH_OnVehPriceResponse",_player];
};

//Defines
// #define CAT_REPR "REPR"
#define CAT_FUEL "FUEL"
#define CAT_RARM "RARM"
// #define CAT_APPR "APPR"
// #define CAT_PYLN "PYLN"
// #define CAT_AWHL "AWHL"
//Copy of NWG_DLG_MECH_LocalService to be available on server side
NWG_DLG_MECH_LocalService = {
	params ["_cat","_veh"];
	switch (_cat) do {
		case CAT_FUEL: {_veh setFuel 1};
		case CAT_RARM: {_veh setVehicleAmmoDef 1};
	};
};
