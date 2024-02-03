#include "..\..\globalDefines.h"
#include "ukrepDefines.h"

/*
    Annotation:
    This module gathers the blueprint of the object composition.
*/
/*
    Every REL blueprint requires a root object - object in the center of the composition.
    Ways to mark root object:
    1. Name it 'NWG_UKREP_Root' (case sensitive)
    2. Init code: this setVariable ["UKREP_IsRoot",true];
    3. Look at it as player - the object under the crosshair will be marked as root.
*/

//================================================================================================================
//Settings
NWG_UKREP_GATHER_Settings = createHashMapFromArray [
    ["DISABLE_PLACEHOLDER_UNITS_ON_START",true],//If true all the placeholder units will be disabled to ease gathering

    ["",0]
];

//================================================================================================================
//Placeholders
NWG_UKREP_placeholders = createHashMapFromArray([
    [OBJ_TYPE_BLDG, []],//Not defined yet
    [OBJ_TYPE_FURN, []],//Not defined yet
    [OBJ_TYPE_DECO, []],//Not defined yet
    [OBJ_TYPE_UNIT, [
        "B_Soldier_VR_F",//Blue VR unit (common units)
        "I_Soldier_VR_F",//Green VR unit (high ground units)
        "C_Soldier_VR_F",//Purple VR unit (officers?)
        "O_Soldier_VR_F"//Red VR unit (not used yet)
    ]],
    [OBJ_TYPE_VEHC, [
        "Land_VR_Target_MRAP_01_F",//Small VR vehicle
        "Land_VR_Target_APC_Wheeled_01_F",//Medium VR vehicle
        "Land_VR_Target_MBT_01_cannon_F"//Large VR vehicle
    ]],
    [OBJ_TYPE_TRRT, [
        "VR_3DSelector_01_default_F",//Blue VR selector (standing turret in closed position like inside the tower)
        "VR_3DSelector_01_complete_F",//Brown VR selector (crouching turret)
        "VR_3DSelector_01_incomplete_F",//Yellow VR selector (AT/AA) (can also be used for standing turret, no problem)
        "VR_3DSelector_01_exit_F"//Red VR selector (Mortar)
    ]],
    [OBJ_TYPE_MINE, []]//Not defined yet
]);

NWG_UKREP_GetPlaceholderType = {
    // private _objectOrClassname = _this;
    private _type = if (_objectOrClassname isEqualType objNull) then {typeOf _objectOrClassname} else {_objectOrClassname};
    private _result = false;
    {if (_type in _y) exitWith {_result = _x}} forEach NWG_UKREP_placeholders;
    //return
    _result
};

NWG_UKREP_IsPlaceholder = {
    // private _objectOrClassname = _this;
    (_this call NWG_UKREP_GetPlaceholderType) isNotEqualTo false
};

NWG_UKREP_GetPlaceholderPayload = {
    // private _placeholderType = _this;
    switch (_this) do {
        case OBJ_TYPE_BLDG;
        case OBJ_TYPE_FURN;
        case OBJ_TYPE_DECO: {[]};
        case OBJ_TYPE_UNIT: {1};
        case OBJ_TYPE_VEHC;
        case OBJ_TYPE_TRRT: {[]};
        case OBJ_TYPE_MINE: {0};
    }
};

//Disable placeholder units
if (NWG_UKREP_GATHER_Settings get "DISABLE_PLACEHOLDER_UNITS_ON_START") then {
    private _placeholderUnitsTypes = NWG_UKREP_placeholders get OBJ_TYPE_UNIT;
    {_x disableAI "ALL"} forEach (allUnits select {(typeOf _x) in _placeholderUnitsTypes});
};

