//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["InventoryOpened",{_this spawn NWG_INVUI_OnInventoryOpen}];
};

//================================================================================================================
//Handler
NWG_INVUI_OnInventoryOpen = {
    disableSerialization;
    // params ["_unit", "_container"];
    // params ["_unit","_mainContainer","_secdContainer"];

    //Wait for vanilla inventory to open
    private _inventoryDisplay = displayNull;
    waitUntil {
        _inventoryDisplay = findDisplay 602;
        !isNull _inventoryDisplay
    };

    //Create our custom inventory UI additons
    private _textWeight = _inventoryDisplay ctrlCreate ["TextWeight",-1];
    private _buttonLoot = _inventoryDisplay ctrlCreate ["ButtonLoot",-1];
    private _buttonWeap = _inventoryDisplay ctrlCreate ["ButtonWeaponSwitch",-1];
    private _buttonUnif = _inventoryDisplay ctrlCreate ["ButtonUniform",-1];
    private _buttonMagR = _inventoryDisplay ctrlCreate ["ButtonMagRepack",-1];

    //Add pictures to buttons
    _buttonLoot ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\upload_ca.paa";
    _buttonWeap ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa";
    _buttonUnif ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\armor_ca.paa";
    _buttonMagR ctrlSetText "\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa";

    //Add tooltips
    _buttonLoot ctrlSetTooltip ("#INV_BUTTON_LOOT_TOOLTIP#" call NWG_fnc_localize);
    _buttonWeap ctrlSetTooltip ("#INV_BUTTON_WEAP_TOOLTIP#" call NWG_fnc_localize);
    _buttonUnif ctrlSetTooltip ("#INV_BUTTON_UNIF_TOOLTIP#" call NWG_fnc_localize);
    _buttonMagR ctrlSetTooltip ("#INV_BUTTON_MAGR_TOOLTIP#" call NWG_fnc_localize);

    //Add handlers
    _buttonLoot ctrlAddEventHandler ["ButtonClick",{call NWG_INVUI_OnButtonLoot}];
    _buttonWeap ctrlAddEventHandler ["ButtonClick",{call NWG_INVUI_OnButtonWeap}];
    _buttonUnif ctrlAddEventHandler ["ButtonClick",{call NWG_INVUI_OnButtonUnif}];
    _buttonMagR ctrlAddEventHandler ["ButtonClick",{call NWG_INVUI_OnButtonMagR}];

    systemChat "Custom inventory UI created!";
};

//================================================================================================================
//Buttons
NWG_INVUI_OnButtonLoot = {
    //TODO: Implement
    systemChat "Loot button pressed!";
};

NWG_INVUI_OnButtonWeap = {
    //TODO: Implement
    systemChat "Weapon switch button pressed!";
};

NWG_INVUI_OnButtonUnif = {
    //TODO: Implement
    systemChat "Uniform change button pressed!";
};

NWG_INVUI_OnButtonMagR = {
    //TODO: Implement
    systemChat "Magazine repack button pressed!";
};

//================================================================================================================
call _Init;