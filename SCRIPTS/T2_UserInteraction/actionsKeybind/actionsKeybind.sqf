/*
	Actions to be called from keybindings
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_AK_Settings = createHashMapFromArray [
	["EARPLUGS_SOUND_TRANSITION",0.5],
	["EARPLUGS_SOUND_MULTIPLIER",0.1],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Earplugs
NWG_AK_ToggleEarPlugs = {
    private _earplugsOn = localNamespace getVariable ["NWG_AK_EarPlugsOn", false];
	private _transition = NWG_AK_Settings get "EARPLUGS_SOUND_TRANSITION";
    if(_earplugsOn) then {
		//'Remove' earplugs
        _transition fadeSound 1;
        ["#AK_EARPLUGS_OFF#"] call NWG_fnc_systemChatMe;
    } else {
		//'Add' earplugs
        _transition fadeSound (NWG_AK_Settings get "EARPLUGS_SOUND_MULTIPLIER");
        ["#AK_EARPLUGS_ON#"] call NWG_fnc_systemChatMe;
    };
    localNamespace setVariable ["NWG_AK_EarPlugsOn",!_earplugsOn];//Toggle earplugs state
};