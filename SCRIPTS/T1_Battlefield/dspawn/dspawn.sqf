//================================================================================================================
//================================================================================================================
//Spawn system
NWG_DSPAWN_SpawnVehicledGroup = {
    params  ["_vehicleClassname","_unitClassnames","_pos","_dir",
            ["_vehicleAppearance", false],["_vehiclePylons", false],["_deferReveal", false],["_side", west]];

    private _vehicle = [_vehicleClassname,_pos,_dir,_vehicleAppearance,_vehiclePylons,_deferReveal] call NWG_fnc_spwnSpawnVehicleAround;
    private _units = [_unitClassnames,_vehicle,_side] call NWG_fnc_spwnSpawnUnitsIntoVehicle;
    private _group = group (_units#0);

    //return
    [_group,_vehicle,_units]
};

//================================================================================================================
//================================================================================================================
//TAGs system
NWG_DSPAWN_GetTags = {
    // private _group = _this;
    //return
    _this getVariable ["NWG_DSPAWN_tags",[]]
};

NWG_DSPAWN_SetTags = {
    params ["_group","_tags"];
    _group setVariable ["NWG_DSPAWN_tags",_tags];
};

NWG_DSPAWN_GenerateTags = {
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
        if ((count (_grpVehicle call NWG_DSPAWN_GetVehicleWeapons)) > 0)
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

NWG_DSPAWN_notWeapon = ["Horn","Laserdesignator","CMFlareLauncher","SmokeLauncher"];
NWG_DSPAWN_GetVehicleWeapons = {
    // private _vehicle = _this;
    private _weaponName = "";
    private _weapons = [];

    //do
    {
        //do
        {
            _weaponName = _x;
            if ((NWG_DSPAWN_notWeapon findIf {_x in _weaponName}) == -1) then {_weapons pushBackUnique _weaponName};
        } forEach (_this weaponsTurret _x);//Foreach weapons of the turret
    } forEach ((fullCrew [_this,"",true]) apply {_x#3});//Foreach turrets of the vehicle

    //return
    _weapons
};