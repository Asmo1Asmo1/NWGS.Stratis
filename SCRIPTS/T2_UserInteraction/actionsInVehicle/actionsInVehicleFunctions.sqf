//Jump out action
NWG_fnc_avJumpOut = {
	if (call NWG_AV_GeneralCondition)
		then {call NWG_AV_JumpOut_Action};
};

//Seat switch action - Next seat
NWG_fnc_avSeatSwitchNext = {
	if (call NWG_AV_GeneralCondition)
		then {true call NWG_AV_SeatSwitch_Action};
};

//Seat switch action - Previous seat
NWG_fnc_avSeatSwitchPrev = {
	if (call NWG_AV_GeneralCondition)
		then {false call NWG_AV_SeatSwitch_Action};
};

//All wheel action - ON
NWG_fnc_avAllWheelOn = {
	if (call NWG_AV_GeneralCondition && {call NWG_AV_AllWheel_ConditionAssign && {false call NWG_AV_AllWheel_ConditionToggle}})
		then {call NWG_AV_AllWheel_ToggleAction};
};

//All wheel action - OFF
NWG_fnc_avAllWheelOff = {
	if (call NWG_AV_GeneralCondition && {call NWG_AV_AllWheel_ConditionAssign && {true call NWG_AV_AllWheel_ConditionToggle}})
		then {call NWG_AV_AllWheel_ToggleAction};
};

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
	_this call NWG_AV_AllWheel_SignVehicle
};

//Check if vehicle is signed
//params:
// - vehicle - Object
//return:
// - success - Boolean
NWG_fnc_avAllWheelIsSigned = {
	// private _vehicle = _this;
	_this call NWG_AV_AllWheel_IsSigned
};

//Check if vehicle is supported (thus there is a sense to sign it)
//params:
// - vehicle - Object
//return:
// - success - Boolean
NWG_fnc_avAllWheelIsSupported = {
	// private _vehicle = _this;
	_this call NWG_AV_AllWheel_IsSupported
};
