/*All Wheel status*/
//All wheel signature and checks
//note: used in conjunction with "SIGNATURE_REQUIRED" setting
//note: the point is when this setting is on, only marked(signed) vehicles will get this action
//Sign vehicle
//params:
// - vehicle - Object
//return:
// - success - Boolean
NWG_fnc_avAllWheelSign = {
	// private _vehicle = _this;
	if (isNull _this) exitWith {false};
	_this setVariable ["NWG_AV_AllWheel_Sign",true,true];
	true
};

//Check if vehicle is signed
//params:
// - vehicle - Object
//return:
// - success - Boolean
NWG_fnc_avAllWheelIsSigned = {
	// private _vehicle = _this;
	if (isNull _this) exitWith {false};
	_this getVariable ["NWG_AV_AllWheel_Sign",false]
};