#include "..\..\globalDefines.h"
#include "ukrepDefines.h"

/*
    Annotation:
    This module gathers the blueprint of the object composition.

    Gather REL (Relative position offset) composition:
    _radius call NWG_UKREP_GatherUkrepREL

    Gather ABS (Absolute position values) composition:
    _radius call NWG_UKREP_GatherUkrepABS

    The result will be dumped to RPT and copied to clipboard.
*/
/*
    Every REL blueprint requires a root object - object in the center of the composition.
    Ways to mark root object (in order of checking in code):
    1. Name it 'NWG_UKREP_Root' (case sensitive)
    2. Init code: this setVariable ["UKREP_IsRoot",true];
    3. Look at it as player - the object under the crosshair will be marked as root.
*/

//================================================================================================================
//Settings
NWG_UKREP_GATHER_Settings = createHashMapFromArray [
    ["PLACEHOLDER_UNITS_DISABLE_AI",true],//If true all the placeholder units will have AI disabled to ease gathering
    ["PLACEHOLDER_UNITS_DISABLE_COLLISION",true],//If true all the placeholder units will be transparent to player to ease gathering

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    if (
        !(NWG_UKREP_GATHER_Settings get "PLACEHOLDER_UNITS_DISABLE_AI") && {
        !(NWG_UKREP_GATHER_Settings get "PLACEHOLDER_UNITS_DISABLE_COLLISION")}
    ) exitWith {};

    private _placeholderUnits = allUnits select {(typeOf _x) in (NWG_UKREP_placeholders get OBJ_TYPE_UNIT)};

    if (NWG_UKREP_GATHER_Settings get "PLACEHOLDER_UNITS_DISABLE_AI")
        then { {_x disableAI "ALL"} forEach _placeholderUnits };

    if (NWG_UKREP_GATHER_Settings get "PLACEHOLDER_UNITS_DISABLE_COLLISION")
        then { {player disableCollisionWith _x} forEach _placeholderUnits };
};

//================================================================================================================
//Placeholders
NWG_UKREP_placeholders = createHashMapFromArray([
    [OBJ_TYPE_BLDG, [
        "Land_VR_Block_04_F"//Big VR block (buildings)
    ]],
    [OBJ_TYPE_FURN, []],//Not defined yet
    [OBJ_TYPE_DECO, [
        "Land_VR_Shape_01_cube_1m_F"//VR cube (boxes)
    ]],
    [OBJ_TYPE_UNIT, [
        "B_Soldier_VR_F",//Blue VR unit (common units)
        "I_Soldier_VR_F",//Green VR unit (high ground units)
        "C_Soldier_VR_F",//Purple VR unit (officers)
        "O_Soldier_VR_F"//Red VR unit (not used yet)
    ]],
    [OBJ_TYPE_VEHC, [
        "Land_VR_Target_MRAP_01_F",//Small VR vehicle
        "Land_VR_Target_APC_Wheeled_01_F",//Medium VR vehicle
        "Land_VR_Target_MBT_01_cannon_F"//Large VR vehicle
    ]],
    [OBJ_TYPE_TRRT, []],//Not defined (we use actual NATO turrets instead)
    [OBJ_TYPE_MINE, []] //Not defined yet
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

    //return
    _fullBlueprint
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
    //Root is one, of course, but it can have nested objects that should be sorted
    _rootObj = [_blueprint deleteAt 0];
    _rootObj = _rootObj call NWG_UKREP_Sort;
    _blueprint = _blueprint call NWG_UKREP_Sort;
    _blueprint = _rootObj + _blueprint;//Put root object first

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

    //return
    _fullBlueprint
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
    "FxWindGrass1",
    "FxWindGrass2",
    "FxWindPollen1",
    "ModuleCurator_F",
    "#mark"
];
NWG_UKREP_GatherObjectsAround = {
    private _radius = _this;
    //return
    (allMissionObjects "") select {
        !((typeOf _x) in NWG_UKREP_excludeFromGathering) && {
        (_x isNotEqualTo player) && {
        ((_x distance2D player) <= _radius)}}
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
            /*BP_POSOFFSET*/0,
            /*BP_DIR*/(getDir _x),
            /*BP_DIROFFSET*/0,
            /*BP_PAYLOAD*/_payload,
            /*BP_INSIDE*/[],
            /*BP_ORIGOBJECT*/_x
        ]
    }
};

