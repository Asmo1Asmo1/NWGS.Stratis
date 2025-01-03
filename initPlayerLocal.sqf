/* --- Scripts receiving --- */
NWG_fnc_clientScriptsReceive = {
    // private _scripts = _this;
    {call _x} forEach _this;
};

/* --- Conditions --- */
waitUntil {(!isNull player && {local player})};//Wait for player to be valid
player allowDamage false;//Fix on spawn kill (will be removed in medicine)
waitUntil {!isNil "NWG_SER_ServerReady"};//Wait for server

/* --- Setup --- */
//Setup dynamic groups (the U button by default) - client side
["InitializePlayer", [player, true]] call BIS_fnc_dynamicGroups;

//Request client scripts that are stored on the server
[player,language] remoteExec ["NWG_fnc_playerScriptsRequest",2];