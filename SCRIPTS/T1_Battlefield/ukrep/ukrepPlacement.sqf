#include "..\..\globalDefines.h"
#include "ukrepDefines.h"

/*
    Annotation:
    This module places object compositions (ukreps) according to blueprints and rules.
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_UKREP_Settings = createHashMapFromArray [
    ["BLUEPRINTS_CATALOGUE_ADDRESS","DATASETS\Server\Ukrep\Blueprints"],//Address of the catalogue for blueprints
    ["FACTIONS_CATALOGUE_ADDRESS","DATASETS\Server\Ukrep\Factions"],//Address of the catalogue for factions

    ["OPTIMIZE_OBJECTS_ON_CREATE",true],//If set to true, script will validate and modify the original object payload for buildings/furniture/decor

    ["DEFAULT_GROUP_SIDE",west],//If group rules not provided - place under this side
    ["DEFAULT_GROUP_DYNASIM",true],//If group rules not provided - place with this dynamic simulation setting
    ["DEFAULT_GROUP_TRYSHUFFLE",true],//If group rules not provided - place with this shuffle setting

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Blueprint catalog get
//TODO

//================================================================================================================
//================================================================================================================
//FRACTAL placement
NWG_UKREP_FRACTAL_PlaceFractalABS = {
    params ["_blueprint",["_chances",[]],["_faction","NATO"],["_groupRules",[]]];
    //TODO
};

NWG_UKREP_FRACTAL_PlaceFractalREL = {
    params ["_blueprint","_pos","_dir",["_chances",[]],["_faction","NATO"],["_groupRules",[]]];
    //TODO
};

//================================================================================================================
//================================================================================================================
//Placement
NWG_UKREP_PlaceABS = {
    params ["_blueprint",["_chances",[]],["_faction","NATO"],["_groupRules",[]]];

    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    private _result = [_blueprint,_groupRules] call NWG_UKREP_PlacementCore;

    //return
    _result
};

NWG_UKREP_PlaceREL_Position = {
    params ["_blueprint","_pos","_dir",["_chances",[]],["_faction","NATO"],["_groupRules",[]],["_adaptToGround",false]];

    _blueprint = [_blueprint,_pos,_dir,_adaptToGround,/*skip root:*/false] call NWG_UKREP_BP_RELtoABS;
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    private _result = [_blueprint,_groupRules] call NWG_UKREP_PlacementCore;

    //return
    _result
};

NWG_UKREP_PlaceREL_Object = {
    params ["_blueprint","_object",["_chances",[]],["_faction","NATO"],["_groupRules",[]],["_adaptToGround",false]];

    private _pos = getPosASL _object;
    private _dir = getDir _object;
    _blueprint = [_blueprint,_pos,_dir,_adaptToGround,/*skip root:*/true] call NWG_UKREP_BP_RELtoABS;
    _blueprint = [_blueprint,_chances] call NWG_UKREP_BP_ApplyChances;
    _blueprint = [_blueprint,_faction] call NWG_UKREP_BP_ApplyFaction;
    private _result = [_blueprint,_groupRules] call NWG_UKREP_PlacementCore;

    //return
    _result
};

