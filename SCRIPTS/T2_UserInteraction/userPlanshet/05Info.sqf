//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_LISTBOX	1501
// #define IDC_DROPDOWN 2101

#define INFO_TEMPLATE 0
#define INFO_DATA_GET 1

//================================================================================================================
//================================================================================================================
//Settings
NWG_UP_05Info_Settings = createHashMapFromArray [
	["WINDOW_NAME","#UP_INFO_TITLE#"],
	["PLANSHET_ROWS",[
		["#UP_INFO_NAME#",{name player}],
		["#UP_INFO_EXP#",{call NWG_fnc_pGetMyExp}],
		["#UP_INFO_LVL#",{call NWG_fnc_pGetMyLvl}],
		["#UP_INFO_TAXI_LVL#",{(call NWG_fnc_pGetMyTaxiLvl) * 10}],
		["#UP_INFO_TRDR_LVL#",{(call NWG_fnc_pGetMyTraderLvl) * 10}],
		["#UP_INFO_COMM_LVL#",{call NWG_fnc_pGetMySupportLvl}]
	]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Category
NWG_UP_05Info_Open = {
	disableSerialization;

	//Prepare items, data and callback
	private _windowName = NWG_UP_05Info_Settings get "WINDOW_NAME";
	private _items = (NWG_UP_05Info_Settings get "PLANSHET_ROWS") apply {format [((_x#INFO_TEMPLATE) call NWG_fnc_localize),(call (_x#INFO_DATA_GET))]};

	//Open interface
	private _interface = [_windowName,_items,[],{}] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_06Settings_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	true
};
