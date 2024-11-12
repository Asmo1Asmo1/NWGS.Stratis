#include "additionalWeaponDefines.h"

/*
    Reference used: NWG_PLAYERSETUP_secondGun by HOPA_EHOTA

    Differences are:
    - Completely different logic to store and apply the weapon configurations
    - Weapon holder get transferred to the new player instance on respawn
    - Object creation and data storage were separated
    - Client<->Server communication logic
    @Asmo
*/

//================================================================================================================
//Weapon switch logic
NWG_AW_SwitchWeapon = {
    //Get current state
    private _holderLoadout = player call NWG_fnc_awGetHolderData;
    private _primaryWeaponLoadout = (getUnitLoadout player) select 0;
    if (_holderLoadout isEqualTo [] && {_primaryWeaponLoadout isEqualTo []}) exitWith {false};//No primary weapon and no additional weapon - do nothing

    //Get rid of existing holder
    player call NWG_fnc_awDeleteHolderObject;

    //Create new holder
    [player,_primaryWeaponLoadout] call NWG_fnc_awSetHolderData;
    [player,_primaryWeaponLoadout] call NWG_fnc_awCreateHolderObject;

    //Move weapon from holder to player if any
    private _newLoadout = [];
    _newLoadout resize 10;//Array with 10 'nil' elements
    _newLoadout set [0,_holderLoadout];
    player setUnitLoadout _newLoadout;

    //Apply fixes
    switch (true) do {
        case (CLOSE_INVENTORY_ON_SWITCH): {
            //Close inventory window
            (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
        };
        case (INVENTORY_WINDOW_FIX): {
            //Fix the issue with inventory tabs disappearing
            player addItem "Antibiotic";
            player removeItem "Antibiotic";
        };
        default {/*Do nothing*/};
    };

    //return
    true
};

//================================================================================================================
//Move on respawn feature logic
if (MOVE_HOLDER_ON_RESPAWN) then {

player addEventHandler ["Respawn",{
    params ["_player","_corpse"];
    //Get existing holder
    private _holderLoadout = _corpse call NWG_fnc_awGetHolderData;
    if (_holderLoadout isNotEqualTo []) then {
        _corpse call NWG_fnc_awDeleteHolderObject;
        [_player,_holderLoadout] call NWG_fnc_awSetHolderData;
        [_player,_holderLoadout] call NWG_fnc_awCreateHolderObject;
    };
}];

};

//================================================================================================================
//Delete holder when player enters a vehicle feature logic
if (DELETE_HOLDER_IN_VEHCILE) then {

player addEventHandler ["GetInMan",{
    // params ["_unit","_role","_vehicle","_turret"];
    params ["_player"];
    _player call NWG_fnc_awDeleteHolderObject;
}];
player addEventHandler ["GetOutMan",{
    // params ["_unit","_role","_vehicle","_turret"];
    params ["_player"];
    private _holderLoadout = _player call NWG_fnc_awGetHolderData;
    [_player,_holderLoadout] call NWG_fnc_awCreateHolderObject;
}];

};