// Stops player instance from issuing voice commands over radio
//params:
// 0: OBJECT - Player
NWG_fnc_shutMeUp = {
	// private _player = _this;
    _this setSpeaker "NoVoice";
};