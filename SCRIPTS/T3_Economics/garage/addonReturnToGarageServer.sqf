NWG_GRG_RET_ImitateFlyToSky = {
	private _vehicle = _this;
	_vehicle allowDamage false;

	//Deploy the parachute
	private _para = createVehicle ["B_parachute_02_F",_vehicle,[],0,"FLY"];
	_para disableCollisionWith _vehicle;
	_para setDir (getDir _vehicle);
	_para setPosATL ((getPosATL _vehicle) vectorAdd [0,0,1.5]);

	//Fly up
	_para enableSimulationGlobal false;
	_vehicle enableSimulationGlobal false;
	private _posP = (getPosASL _vehicle);
	private _posV = (getPosASL _para);
	private _addHeight = 0.033;
	private _timeoutAt = time + 10;
	waitUntil {
		sleep 0.033;
		if (time > _timeoutAt) exitWith {true};
		_posP = _posP vectorAdd [0,0,_addHeight];
		_posV = _posV vectorAdd [0,0,_addHeight];
		_addHeight = _addHeight + 0.033;
		_para setPosASL _posV;
		_vehicle setPosASL _posP;
		false
	};

	//Delete after delay
	deleteVehicle _para;
	deleteVehicle _vehicle;
};