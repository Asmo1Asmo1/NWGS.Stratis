#include "..\..\globalDefines.h"

// //Items types
// #define ITEM_TYPE_CLTH "CLTHG" // Clothing
// #define ITEM_TYPE_WEPN "WEPN"  // Weapon
// #define ITEM_TYPE_ITEM "ITEM"  // Item
// #define ITEM_TYPE_AMMO "AMMO"  // Ammo

NWG_ICAT_GetItemType = {
    private _item = _this;
    if (_item isEqualType objNull) then {_item = typeOf _item};

    //TODO: Implement item type getter
    false
};