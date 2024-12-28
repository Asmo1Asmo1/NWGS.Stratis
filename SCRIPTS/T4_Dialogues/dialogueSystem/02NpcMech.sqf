/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Reminder: Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
*/

//================================================================================================================
//================================================================================================================
//Defines
#define CAT_REPR "REPR"
#define CAT_FUEL "FUEL"
#define CAT_RARM "RARM"
#define CAT_APPR "APPR"
#define CAT_PYLN "PYLN"
#define CAT_AWHL "AWHL"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLG_MECH_Settings = createHashMapFromArray [
	/*Distance where service is available*/
	["MAX_DIST",100],

	/*Prices*/
	["PRICE_REPIR_DEFAULT",10000],
	["PRICE_REPIR_MULTIPLIER",0.75],//Final price = (vehPrice * damage) * multiplier | Acts as discount
	["PRICE_REFEL",1000],
	["PRICE_REARM",2500],
	["PRICE_APRNC",2500],
	["PRICE_PYLON",5000],
	["PRICE_ALWHL",5000],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_DLG_MECH_SelectedCategory = "";
NWG_DLG_MECH_SelectedVehicle = "";

//================================================================================================================
//================================================================================================================
//Open the shop
NWG_DLG_MECH_OpenShop = {
	call NWG_fnc_vshopOpenPlatformShop
};

//================================================================================================================
//================================================================================================================
//Answers generation
NWG_DLG_MECH_GenerateChoices = {
	private _cat = _this;
	private _vehicles = switch (_cat) do {
		case CAT_REPR: {call NWG_DLG_MECH_GetRepairableVehicles};
		case CAT_FUEL: {call NWG_DLG_MECH_GetRefuelableVehicles};
		case CAT_RARM: {call NWG_DLG_MECH_GetRearmableVehicles};
		case CAT_APPR: {call NWG_DLG_MECH_GetAppearanceVehicles};
		case CAT_PYLN: {call NWG_DLG_MECH_GetPylonableVehicles};
		case CAT_AWHL: {call NWG_DLG_MECH_GetAllWheelableVehicles};
	};
	if ((count _vehicles) == 0) exitWith {[["#MECH_NO_VEHICLES#","MECH_01"]]};

	/*Inject getting vehicle prices here*/
	if (_cat isEqualTo CAT_REPR) then {
		[(_vehicles apply {typeOf _x}),player] remoteExec ["NWG_DLG_MECH_PricesRequest",2];
	};

	NWG_DLG_MECH_SelectedCategory = _cat;
	_vehicles apply {[
		(getText ((configOf _x) >> "displayName")),
		"MECH_PAY",
		{NWG_DLG_MECH_SelectedVehicle = _this}
	]};
};

//================================================================================================================
//================================================================================================================
//Prices
NWG_DLG_MECH_vehPrices = createHashMap;
NWG_DLG_MECH_OnVehPriceResponse = {
	params ["_vehArray","_prices"];
	{
		NWG_DLG_MECH_vehPrices set [_x,(_prices select _forEachIndex)];
	} forEach _vehArray;
};

NWG_DLG_MECH_lastPrice = [];
NWG_DLG_MECH_GetPrice = {
	private _cat = NWG_DLG_MECH_SelectedCategory;
	private _veh = NWG_DLG_MECH_SelectedVehicle;

	//Check cached result
	NWG_DLG_MECH_lastPrice params [["_prevCat",""],["_prevVeh",""],["_prevTime",0],["_prevPrice",0]];
	if (_prevCat isEqualTo _cat && {_prevVeh isEqualTo _veh && {(time - _prevTime) < 0.25}}) exitWith {_prevPrice};

	//Calculate price
	private _price = switch (_cat) do {
		case CAT_REPR: {
			//Get actual vehicle (only for this category)
			private _vehObj = [(call NWG_DLG_MECH_GetRepairableVehicles),_veh] call NWG_DLG_MECH_GetSpecificVehicle;
			private _vehPrice = NWG_DLG_MECH_vehPrices getOrDefault [(typeOf _vehObj),(NWG_DLG_MECH_Settings get "PRICE_REPIR_DEFAULT")];
			private _damage = _vehObj call NWG_VSHOP_CLI_GetDamageOfOwnedVehicle;
			private _multiplier = NWG_DLG_MECH_Settings get "PRICE_REPIR_MULTIPLIER";
			private _repPrice = ((_vehPrice * _damage) * _multiplier);
			_repPrice = (round (_repPrice / 100)) * 100;//Round to nearest 100
			(_repPrice max 100)
		};
		case CAT_FUEL: {NWG_DLG_MECH_Settings get "PRICE_REFEL"};
		case CAT_RARM: {NWG_DLG_MECH_Settings get "PRICE_REARM"};
		case CAT_APPR: {NWG_DLG_MECH_Settings get "PRICE_APRNC"};
		case CAT_PYLN: {NWG_DLG_MECH_Settings get "PRICE_PYLON"};
		case CAT_AWHL: {NWG_DLG_MECH_Settings get "PRICE_ALWHL"};
	};

	//Cache result
	NWG_DLG_MECH_lastPrice = [_cat,_veh,time,_price];

	//return
	_price
};

