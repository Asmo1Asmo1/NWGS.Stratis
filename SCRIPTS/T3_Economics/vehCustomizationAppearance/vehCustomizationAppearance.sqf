/*
    Module to change vehicle appearance (colors and components)

    - Uses the same UI as vehCustomizationPylons
    - Uses custom camera view
    - Does not highlight the current selection (TODO: add maybe?)
    @Asmo
*/
/*
    Refactoring notes:
    We loop through the same arrays 3 times: once to get the current customization, once to get all the options and once to get display names.
    Maybe there is a way to do it in one loop?
*/

//Rate limit to prevent DDOS'ing the server (each valid click is another client->server request)
#define PROTECTION_RATE 0.1
NWG_VCAPP_protectionTime = 0;

//======================================================================================================
//======================================================================================================
//Customization getters
NWG_VCAPP_HasCustomizationOptions = {
    // private _vehicle = _this;
    ([_this,/*colors:*/true,/*anims:*/true] call NWG_VCAPP_GetCustomizationOptions) params ["_colors","_animations"];
    //return
    (((count _colors) > 2) || ((count _animations) > 2))
};

NWG_VCAPP_GetCurrentCustomization = {
    //Returns the current customization of the vehicle just like BIS_fnc_getVehicleCustomization does, but with all the options available
    // private _vehicle = _this;
    ([_this,/*colors:*/true,/*anims:*/false] call NWG_VCAPP_GetCustomizationOptions) params ["_colors"];
    (_this call BIS_fnc_getVehicleCustomization) params ["_curColors","_animations"];

    //Transfer color
    private _i = _colors find (_curColors param [0,""]);//_curColors is usually ["ColorName",1]
    if (_i != -1) then {_colors set [(_i+1),1]};

    //Transfer animations
    /*
        Testing and debugging showed that current animations that we got with 'BIS_fnc_getVehicleCustomization'
        Is usually exactly the same as 'all animations' but with flags set correctly.
        So we don't need to do anything here, just take and use it.
    */

    //return
    [_colors,_animations]
};

NWG_VCAPP_GetCustomizationOptions = {
    //Modified content of BIS_fnc_getVehicleCustomization that gets ALL the colors and animations available, not just the current ones
    //see: https://community.bistudio.com/wiki/BIS_fnc_getVehicleCustomization
    params ["_vehicle",["_getColors",true],["_getAnimations",true]];
    private _vehCfg = configFile >> "cfgVehicles" >> (typeof _vehicle);

    private _colors = [];
    if (_getColors) then {
        {
            _colors pushBack (configName _x);
            _colors pushBack 0;
        } forEach ("true" configClasses (_vehCfg >> "TextureSources"));
    };

    private _animations = [];
    if (_getAnimations) then {
        {
            _animations pushBack (configName _x);
            _animations pushBack 0;
        } forEach ((configProperties [_vehCfg >> "animationSources", "isClass _x", true])
            select {getText (_x >> "displayName") isNotEqualTo "" && {getnumber (_x >> "scope") > 1 || !isnumber (_x >> "scope")}});
    };

    //return
    [_colors,_animations]
};

NWG_VCAPP_GetCustomizationDisplayNames = {
    // private _vehicle = _this;
    private _vehCfg = configFile >> "cfgVehicles" >> (typeOf _this);
    private _cur = "";

    private _colorDisplayNames = [];
    {
        _cur = getText (_x >> "displayName");
        if (_cur isEqualTo "") then { _displayName = configName _x};
        _colorDisplayNames pushBack _cur;
        _colorDisplayNames pushBack 0;
    } forEach ("true" configClasses (_vehCfg >> "TextureSources"));

    private _animationDisplayNames = [];
    {
        _cur = getText (_x >> "displayName");
        if (_cur isEqualTo "") then { _displayName = configName _x};
        _animationDisplayNames pushBack _cur;
        _animationDisplayNames pushBack 0;
    } forEach ((configProperties [_vehCfg >> "animationSources", "isClass _x", true])
        select {getText (_x >> "displayName") isNotEqualTo "" && {getNumber (_x >> "scope") > 1 || !isNumber (_x >> "scope")}});

    // return
    [_colorDisplayNames, _animationDisplayNames]
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
    (_vehicle call NWG_VCAPP_GetCurrentCustomization) params ["_colors","_animations"];
};