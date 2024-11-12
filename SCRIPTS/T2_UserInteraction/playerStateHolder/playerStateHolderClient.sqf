//================================================================================================================
//================================================================================================================
//Settings
NWG_PSH_CLI_Settings = createHashMapFromArray [
	["BUFFERING_DELAY",0.5],//Delay before invoking state update on the server - just to avoid flooding
	["LOG_STATE_CHANGE",false],//Log incoming events

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_PSH_CLI_startNotify = false;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	[] spawn {
		waitUntil {sleep 0.1; !isNull player};
		waitUntil {sleep 0.1; alive player};
		waitUntil {sleep 0.1; local player};
		waitUntil {sleep 0.1; isPlayer player};

		player addEventHandler ["Respawn",{"Respawn" call NWG_PSH_CLI_OnClientStateChange}];
		player call NWG_fnc_pshInvokePlayerJoin;
		NWG_PSH_CLI_startNotify = true;
	};
};

//================================================================================================================
//================================================================================================================
//Server notification
NWG_PSH_CLI_notifyAt = 0;
NWG_PSH_CLI_notifyHandle = scriptNull;
NWG_PSH_CLI_OnClientStateChange = {
	// private _reason = _this;

	//Log
	if (NWG_PSH_CLI_Settings get "LOG_STATE_CHANGE")
		then {(format ["NWG_PSH_CLI_OnClientStateChange: Reason: '%1', Time: %2, IsStartNotify: %3",_this,time,NWG_PSH_CLI_startNotify]) call NWG_fnc_logInfo};

	//Check if it is too early
	if !(NWG_PSH_CLI_startNotify) exitWith {};//Ignore until 'player join' invoked

	//Setup buffered notification (buffer by time to avoid network flood)
	NWG_PSH_CLI_notifyAt = time + (NWG_PSH_CLI_Settings get "BUFFERING_DELAY");
	if (isNull NWG_PSH_CLI_notifyHandle || {scriptDone NWG_PSH_CLI_notifyHandle}) then {
		NWG_PSH_CLI_notifyHandle = [] spawn NWG_PSH_CLI_NotifyServer_Core;
	};
};
NWG_PSH_CLI_NotifyServer_Core = {
	waitUntil {sleep 0.1; time >= NWG_PSH_CLI_notifyAt};
	player call NWG_fnc_pshInvokeStateUpdate;
};

//================================================================================================================
call _Init;
