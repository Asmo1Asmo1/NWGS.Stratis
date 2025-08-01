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

	["QUICK_VEH_ACCESS_DISTANCE",5],

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
		private _backpack = (getUnitLoadout player) select 5;
		player setVariable ["NWG_AK_ParachuteDeployment_backpack",_backpack];

		//Prepare loadout change callback
		private _callback = {
			[] spawn {
				//Deploy parachute
				player action ["OpenParachute",player];
				//Wait till player lands
				waitUntil {
					sleep 0.1;
					if (isNull player || {!alive player}) exitWith {true};
					isNull (objectParent player)
				};
				if (isNull player || {!alive player}) exitWith {};
				//Restore original loadout
				private _backpack = player getVariable ["NWG_AK_ParachuteDeployment_backpack",[]];
				private _loadout = [nil,nil,nil,nil,nil,_backpack,nil,nil,nil,nil];
				_loadout call NWG_fnc_invSetPlayerLoadout;
			};
		};

		//Replace backpack with parachute and run callback when done
		private _loadout = [nil,nil,nil,nil,nil,["B_Parachute",[]],nil,nil,nil,nil];
		[player,_loadout,_callback] call NWG_fnc_setUnitLoadout;
	};
};

//================================================================================================================
//================================================================================================================
//Quick vehicle access
NWG_AK_QuickVehicleAccess = {
	if (isNull player || {!alive player || {!isNull objectParent player}}) exitWith {};//Ignore if player is not alive or in vehicle
	if (!isNil "NWG_fnc_medIsWounded" && {player call NWG_fnc_medIsWounded}) exitWith {};//Ignore if player is wounded

	//Get target vehicle
	private _vehicle = cursorObject;
	if (isNull _vehicle) exitWith {};//Ignore if there is no object under cursor
	if ((locked _vehicle) > 1) exitWith {};//Ignore if vehicle is locked
	if ((["ParachuteBase","Car","Tank","Helicopter","Plane","Ship"] findIf {_vehicle isKindOf _x}) <= 0) exitWith {};//Ignore if cursorObject is not a vehicle
	if ((player distance _vehicle) > (NWG_AK_Settings get "QUICK_VEH_ACCESS_DISTANCE")) exitWith {};//Ignore if player is too far from the vehicle
	if (unitIsUAV _vehicle) exitWith {};//Ignore if cursorObject is a UAV

	//Prevent getting into enemy vehicles
	if (((crew _vehicle) findIf {
		alive _x && {
		(incapacitatedState _x) isEqualTo "" && {
		(side (group _x)) isNotEqualTo (side (group player))}}
	}) != -1) exitWith {};

	//Try to get in
	private _fullCrew = _vehicle call NWG_fnc_getFullCrew;
	if (_fullCrew isEqualTo []) exitWith {};
	[_vehicle,_fullCrew,player] call NWG_fnc_placeUnitInFullCrewSeat;
};
