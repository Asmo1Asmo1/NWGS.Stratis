/*Any->Wallet*/
NWG_fnc_wltGetPlayerMoney = {
    // private _player = _this;
    //return
    _this call NWG_WLT_GetPlayerMoney
};

NWG_fnc_wltAddPlayerMoney = {
	// params ["_player","_amount"];
	_this call NWG_WLT_AddPlayerMoney;
};

NWG_fnc_wltSetPlayerMoney = {
	// params ["_player","_amount"];
	_this call NWG_WLT_SetPlayerMoney;
};

NWG_fnc_wltFormatMoney = {
	// private _money = _this;
	//return
	_this call NWG_WLT_MoneyToString
};
