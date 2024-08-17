/*
    Reference used: NWG_PLAYERSETUP_secondGun by HOPA_EHOTA

    Differences are:
    - Completely different logic to store and apply the weapon configurations
    - Weapon holder get transferred to the new player instance on respawn
    - For that - weaponHolder logic been separated from the switch logic
    @Asmo
*/

//================================================================================================================
//Defines

/*Feature toggles*/
#define CLOSE_INVENTORY_ON_SWITCH false //Close inventory on weapon switch (hides the bug with inventory tabs)
#define MOVE_HOLDER_ON_RESPAWN true     //Move weapon holder to the new player instance on respawn
#define DELETE_HOLDER_IN_VEHCILE true   //Delete weapon holder when player enters a vehicle (prevents issues with helicopters)
#define INVENTORY_WINDOW_FIX true       //Fix the issue with inventory tabs disappearing (suggestion by HOPA_EHOTA)

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
        [player,_primaryWeaponLoadout] call NWG_AW_CreateHolder;
    };

    //Move weapon from holder to player if any
    if (_hasHolder)
        then {_newLoadout set [0,_holderLoadout]}
        else {_newLoadout set [0,[]]};

    //Apply new loadout
    player setUnitLoadout _newLoadout;

    //Close inventory window (Hide the issue with vest and backpack tabs disappearing)
    if (CLOSE_INVENTORY_ON_SWITCH) exitWith {
        (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
    };

    //Fix the issue with inventory tabs disappearing
    if (INVENTORY_WINDOW_FIX) exitWith {
        //--- hacky solution how to enable vest and backpack container
        player addItem "Antibiotic";
        player removeItem "Antibiotic";
    };
};

//================================================================================================================
//Holder logic
NWG_AW_GetHolder = {
    // private _unit = _this;

    if (DELETE_HOLDER_IN_VEHCILE && {!isNil {_this getVariable "NWG_AW_HolderLoadout"}})
        exitWith {[_this,(_this getVariable "NWG_AW_HolderLoadout")]};

    private _holder = ((attachedObjects _this) select {_x isKindOf "Library_WeaponHolder"}) param [0,objNull];
    if (!isNull _holder) exitWith {[_holder,(_holder getVariable "NWG_AW_HolderLoadout")]};

    //else return
    [objNull,[]];
};

NWG_AW_CreateHolder = {
    params ["_unit","_config"];

    private _holder = objNull;
    if (DELETE_HOLDER_IN_VEHCILE && {(vehicle _unit) isNotEqualTo _unit}) then {
        _holder = _unit;
    } else {
        _holder = createVehicle ["Library_WeaponHolder", _unit, [], 0, "CAN_COLLIDE"];
        _holder attachTo [_unit, [0,0.84,-0.2], "Spine3", true];
        _holder setVectorDirAndUp [[0, 0, 1], [0, 0.5, 0]];
        _holder addWeaponWithAttachmentsCargoGlobal [_config,1];
        _holder setDamage 1;//Effectively 'close' the holder for any further interaction
    };

    //It's just much easier to go with get/setVariable than to grab an actual object and try to disect it
    _holder setVariable ["NWG_AW_HolderLoadout",_config];

    //return
    _holder
};

NWG_AW_DeleteHolder = {
    // private _holder = _this;

    if (DELETE_HOLDER_IN_VEHCILE && {_this isKindOf "Man"})
        exitWith {_this setVariable ["NWG_AW_HolderLoadout",nil]};

    //else
    detach _this;
    deleteVehicle _this;
};

//================================================================================================================
//Move on respawn feature logic
if (MOVE_HOLDER_ON_RESPAWN) then {

NWG_AW_OnRespawn = {
    params ["_player","_corpse"];
    //Get existing holder
    (_corpse call NWG_AW_GetHolder) params ["_holder","_holderLoadout"];

    //Recreate holder for the new player instance
    if (!isNull _holder) then {
        _holder call NWG_AW_DeleteHolder;
        [_player,_holderLoadout] call NWG_AW_CreateHolder;
    };
};
player addEventHandler ["Respawn",{_this call NWG_AW_OnRespawn}];

};

//================================================================================================================
//Delete holder when player enters a vehicle feature logic
if (DELETE_HOLDER_IN_VEHCILE) then {

NWG_AW_OnInOutOfVehicle = {
    // params ["_unit","_role","_vehicle","_turret"];
    params ["_player"];
    (_player call NWG_AW_GetHolder) params ["_holder","_holderLoadout"];
    if (!isNull _holder) then {
        //Re-create holder (will create a new holder differently based on wether we're in a vehicle or not)
        _holder call NWG_AW_DeleteHolder;
        [_player,_holderLoadout] call NWG_AW_CreateHolder;
    };
};
player addEventHandler ["GetInMan",{_this call NWG_AW_OnInOutOfVehicle}];
player addEventHandler ["GetOutMan",{_this call NWG_AW_OnInOutOfVehicle}];

};