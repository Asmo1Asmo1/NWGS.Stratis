//================================================================================================================
//================================================================================================================
//Fields
NWG_MO_processing = false;
NWG_MO_onMapClick = {};
NWG_MO_onMapClose = {};

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
    addMissionEventHandler ["MapSingleClick",{_this call NWG_MO_OnMapClick}];
    addMissionEventHandler ["Map",{_this call NWG_MO_OnMapClose}];
};

//================================================================================================================
//================================================================================================================
//Open/Close commands
NWG_MO_OpenMap = {
	params [["_onMapClick",{}],["_onMapClose",{}]];

	//Ensure player has map in their inventory
	if ( (((getUnitLoadout player) param [9,[]]) param [0,""]) isEqualTo "") then {
		player addItem "ItemMap";
		player assignItem "ItemMap"
	};

	//Open map and enable processing
	openMap true;
	NWG_MO_processing = true;
	NWG_MO_onMapClick = _onMapClick;
	NWG_MO_onMapClose = _onMapClose;
};

NWG_MO_CloseMap = {
	NWG_MO_processing = false;
	NWG_MO_onMapClick = {};
	NWG_MO_onMapClose = {};
	openMap false;
};

//================================================================================================================
//================================================================================================================
//Handlers
NWG_MO_OnMapClick = {
	//params ["_units","_pos","_alt","_shift"];
	if (!NWG_MO_processing) exitWith {};
	(_this#1) call NWG_MO_onMapClick;
};

NWG_MO_OnMapClose = {
	//params ["_mapIsOpened","_mapIsForced"];
	if (!NWG_MO_processing) exitWith {};
	if (_this#0) exitWith {};
	call NWG_MO_onMapClose;
	call NWG_MO_CloseMap;
};

//================================================================================================================
//================================================================================================================
call _Init;