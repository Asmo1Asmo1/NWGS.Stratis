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
//Gets random daytime as string (does not need to be localized, format "00:00") (can be used in NWG_fnc_wcSetDaytimeAndWeather)
NWG_fnc_wcGetRndDaytimeStr = {
    call NWG_WCONF_COM_GetRndDaytimeStr
};

//Gets random weather as string (NEEDS to be localized) (can be used in NWG_fnc_wcSetDaytimeAndWeather)
NWG_fnc_wcGetRndWeatherStr = {
    call NWG_WCONF_COM_GetRndWeatherStr
};

//Gets weather string localization key
// params:
// 0: string - weather as string (get from NWG_fnc_wcGetRndWeatherStr)
// note: to be used client-side only and with conjunction with NWG_fnc_localize
NWG_fnc_wcGetWeatherStrLoc = {
    // private _weatherStr = _this;
    _this call NWG_WCONF_COM_GetWeatherStrLoc
};

//Sets daytime and weather
// params:
// 0: string - daytime as string (get from NWG_fnc_wcGetRndDaytimeStr)
// 1: string - weather as string (get from NWG_fnc_wcGetRndWeatherStr)
// note: is safe to use on client as it will transfer to server execution
NWG_fnc_wcSetDaytimeAndWeather = {
    // params ["_daytimeStr","_weatherStr"];
    _this call NWG_WCONF_COM_SetDaytimeAndWeather
};
