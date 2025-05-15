// call NWG_WLT_MoneyToString_Test
NWG_WLT_MoneyToString_Test = {
    private _testCases = [
		["Zero",0, "$0"],
		["One",1, "$1"],
		["Small",99, "$99"],
		["Hundreds",156, "$156"],
		["Thousands",1234, "$1,234"],
		["Ten thousands",12345, "$12,345"],
		["Hundred thousands",123456, "$123,456"],
		["Millions",1234567, "$1,234,567"],
		["Negative small",-99, "-$99"],
		["Negative hundreds",-156, "-$156"],
		["Negative thousands",-1234, "-$1,234"],
		["Negative ten thousands",-12345, "-$12,345"],
		["Negative hundred thousands",-123456, "-$123,456"],
		["Negative millions",-1234567, "-$1,234,567"],
		["Decimal small",88.4, "$88"],
		["Decimal hundreds",156.78, "$157"],
		["Decimal thousands",1234.56, "$1,235"],
		["Decimal millions",1234567.89, "$1,234,568"]
	];

	private _failedTests = [];
	{
		_x params ["_testName", "_input", "_expected"];
		private _actual = _input call NWG_WLT_MoneyToString;
		if (_actual isNotEqualTo _expected) then {
			_failedTests pushBack (_x+[_actual]);
		};
	} forEach _testCases;

	if (count _failedTests == 0) exitWith {
		"All tests passed"
	};

	_failedTests = _failedTests apply {
		format ["Test %1 failed. Expected %2, got %3", _x#0, _x#2, _x#3]
	};
	_failedTests call NWG_fnc_testDumpToRptAndClipboard;
	"Some tests failed, check RPT and clipboard!"
};

// call NWG_WLT_GetSeparatorOptions
NWG_WLT_GetSeparatorOptions = {
	_separators = ",.";
	//return
	[_separators,(toArray _separators)]
};

// -25000 call NWG_WLT_BalanceLosses_Test
NWG_WLT_BalanceLosses_Test = {
	private _totalDebt = _this;
	private _moneyArray = [500,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000];
	private _players = ["1","2","3","4","5"];
	private _moneyMap = createHashMapFromArray (_players apply {[_x,(selectRandom _moneyArray)]});
	NWG_WLT_MockMoneyGet = _moneyMap;

	//Re-define NWG_WLT_GetPlayerMoney
	NWG_WLT_GetPlayerMoney = {
		// private _player = _this;
		NWG_WLT_MockMoneyGet getOrDefault [_this,0]
	};

	private _balanced = [_totalDebt,_players] call NWG_WLT_BalanceLosses;
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