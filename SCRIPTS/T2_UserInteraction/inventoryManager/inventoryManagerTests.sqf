#include "..\..\globalDefines.h"

// call NWG_INV_CheckLoadoutChange_Test
NWG_INV_CheckLoadoutChange_Test = {
    [EVENT_ON_LOADOUT_CHANGED,{
        systemChat format["[%1] Loadout change detected",time];
    }] call NWG_fnc_subscribeToClientEvent
};

// "FirstAidKit" call NWG_INV_HasItem
// "Medikit" call NWG_INV_HasItem
// "ToolKit" call NWG_INV_HasItem

// "FirstAidKit" call NWG_INV_RemoveItem