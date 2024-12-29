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
//Defines
// #define NODE_BACK -1
#define NODE_EXIT -2

//================================================================================================================
//================================================================================================================
//Settings
NWG_DLGHLP_Settings = createHashMapFromArray [
	/*Localization keys for answer generation*/
	["HELP_KEYS",["#AGEN_HELP_01#"]],
	["HELP_PLC_KEYS",["#AGEN_HELP_PLC_01#"]],
	["HELP_WHO_KEYS",["#AGEN_HELP_WHO_01#"]],
	["HELP_TLK_KEYS",["#AGEN_HELP_TLK_01#"]],
	["HELP_UFL_KEYS",["#AGEN_HELP_UFL_01#"]],
	["ADV_KEYS",["#AGEN_ADV_01#"]],
	["ANOTHER_Q_KEYS",["#AGEN_ANQ_01#","#AGEN_ANQ_02#","#AGEN_ANQ_03#"]],
	["BACK_KEYS",["#AGEN_BACK_01#","#AGEN_BACK_02#","#AGEN_BACK_03#","#AGEN_BACK_04#"]],
	["DOUBT_KEYS",["#AGEN_DOUBT_01#","#AGEN_DOUBT_02#","#AGEN_DOUBT_03#","#AGEN_DOUBT_04#","#AGEN_DOUBT_05#","#AGEN_DOUBT_06#"]],
	["EXIT_KEYS",["#AGEN_EXIT_01#","#AGEN_EXIT_02#","#AGEN_EXIT_03#","#AGEN_EXIT_04#","#AGEN_EXIT_05#","#AGEN_EXIT_06#"]]
];

//================================================================================================================
//================================================================================================================
//Dice logic (used in conditions)
NWG_DLGHLP_Dice = {
	params ["_req","_dice"];
	(_req > (random _dice))
};

//================================================================================================================
//================================================================================================================
//Money compare logic (used in conditions)
NWG_DLGHLP_HasEnoughMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) >= _this
};
NWG_DLGHLP_HasLessMoney = {
	// private _moneyReq = _this;
	(player call NWG_fnc_wltGetPlayerMoney) < _this
};
NWG_DLGHLP_HasMoreMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) > ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};
NWG_DLGHLP_HasLessOrEqMoneyStartSum = {
	params [["_multiplier",1]];
	(player call NWG_fnc_wltGetPlayerMoney) <= ((call NWG_fnc_wltGetInitialMoney)*_multiplier)
};

//================================================================================================================
//================================================================================================================
//Money format (used in questions like 'That would cost you 1000$')
NWG_DLGHLP_MoneyStr = {
	// private _money = _this;
	_this call NWG_fnc_wltFormatMoney
};

//================================================================================================================
//================================================================================================================
//Answers ending generation (allows to shorten dialogue tree by generating typical answers) (use with A_GEN)
//generates answers ["Help","Advice","Exit"]
NWG_DLGHLP_GenerateRoot = {
	// private _npcName = _this;
	//return
	[
		/*Help Node*/[(selectRandom (NWG_DLGHLP_Settings get "HELP_KEYS")),(format ["%1_HELP",_this])],
		/*Adv  Node*/[(selectRandom (NWG_DLGHLP_Settings get "ADV_KEYS" )),(format ["%1_ADV",_this])],
		/*Exit Node*/[(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["What is this place?","Who are you?","Who should I talk to?","How things work?"]
NWG_DLGHLP_GenerateHelp = {
	// private _npcName = _this;
	[
		/*Place Node*/   [(selectRandom (NWG_DLGHLP_Settings get "HELP_PLC_KEYS")),(format ["%1_HELP_PLACE",_this])],
		/*Who Node*/     [(selectRandom (NWG_DLGHLP_Settings get "HELP_WHO_KEYS")),(format ["%1_HELP_WHO",_this])],
		/*Talk Node*/    [(selectRandom (NWG_DLGHLP_Settings get "HELP_TLK_KEYS")),(format ["%1_HELP_TALK",_this])],
		/*Userflow Node*/[(selectRandom (NWG_DLGHLP_Settings get "HELP_UFL_KEYS")),(format ["%1_HELP_USERFLOW",_this])]
	]
};

//generates answers ["Go back","Exit"]
NWG_DLGHLP_GenerateBackExit = {
	// private _backNode = _this;
	[
		/*Back Node*/[(selectRandom (NWG_DLGHLP_Settings get "BACK_KEYS")),_this],
		/*Exit Node*/[(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["Another question","Back","Exit"]
NWG_DLGHLP_GenerateAnqBackExit = {
	params ["_anqNode","_backNode"];
	[
		/*Another Q Node*/  [(selectRandom (NWG_DLGHLP_Settings get "ANOTHER_Q_KEYS")),_anqNode],
		/*Back Node*/       [(selectRandom (NWG_DLGHLP_Settings get "BACK_KEYS")),_backNode],
		/*Exit Node*/       [(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};

//generates answers ["Go back","Exit"]
NWG_DLGHLP_GenerateDoubtExit = {
	// private _doubtNode = _this;
	[
		/*Doubt Node*/[(selectRandom (NWG_DLGHLP_Settings get "DOUBT_KEYS")),_this],
		/*Exit Node*/ [(selectRandom (NWG_DLGHLP_Settings get "EXIT_KEYS")),NODE_EXIT]
	]
};