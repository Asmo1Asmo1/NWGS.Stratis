//Mission stages
/* initialization */
#define MSTATE_SCRIPTS_COMPILATION -3
#define MSTATE_DISABLED -2
#define MSTATE_MACHINE_STARTUP -1
/* world build */
#define MSTATE_WORLD_BUILD 0
/* base build */
#define MSTATE_BASE_UKREP 1
#define MSTATE_BASE_ECONOMY 2
#define MSTATE_BASE_QUESTS 3
/* missions list */
#define MSTATE_LIST_INIT 4
#define MSTATE_LIST_UPDATE 5
/* player input expect */
#define MSTATE_READY 6
/* mission build */
#define MSTATE_BUILD_UKREP 7
#define MSTATE_BUILD_ECONOMY 8
#define MSTATE_BUILD_DSPAWN 9
#define MSTATE_BUILD_QUESTS 10
/* mission playflow */
#define MSTATE_FIGHT_SETUP 11
#define MSTATE_FIGHT_READY 12
#define MSTATE_FIGHT_INFILTRATION 13
#define MSTATE_FIGHT_ACTIVE 14
#define MSTATE_FIGHT_EXHAUSTED 15
/* mission end */
#define MSTATE_COMPLETED 16
#define MSTATE_CLEANUP 17
#define MSTATE_RESET 18
#define MSTATE_SERVER_RESTART 19

// Exempt defines from ukrepDefines.h
//It is not a good practice, but they are not that widespread to move them to globalDefines.h
//Here we rely on the fact that we'll see those in Search'n'Replace if ever need to make changes (hopefully not)
// UkrepType	UkrepName	ABSPos	[0,0,0]	Radius	0	Payload	Blueprint
#define BPCONTAINER_TYPE 0
#define BPCONTAINER_NAME 1
#define BPCONTAINER_POS 2
#define BPCONTAINER_UNUSED1 3
#define BPCONTAINER_RADIUS 4
#define BPCONTAINER_UNUSED2 5
#define BPCONTAINER_PAYLOAD 6
#define BPCONTAINER_BLUEPRINT 7

//Selection element structure
#define SELECTION_NAME 0
#define SELECTION_POS 1
#define SELECTION_RAD 2
/*Server side*/
#define SELECTION_BLUEPRINT 3
#define SELECTION_SETTINGS 4
/*Client side*/
#define SELECTION_DIFFICULTY 3
#define SELECTION_MARKER 4
#define SELECTION_MARKER_COLOR 5