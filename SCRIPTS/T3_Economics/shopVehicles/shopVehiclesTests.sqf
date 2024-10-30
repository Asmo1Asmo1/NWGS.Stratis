// -2500 call NWG_VSHOP_CLI_TRA_BalanceLosses_Test;
NWG_VSHOP_CLI_TRA_BalanceLosses_Test = {
	private _totalDebt = _this;
	private _moneyArray = [0,50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000];
	private _players = ["1","2","3","4","5"];
	private _moneyMap = createHashMapFromArray (_players apply {[_x,(selectRandom _moneyArray)]});
	NWG_VSHOP_MockMoneyGet = _moneyMap;

	//Re-define NWG_fnc_wltGetPlayerMoney
	NWG_fnc_wltGetPlayerMoney = {
		// private _player = _this;
		NWG_VSHOP_MockMoneyGet getOrDefault [_this,0]
	};

	private _balanced = [_totalDebt,_players] call NWG_VSHOP_CLI_TRA_BalanceLosses;
	_balanced call NWG_fnc_testDumpToRptAndClipboard;

	//Check that math is correct
	private _totalPaid = 0;
	{_totalPaid = _totalPaid + (_x#1)} forEach _balanced;
	if (_totalPaid == _totalDebt) then {
		format ["Math is correct: %1 == %2",_totalPaid,_totalDebt];
	} else {
		format ["Math is incorrect: %1 != %2",_totalPaid,_totalDebt];
	};
};
