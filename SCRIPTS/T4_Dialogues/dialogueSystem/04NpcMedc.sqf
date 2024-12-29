/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Reminder: Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
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
NWG_DLG_MEDC_GetPatchPriceStr = {MEDC_PATCH_PRICE call NWG_fnc_wltFormatMoney};
// NWG_DLG_MEDC_PayForPatch = {[player,-MEDC_PATCH_PRICE] call NWG_fnc_wltAddPlayerMoney};

NWG_DLG_MEDC_Patch = {
	private _isFree = _this;

	//Payment
	if (!_isFree) then {
		[player,-MEDC_PATCH_PRICE] call NWG_fnc_wltAddPlayerMoney;
	};

	//Patch
	player setDamage 0;
	player call NWG_fnc_medReloadSelfHealChance;
};
