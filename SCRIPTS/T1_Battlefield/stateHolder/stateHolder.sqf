/*
    Annotation:
    This is a 'state' module that does not contain any logic
    It's purpose is to share data across Battlefield sub-systems
*/

NWG_STHLD_States = createHashMap;

NWG_STHLD_GetState = {
    // private _state = _this;
    NWG_STHLD_States get _this
};

NWG_STHLD_SetState = {
    params ["_state","_value"];
    NWG_STHLD_States set [_state,_value];
};