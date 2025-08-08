//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Wait for player to be valid
	waitUntil {sleep 0.1; !isNull player};
	waitUntil {sleep 0.1; alive player};
	waitUntil {sleep 0.1; local player};
	waitUntil {sleep 0.1; isPlayer player};

	//Add event handlers
    player addEventHandler ["Respawn",{call NWG_PSU_ShutMeUpGlobal}];
	player addEventHandler ["InventoryClosed",{call NWG_PSU_ShutUpEveryoneLocal}];

	//Invoke method
    call NWG_PSU_ShutMeUpGlobal;
};

//================================================================================================================
//================================================================================================================
//Method
NWG_PSU_ShutMeUpGlobal = {
    player call NWG_fnc_shutMeUp;
	player remoteExec ["NWG_fnc_shutMeUp"];
};

NWG_PSU_ShutUpEveryoneLocal = {
    private _players = call NWG_fnc_getPlayersAll;
    {_x call NWG_fnc_shutMeUp} forEach _players;
};

//================================================================================================================
//================================================================================================================
[] spawn _Init
