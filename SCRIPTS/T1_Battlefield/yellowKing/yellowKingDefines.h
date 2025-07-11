//Target structure
#define TARGET_TYPE 0
#define TARGET_OBJECT 1
#define TARGET_POSITION 2

//Target types
#define TARGET_TYPE_BLDG "BLDG"
#define TARGET_TYPE_INF "INF"
#define TARGET_TYPE_VEH "VEH"
#define TARGET_TYPE_ARM "ARM"
#define TARGET_TYPE_AIR_GND "AIRG"
#define TARGET_TYPE_AIR_FLY "AIRF"
#define TARGET_TYPE_BOAT "BOAT"

//Hunters parents
#define PARENT_DSPAWN "dspawn"
#define PARENT_UKREP "ukrep"

//Hunter structure
#define HUNTER_TYPE 0
#define HUNTER_SPECIAL 1
#define HUNTER_GROUP 2
#define HUNTER_POSITION 3

//Hunter types
#define HUNTER_TYPE_INF_AA "INF_AA"
#define HUNTER_TYPE_INF_AT "INF_AT"
#define HUNTER_TYPE_INF_AAAT "INF_AAAT"
#define HUNTER_TYPE_INF_AP "INF_AP"
#define HUNTER_TYPE_VEH_AA "VEH_AA"
#define HUNTER_TYPE_VEH_AT "VEH_AT"
#define HUNTER_TYPE_VEH_AAAT "VEH_AAAT"
#define HUNTER_TYPE_VEH_AP "VEH_AP"
#define HUNTER_TYPE_AIR_AA "AIR_AA"
#define HUNTER_TYPE_AIR_AT "AIR_AT"
#define HUNTER_TYPE_AIR_AAAT "AIR_AAAT"
#define HUNTER_TYPE_AIR_AP "AIR_AP"
#define HUNTER_TYPE_BOAT "BOAT"
#define HUNTER_TYPE_UKREP "UKREP"
#define HUNTER_TYPE_UNDEF "UNDEF"

//Active specials
#define SPECIAL_NONE ""
#define SPECIAL_AIRSTRIKE "AIRSTRIKE"
#define SPECIAL_ARTA "ARTA"
#define SPECIAL_VEHDEM "VEHDEM"
#define SPECIAL_INFSTORM "INFSTORM"
//Passive specials
#define SPECIAL_VEHREPAIR "VEHREPAIR"
#define SPECIAL_LONEMERGE "LONEMERGE"

//Dice structure
#define DICE_TYPE 0
#define DICE_HUNTER_INDEX 1
#define DICE_ADD_ARG 2

//Dice types (in addition to specials)
#define DICE_IGNORE "IGNORE"
#define DICE_MOVE "MOVE"
#define DICE_REINF "REINF"

//Statistics
#define STAT_ENABLED_AT "EnabledAt"
#define STAT_DISABLED_AT "DisabledAt"
#define STAT_TIME_WORKING "TimeWorking"
#define STAT_GROUPS_ON_ENABLE "GroupsOnEnable"
#define STAT_UNITS_ON_ENABLE "UnitsOnEnable"
#define STAT_GROUPS_ON_DISABLE "GroupsOnDisable"
#define STAT_UNITS_ON_DISABLE "UnitsOnDisable"
#define STAT_KILL_COUNT "KillCount"
#define STAT_REACTION_COUNT "ReactionCount"
#define STAT_TARGETS_ACQUIRED "TargetsAcquired"
#define STAT_TARGETS_IGNORED "TargetsIgnored"
#define STAT_GROUPS_MOVED "GroupsMoved"
#define STAT_REINFS_SENT "ReinfsSent"
#define STAT_SPECIALS_USED "SpecialsUsed"
#define STAT_SPEC_AIRSTRIKE "AirstrikeCount"
#define STAT_SPEC_ARTA "ArtaCount"
#define STAT_SPEC_VEHDEM "VehDemolitionCount"
#define STAT_SPEC_INFSTORM "InfStormCount"
#define STAT_SPEC_VEHREPAIR "VehRepairCount"
#define STAT_SPEC_LONEMERGE "LoneMergeCount"