NWG_UKREP_GetObjectPayload = {
    params ["_object",["_type",""]];
    if (_type isEqualTo "") then {_type = _object call NWG_fnc_ocGetObjectType};

    //return
    switch (_type) do {
        /*For objects - payload is a flag of either SIMPLE, STATIC or INTERACTABLE*/
        case OBJ_TYPE_BLDG;
        case OBJ_TYPE_FURN;
        case OBJ_TYPE_DECO: {
            private _cfg = configfile >> "CfgVehicles" >> (typeOf _object);
            private _canBeSimple = (getNumber (_cfg >> "SimpleObject" >> "eden")) == 1;
            private _isDynamicSimOn = dynamicSimulationEnabled _object;
            private _isInteractable = [_object,_cfg] call NWG_UKREP_IsInteractable;

            switch (true) do {
                /*Simple*/
                case (isSimpleObject _object): {OBJ_SIMPLE};//Object explicitly marked as simple
                case (_canBeSimple && !_isDynamicSimOn && !_isInteractable): {OBJ_SIMPLE};//Object can be simplified
                /*Interactable*/
                case (_isDynamicSimOn): {OBJ_INTERACTABLE};//Object explicitly marked as interactable
                case (simulationEnabled _object && _isInteractable): {OBJ_INTERACTABLE};//Object is interactable by nature and allowed to be interacted with
                /*Static*/
                default {OBJ_STATIC};//Object is static by default
            }
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
            private _defaultVehicle = createVehicle [(typeOf _object), (ASLToATL [120,120,1000])];

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

    //Fill the 'insideOf' arrays for each object
    {
        _x set [BP_INSIDE_OF,((_x#BP_ORIGOBJECT) call NWG_UKREP_GetIsInsideOf)];
    } forEach _records;

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
    //This script iterates through childs and moves them to the parent's 'nested' array if they are inside of it
    //As a result _childObjects may be emptied by the end of the script with all the children moved to respective parents
    private _ABStoREL = {
        params ["_parentObjects","_childObjects","_insideCheckType"];
        if ((count _parentObjects) == 0 || {(count _childObjects) == 0}) exitWith {};

        private ["_parent","_child"];
        private _insideCheck = switch (_insideCheckType) do {
            case -1:  {{true}};
            case  0:  {{(_parent#BP_ORIGOBJECT) in (_child#BP_INSIDE_OF)}};
            case  1:  {{(_parent#BP_ORIGOBJECT) isEqualTo ((_child#BP_INSIDE_OF) param [0,objNull])}};
        };
        //forEach parent
        {
            _parent = _x;
            //forEachReversed child
            {
                _child = _x;
                if (call _insideCheck) then {
                    _child set [BP_POSOFFSET,((_child#BP_POS) vectorDiff (_parent#BP_POS))];
                    _child set [BP_DIROFFSET,((_child#BP_DIR) - (_parent#BP_DIR))];
                    _child set [BP_POS,0];
                    (_parent#BP_INSIDE) pushBack (_childObjects deleteAt _forEachIndex)
                };
            } forEachReversed _childObjects;
        } forEach _parentObjects;
    };

    //Check each decoration against other decorations and vice versa
    private _temp = [];
    private _cur = [];
    while {(count _decos) > 0} do {
        _cur pushBack (_decos deleteAt ((count _decos)-1));
        [_cur,_decos,1] call _ABStoREL;
        [_decos,_cur,1] call _ABStoREL;
        if ((count _cur) > 0) then {_temp pushBack (_cur deleteAt 0)};
    };
    _decos append _temp; _temp resize 0; _cur resize 0;

    //Check all the objects and append them back to the list (order matters)
    [_decos,_records,1] call _ABStoREL; _records append _decos; _decos resize 0;
    [_furns,_records,1] call _ABStoREL; _records append _furns; _furns resize 0;
    [_bldgs,_records,0] call _ABStoREL; _records append _bldgs; _bldgs resize 0;

    //Check remaining objects against root
    private _checkTypeForRoot = if (((_roots#0)#BP_OBJTYPE) isEqualTo OBJ_TYPE_BLDG) then {0} else {1};
    [_roots,_records,_checkTypeForRoot] call _ABStoREL; _records append _roots;

    //Final conversion - calculate offsets of all the 'outside' objects in comparison to the root
    //will also place root first because 'forEachReversed' is used
    _temp = ["","",((_roots#0)#BP_POS),0,((_roots#0)#BP_DIR),0,[],[]];
    [[_temp],_records,-1] call _ABStoREL;
    _records append (_temp#BP_INSIDE); _temp resize 0; _roots resize 0;

    //return
    _records
};

//This implementation returns all/one the objects below _object - just good enough for our use case where this would mean that object is 'inside'
//Returns array of unique objects in order 'top to bottom' (file on the table inside the house -> [table,house])
NWG_UKREP_GetIsInsideOf = {
    params ["_object",["_limit",-1]];
    private _raycastFrom = getPosWorld _object;
    private _raycastTo = _raycastFrom vectorAdd [0,0,-50];
    private _result = (flatten (lineIntersectsSurfaces [_raycastFrom,_raycastTo,_object,objNull,true,_limit,"FIRE","VIEW",true]));//Get raycast result
    _result = _result select {_x isEqualType objNull && {!isNull _x && {!(_x isEqualTo _object)}}};//Filter objects only
    _result = _result arrayIntersect _result;//Remove duplicates
    //return
    _result
};

NWG_UKREP_sortOrder = [OBJ_TYPE_BLDG,OBJ_TYPE_FURN,OBJ_TYPE_DECO,OBJ_TYPE_UNIT,OBJ_TYPE_VEHC,OBJ_TYPE_TRRT,OBJ_TYPE_MINE];
NWG_UKREP_Sort = {
    // private _records = _this;

    private _recursiveSort = {
        private _records = _this;

        //Sort current level
        if ((count _records) > 1) then {
            private _sorted = _records apply {[(NWG_UKREP_sortOrder find (_x#BP_OBJTYPE)),(_x#BP_CLASSNAME),_x]};//Repack for sorting
            _sorted sort true;//Sort
            _records resize 0;
            _records append (_sorted apply {_x#2});//Repack back
        };

        //Sort nested
        {(_x#BP_INSIDE) call _recursiveSort} forEach _records;
    };
    _this call _recursiveSort;

    //return
    _this
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
                (str (_x#BP_OBJTYPE)),
                (str (_x#BP_CLASSNAME)),
                (_x#BP_POS),
                (_x#BP_POSOFFSET),
                (_x#BP_DIR),
                (_x#BP_DIROFFSET),
                (_x#BP_PAYLOAD),
                _lineEnd
            ]);

            if (_hasInside) then {
                private _nextSuffix = if (_isLast) then {"]]"+_suffix} else {"]],"};
                [(_x#BP_INSIDE),(_prefix+_tab),_nextSuffix] call _recursiveLinesFill;
            };
        } forEach _records;
    };
    [[_fullBlueprint],_tab,""] call _recursiveLinesFill;

    //Dump to RPT
    diag_log text "==========[UKREP GATHERED DATA]===========";
    {diag_log (text _x)} forEach _lines;
    diag_log text "==========[        END        ]===========";

    //Dump to clipboard
    copyToClipboard (_lines joinString (toString [13,10]));//Copy with 'new line' separator
};

//================================================================================================================
//Init
call _Init;