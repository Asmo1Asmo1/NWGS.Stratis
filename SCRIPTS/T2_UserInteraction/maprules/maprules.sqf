if (!hasInterface) exitWith {};
[] spawn {
    waitUntil {sleep 0.1; !(isNull (findDisplay 46))};
    waitUntil {sleep 0.1; !(isNull player) && {alive player && {local player}}};

    private _title = "#RULES_TITLE1#" call NWG_fnc_Localize;
    private _description = "#RULES_DESCRIPTION1#" call NWG_fnc_Localize;
	player createDiaryRecord ["Diary", [_title,_description]];

	_title = "#RULES_TITLE2#" call NWG_fnc_Localize;
	_description = "#RULES_DESCRIPTION2#" call NWG_fnc_Localize;
	player createDiaryRecord ["Diary", [_title,_description]];
};