#include "..\..\globalDefines.h"
/*
	This is a helper addon module for specific NPC dialogue tree.
	It is desigend to be unique for this specific project and is allowed to know about its structure for ease of implementation.
	So we omit all the connectors and safety.
	For example, here we can freely use functions and inner methods from other systems and subsystems directly and without precautions.
	Same goes the other way around - there are no 'functions' with documentation declared, methods of this module are used directly in dialogue tree structure.
	Dialogue tree structure can be found at 'DATASETS/Client/Dialogues/Dialogues.sqf'
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
