/*
	Annotation:
	Addon for the loot storage system.
	Allows to open the loot storage on any owned vehicle.
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_LS_AV_Settings = createHashMapFromArray [
	["ASSIGN_ACTION",true],
	["ACTION_TITLE","#LS_STORAGE_ACTION_TITLE_2#"],
	["ACTION_PRIORITY",0],
	["ACTION_SHOW_WINDOW",true],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	player addEventHandler ["Respawn",{call NWG_LS_AV_AssignAction}];
	call NWG_LS_AV_AssignAction;
};

//================================================================================================================
//================================================================================================================
//Assign action
NWG_LS_AV_AssignAction = {
	if !(NWG_LS_AV_Settings get "ASSIGN_ACTION") exitWith {};//Disabled
	private _title = NWG_LS_AV_Settings get "ACTION_TITLE";
	private _priority = NWG_LS_AV_Settings get "ACTION_PRIORITY";
	private _showWindow = NWG_LS_AV_Settings get "ACTION_SHOW_WINDOW";

	player addAction [
		(_title call NWG_fnc_localize),// title
		{call NWG_fnc_lsOpenStorage},// script
		nil,        // arguments
		_priority,  // priority
		_showWindow,      // showWindow
		true,       // hideOnUse
		"",         // shortcut
		"call NWG_LS_AV_ActionCondition",// condition
		-1,         // radius
		false       // unconscious
	];
};

//================================================================================================================
//================================================================================================================
//Action condition
NWG_LS_AV_ActionCondition = {
	if (isNull (call NWG_fnc_radarGetVehInFront)) exitWith {false};
	((call NWG_fnc_radarGetVehInFront) call NWG_fnc_vownGetOwner) isEqualTo player
};

//================================================================================================================
//================================================================================================================
call _Init;