/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
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
	["PRICE_VEH_DEFAULT",10000],
	["PRICE_REPIR_MULTIPLIER",0.75],//Final price = (vehPrice * damage) * multiplier | Acts as discount
	["PRICE_PERCENTAGE",0.1],//Percentage of vehicle price to use as service price
	["PRICE_REFEL_DEFAULT",1000],
	["PRICE_REARM_DEFAULT",2500],
	["PRICE_APRNC_DEFAULT",2500],
	["PRICE_PYLON_DEFAULT",5000],
	["PRICE_ALWHL_DEFAULT",5000],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_DLG_MECH_SelectedCategory = "";
NWG_DLG_MECH_SelectedVehicle = objNull;

//================================================================================================================
//================================================================================================================
//Open shop/garage
NWG_DLG_MECH_OpenShop = {
	call NWG_fnc_vshopOpenPlatformShop
};

NWG_DLG_MECH_OpenGarage = {
	call NWG_fnc_grgOpen;
};


//================================================================================================================
//================================================================================================================
//Inject getting vehicle prices
NWG_DLG_MECH_vehPrices = createHashMap;
NWG_DLG_MECH_GetVehPrices = {
	private _vehicles = (player call NWG_fnc_vownGetOwnedVehicles) select {alive _x && {!unitIsUAV _x}};
	if ((count _vehicles) == 0) exitWith {};
	[(_vehicles apply {typeOf _x}),player] remoteExec ["NWG_DLG_MECH_VehPricesRequest",2];
};
NWG_DLG_MECH_OnVehPriceResponse = {
	params ["_vehArray","_prices"];
	{NWG_DLG_MECH_vehPrices set [_x,(_prices select _forEachIndex)]} forEach _vehArray;
};

//================================================================================================================
//================================================================================================================
//Answers generation
NWG_DLG_MECH_GenerateChoices = {
	private _cat = _this;

	private _maxDist = NWG_DLG_MECH_Settings get "MAX_DIST";
	private _vehicles = (player call NWG_fnc_vownGetOwnedVehicles) select {
		alive _x && {
		!unitIsUAV _x && {
		(player distance _x) <= _maxDist}}
	};
	_vehicles = switch (_cat) do {
		case CAT_REPR: {_vehicles select {(_x call NWG_VSHOP_CLI_GetDamageOfOwnedVehicle) > 0}};
		case CAT_FUEL: {_vehicles select {(fuel _x) < 0.95}};
		case CAT_RARM: {_vehicles select {(count (magazinesAmmo [_x,true])) > 0}};
		case CAT_APPR: {_vehicles select {_x call NWG_fnc_vcaIsValid}};
		case CAT_PYLN: {_vehicles select {_x call NWG_fnc_vcpIsValid}};
		case CAT_AWHL: {_vehicles select {_x call NWG_fnc_avAllWheelIsSupported && {!(_x call NWG_fnc_avAllWheelIsSigned)}}};
	};
	if ((count _vehicles) == 0) exitWith {[["#MECH_NO_VEHICLES#","MECH_SERV"]]};

	NWG_DLG_MECH_SelectedCategory = _cat;
	_vehicles apply {[
		(getText ((configOf _x) >> "displayName")),
		"MECH_PAY",
		{NWG_DLG_MECH_SelectedVehicle = _this},
		_x
	]};
};

