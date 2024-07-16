//Creates vehicle customization UI
//params:
//  _vehicle - object
//  _leftTitle - string
//  _rightTitle - string
//returns: [_gui,_leftPanel,_rightPanel] OR false if there was an error
NWG_fnc_vcuiCreateCustomizationUI = {
    // params ["_vehicle","_leftTitle","_rightTitle"];
    _this call NWG_VCUI_CreateCustomizationUI
};