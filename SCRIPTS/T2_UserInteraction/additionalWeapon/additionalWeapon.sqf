/*
    Reference used: NWG_PLAYERSETUP_secondGun by HOPA_EHOTA

    Differences are:
    - Completely different logic to store and apply the weapon configurations
    - Weapon holder get transferred to the new player instance on respawn
    - For that - weaponHolder logic been separated from the switch logic
    @Asmo
*/
/*
    Known issues:
    - The inventory window bugs out when switching weapons - vest and backpack tabs disappear
    You can recreate this also by running
    [] spawn {
        sleep 1;
        player setUnitLoadout (getUnitLoadout player);
    };
    in the console and opening the inventory window
    Arma bug - not mine to fix. If it bothers you AND you call this from the inventory window - use feature toggle below
*/
#define CLOSE_INVENTORY_ON_SWITCH false

//================================================================================================================
//Weapon switch logic
NWG_AW_SwitchWeapon = {
    //Get current state
    (player call NWG_AW_GetHolder) params ["_holder","_holderLoadout"];
    private _hasHolder = !isNull _holder;
    private _primaryWeaponLoadout = (getUnitLoadout player) select 0;
    private _hasPrimaryWeapon = _primaryWeaponLoadout isNotEqualTo [];
    if (!_hasHolder && !_hasPrimaryWeapon) exitWith {};//No primary weapon and no additional weapon - do nothing

    //Prepare loadout modification
    private _newLoadout = [];
    _newLoadout resize 10;//Get array with 10 'nil' elements

    //Get rid of existing holder
    if (_hasHolder) then {
        _holder call NWG_AW_DeleteHolder;
    };

    //Create a new holder with primary weapon
    if (_hasPrimaryWeapon) then {
        _holder = [player,_primaryWeaponLoadout] call NWG_AW_CreateHolder;
    };

    //Move weapon from holder to player if any
    if (_hasHolder)
        then {_newLoadout set [0,_holderLoadout]}
        else {_newLoadout set [0,[]]};

    //Apply new loadout
    player setUnitLoadout _newLoadout;

    //'Fix' the issue with vest and backpack tabs disappearing
    if (CLOSE_INVENTORY_ON_SWITCH) then {
        (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
    };
};

//================================================================================================================
//Holder logic
NWG_AW_GetHolder = {
    // private _unit = _this;
    private _holder = objNull;
    {if (_x isKindOf "Library_WeaponHolder") exitWith {_holder = _x}} forEach (attachedObjects _this);
    //return
    if (isNull _holder)
        then {[ objNull, []]}
        else {[ _holder, (_holder getVariable ["NWG_AW_HolderLoadout",[]]) ]}
};

NWG_AW_CreateHolder = {
    params ["_unit","_config"];
    private _holder = createVehicle ["Library_WeaponHolder", _unit, [], 0, "CAN_COLLIDE"];
    _holder lockInventory true;
    _holder enableSimulation false;
    _holder attachTo [_unit, [0,0.84,-0.2], "Spine3", true];
    _holder setVectorDirAndUp [[0, 0, 1], [0, 0.5, 0]];
    _holder addWeaponWithAttachmentsCargoGlobal [_config,1];

    //It's just much easier to get with get/setVariable than to grab an actual object and try to disect it
    _holder setVariable ["NWG_AW_HolderLoadout",_config];

    //return
    _holder
};

NWG_AW_DeleteHolder = {
    // private _holder = _this;
    detach _this;
    deleteVehicle _this;
};
