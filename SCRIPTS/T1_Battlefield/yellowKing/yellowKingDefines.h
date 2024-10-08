//Status
#define STATUS_DISABLED "DISABLED"
#define STATUS_READY "READY_AND_WAITING"
#define STATUS_PREPARING "PREPARING_RESPONSE"
#define STATUS_ACTING "RESPONDING"

//Target structure
#define TARGET_OBJECT 0
#define TARGET_TYPE 1
#define TARGET_POSITION 2
#define TARGET_BUILDING 3

//Target types (ensure consistency with SCRIPTS\T1_Battlefield\advancedCombat\advancedCombatDefines.h)
#define TARGET_TYPE_INF "INF"
#define TARGET_TYPE_VEH "VEH"
#define TARGET_TYPE_ARM "ARM"
#define TARGET_TYPE_AIR "AIR"
#define TARGET_TYPE_BOAT "BOAT"


//Hunter structure
#define HUNTER_GROUP 0
#define HUNTER_POSITION 1
#define HUNTER_ALIVE_COUNT 2
#define HUNTER_PARENT_SYSTEM 3
#define HUNTER_TAGS 4
#define HUNTER_SPECIAL 5

//Parent system types
#define PARENT_SYSTEM_DSPAWN "dspawn"
#define PARENT_SYSTEM_UKREP "ukrep"

//Specials
#define SPECIAL_NONE ""
#define SPECIAL_AIRSTRIKE "AIRSTRIKE"
#define SPECIAL_ARTA "ARTA"
#define SPECIAL_MORTAR "MORTAR"
#define SPECIAL_VEHDEMOLITION "VEHDEMOLITION"
#define SPECIAL_INFSTORM "INFSTORM"
#define SPECIAL_VEHREPAIR "VEHREPAIR"

//Specials structure
#define SPEC_TYPE 0
#define SPEC_INDEX 1
#define SPEC_TARGET 2
#define SPEC_ARG 3

//Dice
#define DICE_IGNORE "IGNORE"
#define DICE_MOVE "MOVE"
#define DICE_REINF "REINF"
#define DICE_SPEC "SPEC"

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
#define STAT_SPEC_MORTAR "MortarCount"
#define STAT_SPEC_VEHDEMOLITION "VehDemolitionCount"
#define STAT_SPEC_INFSTORM "InfStormCount"
#define STAT_SPEC_VEHREPAIR "VehRepairCount"