//================================================================================================================
//================================================================================================================
//Vehicle fix (Repair action)
NWG_AI_VehicleFix_partsMemorized = [];
NWG_AI_VehicleFix_MemorizeParts = {
	private _veh = _this;
	(getAllHitPointsDamage _veh) params ["_vehParts"];
	{
		NWG_AI_VehicleFix_partsMemorized pushBackUnique _x;
	} forEach _vehParts;
	NWG_AI_VehicleFix_partsMemorized sort true;
};
NWG_AI_VehicleFix_MemorizeParts_AllVehsAround = {
	private _vehsAround = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],500];
	{_x call NWG_AI_VehicleFix_MemorizeParts} forEach _vehsAround;
	NWG_AI_VehicleFix_partsMemorized call NWG_fnc_testDumpToRptAndClipboard
};

NWG_AI_VehicleFix_DamageAllVehsAround = {
	private _vehsAround = player nearEntities [["Car","Tank","Helicopter","Plane","Ship"],500];
	{_x setDamage 0.75} forEach _vehsAround;
};