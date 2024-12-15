//================================================================================================================
//================================================================================================================
//Settings
NWG_UIH_Settings = createHashMapFromArray [
	/*Player money text blinking*/
	["MONEY_BLINK_COLOR_ON_ERROR",[1,0,0,1]],
	["MONEY_BLINK_TIMES_ON_ERROR",2],
	["MONEY_BLINK_COLOR_ON_SUCCESS",[0,1,0,1]],
	["MONEY_BLINK_TIMES_ON_SUCCESS",1],
	["MONEY_BLINK_COLOR_INTERVAL_ON",0.3],
	["MONEY_BLINK_COLOR_INTERVAL_OFF",0.2],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Player money text
NWG_UIH_FillTextWithPlayerMoney = {
	disableSerialization;
	params ["_gui","_idc"];
	if (isNull _gui) exitWith {
		"NWG_UIH_FillTextWithPlayerMoney: GUI is null" call NWG_fnc_logError;
		false
	};

	private _textCtrl = _gui displayCtrl _idc;
	if (isNull _textCtrl) exitWith {
		(format ["NWG_UIH_FillTextWithPlayerMoney: Text is null: '%1'",_idc]) call NWG_fnc_logError;
		false
	};

	_textCtrl ctrlSetText ((player call NWG_fnc_wltGetPlayerMoney) call NWG_fnc_wltFormatMoney);
	true
};

//================================================================================================================
//================================================================================================================
//Player money text blinking
NWG_UIH_BlinkOnSuccess = {
	params ["_gui","_idc"];
	private _color = NWG_UIH_Settings get "MONEY_BLINK_COLOR_ON_SUCCESS";
	private _times = NWG_UIH_Settings get "MONEY_BLINK_TIMES_ON_SUCCESS";
	[_gui,_idc,_color,_times] call NWG_UIH_BlinkPlayerMoney;
};

NWG_UIH_BlinkOnError = {
	params ["_gui","_idc"];
	private _color = NWG_UIH_Settings get "MONEY_BLINK_COLOR_ON_ERROR";
	private _times = NWG_UIH_Settings get "MONEY_BLINK_TIMES_ON_ERROR";
	[_gui,_idc,_color,_times] call NWG_UIH_BlinkPlayerMoney;
};

NWG_UIH_blinkHandle = scriptNull;
NWG_UIH_BlinkPlayerMoney = {
	disableSerialization;
	params ["_gui","_idc","_color","_times"];

	//Terminate previous blinking
	if (!isNull NWG_UIH_blinkHandle && {!scriptDone NWG_UIH_blinkHandle}) then {
		terminate NWG_UIH_blinkHandle;
	};

	//Find text control
	private _textCtrl = _gui displayCtrl _idc;
	if (isNull _textCtrl) exitWith {
		(format ["NWG_UIH_BlinkPlayerMoney: Text is null: '%1'",_idc]) call NWG_fnc_logError;
		false
	};

	//Start blinking
	NWG_UIH_blinkHandle = [_textCtrl,_color,_times] spawn {
		disableSerialization;
		params ["_textCtrl","_color","_times"];
		private _origColor = _textCtrl getVariable "NWG_UIH_origColor";
		if (isNil "_origColor") then {
			_origColor = ctrlBackgroundColor _textCtrl;
			_textCtrl setVariable ["NWG_UIH_origColor",_origColor];
		};

		private _isOn = false;
		private _blinkCount = 0;
		waitUntil {
			if (isNull _textCtrl) exitWith {true};//Could be closed at this point and that's ok
			if (!_isOn && {_blinkCount >= _times}) exitWith {true};//Exit loop when done

			//Toggle colors
			if (!_isOn) then {
				//Turn on
				_textCtrl ctrlSetBackgroundColor _color;
				sleep (NWG_UIH_Settings get "MONEY_BLINK_COLOR_INTERVAL_ON");
			} else {
				//Turn off
				_textCtrl ctrlSetBackgroundColor _origColor;
				sleep (NWG_UIH_Settings get "MONEY_BLINK_COLOR_INTERVAL_OFF");
			};

			_blinkCount = _blinkCount + 0.5;//Increment (each blink is two steps - ON and OFF, that is why we add 0.5)
			_isOn = !_isOn;//Toggle
			false//Get to the next iteration
		};
	};

	//Return true
	true
};