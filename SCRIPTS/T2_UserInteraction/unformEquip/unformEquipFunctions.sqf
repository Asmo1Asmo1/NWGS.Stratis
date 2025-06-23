/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability as well as ability to quickly equip vests and backpacks.
    Note: It requires inventory to be opened in order to work.

    Usage: Inside "InventoryOpened" event handler, add any handler that will call this function with the same arguments.
    ["_unit","_mainContainer","_secdContainer"] call NWG_fnc_uneqEquipSelected

    I did not find a way to grab actual containers solely from the inventory UI.
    So unfortunately this module requires the arguments of "InventoryOpened" handler to be sent
*/
/*
    Important notes:
    - Items placed inside the uniform/vest/backpack are not transferred
    - This is a feature - we can swap items without manually relocating items
    - And a bug - if we swap while not wearing anything - we'll equip empty uniform/vest/backpack and items inside will be lost
*/

//Equip the unform selected in inventory
//params:
// - _container - object
// - _listboxIDC - number
//returns: boolean - true if successful, false if not
NWG_fnc_uneqEquipSelected = {
    // params [["_container",objNull],["_listboxIDC",-1]];
    _this call NWG_UNEQ_EquipSelectedUniform;
};