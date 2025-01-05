/*
    Reference used: SetupPylons by Artemoz
    This is NOT the same script, but a cut-down and reworked version of it because I wanted to:
    a) Allow it to be put in public (never got such permission from Artemoz)
    b) Make it consistent with vehCustomizationAppearance and use the same UI

    Differences are:
    - Uses custom camera view instead of no changes to camera
    - Uses the same UI as vehCustomizationAppearance instead of custom UI by Artemoz
    - Does not support precise pylon customization, only presets (about 3/4 of functionality is removed)
    - Changes in how we store variables, how we apply choice and so on
    - Click-rate limit to prevent DDOS'ing the server
    - Rearranged and refactored code

    @Asmo
*/

//Rate limit to prevent DDOS'ing the server (each valid click is another client->server request)
#define PROTECTION_RATE 0.1
NWG_VCPYL_protectionTime = 0;

NWG_VCPYL_CanCustomizePylons = {
    // private _vehicle = _this;
    "true" configClasses (configOf _this >> "Components" >> "TransportPylonsComponent") isNotEqualTo []
};

NWG_VCPYL_CustomizePylons = {
    disableSerialization;
    private _vehicle = _this;

    //Check argument
    if !(_vehicle call NWG_VCPYL_CanCustomizePylons) exitWith {
        (format ["NWG_VCPYL_CustomizePylons: %1 cannot be customized",(typeOf _vehicle)]) call NWG_fnc_logError;
        false
    };

    //Create GUI
    private _guiCreateResult = [_vehicle,"#CPYL_LEFT_TITLE#","#CPYL_RIGHT_TITLE#"] call NWG_fnc_vcuiCreateCustomizationUI;
    if (_guiCreateResult isEqualTo false) exitWith {
        "NWG_VCPYL_CustomizePylons: Failed to create GUI" call NWG_fnc_logError;
        false
    };
    _guiCreateResult params ["_gui","_leftPanel","_rightPanel"];

    //Init the left panel (pylon presets)
    private _presets = "true" configClasses (configOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Presets");
    private _picture = getText (configOf _vehicle >> "icon");
    {
        private _i = _leftPanel lbAdd (getText (_x >> "displayName"));
        _leftPanel lbSetData [_i, (configName _x)];
        _leftPanel lbSetPicture [_i, _picture];
    } forEach _presets;

    //Init the right panel (pylon owner)
    _rightPanel lbAdd ("#CPYL_OWNER_PILOT#" call NWG_fnc_localize);
    _rightPanel lbAdd ("#CPYL_OWNER_GUNNER#" call NWG_fnc_localize);

    //Define customization logic
    with uiNamespace do {
        _gui setVariable ["NWG_VCPYL_vehicle",_vehicle];
        _gui setVariable ["NWG_VCPYL_selectedPreset",""];
        _gui setVariable ["NWG_VCPYL_isPilotOwner",true];
    };

    _leftPanel ctrlAddEventHandler ["LBSelChanged", {
        //Pylon preset selected
        // params ["_control", "_lbCurSel", "_lbSelection"];
        params ["_panel","_index"];

        if (time > NWG_VCPYL_protectionTime) then {
            NWG_VCPYL_protectionTime = time + PROTECTION_RATE;
            private _gui = ctrlParent _panel;
            switch (_index) do {
                case -1: {/*Do nothing on 'unselected'*/};
                case  0: {_gui setVariable ["NWG_VCPYL_selectedPreset",""]};//Title clicked - Clear preset
                default {
                    private _preset = _panel lbData _index;
                    _gui setVariable ["NWG_VCPYL_selectedPreset",_preset];

                    private _vehicle = _gui getVariable "NWG_VCPYL_vehicle";
                    private _isPilotOwner = _gui getVariable "NWG_VCPYL_isPilotOwner";
                    [_vehicle,_preset,_isPilotOwner] spawn NWG_fnc_vcpOnPresetSelected;
                };
            };
        };

    }];

    _rightPanel ctrlAddEventHandler ["LBSelChanged", {
        //Pylon owner selected
        // params ["_control", "_lbCurSel", "_lbSelection"];
        params ["_panel","_index"];

        if (time > NWG_VCPYL_protectionTime) then {
            NWG_VCPYL_protectionTime = time + PROTECTION_RATE;
            private _gui = ctrlParent _panel;
            switch (_index) do {
                case -1: {/*Do nothing on 'unselected'*/};
                case  0: {_gui setVariable ["NWG_VCPYL_isPilotOwner",true]};//Title clicked - Default to pilot
                default {
                    private _isPilotOwner = (_index == 1);
                    _gui setVariable ["NWG_VCPYL_isPilotOwner",_isPilotOwner];

                    private _vehicle = _gui getVariable "NWG_VCPYL_vehicle";
                    private _preset = _gui getVariable "NWG_VCPYL_selectedPreset";
                    if (_preset isNotEqualTo "")
                        then {[_vehicle,_preset,_isPilotOwner] spawn NWG_fnc_vcpOnPresetSelected};
                };
            };
        };

    }];

    /*
        It could be re-written to decrease nesting and improve readability, BUT,
        not sure with that one, but with some other vanilla event handlers
        there were legit issues with 'exitWith' command being used inside the event handler code block
        resulting in unexpected behavior.
        So it is how it is.
    */

    true
};