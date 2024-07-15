/*
    Reference used: SetupPylons by Artemoz
    This is NOT the same script, but a cut-down and reworked version of it because I wanted to:
    a) Allow it to be put in public (never got such permission from Artemoz)
    b) Make it consistent with appearanceCustomization and use the same UI

    Differences are:
    - Uses custom camera view instead of no changes to camera
    - Uses the same UI as appearanceCustomization instead of custom UI by Artemoz
    - Does not support precise pylon customization, only presets (about 3/4 of functionality is removed)
    - Rearranged and refactored code

    @Asmo
*/

//================================================================================================================
//================================================================================================================
//Defines
#define TITLE_TEMPLATE "[ %1 ]"

//================================================================================================================
//================================================================================================================
//Methods
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
    };

    //Create GUI
    private _guiCreateResult = _vehicle call NWG_fnc_vcuiCreateCustomizationUI;
    if (_guiCreateResult isEqualTo false) exitWith {
        "NWG_VCPYL_CustomizePylons: Failed to create GUI" call NWG_fnc_logError;
    };
    _guiCreateResult params ["_gui","_leftPanel","_rightPanel"];

    //Init the left panel (pylon presets)
    _leftPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_LEFT_TITLE#" call NWG_fnc_localize)]);
    private _presets = "true" configClasses (configOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Presets");
    private _picture = getText (configOf _vehicle >> "icon");
	{
		private _i = _leftPanel lbAdd (getText (_x >> "displayName"));
		_leftPanel lbSetData [_i, (configName _x)];
        _leftPanel lbSetPicture [_i, _picture];
	} forEach _presets;

    //Init the right panel (pylon owner)
    _rightPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_RIGHT_TITLE#" call NWG_fnc_localize)]);
    _rightPanel lbAdd ("#CPYL_OWNER_PILOT#" call NWG_fnc_localize);
    _rightPanel lbAdd ("#CPYL_OWNER_GUNNER#" call NWG_fnc_localize);
};