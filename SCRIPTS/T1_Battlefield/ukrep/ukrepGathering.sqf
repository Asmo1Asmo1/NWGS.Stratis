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
    //This script iterates through childs and moves them to the parent's 'nested' array if they are inside it
    //As a result _childObjects may be emptied by the end of the script with all the children moved to respective parents
    private _ABStoREL = {
        params ["_parentObjects","_childObjects",["_isParentBuilding",false],["_isFinalConversion",false]];
        if ((count _parentObjects) == 0 || {(count _childObjects) == 0}) exitWith {};

        private ["_parent","_child"];
        {
            _parent = _x;
            {
                _child = _x;
                if (_isFinalConversion || {[(_child#BP_ORIGOBJECT),(_parent#BP_ORIGOBJECT),_isParentBuilding] call NWG_UKREP_IsInside}) then {
                    _child set [BP_POSOFFSET,((_child#BP_POS) vectorDiff (_parent#BP_POS))];
                    _child set [BP_DIROFFSET,((_child#BP_DIR) - (_parent#BP_DIR))];
                    _child set [BP_POS,0];
                    (_parent#BP_INSIDE) pushBack (_childObjects deleteAt _forEachIndex)
                };
            } forEachReversed _childObjects;
            if ((count _childObjects) == 0) exitWith {};//All the children are moved
        } forEach _parentObjects;
    };

    //Check each decoration against other decorations
    private _temp = [];
    private _cur = [];
    while {(count _decos) > 0} do {
        _cur pushBack (_decos deleteAt ((count _decos)-1));
        [_cur,_decos] call _ABStoREL;
        [_decos,_cur] call _ABStoREL;
        if ((count _cur) > 0)
            then {_temp pushBack (_cur deleteAt 0)};
    };
    _decos append _temp; _temp resize 0; _cur resize 0;

    //Check all the objects in hierarchy and append them back to the list
    [_decos,_records]      call _ABStoREL; _records append _decos; _decos resize 0;
    [_furns,_records]      call _ABStoREL; _records append _furns; _furns resize 0;
    [_bldgs,_records,true] call _ABStoREL; _records append _bldgs; _bldgs resize 0;
    [_roots,_records]      call _ABStoREL; _records append _roots;

    //Final conversion - calculate offsets of all the 'outside' objects in comparison to the root (will also place root first)
    _temp = ["","",((_roots#0)#BP_POS),0,((_roots#0)#BP_DIR),0,[],[]];
    [[_temp],_records,false,true] call _ABStoREL;
    _records append (_temp#BP_INSIDE); _temp resize 0; _roots resize 0;

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

    //Dump to output console as is
    _lines
};

    ["REL","UKREPNAME",0,0,19.1667,0,[],[
        ["BLDG","Land_BagBunker_Tower_F",0,[0,0,0],2.538,0,[false,false,true,false,true,false],[
            ["DECO","Land_PortableGenerator_01_black_F",0,[0.284424,2.30762,2.779],213.695,211.157,[true,false,true,false,true,false]],
            ["UNIT","B_Soldier_VR_F",0,[-0.640991,1.56201,2.78144],32.1783,29.6403,2]]],
        ["BLDG","Land_Cargo_Patrol_V3_F",0,[0.751831,14.6011,4.76837e-007],270,267.462,[false,false,true,false,true,true],[
            ["MINE","APERSMine",0,[1.14905,-1.67627,4.32116],0,-270,0],
            ["MINE","APERSTripMine",0,[1.72949,-0.957031,4.25278],269.574,-0.426361,0]]],
        ["BLDG","Land_Cargo_Patrol_V3_F",0,[-13.7765,4.58887,4.76837e-007],0,-2.538,[false,false,true,false,true,true],[
            ["DECO","Land_PortableCabinet_01_4drawers_black_F",0,[-2.41797,0.640625,4.13905],281.546,281.546,[true,false,true,false,true,true],[
                ["DECO","Land_File1_F",0,[-0.0919189,-0.0200195,0.828816],159.763,-121.783,[true,false,true,false,true,false]]]],
            ["DECO","Land_PortableCabinet_01_4drawers_black_F",0,[-2.58643,1.64795,4.13905],272.151,272.151,[true,false,true,false,true,true]],
            ["TRRT","B_GMG_01_high_F",0,[1.06506,-0.821777,4.33123],181.102,181.102,["B_Soldier_VR_F"]]]],
        ["FURN","Land_CampingTable_F",0,[-0.381958,2.57275,-0.00259209],359.998,357.46,[true,false,true,false,true,false],[
            ["DECO","Land_Computer_01_black_F",0,[0.672119,-0.121094,0.813634],0.00494434,-359.993,[true,false,true,false,true,false]],
            ["DECO","Land_Laptop_03_black_F",0,[-0.322632,0.00195313,0.813633],334.943,-25.0556,[true,false,true,false,true,false]]]],
        ["DECO","Land_CncBarrier_F",0,[-17.6163,-4.66992,0],225.329,222.791,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[-15.3342,-5.66992,0],181.326,178.788,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[0.837646,-6.25391,0],181.185,178.647,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[3.12073,-5.396,0],138.856,136.318,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[4.13452,-3.12793,0],90.833,88.295,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[-12.6936,-5.71094,0],181.108,178.57,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[-1.8031,-6.2168,0],181.409,178.871,[false,false,true,false,true,false]],
        ["DECO","Land_CncBarrier_F",0,[-18.4803,-2.38623,0],273.344,270.806,[false,false,true,false,true,false]],
        ["DECO","Land_PortableGenerator_01_F",0,[3.51221,1.72314,-0.000999928],271.873,269.335,[true,false,true,false,true,false]],
        ["DECO","RoadBarrier_F",0,[-1.57263,-8.07764,-0.00399303],184.508,181.97,[true,false,true,false,true,false]],
        ["DECO","RoadBarrier_F",0,[-12.9766,-7.7627,-0.00399303],177.313,174.775,[true,false,true,false,true,false]],
        ["UNIT","B_Soldier_VR_F",0,[-6.92554,1.97119,0.00143909],182.167,179.629,0],
        ["UNIT","B_Soldier_VR_F",0,[-0.212158,1.43604,0.00143909],0,-2.538,0],
        ["VEHC","B_G_Quadbike_01_F",0,[-11.1637,11.8916,0.0125246],102.77,100.232,[["B_Soldier_VR_F"],[["Guerrilla_02",1],[]],false]],
        ["VEHC","B_T_Quadbike_01_F",0,[-10.9778,15.7114,0.0123229],85.8734,83.3354,[[]]],
        ["TRRT","B_G_Mortar_01_F",0,[-15.0779,-2.73389,0.036881],147.218,144.68,["B_Soldier_VR_F"]],
        ["TRRT","B_HMG_01_high_F",0,[-12.7112,-3.63135,-0.0121183],183.271,180.733,[]],
        ["MINE","APERSBoundingMine",0,[-9.85559,-11.6309,-0.100053],0,-2.538,0],
        ["MINE","APERSTripMine",0,[-9.67957,-9.8877,-0.0912571],0,-2.538,0],
        ["MINE","SLAMDirectionalMine",0,[-5.10327,-10.9858,-0.0013361],0,-2.538,0],
        ["MINE","TrainingMine_01_F",0,[-6.96167,-10.3579,0.000205994],0,-2.538,0]]]