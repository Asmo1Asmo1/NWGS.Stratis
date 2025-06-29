//================================================================================================================
//================================================================================================================
//Players

//Find player by name
//note: caches last found player as 'NWG_ADM_Lastfound'
// params
// 	name - player name
// returns either
// 	[player name, player group, steam ID] - array of three elements
// 	or
// 	"Player not found" - string
// 	"Multiple players found" - string
NWG_fnc_admFindByName = {
	_this call NWG_ADM_FindByName
};

//Return last found player
//returns
// 	[player name, player group, steam ID] - array of three elements
// 	or
// 	["NaN",grpNull,"NaN"] - array of three elements
NWG_fnc_admGetLastFound = {
	NWG_ADM_Lastfound
};

//Kick last found player
NWG_fnc_admKickLastFound = {
	call NWG_ADM_KickLastFound
};

//Ban last found player
NWG_fnc_admBanLastFound = {
	call NWG_ADM_BanLastFound
};

//Rename group of last found player
//params: - name - string - new name of the group
NWG_fnc_admRenameGroup = {
	// private _newName = _this;
	_this call NWG_ADM_RenameGroupOfLastFound
};

//================================================================================================================
//================================================================================================================
//Enemies

//Get enemy group by name
//params: - name - string - name of the group
//returns: group object or "No group found"|"Multiple groups found" string
NWG_fnc_admGetEnemyGroup = {
	_this call NWG_ADM_GetEnemyGroup
};

//================================================================================================================
//================================================================================================================
//Database

//Force save everything into DB
//returns: array of reports
NWG_fnc_admForceSaveToDB = {
	call NWG_ADM_ForceSaveToDB
};