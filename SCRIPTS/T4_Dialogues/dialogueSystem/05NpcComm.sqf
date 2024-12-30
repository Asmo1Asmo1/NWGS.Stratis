#include "..\..\globalDefines.h"
/*
	This is a helper addon module for specific NPC dialogue tree used in dialogue tree structure.
	It contains logic unique to this NPC and is not mandatory for dialogue system to work.
	So we can safely omit all the connectors and safety logic. For example, here we can freely use functions and inner methods from other systems and subsystems directly without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Reminder: Each answer is array of [%ANSWER_STR%,%NEXT_NODE%,(optional:%CODE%)]
*/

//================================================================================================================
//================================================================================================================
//Mission state
NWG_DLG_COMM_IsMissionStarted = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState > MSTATE_READY
};
NWG_DLG_COMM_IsMissionReady = {
	if (isNil "NWG_MIS_CurrentState") exitWith {false};
	NWG_MIS_CurrentState == MSTATE_READY
};

//================================================================================================================
//================================================================================================================
//Start mission
NWG_DLG_COMM_StartMission = {
	call NWG_fnc_mmOpenSelectionUI;
};
