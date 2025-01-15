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
/*Yeah, let's just hardcode it*/
#define ADV_PRICE 100

//================================================================================================================
//================================================================================================================
//Open the shop
NWG_DLG_TRDR_OpenItemsShop = {
	call NWG_fnc_ishopOpenShop
};

//================================================================================================================
//================================================================================================================
//Advice payment
NWG_DLG_TRDR_GetAdvPrice = {ADV_PRICE};
NWG_DLG_TRDR_PayForAdvice = {[player,-ADV_PRICE] call NWG_fnc_wltAddPlayerMoney};
