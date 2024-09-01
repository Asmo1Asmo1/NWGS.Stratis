/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability.
    Note: It requires inventory to be opened in order to work.

    Usage: Inside "InventoryOpened" event handler, add any handler that will call this function with the same arguments.
    ["_unit","_mainContainer","_secdContainer"] call NWG_fnc_uneqEquipSelected

    I did not find a way to grab actual containers solely from the inventory UI.
    So unfortunately this module requires the arguments of "InventoryOpened" handler to be sent
*/

//Equip the unform selected in inventory
//params: "InventoryOpened" event args: ["_unit","_mainContainer","_secdContainer"];
//note: this function must be called from within the inventory UI
//returns: boolean - true if successful, false if not
NWG_fnc_uneqEquipSelected = {
    // params ["_unit","_mainContainer","_secdContainer"];
    _this call NWG_UNEQ_EquipSelectedUniform;
};