//================================================================================================================
//================================================================================================================
//Checking vanilla vehicles list for adding to dynamic shop items
// call NWG_VSHOP_ValidateVehiclesCatalogue
NWG_VSHOP_ValidateVehiclesCatalogue = {
	private _cataloguePath = NWG_VSHOP_SER_Settings get "CATALOGUE_PATH_VANILLA";
	private _catalogue = call (_cataloguePath call NWG_fnc_compile);
	if (isNil "_catalogue" || {!(_catalogue isEqualType [])}) exitWith {
		//return to console
		format ["Failed to compile catalogue: '%1'",_cataloguePath]
	};
	if ((count _catalogue) == 0) exitWith {
		format ["Catalogue is empty: '%1'",_cataloguePath]
	};

	_catalogue = _catalogue call NWG_VSHOP_SER_ArrayToChart;
	(_catalogue call NWG_VSHOP_SER_ValidateItemsChart) params ["","_isValid"];
	if (!_isValid) exitWith {
		format ["Invalid items found in catalogue: '%1'",_cataloguePath]
	};

	format ["Catalogue is valid: '%1'",_cataloguePath]
};

//================================================================================================================
//================================================================================================================
//Checking if vehicle has weapons (use same vanilla catalogue for testing)
// call NWG_VSHOP_SER_IsArmedVehicle_Test
NWG_VSHOP_SER_IsArmedVehicle_Test = {
	private _cataloguePath = NWG_VSHOP_SER_Settings get "CATALOGUE_PATH_VANILLA";
	private _catalogue = call (_cataloguePath call NWG_fnc_compile);
	if (isNil "_catalogue" || {!(_catalogue isEqualType [])}) exitWith {
		format ["Failed to compile catalogue: '%1'",_cataloguePath]
	};
	if ((count _catalogue) == 0) exitWith {
		format ["Catalogue is empty: '%1'",_cataloguePath]
	};

	private _armedVehicles = [];
	private _unarmedVehicles = [];
	{
		if (_x call NWG_VSHOP_SER_IsArmedVehicle)
			then {_armedVehicles pushBack _x}
			else {_unarmedVehicles pushBack _x};
	} forEach _catalogue;

	private _result = ["==== ARMED VEHICLES ===="] + _armedVehicles + ["==== UNARMED VEHICLES ===="] + _unarmedVehicles;
	_result call NWG_fnc_testDumpToRptAndClipboard;
	"Result saved to RPT and clipboard"
};
