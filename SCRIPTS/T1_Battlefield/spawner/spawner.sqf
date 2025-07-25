//================================================================================================================
//================================================================================================================
//Spawning of a vehicle

NWG_SPWN_PrespawnVehicle = {
    params ["_classname","","_dir",["_appearance",false],["_pylons",false]];

    //Pre-spawn a default vehicle at a safe position
    private _safepos = call NWG_SPWN_GetSafePrespawnPos;
    private _vehicle = createVehicle [_classname,_safepos,[],0,"CAN_COLLIDE"];

    //Setup appearance and pylons
    if (_appearance isNotEqualTo false) then {[_vehicle,_appearance] call NWG_SPWN_SetVehicleAppearance};
    if (_pylons isNotEqualTo false) then {[_vehicle,_pylons] call NWG_SPWN_SetVehiclePylons};

    //Rotate and hide
    _vehicle setDir _dir;
    _vehicle call NWG_SPWN_Hide;

    //return
    _vehicle
};

//Spawn the vehicle with free space search around given position
NWG_SPWN_SpawnVehicleAround = {
    params ["_classname","_pos","_dir",["_appearance",false],["_pylons",false],["_deferReveal",false]];

    private _vehicle = _this call NWG_SPWN_PrespawnVehicle;
    [_vehicle,_pos] call NWG_SPWN_PlaceAround;
    if (!_deferReveal) then {_vehicle call NWG_SPWN_Reveal};

    //return
    _vehicle
};

