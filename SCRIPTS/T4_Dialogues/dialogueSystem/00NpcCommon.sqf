/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
*/

//================================================================================================================
//================================================================================================================
//dice logic
NWG_DLGHLP_Dice = {
	params ["_req","_dice"];
	(_req > (random _dice))
};

//================================================================================================================
//================================================================================================================
//money logic
NWG_DLGHLP_HasEnoughMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) >= _this
};

NWG_DLGHLP_HasLessMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) < _this
};

NWG_DLGHLP_HasMoreMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) > ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};

NWG_DLGHLP_HasLessOrEqMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) <= ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};
