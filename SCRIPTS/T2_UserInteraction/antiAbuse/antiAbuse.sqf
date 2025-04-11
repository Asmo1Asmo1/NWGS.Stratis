//================================================================================================================
//================================================================================================================
//Settings
NWG_AA_Settings = createHashMapFromArray [
	["ALL_ALLOWED_IN_LOCAL_DEV",true],
	["ALL_ALLOWED_IN_MP_DEV",false],
	["DISABLE_ARSENAL",true],
	["PREVENT_BACKPACK_ACCESS",false],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	//Check dev build
	if (is3DENPreview && {NWG_AA_Settings get "ALL_ALLOWED_IN_LOCAL_DEV"}) exitWith {};
	if (is3DENMultiplayer && {NWG_AA_Settings get "ALL_ALLOWED_IN_MP_DEV"}) exitWith {};

	//Disable arsenal
	if (NWG_AA_Settings get "DISABLE_ARSENAL") then {
		[missionNamespace, "arsenalOpened", {
			(uiNamespace getVariable ["RscDisplayArsenal",displayNull]) closeDisplay 2;
		}] call BIS_fnc_addScriptedEventHandler;
	};

	//Protect player's backpacks
	if (NWG_AA_Settings get "PREVENT_BACKPACK_ACCESS") then {
		player addEventHandler ["InventoryOpened",{_this call NWG_AA_BackpackProtection}];
	};
};

//================================================================================================================
//================================================================================================================
//Backpack protection
NWG_AA_BackpackProtection = {
	// params ["_unit","_mainContainer","_secdContainer"];
	params ["","_main","_secd"];

	//Get info on opened containers
	private _containers = [_main,_secd];
	if (!isNull _main) then {_containers pushBack (objectParent _main)};
	if (!isNull _secd) then {_containers pushBack (objectParent _secd)};

	//Check if opening other player's backpack
	private _p = _containers findIf {!isNull _x && {_x isKindOf "Man" && {_x isNotEqualTo player && {isPlayer _x}}}};
	if (_p == -1) exitWith {};//Ignore if not accessing other players

	//Check if accessing wounded player - that's okay
	if (!isNil "NWG_fnc_medIsWounded" && {(_containers#_p) call NWG_fnc_medIsWounded}) exitWith {};

	//Close inventory UI
	(uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
};

//================================================================================================================
//================================================================================================================
call _Init;
