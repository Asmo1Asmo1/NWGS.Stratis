//Gets the world name
//note: worldName -> 'stratis', this function -> 'Stratis'
NWG_fnc_wcGetWorldName = {
    call NWG_WINFO_GetWorldName
};

//Gets the world name localization key
//note: to be used client-side only and with conjunction with NWG_fnc_localize
NWG_fnc_wcGetWorldNameLocKey = {
    call NWG_WINFO_GetWorldNameLocKey
};