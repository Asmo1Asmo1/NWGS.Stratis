//================================================================================================================
//Settings
NWG_INVUI_Settings = createHashMapFromArray [
    ["BUTTON_LOOT_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\upload_ca.paa"],
    ["BUTTON_WEAP_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa"],
    ["BUTTON_UNIF_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\armor_ca.paa"],
    ["BUTTON_MAGR_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa"],
    ["TEXT_WEIGHT_TEMPLATE","%1kg"],

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["InventoryOpened",{_this spawn NWG_INVUI_OnInventoryOpen}];

    //Auto-update text on Take/Put
    player addEventHandler ["Take",{call NWG_INVUI_UpdateWeight}];
    player addEventHandler ["Put",{call NWG_INVUI_UpdateWeight}];
};

//================================================================================================================
//Handler
NWG_INVUI_OnInventoryOpen = {
    disableSerialization;
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

    //Handle data store and cleanup
    uiNamespace setVariable ["NWG_INVUI_textWeight",_textWeight];//Store weight text control
    uiNamespace setVariable ["NWG_INVUI_eventArgs",_this];//Store arguments for later use
    _inventoryDisplay displayAddEventHandler ["Unload",{
        uiNamespace setVariable ["NWG_INVUI_textWeight",nil];
        uiNamespace setVariable ["NWG_INVUI_eventArgs",nil];
    }];

    //Init weight text
    call NWG_INVUI_UpdateWeight;

    //Add pictures to buttons
    _buttonLoot ctrlSetText (NWG_INVUI_Settings get "BUTTON_LOOT_ICON");
    _buttonWeap ctrlSetText (NWG_INVUI_Settings get "BUTTON_WEAP_ICON");
    _buttonUnif ctrlSetText (NWG_INVUI_Settings get "BUTTON_UNIF_ICON");
    _buttonMagR ctrlSetText (NWG_INVUI_Settings get "BUTTON_MAGR_ICON");

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
};

//================================================================================================================
//Weight text
NWG_INVUI_UpdateWeight = {
    // disableSerialization;//Don't need if there are no private variables
    if (isNull (uiNamespace getVariable ["NWG_INVUI_textWeight",controlNull])) exitWith {};//Exit if not initialized (inventory closed or other reason)
    private _weight = round ((loadAbs player)/10);//Convert to kg
    (uiNamespace getVariable ["NWG_INVUI_textWeight",controlNull]) ctrlSetText (format [(NWG_INVUI_Settings get "TEXT_WEIGHT_TEMPLATE"),_weight]);
};

//================================================================================================================
//Buttons
NWG_INVUI_OnButtonLoot = {
    //Loot the container opened in inventory
    (uiNamespace getVariable ["NWG_INVUI_eventArgs",[]]) call NWG_fnc_lsLootOpenedContainer;
};

NWG_INVUI_OnButtonWeap = {
    //Switch primary<->additional weapon
    call NWG_fnc_awSwitchWeapon;
    call NWG_INVUI_UpdateWeight;
};

NWG_INVUI_OnButtonUnif = {
    //Equip the unform selected in inventory
    (uiNamespace getVariable ["NWG_INVUI_eventArgs",[]]) call NWG_fnc_uneqEquipSelected;
    call NWG_fnc_lsNotifyStorageChanged;//Notify loot storage that storage may have changed (if we equip uniform from loot storage)
};

NWG_INVUI_OnButtonMagR = {
    //Magazine repack
    call NWG_fnc_mroOpen;
};

//================================================================================================================
call _Init;