/*
	Connector between 'actionsItems' and 'SCRIPTS\T4_Dialogues\dialogueSystem\01NpcTaxi.sqf'
	This module is optional so it uses inner logic of 'medicineClientSide.sqf' and '01NpcTaxi.sqf' without precautions as well as hardcoded values
*/
/*Keep in sync with NWG_DLG_TAXI_Settings */
#define PRICE_CMP_RAW 500
#define PRICE_CMP_KM 100

/*Works on Server side*/
NWG_AI_TC_SetupCampFire = {
	private _campFireObj = _this;

	private _teleportTo = NWG_MIS_SER_playerBase;//From 'missionMachineServerSide.sqf'
	private _price = ((((round ((_campFireObj distance _teleportTo) / 1000))) * PRICE_CMP_KM) + PRICE_CMP_RAW);

	private _title = ["#AI_CAMP_TO_BASE_TITLE#",(_price call NWG_fnc_wltFormatMoney)];
	private _icon = "\a3\ui_f\data\igui\cfg\holdactions\holdaction_unloaddevice_ca.paa";
	private _onCompleted = {call NWG_AI_TC_ToBase};
	[_campFireObj,_title,_icon,_onCompleted] call NWG_fnc_addHoldActionGlobal;
};

/*Works on Client side*/
NWG_AI_TC_ToBase = {
	//Get respawn point from 'medicineClientSide.sqf' to use as a teleportation point (it is ASL type)
	private _teleportTo = NWG_MED_CLI_respawnPoint;
	if (_teleportTo isEqualTo []) exitWith {
		"NWG_AI_TC_ToBase: Respawn point is not set" call NWG_fnc_logError;
		"#TAXI_INV_DROP_POINT#" call NWG_fnc_systemChatMe;
	};

	//Check if there are enemies nearby (enemies side is hardcoded to 'west')
	private _enemiesNear = ((units west) findIf {alive _x && {(_x distance player) < 100}}) != -1;
	if (_enemiesNear) exitWith {
		private _message = "#AI_CAMP_TO_BASE_ENEMIES#";
		_message call NWG_fnc_systemChatMe;
		hint (_message call NWG_fnc_localize);
	};

	//Calculate the price by re-using inner logic of '01NpcTaxi.sqf' dialogue addon
	private _price = ((((round ((player distance _teleportTo) / 1000))) * PRICE_CMP_KM) + PRICE_CMP_RAW);
	if ((player call NWG_fnc_wltGetPlayerMoney) < _price) exitWith {
		private _message = format [("#AI_CAMP_TO_BASE_MONEY_LOW#" call NWG_fnc_localize),(_price call NWG_fnc_wltFormatMoney)];
		_message call NWG_fnc_systemChatMe;
		hint _message;
	};

	//Pay for the taxi
	[player,-_price] call NWG_fnc_wltAddPlayerMoney;

	//Teleport player to the respawn point
	player setPosASL _teleportTo;
};