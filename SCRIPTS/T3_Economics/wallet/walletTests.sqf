// call NWG_WLT_MoneyToString_Test
NWG_WLT_MoneyToString_Test = {
    private _testCases = [
		["Zero",0, "$0"],
		["One",1, "$1"],
		["Small",99, "$99"],
		["Hundreds",156, "$156"],
		["Thousands",1234, "$1.234"],
		["Ten thousands",12345, "$12.345"],
		["Hundred thousands",123456, "$123.456"],
		["Millions",1234567, "$1.234.567"],
		["Negative small",-99, "-$99"],
		["Negative hundreds",-156, "-$156"],
		["Negative thousands",-1234, "-$1.234"],
		["Negative ten thousands",-12345, "-$12.345"],
		["Negative hundred thousands",-123456, "-$123.456"],
		["Negative millions",-1234567, "-$1.234.567"],
		["Decimal small",88.4, "$88"],
		["Decimal hundreds",156.78, "$157"],
		["Decimal thousands",1234.56, "$1.235"],
		["Decimal millions",1234567.89, "$1.234.568"]
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