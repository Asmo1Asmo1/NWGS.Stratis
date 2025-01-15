/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
*/

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLG_ROOF_Settings = createHashMapFromArray [
	["PRICE_REFLASH",250],
	["REFLASH_FROM",["I_UavTerminal","C_UavTerminal","I_E_UavTerminal","B_UavTerminal"]],
	["REFLASH_TO","O_UavTerminal"],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_DLG_ROOF_SelectedTerminal = "";

//================================================================================================================
//================================================================================================================
//Answers generation
NWG_DLG_ROOF_GenerateChoices = {
	private _terminals = NWG_DLG_ROOF_Settings get "REFLASH_FROM";
	_terminals = _terminals select {_x call NWG_fnc_invHasItem};
	if ((count _terminals) == 0) exitWith {[["#ROOF_NO_TERMINALS#","ROOF_01"]]};

	_terminals apply {[
		(getText (configFile >> "CfgWeapons" >> _x >> "displayName")),
		"ROOF_PAY",
		{NWG_DLG_ROOF_SelectedTerminal = _this}
	]}
};

//================================================================================================================
//================================================================================================================
//Prices
NWG_DLG_ROOF_GetPrice = {
	NWG_DLG_ROOF_Settings get "PRICE_REFLASH"
};

//================================================================================================================
//================================================================================================================
//Services
NWG_DLG_ROOF_DoReflash = {
	//Get selection and price
	private _selected = NWG_DLG_ROOF_SelectedTerminal;
	private _price = call NWG_DLG_ROOF_GetPrice;

	//Get actual terminal classname
	private _i = (NWG_DLG_ROOF_Settings get "REFLASH_FROM") findIf {(getText (configFile >> "CfgWeapons" >> _x >> "displayName")) isEqualTo _selected};
	if (_i == -1) exitWith {"#ROOF_INV_TERMINAL#" call NWG_fnc_systemChatMe};
	private _reflashFrom = (NWG_DLG_ROOF_Settings get "REFLASH_FROM") select _i;
	if !(_reflashFrom call NWG_fnc_invHasItem) exitWith {"#ROOF_INV_TERMINAL#" call NWG_fnc_systemChatMe};
	private _reflashTo = NWG_DLG_ROOF_Settings get "REFLASH_TO";

	//Exchange items
	if ((((getUnitLoadout player) param [9,[]]) param [1,""]) isEqualTo _reflashFrom) then {
		/*Target terminal is in slot*/
		player unlinkItem _reflashFrom;
		player linkItem _reflashTo;
	} else {
		/*Target terminal is not in slot*/
		player removeItem _reflashFrom;
		player addItem _reflashTo;
	};
	call NWG_fnc_invInvokeChangeCheck;

	//Deplete player's money
	[player,-_price] call NWG_fnc_wltAddPlayerMoney;
};
