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

//===============================================
// ShopMobile faction (the support player can order)
[
    //===========================================
    //Passenger container (used to fill 'RANDOM' slots - usually passenger seats in vehicles)
    [
        /*Common units (60% chance)*/
        ["I_G_Soldier_A_F",
		"I_G_medic_F",
		"I_G_engineer_F",
		"I_G_Soldier_exp_F",
		"I_G_Soldier_F",
		"I_G_Soldier_lite_F",
		"I_G_Soldier_SL_F",
		"I_G_Soldier_M_F",
		"I_G_officer_F",
		"I_G_Soldier_LAT_F",
		"I_G_Soldier_AR_F",
		"I_G_Soldier_GL_F",
		"I_G_Sharpshooter_F",
		"I_G_Survivor_F",
		"I_G_Soldier_LAT2_F"],

        /*Uncommon units (30% chance) (AT soldiers or heavy machinegunners for example)*/
        ["I_G_Soldier_M_F",
		"I_G_officer_F",
		"I_G_Soldier_LAT_F",
		"I_G_Soldier_AR_F",
		"I_G_Soldier_GL_F"],

        /*Rare units (10% chance) (AA soldiers or marksmans for example)*/
        ["I_G_Sharpshooter_F",
		"I_G_Survivor_F",
		"I_G_Soldier_LAT2_F"]
    ],
    //===========================================
    //Paradrop vehicle(s) (used to imitate vehicles drop from the sky) (leave empty to disable for this faction)
    [
        ""
    ],
    //===========================================
    //Groups descriptions (blueprints)
    [
        //=======================================
        /*INF - Infantry*/
        //Team (2)
        [["INF","REG","C2I0"],2,false,[2,"RANDOM"]],
        //Squad (3)
        [["INF","REG","C2I1"],2,false,[3,"RANDOM"]],
        //Company (5)
        [["INF","REG","C2I2"],2,false,[5,"RANDOM"]],
        //Fire team (8)
        [["INF","REG","C2I3"],2,false,[8,"RANDOM"]],

        //=======================================
        /*AIR - Air vehicles*/
        //Scout drone
        [
            ["AIR","MEC","HELI","UAV","REG","C0I0"],2,
            ["I_UAV_01_F"],
            [2,"O_UAV_AI"]
        ],
		//Suicide and EMI drones
		[
			["AIR","MEC","HELI","UAV","REG","C0I1","C0I2","C0I3","C0I5"],2,
			["I_UAV_01_F"],
			["O_UAV_AI"]
		],
        //Mine deployment drone
        [
			["AIR","MEC","HELI","UAV","REG","C0I4"],2,
			["C_UAV_06_F"],
			["O_UAV_AI"]
		],
		//Bomber drone
		[
			["AIR","MEC","HELI","UAV","REG","C0I6"],2,
			["C_IDAP_UAV_06_antimine_F"],
			["O_UAV_AI"]
		],
		//Ababil
		[
			["AIR","MEC","PLANE","UAV","REG","C0I7"],2,
			["I_UAV_02_dynamicLoadout_F"],
			[2,"O_UAV_AI"]
		]
    ]
]
