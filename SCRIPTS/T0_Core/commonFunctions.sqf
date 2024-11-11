//===============================================================
//Error logging

//Logs an error to the server's RPT file even if called from a client
//params: _message - message to log
NWG_fnc_logError = {
    // private _message = _this;
    diag_log formatText ["  [ERROR] #### %1",_this];
    if (!isServer) then {_this remoteExec ["NWG_fnc_logError",2]};
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
    private _history = _historyBook getOrDefault [_arrayID,[]];

    //Check history validity and values
    private ["_lastPick","_freeSpace"];
    if ((count _history) == _arrayCount) then {
        //valid, continue the work
        _lastPick = _history find 2;
        _freeSpace = _history find 0;
    } else {
        //invalid, reset history
        _history resize _arrayCount;
        _history = _history apply {0};
        _lastPick = -1;
        _freeSpace = 0;
    };

    //Select random index
    private _index = floor (random _arrayCount);

    //Evaluate the index
    _index = switch (true) do {
        case ((_history#_index) == 0): {
            //We stumbled upon a free space - use it
            if (_lastPick != -1) then {_history set [_lastPick,1]};
            _history set [_index,2];
            _index
        };
        case (_freeSpace != -1): {
            //We stumbled upon occupied space, but there is free space available - use free space
            if (_lastPick != -1) then {_history set [_lastPick,1]};
            _history set [_freeSpace,2];
            _freeSpace
        };
        default {
            //There is no free space left - reset history and pick new random index
            private _newIndex = -1;
            private _tries = 99;//Just in case, apply NASA standards
            while {_newIndex = floor (random _arrayCount); _newIndex == _lastPick && {_tries > 0}} do {_tries = _tries - 1};
            _history = _history apply {0};
            _history set [_newIndex,2];
            _newIndex
        };
    };

    //Save history
    _historyBook set [_arrayID, _history];
    if (_deepSave) then {
        profileNamespace setVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", _historyBook];
        saveProfileNamespace;
    } else {
        localNamespace setVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", _historyBook];
    };

    //return
    (_array#_index)
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
    (allPlayers - (entities "HeadlessClient_F")) //0.0011
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
    // params ["_object","_title","_script"];
    params ["_object"];
    if (isNull _object) exitWith {
        "NWG_fnc_addActionGlobal: object is Null" call NWG_fnc_logError;
    };

    ["NWG_fnc_addAction",_this] remoteExec ["NWG_fnc_clientRemoteExecReliable",0,_object];
};

//Adds action to object
//note: action radius and conditions are hardcoded
NWG_fnc_addAction = {
    params ["_object","_title","_script"];
    if (!hasInterface || {isNull _object}) exitWith {};

    _object addAction [
        (_title call NWG_fnc_localize),
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