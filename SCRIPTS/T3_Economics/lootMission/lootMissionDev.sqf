#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Items gathering
#define KEY_GATHER 45
#define KEY_CLEAR 44

#define DEFAULT_TAGS ["ANYFAC","ANYVEH","ANYBOX"]

NWG_LM_GATHER_gatheringStarted = false;
NWG_LM_GATHER_ignoreItems = ["B_Bergen_hex_F"];
NWG_LM_GATHER_gatheredItems = [];
NWG_LM_GATHER_tagsToUse = [];

// [] call NWG_LM_GATHER_StartGathering
NWG_LM_GATHER_StartGathering = {
	private _tags = _this;
	if (_tags isEqualTo []) then {_tags = DEFAULT_TAGS};

	private _gatheringActive = NWG_LM_GATHER_gatheringStarted;

	if !(_gatheringActive) then {
		[missionNamespace, "arsenalOpened", {
			// params ["_display","_toggleSpace"];
			params ["_display"];
			_display displayAddEventHandler ["KeyDown",{
				// params ["_eventName","_keyCode","_shift","_ctrl","_alt"];
				params ["","_keyCode"];
				switch (_keyCode) do {
					case KEY_GATHER: {call NWG_LM_GATHER_GatherLoadout; true};
					case KEY_CLEAR: {call NWG_LM_GATHER_ClearGatheredItems; true};
					default {false};/*Do not intercept*/
				}
			}];
		}] call BIS_fnc_addScriptedEventHandler;
	};

	NWG_LM_GATHER_gatheringStarted = true;
	NWG_LM_GATHER_tagsToUse = _tags;

	//return to console
	if !(_gatheringActive) then {
		format ["%1: Gathering started",time]
	} else {
		format ["%1: Gathering updated",time]
	}
};

NWG_LM_GATHER_GatherLoadout = {
	if (NWG_LM_GATHER_gatheredItems isEqualTo []) then {
		NWG_LM_GATHER_gatheredItems = LOOT_ITEM_DEFAULT_CHART;
	};

	private _loadout = flatten (getUnitLoadout player);
	_loadout = _loadout select {_x isEqualType "" && {_x isNotEqualTo "" && {!(_x in NWG_LM_GATHER_ignoreItems)}}};

	private _cur = "";
	private _cat = -1;
	{
		_cur = _x;
		_cat = switch ((_cur) call NWG_fnc_icatGetItemType) do {
			case LOOT_ITEM_TYPE_CLTH: {LOOT_ITEM_CAT_CLTH};
			case LOOT_ITEM_TYPE_WEAP: {LOOT_ITEM_CAT_WEAP};
			case LOOT_ITEM_TYPE_ITEM: {LOOT_ITEM_CAT_ITEM};
			case LOOT_ITEM_TYPE_AMMO: {LOOT_ITEM_CAT_AMMO};
			default {throw (format ["NWG_LM_GATHER_GatherLoadout: Invalid item type: %1",_cur])};
		};
		_cur = switch (_cat) do {
			case LOOT_ITEM_CAT_CLTH: {_cur call NWG_fnc_icatGetBaseBackpack};
			case LOOT_ITEM_CAT_WEAP: {_cur call NWG_fnc_icatGetBaseWeapon};
			default {_cur};
		};

		(NWG_LM_GATHER_gatheredItems#_cat) pushBackUnique _cur;
	} forEach _loadout;

	//Sort items alphabetically
	{_x sort true} forEach NWG_LM_GATHER_gatheredItems;

	//Format lines
	private _lines = [];
	_lines pushBack "	[";
	_lines pushBack (format ["		%1,TIER_1,[",text (str NWG_LM_GATHER_tagsToUse)]);
	_lines pushBack (format ["			%1,",text (str (NWG_LM_GATHER_gatheredItems#LOOT_ITEM_CAT_CLTH))]);
	_lines pushBack (format ["			%1,",text (str (NWG_LM_GATHER_gatheredItems#LOOT_ITEM_CAT_WEAP))]);
	_lines pushBack (format ["			%1,",text (str (NWG_LM_GATHER_gatheredItems#LOOT_ITEM_CAT_ITEM))]);
	_lines pushBack (format ["			%1", text (str (NWG_LM_GATHER_gatheredItems#LOOT_ITEM_CAT_AMMO))]);
	_lines pushBack "		]";
	_lines pushBack "	],";

	//Copy to clipboard
	copyToClipboard (_lines joinString (toString [13,10]));//Copy with 'new line' separator

	systemChat format ["%1: Gathered",time];
};

NWG_LM_GATHER_ClearGatheredItems = {
	NWG_LM_GATHER_gatheredItems resize 0;
	systemChat format ["%1: Gathering cleared",time];
};

//================================================================================================================
//================================================================================================================
//Check loot catalogue (using logic from items shop)
#define SET_TAGS 0
#define SET_ITEMS 1

// call NWG_LM_TEST_CheckLootCatalogue
NWG_LM_TEST_CheckLootCatalogue = {
	if (isNil "NWG_ISHOP_SER_ValidateItemsChart") exitWith {
		"NWG_LM_TEST_CheckLootCatalogue: Shop items validation function is not available"
	};

	private _catalogue = call NWG_LM_SER_GetFullCatalogue;
	if (_catalogue isEqualTo false) exitWith {
		"NWG_LM_TEST_CheckLootCatalogue: Failed to get full catalogue"
	};

	private _errors = [];
	{
		((_x#SET_ITEMS) call NWG_ISHOP_SER_ValidateItemsChart) params ["","_valid"];
		if !(_valid) then {
			_errors pushBack (format ["Set failed validation, tags: '%1'",(_x#SET_TAGS)]);
		};
	} forEach _catalogue;

	if (_errors isEqualTo []) then {
		"All sets passed validation successfully"
	} else {
		_errors call NWG_fnc_testDumpToRptAndClipboard;
		"Some sets failed validation, see RPT for details"
	}
};
