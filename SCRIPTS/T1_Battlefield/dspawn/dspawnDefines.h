/*
    Annotation:
    Group structure follows the format:
    [
        ["TAGS"], TIER,
        ["VEH_CLASSNAME",[APPEARANCE],[PYLONS]],
        ["UNIT_CLASSNAMES"],
        {ADDITIONAL_CODE}
    ]

    Note: Every group gets Weapon tag 'REG' as there is no means to define it automatically, edit it manually if needed
    Note: Every number value in appearance means 0-1 probability, you can set it to 0.5 to get 50/50 chance for each item
    Note: UNIT_CLASSNAMES is a shortened format, example: ["class1",2,"class2"] that will be uncomacted into ["class1","class2","class2"] by dspawn logic
    Note: ADDITIONAL_CODE will recieve 'params ["_group","_vehicle","_units"]'
*/

//Group description structure
#define DESCR_TAGS 0
#define DESCR_TIER 1
#define DESCR_VEHICLE 2
#define DESCR_UNITS 3
#define DESCR_ADDITIONAL_CODE 4

//Catalogue page structure
#define PASSENGERS_CONTAINER 0
#define PARADROP_CONTAINER 1
#define GROUPS_CONTAINER 2