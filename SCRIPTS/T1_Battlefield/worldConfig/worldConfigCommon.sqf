//================================================================================================================
//================================================================================================================
//Defines
#define WORLD_NAME_RAW 0
#define WORLD_NAME_LOC 1

#define DAYTIME_HOUR_STR 0
#define DAYTIME_HOUR_INT 1

#define WEATHER_STR 0
#define WEATHER_LOC 1
#define WEATHER_SETTINGS 2
//================================================================================================================
//================================================================================================================
//Settings
NWG_WCONF_COM_Settings = createHashMapFromArray [
	/*World names*/
	["WORLD_NAMES", createHashMapFromArray [
		["stratis", ["Stratis","#WORLD_NAME_STRATIS#"]],
		["altis",   ["Altis","#WORLD_NAME_ALTIS#"]],
		["tanoa",   ["Tanoa","#WORLD_NAME_TANOA#"]],
		["malden",  ["Malden","#WORLD_NAME_MALDEN#"]],
		["bootcamp",["Bootcamp","#WORLD_NAME_BOOTCAMP#"]],
		["vr",      ["VR","#WORLD_NAME_VR#"]],
		["unknown", ["Unknown","#WORLD_NAME_UNKNOWN#"]]
	]],

	/*Daytime settings*//*[hourStr,hourInt]*/
	["DAYTIMES",[
		["00:00",0],
		// ["01:00",1],
		["02:00",2],
		// ["03:00",3],
		["04:00",4],
		// ["05:00",5],
		["06:00",6],
		["07:00",7],
		["08:00",8],
		["09:00",9],
		["10:00",10],
		["11:00",11],
		["12:00",12],
		["13:00",13],
		["14:00",14],
		["15:00",15],
		["16:00",16],
		["17:00",17],
		["18:00",18],
		["19:00",19],
		["20:00",20],
		// ["21:00",21],
		["22:00",22]
		// ["23:00",23]
	]],
	["DAYTIME_SMOOTH_TRANSITION",true],//If true, daytime will be set with transition (see: https://community.bistudio.com/wiki/BIS_fnc_setDate)

	/*Weather settings*//*[_weatherStr,_weatherLocKey,_settings: [[_overcastMinMax],[_windMinMax],[_rainMinMax],[_lightningsMinMax],[_fogMinMax]]]*/
	["WEATHERS",[
		["clear",  "#WEATHER_CLEAR#",[/*ovc:*/[0.0,0.3],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.0,0.3]]],
		["clear",  "#WEATHER_CLEAR#",[/*ovc:*/[0.0,0.3],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.0,0.3]]],
		["clear",  "#WEATHER_CLEAR#",[/*ovc:*/[0.0,0.3],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.0,0.3]]],
		["clear+w","#WEATHER_CLEAR#",[/*ovc:*/[0.0,0.3],/*wind:*/[3.0,6.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.4,0.7]]],
		["cloud",  "#WEATHER_CLOUD#",[/*ovc:*/[0.4,0.6],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.0,0.3]]],
		["cloud",  "#WEATHER_CLOUD#",[/*ovc:*/[0.4,0.6],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.0,0.3]]],
		["cloud+w","#WEATHER_CLOUD#",[/*ovc:*/[0.4,0.6],/*wind:*/[3.0,6.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.0,0.0],/*waves:*/[0.4,0.7]]],
		["rain",   "#WEATHER_RAIN#", [/*ovc:*/[0.6,0.9],/*wind:*/[0.0,0.0],/*rain:*/[0.5,0.8],/*lightnings:*/[0.0,0.5],/*fog:*/[0.0,0.0],/*waves:*/[0.2,0.5]]],
		["rain+w", "#WEATHER_RAIN#", [/*ovc:*/[0.6,0.9],/*wind:*/[1.5,2.5],/*rain:*/[0.5,0.8],/*lightnings:*/[0.0,0.7],/*fog:*/[0.0,0.0],/*waves:*/[0.4,0.7]]],
		["fog",    "#WEATHER_FOG#",  [/*ovc:*/[0.4,0.6],/*wind:*/[0.0,0.0],/*rain:*/[0.0,0.0],/*lightnings:*/[0.0,0.0],/*fog:*/[0.4,0.6],/*waves:*/[0.0,0.3]]],
		["storm",  "#WEATHER_STORM#",[/*ovc:*/[1.0,1.0],/*wind:*/[6.0,9.0],/*rain:*/[1.0,1.0],/*lightnings:*/[1.0,1.0],/*fog:*/[0.0,0.0],/*waves:*/[1.0,1.0]]]
	]],

	["",0]
];