NWG_DLG_MECH_GetPriceStr = {
	((call NWG_DLG_MECH_GetPrice) call NWG_fnc_wltFormatMoney)
};

//================================================================================================================
//================================================================================================================
//Services
NWG_DLG_MECH_DoService = {
	//Get selection and price
	private _cat = NWG_DLG_MECH_SelectedCategory;
	private _veh = NWG_DLG_MECH_SelectedVehicle;
	private _price = call NWG_DLG_MECH_GetPrice;

	//Get actual vehicle object
	private _vehArray = switch (_cat) do {
		case CAT_REPR: {call NWG_DLG_MECH_GetRepairableVehicles};
		case CAT_FUEL: {call NWG_DLG_MECH_GetRefuelableVehicles};
		case CAT_RARM: {call NWG_DLG_MECH_GetRearmableVehicles};
		case CAT_APPR: {call NWG_DLG_MECH_GetAppearanceVehicles};
		case CAT_PYLN: {call NWG_DLG_MECH_GetPylonableVehicles};
		case CAT_AWHL: {call NWG_DLG_MECH_GetAllWheelableVehicles};
	};
	private _vehObj = [_vehArray,_veh] call NWG_DLG_MECH_GetSpecificVehicle;
	if (isNull _vehObj) exitWith {
		"#MECH_INV_VEH#" call NWG_fnc_systemChatMe;
	};

	//Deplete player's money

	//Do service
	switch (_cat) do {
		case CAT_REPR: {
			[player,-_price] call NWG_fnc_wltAddPlayerMoney;
			_vehObj setDamage 0;//Global and reliable command, thank god
		};
		case CAT_FUEL;
		case CAT_RARM: {
			//Do service where the vehicle is local (hopefully)
			[player,-_price] call NWG_fnc_wltAddPlayerMoney;
			[_cat,_vehObj] remoteExec ["NWG_DLG_MECH_LocalService",_vehObj];
		};
		case CAT_APPR: {
			if (_vehObj call NWG_fnc_vcaOpen)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
		case CAT_PYLN: {
			if (_vehObj call NWG_fnc_vcpOpen)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
		case CAT_AWHL: {
			if (_vehObj call NWG_fnc_avAllWheelSign)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
	};
};

NWG_DLG_MECH_LocalService = {
	params ["_cat","_vehObj"];
	switch (_cat) do {
		case CAT_FUEL: {_vehObj setFuel 1};
		case CAT_RARM: {_vehObj setVehicleAmmoDef 1};
	};
};

//================================================================================================================
//================================================================================================================
//Services helpers
NWG_DLG_MECH_GetOwnedVehicles = {
	private _maxDist = NWG_DLG_MECH_Settings get "MAX_DIST";
	(player call NWG_fnc_vownGetOwnedVehicles) select {
		alive _x && {
		!unitIsUAV _x && {
		(player distance _x) <= _maxDist}}
	}
};
NWG_DLG_MECH_GetRepairableVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {(_x call NWG_VSHOP_CLI_GetDamageOfOwnedVehicle) > 0}//Inner method of 'shopVehiclesClientSide.sqf'
};
NWG_DLG_MECH_GetRefuelableVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {(fuel _x) < 0.95}
};
NWG_DLG_MECH_GetRearmableVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {(count (magazinesAmmo [_x,true])) > 0}
};
NWG_DLG_MECH_GetAppearanceVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {_x call NWG_fnc_vcaIsValid}
};
NWG_DLG_MECH_GetPylonableVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {_x call NWG_fnc_vcpIsValid}
};
NWG_DLG_MECH_GetAllWheelableVehicles = {
	(call NWG_DLG_MECH_GetOwnedVehicles) select {_x call NWG_fnc_avAllWheelIsSupported && {!(_x call NWG_fnc_avAllWheelIsSigned)}}
};
NWG_DLG_MECH_GetSpecificVehicle = {
	params ["_vehArray","_displayName"];
	private _i = _vehArray findIf {(getText ((configOf _x) >> "displayName")) isEqualTo _displayName};
	_vehArray param [_i,objNull]
};
