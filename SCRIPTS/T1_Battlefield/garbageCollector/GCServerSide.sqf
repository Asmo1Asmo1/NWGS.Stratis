#include "..\..\globalDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_GC_Settings = createHashMapFromArray [
    ["PLAYER_DELETION_DELAY",0.25],//Delay amount to wait before deleting the player (on respawn or disconnect)
    ["IMMEDIATE_DELETE_IF_PLAYER_DISTANCE",2500],//If vehicle/unit is killed not by player and there are no players closer than N - delete immediately (prevent bodies on the roads)

    ["BODIES_LIMITS",[18,36]],//Min and max bodies count on the map allowed
    ["WRECKS_LIMITS",[6,12]],//Min and max vehicle/turret wrecks
    ["TRASH_LIMITS",[5,10]],//Min and max ground trash
    ["PRESERVE_DISTANCE",25],//Distance from players to objects at which we will try to preserve them to not break immersion

    ["BUILDING_DECOR_DELETE",true],//Delete building decorations on building destroy
    ["BUILDING_DECOR_DELETE_DELAY",2],//Delay before deleting building decorations on building destroy

    ["MISSION_DELETE_PRESERVE_GROUND_TRASH_IF_PLAYER_NEAR",true],//Preserve player generated ground trash (e.g.:WeaponHolders) IF any player is near
    ["MISSION_DELETE_PRESERVE_VEHICLES_IF_PLAYER_NEAR",true],//Preserve vehicles (and static weapons) IF any player is near
    ["MISSION_DELETE_PRESERVE_OBJECTS_IF_PLAYER_NEAR",true],//Preserve objects IF any player is near (WARNING: Set it to false if mission deletion is called inside mission area)

    ["",0]
];

//======================================================================================================
//======================================================================================================
//Fields
NWG_GC_originalMarkers = [];
NWG_GC_originalObjects = [];
NWG_GC_originalGroups = [];

#define BIN_BODIES 0
#define BIN_WRECKS 1
#define BIN_TRASH 2
NWG_GC_garbageBin = [/*Bodies*/[],/*Wrecks*/[],/*Trash*/[]];
NWG_GC_environmentExclude = [
    "Sign_Arrow_Green_F",
    "Sign_Arrow_F",
    "Sign_Arrow_Yellow_F",
    "babe_helper",
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
    "#mark"
];

