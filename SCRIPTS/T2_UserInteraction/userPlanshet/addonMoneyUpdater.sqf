#include "..\..\globalDefines.h"
/*
	Addon for updating player money text on money change event
*/
//--- userPlanshetUIBase
#define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
// #define IDC_LISTBOX	1501

[EVENT_ON_MONEY_CHANGED,{
	{
		[_x,IDC_TEXT_LEFT] call NWG_fnc_uiHelperFillTextWithPlayerMoney;
	} forEach (call NWG_fnc_upGetAllMenus);
}] call NWG_fnc_subscribeToClientEvent;