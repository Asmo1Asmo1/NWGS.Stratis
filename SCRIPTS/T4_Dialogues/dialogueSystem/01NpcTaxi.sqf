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
#define CAT_SQD "SQD"
#define CAT_VHC "VHC"
#define CAT_CMP "CMP"
#define CAT_AIR "AIR"

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLG_TAXI_Settings = createHashMapFromArray [
	/*Min drop distance*/
	["MIN_DIST_SQD",100],
	["MIN_DIST_VHC",100],
	["MIN_DIST_CMP",100],
	// ["MIN_DIST_AIR",100],//Not applicable

	/*Prices*/
	["PRICE_SQD_RAW",1000],
	["PRICE_SQD_KM",500],
	["PRICE_VHC_RAW",1000],
	["PRICE_VHC_KM",500],
	["PRICE_CMP_RAW",500],
	["PRICE_CMP_KM",100],
	["PRICE_AIR_RAW",5000],

	/*Teleportation*/
	["UNIT_RADIUS",5],
	["VHCL_RADIUS",7],
	["PARADROP_ALTITUDE",1500],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Global variables
NWG_DLG_TAXI_SelectedCat = "";
NWG_DLG_TAXI_SelectedItem = "";

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["MapSingleClick",{_this call NWG_DLG_TAXI_OnMapClick}];
};

//================================================================================================================
//================================================================================================================
//Dialogue answers generation
NWG_DLG_TAXI_GenerateDropCategories = {
	private _categories = [];

	_categories pushBack ["#TAXI_CAT_SQD#","TAXI_PS",{NWG_DLG_TAXI_SelectedCat = CAT_SQD}];
	_categories pushBack ["#TAXI_CAT_VHC#","TAXI_PS",{NWG_DLG_TAXI_SelectedCat = CAT_VHC}];
	_categories pushBack ["#TAXI_CAT_CMP#","TAXI_PS",{NWG_DLG_TAXI_SelectedCat = CAT_CMP}];
	_categories pushBack ["#TAXI_CAT_AIR#","TAXI_PAY",{NWG_DLG_TAXI_SelectedCat = CAT_AIR}];

	//return
	_categories
};

NWG_DLG_TAXI_GenerateDropPoints = {
	private _dropPoints = switch (NWG_DLG_TAXI_SelectedCat) do {
		case CAT_SQD: {
			private _minDist = NWG_DLG_TAXI_Settings get "MIN_DIST_SQD";
			private _squadMembers = (units (group player)) - [player];
			_squadMembers = _squadMembers select {
				alive _x && {
				(player distance _x) >= _minDist}
			};
			_squadMembers apply {[
				(name _x),
				"TAXI_PAY",
				{NWG_DLG_TAXI_SelectedItem = _this}
			]}
		};
		case CAT_VHC: {
			private _minDist = NWG_DLG_TAXI_Settings get "MIN_DIST_VHC";
			private _ownedVehicles = player call NWG_fnc_vownGetOwnedVehicles;
			_ownedVehicles = _ownedVehicles select {
				alive _x && {
				!unitIsUAV _x && {
				(player distance _x) >= _minDist}}
			};
			_ownedVehicles apply {[
				(getText ((configOf _x) >> "displayName")),
				"TAXI_PAY",
				{NWG_DLG_TAXI_SelectedItem = _this}
			]}
		};
		case CAT_CMP: {
			private _campMarkers = allMapMarkers select {"PlayerCamp" in _x};
			_campMarkers apply {[
				(trim (markerText _x)),
				"TAXI_PAY",
				{NWG_DLG_TAXI_SelectedItem = _this}
			]}
		};
		case CAT_AIR: {
			//Not applicable, should not get here
			"NWG_DLG_TAXI_GenerateDropPoints: CAT_AIR should not be used in this context" call NWG_fnc_logError;
			[]
		};
		default {
			(format ["NWG_DLG_TAXI_GenerateDropPoints: Invalid category: %1",NWG_DLG_TAXI_SelectedCat]) call NWG_fnc_logError;
			[]
		};
	};

	if ((count _dropPoints) == 0) then {
		NWG_DLG_TAXI_SelectedCat = "";
		NWG_DLG_TAXI_SelectedItem = "";
		_dropPoints pushBack ["#TAXI_NO_DROP_POINTS#","TAXI_CS"];
	};

	//return
	_dropPoints
};