//================================================================================================================
//Gather ABS composition
NWG_UKREP_GatherUkrepABS = {
    private _radius = _this;

    private _objects = _radius call NWG_UKREP_GatherObjectsAround;//Gather objects around player
    [_objects] call NWG_UKREP_MarkObjectsOnMap;//Mark them on map

    //Calculate position and radius (inlined)
    private _coords = _objects apply {getPosASL _x};
    private _bpPos = _coords call NWG_fnc_dtsFindMidpoint;
    private _bpRad = 0;
    {_bpRad = _bpRad max (_bpPos distance2D _x)} forEach _coords;

    private _blueprint = _objects call NWG_UKREP_PackIntoRecords;//Pack into records
    _blueprint = _blueprint call NWG_UKREP_Sort;//Sort

    //Pack into full blueprint
    private _fullBlueprint = [
        /*BPCONTAINER_TYPE*/"ABS",
        /*BPCONTAINER_NAME*/"UKREPNAME",
        /*BPCONTAINER_POS*/_bpPos,
        /*BPCONTAINER_UNUSED1*/0,
        /*BPCONTAINER_RADIUS*/_bpRad,
        /*BPCONTAINER_UNUSED2*/0,
        /*BPCONTAINER_PAYLOAD*/[],
        /*BPCONTAINER_BLUEPRINT*/_blueprint
    ];
    _fullBlueprint call NWG_UKREP_Dump;//Dump to RPT
};

//================================================================================================================
//Gather REL composition
NWG_UKREP_GatherUkrepREL = {
    private _radius = _this;

    private _objects = _radius call NWG_UKREP_GatherObjectsAround;//Gather objects around player
    private _rootObj = _objects call NWG_UKREP_FindRoot;//Find root object
    if (isNull _rootObj) exitWith {"NWG_UKREP_GatherUkrepREL: Root object not found!"};
    _objects = _objects - [_rootObj];//Remove root object from the list
    [_objects,_rootObj] call NWG_UKREP_MarkObjectsOnMap;//Mark them on map

    //Calculate radius (inlined)
    private _bpRad = 0;
    {_bpRad = _bpRad max (_rootObj distance2D _x)} forEach _objects;

    _objects = [_rootObj] + _objects;//Put root object first
    private _blueprint = _objects call NWG_UKREP_PackIntoRecords;//Pack into records
    _blueprint = _blueprint call NWG_UKREP_ABStoREL;//Convert to REL

    //Sort root and the rest separately
    private _roots = [_blueprint deleteAt 0];
    _roots = _roots call NWG_UKREP_Sort;
    _blueprint = _blueprint call NWG_UKREP_Sort;
    _blueprint = _roots + _blueprint;//Put root object first

    //Pack into full blueprint
    private _fullBlueprint = [
        /*BPCONTAINER_TYPE*/"REL",
        /*BPCONTAINER_NAME*/"UKREPNAME",
        /*BPCONTAINER_POS*/0,
        /*BPCONTAINER_UNUSED1*/0,
        /*BPCONTAINER_RADIUS*/_bpRad,
        /*BPCONTAINER_UNUSED2*/0,
        /*BPCONTAINER_PAYLOAD*/[],
        /*BPCONTAINER_BLUEPRINT*/_blueprint
    ];
    _fullBlueprint call NWG_UKREP_Dump;//Dump to RPT
};

//================================================================================================================
//Gathering utilities
NWG_UKREP_excludeFromGathering = [
    "Sign_Arrow_Green_F",
    "Sign_Arrow_F",
    "Sign_Arrow_Yellow_F",
    "babe_helper",
    "Logic",
    "Camera",
    "Snake_random_F",
    "Kestrel_Random_F",
    "ButterFly_random",
    "Rabbit_F",
    "HoneyBee",
    "Mosquito",
    "HouseFly",
    "FxWindGrass2",
    "FxWindPollen1",
    "ModuleCurator_F",
    "#mark"
];
NWG_UKREP_GatherObjectsAround = {
    private _radius = _this;
    //return
    (allMissionObjects "") select {
        switch (true) do {
            case ((typeOf _x) in NWG_UKREP_excludeFromGathering): {false};
            case ((_x distance2D player) > _radius): {false};
            case (_x isEqualTo player): {false};
            default {true};
        }
    };
};

