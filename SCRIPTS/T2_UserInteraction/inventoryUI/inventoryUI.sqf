//================================================================================================================
//Settings
NWG_INVUI_Settings = createHashMapFromArray [
    ["BUTTON_LOOT_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\upload_ca.paa"],
    ["BUTTON_WEAP_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa"],
    ["BUTTON_UNIF_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\armor_ca.paa"],
    ["BUTTON_MAGR_ICON","\A3\ui_f\data\igui\cfg\simpleTasks\types\rearm_ca.paa"],

    ["SOUND_ON",true],
    ["SOUND_BUTTON_LOOT","Scared_Animal2"],
    ["SOUND_BUTTON_WEAP","surrender_fall"],
    ["SOUND_BUTTON_UNIF","surrender_stand_up"],
    ["SOUND_BUTTON_MAGR","Place_Flag"],

    ["WHILE_LOADOUT_SET_CLOSE",true],//Close inventory during loadout set for player (e.g.: open inventory while equipping uniform)
    ["WHILE_LOADOUT_SET_BLOCK",true],//Block buttons during loadout set for player (e.g.: pushing buttons while changing add. weapon)

    ["",0]
];

//================================================================================================================
//Init
private _Init = {
    player addEventHandler ["InventoryOpened",{_this spawn NWG_INVUI_OnInventoryOpen}];
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

    //Check if player loadout set is in progress
    if ((NWG_INVUI_Settings get "WHILE_LOADOUT_SET_CLOSE") && {call NWG_fnc_invIsLoadoutSetInProgress}) then {
        (uiNamespace getVariable ["RscDisplayInventory", displayNull]) closeDisplay 2;
    };

    //Create our custom inventory UI additons
    private _buttonLoot = _inventoryDisplay ctrlCreate ["IUI_ButtonLoot",-1];
    private _buttonWeap = _inventoryDisplay ctrlCreate ["IUI_ButtonWeaponSwitch",-1];
    private _buttonUnif = _inventoryDisplay ctrlCreate ["IUI_ButtonUniform",-1];
    private _buttonMagR = _inventoryDisplay ctrlCreate ["IUI_ButtonMagRepack",-1];

    //Handle data store and cleanup
    uiNamespace setVariable ["NWG_INVUI_eventArgs",_this];//Store arguments for later use
    _inventoryDisplay displayAddEventHandler ["Unload",{
        uiNamespace setVariable ["NWG_INVUI_eventArgs",nil];
    }];

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
//Buttons
NWG_INVUI_OnButtonLoot = {
    if ((NWG_INVUI_Settings get "WHILE_LOADOUT_SET_BLOCK") && {call NWG_fnc_invIsLoadoutSetInProgress}) exitWith {};
    //Loot the container opened in inventory
    private _ok = (call NWG_INVUI_GetActualContainer) call NWG_fnc_lsLootContainerByUI;
    if (_ok) then {
        (NWG_INVUI_Settings get "SOUND_BUTTON_LOOT") call NWG_INVUI_PlaySound;
    };
};

NWG_INVUI_OnButtonWeap = {
    if ((NWG_INVUI_Settings get "WHILE_LOADOUT_SET_BLOCK") && {call NWG_fnc_invIsLoadoutSetInProgress}) exitWith {};
    //Switch primary<->additional weapon
    private _ok = call NWG_fnc_awSwitchWeapon;
    if (_ok) then {
        (NWG_INVUI_Settings get "SOUND_BUTTON_WEAP") call NWG_INVUI_PlaySound;
    };
};

NWG_INVUI_OnButtonUnif = {
    if ((NWG_INVUI_Settings get "WHILE_LOADOUT_SET_BLOCK") && {call NWG_fnc_invIsLoadoutSetInProgress}) exitWith {};
    //Equip the unform selected in inventory
    private _ok = (call NWG_INVUI_GetActualContainer) call NWG_fnc_uneqEquipSelected;
    if (_ok) then {
        (NWG_INVUI_Settings get "SOUND_BUTTON_UNIF") call NWG_INVUI_PlaySound;
    };
};

NWG_INVUI_OnButtonMagR = {
    if ((NWG_INVUI_Settings get "WHILE_LOADOUT_SET_BLOCK") && {call NWG_fnc_invIsLoadoutSetInProgress}) exitWith {};
    //Magazine repack
    call NWG_fnc_mroOpen;//Opens separate window
    (NWG_INVUI_Settings get "SOUND_BUTTON_MAGR") call NWG_INVUI_PlaySound;//Always play sound
};

//================================================================================================================
//Actual container get
//Returns container object and listbox IDC
NWG_INVUI_GetActualContainer = {
    disableSerialization;

    //Get physical containers
    (uiNamespace getVariable ["NWG_INVUI_eventArgs",[]]) params [["_c1",objNull],["_c2",objNull]];
    if (isNull _c1 && {isNull _c2}) exitWith {
        "NWG_INVUI_GetActualContainer: both containers are null" call NWG_fnc_logError;
        [objNull,-1]
    };

    //Get UI lists
    private _display = uiNamespace getVariable ["RscDisplayInventory", displayNull];
    if (isNull _display) exitWith {
        "NWG_INVUI_GetActualContainer: inventory display not found" call NWG_fnc_logError;
        [objNull,-1]
    };
    private _l1 = _display displayCtrl 640;
    private _l2 = _display displayCtrl 632;
    private _l1Shown = ctrlShown _l1;
    private _l2Shown = ctrlShown _l2;
    if (!_l1Shown && !_l2Shown) exitWith {
        "NWG_INVUI_GetActualContainer: both lists are hidden" call NWG_fnc_logError;
        [objNull,-1]
    };
    if (_l1Shown && _l2Shown) exitWith {
        "NWG_INVUI_GetActualContainer: both lists are shown" call NWG_fnc_logError;
        [objNull,-1]
    };

    //Define which UI list to return
    private _resultIDC = if (_l1Shown) then {640} else {632};

    //Define which container to return
    private _normalize = {
        private _container = _this;
        if (isNull _container) exitWith {objNull};//Null check
        if (_container isEqualTo player) exitWith {objNull};//Player check (1)
        private _parent = if (_container isKindOf "GroundWeaponHolder" || {
            _container isKindOf "WeaponHolder" || {
            _container isKindOf "WeaponHolderSimulated"}}
        ) then {objNull} else {objectParent _container};
        if (!isNull _parent && {_parent isKindOf "Man"}) then {_container = _parent};//Replace with unit parent
        if (_container isEqualTo player) exitWith {objNull};//Player check (2)
        if (_container isKindOf "Man" && {alive _container}) exitWith {objNull};//Alive unit check
        _container
    };
    _c1 = _c1 call _normalize;
    _c2 = _c2 call _normalize;

    private _resultContainer = switch (true) do {
        case (isNull _c1): {_c2};
        case (isNull _c2): {_c1};
        case (_l1Shown): {_c1};
        case (_l2Shown): {_c2};
        default {
            "NWG_INVUI_GetActualContainer: could not determine container" call NWG_fnc_logError;
            objNull
        };
    };

    //return
    [_resultContainer,_resultIDC]
};

//================================================================================================================
//Sound
NWG_INVUI_PlaySound = {
    //private _sound = _this;
    if !(NWG_INVUI_Settings get "SOUND_ON") exitWith {};
    playSound _this;
};

//================================================================================================================
call _Init;