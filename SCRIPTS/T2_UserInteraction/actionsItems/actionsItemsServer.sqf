//================================================================================================================
//================================================================================================================
//Settings
NWG_AI_SER_Settings = createHashMapFromArray [
	["CAMP_BUILDING_FUNC",{_this call NWG_AI_UC_CampDeploy}],//param: playerObject | returns: bool
	["CAMP_BUILDING_MARKER_BG_TYPE","o_unknown"],//Marker to be placed at player camp as a background (set to false to disable)
    ["CAMP_BUILDING_MARKER_TYPE","loc_Tourism"],//Marker to be placed at player camp
    ["CAMP_BUILDING_MARKER_SIZE",1.1],//Size of the marker
	["CAMP_BUILDING_MARKER_TEXT_TEMPLATE","   %1 : %2"],//Text of the marker

	["",0]
];

//================================================================================================================
//================================================================================================================
//Global fields
// NWG_AI_MissionPos = nil;//Will be set later

//================================================================================================================
//================================================================================================================
//Mission pos
NWG_AI_SER_SetMissionPos = {
	// params ["_pos","_rad"];
	NWG_AI_MissionPos = _this;
	publicVariable "NWG_AI_MissionPos";
};

NWG_AI_SER_DropMissionPos = {
	NWG_AI_MissionPos = false;
	publicVariable "NWG_AI_MissionPos";
};

//================================================================================================================
//================================================================================================================
//Camp deploy
NWG_AI_SER_campCounter = 0;
NWG_AI_SER_OnRequestCamp = {
	private _playerObject = _this;

	//Build camp
	private _deployFunc = NWG_AI_SER_Settings get "CAMP_BUILDING_FUNC";
	private _deployOk = _playerObject call _deployFunc;
	if !(_deployOk) exitWith {
		(format ["NWG_AI_SER_OnRequestCamp: Camp deploy failed for '%1'",(name _playerObject)]) call NWG_fnc_logError;
	};

	//Mark it on the map
	NWG_AI_SER_campCounter = NWG_AI_SER_campCounter + 1;
	private _count = NWG_AI_SER_campCounter;

	//Set background marker
	if ((NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_BG_TYPE") isNotEqualTo false) then {
		private _bgMarkerType = NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_BG_TYPE";
		private _bgMarkerSize = NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_SIZE";
		private _bgMarkerName = format ["CampBg_%1",_count];
		private _bgMarker = createMarkerLocal [_bgMarkerName,_playerObject];
		_bgMarker setMarkerShapeLocal "icon";
		_bgMarker setMarkerTypeLocal _bgMarkerType;
		_bgMarker setMarkerSize [_bgMarkerSize,_bgMarkerSize];
	};

	//Set main marker
	private _markerType = NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_TYPE";
	private _markerSize = NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_SIZE";
	private _markerName = format ["PlayerCamp_%1_%2",(name _playerObject),_count];
	private _markerText = format [(NWG_AI_SER_Settings get "CAMP_BUILDING_MARKER_TEXT_TEMPLATE"),(name _playerObject),_count];
	private _marker = createMarkerLocal [_markerName,_playerObject];
	_marker setMarkerShapeLocal "icon";
	_marker setMarkerTypeLocal _markerType;
	_marker setMarkerSizeLocal [_markerSize,_markerSize];
	_marker setMarkerText _markerText;
};