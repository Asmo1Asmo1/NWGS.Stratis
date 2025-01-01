/*Client->Server*/
//Request to build camp where player is
//params: player - player object
NWG_fnc_aiRequestCamp = {
    // private _player = _this;
	if !(_this isEqualType objNull) exitWith {
		"NWG_fnc_aiRequestCamp: Invalid player object" call NWG_fnc_logError;
	};
	if (isNull _this || {!alive _this}) exitWith {
		"NWG_fnc_aiRequestCamp: Player is null or dead" call NWG_fnc_logError;
	};

	if (isServer)
		then {_this call NWG_AI_SER_OnRequestCamp}
		else {_this remoteExec ["NWG_fnc_aiRequestCamp",2]};
};

/*Any->Server*/
//Set mission pos
//params: [pos,rad]
NWG_fnc_aiSetMissionPos = {
	_this call NWG_AI_SER_SetMissionPos;
};

//Drop mission pos
//params: none
NWG_fnc_aiDropMissionPos = {
	call NWG_AI_SER_DropMissionPos;
};
