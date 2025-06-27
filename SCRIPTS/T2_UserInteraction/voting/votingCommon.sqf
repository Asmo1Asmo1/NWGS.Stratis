/*
    Annotation:
    This block is common for both server and client sides
    It is compiled for both, exists for both and may be internally used in both server and client side modules and functions
*/

NWG_VOTE_COM_IsValidAnchor = {
    // private _anchor = _this;
    !isNull _this && {alive _this && {!isNil {_this getVariable "NWG_VOTE_infavor"}}}
};

NWG_VOTE_COM_GetInfavor = {
    // private _anchor = _this;
    _this getVariable ["NWG_VOTE_infavor",0]
};
NWG_VOTE_COM_SetInfavor = {
    params ["_anchor","_value"];
    _anchor setVariable ["NWG_VOTE_infavor",_value,true];
};

NWG_VOTE_COM_GetAgainst = {
    // private _anchor = _this;
    _this getVariable ["NWG_VOTE_against",0]
};
NWG_VOTE_COM_SetAgainst = {
    params ["_anchor","_value"];
    _anchor setVariable ["NWG_VOTE_against",_value,true];
};

NWG_VOTE_COM_Clear = {
    // private _anchor = _this;
    if !(_this call NWG_VOTE_COM_IsValidAnchor) exitWith {};
    _this setVariable ["NWG_VOTE_infavor",nil,true];
    _this setVariable ["NWG_VOTE_against",nil,true];
};