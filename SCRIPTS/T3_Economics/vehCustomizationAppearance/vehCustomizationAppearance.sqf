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

NWG_VCAPP_HasCustomizationOptions = {
    // private _vehicle = _this;
    (_this call NWG_VCAPP_GetCustomizationOptions) params ["_colors","_animations"];
    //return
    (((count _colors) > 2) || ((count _animations) > 2))
};

NWG_VCAPP_GetCurrentCustomization = {
    //Returns the current customization of the vehicle just like BIS_fnc_getVehicleCustomization does, but with all the options available
    // private _vehicle = _this;
    (_this call NWG_VCAPP_GetCustomizationOptions) params ["_colors"];
    (_this call BIS_fnc_getVehicleCustomization)   params ["_curColors","_animations"];

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
    // private _vehicle = _this;
    private _vehCfg = configFile >> "cfgVehicles" >> (typeof _this);

    private _colors = [];
    {
        _colors pushBack (configName _x);
        _colors pushBack 0;
    } forEach ("true" configClasses (_vehCfg >> "TextureSources"));

    private _animations = [];
    {
        _animations pushBack (configName _x);
        _animations pushBack 0;
    } forEach ((configProperties [_vehCfg >> "animationSources", "isClass _x", true])
        select {getText (_x >> "displayName") isNotEqualTo "" && {getnumber (_x >> "scope") > 1 || !isnumber (_x >> "scope")}});

    //return
    [_colors,_animations]
};