NWG_UKREP_FindRoot = {
    private _objects = _this;

    //1. Name 'NWG_UKREP_Root' (case sensitive)
    if (!isNil "NWG_UKREP_Root" && {!isNull NWG_UKREP_Root && {NWG_UKREP_Root in _objects}}) exitWith {NWG_UKREP_Root};

    //2. Init code: this setVariable ["UKREP_IsRoot",true];
    private _i = _objects findIf {(_x getVariable ["UKREP_IsRoot",false])};
    if (_i != -1) exitWith {_objects select _i};

    //3. Look at it as player - the object under the crosshair will be marked as root.
    private _underCursor = cursorObject;
    if (!isNull _underCursor && {_underCursor in _objects}) exitWith {_underCursor};

    //return
    systemChat "NWG_UKREP_FindRoot: Root object not found!";
    objNull
};

NWG_UKREP_MarkObjectsOnMap = {
    params ["_objects",["_rootObj",objNull]];
    call NWG_fnc_testClearMap;
    if (!isNull _rootObj) then {
        _objects = _objects - [_rootObj];
        [_rootObj,"ukrepObj_root","ColorBlue"] call NWG_fnc_testPlaceMarker;
    };
    {[_x,(format ["ukrepObj_%1",_forEachIndex]),"ColorRed"] call NWG_fnc_testPlaceMarker} forEach _objects;
};

