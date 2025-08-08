#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Settings
NWG_CKF_Settings = createHashMapFromArray [
	["FINE_INITIAL",1000],//Initial fine amount
	["FINE_INCREMENT",100],//Fine increment for each kill

	/*Localization*/
	["LOC_MESSAGE_TEMPLATE","#CKF_NOTIFY_TEMPLATE#"],

    ["",0]
];

//================================================================================================================
//================================================================================================================
//Fields
NWG_CKF_CurrentFine = 0;

//================================================================================================================
//================================================================================================================
//Init
private _Init = {
	call NWG_CKF_Reset;
	[EVENT_ON_OBJECT_KILLED,{_this call NWG_CKF_OnKill}] call NWG_fnc_subscribeToServerEvent;
};

//================================================================================================================
//================================================================================================================
//Reset method
NWG_CKF_Reset = {
	NWG_CKF_CurrentFine = NWG_CKF_Settings get "FINE_INITIAL";
};

//================================================================================================================
//================================================================================================================
//On kill handler
NWG_CKF_OnKill = {
	params ["_obj","_objType","_actualKiller","_isPlayerKiller"];

	//Simple checks
	if !(_isPlayerKiller) exitWith {};
	if (_objType isNotEqualTo OBJ_TYPE_UNIT) exitWith {};
	if (isNull _actualKiller || {!alive _actualKiller || {!isPlayer _actualKiller}}) exitWith {};
	if (isNull _obj) exitWith {};
	if !(_obj isKindOf "Man") exitWith {};
	if (_obj isKindOf "Animal") exitWith {};//Should not happen, but just in case

	//Check killed unit side
	private _side = if (isNull (group _obj))
		then {side _obj}/*Agents don't have groups and may only be checked using their own side*/
		else {side (group _obj)};/*Actual units should be checked using their group in case they are unconcious (will always return CIV for unconscious units)*/
	if (_side isNotEqualTo civilian) exitWith {};

	//Prepare variables
	private _group = group _actualKiller;
	private _fine = NWG_CKF_CurrentFine;
	NWG_CKF_CurrentFine = _fine + (NWG_CKF_Settings get "FINE_INCREMENT");

	//Send message to entire group
	[
		(NWG_CKF_Settings get "LOC_MESSAGE_TEMPLATE"),
		(name _actualKiller),
		(_fine call NWG_fnc_wltFormatMoney)
	] remoteExec ["NWG_fnc_sideChatMe",_group];

	//Subtract money from each group member
	private _data = (units _group) apply {[_x,-_fine]};
	[_data,"NWG_CKF_OnKill",/*cancelOnError*/false] call NWG_fnc_wltDistributeMoneys;
};

//================================================================================================================
//================================================================================================================
call _Init;