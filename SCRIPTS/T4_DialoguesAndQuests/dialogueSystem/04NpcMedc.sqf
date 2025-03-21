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
//Defiens
#define MEDC_PATCH_PRICE 500

//================================================================================================================
//================================================================================================================
//Patch
NWG_DLG_MEDC_IsInjured = {
	if ((damage player) > 0.1) exitWith {true};
	if ((((getAllHitPointsDamage player)#2) findIf {_x >= 0.1}) != -1) exitWith {true};
	if (NWG_MED_CLI_SA_selfHealSuccessChance < (NWG_MED_CLI_Settings get "SELF_HEAL_INITIAL_CHANCE")) exitWith {true};//Inner kitchen of 'medicineClientSide.sqf'
	false
};

NWG_DLG_MEDC_GetPatchPrice = {MEDC_PATCH_PRICE};
NWG_DLG_MEDC_Patch = {
	// private _isFree = _this;

	//Payment
	if (!_this) then {[player,-MEDC_PATCH_PRICE] call NWG_fnc_wltAddPlayerMoney};

	//Patch
	player setDamage 0;
	player call NWG_fnc_medReloadSelfHealChance;
};
