/*
    In Arma 3, it is forbidden to equip any uniform that is not of the same faction as the player.
    This module adds this ability.
    Note: It requires inventory to be opened in order to work.

    Usage: Inside "InventoryOpened" event handler, add any handler that will call this function with the same arguments.
    ["_unit","_mainContainer","_secdContainer"] call NWG_fnc_uneqEquipSelected

    I did not find a way to grab actual containers solely from the inventory UI.
    So unfortunately this module requires the arguments of "InventoryOpened" handler to be sent
*/
/*
    Known issues:
    - If there are items in the uniform, they will be lost.
*/
//================================================================================================================
//Defines
#define CLOSE_INVENTORY_ON_UNIFORM_CHANGE false //Close inventory on uniform switch (hides the bug with inventory tabs)
#define INVENTORY_WINDOW_FIX true       //Fix the issue with inventory tabs disappearing (suggestion by HOPA_EHOTA)

//UI IDDs
#define MAIN_CONTAINER_LIST 640
#define SECN_CONTAINER_LIST 632

//Enum helper
#define UNIFORM_IN_LOADOUT 3

//================================================================================================================
//Script
NWG_UNEQ_EquipSelectedUniform = {
    disableSerialization;
    //params ["_unit","_mainContainer","_secdContainer"];
    params ["",["_mainContainer",objNull],["_secdContainer",objNull]];

    private _inventoryDisplay = findDisplay 602;
    if (isNull _inventoryDisplay) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Inventory must be opened to equip uniform." call NWG_fnc_logError;
        false
    };

    //Find UI container with selected item
    private _uiContainerID = -1;
    {
        if ((lbCurSel (_inventoryDisplay displayCtrl _x)) > -1) exitWith {_uiContainerID = _x};
    } forEach [MAIN_CONTAINER_LIST,SECN_CONTAINER_LIST];
    if (_uiContainerID == -1) exitWith {false};//Nothing is selected anywhere
    private _uiContainer = _inventoryDisplay displayCtrl _uiContainerID;

    //Get selected item
    private _selectedItem = _uiContainer lbData (lbCurSel _uiContainer);
    if ((getNumber (configFile >> "CfgWeapons" >> _selectedItem >> "ItemInfo" >> "type")) != 801) exitWith {false};//Not a uniform

    //Get physical container
    private _container = if (_uiContainerID == MAIN_CONTAINER_LIST)
        then {if (!isNull _mainContainer) then {_mainContainer} else {_secdContainer}}
        else {if (!isNull _secdContainer) then {_secdContainer} else {_mainContainer}};//Fix looting corpses (switches the containers)
    if (isNull _container) exitWith {
        "NWG_UNEQ_EquipSelectedUniform: Inventory containers are not available." call NWG_fnc_logError;
        false
    };

    //Get player's uniform
    private _playerUniformLoadout = (getUnitLoadout player) select UNIFORM_IN_LOADOUT;
    private _playerUniformClass = _playerUniformLoadout param [0,""];
    if (_playerUniformClass isEqualTo _selectedItem) exitWith {false};//Already wearing this uniform

    //Update the container based on what it is
    if (_container isKindOf "Man") then {
        //Fix uniform duplication abuse (by just ignoring uniform that was put into dead unit's inventory)
        if (((getUnitLoadout _container)#UNIFORM_IN_LOADOUT) param [0,""] isNotEqualTo _selectedItem) exitWith {};//Not the same uniform
        //Swap uniforms
        [_container,_playerUniformClass] call NWG_UNEQ_ReplaceUniformForUnit;//Replace uniform for the (apparently dead) unit
        [player,_selectedItem] call NWG_UNEQ_ReplaceUniformForUnit;//Update player's loadout
    } else {
        //Swap uniforms
        [_container,_selectedItem,_playerUniformClass] call NWG_UNEQ_ReplaceUniformInContainer;//Replace uniform in the container
        [player,_selectedItem] call NWG_UNEQ_ReplaceUniformForUnit;//Update player's loadout
    };

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
//Utils
NWG_UNEQ_ReplaceUniformInContainer = {
    params ["_container","_uniToRemove","_uniToAdd"];

    //Remove old uniform from the container
    //In a most inconvenient Arma approved way - remove all items, then add them back except for the one to remove
    (getItemCargo _container) params ["_items","_counts"];
    clearItemCargoGlobal _container;
    //forEach item record
    {
        if (_x isNotEqualTo _uniToRemove) then {
            _container addItemCargoGlobal [_x,(_counts#_forEachIndex)];//Add it back
            continue;
        };
        if ((_counts#_forEachIndex) > 1) then {
            _container addItemCargoGlobal [_x,((_counts#_forEachIndex)-1)];//Decrease count
        };
        //else - Just don't add it back at all
    } forEach _items;

    //Add new uniform to the container
    if (_uniToAdd isNotEqualTo "") then {_container addItemCargoGlobal [_uniToAdd,1]};
};

NWG_UNEQ_ReplaceUniformForUnit = {
    params ["_unit","_newUniform"];

    private _unitUniformLoadout = (getUnitLoadout _unit) select UNIFORM_IN_LOADOUT;
    if (_unitUniformLoadout isEqualTo []) then {
        _unitUniformLoadout = [_newUniform,nil];//Dress up naked units
    } else {
        _unitUniformLoadout set [0,_newUniform];//Replace uniform
    };

    private _newLoadout = [];
    _newLoadout resize 10;//Get array with 10 'nil' elements
    _newLoadout set [UNIFORM_IN_LOADOUT,_unitUniformLoadout];

    _unit setUnitLoadout _newLoadout;
};