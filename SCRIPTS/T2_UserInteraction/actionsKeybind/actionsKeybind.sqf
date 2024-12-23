/*
	Actions to be called from keybindings
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_AK_Settings = createHashMapFromArray [
	["EARPLUGS_SOUND_TRANSITION",0.5],
	["EARPLUGS_SOUND_MULTIPLIER",0.1],

	["PARACHUTE_DEPLOYMENT_MIN_ALTITUDE",5],

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

//================================================================================================================
//================================================================================================================
//Weapons away
NWG_AK_WeaponsAway = {
	if (isNull player || {!alive player || {!isNull objectParent player}}) exitWith {};//Ignore if player is not alive or in vehicle
	if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Ignore if player is wounded
	player action ["SwitchWeapon",player,player,-1];//Switch weapon to -1 (legacy from Arma 2, puts all weapons away)
};

//================================================================================================================
//================================================================================================================
//Parachute deployment
NWG_AK_ParachuteDeployment = {
	if (isNull player || {!alive player || {!isNull objectParent player}}) exitWith {};//Ignore if player is not alive or in vehicle
	if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Ignore if player is wounded
	if (((getPos player)#2) < (NWG_AK_Settings get "PARACHUTE_DEPLOYMENT_MIN_ALTITUDE")) exitWith {};//Ignore if player is not high enough above any surface

	[] spawn {
		//Save current backpack loadout
		//[[],[],[],[],[],["B_Parachute",[]],"","",[],["","","","","",""]]
		private _loadout = getUnitLoadout player;
		private _backpack = _loadout select 5;

		//Replace backpack with parachute
		_loadout = [nil,nil,nil,nil,nil,["B_Parachute",[]],nil,nil,nil,nil];
		player setUnitLoadout _loadout;
		player action ["OpenParachute",player];//Deploy parachute

		//Wait till player lands
		waitUntil {
			sleep 0.1;
			if (isNull player || {!alive player}) exitWith {true};
			isNull (objectParent player)
		};
		if (isNull player || {!alive player}) exitWith {};

		//Restore backpack loadout
		_loadout set [5,_backpack];
		player setUnitLoadout _loadout;
	};
};

