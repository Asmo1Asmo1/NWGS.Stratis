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
