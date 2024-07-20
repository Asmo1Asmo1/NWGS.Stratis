//Switch primary<->additional weapon
//note: if there is no additional weapon at the moment, this function will remove the primary weapon and put it into 'additional' slot
//note: effectively, this function will swap the primary and additional weapons
NWG_fnc_awSwitchWeapon = {
    call NWG_AW_SwitchWeapon;
};