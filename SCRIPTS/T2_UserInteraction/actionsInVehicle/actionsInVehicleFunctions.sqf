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