//================================================================================================================
//================================================================================================================
//Blueprint manipulation
NWG_UKREP_BP_RELtoABS = {
    params ["_blueprint","_placementPos","_placementDir","_adaptToGround","_skipAdaptRoot"];

    private _result = [];
    private _recursiveRELtoABS = {
        params ["_rootPos","_rootOrigDir","_rootCurDir","_adapt","_records"];

        //Prepare variables
        private _a = if (_rootCurDir >= _rootOrigDir)
            then {((360-_rootCurDir)+_rootOrigDir)}
            else {(360-((360-_rootOrigDir)+_rootCurDir))};
        private _sin = if (_a == 180 || {_a == 360}) then {0} else {sin _a};//Fix SQF sin/cos bug
        private _cos = if (_a == 90  || {_a == 270}) then {0} else {cos _a};//Fix SQF sin/cos bug

        //Process records
        {
            //Calculate ABS position
            private _posOffset = _x#BP_POSOFFSET;
            private _dX = ((_posOffset#0)*_cos)-((_posOffset#1)*_sin);
            private _dY = ((_posOffset#1)*_cos)+((_posOffset#0)*_sin);
            private _absPos = [
                ((_rootPos#0)+_dX),
                ((_rootPos#1)+_dY),
                ((_rootPos#2)+(_posOffset#2))
            ];
            if (_adapt) then {
                if (_skipAdaptRoot && {_forEachIndex == 0}) exitWith {};//Skip root adaptation
                _absPos set [2,0];
                _absPos = ATLToASL _absPos;
            };
            _x set [BP_POS,_absPos];

            //Calculate ABS direction
            private _origDir   = _x#BP_DIR;//Save for later
            private _dirOffset = _x#BP_DIROFFSET;
            private _absDir = (_rootCurDir + _dirOffset);
            _x set [BP_DIR,_absDir];

            //Check if we need to go deeper (and save in both cases)
            private _inside = _x param [BP_INSIDE,[]];
            if ((count _inside) > 0) then {
                _x resize BP_INSIDE;
                _result pushBack _x;
                [_absPos,_origDir,_absDir,false,_inside] call _recursiveRELtoABS;
            } else {
                _result pushBack _x;
            };
        } forEach _records;
    };

    [_placementPos,((_blueprint#0)#BP_DIR),_placementDir,_adaptToGround,_blueprint] call _recursiveRELtoABS;
    _blueprint resize 0;
    _blueprint append _result;

    //return
    _blueprint
};

NWG_UKREP_BP_ApplyChances = {
    params ["_blueprint",["_chances",[]]];
    if (_chances isEqualTo []) exitWith {_blueprint};//Nothing to do

    private _toRemove = [];
    {
        private _chance = _chances param [_forEachIndex,1];
        if (_chance isEqualTo 1) then {continue};//Skip 100% chance

        private _affectedObjects = _blueprint select {(_x#BP_OBJTYPE) isEqualTo _x};
        if ((count _affectedObjects) == 0) then {continue};//Skip if no objects of this type

        private _targetCount = if (_chance isEqualType []) then {
            //Min and max count
            _chance params ["_min","_max"];
            (floor (random (_max-_min+1))) + _min
        } else {
            //Percentage
            round ((count _affectedObjects) * _chance)
        };
        if ((count _affectedObjects) <= _targetCount) then {continue};//Skip if no objects to remove

        _affectedObjects = _affectedObjects call NWG_fnc_arrayShuffle;
        _toRemove append (_affectedObjects select [_targetCount]);
    } forEach [
        OBJ_TYPE_BLDG,
        OBJ_TYPE_FURN,
        OBJ_TYPE_DECO,
        OBJ_TYPE_UNIT,
        OBJ_TYPE_VEHC,
        OBJ_TYPE_TRRT,
        OBJ_TYPE_MINE
    ];

    if ((count _toRemove) > 0) then {
        private _temp = _blueprint - _toRemove;
        _blueprint resize 0;
        _blueprint append _temp;
    };

    //return
    _blueprint
};

NWG_UKREP_BP_ApplyFaction = {
    params ["_blueprint",["_faction",""]];
    if (_faction isEqualTo "") exitWith {_blueprint};//Nothing to do

    private _factionPage = createHashMap;//TODO: Replace with an actual catalogue get
    if (_factionPage isEqualTo false) exitWith {_blueprint};//Error

    private _toReplace = _blueprint select {(_x#BP_CLASSNAME) in _factionPage};
    if ((count _toReplace) == 0) exitWith {_blueprint};//Nothing to do

    private _replacement = [];
    {
        _replacement = _factionPage get (_x#BP_CLASSNAME);
        _replacement = if ((count _replacement) > 1)
            then {[_replacement,(format ["NWG_UKREP_BP_ApplyFaction_",(_x#BP_CLASSNAME)])] call NWG_fnc_selectRandomGuaranteed}
            else {_replacement#0};
        if (_replacement isEqualType []) then {
            _x set [BP_CLASSNAME,_replacement#0];
            _x set [BP_PAYLOAD,_replacement#1];
        } else {
            _x set [BP_CLASSNAME,_replacement];
        };
    } forEach _toReplace;

    //return
    _blueprint
};

//================================================================================================================
//================================================================================================================
//Placement CORE
//Note: at this point we expect the blueprint to be in absolute coordinates ASL, insides unpacked into single-dimension array and protected from modification of the original blueprint
NWG_UKREP_PlacementCore = {
    params ["_blueprint",["_groupRules",[]]];

    /*Sort into groups*/
    private _hlprs = _blueprint select {(_x#BP_OBJTYPE) isEqualTo "HELP"};        _blueprint = _blueprint - _hlprs;
    private _bldgs = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_BLDG}; _blueprint = _blueprint - _bldgs;
    private _furns = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_FURN}; _blueprint = _blueprint - _furns;
    private _decos = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_DECO}; _blueprint = _blueprint - _decos;
    private _units = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_UNIT}; _blueprint = _blueprint - _units;
    private _vehcs = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_VEHC}; _blueprint = _blueprint - _vehcs;
    private _trrts = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_TRRT}; _blueprint = _blueprint - _trrts;
    private _mines = _blueprint select {(_x#BP_OBJTYPE) isEqualTo OBJ_TYPE_MINE};

    /*Place HELP - helper modules*/
    if ((count _hlprs) > 0) then {
        private _hlprsGroup = group (missionNamespace getvariable ["BIS_functions_mainscope",objnull]);
        if (isNull _hlprsGroup) exitWith {};//Failed to obtain
        {
            private _helper = _hlprsGroup createUnit [(_x#BP_CLASSNAME),(_x#BP_POS),[],0,"CAN_COLLIDE"];
            _helper setDir (_x#BP_DIR);
            _helper setPosASL (_x#BP_POS);
            {_helper setVariable _x} forEach (_x#BP_PAYLOAD);
        } forEach _hlprs;
        _hlprs resize 0;//Clear
    };

    /*Place regular objects (BLDG,FURN,DECO) - buildings, furniture, decor*/
    _bldgs = _bldgs apply {_x call NWG_UKREP_CreateObject};
    _furns = _furns apply {_x call NWG_UKREP_CreateObject};
    _decos = _decos apply {_x call NWG_UKREP_CreateObject};

    /*Prepare the group to include units into with lazy evaluation*/
    private _placementGroup = grpNull;
    private _getGroup = {
        if (!isNull _placementGroup) exitWith {_placementGroup};
        _placementGroup = createGroup [
            (_groupRules param [GRP_RULES_SIDE,(NWG_UKREP_Settings get "DEFAULT_GROUP_SIDE")]),
            /*delete when empty:*/true
        ];
        _placementGroup
    };

    /*Place UNIT - units*/
    if ((count _units) > 0) then {
        private _tryShufflePositions = _groupRules param [GRP_RULES_TRYSHUFFLE,(NWG_UKREP_Settings get "DEFAULT_GROUP_TRYSHUFFLE")];
        _units = _units apply {[(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),(_x#BP_PAYLOAD)]};//Repack into func argument
        _units = [_units,(call _getGroup),_tryShufflePositions] call NWG_fnc_spwnSpawnUnitsExact;
        {_x disableAI "PATH"} forEach _units;//Disable pathfinding for all units
    };

    /*Place VEHC - vehicles*/
    _vehcs = _vehcs apply {
        (_x#BP_PAYLOAD) params [["_crew",[]],["_appearance",false],["_pylons",false]];
        private _vehicle = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR),_appearance,_pylons] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_vehicle,(call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _vehicle
    };

    /*Place TRRT - turrets*/
    _trrts = _trrts apply {
        private _crew = _x param [BP_PAYLOAD,[]];
        private _turret = [(_x#BP_CLASSNAME),(_x#BP_POS),(_x#BP_DIR)] call NWG_fnc_spwnSpawnVehicleExact;
        if ((count _crew) > 0) then {[(_crew call NWG_fnc_unCompactStringArray),_turret,(call _getGroup)] call NWG_fnc_spwnSpawnUnitsIntoVehicle};
        _turret
    };

    /*Finalize group*/
    if (!isNull _placementGroup) then {
        private _dynaSim = _groupRules param [GRP_RULES_DYNASIM,(NWG_UKREP_Settings get "DEFAULT_GROUP_DYNASIM")];
        _placementGroup enableDynamicSimulation _dynaSim;
    };

    /*Place MINE - mines*/
    if ((count _mines) > 0) then {
        private _minesDirs = [];//Fix for mines direction in MP
        _mines = _mines apply {
            private _pos = if ((_x#BP_CLASSNAME) isEqualTo "APERSTripMine")
                then {(_x#BP_POS) vectorAdd [0,0,0.1]}
                else {(_x#BP_POS)};//Fix for APERSTripMine

            private _mine = createMine [(_x#BP_CLASSNAME),(ASLToAGL _pos),[],0];
            _mine enableDynamicSimulation true;//Always true
            _mine setDir (_x#BP_DIR);

            _minesDirs pushBack (_x#BP_DIR);
            _mine
        };
        [_mines,_minesDirs] call NWG_fnc_ukrpMinesRotateAndAdapt;
        [_mines,_minesDirs] remoteExec ["NWG_fnc_ukrpMinesRotateAndAdapt",-2];//Fix for mines direction in MP
    };

    //return
    [_bldgs,_furns,_decos,_units,_vehcs,_trrts,_mines]
};

NWG_UKREP_CreateObject = {
    // params ["_objType","_classname","_pos","_posOffset","_dir","_dirOffset","_payload","_inside"];
    private _classname = _this#BP_CLASSNAME;
    private _pos = _this#BP_POS;
    private _dir = _this#BP_DIR;
    (_this#BP_PAYLOAD) params [["_canSimple",false],["_isSimple",false],["_isSimOn",false],["_isDynaSimOn",false],["_isDmgAllowed",false],["_isInteractable",false]];

    //Optimize settings
    if (NWG_UKREP_Settings get "OPTIMIZE_OBJECTS_ON_CREATE") then {
        if (_canSimple && !_isInteractable) then {_isSimple = true};
        if (!_isInteractable) then {_isSimOn = false; _isDynaSimOn = false};
        if (_isSimOn && !_isDynaSimOn) then {_isDynaSimOn = true};
    };

    //Create
    private _obj = if (_isSimple)
        then {createSimpleObject [_classname,_pos]}
        else {createVehicle [_classname,(ASLToATL _pos),[],0,"CAN_COLLIDE"]};
    _obj setDir _dir;
    _obj setPosASL _pos;//Fix postion distortion after setDir for certain objects (buildings especially)

    //Apply settings
    if (!_isSimple) then {
        _obj enableSimulation _isSimOn;
        _obj enableDynamicSimulation _isDynaSimOn;
        _obj allowDamage _isDmgAllowed;
    };

    //return
    _obj
};