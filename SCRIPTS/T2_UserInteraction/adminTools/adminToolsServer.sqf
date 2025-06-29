#include "..\..\secrets.h"

//================================================================================================================
//================================================================================================================
//Players
#define FOUND_NAME 0
#define FOUND_GROUP 1
#define FOUND_UID 2
NWG_ADM_Lastfound = ["NaN",grpNull,"NaN"];

/*Find player by name*/
NWG_ADM_FindByName = {
	private _name = toLower _this;
	private _match = (call NWG_fnc_getPlayersAll) select {_name in (toLower (name _x))};
	if ((count _match) == 0) exitWith {"Player not found"};
	if ((count _match) > 1) exitWith {"Multiple players found"};

	private _result = [(name (_match#0)),(group (_match#0)),(getPlayerUID (_match#0))];
	NWG_ADM_Lastfound = _result;
	_result
};

/*Kick player*/
NWG_ADM_Kick = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#kick %1",(str _this)]);
};
NWG_ADM_KickLastFound = {
	private _steamId = (NWG_ADM_Lastfound select FOUND_UID);
	_steamId call NWG_ADM_Kick;
};

/*Ban player*/
NWG_ADM_Ban = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#exec ban %1",(str _this)]);
};
NWG_ADM_BanLastFound = {
	private _steamId = (NWG_ADM_Lastfound select FOUND_UID);
	_steamId call NWG_ADM_Ban;
};

/*Unban player*/
NWG_ADM_Unban = {
	// private _steamId = _this;
	SERVER_COMMAND_PASSWORD serverCommand (format ["#exec unban %1",(str _this)]);
};

/*Rename group*/
NWG_ADM_RenameGroupOfLastFound = {
	private _newName = _this;
	private _group = (NWG_ADM_Lastfound select FOUND_GROUP);
	if (isNull _group) exitWith {"No group found"};
	_group setGroupIdGlobal _newName;
	"Renamed"
};

//================================================================================================================
//================================================================================================================
//Enemies
NWG_ADM_GetEnemyGroup = {
	private _grpName = toLower _this;
	private _match = (groups west) select {_grpName in (toLower (groupId _x))};
	if ((count _match) == 0) exitWith {"No group found"};
	if ((count _match) > 1) exitWith {"Multiple groups found"};

	//return
	_match#0
};

//================================================================================================================
//================================================================================================================
//Database

NWG_ADM_ForceSaveToDB = {
	private _report = "";
	private _reports = [];

	//1. Update player records
	_report = call {
		private _ok = call NWG_fnc_pshSyncRequest;
		if (_ok) then {"OK"} else {"ERRORS"};
	};
	_report = format ["PLAYERS : %1",_report];
	_reports pushBack _report;

	//2. Save items prices
	_report = call {
		private _pricesChart = call NWG_fnc_ishopDownloadPrices;
		if (_pricesChart isEqualTo false) exitWith {
			"NWG_ADM_ForceSaveToDB: Failed to get items prices" call NWG_fnc_logError;
			"ERRORS"
		};
		private _ok = _pricesChart call NWG_fnc_dbSaveItemPrices;
		if !(_ok) exitWith {
			"NWG_ADM_ForceSaveToDB: Failed to save items prices" call NWG_fnc_logError;
			"ERRORS"
		};
		"OK"
	};
	_report = format ["ITEMS : %1",_report];
	_reports pushBack _report;

	//3. Save vehicles prices
	_report = call {
		private _pricesChart = call NWG_fnc_vshopDownloadPrices;
		if (_pricesChart isEqualTo false) exitWith {
			"NWG_ADM_ForceSaveToDB: Failed to get vehicles prices" call NWG_fnc_logError;
			"ERRORS"
		};
		private _ok = _pricesChart call NWG_fnc_dbSaveVehiclePrices;
		if !(_ok) exitWith {
			"NWG_ADM_ForceSaveToDB: Failed to save vehicles prices" call NWG_fnc_logError;
			"ERRORS"
		};
		"OK"
	};
	_report = format ["VEHICLES : %1",_report];
	_reports pushBack _report;

	//4. Save unlocked levels
	_report = call {
		private _unlockedLevels = NWG_MIS_UnlockedLevels + [];//Shallow copy
		private _ok = _unlockedLevels call NWG_fnc_dbSaveUnlockedLevels;
		if !(_ok) exitWith {
			"NWG_ADM_ForceSaveToDB: Failed to save unlocked levels" call NWG_fnc_logError;
			"ERRORS"
		};
		"OK"
	};
	_report = format ["LEVELS : %1",_report];
	_reports pushBack _report;

	//6. Save all reports to log
    diag_log text "==========[ FORCE SAVE TO DB ]===========";
    {diag_log (text _x)} forEach _reports;
    diag_log text "==========[       END        ]===========";

	//return
	_reports
};