NWG_UKREP_PackIntoRecords = {
    // private _objects = _this;

    private ["_c","_isPlaceholder","_type","_payload"];
    //return
    _this apply {
        _c = typeOf _x;
        _isPlaceholder = _c call NWG_UKREP_IsPlaceholder;
        _type = if (_isPlaceholder)
            then {_c call NWG_UKREP_GetPlaceholderType}
            else {_x call NWG_fnc_ocGetObjectType};
        _payload = if (_isPlaceholder && {_type isNotEqualTo OBJ_TYPE_UNIT})
            then {_type call NWG_UKREP_GetPlaceholderPayload}
            else {[_x,_type] call NWG_UKREP_GetObjectPayload};

        //Fix for mines (gathered as XXX_Ammo when we need an actaul mine classname, not a magazine)
        if (_type isEqualTo OBJ_TYPE_MINE) then {
            private _parts = _c splitString "_";
            _c = switch (true) do {
                case ((count _parts) > 1 && {(_parts#1) isEqualTo "F"}): {format ["%1_F",(_parts#0)]};
                case ((_parts#0) isEqualTo "TrainingMine"): {"TrainingMine_01_F"};
                default {_parts#0};
            };
        };

        //pack
        [
            /*BP_OBJTYPE*/_type,
            /*BP_CLASSNAME*/_c,
            /*BP_POS*/(getPosASL _x),
            /*BP_POSOFFSET*/0
            /*BP_DIR*/(getDir _x),
            /*BP_DIROFFSET*/0
            /*BP_PAYLOAD*/_payload,
            /*BP_INSIDE*/[]
            /*BP_ORIGOBJECT*/_x
        ]
    }
};

NWG_UKREP_GetObjectPayload = {
    params ["_object",["_type",""]];
    if (_type isEqualTo "") then {_type = _object call NWG_fnc_ocGetObjectType};

    //return
    switch (_type) do {
        /*For objects - payload is array of flags*/
        case OBJ_TYPE_BLDG;
        case OBJ_TYPE_FURN;
        case OBJ_TYPE_DECO: {
            private _cfg = configfile >> "CfgVehicles" >> (typeOf _object);
            [
                /*P_OBJ_CAN_SIMPLE*/((getNumber (_cfg >> "SimpleObject" >> "eden")) == 1),
                /*P_OBJ_IS_SIMPLE*/(isSimpleObject _object),
                /*P_OBJ_IS_SIM_ON*/(simulationEnabled _object),
                /*P_OBJ_IS_DYNASIM_ON*/(dynamicSimulationEnabled _object),
                /*P_OBJ_IS_DMG_ALLOWED*/(isDamageAllowed _object),
                /*P_OBJ_IS_INTERACTABLE*/([_object,_cfg] call NWG_UKREP_IsInteractable)
            ]
        };

        /*For units - payload is a stance of unit*/
        case OBJ_TYPE_UNIT: {
            switch (toLower (unitPos _object)) do {
                case "up":    {1};
                case "middle":{2};
                case "down":  {3};
                default       {0};
            }
        };

        /*For vehicles - payload is array of [[crew],(optional)[appearance],(optional)[pylons]]*/
        case OBJ_TYPE_VEHC: {
            private _crew = ((crew _object) apply {typeOf _x}) call NWG_fnc_compactStringArray;

            //Create default second vehicle to compare its appearance and pylons with original
            private _defaultVehicle = createVehicle [_vehClassname, (ASLToATL [120,120,1000])];

            //Gather appearance info
            private _vehicleAppearance = _object call NWG_fnc_spwnGetVehicleAppearance;
            private _defaultAppearance = _defaultVehicle call NWG_fnc_spwnGetVehicleAppearance;
            private _appearance = if (_vehicleAppearance isEqualTo _defaultAppearance) then {false} else {_vehicleAppearance};

            //Gather pylons info
            private _vehiclePylons = _object call NWG_fnc_spwnGetVehiclePylons;
            private _defaultPylons = _defaultVehicle call NWG_fnc_spwnGetVehiclePylons;
            private _pylons = if (_vehiclePylons isEqualTo _defaultPylons) then {false} else {_vehiclePylons};

            //Delete default vehicle
            deleteVehicle _defaultVehicle;

            //return
            if (_appearance isNotEqualTo false || _pylons isNotEqualTo false)
                then {[_crew,_appearance,_pylons]}
                else {[_crew]}
        };

        /*For turrets - payload is [crew]*/
        case OBJ_TYPE_TRRT: {
            (((crew _object) apply {typeOf _x}) call NWG_fnc_compactStringArray)
        };

        /*For mines - payload is empty*/
        case OBJ_TYPE_MINE: {
            0
        };

        /*For unknown objects - payload is ERROR*/
        default {
            (format ["NWG_UKREP_GetObjState: Unknown object type: %1", _objectType]) call NWG_fnc_logError;
            "ERROR"
        };
    }
};

//Separated to be able to test it
NWG_UKREP_IsInteractable = {
    params ["_object",["_cfg",configNull]];
    if (isNull _cfg) then {_cfg = configfile >> "CfgVehicles" >> (typeOf _object)};

    //return
    (count ("true" configClasses (_cfg >> "UserActions"))) > 0 ||
    {(getNumber (_cfg >> 'maximumLoad')) > 0 ||
    {(objectParent _object) isKindOf "WeaponHolder"}}
};

NWG_UKREP_ABStoREL = {
    private _records = _this;

    //Separate
    private _roots  = [_records deleteAt 0];
    private _bldgs = []; private _furns = []; private _decos = [];
    {
        switch ((_x#BP_OBJTYPE)) do {
            case OBJ_TYPE_BLDG: {_bldgs pushBack (_records deleteAt _forEachIndex)};
            case OBJ_TYPE_FURN: {_furns pushBack (_records deleteAt _forEachIndex)};
            case OBJ_TYPE_DECO: {_decos pushBack (_records deleteAt _forEachIndex)};
        }
    } forEachReversed _records;

    //Prepare the script
    private _ABStoREL = {
        params ["_parentObjects","_childObjects",["_isBuilding",false]];
        if ((count _parentObjects) == 0 || {(count _childObjects) == 0}) exitWith {};
        private ["_parent","_child"];
        {
            _parent = _x;
            {
                _child = _x;
                if ([(_child#BP_ORIGOBJECT),(_parent#BP_ORIGOBJECT),_isBuilding] call NWG_UKREP_IsInside) then {
                    _child set [BP_POSOFFSET,((_child#BP_POS) vectorDiff (_parent#BP_POS))];
                    _child set [BP_DIROFFSET,((_child#BP_DIR) - (_parent#BP_DIR))];
                    (_parent#BP_INSIDE) pushBack (_childObjects deleteAt _forEachIndex)
                };
            } forEachReversed _childObjects;
            if ((count _childObjects) == 0) exitWith {};
        } forEach _parentObjects;
    };

    //Check each decoration against other decorations
    private _temp = [];
    private _cur = [];
    while ((count _decos) > 0) do {
        _cur pushBack (_decos deleteAt ((count _decos)-1));
        [_cur,_decos] call _ABStoREL;
        [_decos,_cur] call _ABStoREL;
        if ((count _cur) > 0)
            then {_temp pushBack (_cur deleteAt 0)};
    };
    _decos append _temp;

    //Check each objects in hierarchy and append them back to the list
    [_decos,_records] call _ABStoREL; _records append _decos; _decos resize 0;
    [_furns,_records] call _ABStoREL; _records append _furns; _furns resize 0;
    [_bldgs,_records,true] call _ABStoREL; _records append _bldgs; _bldgs resize 0;
    [_roots,_records] call _ABStoREL; _records append _roots; _roots resize 0;
    reverse _records;//Reverse to keep the root object first

    //return
    _records
};

//This implementation relies solely on raycasting and check if _objectA is above _objectB - good enough
NWG_UKREP_IsInside = {
    params ["_objectA","_objectB",["_isBuilding",false]];
    private _raycastFrom = getPosWorld _objectA;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _limit = if (_isBuilding) then {-1} else {1};//-1 for buildings, 1 for everything else
    //return
    _objectB in (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_objectA,objNull,true,_limit,"FIRE","VIEW",true]))
};

NWG_UKREP_sortOrder = [OBJ_TYPE_BLDG,OBJ_TYPE_FURN,OBJ_TYPE_DECO,OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT,OBJ_TYPE_MINE];
NWG_UKREP_Sort = {
    private _records = _this;

    private _recursiveSort = {
        private _records = _this;
        if ((count _records) <= 1) exitWith {};

        private _sorted = _records apply {[(_sortOrder find (_x#BP_OBJTYPE)),(_x#BP_CLASSNAME),_x]};//Repack for sorting
        _sorted sort true;//Sort
        _records resize 0;
        _records append (_sorted apply {_x#2});//Repack back
        {(_x#BP_INSIDE) call _recursiveSort} forEach _records;//Sort nested
    };
    _records call _recursiveSort;

    //return
    _records
};

NWG_UKREP_Dump = {
    private _fullBlueprint = _this;

    //Form lines of text
    private _lines = [];
    private _tab = "    ";
    private _recursiveLinesFill = {
        params ["_records","_prefix","_suffix"];

        {
            private _isLast = (_forEachIndex == ((count _records)-1));
            private _hasInside = (count (_x#BP_INSIDE)) > 0;
            private _lineEnd = switch (true) do {
                case (_hasInside): {",["};
                case (_isLast): {"]"+_suffix};
                default {"],"}
            };

            _lines pushBack (format ["%1[%2,%3,%4,%5,%6,%7,%8%9",
                _prefix,
                (_x#BP_OBJTYPE),
                (_x#BP_CLASSNAME),
                (_x#BP_POS),
                (_x#BP_POSOFFSET),
                (_x#BP_DIR),
                (_x#BP_DIROFFSET),
                (_x#BP_PAYLOAD),
                _lineEnd
            ]);

            if (_hasInside) then {
                private _nextSuffix = if (_isLast) then {"]]"+_suffix} else {"]],"}
                [(_x#BP_INSIDE),(_prefix+_tab),_nextSuffix] call _recursiveLinesFill;
            };
        } forEach _records;
    };
    [_fullBlueprint,_tab,""] call _recursiveLinesFill;

    //Dump to RPT
    diag_log text "==========[UKREP GATHERED DATA]===========";
    {diag_log (text _x)} forEach _lines;
    diag_log text "==========[        END        ]===========";

    //Dump to clipboard
    copyToClipboard (_lines joinString (toString [13,10]));//Copy with 'new line' separator

    //Dump to output console as is
    _lines
};