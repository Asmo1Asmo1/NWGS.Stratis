#include "..\..\globalDefines.h"

// call NWG_INV_CheckLoadoutChange_Test
NWG_INV_CheckLoadoutChange_Test = {
    [EVENT_ON_LOADOUT_CHANGED,{
        systemChat format["[%1] Loadout change detected",time];
    }] call NWG_fnc_subscribeToClientEvent
};

/*Has item*/
// "FirstAidKit" call NWG_INV_HasItem
// "Medikit" call NWG_INV_HasItem
// "ToolKit" call NWG_INV_HasItem

/*Remove item*/
// "FirstAidKit" call NWG_INV_RemoveItem

/*Get items count*/
// [
//     ("FirstAidKit" call NWG_INV_GetItemCount),
//     ("Medikit" call NWG_INV_GetItemCount),
//     ("50Rnd_570x28_SMG_03" call NWG_INV_GetItemCount),
//     ("ItemCompass" call NWG_INV_GetItemCount)
// ]