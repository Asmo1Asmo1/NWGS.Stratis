//================================================================================================================
//================================================================================================================
//Assign ownership
NWG_VEHOWN_SetVehicleOwner = {
	params ["_vehicle","_player"];
	_vehicle setVariable ["NWG_VEHOWN_Owner",(name _player),true];
};

//================================================================================================================
//================================================================================================================
//Get ownership
NWG_VEHOWN_GetVehicleOwner = {
	// private _vehicle = _this;
	private _ownerName = _this getVariable ["NWG_VEHOWN_Owner",""];
	private _allPlayers = call NWG_fnc_getPlayersAll;
	private _i = _allPlayers findIf {(name _x) isEqualTo _ownerName};
	//return
	_allPlayers param [_i,objNull]
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