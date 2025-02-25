//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_LISTBOX	1501
// #define IDC_DROPDOWN 2101

//================================================================================================================
//================================================================================================================
//Settings
NWG_UP_05Info_Settings = createHashMapFromArray [
	["WINDOW_NAME","#UP_INFO_TITLE#"],
	["PLANSHET_ROWS",[
		["#UP_INFO_GENERAL#",{name player},{player call NWG_fnc_pGetMyLvl},{player call NWG_fnc_pGetMyExp}],
		["#UP_INFO_TAXI_LVL#",{(player call NWG_fnc_pGetMyTaxiLvl) * 10}],
		["#UP_INFO_TRDR_LVL#",{(player call NWG_fnc_pGetMyTraderLvl) * 10}],
		["#UP_INFO_COMM_LVL#",{(player call NWG_fnc_pGetMySupportLvl) * 10}]
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
	private _items = (NWG_UP_05Info_Settings get "PLANSHET_ROWS") apply {
		format ([((_x#0) call NWG_fnc_localize)] + ((_x select [1]) apply {call _x}))
	};

	//Open interface
	private _interface = [_windowName,_items,[],{}] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_06Settings_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	true
};
