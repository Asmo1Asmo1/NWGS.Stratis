//===============================================================
//Logging

//Logs an error to the server's RPT file even if called from a client
//params: _message - message to log
NWG_fnc_logError = {
    // private _message = _this;
    diag_log formatText ["  [ERROR] #### %1",_this];
    if (!isServer) then {_this remoteExec ["NWG_fnc_logError",2]};
};

//Logs info message (without sending it over the network)
//params: _message - message to log
NWG_fnc_logInfo = {
    // private _message = _this;
    diag_log formatText ["  [INFO] #### %1",_this];
};

//===============================================================
//Array manipulation

//Shuffles array and returns it (modifies the input array) (utilizes Fisher-Yates shuffle algorithm)
NWG_fnc_arrayShuffle = {
    //private _array = _this;
    if ((count _this) <= 1) exitWith {_this};//Check obvious case

    private _j = -1;
    {
        _j = floor (random (_forEachIndex + 1));//Generate a random index _j between 0 and current index
        _this set [_forEachIndex,(_this#_j)];
        _this set [_j,_x];
    } forEachReversed _this;

    _this
};

//Shifts array elements by random amount and returns it (modifies the input array)
NWG_fnc_arrayRandomShift = {
    //private _array = _this;
    private _i = floor (random (count _this));
    if (_i <= 0) exitWith {_this};
    private _result = (_this select [_i]) + (_this select [0,_i]);
    _this resize 0;
    _this append _result;
    _this
};

//Returns random element from array
//Ensures that each element of the array is picked at least once before repeating
//Ensures that each element would not be picked twice in a row even at the border of cycles
//Works much slower than your regular selectRandom and should be used with that in mind
//params:
// array - array to pick from
// arrayID - unique ID of array by which the pick history is saved
// deepSave - if true, history is saved in profileNamespace, making it cross-session ⚠️EXTREMELY SLOW⚠️
//returns: random element from array
NWG_fnc_selectRandomGuaranteed = {
    params ["_array","_arrayID",["_deepSave",false]];

    //Check obvious case
    private _arrayCount = count _array;
    if (_arrayCount <= 1) exitWith {_array param [0]};

    //Get history of previous picks (ID tree)
    private _historyBook = if (_deepSave)
        then {(profileNamespace getVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", createHashMap])}
        else {(localNamespace getVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", createHashMap])};

    //Check history validity, re-create if invalid (except for _lastPick - it needs to be preserved)
    (_historyBook getOrDefault [_arrayID,[-1,-1,[]]]) params ["_lastArrayCount","_lastPick","_picksLeft"];
    if (_lastArrayCount != _arrayCount || {(count _picksLeft) == 0}) then {
        //Update last array count
        _lastArrayCount = _arrayCount;

        //Update picks left
        _picksLeft resize _arrayCount;
        {_picksLeft set [_forEachIndex,_forEachIndex]} forEach _picksLeft;
        _picksLeft = _picksLeft call NWG_fnc_arrayShuffle;//Shuffle that uses Fisher-Yates algorithm

        //Ensure that the first pick of this cycle is not the same as the last pick of the previous cycle
        private _attempts = 10;//Just in case, apply NASA standards
        while {(_picksLeft#0) == _lastPick && {_attempts > 0}} do {
            _picksLeft = _picksLeft call NWG_fnc_arrayShuffle;
            _attempts = _attempts - 1;
        };
    };

    //Select random index by getting it from pre-shuffled array
    _lastPick = _picksLeft deleteAt 0;

    //Save history
    _historyBook set [_arrayID,[_lastArrayCount,_lastPick,_picksLeft]];
    if (_deepSave) then {
        profileNamespace setVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", _historyBook];
        saveProfileNamespace;
    } else {
        localNamespace setVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", _historyBook];
    };

    //return
    (_array#_lastPick)
};

//===============================================================
//String array compacting

//Compacts string array ["a","b","b"] to ["a",2,"b"]
NWG_fnc_compactStringArray = {
    // private _array = _this;
    private _result = [];
    private _i = -1;

    //do
    {
        _i = _result find _x;
        if (_i == -1)
            then {_result pushBack 1; _result pushBack _x}
            else {_result set [(_i-1),((_result#(_i-1))+1)]};
    } forEach _this;

    //return
    _this resize 0;
    _this append (_result - [1]);//Remove '1's
    _this
};

//Uncompacts string array ["a",2,"b"] to ["a","b","b"]
NWG_fnc_unCompactStringArray = {
    // private _array = _this;
    private _result = [];
    private _count = 1;

    //do
    {
        if (_x isEqualType 0)
            then {_count = _x}
            else {for "_i" from 1 to _count do {_result pushBack _x}; _count = 1};
    } forEach _this;

    //return
    _this resize 0;
    _this append _result;
    _this
};

//Merges two compacted string arrays ["a",2,"b"]+[2,"b",3,"c"] = ["a",4,"b",3,"c"]
//note: faster alternative to ((A+B) call NWG_fnc_unCompactStringArray) call NWG_fnc_compactStringArray;
NWG_fnc_mergeCompactedStringArrays = {
    params ["_array1","_array2"];

    //Simple cases
    if ((count _array1) == 0) exitWith {_array2+[]};//Shallow copy of the second array
    if ((count _array2) == 0) exitWith {_array1+[]};//Shallow copy of the first array

    //Get compacted array but with unomitted '1' counts
    private _result = [];
    private _count = 1;
    {
        if (_x isEqualType 0) then {
            _count = _x;
        } else {
            _result pushBack _count;
            _result pushBack _x;
            _count = 1;
        };
    } forEach _array1;

    //Merge in the second array
    private _i = -1;
    _count = 1;//Reset count
    {
        if (_x isEqualType 0) then {
            _count = _x;
            continue;
        };

        _i = _result find _x;
        if (_i == -1) then {
            //Element not found, add it
            _result pushBack _count;
            _result pushBack _x;
        } else {
            //Element found, merge counts
            _result set [(_i-1),((_result#(_i-1))+_count)];
        };
        _count = 1;
    } forEach _array2;

    //Omit '1' counts
    _result = _result - [1];

    //return
    _result
};

//===============================================================
//Range
//Returns a random number within the range
NWG_fnc_randomRangeInt = {
    params ["_min","_max"];
    (floor (_min + (random ((_max - _min) + 1))))
};
NWG_fnc_randomRangeFloat = {
    params ["_min","_max"];
    (_min + (random (_max - _min)))
};

//===============================================================
//Players
//Returns array of all players
NWG_fnc_getPlayersAll = {
    // allPlayers - 0.0006, but returns headless clients
    // call BIS_fnc_listPlayers - works fine, but 0.0056
    ((allPlayers - (entities "HeadlessClient_F")) select {alive _x}) //0.0011
};

//Returns an array of players on foot and vehicles occupied by one or more players (array of unique elements)
NWG_fnc_getPlayersOrOccupiedVehicles = {
    private _result = (((call NWG_fnc_getPlayersAll) apply {vehicle _x}) select {alive _x});
    _result arrayIntersect _result//Remove duplicates and return
};

//===============================================================
//Animation
NWG_fnc_playAnimGlobal = {
    params ["_unit","_animName"];
    if (isNil "_unit" || {isNull _unit}) exitWith {"NWG_fnc_playAnimGlobal: unit is Null" call NWG_fnc_logError};
    _this remoteExecCall ["NWG_fnc_playAnim",0];
};

NWG_fnc_playAnim = {
    params ["_unit","_animName"];
    //Force unscheduled environment, see Leopard20's comment on https://community.bistudio.com/wiki/switchMove
    if (canSuspend)
        then {isNil {_unit switchMove _animName; _unit playMoveNow _animName}}
        else {_unit switchMove _animName; _unit playMoveNow _animName};
};

//===============================================================
//Localization
NWG_fnc_localize = {
    //Check localization dictionary
    if (isNil "NWG_LocalizationDictionary") exitWith {_this};
    //Return localized input if such localization exists and input itself if not
    (NWG_LocalizationDictionary getOrDefault [_this,_this])
};

NWG_fnc_localizeDisplay = {
    params ["_display","_controls"];
    if (isNil "_controls") then {_controls = allControls _display};

    //foreach _control in _controls do
    {
        private _cur = _x;
        if (_cur isEqualType 123) then {_cur = _display displayCtrl _cur};
        if (isNull _cur) then {continue};

        private _text = ctrlText _cur;
        if (!isNil "_text" && {_text isNotEqualTo ""}) then {
            _cur ctrlSetText (_text call NWG_fnc_localize);
        };

        private _tooltip = ctrlTooltip _cur;
        if (!isNil "_tooltip" && {_tooltip isNotEqualTo ""}) then {
            _cur ctrlSetTooltip (_tooltip call NWG_fnc_localize);
        };
    } forEach _controls;
};

//===============================================================
//Messaging
//Supported message types: single string or array of format arguments as [template,arg0,arg1...]
NWG_fnc_translateMessage = {
    // private _message = _this;
    private _translate = {
        if (_this isEqualType "")
            then {_this call NWG_fnc_localize}
            else {str _this}
    };

    switch (true) do {
        /*Simple message*/
        case (!(_this isEqualType [])): {_this call _translate};//Single argument (string, int, bool, obj, etc.)
        case ((count _this) <= 1):      {(_this param [0,""]) call _translate};//Single element or empty array
        /*Formatted message*/
        default {format (_this apply {_x call _translate})};//Array of format arguments as [template,arg0,arg1...]
    }
};

NWG_fnc_sideChatMe = {
    // private _message = _this;
    if (!hasInterface || {isNull player}) exitWith {};
    [playerSide,"HQ"] sideChat (_this call NWG_fnc_translateMessage);
};
NWG_fnc_sideChatAll = {
    // private _message = _this;
    _this remoteExec ["NWG_fnc_sideChatMe"];
};

NWG_fnc_systemChatMe = {
    // private _message = _this;
    if (!hasInterface) exitWith {};
    systemChat (_this call NWG_fnc_translateMessage);
};
NWG_fnc_systemChatAll = {
    // private _message = _this;
    _this remoteExec ["NWG_fnc_systemChatMe"];
};

//===============================================================
//Actions
//Adds action to object on every client (MP and JIP compatible, action title localized)
//note: action radius and conditions are hardcoded
NWG_fnc_addActionGlobal = {
    params ["_object","_title","_script"];
    if (isNull _object) exitWith {
        "NWG_fnc_addActionGlobal: object is Null" call NWG_fnc_logError;
    };

    [_object,"NWG_fnc_addAction",[_title,_script]] call NWG_fnc_rqAddCommand;
};

//Adds action to object
//note: action radius and conditions are hardcoded
NWG_fnc_addAction = {
    params ["_object","_title","_script"];
    if (!hasInterface || {isNull _object}) exitWith {};

    _object addAction [
        (_title call NWG_fnc_translateMessage),
        _script,
        nil,   // arguments
        1.5,   // priority
        true,  // showWindow
        true,  // hideOnUse
        "",    // shortcut
        "true",// condition
        4,     // radius
        false, // unconscious
        "",    // selection
        ""     // memoryPoint
    ];
};

//Adds hold action to object on every client (MP and JIP compatible, action title localized)
//note: action radius and conditions are hardcoded
NWG_fnc_addHoldActionGlobal = {
    params ["_object","_title","_icon","_onCompleted",["_onStarted",{}]];
    if (isNull _object) exitWith {
        "NWG_fnc_addHoldActionGlobal: object is Null" call NWG_fnc_logError;
    };

    [_object,"NWG_fnc_addHoldAction",[_title,_icon,_onCompleted,_onStarted]] call NWG_fnc_rqAddCommand;
};

//Adds hold action to object
//note: action radius and conditions are hardcoded
NWG_fnc_addHoldAction = {
    params ["_object","_title","_icon","_onCompleted",["_onStarted",{}]];
    if (!hasInterface || {isNull _object}) exitWith {};

    [
        _object,                         // Object the action is attached to
        (_title call NWG_fnc_translateMessage),  // Title of the action
        _icon,                           // Idle icon shown on screen
        _icon,                           // Progress icon shown on screen
        "(_this distance _target) < 3",  // Condition for the action to start
        "(_caller distance _target) < 3",// Condition for the action to progress
        _onStarted,                      // Code executed when action starts
        {},                              // Code executed on every progress tick
        _onCompleted,                    // Code executed on completion
        {},                              // Code executed on interrupted
        [],                              // Arguments passed to the scripts as _this select 3
        3,                               // Action duration in seconds
        15,                              // Priority
        false,                           // Remove on completion
        false,                           // Show in unconscious state
        true                             // Auto show on screen
    ] call BIS_fnc_holdActionAdd
};

//Set hitIndex for vehicle (actions 'Repair', 'EMI drone action', etc.)
//params:
//	vehicle - vehicle object
//	array - of [index,value,index,value...]
//	actor - (optional, default objNull) unit who will be recorded as person doing the damage
//	useEffects - (optional, default false) if true, effects will be used
//	breakRotor - (optional, default false) if true, rotor will be broken
NWG_fnc_setHitIndex = {
	params ["_vehicle","_array",["_actor",objNull],["_useEffects",false],["_breakRotor",false]];
	if (isNull _vehicle || {!alive _vehicle}) exitWith {"NWG_fnc_setHitIndex: Vehicle is null or dead" call NWG_fnc_logError};
    if ((count _array) == 0) exitWith {};
    if (!local _vehicle) exitWith {_this remoteExec ["NWG_fnc_setHitIndex",_vehicle]};

	for "_i" from 0 to ((count _array) - 1) step 2 do {
		_vehicle setHitIndex [(_array#_i),(_array#(_i+1)),_useEffects,_actor,_actor,_breakRotor];
	};
};

//Set fuel for vehicle
//params:
//	_vehicle - vehicle object
//	_fuel - fuel value (0-1)
NWG_fnc_setFuel = {
	params ["_vehicle","_fuel"];
	if (isNull _vehicle || {!alive _vehicle}) exitWith {};
    if (!local _vehicle) exitWith {_this remoteExec ["NWG_fnc_setFuel",_vehicle]};
	_vehicle setFuel _fuel;
};

//Returns full crew array of a valid vehicle in driver->gunner->commander->turret->cargo order
//note: fixes Arma's fullCrew complete mess of an order driver->cargo->turret->gunner->commander, like wtf
//params: _vehicle - vehicle object
//returns: full crew array or empty array if vehicle is not valid
#define FULL_CREW_INCLUDE_EMPTY true
#define FULL_CREW_UNIT 0
#define FULL_CREW_ROLE 1
#define FULL_CREW_CARGO_INDEX 2
#define FULL_CREW_TURRET_PATH 3
NWG_fnc_getFullCrew = {
	private _vehicle = _this;
    if (isNull _vehicle || {!alive _vehicle}) exitWith {[]};
	if ((["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {_vehicle isKindOf _x}) <= 0) exitWith {[]};

    //Get full crew
	private _fullCrew = fullCrew [_vehicle,"",FULL_CREW_INCLUDE_EMPTY];
	if ((count _fullCrew) <= 1) exitWith {[]};

	//Sort crew by predefined order
	private _order = ["driver","gunner","commander","turret","cargo"];
	_fullCrew = _fullCrew apply {[(_order find (_x#FULL_CREW_ROLE)),(_x#FULL_CREW_CARGO_INDEX),_x]};
	_fullCrew sort true;
	_fullCrew = _fullCrew apply {_x#2};

    //return
    _fullCrew
};

//Places unit into the first available seat in a vehicle
//params:
// _vehicle - vehicle object
// _fullCrew - full crew array from 'NWG_fnc_getFullCrew' (you can modify it before calling this function)
// _unit - unit to place into a seat
// _allowReplacingDead - (optional, default true) if true, unit will be placed into a seat even if it is occupied by another dead unit
//returns: true if unit was placed into a seat, false if there are no available seats
NWG_fnc_placeUnitInFullCrewSeat = {
    params ["_vehicle","_fullCrew","_unit",["_allowReplacingDead",true]];

    //Find next available seat
	private _nextAvailableSeat = if (_allowReplacingDead)
        then {_fullCrew findIf {!alive (_x#FULL_CREW_UNIT)}}
        else {_fullCrew findIf {isNull (_x#FULL_CREW_UNIT)}};
	if (_nextAvailableSeat == -1) exitWith {false};

	//Place unit into the next available seat
	private _newSeat = _fullCrew select _nextAvailableSeat;
	switch (_newSeat#FULL_CREW_ROLE) do {
		case "driver": {
			_unit assignAsDriver _vehicle;
			_unit moveInDriver _vehicle
		};
		case "commander": {
			_unit assignAsCommander _vehicle;
			_unit moveInCommander _vehicle
		};
		case "gunner": {
			_unit assignAsGunner _vehicle;
			_unit moveInGunner _vehicle
		};
		case "turret": {
			_unit assignAsTurret [_vehicle,(_newSeat#FULL_CREW_TURRET_PATH)];
			_unit moveInTurret [_vehicle,(_newSeat#FULL_CREW_TURRET_PATH)]
		};
		case "cargo": {
			_unit assignAsCargo _vehicle;
			_unit moveInCargo [_vehicle,(_newSeat#FULL_CREW_CARGO_INDEX)];
		};
	};

    //return
    true
};
//===============================================================
//Containers
//Clears container cargo in a JIP-friendly manner - only clear what is needed
NWG_fnc_clearContainerCargo = {
    // private _object = _this;
    //Clear in a JIP-friendly manner - only clear what is needed
    if ((count ((getWeaponCargo _this)   param [0,[]])) > 0) then {clearWeaponCargoGlobal _this};
    if ((count ((getMagazineCargo _this) param [0,[]])) > 0) then {clearMagazineCargoGlobal _this};
    if ((count ((getItemCargo _this)     param [0,[]])) > 0) then {clearItemCargoGlobal _this};
    if ((count ((getBackpackCargo _this) param [0,[]])) > 0) then {clearBackpackCargoGlobal _this};
};

//Fix for Arma's 2.20 'setUnitLoadout' shitty behavior
//note: they reverted it back for now, see: https://dev.arma3.com/post/spotrep-00119
//note: I've spent too much time on that, plus they can change it again in the future, so I'm leaving it here
#define BOHEMIA_CHANGED_MIND true
NWG_fnc_setUnitLoadout = {
    params ["_unit","_loadout",["_callback",{}]];
    if (BOHEMIA_CHANGED_MIND) exitWith {_unit setUnitLoadout _loadout; _unit call _callback};//Immediate execution
    if (!alive _unit) exitWith {_unit setUnitLoadout _loadout; _unit call _callback};//Should work fine for dead units
    if (!isSwitchingWeapon _unit) exitWith {_unit setUnitLoadout _loadout; _unit call _callback};//Should be no problem with stable units

    private _queue = localNamespace getVariable ["NWG_fnc_setUnitLoadout_queue",[]];
    _queue pushBack _this;//[_unit,_loadout,_callback]
    localNamespace setVariable ["NWG_fnc_setUnitLoadout_queue",_queue];

    private _handle = localNamespace getVariable ["NWG_fnc_setUnitLoadout_handle",scriptNull];
    if (!isNull _handle && {!scriptDone _handle}) exitWith {};//Already running

    _handle = [] spawn {
        waitUntil {
            private _queue = localNamespace getVariable ["NWG_fnc_setUnitLoadout_queue",[]];
            reverse _queue;
            {
                _x params ["_unit","_loadout",["_callback",{}]];
                if (isNull _unit) then {_queue deleteAt _forEachIndex; continue};
                if (alive _unit && {isSwitchingWeapon _unit}) then {continue};
                _unit setUnitLoadout _loadout;
                _unit call _callback;
                _queue deleteAt _forEachIndex;
            } forEachReversed _queue;
            reverse _queue;
            localNamespace setVariable ["NWG_fnc_setUnitLoadout_queue",_queue];
            sleep 0.1;
            //Exit the cycle if:
            (count _queue) == 0
        };
    };
    localNamespace setVariable ["NWG_fnc_setUnitLoadout_handle",_handle];
};

//===============================================================
//Modules (lightweight version of BIS modules)
NWG_fnc_moduleLightning = {
	private _object = _this;
	private _pos = position _object;
    private _owner = _object getVariable ["NWG_owner",objNull];

	//Create explosion effect
	private _bolt = createVehicle ["LightningBolt",_pos,[],0,"CAN_COLLIDE"];
    if (!isNull _owner) then {_bolt setShotParents [_owner, _owner]};
	_bolt setPosATL _pos;
	_bolt setDamage 1;

	//Create lightning effect on every machine (because sleep and because commands are LA LE)
	_pos remoteExec ["NWG_fnc_moduleLightning_Local",0];
};

NWG_fnc_moduleLightning_Local = {
	private _pos = _this;
	if (!hasInterface) exitWith {};

	private _light = "#lightpoint" createVehicleLocal _pos;
	_light setPosATL (_pos vectorAdd [0,0,10]);
	_light setLightDayLight true;
	_light setLightBrightness 300;
	_light setLightAmbient [0.05, 0.05, 0.1];
	_light setLightColor [1, 1, 2];

	sleep 0.15;
	_light setLightBrightness 0;
	sleep (random 0.15);

	private _class = selectRandom ["lightning1_F","lightning2_F"];
	private _lightning = _class createVehicleLocal [100,100,100];
	_lightning setDir (random 360);
	_lightning setPos _pos;
	for "_i" from 0 to 3 do {
		_light setLightBrightness (100 + random 100);
		sleep 0.15;
	};

	deleteVehicle _lightning;
	deleteVehicle _light;
};
