/*
    Module to change vehicle appearance (colors and components)

    - Uses the same UI as vehCustomizationPylons
    - Uses custom camera view
    - Does not highlight the current selection (TODO: add maybe?)
    @Asmo
*/

//Rate limit to prevent DDOS'ing the server (each valid click is another client->server request)
#define PROTECTION_RATE 0.1
NWG_VCAPP_protectionTime = 0;

//Enum
#define CONFIG_NAME 0
#define DISPLAY_NAME 1
#define FLAG 2

//======================================================================================================
//======================================================================================================
//Customization getters
NWG_VCAPP_HasCustomizationOptions = {
    // private _vehicle = _this;
    (_this call NWG_VCAPP_GetCustomization) params ["_colors","_animations"];
    //return
    (((count _colors) > 1) || ((count _animations) > 1))
};

NWG_VCAPP_GetCustomization = {
    //Modified content of BIS_fnc_getVehicleCustomization that gets ALL the colors and animations available not just the current ones (+ with display names)
    //see: https://community.bistudio.com/wiki/BIS_fnc_getVehicleCustomization
    private _vehicle = _this;
    private _vehCfg = configFile >> "cfgVehicles" >> (typeof _vehicle);
    private ["_configName","_displayName","_flag"];

    //--- Read colors
    private _colors = [];
    private _normalizeTexturesArray = {
        // private _array = _this;
        //return
        _this apply {
            switch (true) do {
                case (!(_x isEqualType "")): {_x};
                case (_x find "\" != 0): {"\" + (toLower _x)};
                default {(toLower _x)};
            }
        }
    };

    private _currentTextures = (getObjectTextures _vehicle) call _normalizeTexturesArray;
    _flag = 0;
    {
        _configName = configName _x;
        _displayName = getText (_x >> "displayName");
        if (isNil "_displayName" || {_displayName isEqualTo ""}) then {_displayName = _configName};
        /*Use the fact that only one color can hit match, so we can safely cut corner and skip the rest*/
        if (_flag == 0) then {
            private _textures = (getArray (_x >> "textures")) call _normalizeTexturesArray;
            private _isMatch = (count (_textures arrayIntersect _currentTextures)) > 0;
            _flag = if (_isMatch) then {1} else {0};
            _colors pushBack [_configName,_displayName,_flag];
        } else {
            _colors pushBack [_configName,_displayName,0];
        };
    } forEach ("true" configClasses (_vehCfg >> "TextureSources"));

    //--- Read components
    //(animations they call them, technically some of them are, but mostly they are just 'on|off' switches)
    private _animations = [];
    {
        _configName = configName _x;
        _displayName = getText (_x >> "displayName");
        if (isNil "_displayName" || {_displayName isEqualTo ""}) then {_displayName = _configName};
        _flag = _vehicle animationPhase _configName;
        _animations pushBack [_configName,_displayName,_flag];
    } forEach ((configProperties [_vehCfg >> "animationSources", "isClass _x", true])
        select {getText (_x >> "displayName") isNotEqualTo "" && {getNumber (_x >> "scope") > 1 || !isNumber (_x >> "scope")}});

    //return
    [_colors,_animations]
};

//======================================================================================================
//======================================================================================================
//Customization change logic
NWG_VCAPP_CustomizeAppearance = {
    disableSerialization;
    private _vehicle = _this;

    //Check argument
    if !(_vehicle call NWG_VCAPP_HasCustomizationOptions) exitWith {
        (format ["NWG_VCAPP_CustomizeAppearance: %1 cannot be customized",(typeOf _vehicle)]) call NWG_fnc_logError;
    };

    //Create GUI
    private _guiCreateResult = [_vehicle,"#CAPP_LEFT_TITLE#","#CAPP_RIGHT_TITLE#"] call NWG_fnc_vcuiCreateCustomizationUI;
    if (_guiCreateResult isEqualTo false) exitWith {
        "NWG_VCAPP_CustomizeAppearance: Failed to create GUI" call NWG_fnc_logError;
    };
    _guiCreateResult params ["_gui","_leftPanel","_rightPanel"];

    //Get customization options
    (_vehicle call NWG_VCAPP_GetCustomization) params ["_colors","_animations"];

    //Init the left panel (colors)
    private _picture = getText (configOf _vehicle >> "icon");
    {
        private _i = _leftPanel lbAdd (_x select DISPLAY_NAME);
        _leftPanel lbSetPicture [_i, _picture];
    } forEach _colors;

    //Init the right panel (components)
    {
        _rightPanel lbAdd (_x select DISPLAY_NAME);
    } forEach _animations;
};