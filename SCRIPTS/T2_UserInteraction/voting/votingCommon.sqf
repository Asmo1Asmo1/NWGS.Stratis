/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

NWG_VOTE_COM_IsValid = {
    // private _anchor = _this;
    !isNull _this && {alive _this && {!isNil {_this getVariable "NWG_VOTE_for"}}}
};

NWG_VOTE_COM_GetFor = {
    // private _anchor = _this;
    _this getVariable ["NWG_VOTE_for",0]
};
NWG_VOTE_COM_SetFor = {
    params ["_anchor","_value"];
    _this setVariable ["NWG_VOTE_for",_value,true];
};
NWG_VOTE_COM_AddFor = {
    // private _anchor = _this;
    [_this,((_this call NWG_VOTE_COM_GetFor) + 1)] call NWG_VOTE_COM_SetFor;
};

NWG_VOTE_COM_GetAgainst = {
    // private _anchor = _this;
    _this getVariable ["NWG_VOTE_against",0]
};
NWG_VOTE_COM_SetAgainst = {
    params ["_anchor","_value"];
    _this setVariable ["NWG_VOTE_against",_value,true];
};
NWG_VOTE_COM_AddAgainst = {
    // private _anchor = _this;
    [_this,((_this call NWG_VOTE_COM_GetAgainst) + 1)] call NWG_VOTE_COM_SetAgainst;
};