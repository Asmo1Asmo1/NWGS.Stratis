// Exempt defines from ukrepDefines.h
//It is not a good practice, but they are not that widespread to move them to globalDefines.h
//Here we rely on the fact that we'll see those in Search'n'Replace if ever need to make changes (hopefully not)
// UkrepType	UkrepName	ABSPos	[0,0,0]	Radius	0	Payload	Blueprint
#define BPCONTAINER_TYPE 0
#define BPCONTAINER_NAME 1
#define BPCONTAINER_POS 2
// #define BPCONTAINER_UNUSED1 3
#define BPCONTAINER_RADIUS 4
// #define BPCONTAINER_UNUSED2 5
#define BPCONTAINER_PAYLOAD 6
#define BPCONTAINER_BLUEPRINT 7

#define FRACTAL_STEP_ROOT 0
#define FRACTAL_STEP_BLDG 1
#define FRACTAL_STEP_FURN 2

#define FRACTAL_CHANCES 1

//Mission blueprint container name parts
#define BPCNAME_NAME 0
// #define BPNAME_VARIANT 1 //unused
#define BPCNAME_TIER 2

//Mission list structure
#define MLIST_NAME 0
#define MLIST_TIER 1
#define MLIST_POS 2
#define MLIST_BLUEPRINT 3

//Selection structure
#define SELECTION_NAME 0
#define SELECTION_LEVEL 1
#define SELECTION_INDEX 2
#define SELECTION_POS 3
#define SELECTION_RAD 4
#define SELECTION_FACTION 5
#define SELECTION_COLOR 6
#define SELECTION_TIME 7
#define SELECTION_TIME_STR 8
#define SELECTION_WEATHER 9
#define SELECTION_WEATHER_STR 10

//Mission info
#define MINFO_NAME "Name"
#define MINFO_LEVEL "Level"
#define MINFO_TIERS "Tiers"
#define MINFO_POSITION "Position"
#define MINFO_RADIUS "Radius"
#define MINFO_ENEMY_SIDE "EnemySide"
#define MINFO_ENEMY_FACTION "EnemyFaction"
#define MINFO_ENEMY_COLOR "EnemyColor"
#define MINFO_BLUEPRINT "Blueprint"
#define MINFO_EXHAUST_AFTER "ExhaustAfter"
#define MINFO_IS_ESCAPE "IsEscape"
#define MINFO_ESCAPE_VEHICLE "EscapeVehicle"
//Mission info 'fight'
#define MINFO_LAST_ONLINE_AT "LastOnlineAt"
#define MINFO_IS_RESTART_CONDITION "IsRestartCondition"
#define MINFO_IS_ALL_PLAYERS_ON_BASE "IsAllPlayersOnBase"
#define MINFO_IS_INFILTRATED "IsInfiltrated"
#define MINFO_IS_ENGAGED "IsEngaged"
#define MINFO_IS_EXHAUSTED "IsExhausted"
#define MINFO_WILL_EXHAUST_AT "WillExhaustAt"
#define MINFO_IS_ALL_PLAYERS_IN_ESCAPE_VEHICLE "IsAllPlayersInEscapeVehicle"
