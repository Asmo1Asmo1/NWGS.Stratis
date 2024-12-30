/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Reminder: Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
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
NWG_DLG_TRDR_GetAdvPriceStr = {ADV_PRICE call NWG_fnc_wltFormatMoney};
NWG_DLG_TRDR_PayForAdvice = {[player,-ADV_PRICE] call NWG_fnc_wltAddPlayerMoney};
