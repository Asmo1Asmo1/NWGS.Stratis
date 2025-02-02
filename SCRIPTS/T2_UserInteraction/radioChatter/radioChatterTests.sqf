// [] spawn NWG_RC_TestAllSounds;
NWG_RC_TestAllSounds = {
	{
		systemChat format ["[%1] Playing sound: %2",_forEachIndex,_x];
		_x call NWG_RC_Play;
		sleep 1;
	} forEach ( NWG_RC_Settings get "SOUNDS");
};