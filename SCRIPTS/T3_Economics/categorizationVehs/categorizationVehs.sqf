#include "..\..\globalDefines.h"

//Get vehicle type
NWG_VCAT_GetVehcType_cache = createHashMapFromArray [
    ["B_AFV_Wheeled_01_cannon_F",LOOT_VEHC_TYPE_TANK],//Rhino is definetly too powerful for APCs
    ["B_AFV_Wheeled_01_up_cannon_F",LOOT_VEHC_TYPE_TANK]//Rhino is definetly too powerful for APCs
];
NWG_VCAT_GetVehcType = {
    private _veh = _this;
    if (_veh isEqualType objNull) then {_veh = typeOf _veh};

    //Check cache
    private _cached = NWG_VCAT_GetVehcType_cache get _veh;
    if (!isNil "_cached") exitWith {_cached};

    //We will use the editor categories to determine the vehicle type
    private _vehcType = switch (getText (configFile >> "CfgVehicles" >> _veh >> "editorSubCategory")) do {
        case "EdSubcat_AAs":          {LOOT_VEHC_TYPE_AAIR};
        case "EdSubcat_APCs":         {LOOT_VEHC_TYPE_APCS};
        case "EdSubcat_Artillery":    {LOOT_VEHC_TYPE_ARTY};
        case "EdSubcat_Boats":        {LOOT_VEHC_TYPE_BOAT};
        case "EdSubcat_Cars":         {LOOT_VEHC_TYPE_CARS};
        case "EdSubcat_Drones":       {LOOT_VEHC_TYPE_DRON};
        case "EdSubcat_Helicopters":  {LOOT_VEHC_TYPE_HELI};
        case "EdSubcat_Planes":       {LOOT_VEHC_TYPE_PLAN};
        case "EdSubcat_Submersibles": {LOOT_VEHC_TYPE_SUBM};
        case "EdSubcat_Tanks":        {LOOT_VEHC_TYPE_TANK};
        default {
            (format ["NWG_VCAT_GetVehcType: Unknown vehicle type: '%1' with subcat: '%2'",
                _veh, getText (configFile >> "CfgVehicles" >> _veh >> "editorSubCategory")]) call NWG_fnc_logError;
            LOOT_VEHC_TYPE_CARS//Default to cars
        };
    };

    //Cache and return
    NWG_VCAT_GetVehcType_cache set [_veh,_vehcType];
    _vehcType
};

//BIS_fnc_baseVehicle (reworked)
NWG_VCAT_GetBaseVehicle_cache = createHashMap;
NWG_VCAT_GetBaseVehicle = {
    private _input = _this;

    //Check cache
    private _cached = NWG_VCAT_GetBaseVehicle_cache get _input;
    if (!isNil "_cached") exitWith {_cached};

    //Check if it's a vehicle
    private _cfg = configFile >> "CfgVehicles" >> _input;
    if !(isClass _cfg) exitWith {
        NWG_VCAT_GetBaseVehicle_cache set [_input,_input];
        _input
    };//Not a vehicle

    //Get base vehicle
    private _base = getText (_cfg >> "baseVehicle");
    if (isClass (configFile >> "CfgVehicles" >> _base)) exitWith {
        NWG_VCAT_GetBaseVehicle_cache set [_input,_base];
        _base
    };//Base vehicle found

    //Deeper search
    private _return = _input;
    private _model = getText (_cfg >> "model");
    {
        if ((gettext (_x >> "model")) isEqualTo _model && {(getnumber (_x >> "scope")) == 2}) then {_return = configname _x};
    } foreach (_cfg call BIS_fnc_returnParents);

    //Cache and return
    NWG_VCAT_GetBaseVehicle_cache set [_input,_return];
    _return
};


//Get unified classname
NWG_VCAT_GetUnifiedClassname_cache = createHashMapFromArray [
    ["I_C_Boat_Transport_02_F","I_C_Boat_Transport_02_F"]/*Exception: B_G_... class exists, but is hidden, that breaks getting its picture for shop UI*/
];
NWG_VCAT_GetUnifiedClassname = {
	private _input = _this;

    //Check cache
    private _cached = NWG_VCAT_GetUnifiedClassname_cache get _input;
    if (!isNil "_cached") exitWith {_cached};

	//Get base classname for the vehicle and disassemble it for analysis
	private _classname =_this call NWG_VCAT_GetBaseVehicle;
	private _classnameParts = _classname splitString "_";
	if ((count _classnameParts) < 2) exitWith {
		(format ["NWG_VCAT_GetUnifiedClassname: Invalid classname '%1'",_classname]) call NWG_fnc_logError;
        NWG_VCAT_GetUnifiedClassname_cache set [_input,_input];
		_input
	};

	//Get variables for further analysis
	private _prefix1 = _classnameParts#0;
	private _prefix2 = _classnameParts#1;
	private _doublePrefix = ((count _prefix2) == 1) || {_prefix2 isEqualTo "IDAP"};
	private _body = if (_doublePrefix)
		then {_classnameParts select [2]} /*select [2:]*/
		else {_classnameParts select [1]};/*select [1:]*/

	//Check if we already dealing with BLUFOR standard vehicle
	if (_prefix1 isEqualTo "B" && !_doublePrefix) exitWith {
        NWG_VCAT_GetUnifiedClassname_cache set [_input,_classname];
        _classname
    };

    //Try getting unified classname of whatever faction it is now
    if (_doublePrefix) then {
        private _tempBody = _body + [];
        _tempBody deleteAt (_tempBody find "ghex");//CSAT pacific

        private _newClassname = ([_prefix1] + _tempBody) joinString "_";
        if (isClass (configFile >> "CfgVehicles" >> _newClassname)) then {
            _body = _tempBody;
            _classname = _newClassname;
        };
    };

	//Try converting to BLUFOR
	private _newClassname = (["B"] + _body) joinString "_";
	if (isClass (configFile >> "CfgVehicles" >> _newClassname)) exitWith {
        NWG_VCAT_GetUnifiedClassname_cache set [_input,_newClassname];
        _newClassname
    };

	//Try converting to BLUFOR guerilla
	_newClassname = (["B","G"] + _body) joinString "_";
	if (isClass (configFile >> "CfgVehicles" >> _newClassname)) exitWith {
        NWG_VCAT_GetUnifiedClassname_cache set [_input,_newClassname];
        _newClassname
    };

	//Return original name or original within its faction (if were able to convert)
    NWG_VCAT_GetUnifiedClassname_cache set [_input,_classname];
	_classname
};