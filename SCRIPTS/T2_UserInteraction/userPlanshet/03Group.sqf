#include "ui_toolkit.h"
#include "..\..\secrets.h"

//================================================================================================================
//================================================================================================================
//Defines
//--- userPlanshetUIBase
// #define IDC_TEXT_LEFT 1000
// #define IDC_TEXT_RIGHT 1001
#define IDC_LISTBOX	1501
// #define IDC_DROPDOWN 2101

/*enum*/
#define GROUP_MENU "GROUP_MENU"
#define GROUP_VOTE_BAN "GROUP_VOTE_BAN"
#define GROUP_VOTE_KICK "GROUP_VOTE_KICK"
#define GROUP_DISCORD "DISCORD"

//--- scale helpers
#define DISCORD_BUTTON_W (0.5 * X_SCALE)
#define DISCORD_BUTTON_H (0.1 * Y_SCALE)

//--- position helpers
#define DISCORD_BUTTON_X (FROM_CENTER(DISCORD_BUTTON_W))
#define DISCORD_BUTTON_Y (FROM_CENTER((DISCORD_BUTTON_H * 0.5)))

//================================================================================================================
//================================================================================================================
//Settings
NWG_UP_03Group_Settings = createHashMapFromArray [
	["WINDOW_NAME","#UP_GROUP_TITLE#"],
	["PLANSHET_ROWS",[
		["#UP_GROUP_MENU#",GROUP_MENU],
		["#UP_GROUP_VOTE_BAN#",GROUP_VOTE_BAN],
		["#UP_GROUP_VOTE_KICK#",GROUP_VOTE_KICK],
		["#UP_GROUP_DISCORD#",GROUP_DISCORD]
	]],

	/*Localization*/
	["LOC_VOTE_BAN_FAILED","#UP_GROUP_VOTE_BAN_FAILED#"],
	["LOC_DISCORD_BUTTON","#UP_GROUP_DISCORD_BUTTON#"],

	["",0]
];

//================================================================================================================
//================================================================================================================
//Category
NWG_UP_03Group_Open = {
	disableSerialization;

	//Prepare items, data and callback
	private _windowName = NWG_UP_03Group_Settings get "WINDOW_NAME";
	private _planshetRows = NWG_UP_03Group_Settings get "PLANSHET_ROWS";
	private _items = _planshetRows apply {(_x select 0) call NWG_fnc_localize};
	private _data =  _planshetRows apply {_x select 1};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _settingName = _listBox lbData _selectedIndex;
		switch (_settingName) do {
			case GROUP_MENU: {call NWG_UP_03Group_Menu_Open};
			case GROUP_VOTE_BAN: {call NWG_UP_03Group_VoteBan_Open};
			case GROUP_VOTE_KICK: {call NWG_UP_03Group_VoteKick_Open};
			case GROUP_DISCORD: {call NWG_UP_03Group_Discord_Open};
			default {(format ["NWG_UP_03Group_OnRowSelected: Unknown setting: '%1'",_settingName]) call NWG_fnc_logError};
		};
	};

	//Open interface
	private _interface = [_windowName,_items,_data,_callback] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_03Group_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	true
};

//================================================================================================================
//================================================================================================================
//Group menu
NWG_UP_03Group_Menu_Open = {
	disableSerialization;
	call NWG_fnc_upCloseAllMenus;
	(findDisplay 46) createDisplay "RscDisplayDynamicGroups";
};

//================================================================================================================
//================================================================================================================
//Vote ban
NWG_UP_03Group_VoteBan_Open = {
	disableSerialization;

	//Prepare interface open
	private _planshetRows = NWG_UP_03Group_Settings get "PLANSHET_ROWS";
	private _windowName = (_planshetRows param [(_planshetRows findIf {(_x#1) isEqualTo GROUP_VOTE_BAN}),[]]) param [0,""];
	private _playerNames = call {
		private _players = call NWG_fnc_getPlayersAll;
		private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
		if (!_isDevBuild) then {_players = _players - [player]};
		_players apply {name _x}
	};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _name = _listBox lbData _selectedIndex;
		call NWG_fnc_upCloseAllMenus;
		_name call NWG_fnc_voteBan;
	};

	//Open interface
	private _interface = [_windowName,_playerNames,_playerNames,_callback] call NWG_fnc_upOpenSecondaryMenuPrefilled;
};

//================================================================================================================
//================================================================================================================
//Vote kick
NWG_UP_03Group_VoteKick_Open = {
	disableSerialization;

	//Prepare interface open
	private _planshetRows = NWG_UP_03Group_Settings get "PLANSHET_ROWS";
	private _windowName = (_planshetRows param [(_planshetRows findIf {(_x#1) isEqualTo GROUP_VOTE_KICK}),[]]) param [0,""];
	private _playerNames = call {
		private _players = call NWG_fnc_getPlayersAll;
		private _isDevBuild = (is3DENPreview || {is3DENMultiplayer});
		if (!_isDevBuild) then {_players = _players - [player]};
		_players apply {name _x}
	};
	private _callback = {
		// params ["_listBox","_selectedIndex","_withTitleRow"];
		params ["_listBox","_selectedIndex"];
		private _name = _listBox lbData _selectedIndex;
		call NWG_fnc_upCloseAllMenus;
		_name call NWG_fnc_voteKick;
	};

	//Open interface
	private _interface = [_windowName,_playerNames,_playerNames,_callback] call NWG_fnc_upOpenSecondaryMenuPrefilled;
};

//================================================================================================================
//================================================================================================================
//Discord
NWG_UP_03Group_Discord_Open = {
	disableSerialization;

	//Prepare interface open
	private _planshetRows = NWG_UP_03Group_Settings get "PLANSHET_ROWS";
	private _windowName = (_planshetRows param [(_planshetRows findIf {(_x#1) isEqualTo GROUP_DISCORD}),[]]) param [0,""];

	//Open interface
	private _interface = [_windowName,nil,nil,{}] call NWG_fnc_upOpenSecondaryMenuPrefilled;
	if (isNil "_interface" || {_interface isEqualTo false || {isNull _interface}}) exitWith {
		"NWG_UP_06Settings_Open: Failed to open interface" call NWG_fnc_logError;
		false
	};

	//Add discord button
	private _ctrlButton = _interface ctrlCreate ["RscButton",-1];
	_ctrlButton ctrlSetText ((NWG_UP_03Group_Settings get "LOC_DISCORD_BUTTON") call NWG_fnc_localize);
	_ctrlButton ctrlSetPosition [
		DISCORD_BUTTON_X,
		DISCORD_BUTTON_Y,
		DISCORD_BUTTON_W,
		DISCORD_BUTTON_H
	];
	_ctrlButton ctrlSetBackgroundColor [0,0,0,0.15];
	_ctrlButton ctrlSetURL ("https://discord.gg/" + DISCORD_INVITE);
	_ctrlButton ctrlCommit 0;

	true
};
