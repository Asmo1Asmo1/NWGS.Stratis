#include "..\..\globalDefines.h"

//======================================================================================================
//======================================================================================================
//Settings
NWG_GC_Settings = createHashMapFromArray [
    ["PLAYER_DELETION_DELAY",0.1],//Delay amount to wait before deleting the player (on respawn or disconnect)
    ["IMMEDIATE_DELETE_IF_PLAYER_DISTANCE",5000],//If vehicle/unit is killed not by player and there are no players closer than N - delete immediately (prevent bodies on the roads)

    ["BODIES_MAX",[15,30]],//Min and max bodies count on the map allowed
    ["WRECKS_MAX",[5,10]],//Min and max vehicle/turret wrecks
    ["TRASH_MAX",[4,8]],//Min and max ground trash
    ["PRESERVE_DISTANCE",25],//Distance from players to objects at which we will try to preserve them to not break immersion

    ["BUILDING_DECOR_DELETE",true],//Delete building decorations on building destroy
    ["BUILDING_DECOR_DELETE_DELAY",2],//Delay before deleting building decorations on building destroy

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

    /*Subscribe to NWG events*/
    [EVENT_ON_OBJECT_KILLED,{_this call NWG_GC_OnKilled}] call NWG_fnc_subscribeToServerEvent;
    [EVENT_ON_UKREP_PLACED,{_this call NWG_GC_RegisterBuildingDecoration}] call NWG_fnc_subscribeToServerEvent;

    /*Save original map state*/
    NWG_GC_originalMarkers = allMapMarkers;
    NWG_GC_originalObjects = (allMissionObjects "") select {!((typeOf _x) in NWG_GC_environmentExclude)};
    NWG_GC_originalGroups = allGroups;
};

//======================================================================================================
//======================================================================================================
//Delete methods
NWG_GC_DeleteUnit = {
    // private _unit = _this;
    if (isNull _this) exitWith {};

    private _vehicle = vehicle _this;
    switch (true) do {
        case (isNull _vehicle): {deleteVehicle _this};//Just in case
        case (_vehicle isEqualTo _this): {deleteVehicle _this};//Unit on foot
        case (!alive _vehicle && {!alive _this}): {};//Game will delete on vehicle deletion (Fix possible game crash)
        default {_vehicle deleteVehicleCrew _this};//Unit inside vehicle
    };
};