//================================================================================================================
//================================================================================================================
//Prices
NWG_DLG_MECH_lastPrice = [];
NWG_DLG_MECH_GetPrice = {
	private _cat = NWG_DLG_MECH_SelectedCategory;
	private _veh = NWG_DLG_MECH_SelectedVehicle;

	//Check cached result
	NWG_DLG_MECH_lastPrice params [["_prevCat",""],["_prevVeh",""],["_prevTime",0],["_prevPrice",0]];
	if (_prevCat isEqualTo _cat && {_prevVeh isEqualTo _veh && {(time - _prevTime) < 0.25}}) exitWith {_prevPrice};

	//Calculate price
	private _vehPrice = NWG_DLG_MECH_vehPrices getOrDefault [(typeOf _veh),(NWG_DLG_MECH_Settings get "PRICE_VEH_DEFAULT")];
	private _price = if (_cat isEqualTo CAT_REPR) then {
		private _damage = _veh call NWG_VSHOP_CLI_GetDamageOfOwnedVehicle;//Inner method of 'shopVehiclesClientSide.sqf'
		private _multiplier = NWG_DLG_MECH_Settings get "PRICE_REPIR_MULTIPLIER";
		private _repPrice = ((_vehPrice * _damage) * _multiplier);
		_repPrice = (round (_repPrice / 100)) * 100;//Round to nearest 100
		(_repPrice max 100)//Charge at least 100
	} else {
		private _defaultPrice = switch (_cat) do {
			case CAT_FUEL: {NWG_DLG_MECH_Settings get "PRICE_REFEL_DEFAULT"};
			case CAT_RARM: {NWG_DLG_MECH_Settings get "PRICE_REARM_DEFAULT"};
			case CAT_APPR: {NWG_DLG_MECH_Settings get "PRICE_APRNC_DEFAULT"};
			case CAT_PYLN: {NWG_DLG_MECH_Settings get "PRICE_PYLON_DEFAULT"};
			case CAT_AWHL: {NWG_DLG_MECH_Settings get "PRICE_ALWHL_DEFAULT"};
		};
		private _calcPrice = _vehPrice * (NWG_DLG_MECH_Settings get "PRICE_PERCENTAGE");
		_calcPrice = (round (_calcPrice / 100)) * 100;//Round to nearest 100
		if (_calcPrice > _defaultPrice)
			then {_calcPrice}
			else {_defaultPrice};
	};

	//Cache result
	NWG_DLG_MECH_lastPrice = [_cat,_veh,time,_price];

	//return
	_price
};

//================================================================================================================
//================================================================================================================
//Services
NWG_DLG_MECH_SeparateUi = {
	NWG_DLG_MECH_SelectedCategory in [CAT_APPR,CAT_PYLN]
};

NWG_DLG_MECH_DoService = {
	private _updateMoney = _this;

	//Get selection and price
	private _cat = NWG_DLG_MECH_SelectedCategory;
	private _veh = NWG_DLG_MECH_SelectedVehicle;
	if (isNull _veh || {!(alive _veh)}) exitWith {
		"#MECH_INV_VEH#" call NWG_fnc_systemChatMe;
	};
	private _price = call NWG_DLG_MECH_GetPrice;

	switch (_cat) do {
		case CAT_REPR: {
			[player,-_price] call NWG_fnc_wltAddPlayerMoney;
			_veh setDamage 0;//Global and reliable command, thank god
		};
		case CAT_FUEL;
		case CAT_RARM: {
			//Do service where the vehicle is local (hopefully)
			[player,-_price] call NWG_fnc_wltAddPlayerMoney;
			[_cat,_veh] remoteExec ["NWG_DLG_MECH_LocalService",_veh];
		};
		case CAT_APPR: {
			if (_veh call NWG_fnc_vcaOpen)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
		case CAT_PYLN: {
			if (_veh call NWG_fnc_vcpOpen)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
		case CAT_AWHL: {
			if (_veh call NWG_fnc_avAllWheelSign)
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#MECH_INV_VEH#" call NWG_fnc_systemChatMe};
		};
	};

	if (_updateMoney) then {call NWG_DLGHLP_UI_UpdatePlayerMoney};
};

NWG_DLG_MECH_LocalService = {
	params ["_cat","_veh"];
	switch (_cat) do {
		case CAT_FUEL: {_veh setFuel 1};
		case CAT_RARM: {_veh setVehicleAmmoDef 1};
	};
};
