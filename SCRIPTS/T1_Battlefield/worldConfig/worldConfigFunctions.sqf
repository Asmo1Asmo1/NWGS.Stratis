/*World name*/
//Gets the world name
//note: worldName -> 'stratis', this function -> 'Stratis'
NWG_fnc_wcGetWorldName = {
    call NWG_WCONF_COM_GetWorldNameRaw
};

//Gets the world name localization key
//note: to be used client-side only and with conjunction with NWG_fnc_localize
NWG_fnc_wcGetWorldNameLocKey = {
    call NWG_WCONF_COM_GetWorldNameLoc
};

/*Daytime and Weather*/
//Returns random daytime
//returns:
// 0: string - daytime string value
// 1: string - daytime localization key
NWG_fnc_wcGetRndDaytime = {
    call NWG_WCONF_COM_GetRndDaytime
};

//Returns random weather
//returns:
// 0: string - weather string value
// 1: string - weather localization key
NWG_fnc_wcGetRndWeather = {
    call NWG_WCONF_COM_GetRndWeather
};

//Sets daytime and weather
// params:
// 0: string - daytime string value (get from NWG_fnc_wcGetRndDaytime)
// 1: string - weather string value (get from NWG_fnc_wcGetRndWeather)
// note: is safe to use on client as it will transfer to server execution
NWG_fnc_wcSetDaytimeAndWeather = {
    // params ["_daytime","_weather"];
    _this call NWG_WCONF_COM_SetDaytimeAndWeather
};
