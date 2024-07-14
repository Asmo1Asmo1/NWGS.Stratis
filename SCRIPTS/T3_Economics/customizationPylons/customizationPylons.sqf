/*
    Reference used: SetupPylons by Artemoz
    This is NOT the same script, this is cut-down and reworked version of it because I wanted to:
    a) Allow it to be put in public (never got such permission from Artemoz)
    b) Make it consistent with appearanceCustomization and use the same UI

    Differences are:
    - Uses the same UI as appearanceCustomization instead of custom UI by Artemoz
    - Does not support precise pylon customization, only presets (removed 3/4 of functionality)
    - Rearranged and refactored code

    @Asmo
*/

//================================================================================================================
//================================================================================================================
//Defines
#define DIALOGUE_NAME "vehicleCustomization"
#define LEFT_BOX_IDD 1500
#define RIGHT_BOX_IDD 1501
#define TITLE_TEMPLATE "[ %1 ]"

//================================================================================================================
//================================================================================================================
//Methods
NWG_CPYL_CanCustomizePylons = {
    // private _vehicle = _this;
    "true" configClasses (configOf _this >> "Components" >> "TransportPylonsComponent") isNotEqualTo []
};

NWG_CPYL_CustomizePylons = {
    disableSerialization;
    // private _vehicle = _this;

    //Check argument
    if !(_this call NWG_CPYL_CanCustomizePylons) exitWith {
        (format ["NWG_CPYL_CustomizePylons: %1 cannot be customized",(typeOf _this)]) call NWG_fnc_logError;
    };

    //Create GUI
    private _gui = createDialog [DIALOGUE_NAME,true];
    if (isNull _gui) exitWith {
        "NWG_CPYL_CustomizePylons: Failed to create GUI" call NWG_fnc_logError;
    };

    //Save arguments so far (will be disposed of when GUI is closed)
    _gui setVariable ["NWG_CPYL_vehicle",_this];

    //Init the left panel (pylon presets)
    private _leftPanel = _gui displayCtrl LEFT_BOX_IDD;
    _leftPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_LEFT_TITLE#" call NWG_fnc_localize)]);
    private _presets = "true" configClasses (configOf _this >> "Components" >> "TransportPylonsComponent" >> "Presets");
    private _picture = getText (configOf _this >> "icon");
	{
		private _i = _leftPanel lbAdd (getText (_x >> "displayName"));
		_leftPanel lbSetData [_i, (configName _x)];
        _leftPanel lbSetPicture [_i, _picture];
	} forEach _presets;

    //Init the right panel (pylon owner)
    private _rightPanel = _gui displayCtrl RIGHT_BOX_IDD;
    _rightPanel lbAdd (format [TITLE_TEMPLATE,("#CPYL_RIGHT_TITLE#" call NWG_fnc_localize)]);
    _rightPanel lbAdd ("#CPYL_OWNER_PILOT#" call NWG_fnc_localize);
    _rightPanel lbAdd ("#CPYL_OWNER_GUNNER#" call NWG_fnc_localize);
};