//================================================================================================================
//================================================================================================================
//Prices (+for dialogue question format)
NWG_DLG_TAXI_lastPrice = [];
NWG_DLG_TAXI_GetPrice = {
	private _cat = NWG_DLG_TAXI_SelectedCat;
	private _item = NWG_DLG_TAXI_SelectedItem;

	//Check cached result
	NWG_DLG_TAXI_lastPrice params [["_prevCat",""],["_prevItem",""],["_prevTime",0],["_prevPrice",0]];
	if (_prevCat isEqualTo _cat && {_prevItem isEqualTo _item && {(time - _prevTime) < 0.25}}) exitWith {_prevPrice};

	//Calculate price
	private _price = switch (_cat) do {
		case CAT_SQD: {
			private _units = units (group player);
			private _i = _units findIf {(name _x) isEqualTo _item};
			if (_i == -1) exitWith {NWG_DLG_TAXI_Settings get "PRICE_SQD_RAW"};//Nasty situation, but we will filter it out later
			//return
			((((round ((player distance (_units#_i)) / 1000))) * (NWG_DLG_TAXI_Settings get "PRICE_SQD_KM")) + (NWG_DLG_TAXI_Settings get "PRICE_SQD_RAW"))
		};
		case CAT_VHC: {
			private _vehicles = player call NWG_fnc_vownGetOwnedVehicles;
			private _i = _vehicles findIf {(getText ((configOf _x) >> "displayName")) isEqualTo _item};
			if (_i == -1) exitWith {NWG_DLG_TAXI_Settings get "PRICE_VHC_RAW"};//Nasty situation, but we will filter it out later
			//return
			((((round ((player distance (_vehicles#_i)) / 1000))) * (NWG_DLG_TAXI_Settings get "PRICE_VHC_KM")) + (NWG_DLG_TAXI_Settings get "PRICE_VHC_RAW"))
		};
		case CAT_CMP: {
			private _campMarkers = allMapMarkers select {"PlayerCamp" in _x};
			private _i = _campMarkers findIf {(trim (markerText _x)) isEqualTo _item};
			if (_i == -1) exitWith {NWG_DLG_TAXI_Settings get "PRICE_CMP_RAW"};//Nasty situation, but we will filter it out later
			//return
			((((round ((player distance (getMarkerPos (_campMarkers#_i))) / 1000))) * (NWG_DLG_TAXI_Settings get "PRICE_CMP_KM")) + (NWG_DLG_TAXI_Settings get "PRICE_CMP_RAW"))
		};
		case CAT_AIR: {
			NWG_DLG_TAXI_Settings get "PRICE_AIR_RAW"
		};
	};

	//Cache result
	NWG_DLG_TAXI_lastPrice = [_cat,_item,time,_price];

	//return
	_price
};

//================================================================================================================
//================================================================================================================
//Teleportation
#define TTYPE_FAIL 0
#define TTYPE_UNIT 1
#define TTYPE_VHCL 2
#define TTYPE_POS 3
#define TTYPE_AIR 4
NWG_DLG_TAXI_Teleport = {
	private _cat = NWG_DLG_TAXI_SelectedCat;
	private _item = NWG_DLG_TAXI_SelectedItem;
	private _price = call NWG_DLG_TAXI_GetPrice;

	//Get actual object or position to teleport to
	private _teleportTo = switch (_cat) do {
		case CAT_SQD: {
			private _units = units (group player);
			private _i = _units findIf {(name _x) isEqualTo _item};
			if (_i == -1) exitWith {[TTYPE_FAIL,-1]};
			private _unit = _units#_i;
			private _veh = vehicle _unit;
			if (_veh isEqualTo _unit)
				then{[TTYPE_UNIT,_unit]}
				else{[TTYPE_VHCL,_veh]}
		};
		case CAT_VHC: {
			private _vehicles = player call NWG_fnc_vownGetOwnedVehicles;
			private _i = _vehicles findIf {(getText ((configOf _x) >> "displayName")) isEqualTo _item};
			if (_i == -1) exitWith {[TTYPE_FAIL,-1]};
			private _veh = _vehicles#_i;
			if (!alive _veh) exitWith {[TTYPE_FAIL,-1]};
			[TTYPE_VHCL,_veh]
		};
		case CAT_CMP: {
			private _campMarkers = allMapMarkers select {"PlayerCamp" in _x};
			private _i = _campMarkers findIf {(trim (markerText _x)) isEqualTo _item};
			if (_i == -1) exitWith {[TTYPE_FAIL,-1]};
			private _camp = getMarkerPos [(_campMarkers#_i),true];
			[TTYPE_POS,_camp]
		};
		case CAT_AIR: {
			[TTYPE_AIR,-1]
		};
		default {
			(format ["NWG_DLG_TAXI_Teleport: Invalid category: %1",_cat]) call NWG_fnc_logError;
			[TTYPE_FAIL,-1]
		};
	};

	//Based on selected destination
	_teleportTo params [["_tType",TTYPE_FAIL],["_target",-1]];
	switch (_tType) do {
		case TTYPE_FAIL: {
			"#TAXI_INV_DROP_POINT#" call NWG_fnc_systemChatMe;//Failed
		};
		case TTYPE_UNIT;
		case TTYPE_POS: {
			private _radius = NWG_DLG_TAXI_Settings get "UNIT_RADIUS";
			if (player setVehiclePosition [_target,[],_radius,"NONE"])
				then {[player,-_price] call NWG_fnc_wltAddPlayerMoney}
				else {"#TAXI_INV_DROP_POINT#" call NWG_fnc_systemChatMe};
		};
		case TTYPE_VHCL: {
			private _radius = NWG_DLG_TAXI_Settings get "VHCL_RADIUS";
			if (player moveInAny _target)
				exitWith {[player,-_price] call NWG_fnc_wltAddPlayerMoney};
			if (player setVehiclePosition [_target,[],_radius,"NONE"])
				exitWith {[player,-_price] call NWG_fnc_wltAddPlayerMoney};
			"#TAXI_INV_DROP_POINT#" call NWG_fnc_systemChatMe;
		};
		case TTYPE_AIR: {
			//Deplete money
			[player,-_price] call NWG_fnc_wltAddPlayerMoney;

			//Force open map
			NWG_DLG_TAXI_mapClickExpected = true;
			if ( (((getUnitLoadout player) param [9,[]]) param [0,""]) isEqualTo "")
				then {player addItem "ItemMap"; player assignItem "ItemMap"};
			openMap [true,true];
			hint ("#TAXI_PARADROP_HINT#" call NWG_fnc_localize);//Show hint
			//To be continued in map click handler 'NWG_DLG_TAXI_OnMapClick'....
		};
	};
};

//================================================================================================================
//================================================================================================================
//Paradrop
NWG_DLG_TAXI_mapClickExpected = false;
NWG_DLG_TAXI_OnMapClick = {
	// params ["_units","_pos","_alt","_shift"];
	private _pos = _this select 1;

	//Check flag
	if (!NWG_DLG_TAXI_mapClickExpected) exitWith {};
	NWG_DLG_TAXI_mapClickExpected = false;

	//Close map
	openMap [true,false];
	openMap false;
	// hintSilent "";

	//Teleport
	_pos set [2,(NWG_DLG_TAXI_Settings get "PARADROP_ALTITUDE")];
	player setPosATL _pos;
};

//================================================================================================================
//================================================================================================================
call _Init