//======================================================================================================
//======================================================================================================
//Init
private _Init = {
    /*Subscribe to mission events*/
    //Delete player body on disconnect
    addMissionEventHandler ["HandleDisconnect", {
        // params ["_unit", "_id", "_uid", "_name"];
        (_this#0) call NWG_GC_DeleteUnitAfterDelay;
        //Fix AI replacing player
        false
    }];

    //Delete player body on respawn
    addMissionEventHandler ["EntityRespawned", {
        // params ["_newEntity", "_oldEntity"];
        (_this#1) call NWG_GC_DeleteUnitAfterDelay;
    }];

    //Delete floating decor when building model changes (partial destruction)
    addMissionEventHandler ["BuildingChanged", {
	    // params ["_from", "_to", "_isRuin"];
        _this call NWG_GC_OnBuildingChanged;
    }];

    /*Subscribe to NWG events*/
    [EVENT_ON_OBJECT_KILLED,{_this call NWG_GC_OnKilled}] call NWG_fnc_subscribeToServerEvent;
    [EVENT_ON_UKREP_OBJECT_DECORATED,{_this call NWG_GC_RegisterObjectDecoration}] call NWG_fnc_subscribeToServerEvent;

    /*Save original map state*/
    NWG_GC_originalMarkers = allMapMarkers;
    NWG_GC_originalObjects = (allMissionObjects "") select {!((typeOf _x) in NWG_GC_environmentExclude)};
    NWG_GC_originalGroups = allGroups;
};

//======================================================================================================
//======================================================================================================
//Ignore methods
NWG_GC_AddToOriginalObjects = {
    // private _objects = _this;
    NWG_GC_originalObjects append _this;
};

NWG_GC_AddToOriginalMarkers = {
    // private _markers = _this;
    NWG_GC_originalMarkers append _this;
};

//======================================================================================================
//======================================================================================================
//Dead vehicle util
NWG_GC_IsInDeadVehicle = {
    // private _unit = _this;
    !isNull (objectParent _this) && {!alive (objectParent _this)}
};

//======================================================================================================
//======================================================================================================
//Delete methods
NWG_GC_DeleteUnit = {
    // private _unit = _this;
    if (isNull _this) exitWith {};
    if (_this call NWG_GC_IsInDeadVehicle) exitWith {};//Ignore if inside dead vehicle - game will delete it itself

    private _vehicle = objectParent _this;
    if (isNull _vehicle)
        then {deleteVehicle _this}/*Unit on foot*/
        else {_vehicle deleteVehicleCrew _this};/*Unit inside vehicle*/
};

NWG_GC_delayedUnitsQueue = [];
NWG_GC_delayedUnitsHandle = scriptNull;
NWG_GC_DeleteUnitAfterDelay = {
    // private _unit = _this;
    if (isNull _this) exitWith {};

    //Delete all attached objects
    {detach _x; deleteVehicle _x} forEach ((attachedObjects _this) select {!isNull _x && {!(_x isKindOf "Man")}});

    //Setup delayed deletion
    NWG_GC_delayedUnitsQueue pushBack _this;
    if (isNull NWG_GC_delayedUnitsHandle || {scriptDone NWG_GC_delayedUnitsHandle}) then {
        NWG_GC_delayedUnitsHandle = [] spawn NWG_GC_DeleteUnitAfterDelay_Core;
    };
};
NWG_GC_DeleteUnitAfterDelay_Core = {
    while {(count NWG_GC_delayedUnitsQueue) > 0} do {
        sleep (NWG_GC_Settings get "PLAYER_DELETION_DELAY");
        (NWG_GC_delayedUnitsQueue deleteAt 0) call NWG_GC_DeleteUnit;
    };
};

NWG_GC_DeleteVehicle = {
    // private _vehicle = _this;
    if (isNull _this) exitWith {};
    deleteVehicle _this;
};

NWG_GC_DeleteObject = {
    // private _object = _this;
    if (isNull _this) exitWith {};
    deleteVehicle _this;
};

NWG_GC_DeleteGroup = {
    // private _group = _this;
    if (isNull _this) exitWith {};

    //Delete units and vehicles
    private _units = units _this;
    private _vehicles = (_units apply {objectParent _x}) select {!isNull _x};
    _vehicles = _vehicles arrayIntersect _vehicles;//Remove duplicates
    _vehicles = _vehicles select {((crew _x) findIf {isPlayer _x}) == -1};//Remove vehicles with players inside
    {_x call NWG_GC_DeleteUnit} forEach _units;
    {_x call NWG_GC_DeleteVehicle} forEach _vehicles;

    //Delete waypoints
    for "_i" from ((count (waypoints _this)) - 1) to 0 step -1 do {
        deleteWaypoint [_this, _i];
    };

    //Delete group
    deleteGroup _this;
};

//======================================================================================================
//======================================================================================================
//Handler
NWG_GC_OnKilled = {
    params ["_object","_objType"/*,"_actualKiller","_isPlayerKiller"*/];
    if (isNull _object) exitWith {};//Unknown error or other Arma moment

    switch (_objType) do {
        case OBJ_TYPE_BLDG: {_this call NWG_GC_OnBuildingDestroyed};
        case OBJ_TYPE_UNIT;
        case OBJ_TYPE_VEHC;
        case OBJ_TYPE_TRRT: {_this call NWG_GC_OnObjectKilled};
        default {/*Do nothing*/};
    };
};

//======================================================================================================
//======================================================================================================
//Handle garbage
NWG_GC_OnObjectKilled = {
    params ["_object","_objType","_actualKiller","_isPlayerKiller"];

    private _binIndex = switch (_objType) do {
        case OBJ_TYPE_UNIT: {BIN_BODIES};
        case OBJ_TYPE_VEHC: {BIN_WRECKS};
        case OBJ_TYPE_TRRT: {BIN_WRECKS};
        default {-1};
    };
    if (_binIndex < 0) exitWith {};
    if (_binIndex == BIN_BODIES && {_object call NWG_GC_IsInDeadVehicle}) exitWith {};//Ignore if inside dead vehicle - game will delete it itself

    private _immediateDelete = false;
    if (isNull _actualKiller || {!_isPlayerKiller}) then {
        private _players = call NWG_fnc_getPlayersOrOccupiedVehicles;
        private _distance = NWG_GC_Settings get "IMMEDIATE_DELETE_IF_PLAYER_DISTANCE";
        _immediateDelete = (_players findIf {(_x distance2D _object) <= _distance}) == -1;
    };
    if (_immediateDelete) exitWith {
        switch (_binIndex) do {
            case BIN_BODIES: {_object call NWG_GC_DeleteUnit};
            case BIN_WRECKS: {_object call NWG_GC_DeleteVehicle};
        };
    };

    [_object,_binIndex] call NWG_GC_Collect;
};

NWG_GC_OnReportTrash = {
    // private _trashObject = _this;
    if (isNull _this) exitWith {};
    [_this,BIN_TRASH] call NWG_GC_Collect;
};

NWG_GC_Collect = {
    params ["_object","_binIndex"];

    //Check double collection
    private _bin = NWG_GC_garbageBin select _binIndex;
    if (_object in _bin) exitWith {};//<= EXIT if already in the bin

    //Filter out invalid bin objects
    private _shouldForget = switch (_binIndex) do {
        case BIN_BODIES: {{isNull _this || {_this call NWG_GC_IsInDeadVehicle}}};//Forget nulls AND bodies inside destroyed vehicles
        default {{isNull _this}};//Forget nulls
    };
    {if (_x call _shouldForget) then {_bin deleteAt _forEachIndex}} forEachReversed _bin;

    //Check bin limits
    private _limits = switch (_binIndex) do {
        case BIN_BODIES: {NWG_GC_Settings get "BODIES_LIMITS"};
        case BIN_WRECKS: {NWG_GC_Settings get "WRECKS_LIMITS"};
        case BIN_TRASH:  {NWG_GC_Settings get "TRASH_LIMITS"};
        default {[0,0]};
    };
    _limits params ["_min","_max"];
    _min = _min - 1;//Skip the last object we will add
    _max = _max - 1;
    if ((count _bin) <= _min) exitWith {_bin pushBack _object};//<= EXIT if lower limit not reached

    //Prepare variables
    private _allPlayers = call NWG_fnc_getPlayersOrOccupiedVehicles;
    private _preserveDistance = NWG_GC_Settings get "PRESERVE_DISTANCE";
    private _isNoPlayerNear = {
        (_allPlayers findIf {(_x distance _this) <= _preserveDistance}) == -1
    };
    private _terminate = switch (_binIndex) do {
        case BIN_BODIES: {{_this call NWG_GC_DeleteUnit}};
        case BIN_WRECKS: {{_this call NWG_GC_DeleteVehicle}};
        default {{_this call NWG_GC_DeleteObject}};
    };
    reverse _bin;//We will delete from the end to the beginning

    //Delete old->new based on distance to players until limit is reached
    if ((count _bin) > _min) then {
        {
            if (_x call _isNoPlayerNear) then {(_bin deleteAt _forEachIndex) call _terminate};//Delete if no players around
            if ((count _bin) <= _min) exitWith {};//Exit loop if limit reached
        } forEachReversed _bin;
    };

    //Delete old->new until max limit is reached
    if ((count _bin) > _max) then {
        {
            (_bin deleteAt _forEachIndex) call _terminate;
            if ((count _bin) <= _max) exitWith {};//Exit loop if max limit reached
        } forEachReversed _bin;
    };

    //Re-form bin
    reverse _bin;//Restore original order
    _bin pushBack _object;//Add new object on top
};

//======================================================================================================
//======================================================================================================
//Handle building decorations (furniture, decorations, etc)
NWG_GC_nextBuildingID = 0;
NWG_GC_GetBuildingID = {_this getVariable ["NWG_GC_buildingID",-1]};
NWG_GC_NewBuildingID = {private _id = NWG_GC_nextBuildingID; NWG_GC_nextBuildingID = _id + 1; _id};
NWG_GC_SetBuildingID = {params ["_building","_id"]; _building setVariable ["NWG_GC_buildingID",_id]};

NWG_GC_buildingDecorations = [];
NWG_GC_RegisterObjectDecoration = {
    params ["_obj","_objType","_ukrepResult"];
    if !(NWG_GC_Settings get "BUILDING_DECOR_DELETE") exitWith {};//Skip if disabled

    //_ukrepResult params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    private _decor = (_ukrepResult#1) + (_ukrepResult#2);//Furniture + decorations

    switch (true) do {
        //Register new building
        case (_objType isEqualTo OBJ_TYPE_BLDG && {(_obj call NWG_GC_GetBuildingID) < 0}): {
            private _id = call NWG_GC_NewBuildingID;
            [_obj,_id] call NWG_GC_SetBuildingID;
            NWG_GC_buildingDecorations set [_id,_decor];
        };
        //Update registered building
        case (_objType isEqualTo OBJ_TYPE_BLDG): {
            private _id = _obj call NWG_GC_GetBuildingID;
            (NWG_GC_buildingDecorations select _id) append _decor;
        };
        //Check if this object is a decoration of registered building - update accordingly
        default {
            private _id = NWG_GC_buildingDecorations findIf {_obj in _x};
            if (_id < 0) exitWith {};//Not a decoration of registered building
            (NWG_GC_buildingDecorations select _id) append _decor;
        };
    };

};

NWG_GC_OnBuildingChanged = {
    // params ["_from", "_to", "_isRuin"];
    params ["_oldBuilding","_newBuilding"];
    if !(NWG_GC_Settings get "BUILDING_DECOR_DELETE") exitWith {};//Skip if disabled

    private _id = _oldBuilding call NWG_GC_GetBuildingID;
    if (_id < 0) exitWith {};//Skip unknown building

    if (!isNull _newBuilding) then {[_newBuilding,_id] call NWG_GC_SetBuildingID};//Copy ID to new building
    //We do not delete id from the old building because NWG_GC_OnBuildingDestroyed may fire for it

    _id call NWG_GC_DeleteFloatingBuildingDecor;
};

NWG_GC_OnBuildingDestroyed = {
    // params ["_object","_objType","_actualKiller","_isPlayerKiller"];
    params ["_building"];
    if !(NWG_GC_Settings get "BUILDING_DECOR_DELETE") exitWith {};//Skip if disabled

    private _id = _building call NWG_GC_GetBuildingID;
    if (_id < 0) exitWith {};//Skip unknown building

    _id call NWG_GC_DeleteFloatingBuildingDecor;
};

NWG_GC_deletionHandles = [];
NWG_GC_DeleteFloatingBuildingDecor = {
    private _buildingID = _this;

    //Fix NWG_GC_OnBuildingChanged and NWG_GC_OnBuildingDestroyed being called at the same time (case with some buildings)
    private _curHandle = NWG_GC_deletionHandles param [_buildingID,scriptNull];
    if (!isNull _curHandle && {!scriptDone _curHandle}) exitWith {};//There is already a deletion in progress

    _curHandle = _buildingID spawn NWG_GC_DeleteFloatingBuildingDecor_Core;
    NWG_GC_deletionHandles set [_buildingID,_curHandle];
};

NWG_GC_DeleteFloatingBuildingDecor_Core = {
    private _buildingID = _this;
    sleep (NWG_GC_Settings get "BUILDING_DECOR_DELETE_DELAY");

    private _decor = NWG_GC_buildingDecorations param [_buildingID,[]];
    private _prevCount = count _decor;
    waitUntil {
        if ((count _decor) == 0) exitWith {true};//Nothing to delete (safe check for possible NWG_GC_DeleteMission call while sleeping)

        //Delete all floating decorations
        {
            if (isNull _x || {((position _x)#2) > 0.1})
                then {(_decor deleteAt _forEachIndex) call NWG_GC_DeleteObject};
        } forEachReversed _decor;

        if ((count _decor) == _prevCount) exitWith {true};//Nothing was deleted
        _prevCount = count _decor;//Update cached count
        sleep 0.1;
        //Go to next iteration
        false
    };
};

//======================================================================================================
//======================================================================================================
//Clear battlefield
NWG_GC_DeleteMission = {
    params [["_callback",{}]];

    //Prepare preservation script
    private _players = call NWG_fnc_getPlayersAll;
    private _preserveDistance = NWG_GC_Settings get "PRESERVE_DISTANCE";
    private _isNoPlayerNear = {
        // private _object = _this;
        if (isNull _this) exitWith {true};
        (_players findIf {(_x distance _this) <= _preserveDistance}) == -1
    };

    //1. Purge garbage bin
    NWG_GC_garbageBin params [["_bodies",[]],["_wrecks",[]],["_trash",[]]];
    /*Purge bodies and vehicle wrecks*/
    {_x call NWG_GC_DeleteUnit} forEach _bodies; _bodies resize 0;
    {_x call NWG_GC_DeleteVehicle} forEach _wrecks; _wrecks resize 0;
    /*Purge player generated ground trash*/
    private _preserveTrash = NWG_GC_Settings get "MISSION_DELETE_PRESERVE_GROUND_TRASH_IF_PLAYER_NEAR";
    {
        if (!_preserveTrash || {_x call _isNoPlayerNear}) then {(_trash deleteAt _forEachIndex) call NWG_GC_DeleteObject};
    } forEachReversed _trash;

    //2. Purge buildings decorations
    {
        {_x call NWG_GC_DeleteObject} forEach _x;
        _x resize 0;
    } forEach NWG_GC_buildingDecorations;

    //3. Find and delete all AI groups
    {_x call NWG_GC_DeleteGroup} forEach (allGroups select {!(_x in NWG_GC_originalGroups) && {((units _x) findIf {isPlayer _x}) == -1}});

    //4. Delete all mission objects
    private _missionObjects = (allMissionObjects "") select {!((typeOf _x) in NWG_GC_environmentExclude)};
    _missionObjects = _missionObjects - NWG_GC_originalObjects - _players;
    private _preserveObjects = NWG_GC_Settings get "MISSION_DELETE_PRESERVE_OBJECTS_IF_PLAYER_NEAR";
    private _preserveVehicles = NWG_GC_Settings get "MISSION_DELETE_PRESERVE_VEHICLES_IF_PLAYER_NEAR";
    //forEach mission object
    {
        switch (_x call NWG_fnc_ocGetObjectType) do {
            case OBJ_TYPE_BLDG;
            case OBJ_TYPE_FURN;
            case OBJ_TYPE_MINE: {_x call NWG_GC_DeleteObject};

            case OBJ_TYPE_DECO: {
                if (!_preserveObjects || {_x call _isNoPlayerNear}) then {_x call NWG_GC_DeleteObject};
            };

            case OBJ_TYPE_UNIT: {
                if (!isPlayer _x) then {_x call NWG_GC_DeleteUnit};
            };

            case OBJ_TYPE_VEHC;
            case OBJ_TYPE_TRRT: {
                private _veh = _x;
                if (!alive _veh) exitWith {_veh call NWG_GC_DeleteVehicle};//Just delete if destroyed
                {_veh deleteVehicleCrew _x} forEach ((crew _veh) select {!unitIsUAV _x && {!alive _x || !isPlayer _x}});//Delete all the crew inside
                if (!_preserveVehicles || {_veh call _isNoPlayerNear}) then {_veh call NWG_GC_DeleteVehicle};//Delete if no players around
            };
        };
    } forEach _missionObjects;

    //5. Delete all map markers
    {deleteMarker _x} forEach (allMapMarkers select {!(_x in NWG_GC_originalMarkers)});
    call NWG_fnc_gcDeleteUserMarkers;
    remoteExec ["NWG_fnc_gcDeleteUserMarkers",-2];

    //6. Delete all tasks
    {
        {
            [_x,true,true] call BIS_fnc_deleteTask;
        } forEach (_x call BIS_fnc_tasksUnit);
    } forEach _players;

    //7. Invoke callback
    call _callback;
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;