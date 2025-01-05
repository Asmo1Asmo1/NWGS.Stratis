//================================================================================================================
//================================================================================================================
//Settings
NWG_AA_Settings = createHashMapFromArray [
	["ALL_ALLOWED_IN_LOCAL_DEV",true],
	["ALL_ALLOWED_IN_MP_DEV",false],
	["DISABLE_ARSENAL",true],

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
};

//================================================================================================================
//================================================================================================================
call _Init;
