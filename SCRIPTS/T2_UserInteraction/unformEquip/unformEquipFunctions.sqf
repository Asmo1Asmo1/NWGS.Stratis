/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability.
    Note: It requires inventory to be opened in order to work.

    Usage: Inside "InventoryOpened" event handler, add the following line:
    uiNamespace setVariable ["NWG_UNEQ_ForEquipSelectedUniform",_this];

    Then, in your custom button handler, add the following line:
    call NWG_fnc_uneqEquipSelected;
*/

//Equip the unform selected in inventory
//note: this function must be called from the inventory UI
NWG_fnc_uneqEquipSelected = {
    call NWG_UNEQ_EquipSelectedUniform;
};