//Spawn the vehicle at the given position
NWG_SPWN_SpawnVehicleExact = {
    params ["_classname","_pos","_dir",["_appearance",false],["_pylons",false],["_deferReveal",false]];

    private _vehicle = _this call NWG_SPWN_PrespawnVehicle;
    private _posATL = ASLToATL _pos;
    if ((_posATL#2) < 0.1) then {
        _posATL set [2,0];
        _vehicle setVehiclePosition [_posATL,[],0,"CAN_COLLIDE"];//Placement with attempt to avoid ground collision
    } else {
        _vehicle setPosASL _pos;//Just move it there
    };

    if (!_deferReveal) then {_vehicle call NWG_SPWN_Reveal};

    //return
    _vehicle
};

//================================================================================================================
//================================================================================================================
//Spawning of units

NWG_SPWN_PrespawnUnits = {
    params ["_classnames","",["_membership",west]];

    private _createGroupUnits = {
        params ["_group","_side"];
        private _unit = objNull;
        _classnames apply {
            _unit = _group createUnit [_x,(call NWG_SPWN_GetSafePrespawnPos),[],0,"CAN_COLLIDE"];
            //Fix units from other faction beign spawned into 'wrong' side (see: https://community.bistudio.com/wiki/createUnit)
            if ((side _unit) isNotEqualTo _side) then {[_unit] joinSilent _group};
            _unit
        }
    };

    private _units = switch (true) do {
        case (_membership isEqualType west): {
            //Side provided - create a new group for it
            private _group = createGroup [_membership,/*delete when empty:*/true];
            [_group,_membership] call _createGroupUnits
        };
        case (_membership isEqualType grpNull): {
            //Group provided - use it
            [_membership,(side _membership)] call _createGroupUnits
        };
        case (_membership isEqualTo "AGENT"): {
            //Agents requested (units with no group/side/behaviour)
            _classnames apply {createAgent [_x,(call NWG_SPWN_GetSafePrespawnPos),[],0,"CAN_COLLIDE"]}
        };
        default {
            //Invalid membership
            format ["NWG_SPWN_PrespawnUnits: Invalid membership provided: %1",_membership] call NWG_fnc_logError;
            //Fallback to default side
            private _group = createGroup [west,/*delete when empty:*/true];
            [_group,west] call _createGroupUnits
        };
    };

    //Part of fixing units falling on spawn
    {_x setVelocity [0,0,0]} forEach _units;

    //return
    _units
};

NWG_SPWN_FinalizeUnitsSpawn = {
    // private _units = _this;
    if ((count _this) == 0) exitWith {_this};

    //Delete default waypoint(s) if any
    private _group = group (_this#0);
    if !(isNull _group) then {
        for "_i" from ((count (waypoints _group)) - 1) to 0 step -1 do {
            deleteWaypoint [_group, _i];
        };
    };

    //return
    _this
};

//Spawn the group of units at given position
NWG_SPWN_SpawnUnitsAround = {
    params ["_classnames","_pos",["_membership",west]];
    private _units = _this call NWG_SPWN_PrespawnUnits;
    if ((count _units) == 0) exitWith {_units};

    //Carefully place the first unit of the group
    private _scout = _units#0;
    _scout setDir (random 360);
    [_scout,_pos] call NWG_SPWN_PlaceAround;

    //Move the rest of the group around the scout
    private "_u";
    for "_i" from 1 to ((count _units)-1) do {
        _u = _units#_i;
        _u setDir (random 360);
        _u setVehiclePosition [_scout,[],(count _units),"NONE"];
    };

    //return
    (_units call NWG_SPWN_FinalizeUnitsSpawn)
};

//Spawn the group of units into given vehicle
NWG_SPWN_SpawnUnitsIntoVehicle = {
    params ["_classnames","_vehicle",["_membership",west]];
    private _units = _this call NWG_SPWN_PrespawnUnits;
    if ((count _units) == 0) exitWith {_units};

    //Place units into vehicle
    private _group = group (_units#0);
    _group addVehicle _vehicle;
    {_x moveInAny _vehicle} forEach _units;

    //return
    (_units call NWG_SPWN_FinalizeUnitsSpawn)
};

//Spawn the group of units into given building
NWG_SPWN_SpawnUnitsIntoBuilding = {
    params ["_classnames","_building",["_membership",west]];
    private _units = _this call NWG_SPWN_PrespawnUnits;
    if ((count _units) == 0) exitWith {_units};

    //Place units into building
    private _buildingPositions = (_building buildingPos -1) call NWG_fnc_arrayShuffle;
    if ((count _buildingPositions) == 0) exitWith {"NWG_SPWN_SpawnUnitsIntoBuilding: No building positions found!" call NWG_fnc_logError};

    private _i = -1;
    private _getNextPos = {
        _i = (_i + 1) mod (count _buildingPositions);//Math hack. Testing confirms that it is working as expected
        _buildingPositions#_i
    };

    //do
    {
        _x setDir (random 360);
        _x setPosATL (call _getNextPos);
    } forEach _units;

    //return
    (_units call NWG_SPWN_FinalizeUnitsSpawn)
};

#define DATA_CLASSNAME 0
#define DATA_POSITION 1
#define DATA_DIRECTION 2
#define DATA_STANCE 3
NWG_SPWN_SpawnUnitsExact = {
    params ["_data",["_membership",west]];

    //Prespawn units
    private _units = [(_data apply {_x#DATA_CLASSNAME}),nil,_membership] call NWG_SPWN_PrespawnUnits;
    if ((count _units) == 0) exitWith {_units};

    //Place units
    private _stances = ["UP","UP","MIDDLE","DOWN"];
    private "_unit";
    {
        _unit = _units#_forEachIndex;
        _unit setDir (_x param [DATA_DIRECTION,0]);
        _unit setPosASL (_x param [DATA_POSITION,[0,0,0]]);
        _unit setUnitPos (_stances#(_x param [DATA_STANCE,0]));
    } forEach _data;

    //return
    (_units call NWG_SPWN_FinalizeUnitsSpawn)
};

//================================================================================================================
//================================================================================================================
//Placement utils
NWG_SPWN_PlaceAround = {
    params ["_object","_pos"];

    //Normalize placement height
    if ((_pos#2) < 0) then {_pos set [2,0]};

    //Get variables for check
    private _boundingBox = _object call NWG_SPWN_GetBoundingBox;
    private _isInAir = (_pos#2) > 0.3;
    private _isOnWater = surfaceIsWater _pos;
    private _isOnGround = !_isInAir && !_isOnWater;
    private _placementVar = [];
    private _isPlacementVarOnWater = false;
    private _place = if (_isOnGround && {!(_object isKindOf "Man")})
        then {{(_this#0) setVehiclePosition [(_this#1),[],0,"CAN_COLLIDE"]}}//Placement with attempt to avoid ground collision
        else {{(_this#0) setPosATL (_this#1)}};//Just move it there

    //Do iterations of attempts to place the object
    for "_r" from 0 to 50 step 1 do {
        _placementVar = _pos getPos [_r,(random 360)];
        _placementVar set [2,(_pos#2)];
        _isPlacementVarOnWater = surfaceIsWater _placementVar;

        if (!_isInAir && {_isOnWater != _isPlacementVarOnWater}) then {continue};//Check water/terrain consistency
        if (_isPlacementVarOnWater) then {_placementVar = ASLToATL _placementVar};//Convert Z coordinate if over water
        [_object,_placementVar] call _place;//Place the object

        //Check for collisions
        if ([_object,_boundingBox,_isOnGround] call NWG_SPWN_CollisionCheck) exitWith {};
    };

    //return
    _object
};

//================================================================================================================
//================================================================================================================
//Spawn utils
NWG_SPWN_GetSafePrespawnPos = {
    ASLToAGL [
        (round (random 500)),
        (round (random 500)),
        ((round (random 5000)) + 500)
    ]
};

NWG_SPWN_Hide = {
    _this enableSimulationGlobal false;
    _this hideObjectGlobal true;
};

NWG_SPWN_Reveal = {
    _this enableSimulationGlobal true;
    _this hideObjectGlobal false;
};

NWG_SPWN_GetBoundingBox = {
    // private _object = _this;

    //Get boundings
    private _bb = 0 boundingBoxReal _this;

    //Adjust
    private _minZ = (_bb#0)#2;
    private _maxZ = (_bb#1)#2;
    (_bb#1) set [2,(_maxZ - ((abs (_maxZ - _minZ))*0.15))];
    (_bb#0) set [2,(_minZ + ((((getPosATL _this)#2) + 0.1) - ((ASLToATL (_this modelToWorldWorld (_bb#0)))#2)))];

    //Return full bounding box as relative points to the model
    //return
    [
        [/*minX*/((_bb#0)#0),/*minY*/((_bb#0)#1),/*minZ*/(_bb#0)#2],
        [/*maxX*/((_bb#1)#0),/*minY*/((_bb#0)#1),/*minZ*/(_bb#0)#2],
        [/*maxX*/((_bb#1)#0),/*maxY*/((_bb#1)#1),/*minZ*/(_bb#0)#2],
        [/*minX*/((_bb#0)#0),/*maxY*/((_bb#1)#1),/*minZ*/(_bb#0)#2],

        [/*minX*/((_bb#0)#0),/*minY*/((_bb#0)#1),/*maxZ*/(_bb#1)#2],
        [/*maxX*/((_bb#1)#0),/*minY*/((_bb#0)#1),/*maxZ*/(_bb#1)#2],
        [/*maxX*/((_bb#1)#0),/*maxY*/((_bb#1)#1),/*maxZ*/(_bb#1)#2],
        [/*minX*/((_bb#0)#0),/*maxY*/((_bb#1)#1),/*maxZ*/(_bb#1)#2]
    ]
};

NWG_SPWN_collisionCheckOrder = [
        //Lower diagonals
        [0,2],[1,3],
        //Lower perimeter
        [0,1],[1,2],[2,3],[3,0],
        //Verticals
        [4,0],[5,1],[6,2],[7,3],
        //Side diagonals
        [4,1],[5,2],[6,3],[7,0],
        //Upper perimeter
        [4,5],[5,6],[6,7],[7,4],
        //Upper diagonals (optional)
        [4,6],[5,7],
        //Inner diagonals (optional)
        [4,2] /*,[5,3],[6,0],[7,1]*/
];
NWG_SPWN_CollisionCheck = {
    params ["_object","_boundingBox",["_mayBeOnGround",true]];

    //Convert relative bounding box to world coordinates for current position
    private _worldBoundingBox = (_boundingBox + []) apply {(_object modelToWorldWorld _x)};

    //Check if lower points gone underground
    if (_mayBeOnGround) then {
        private ["_point","_atlZ"];
        for "_i" from 0 to 3 do {
            _point = _worldBoundingBox#_i;
            _atlZ = (ASLToATL _point)#2;
            if (_atlZ < 0.05) then {_point set [2,( (_point#2) - (_atlZ-0.05) )]};
        };
    };

    //Check possible intersection with any other object
    private _intersectArgs = [nil,nil,_object,objNull,true,1,"FIRE","VIEW",true];
    private _ok = true;
    //do
    {
        _intersectArgs set [0,(_worldBoundingBox#(_x#0))];
        _intersectArgs set [1,(_worldBoundingBox#(_x#1))];
        if ((count (lineIntersectsSurfaces _intersectArgs)) > 0) exitWith {_ok = false};
    } forEach NWG_SPWN_collisionCheckOrder;
    if (!_ok) exitWith {false};

    // Check if not inside some rock or building
    _ok = if (_mayBeOnGround) then {
        private _thisASL = getPosASL _object;
        (count (lineIntersectsSurfaces [_thisASL,(_thisASL vectorAdd [0,0,50]),_object,objNull,false,1,"GEOM","NONE"])) == 0
    } else {true};

    //return
    _ok
};

//================================================================================================================
//================================================================================================================
//Vehicle utils
NWG_SPWN_GetOriginalCrew = {
    // private _classname = _this;

    private _vehCfg = configFile >> "CfgVehicles" >> _this;
    private _crewUnit = getText (_vehCfg >> "crew");
    private _crewCount = {
        round getNumber (_x >> "dontCreateAI") < 1 &&
       ((_x == _vehCfg && { round getNumber (_x >> "hasDriver") > 0 }) ||
       (_x != _vehCfg && { round getNumber (_x >> "hasGunner") > 0 }))
    } count ([_this, configNull] call BIS_fnc_getTurrets);

    //return
    private _result = [];
    _result resize _crewCount;
    _result apply {_crewUnit}
};

NWG_SPWN_GetVehicleAppearance = {
    // private _vehicle = _this;
    (_this call BIS_fnc_getVehicleCustomization)
};

NWG_SPWN_GetVehicleAppearanceAll = {
    // private _vehicle = _this;

    //Modified copy of BIS_fnc_getVehicleCustomization content that gets ALL the colors and animations available
    private _vehCfg = configFile >> "cfgVehicles" >> (typeof _this);

    private _colors = [];
    {
        _colors pushBack (configName _x);
        _colors pushBack 0.5;
    } forEach ("true" configClasses (_vehCfg >> "TextureSources"));

    private _animations = [];
    {
        _animations pushBack (configName _x);
        _animations pushBack 0.5;
    } forEach ((configProperties [_vehCfg >> "animationSources", "isClass _x", true])
        select {getText (_x >> "displayName") isNotEqualTo "" && {getnumber (_x >> "scope") > 1 || !isnumber (_x >> "scope")}});

    //return
    [_colors,_animations]
};

NWG_SPWN_SetVehicleAppearance = {
    params ["_vehicle","_appearance"];
    ([_vehicle]+_appearance) call BIS_fnc_initVehicle;
};

NWG_SPWN_GetVehiclePylons = {
    // private _vehicle = _this;
    (getPylonMagazines _this)
};

NWG_SPWN_SetVehiclePylons = {
    params ["_vehicle","_pylons"];

    private _currentPylons = getPylonMagazines _vehicle;
    private _pylonPaths = configProperties [configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"];
    _pylonPaths = _pylonPaths apply {getArray (_x >> "turret")};

    for "_i" from 0 to ((count _currentPylons)-1) do {
        _vehicle removeWeaponGlobal getText (configFile >> "CfgMagazines" >> (_currentPylons#_i) >> "pylonWeapon");
    };

    for "_i" from 0 to ((count _pylons)-1) do {
        _vehicle setPylonLoadout [(_i+1),(_pylons#_i),true,(_pylonPaths#_i)];
    };
};