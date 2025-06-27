#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Fields
NWG_GN_groupNames = [
    "Falcon",
    "Wolf",
    "Eagle",
    "Raven",
    "Tiger",
    "Cobra",
    "Phoenix",
    "Hawk",
    "Bear",
    "Panther",
    "Viper",
    "Thunder",
    "Steel",
    "Storm",
    "Shadow",
	"Vostok",
    "Voshod",
    "Romashka",
    "Berkut",
    "Orion",
    "Sputnik",
    "Molniya",
    "Buran",
    "Ural",
    "Kosmos",
    "Sokol",
    "Volga",
    "Taiga",
    "Belka"
];
NWG_GN_groupNumber = 11;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	[EVENT_ON_MISSION_HEARTBEAT,{call NWG_GN_AssignGroupNames}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//================================================================================================================
//Group name assignment
NWG_GN_AssignGroupNames = {
	//Get all groups
	private _groups = (call NWG_fnc_getPlayersAll) apply {group _x};
	if ((count _groups) == 0) exitWith {};//No players online

	//Filter
	{if (isNil "_x" || {isNull _x}) then {_groups deleteAt _forEachIndex}} forEachReversed _groups;
	_groups = _groups arrayIntersect _groups;//Remove duplicates
	if ((count _groups) == 0) exitWith {};//No VALID groups found

	//Assign callsigns
	private ["_groupName"];
	{
		_groupName = _x getVariable "NWG_GN_groupName";
		if (isNil "_groupName") then {
			//No name assigned yet
			_groupName = call NWG_GN_GenerateNewName;
			_x setVariable ["NWG_GN_groupName",_groupName];
			_x setGroupIdGlobal [_groupName];
			continue
		};
		if ((groupID _x) isNotEqualTo _groupName) then {
			//Name not changed yet
			_x setGroupIdGlobal [_groupName];
		};
	} forEach _groups;
};

NWG_GN_GenerateNewName = {
	private _name = [NWG_GN_groupNames,"NWG_GN_groupNames"] call NWG_fnc_selectRandomGuaranteed;
	private _number = NWG_GN_groupNumber;
	NWG_GN_groupNumber = NWG_GN_groupNumber + 1;
	if ((NWG_GN_groupNumber % 10) == 0) then {NWG_GN_groupNumber = NWG_GN_groupNumber + 1};
	private _numberStr = _number toFixed 0;
	//return
	format ["%1 %2-%3",_name,(_numberStr select [0,1]),(_numberStr select [1,1])]
};

//================================================================================================================
//================================================================================================================
call _Init;