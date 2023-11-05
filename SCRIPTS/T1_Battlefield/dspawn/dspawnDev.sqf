#include "dspawnDefines.h"

/*
    Annotation:
    Group structure follows the format:
    [
        ["TAGS"], TIER,
        ["VEH_CLASSNAME",[APPEARANCE],[PYLONS]],
        ["UNIT_CLASSNAMES"],
        {ADDITIONAL_CODE}
    ]

    Note: Every group gets Weapon tag 'REG' as there is no means to define it automatically, edit it manually if needed
    Note: Every number value in appearance means 0-1 probability, you can set it to 0.5 to get 50/50 chance for each item
    Note: UNIT_CLASSNAMES is a shortened format, example: ["class1",2,"class2"] that will be uncomacted into ["class1","class2","class2"] by dspawn logic
    Note: ADDITIONAL_CODE will recieve 'params ["_group","_vehicle","_units"]'
*/

//================================================================================================================
//================================================================================================================
//Group description gathering
NWG_DSPAWN_Dev_EasyGather = {
    (group player) call NWG_DSPAWN_Dev_Gather;
};

NWG_DSPAWN_Dev_Gather = {
    private _group = _this;
    private _grpVehicle = vehicle (leader _group);

    //Gather group tags
    private _tags = _group call NWG_DSPAWN_Dev_GenerateTags;

    //Gather default group tier
    private _tier = 1;

    //Gather group's units
    private _unitsDescr = ((units _group) apply {typeOf _x}) call NWG_DSPAWN_Dev_CompactStringArray;

    //Exit if group is infantry (no vehicle)
    if ("INF" in _tags) exitWith {
        [_tags,_tier,false,_unitsDescr] call NWG_DSPAWN_Dev_Dump
    };

    //Gather group's vehicle values
    private _vehClassname = typeOf _grpVehicle;
    private _maxPassengers = {isNull (_x#0)} count (fullCrew [_vehicle,"",true]);

    //Enrich the _unitsDescr with amount of random passengers
    if (_maxPassengers > 0) then {
        _unitsDescr pushBack _maxPassengers;
        _unitsDescr pushBack "RANDOM";
    };

    //Create default second vehicle to compare its appearance and pylons with the first one
    private _defaultVehicle = createVehicle [_vehClassname, (ASLToATL [100,100,1000])];

    //Gather appearance info
    private _vehicleAppearance = _grpVehicle call NWG_fnc_spwnGetVehicleAppearance;
    private _defaultAppearance = _defaultVehicle call NWG_fnc_spwnGetVehicleAppearance;
    private _appearance = if (_vehicleAppearance isEqualTo _defaultAppearance) then {false} else {_vehicleAppearance};

    //Gather pylons info
    private _vehiclePylons = _grpVehicle call NWG_fnc_spwnGetVehiclePylons;
    private _defaultPylons = _defaultVehicle call NWG_fnc_spwnGetVehiclePylons;
    private _pylons = if (_vehiclePylons isEqualTo _defaultPylons) then {false} else {_vehiclePylons};

    //Delete default vehicle
    deleteVehicle _defaultVehicle;

    //Form vehicle description
    private _vehDescr = [_vehClassname];
    if (_appearance isNotEqualTo false || _pylons isNotEqualTo false) then {
        _vehDescr pushBack _appearance;
        _vehDescr pushBack _pylons;
    };

    //return
    [_tags,_tier,_vehDescr,_unitsDescr] call NWG_DSPAWN_Dev_Dump
};

NWG_DSPAWN_Dev_Dump = {
    params ["_tags","_tier","_vehDescr","_unitsDescr"];

    //Form lines of text
    private _lines = [
        "[",
        (format ["    %1,%2,",_tags,_tier]),
        (format ["    %1,",_vehDescr]),
        (format ["    %1",_unitsDescr]),
        "],"
    ];

    //Dump to RPT
    diag_log text "==========[DSPANW GROUP GATHERED DATA]===========";
    {diag_log (text _x)} forEach _lines;
    diag_log text "==========[           END            ]===========";

    //Dump to clipboard
    copyToClipboard (_lines joinString (toString [13,10]));//Copy with 'new line' separator

    //Dump to output console
    _this
};

//================================================================================================================
//================================================================================================================
//TAGs system
NWG_DSPAWN_Dev_GenerateTags = {
    // private _group = _this;

    private _grpVehicle = vehicle (leader _this);
    private _simulationType = tolower (getText(configFile >> "CfgVehicles" >> (typeOf _grpVehicle) >> "simulation"));

    //Prime tags -
    private _tags = switch (_simulationType) do {
        case "soldier": {["INF"]};
        case "carx":    {["VEH"]};
        case "tankx":   {["ARM"]};
        case "airplanex";
        case "helicopterrtd";
        case "helicopterx": {["AIR"]};
        case "shipx":   {["BOAT"]};
        default         {["VEH"]};
    };

    //Vehicle tags -
    if (!("INF" in _tags)) then {
        if ((count (_grpVehicle call NWG_DSPAWN_Dev_GetVehicleWeapons)) > 0)
            then {_tags pushBack "MEC"}
            else {_tags pushBack "MOT"};
    };

    //Air tags -
    if ("AIR" in _tags) then {
        switch (_simulationType) do {
            case "airplanex": {_tags pushBack "PLANE"};
            case "helicopterrtd";
            case "helicopterx": {_tags pushBack "HELI"};
        };
    };

    //Weapon tags -
    //I have not a slightest idea on how to automatically determinate that
    _tags pushBack "REG";

    //Vehicle logic -
    if ("VEH" in _tags) then {
        //If vehicle is light enough - it can be paradropped
        if  ((getMass _grpVehicle) < 10000) then {_tags pushBack "PARADROPPABLE+"};
    };

    //Air logic -
    if ("AIR" in _tags) then {
        //If there can be passengers - vehicle can disembark them
        if ((count (fullCrew [_grpVehicle,"cargo",true])) > 0) then {
            if ("HELI" in _tags) then {_tags pushBack "LAND+"};
            _tags pushBack "PARA+";
        };

        //If there are pylons - vehicle can do airstrike
        if ((count (getPylonMagazines _grpVehicle)) > 0) then {_tags pushBack "AIRSTRIKE+"};
    };

    //return
    _tags
};

NWG_DSPAWN_Dev_notWeapon = ["Horn","Laserdesignator","CMFlareLauncher","SmokeLauncher"];
NWG_DSPAWN_Dev_GetVehicleWeapons = {
    // private _vehicle = _this;
    private _weaponName = "";
    private _weapons = [];

    //do
    {
        //do
        {
            _weaponName = _x;
            if ((NWG_DSPAWN_Dev_notWeapon findIf {_x in _weaponName}) == -1) then {_weapons pushBackUnique _weaponName};
        } forEach (_this weaponsTurret _x);//Foreach weapons of the turret
    } forEach ((fullCrew [_this,"",true]) apply {_x#3});//Foreach turrets of the vehicle

    //return
    _weapons
};

//================================================================================================================
//================================================================================================================
//String array
NWG_DSPAWN_Dev_CompactStringArray = {
    // private _array = _this;
    private _result = [];

    //do
    {
        _i = _result find _x;
        if (_i == -1) then {
            _result pushBack 1;
            _result pushBack _x;
        } else {
            _result set [(_i-1),((_result#(_i-1))+1)];
        };
    } forEach _this;

    _this resize 0;
    _this append (_result - [1]);

    //return
    _this
};