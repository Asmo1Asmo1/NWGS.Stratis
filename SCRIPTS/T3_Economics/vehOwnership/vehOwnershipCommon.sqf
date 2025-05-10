//================================================================================================================
//================================================================================================================
//Assign ownership
NWG_VEHOWN_SetVehicleOwner = {
	params ["_vehicle","_playerName"];
	_vehicle setVariable ["NWG_VEHOWN_Owner",_playerName,true];
};

//================================================================================================================
//================================================================================================================
//Get ownership
NWG_VEHOWN_IsPlayerOwner = {
	params ["_vehicle","_player"];
	(_vehicle getVariable ["NWG_VEHOWN_Owner",""]) isEqualTo (name _player)
};

NWG_VEHOWN_GetVehicleOwnerName = {
	// private _vehicle = _this;
	_this getVariable ["NWG_VEHOWN_Owner",""];
};

NWG_VEHOWN_GetOwnedVehicles = {
	//private _player = _this;
	private _ownerName = name _this;
	private _allVehicles = entities [["Car","Tank","Helicopter","Plane","Ship"],[],false,true];
	//return
	_allVehicles select {
		alive _x && {
		(_x getVariable ["NWG_VEHOWN_Owner",""]) isEqualTo _ownerName}
	}
};

NWG_VEHOWN_GetOwnedVehiclesGroup = {
	//private _group = _this;
	private _owners = ((units _this) select {alive _x && {isPlayer _x}}) apply {name _x};
	private _allVehicles = entities [["Car","Tank","Helicopter","Plane","Ship"],[],false,true];
	//return
	_allVehicles select {
		alive _x && {
		(_x getVariable ["NWG_VEHOWN_Owner",""]) isNotEqualTo "" && {
		(_x getVariable ["NWG_VEHOWN_Owner",""]) in _owners}}
	}
};