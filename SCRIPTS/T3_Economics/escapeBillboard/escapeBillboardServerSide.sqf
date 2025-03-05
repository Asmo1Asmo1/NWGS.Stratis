//================================================================================================================
//================================================================================================================
//Settings
NWG_ESCB_SER_Settings = createHashMapFromArray [
	["MAX_WINNERS",16],//Max number of winners names that can be displayed on the billboard
	["RESPONSE_TIMEOUT",30],//Timeout in seconds for response to client

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_ESCB_SER_billboardObject = nil;
NWG_ESCB_SER_winners = nil;

//================================================================================================================
//================================================================================================================
//Billboard object
NWG_ESCB_SER_SetBillboardObject = {
    // private _billboard = _this;
    NWG_ESCB_SER_billboardObject = _this;
};

//================================================================================================================
//================================================================================================================
//Winners names
NWG_ESCB_SER_SetWinners = {
	// private _winners = _this;
	if !(isNil "NWG_ESCB_SER_winners") exitWith {
		"NWG_ESCB_SER_SetWinners: Winners are already set" call NWG_fnc_logError;
	};
	NWG_ESCB_SER_winners = _this;
};

NWG_ESCB_SER_AddWinners = {
	private _newWinners = _this;
	if (isNil "NWG_ESCB_SER_winners") exitWith {
		"NWG_ESCB_SER_AddWinners: Cur winners are not set" call NWG_fnc_logError;
	};
	if !(_newWinners isEqualType []) exitWith {
		"NWG_ESCB_SER_AddWinners: Invalid new winners" call NWG_fnc_logError;
	};

	//Add new winners
	_newWinners = _newWinners + [];//Shallow copy
	{_newWinners pushBackUnique _x} forEach NWG_ESCB_SER_winners;//Add unique current winners
	private _limit = NWG_ESCB_SER_Settings get "MAX_WINNERS";
	if ((count _newWinners) > _limit) then {_newWinners resize _limit};//Limit to max
	NWG_ESCB_SER_winners = _newWinners;

	//return
	_newWinners
};

//================================================================================================================
//================================================================================================================
//Client request
NWG_ESCB_SER_OnValuesRequest = {
    private _caller = remoteExecutedOwner;
    if (isDedicated && _caller <=  0) exitWith {
        (format ["NWG_ESCB_SER_OnValuesRequest: Caller can not be identified! callerID:%1",_caller]) call NWG_fnc_logError;
    };

	private _timeoutAt = time + (NWG_ESCB_SER_Settings get "RESPONSE_TIMEOUT");
	private _values = nil;
	waitUntil {
		if (time > _timeoutAt) exitWith {true};
		if (isNil "NWG_ESCB_SER_billboardObject" || {isNil "NWG_ESCB_SER_winners"}) exitWith {sleep 1; false};//Wait until both are set
		_values = [NWG_ESCB_SER_billboardObject,NWG_ESCB_SER_winners];
		true
	};
	if (isNil "_values") exitWith {
		"NWG_ESCB_SER_OnValuesRequest: Timeout reached! Values are not set" call NWG_fnc_logError;
	};

	//return
	_values remoteExec ["NWG_fnc_escbValuesResponse",_caller];
};