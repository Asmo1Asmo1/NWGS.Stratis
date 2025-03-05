/*Other systems->Server*/
//Set billboard object
//params: _billboard - object
NWG_fnc_escbSetBillboardObject = {
    // private _billboard = _this;
    if !(_this isEqualType objNull) exitWith {
        "NWG_fnc_escbSetBillboardObject: Invalid billboard" call NWG_fnc_logError;
	};
	if (isNull _this) exitWith {
        "NWG_fnc_escbSetBillboardObject: Billboard is null" call NWG_fnc_logError;
	};

	_this call NWG_ESCB_SER_SetBillboardObject;
};

//Set winners names
//params: _winners - array of strings
NWG_fnc_escbSetWinners = {
    // private _winners = _this;
	if !(_this isEqualType []) exitWith {
        "NWG_fnc_escbSetWinners: Invalid winners" call NWG_fnc_logError;
	};
	_this call NWG_ESCB_SER_SetWinners;
};

//Add winners names to billboard
//params: _winners - array of strings
//returns: array of strings - winners names after applying limits and other stuff
NWG_fnc_escbAddWinners = {
    // private _winners = _this;
	if !(_this isEqualType []) exitWith {
        "NWG_fnc_escbAddWinners: Invalid winners" call NWG_fnc_logError;
	};
    _this call NWG_ESCB_SER_AddWinners
};

/*Client<->Server*/
//Request billboard values from server
//note: caller is defined internally
NWG_fnc_escbRequestValues = {
	call NWG_ESCB_SER_OnValuesRequest;
};

//Server response to billboard values request
NWG_fnc_escbValuesResponse = {
    // params ["_billboardObject","_winners"];
	_this call NWG_ESCB_CLI_OnValuesResponse;
};
