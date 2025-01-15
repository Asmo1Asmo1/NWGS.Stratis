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
    player addEventHandler ["Respawn",{call NWG_PSU_ShutMeUp}];
	player addEventHandler ["InventoryClosed",{call NWG_PSU_ShutMeUp}];

	//Invoke method
    call NWG_PSU_ShutMeUp;
};

//================================================================================================================
//================================================================================================================
//Method
NWG_PSU_ShutMeUp = {
    player call NWG_fnc_shutMeUp;
	player remoteExec ["NWG_fnc_shutMeUp"];
};

//================================================================================================================
//================================================================================================================
[] spawn _Init
