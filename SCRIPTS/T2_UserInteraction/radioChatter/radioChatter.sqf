//================================================================================================================
//================================================================================================================
//Settings
NWG_RC_Settings = createHashMapFromArray [
	/*Sounds*/
	["SOUNDS",[
		"QRF_CSAT_report_Soldier_A_01_Chinese01_Processed",
		// "QRF_CSAT_report_Soldier_A_01_Chinese02_Processed",
		"QRF_CSAT_report_Soldier_A_01_Chinese03_Processed",
		"QRF_CSAT_report_Soldier_A_01_Chinese04_Processed",
		"QRF_CSAT_report_Soldier_A_02_Chinese01_Processed",
		// "QRF_CSAT_report_Soldier_A_02_Chinese02_Processed",
		// "QRF_CSAT_report_Soldier_A_02_Chinese03_Processed",
		// "QRF_CSAT_report_Soldier_A_02_Chinese04_Processed",
		"QRF_CSAT_report_Soldier_A_03_Chinese01_Processed",
		"QRF_CSAT_report_Soldier_A_03_Chinese02_Processed",
		"QRF_CSAT_report_Soldier_A_03_Chinese03_Processed",
		"QRF_CSAT_report_Soldier_A_03_Chinese04_Processed",
		"QRF_Gendarmerie_report_Gendarme_A_01_Vincent_Processed",
		"QRF_Gendarmerie_report_Gendarme_A_02_Vincent_Processed",
		"QRF_Gendarmerie_report_Gendarme_A_Ahmeed_01_Processed",
		"QRF_Gendarmerie_report_Gendarme_A_Ahmeed_02_Processed"
	]],

	/*Delay*/
	["DELAY",0.25],

	/*Channels to operate on*/
	["CHANNELS",[3]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_RC_radioKeys = [];
NWG_RC_transmitting = false;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Setup key handlers
	waitUntil {sleep 0.1; !isNull (findDisplay 46)};//46 is a mission display, see https://community.bistudio.com/wiki/findDisplay
	(findDisplay 46) displayAddEventHandler ["KeyDown",{_this call NWG_RC_OnKeyDown}];
	(findDisplay 46) displayAddEventHandler ["KeyUp",  {_this call NWG_RC_OnKeyUp}];

	//Setup radio keys
	private _radioKeys = [];
	_radioKeys append (actionKeys "pushToTalk");
	_radioKeys append (actionKeys "voiceOverNet");
	_radioKeys append (actionKeys "PushToTalkAll");
	_radioKeys append (actionKeys "PushToTalkSide");
	_radioKeys append (actionKeys "PushToTalkCommand");
	_radioKeys append (actionKeys "PushToTalkGroup");
	_radioKeys append (actionKeys "PushToTalkVehicle");
	_radioKeys = _radioKeys arrayIntersect _radioKeys;//Remove duplicates
	NWG_RC_radioKeys = _radioKeys;
};

//================================================================================================================
//================================================================================================================
//Event handlers
NWG_RC_OnKeyDown = {
	// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
	params ["","_key"];
	if !(_key in NWG_RC_radioKeys) exitWith {};
	if !(currentChannel in (NWG_RC_Settings get "CHANNELS")) exitWith {};
	if (NWG_RC_transmitting) exitWith {};//Prevent multiple executions while holding the key
	NWG_RC_transmitting = true;
	remoteExec ["NWG_fnc_rcPlay"];
};
NWG_RC_OnKeyUp = {
	// params ["_displayOrControl","_key","_shift","_ctrl","_alt"];
	params ["","_key"];
	if !(_key in NWG_RC_radioKeys) exitWith {};
	if !(currentChannel in (NWG_RC_Settings get "CHANNELS")) exitWith {};
	NWG_RC_transmitting = false;
	remoteExec ["NWG_fnc_rcPlay"];
};

//================================================================================================================
//================================================================================================================
//Play radio chatter sound
NWG_RC_Play = {
	params ["_sound"];
	if (isNil "_sound") then {_sound = selectRandom (NWG_RC_Settings get "SOUNDS")};
	private _soundObject = playSound _sound;
	if (canSuspend)
		then {sleep (NWG_RC_Settings get "DELAY")}
		else {"NWG_RC_Play: This method must be called in scheduled environment" call NWG_fnc_logError};
	deleteVehicle _soundObject;
};

//================================================================================================================
//================================================================================================================
[] spawn _Init