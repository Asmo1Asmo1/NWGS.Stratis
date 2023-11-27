//===============================================================
//Error logging

//Logs an error to the server's RPT file even if called from a client
//params: _message - message to log
NWG_fnc_logError = {
    // private _message = _this;
    diag_log formatText ["  [ERROR] #### %1",_this];
    if (!isServer) then {_this remoteExec ["NWG_fnc_logError", 2]};
};

//===============================================================
//Array manipulation

//Shuffles array and returns it
//params: _array - array to shuffle
//returns: shuffled array (modifies the input array)
//note: modifies the input array
//note: previously known as 'KK_fnc_arrayShuffle'
//note: made by Nelson Duarte, optimised by Killzone_Kid, optimised by HOPA_EHOTA
NWG_fnc_arrayShuffle = {
    //private _array = _this;
	for "_i" from 1 to (count _this) do {_this pushBack (_this deleteAt (floor (random (count _this))))};
    //return
	_this
};

//Shifts array elements by random amount
//params: _array - array to shift
//returns: shifted array (modifies the input array)
//note: modifies the input array
//note: there is no guarantee that the array will be shifted at all
NWG_fnc_arrayRandomShift = {
    //private _array = _this;
    private _i = floor (random (count _this));
    private _result = (_this select [_i,(count _this)]) + (_this select [0,_i]);
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

    //Check arguments
    if (!(_this isEqualTypeParams [[],""]) || {_arrayID isEqualTo ""}) exitWith {
        (format ["NWG_fnc_selectRandomGuaranteed: invalid arguments '%1'",_this]) call NWG_fnc_logError;
        nil
    };

    //Check obvious case
    private _arrayCount = count _array;
    if (_arrayCount <= 1) exitWith {_array param [0]};

    //Get history of previous picks (ID tree)
    private _historyBook = if (_deepSave) then {
        (profileNamespace getVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", createHashMap])
    } else {
        (localNamespace getVariable ["NWG_fnc_selectRandomGuaranteed_historyBook", createHashMap])
    };
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
            _history set [_lastPick,1];
            _history set [_freeSpace,2];
            _freeSpace
        };
        default {
            //There is no free space left - reset history and pick new random index
            private _newIndex = -1;
            while {_newIndex = floor (random _arrayCount); _newIndex == _lastPick} do {};
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
//Players
//Returns array of all players
//params: none
//returns: array of all players
NWG_fnc_getPlayersAll =
{
    // allPlayers - 0.0006, but returns headless clients
    // call BIS_fnc_listPlayers - works fine, but 0.0056
    (allPlayers - (entities "HeadlessClient_F")) //0.0011
};

//Returns array of all vehicles of players
//params: none
//returns: array of vehicles
//note: includes 'isKindOf "Man"' vehicles as well (players themselves)
//note: returns array of uniqe objects
NWG_fnc_getPlayerVehiclesAll =
{
    private _result = (((call NWG_fnc_getPlayersAll) apply {vehicle _x}) select {alive _x});
    _result arrayIntersect _result//Remove duplicates and return
};