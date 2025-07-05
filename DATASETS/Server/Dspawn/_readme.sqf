/*
    Annotation:
    Catalogue page structure follows the format
    [
        [PASSENGERS],
        [PARADROP_VEHICLES],
        [GROUP_DESCRIPTIONS]
    ]

    Group description follows the format:
    [
        ["TAGS"], TIER,
        ["VEH_CLASSNAME",[APPEARANCE](optional),[PYLONS](optional)], //or 'false' if no vehicle
        ["UNIT_CLASSNAMES"],
        {ADDITIONAL_CODE}(optional)
    ]

    Note: Every number value in appearance means 0-1 probability, you can set it to 0.5 to get 50/50 chance for each item
    Note: UNIT_CLASSNAMES uses a shortened format, example: [2,"aaa","bbb",3,"ccc"] that will be uncompacted into ["aaa","aaa","bbb","ccc","ccc","ccc"]
    Note: ADDITIONAL_CODE will recieve 'params ["_group","_vehicle","_units"]'
*/

//Gather the description of player group OR the first group of west side if there is no player
call NWG_DSPAWN_Dev_EasyGather

//Gather the description of provided group (e.g.: ((groups west)#0) call NWG_DSPAWN_Dev_Gather)
_group call NWG_DSPAWN_Dev_Gather

//Gather UAVs
(group cursorObject) call NWG_DSPAWN_Dev_Gather