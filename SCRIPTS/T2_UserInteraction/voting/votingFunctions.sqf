/* Server -> Client */

//Not for public use
NWG_fnc_voteRequestGolos = {
    // params ["_anchor","_title","_timeout"];
    if (isNil "NWG_VOTE_CLI_OnGolosRequest") exitWith {};//Fix client not ready yet
    if (isNull player || {!alive player}) exitWith {};//Fix player not ready yet
    _this call NWG_VOTE_CLI_OnGolosRequest;
};