NWG_GC_delayedUnitsQueue = [];
NWG_GC_delayedUnitsHandle = scriptNull;
NWG_GC_DeleteUnitAfterDelay = {
    // private _unit = _this;
    if (isNull _this) exitWith {};

    NWG_GC_delayedUnitsQueue pushBack [(time + (NWG_GC_Settings get "PLAYER_DELETION_DELAY")), _this];
    if (isNull NWG_GC_delayedUnitsHandle || {scriptDone NWG_GC_delayedUnitsHandle}) then {
        NWG_GC_delayedUnitsHandle = [] spawn NWG_GC_DeleteUnitAfterDelay_Core;
    };
};
NWG_GC_DeleteUnitAfterDelay_Core = {
    while {(count NWG_GC_delayedUnitsQueue) > 0} do {
        sleep (NWG_GC_Settings get "PLAYER_DELETION_DELAY");
        while {(count NWG_GC_delayedUnitsQueue) > 0 && {((NWG_GC_delayedUnitsQueue#0)#0) <= time}} do {
            ((NWG_GC_delayedUnitsQueue deleteAt 0)#1) call NWG_GC_DeleteUnit;
        };
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
    private _vehicles = (_units select {(vehicle _x) isNotEqualTo _x}) apply {vehicle _x};
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
        case OBJ_TYPE_UNIT: {
            if ((vehicle _object) isNotEqualTo _object && {(!alive (vehicle _object))}) exitWith {-1};//Ignore dead crew inside dead vehicle
            BIN_BODIES
        };
        case OBJ_TYPE_VEHC: {BIN_WRECKS};
        case OBJ_TYPE_TRRT: {BIN_WRECKS};
        default {-1};
    };
    if (_binIndex < 0) exitWith {};

    private _immediateDelete = false;
    if (isNull _actualKiller || {!_isPlayerKiller}) then {
        //Check if any player saw it die
        private _players = call NWG_fnc_getPlayersAndOrPlayedVehiclesAll;
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

    //Check if object is in the bin
    private _bin = NWG_GC_garbageBin select _binIndex;
    if (_object in _bin) exitWith {};//Already in the bin

    //Update bin
    private _updated = (_bin - [objNull]) + [_object];
    if (_binIndex == BIN_BODIES) then {
        //Forget bodies inside destroyed vehicles (game will take care of them itself)
        _updated = _updated select {(vehicle _x) isEqualTo _x || {alive (vehicle _x)}};
    };
    _bin resize 0;
    _bin append _updated;

    //Check bin limits
    (NWG_GC_Settings get (["BODIES_MAX","WRECKS_MAX","TRASH_MAX"] select _binIndex)) params ["_min","_max"];
    if ((count _bin) <= _min) exitWith {};//Limit not reached

    //Prepare variables
    private _allPlayers = call NWG_fnc_getPlayersAndOrPlayedVehiclesAll;
    private _preserveDistance = NWG_GC_Settings get "PRESERVE_DISTANCE";
    private _terminate = switch (_binIndex) do {
        case BIN_BODIES: {{_this call NWG_GC_DeleteUnit}};
        case BIN_WRECKS: {{_this call NWG_GC_DeleteVehicle}};
        default {{_this call NWG_GC_DeleteObject}};
    };

    //Delete old->new based on distance to players until limit is reached
    private _cur = objNull;
    private _index = 0;
    while {true} do {
        _cur = _bin select _index;
        if ((_allPlayers findIf {(_x distance _cur) <= _preserveDistance}) == -1)
            then {(_bin deleteAt _index) call _terminate}//Delete if no players nearby
            else {_index = _index + 1};//Skip if players nearby
        if ((count _bin) <= _min || {_index >= ((count _bin)-1)}) exitWith {};//-1 to fix 'kill->delete' situation
    };
    if ((count _bin) <= _max) exitWith {};//Even if nothing was deleted - max limit is not reached yet

    //Delete old->new until max limit is reached
    while {(count _bin) > _max} do {
        (_bin deleteAt 0) call _terminate;
    };
};

//======================================================================================================
//======================================================================================================
//Clear building on destruction
NWG_GC_buildingDecorations = createHashMap;
NWG_GC_RegisterBuildingDecoration = {
    // params ["_bldgs","_furns","_decos","_units","_vehcs","_trrts","_mines"];
    if !(NWG_GC_Settings get "BUILDING_DECOR_DELETE") exitWith {};//Skip if disabled

    //forEach furniture and decoration
    {
        (NWG_GC_buildingDecorations getOrDefault [(_x call NWG_fnc_ukrpGetBuildingID),[],true]) pushBack _x;
    } forEach (((_this#1)+(_this#2)) select {(_x call NWG_fnc_ukrpGetBuildingID) isNotEqualTo false});
};

NWG_GC_OnBuildingDestroyed = {
    // params ["_object","_objType","_actualKiller","_isPlayerKiller"];
    if !(NWG_GC_Settings get "BUILDING_DECOR_DELETE") exitWith {};//Skip if disabled

    //Check building ID
    private _buildingID = (_this#0) call NWG_fnc_ukrpGetBuildingID;
    if (_buildingID isEqualTo false) exitWith {};//This building was not part of the mission

    //Get decorations
    private _buildingDecor = NWG_GC_buildingDecorations getOrDefault [_buildingID,[]];
    if ((count _buildingDecor) == 0) exitWith {};//No decorations to delete

    //Delete all decorations that hang in the air
    _buildingDecor spawn {
        // private _buildingDecor = _this;
        sleep (NWG_GC_Settings get "BUILDING_DECOR_DELETE_DELAY");
        if ((count _this) == 0) exitWith {};//Check again (just in case)

        //OK, I guess a little explanation is needed here:
        //We do the main logic INSIDE THE CONDITION BLOCK - this way we got us some sort of a "do-while" loop in SQF
        private _prevCount = count _this;
        while {
            {
                if (isNull _x || {((position _x)#2) > 0.1})
                    then {(_this deleteAt _forEachIndex) call NWG_GC_DeleteObject};
            } forEachReversed _this;
            (count _this) != _prevCount
        } do {
            _prevCount = count _this;
        };
    };
};

//======================================================================================================
//======================================================================================================
//Clear battlefield
NWG_GC_DeleteMission = {
    params [["_callback",{}]];

    //1. Purge garbage bin
    {_x call NWG_GC_DeleteUnit} forEach (NWG_GC_garbageBin#BIN_BODIES);
    {_x call NWG_GC_DeleteVehicle} forEach (NWG_GC_garbageBin#BIN_WRECKS);
    {_x call NWG_GC_DeleteObject} forEach (NWG_GC_garbageBin#BIN_TRASH);
    {_x resize 0} forEach NWG_GC_garbageBin;

    //2. Purge buildings decorations
    {
        {_x call NWG_GC_DeleteObject} forEach _x;
        _x resize 0;
    } forEach (values NWG_GC_buildingDecorations);

    //3. Find and delete all AI groups
    {_x call NWG_GC_DeleteGroup} forEach (allGroups select {!(_x in NWG_GC_originalGroups) && {((units _x) findIf {isPlayer _x}) == -1}});

    //4. Delete all mission objects
    //do
    {
        switch (_x call NWG_fnc_ocGetObjectType) do {
            case OBJ_TYPE_BLDG;
            case OBJ_TYPE_FURN;
            case OBJ_TYPE_DECO;
            case OBJ_TYPE_MINE: {_x call NWG_GC_DeleteObject};

            case OBJ_TYPE_UNIT: {
                if (!isPlayer _x) then {_x call NWG_GC_DeleteUnit};
            };

            case OBJ_TYPE_VEHC;
            case OBJ_TYPE_TRRT: {
                //Just delete if destroyed
                if (!alive _x) exitWith {_x call NWG_GC_DeleteVehicle};
                //Delete all the crew inside of alive vehicle
                {(vehicle _x) deleteVehicleCrew _x} forEach ((crew _x) select {!unitIsUAV _x && {!alive _x || !isPlayer _x}});
                //Delete if no players inside
                if (((crew _x) findIf {isPlayer _x}) == -1) then {_x call NWG_GC_DeleteVehicle};
            };
        };
    } forEach ((allMissionObjects "") select {!(_x in NWG_GC_originalObjects) && {!((typeOf _x) in NWG_GC_environmentExclude)}});

    //5. Delete all map markers
    {deleteMarker _x} forEach (allMapMarkers select {!(_x in NWG_GC_originalMarkers)});
    call NWG_fnc_gcDeleteUserMarkers;
    remoteExec ["NWG_fnc_gcDeleteUserMarkers",-2];

    //6. Delete all tasks
    {
        {
            [_x,true,true] call BIS_fnc_deleteTask;
        } forEach (_x call BIS_fnc_tasksUnit);
    } forEach ((call NWG_fnc_getPlayersAll) select {alive _x});

    //7. Invoke callback
    call _callback;
};

//======================================================================================================
//======================================================================================================
//Init
call _Init;