/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Reminder: Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
*/
NWG_DLG_MECH_PricesRequest = {
	params ["_vehArray","_player"];
	if (isNull _player) exitWith {};
	private _prices = _vehArray apply {_x call NWG_VSHOP_SER_EvaluateVeh};//Inner method of 'shopVehiclesServerSide.sqf'
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
	params ["_cat","_vehObj"];
	switch (_cat) do {
		case CAT_FUEL: {_vehObj setFuel 1};
		case CAT_RARM: {_vehObj setVehicleAmmoDef 1};
	};
};
