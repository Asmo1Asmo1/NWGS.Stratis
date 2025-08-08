//================================================================================================================
//================================================================================================================
//Settings
NWG_AA_Settings = createHashMapFromArray [
	["ALL_ALLOWED_IN_LOCAL_DEV",true],
	["ALL_ALLOWED_IN_MP_DEV",false],
	["DISABLE_ARSENAL",true],
	["PREVENT_BACKPACK_ACCESS",true],

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
NWG_AA_BackpackProtection_AfkAnims = [
	"amovpsitmstpsnonwnondnon_ground",/*Sitting on the ground unarmed*/
	"amovpsitmstpsnonwpstdnon_ground",
	"amovpsitmstpslowwrfldnon"/*Sitting on the ground with weapon*/
];
NWG_AA_BackpackProtection = {
	// params ["_unit","_mainContainer","_secdContainer"];
	params ["","_backpack"];
	private _unit = objectParent _backpack;

	//First set of checks - make sure it's unit wearing backpack
	if (isNull _unit) exitWith {};
	if !(_unit isKindOf "Man") exitWith {};
	if (_unit isEqualTo player) exitWith {};
	if !(isPlayer _unit) exitWith {};

	//Close invenotry if trying to access AFK player backpack
	if ((animationState _unit) in NWG_AA_BackpackProtection_AfkAnims) exitWith {
		(uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
	};
};

//================================================================================================================
//================================================================================================================
call _Init;