//================================================================================================================
//================================================================================================================
//World name
NWG_WCONF_COM_GetWorldName = {
	private _worldNames = NWG_WCONF_COM_Settings get "WORLD_NAMES";
	private _curWorld = toLowerANSI worldName;
	_worldNames getOrDefault [_curWorld,(_worldNames get "unknown")]
};
NWG_WCONF_COM_GetWorldNameRaw = {
	(call NWG_WCONF_COM_GetWorldName) select WORLD_NAME_RAW
};
NWG_WCONF_COM_GetWorldNameLoc = {
	(call NWG_WCONF_COM_GetWorldName) select WORLD_NAME_LOC
};

//================================================================================================================
//================================================================================================================
//Daytime and Weather
NWG_WCONF_COM_GetRndDaytime = {
	private _daytimes = NWG_WCONF_COM_Settings get "DAYTIMES";
	private _dayTime = ([_daytimes,"NWG_WCONF_GetRndDaytime"] call NWG_fnc_selectRandomGuaranteed) select DAYTIME_HOUR_STR;
	//return
	//note: _daytime is both the string value and the (nonexistent) loc key (what's the point of localizing "00:00"?)
	[_dayTime,_dayTime]
};

NWG_WCONF_COM_GetRndWeather = {
	private _weathers = NWG_WCONF_COM_Settings get "WEATHERS";
	private _weather = ([_weathers,"NWG_WCONF_GetRndWeather"] call NWG_fnc_selectRandomGuaranteed);
	//return
	[(_weather#WEATHER_STR),(_weather#WEATHER_LOC)]
};

NWG_WCONF_COM_SetDaytimeAndWeather = {
	params ["_daytimeStr","_weatherStr"];

	//Check server side execution (mandatory)
	if (!isServer) exitWith {_this remoteExec ["NWG_WCONF_COM_SetDaytimeAndWeather",2]};//Should run on server

	//Calculate skip time
	private _daytimes = NWG_WCONF_COM_Settings get "DAYTIMES";
	private _i = _daytimes findIf {(_x#DAYTIME_HOUR_STR) isEqualTo _daytimeStr};
	if (_i == -1) exitWith {
		(format ["NWG_WCONF_COM_SetDaytimeAndWeather: Daytime not found: %1",_daytimeStr]) call NWG_fnc_logError;
	};
	private _skipHours = (((_daytimes#_i)#DAYTIME_HOUR_INT) - dayTime + 24) % 24;//See 'Example 4' of https://community.bistudio.com/wiki/skipTime
	if (_skipHours == 0) then {_skipHours = 24};

	//Setup daytime change
	private _smoothTransition = NWG_WCONF_COM_Settings get "DAYTIME_SMOOTH_TRANSITION";
	if (_smoothTransition)
		then {[_skipHours,true,true] call BIS_fnc_setDate}
		else {skipTime _skipHours};

	//Hold on a little bit before changing weather
	if (_smoothTransition && canSuspend) then {sleep 3.5};

	//Setup weather change
	private _weathers = NWG_WCONF_COM_Settings get "WEATHERS";
	private _i = _weathers findIf {(_x#WEATHER_STR) isEqualTo _weatherStr};
	if (_i == -1) exitWith {
		(format ["NWG_WCONF_COM_SetWeatherStr: Weather not found: %1",_weatherStr]) call NWG_fnc_logError;
		false
	};
	((_weathers#_i)#WEATHER_SETTINGS) params ["_overcastMinMax","_windMinMax","_rainMinMax","_lightningsMinMax","_fogMinMax","_wavesMinMax"];

	//Setup new weather
	0 setOvercast (_overcastMinMax call NWG_fnc_randomRangeFloat); forceWeatherChange;
	0 setRain (_rainMinMax call NWG_fnc_randomRangeFloat); forceWeatherChange;
	0 setLightnings (_lightningsMinMax call NWG_fnc_randomRangeFloat); forceWeatherChange;

	//Setup new wind
	private _eastW = (_windMinMax call NWG_fnc_randomRangeFloat);
	if (random 1 > 0.5) then {_eastW = -_eastW};
	private _westW = (_windMinMax call NWG_fnc_randomRangeFloat);
	if (random 1 > 0.5) then {_westW = -_westW};
	setWind [_eastW,_westW,true];
	forceWeatherChange;

	//Setup new fog
	private _fog = (_fogMinMax call NWG_fnc_randomRangeFloat);
	if (_fog > 0)
		then {0 setFog [_fog,(_fog / 2),(_fog * 4)]}
		else {0 setFog 0};
	forceWeatherChange;

	//Setup waves
	0 setWaves (_wavesMinMax call NWG_fnc_randomRangeFloat);
	forceWeatherChange;
};
