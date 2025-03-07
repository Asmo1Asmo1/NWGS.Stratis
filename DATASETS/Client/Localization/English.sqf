NWG_LocalizationDictionary = createHashMapFromArray [
    //T1_Battlefield
    //missionMachine
    // ["#MIS_ACTION_TITLE#","Select mission"],//not used anymore
    ["#MIS_CLI_BRIEFING_1#","new destination..."],
    ["#MIS_CLI_BRIEFING_2#","Enemy: %1"],
    ["#MIS_COMPLETED_MESSAGE#","RAID COMPLETED"],
    ["#MIS_NOT_ALL_PLAYERS_ON_BASE#","Some players are not on the base. Can not start the mission."],
    ["#MIS_VOTE_TITLE#","Vote to confirm\nRaid: %1\nLevel: %2\nEnemy: %3\nTime: %4\nWeather: %5"],
    ["#MIS_VOTE_WAITING#","Waiting for another vote to finish..."],
    ["#MIS_VOTE_CANNOT_START#","Failed to start vote"],
    ["#MIS_VOTE_ERROR#","Failed to get vote result"],
    ["#MIS_VOTE_AGAINST#","Players voted against the mission"],
    ["#MIS_RESTART_MESSAGE#","Server restart in progress..."],
    //worldConfig
    ["#WORLD_NAME_STRATIS#","Stratis"],
    ["#WORLD_NAME_ALTIS#","Altis"],
    ["#WORLD_NAME_TANOA#","Tanoa"],
    ["#WORLD_NAME_MALDEN#","Malden"],
    ["#WORLD_NAME_BOOTCAMP#","Bootcamp"],
    ["#WORLD_NAME_VR#","VR"],
    ["#WORLD_NAME_UNKNOWN#","Unknown"],
    ["#WEATHER_CLEAR#","Clear"],
    ["#WEATHER_CLOUD#","Clouds"],
    ["#WEATHER_RAIN#","Rain"],
    ["#WEATHER_STORM#","Storm"],
    ["#WEATHER_FOG#","Fog"],

    //T2_UserInteraction
    //actionsInVehicle
    ["#AV_JUMP_OUT_TITLE#","Jump out"],
    ["#AV_SEAT_SWITCH_NEXT_TITLE#","Next seat"],
    ["#AV_SEAT_SWITCH_PREV_TITLE#","Previous seat"],
    ["#AV_ALL_WHEEL_TITLE_ON#","All wheel drive ON"],
    ["#AV_ALL_WHEEL_TITLE_OFF#","All wheel drive OFF"],
    ["#AV_QUICK_VEH_ACCESS_TITLE#","Quick vehicle get in"],
    //actionsItems
    ["#AI_CAMP_TITLE#","Deploy camp"],
    ["#AI_CAMP_TO_BASE_TITLE#","Return to base"],
    ["#AI_CAMP_TO_BASE_ENEMIES#","Taxi: 'Sorry, boss, but there are enemies nearby'"],
    ["#AI_CAMP_TO_BASE_MONEY_LOW#","Taxi: 'That would be %1. Seems you don't have that'"],
    ["#AI_SMOKE_TITLE#","Smoke out"],
    ["#AI_REPAIR_TITLE#","Repair"],
    ["#AI_UNFLIP_TITLE#","Unflip"],
    //actionsKeybind
    ["#AK_EARPLUGS_ON#","Earplugs on"],
    ["#AK_EARPLUGS_OFF#","Earplugs off"],
    //inventoryUI
    ["#INV_BUTTON_LOOT_TOOLTIP#","Loot to storage"],
    ["#INV_BUTTON_WEAP_TOOLTIP#","Switch weapon"],
    ["#INV_BUTTON_UNIF_TOOLTIP#","Change uniform"],
    ["#INV_BUTTON_MAGR_TOOLTIP#","Repack magazines"],
    //keybindings
    ["#KB_USER_PLANSHET#","User Tablet"],
    ["#KB_ACT_EARPLUGS#","Earplugs"],
    ["#KB_ACT_WEAPONS_AWAY#","Weapons away"],
    ["#KB_VIEW_DISTANCE#","View Distance"],
    ["#KB_ACT_PARACHUTE_DEPLOYMENT#","Parachute deployment"],
    ["#UP_SETTINGS_KEYBINDINGS_HINT_1#","Press new key or key combination to assign"],
    ["#UP_SETTINGS_KEYBINDINGS_HINT_2#","Ctrl, Shift, Alt - modifiers"],
    ["#UP_SETTINGS_KEYBINDINGS_HINT_3#",'"Delete" or "BackSpace" - delete keybinding'],
    ["#UP_SETTINGS_KEYBINDINGS_HINT_4#",'"Tab" - toggle key bypass'],
    //medicine
    ["#MED_CLI_BLEEDING_UI_TITLE_LOW#","Patched"],
    ["#MED_CLI_BLEEDING_UI_TITLE_MID#","Bleeding"],
    ["#MED_CLI_BLEEDING_UI_TITLE_HIGH#","Actively bleeding"],
    ["#MED_CLI_BLEEDING_UI_TITLE_DMG#","Bleeding fresh wounds"],
    ["#MED_CLI_BLEEDING_UI_TIMELEFT#","Time left: %1  [-%2]"],
    ["#MED_CLI_BLEEDING_UI_CLOSEST_PLAYER#","Nearby: %1 (%2m)"],
    ["#MED_CLI_BLEEDING_UI_NO_CLOSEST#","Nobody nearby"],
    ["#MED_ACTION_SELF_HEAL_TITLE#","Heal yourself"],
    ["#MED_ACTION_SELF_HEAL_HINT#","FAKs left: %1  Success chance: %2%%"],
    ["#MED_ACTION_SELF_HEAL_PATCHED#","%1 patched themself"],
    ["#MED_ACTION_SELF_HEAL_SUCCESS#","%1 revived themself"],
    ["#MED_ACTION_SELF_HEAL_FAILURE#","%1 failed to revive themself"],
    ["#MED_ACTION_RESPAWN_TITLE#","Evac to base"],
    ["#MED_ACTION_HEAL_TITLE#","Heal"],
    ["#MED_HAS_MEDKIT#","[+]"],
    ["#MED_NO_MEDKIT#","[-]"],
    ["#MED_ACTION_HEAL_MED_HINT#","Medkit: %1  FAKs left: %2"],
    ["#MED_ACTION_HEAL_FAK_HINT#","FAKs left: %1  Success chance: %2%%"],
    ["#MED_ACTION_HEAL_PATCHED#","%2 patched by %1"],
    ["#MED_ACTION_HEAL_SUCCESS#","%2 revived by %1"],
    ["#MED_ACTION_HEAL_FAILURE#","%1 failed to revive %2"],
    ["#MED_ACTION_DRAG_TITLE#","Drag"],
    ["#MED_ACTION_CARRY_TITLE#","Carry"],
    ["#MED_ACTION_RELEASE_TITLE#","Release"],
    ["#MED_ACTION_VEH_LOADIN_TITLE#","Load in"],
    ["#MED_BLAME_VEH_KO_NOBODYS#","%1 lost vehicle"],
    ["#MED_BLAME_VEH_KO_DAMAGER#","%2 lost vehicle by %1"],
    ["#MED_BLAME_WOUND_NOBODYS#","%1 incapacitated"],
    ["#MED_BLAME_WOUND_DAMAGER#","%2 incapacitated by %1"],
    ["#MED_BLAME_KILL_NOBODYS#","%1 executed"],
    ["#MED_BLAME_KILL_DAMAGER#","%2 executed by %1"],
    //playerStateHolder
    ["#DPL_LOADOUT_DEPLETED#","Taxi driver took %1%% of your equipment"],
    ["#DPL_ADD_WEAPON_DEPLETED#","Taxi driver took your additional weapon"],
    ["#DPL_LOOT_DEPLETED#","Trader sold %1%% of your loot"],
    //userPlanshet
    ["#UP_BUTTON_MOBLSHOP_TOOLTIP#","Field support"],
    ["#UP_BUTTON_MTRANSFR_TOOLTIP#","Money transfer"],
    ["#UP_BUTTON_GROUPMNG_TOOLTIP#","Group management"],
    ["#UP_BUTTON_DOCUMNTS_TOOLTIP#","Documents"],
    ["#UP_BUTTON_PLR_INFO_TOOLTIP#","Player info"],
    ["#UP_BUTTON_SETTINGS_TOOLTIP#","Settings"],
    ["#UP_NOT_IMPLEMENTED_TOOLTIP#","This option is not implemented yet"],
    //03Group
    ["#UP_GROUP_TITLE#","Group management"],
    ["#UP_GROUP_MENU#","Open group menu"],
    ["#UP_GROUP_VOTE_BAN#","Ban vote"],
    ["#UP_GROUP_DISCORD#","Discord"],
    ["#UP_GROUP_DISCORD_BUTTON#","-=   Join NWGS Discord   =-"],
    //05Info
    ["#UP_INFO_TITLE#","Player info"],
    ["#UP_INFO_GENERAL#","%1    [lvl %2]    (Exp: %3)"],
    ["#UP_INFO_TAXI_LVL#","Taxi insurance: %1%%"],
    ["#UP_INFO_TRDR_LVL#","Trader insurance: %1%%"],
    ["#UP_INFO_COMM_LVL#","Support level: %1"],
    //06Settings
    ["#UP_SETTINGS_TITLE#","Settings"],
    ["#UP_SETTINGS_KEYBINDINGS#","Keybindings"],
    //voting
    ["#VOTE_RESULT_INFAVOR#","\nResult: IN FAVOR"],
    ["#VOTE_RESULT_AGAINST#","\nResult: AGAINST"],
    ["#VOTE_RESULT_UNDEFINED#","\nResult: UNDEFINED"],
    ["#VOTE_HINT_BODY#","[+]:%1 [-]:%2 (%3)sec"],
    ["#VOTE_HINT_FOOTER_DO#","\nEnter + or - in chat"],
    ["#VOTE_HINT_FOOTER_DONE#","\nYour voice counted as [%1]"],
    //votingBan
    ["#VOTE_BAN_TITLE#","Ban %1?"],
    ["#VOTE_BAN_ALREADY_RUNNING#","Another vote is running"],
    ["#VOTE_BAN_NO_TARGET#","No such player '%1'"],
    ["#VOTE_BAN_NOT_ENOUGH_PLAYERS#","Not enough players on server to start the vote (min: %1)"],

    //T3_Economics
    //escapeBillboard
    ["#ESCB_TITLE#","Level 17th Winners"],
    ["#ESCB_NO_WINNERS#","\nBe the first to get here!"],
    //hunting
    ["#A_HUNT_TITLE#",""],
    ["#A_HUNT_FORBIDDEN_MESSAGE#","Hey, %1, stay the fuck away from the dogs, you sick fuck!"],
    //lootMission
    ["#LS_ACTION_LOOT_TITLE#","<img image='a3\ui_f\data\igui\cfg\actions\gear_ca.paa' size='2.0'/>"],
    ["#LS_ACTION_LOOT_SUCCESS#","Looted"],
    ["#LS_ACTION_LOOT_FAILURE#","Nothing to take"],
    ["#LS_ACTION_LUGGAGE_TITLE#","<img image='a3\ui_f\data\igui\cfg\actions\gear_ca.paa' size='2.0'/>"],
    //lootStorage
    ["#LS_STORAGE_ACTION_TITLE#","<t size='1.4'>Open Storage</t>"],
    ["#LS_STORAGE_ACTION_TITLE_2#","Open Storage"],
    ["#LS_DEPLETE_NOTIFICATION#","%1%% of your loot depleted"],
    //moneyTransfer
    ["#MT_ACTION_TITLE#","Money transfer"],
    ["#MT_PLAYER_NOT_FOUND#","Player not found"],
    //progress
    ["#PRG_NOTIFY__EXP#","[Exp:  %1] (Total Exp:%2)"],
    ["#PRG_NOTIFY_TEXP#","Level up!  %1. New level: lvl %2"],
    ["#PRG_NOTIFY_TAXI#","Taxi insurance increased by %1%%. New insurance: %2%%"],
    ["#PRG_NOTIFY_TRDR#","Trader insurance increased by %1%%. New insurance: %2%%"],
    ["#PRG_NOTIFY_COMM#","Support level increased by %1. New support level: %2"],
    //shopItems
    // ["#ISHOP_ACTION_TITLE#","Open Shop"],//not used anymore
    ["#ISHOP_SELLER_MONEY_CONST#","€$---"],
    ["#ISHOP_CAT_ALL#","All"],
    ["#ISHOP_CAT_CLTH#","Clothing"],
    ["#ISHOP_CAT_WEAP#","Weapons"],
    ["#ISHOP_CAT_ITEM#","Items"],
    ["#ISHOP_CAT_AMMO#","Ammunition"],
    ["#ISHOP_MULT_X10_TT#","Ctrl"],
    ["#ISHOP_MULT_ALL_TT#","Shift"],
    //shopMobile
    ["#MSHOP_ROOT_TITLE#","Field support"],
    ["#MSHOP_SUPPORT_NEED_TEMPLATE#","[ NO ACCESS. Support level: %1 ]"],
    ["#MSHOP_CAT0_TITLE#","Drones"],
    ["#MSHOP_C0I0#","Scout drone"],
    ["#MSHOP_C0I1#","Suicide drone (Heat 44)"],
    ["#MSHOP_C0I2#","Suicide drone (Heat 55)"],
    ["#MSHOP_C0I3#","Suicide drone (Heat 75)"],
    ["#MSHOP_C0I4#","Mine-deployment drone"],
    ["#MSHOP_C0I4_ActionTitle#","Deploy mine"],
    ["#MSHOP_C0I4_ActionTooHigh#","Too high for mine deployment"],
    ["#MSHOP_C0I5#","Thunder EMI drone"],
    ["#MSHOP_C0I5_ActionTitle#","Activate"],
    ["#MSHOP_C0I6#","Bomber drone"],
    ["#MSHOP_C0I7#","Ababil"],
    ["#MSHOP_CAT1_TITLE#","Mortar strike"],
    ["#MSHOP_C1I0#","Single strike"],
    ["#MSHOP_C1I1#","Double tap"],
    ["#MSHOP_C1I2#","Three in a row"],
    ["#MSHOP_C1I3#","Barrage"],
    ["#MSHOP_C1I4#","Illumination shells"],
    ["#MSHOP_C1I5#","Smoke shells"],
    ["#MSHOP_CAT2_TITLE#","Infantry support"],
    ["#MSHOP_C2I0#","Team (2)"],
    ["#MSHOP_C2I1#","Squad (3)"],
    ["#MSHOP_C2I2#","Company (5)"],
    ["#MSHOP_C2I3#","Fire team (8)"],
    ["#MSHOP_CAT3_TITLE#","Vehicle delivery"],
    ["#MSHOP_MAP_ITEM_HINT#","Point destination"],
    ["#MSHOP_MAP_VEHICLE_HINT#","Point where to deliver"],
    //shopVehicles
    // ["#VSHOP_ACTION_TITLE#","Open Shop"],//not used anymore
    ["#VSHOP_SELLER_MONEY_CONST#","€$---"],
    ["#VSHOP_CAT_ALL#","All"],
    ["#VSHOP_CAT_AAIR#","Anti-Air"],
    ["#VSHOP_CAT_APCS#","APCs"],
    ["#VSHOP_CAT_ARTY#","Artillery"],
    ["#VSHOP_CAT_BOAT#","Boats"],
    ["#VSHOP_CAT_CARS#","Cars"],
    ["#VSHOP_CAT_DRON#","Drones"],
    ["#VSHOP_CAT_HELI#","Helicopters"],
    ["#VSHOP_CAT_PLAN#","Planes"],
    ["#VSHOP_CAT_SUBM#","Submarines"],
    ["#VSHOP_CAT_TANK#","Tanks"],
    ["#VSHOP_PLATFORM_OCCUPIED#","Platform occupied"],
    ["#VSHOP_CANNOT_SELL_VEHICLE#","Vehicle unavailable"],
    //vehCustomizationAppearance
    ["#CAPP_LEFT_TITLE#","Color"],
    ["#CAPP_RIGHT_TITLE#","Components"],
    //vehCustomizationPylons
    ["#CPYL_LEFT_TITLE#","Pylon presets"],
    ["#CPYL_RIGHT_TITLE#","Pylons owner"],
    ["#CPYL_OWNER_PILOT#","Pilot"],
    ["#CPYL_OWNER_GUNNER#","Gunner"],
    //vehOwnership
    ["#VEHOWN_MESSAGE_OWNER#","['%1'] Owner: %2"],
    //wallet
    ["#WLT_NOTIFY_MONEY_ADD#","[Money:  +%1]"],
    ["#WLT_NOTIFY_MONEY_SUB#","[Money:  %1]"],

    //T4_Dialogues
    //dialogueSystem
    /*Action title*/
    ["#DLG_OPEN_TITLE#","<img image='a3\ui_f\data\igui\cfg\actions\talk_ca.paa' size='1.5'/> <t size='1.5'>Talk</t>"],
    /*NPC names*/
    ["#NPC_TAXI_NAME#","Taxi"],
    ["#NPC_MECH_NAME#","Mechanic"],
    ["#NPC_TRDR_NAME#","Trader"],
    ["#NPC_MEDC_NAME#","Doc"],
    ["#NPC_COMM_NAME#","Commander"],
    ["#NPC_ROOF_NAME#","Ivan the Roof"],
    /*Answers generation (auto gen for any NPC by DLGHLP)*/
    ["#AGEN_PRGB_HOW_WORK_01#","How does it work?"],
    ["#AGEN_PRGB_CUR_STAT_01#","What's the current state?"],
    ["#AGEN_PRGB_LETS_UPG_01#","I want to upgrade it"],
    ["#AGEN_HELP_01#","What should I know?"],
    ["#AGEN_HELP_PLC_01#","What is this place?"],
    ["#AGEN_HELP_WHO_01#","Who are you?"],
    ["#AGEN_HELP_TLK_01#","Who should I talk to?"],
    ["#AGEN_HELP_UFL_01#","How things are done here?"],
    ["#AGEN_ADV_01#","Any advice?"],
    ["#AGEN_ANQ_01#","Another question"],
    ["#AGEN_ANQ_02#","I have another question"],
    ["#AGEN_ANQ_03#","And another one"],
    ["#AGEN_ANQ_04#","And one more thing"],
    ["#AGEN_ANQ_05#","Also something else"],
    ["#AGEN_BACK_01#","Got it"],
    ["#AGEN_BACK_02#","Yeah, I got it"],
    ["#AGEN_BACK_03#","Got it, thanks"],
    ["#AGEN_BACK_04#","All right"],
    ["#AGEN_BACK_05#","All right, got it"],
    ["#AGEN_DOUBT_01#","No, something else first"],
    ["#AGEN_DOUBT_02#","On the second thought..."],
    ["#AGEN_DOUBT_03#","No, never mind"],
    ["#AGEN_DOUBT_04#","No, forget it"],
    ["#AGEN_DOUBT_05#","Not now maybe"],
    ["#AGEN_DOUBT_06#","Actually, no, forget it"],
    ["#AGEN_EXIT_01#","See you around"],
    ["#AGEN_EXIT_02#","Ok, see you"],
    ["#AGEN_EXIT_03#","Thanks, bye"],
    ["#AGEN_EXIT_04#","I better go now"],
    ["#AGEN_EXIT_05#","I'll come back later"],
    ["#AGEN_EXIT_06#","Never mind, I'll go now"],
    ["#AGEN_PAY_Y_MONEY_01#","Here you go"],
    ["#AGEN_PAY_Y_MONEY_02#","Take it"],
    ["#AGEN_PAY_Y_MONEY_03#","Here's the money"],
    ["#AGEN_PAY_Y_MONEY_04#","Sure, here it is"],
    ["#AGEN_PAY_Y_MONEY_05#","Yeah, here"],
    ["#AGEN_PAY_N_MONEY_01#","I don't have that much"],
    ["#AGEN_PAY_N_MONEY_02#","That's more than I have"],
    ["#AGEN_PAY_N_MONEY_03#","Damn, I don't have that much"],
    ["#AGEN_PAY_N_MONEY_04#","Don't have that much right now"],
    ["#AGEN_PAY_N_MONEY_05#","Nah, don't have that"],
    ["#AGEN_PAY_REFUSE_01#","Never mind actually"],
    ["#AGEN_PAY_REFUSE_02#","I've changed my mind"],
    ["#AGEN_PAY_REFUSE_03#","I'll come back later maybe"],
    ["#AGEN_PAY_REFUSE_04#","No, forget it"],
    ["#AGEN_PAY_REFUSE_05#","I have to think about it"],
    /*Common answers to any NPC*/
    ["#XXX_01_Q_01#","Anything else?"],
    ["#XXX_QUIT_DIALOGUE#","No, nothing"],
    ["#XXX_PAY_Q_01#","That would be %1"],
    /*====== TAXI =====*/
    /*Taxi - logic*/
    ["#TAXI_CAT_SQD#","To my Squad Mates"],
    ["#TAXI_CAT_VHC#","To my Vehicle"],
    ["#TAXI_CAT_CMP#","To my Camp"],
    ["#TAXI_CAT_AIR#","Paradrop me, I'll show on the map"],
    ["#TAXI_NO_DROP_POINTS#","Sorry, guess there are none..."],
    ["#TAXI_INV_DROP_POINT#","Failed to drop you"],
    ["#TAXI_PARADROP_HINT#","Hint: Deploy parachute\n'Space' by default while in air"],
    /*Taxi - TAXI_00*/
    ["#TAXI_00_Q_01#","Always good to see new faces"],
    ["#TAXI_00_Q_02#","How's it going, boss?"],
    ["#TAXI_00_Q_03#","Need a ride?"],
    ["#TAXI_00_Q_04#","Hey, what's up, boss?"],
    ["#TAXI_00_A_01#","Drop me by..."],
    ["#TAXI_00_A_02#","About my insurance..."],
    /*Taxi - TAXI_01*/
    ["#TAXI_01_Q_02#","So?"],
    /*Taxi - TAXI_CS*/
    ["#TAXI_CS_Q_01#","Where to, boss?"],
    ["#TAXI_CS_Q_02#","Sure thing, boss|Where do you need to?"],
    ["#TAXI_CS_Q_03#","Okay, where to?"],
    /*Taxi - TAXI_PS*/
    ["#TAXI_PS_Q_01#","Which one?"],
    /*Taxi - TAXI_LOW*/
    ["#TAXI_LOW_Q_01#","That's a shame, boss"],
    ["#TAXI_LOW_Q_02#","Come back when you have it, boss|Or check other options"],
    ["#TAXI_LOW_Q_03#","Low on cash, boss?|Try selling some stuff"],
    ["#TAXI_LOW_Q_04#","Sorry, boss, no discounts"],
    ["#TAXI_LOW_A_01#","Yeah, right..."],
    ["#TAXI_LOW_A_02#","See you later"],
    /*Taxi - TAXI_HELP*/
    ["#TAXI_HELP_Q_01#","Specific or in general?"],
    ["#TAXI_HELP_Q_02#","Depends. What would you like to know, boss?"],
    ["#TAXI_HELP_Q_03#","A lot of things, boss|But is there anything specific?"],
    ["#TAXI_HELP_Q_04#","Shoot your question, boss"],
    /*Taxi - TAXI_HELP_PLACE*/
    ["#TAXI_HELP_PLACE_Q_01#","You mean the base or my stand in particular, boss?|Well, the base is a base|As for my stand - it is a pickup point for my customers|For you guys that is|You can always meet me here and ask for a ride|Or just chat, I don't mind|Whatever floats your boat, boss"],
    /*Taxi - TAXI_HELP_WHO*/
    ["#TAXI_HELP_WHO_Q_01#","They call me a 'taxi driver' or 'taxi' for short|Suits me fine|Don't know what else to tell you|I like a good tea and I save money to buy me a new car|I do a straightforward exchange of your funds for my services|Oh, and recently I partnered with a local fella having a plane|So now we're 'taxi airline' too|You should try it, boss, just ask for a paradrop"],
    /*Taxi - TAXI_HELP_TALK*/
    ["#TAXI_HELP_TALK_Q_01#","You should definitely talk to a bossman inside|Tell him I said hi|There's also a mech guy - awesome fella|Always helps me with my vehicles|You can buy yourself one too, of course|But then, it's easier to just ask me for a ride|Cheaper too|Then there's a trader guy, charming lad, you'll like him|Medic and some shady guy on the roof, don't know him honestly|And that's about it"],
    /*Taxi - TAXI_HELP_USERFLOW*/
    ["#TAXI_HELP_USERFLOW_Q_01#","Quite simple, just tell me where to drop you off|I'll calculate the price and get you there in no time|As for getting back...|If you grab a sleeping bag and deploy a camp - sure, no problem|But if you don't|Sorry, boss, but you'll have to figure it out yourself then|Nothing personal, just a safety measure|Speaking of safety|I actually do one extreme thing - the emergency evac|But only if it's a 'life or death' situation|And it won't even cost you money, ain't that great?|I'll just take your equipment as a payment|Sounds fair, right?|Oh c'mon, boss, a man has to keep his business afloat|If you're so against it - let's discuss the insurance"],
    /*Taxi - TAXI_ADV*/
    ["#TAXI_ADV_Q_01#","Always plan your exit route|As much as I like doing my job and getting my cut|Just as much I want my customers to turn into regulars|You know what I mean?"],
    ["#TAXI_ADV_Q_02#","Don't rush into the fight|If you want me to drop you near you squad|Ask them first if it is safe"],
    ["#TAXI_ADV_Q_03#","Always tip your driver|That would be me"],
    ["#TAXI_ADV_Q_04#","If you find a sleeping bag|You can deploy a camp for yourself and the others|Just make sure you do that at a safe distance|Away from both the enemy lines and our base|And since I know it is a relatively safe route|I'll charge less to drop you off there|And even pick you up as well"],
    ["#TAXI_ADV_A_01#","That is a good wisdom"],
    /*Taxi - TAXI_PRGB*/
    ["#TAXI_PRGB_Q_01#","What about it, boss?"],
    ["#TAXI_PRGB_Q_02#","Yeah? What about it?"],
    /*Taxi - TAXI_PRGB_HOW_WORK*/
    ["#TAXI_PRGB_HOW_WORK_Q_01#","Why don't you just make it back on your own, boss?|That will spare us from having a tough conversation|But... Yeah, all right, listen|I do emergency evac, all right?|And bossman inside says I do it 'pro bono'|Meaning I am forbidden from charging you guys money for it|Like it was a part of my deal with the bossman|And, honestly|I won't have time to bargain anyway if things get rough|So... I say ok, I'll go another route|I'll need to cut off what's on you|To make my job easier|Remove the heavy, you know?|And where it goes - it goes|Now, if you want me to keep it for you - we can strike a deal|You pay better - I try harder. How does that sound?"],
    /*Taxi - TAXI_PRGB_CUR_STAT*/
    ["#TAXI_PRGB_CUR_STAT_Q_01#","Your current insurance covers %1|Meaning I'll take %2 of your stuff|And there's a %2 chance I'll take your additional weapon"],
    /*Taxi - TAXI_PRGB_LETS_UPG*/
    ["#TAXI_PRGB_LETS_UPG_Q_01#","Hey, boss, I've got a good news for you|Your insurance is absolute|That's a money well spent|So... no, there's nothing to upgrade|Mr. Big Boss"],
    ["#TAXI_PRGB_LETS_UPG_Q_02#","Sure thing, boss, that would be|%1"],
    /*Taxi - TAXI_PRGB_UPG*/
    ["#TAXI_PRGB_UPG_Q_01#","Always a pleasure dealing with you, boss|I'll write it down under your name"],
    /*====== MECH =====*/
    /*Mech - logic*/
    ["#MECH_NO_VEHICLES#","Sorry, guess there are none..."],
    ["#MECH_INV_VEH#","Failed to service vehicle"],
    /*Mech - MECH_00*/
    ["#MECH_00_Q_01#","Newcomer?|Hope you know how to drive"],
    ["#MECH_00_Q_02#","Yes?"],
    ["#MECH_00_Q_03#","What can I help you with?"],
    ["#MECH_00_Q_04#","Hey, have you seen...|A guy with a red crowbar?|The fucker owes me|That's MY fucking crowbar|And it is my favorite|You meet him - you let me know|Okay?"],
    ["#MECH_00_Q_05#","Buy? Sell? Repair?"],
    ["#MECH_00_A_01#","Open the shop"],
    ["#MECH_00_A_02#","Open the garage"],
    ["#MECH_00_A_03#","I need your services"],
    /*Mech - MECH_01*/
    ["#MECH_01_Q_02#","What?"],
    ["#MECH_01_Q_03#","Yeah, what?"],
    /*Mech - MECH_SERV*/
    ["#MECH_SERV_Q_01#","What kind of?"],
    ["#MECH_SERV_A_01#","I need repair"],
    ["#MECH_SERV_A_02#","I need refuel"],
    ["#MECH_SERV_A_03#","I need my vehicle rearmed"],
    ["#MECH_SERV_A_04#","Can you customize my vehicle?"],
    ["#MECH_SERV_A_05#","Can you change pylons?"],
    ["#MECH_SERV_A_06#","Can you install that 'All Wheel' drive gear?"],
    /*Mech - MECH_REPAIR*/
    ["#MECH_REPAIR_Q_01#","Sure thing, which vehicle?"],
    ["#MECH_REPAIR_Q_02#","Repairs is what I do. Which one to look at?"],
    /*Mech - MECH_REFUEL*/
    ["#MECH_REFUEL_Q_01#","You're lucky I didn't spend it all. Which one to refuel?"],
    ["#MECH_REFUEL_Q_02#","Yeah, got some fuel. Which one?"],
    /*Mech - MECH_REARM*/
    ["#MECH_REARM_Q_01#","Got some ammo. Which one to top up?"],
    ["#MECH_REARM_Q_02#","Sure thing"],
    /*Mech - MECH_APRNC*/
    ["#MECH_APRNC_Q_01#","Drive with a style kinda guy?|Sure thing, which one?"],
    ["#MECH_APRNC_Q_02#","Want me to pimp your ride?"],
    /*Mech - MECH_PYLON*/
    ["#MECH_PYLON_Q_01#","Let's do some heavy lifting then"],
    ["#MECH_PYLON_Q_02#","I don't mind heavy lifting|But those missiles are a pain in the ass|Especially when they fall|But sure, let's do it, which one?"],
    ["#MECH_PYLON_Q_03#","Guess we've got an actual pilot here, huh?"],
    /*Mech - MECH_ALWHL*/
    ["#MECH_ALWHL_Q_01#","Yeah, crazy stuff|But extremely useful"],
    ["#MECH_ALWHL_Q_02#","So you like my invetion?|It ain't cheap"],
    ["#MECH_ALWHL_Q_03#","Yeah, man, let's make you a monster truck"],
    ["#MECH_ALWHL_Q_04#","Glad someone appreciates it"],
    /*Mech - MECH_LOW*/
    ["#MECH_LOW_Q_01#","Well, yeah, it ain't cheap"],
    ["#MECH_LOW_Q_02#","Sorry, bud, no discounts"],
    ["#MECH_LOW_A_01#","I guess"],
    ["#MECH_LOW_A_02#","Well, see you"],
    /*Mech - MECH_DONE*/
    ["#MECH_DONE_Q_01#","It's son and done!"],
    ["#MECH_DONE_Q_02#","Give me a minute...|Here. All done"],
    ["#MECH_DONE_Q_03#","Hold on a second...|Yep. That will do"],
    ["#MECH_DONE_Q_04#","Done in no time"],
    /*Mech - MECH_HELP*/
    ["#MECH_HELP_Q_01#","About what?"],
    ["#MECH_HELP_Q_02#","Yeah? About what?"],
    ["#MECH_HELP_Q_03#","In particular?"],
    /*Mech - MECH_HELP_PLACE*/
    ["#MECH_HELP_PLACE_Q_01#","This is a place where you can sell or buy your own vehicle|I also do repairs, refueling and other services"],
    /*Mech - MECH_HELP_WHO*/
    ["#MECH_HELP_WHO_Q_01#","Sorry, there are no names here|So just call me 'mechanic' or 'mech guy'|It should be pretty obvious what I do"],
    /*Mech - MECH_HELP_TALK*/
    ["#MECH_HELP_TALK_Q_01#","Talk to?|The taxi guy over there does deliveries|I work with vehicles|Trader inside will buy your stuff|And if you don't know where to start|Go report to the field commander|He'll explain everything"],
    /*Mech - MECH_HELP_USERFLOW*/
    ["#MECH_HELP_USERFLOW_Q_01#","Well, my shop is open for business 24/7|You bring in vehicles - I don't ask where they came from|I buy everything - military grade, civilian, cars, quads...|Naturally, I will have to check them for any damage and fix it|That will lower the price for you|Oh, and don't forget anything inside - it goes straight to trash|You can also buy vehicles from me|We do have a 'buy back' program|Where you can buy something others sold|Or there are occasional new offers if you interested|They are mostly based on our reputation and progress|The more we clear - the more I have to offer|Lastly, you can order a delivery through your tablet|We will charge a little extra for that|Just go to 'F3' 'Field support' 'Vehicle delivery'|Oh, and things become more interesting if you are a squad leader|In that case|You can buy vehicles using your entire squad's funds|And if you sell - the profit is split between all of you"],
    /*Mech - MECH_ADV*/
    ["#MECH_ADV_Q_01#","Avoid drowning your vehicle|You can repair it if it's broken|Refuel it if it's empty|Hell, even flip it back on it's wheels|But drowning?|That's a 'no return' and 'warranty void'|Nothing you can do"],
    ["#MECH_ADV_Q_02#","I'm not sure if I should tell it|But hell, there's so much work|So listen|Repair your own vehicle before selling it|I will buy it for more|And won't have to spend much time with it|A win-win, right?"],
    ["#MECH_ADV_Q_03#","Don't get greedy|If you see you need to sacrifice your ride|Do it|You can always get a new one|It is better to lose some additionals|Than most of what you got so far"],
    ["#MECH_ADV_Q_04#","Keep your toolkit with you|Yeah, that simple"],
    ["#MECH_ADV_Q_05#","Every owned vehicle doubles as a loot stash|Don't worry, others can't access it|And when you come back, we'll move your stuff to Trader's"],
    /*====== TRDR =====*/
    /*Trdr - TRDR_00*/
    ["#TRDR_00_Q_01#","How come you have no money?|Look but don't touch anything|Have something to sell at least?"],
    ["#TRDR_00_Q_02#","Newcomer?|You would be wise to buy a UAV terminal and a radio|It's a good investment|Here, I have some for sale"],
    ["#TRDR_00_Q_03#","Welcome to my shop, friend"],
    ["#TRDR_00_Q_04#","My favorite customer|How are you today?"],
    ["#TRDR_00_Q_05#","Yes?"],
    ["#TRDR_00_Q_06#","Look who we got here"],
    ["#TRDR_00_Q_07#","Buy or sell?"],
    ["#TRDR_00_Q_08#","Come on in"],
    ["#TRDR_00_A_01#","Let's trade"],
    ["#TRDR_00_A_02#","About insurance..."],
    /*Trdr - TRDR_01*/
    ["#TRDR_01_Q_01#","Made your mind?"],
    ["#TRDR_01_Q_02#","So what it will be?"],
    ["#TRDR_01_Q_03#","Something else?"],
    /*Trdr - TRDR_HELP*/
    ["#TRDR_HELP_Q_01#","About what?"],
    ["#TRDR_HELP_Q_02#","Yeah? About what?"],
    ["#TRDR_HELP_Q_03#","I'm a busy man, keep it short"],
    /*Trdr - TRDR_HELP_PLACE*/
    ["#TRDR_HELP_PLACE_Q_01#","Look around, this is my shop|This is where the money are made|And other there is your storage|You can check it out before selling things to me|Everything you get from outside goes into this box|And if you want to sell something that's on you at the moment|You should put it there"],
    /*Trdr - TRDR_HELP_WHO*/
    ["#TRDR_HELP_WHO_Q_01#","I am your best friend here|Seriously, you may not like me,|But as long as we both mean business - it doesn't matter|We'll get along just fine"],
    /*Trdr - TRDR_HELP_TALK*/
    ["#TRDR_HELP_TALK_Q_01#","You want me... to tell you about others?|(stares at you)|No|How about you go ask them yourself?"],
    /*Trdr - TRDR_HELP_USERFLOW*/
    ["#TRDR_HELP_USERFLOW_Q_01#","Listen, it's pretty simple|You find something of value out there|You put it in your storage|And then come back here and we trade|The more we expand our operations - the more I have to offer"],
    /*Trdr - TRDR_ADV1*/
    ["#TRDR_ADV1_Q_01#","Advice?|Put your money on the table|That's my advice|Next advice will cost you %1"],
    ["#TRDR_ADV1_Q_02#","Have you ever heard 'Advices are cheap'?|Well|Not mine though|How about %1?"],
    ["#TRDR_ADV1_Q_03#","%1"],
    /*Trdr - TRDR_ADV2*/
    ["#TRDR_ADV2_Q_01#","Don't stick with just one gun|There is always something to shoot from|But if you stick with one and only|You'll have a hard time finding ammo"],
    ["#TRDR_ADV2_Q_02#","Always share with others|Might sound stupid|But they can get your ass out of trouble|Or frag you|And say you were like that when they found you|Always remember that|Mutual respect brings more profit|And more customers"],
    ["#TRDR_ADV2_Q_03#","Found a pile of bodies?|Loot them|Only then move on|You never know if you see them again"],
    /*Trdr - TRDR_LOW*/
    ["#TRDR_LOW_Q_01#","Don't waste my time then|Advice he needs... pfft"],
    ["#TRDR_LOW_A_01#","Not like I wanted your stupid advice anyway"],
    ["#TRDR_LOW_A_02#","Yeah, right..."],
    ["#TRDR_LOW_A_03#","I'll be back"],
    /*Trdr - TRDR_PRGB*/
    ["#TRDR_PRGB_Q_01#","What about it?"],
    ["#TRDR_PRGB_Q_02#","Want to know more? Or strike a deal?"],
    /*Trdr - TRDR_PRGB_HOW_WORK*/
    ["#TRDR_PRGB_HOW_WORK_Q_01#","So here's the deal|You find some precious items out there|And you bring them here|If you don't come back yourself|Someone else has to bring them|And I have to pay them for that|So I sell what you've got and split the profit|Don't worry, I'll give you your cut as well|But don't expect much|If you don't like it - let's strike a deal|You make one time payment and I increase my generosity|I'll leave more of your loot untouched|Interested?"],
    /*Trdr - TRDR_PRGB_CUR_STAT*/
    ["#TRDR_PRGB_CUR_STAT_Q_01#","Let's see...|Your current insurance rate is %1|Which means I'll sell %2 of your loot if you screw up|Nothing personal, just a business"],
    /*Trdr - TRDR_PRGB_LETS_UPG*/
    ["#TRDR_PRGB_LETS_UPG_Q_01#","Your insurance covers it all|Wow|I'm not sure there's anyone else who have reached that level|So last time it was your final upgrade|Congratulations"],
    ["#TRDR_PRGB_LETS_UPG_Q_02#","Okay, let me see the money|The price is %1"],
    /*Trdr - TRDR_PRGB_LOW*/
    ["#TRDR_PRGB_LOW_Q_01#","So why exactly are you wasting my time then?"],
    ["#TRDR_PRGB_LOW_A_01#","There's something else I need"],
    ["#TRDR_PRGB_LOW_A_02#","I'll be back"],
    /*Trdr - TRDR_PRGB_UPG*/
    ["#TRDR_PRGB_UPG_Q_01#","Sign here|Done|Smart man makes a wise investment"],
    /*====== MEDC =====*/
    /*Medc - MEDC_00*/
    ["#MEDC_00_Q_01#","Are you injured? Need my help?"],
    ["#MEDC_00_Q_02#","You don't look good, son"],
    ["#MEDC_00_Q_03#","Yes? Yes?"],
    ["#MEDC_00_Q_04#","Did you bring your med card?"],
    ["#MEDC_00_Q_05#","Need pills?|Me too, son, me too"],
    ["#MEDC_00_A_01#","Yeah, I am. Can you patch me up?"],
    /*Medc - MEDC_01*/
    ["#MEDC_01_Q_01#","You look tired, son"],
    ["#MEDC_01_Q_02#","Make sure you eat well"],
    ["#MEDC_01_Q_03#","You need some sleep schedule"],
    ["#MEDC_01_A_01#","Can you patch me up?"],
    /*Medc - MEDC_PATCH*/
    ["#MEDC_PATCH_Q_01#","Sure thing, son|And since you're new here|Let's say your insurance covers it|Shall we?"],
    ["#MEDC_PATCH_Q_02#","Sure thing|It will cost you just %1"],
    ["#MEDC_PATCH_A_01#","Thanks,doc"],
    ["#MEDC_PATCH_A_02#","Yeah, here you go"],
    /*Medc - MEDC_HELP*/
    ["#MEDC_HELP_Q_01#","What would you like to know, son?"],
    ["#MEDC_HELP_Q_02#","Sure, what is it?"],
    /*Medc - MEDC_HELP_PLACE*/
    ["#MEDC_HELP_PLACE_Q_01#","Why, this is a hospital, of course.|You're not feeling well, son?|Do you know what year it is?"],
    /*Medc - MEDC_HELP_WHO*/
    ["#MEDC_HELP_WHO_Q_01#","My name is Dr. Jean-Baptiste Adebayo|But you can call me 'Doc'|Everybody here calls me that|They act strange when I use my full name|Like it is prohibited|But that is just natural for a man to have a name|We're not dogs"],
    /*Medc - MEDC_HELP_TALK*/
    ["#MEDC_HELP_TALK_Q_01#","Others?|Hmm, yes, I guess there are others|What about them?"],
    /*Medc - MEDC_HELP_USERFLOW*/
    ["#MEDC_HELP_USERFLOW_Q_01#","I'm just making sure everyone's wounds are treated here|These new FAK packages are something else, I tell you|Makes you feel like nothing's happened, and you're good as new|But that's just emergency medicine, son|Underneath|Your body gets damaged, and each new wound may be your last|You'll see|How it's getting harder and harder to pull yourself up|With each new shot you take|That's when you should come visit me|Or at least allow that driver to take you|I'll put you up on your feet. That's a promise"],
    /*Medc - MEDC_ADV*/
    ["#MEDC_ADV_Q_01#","Make sure you have enough first aid kits with you|Full Medkit is great too|But it is FAK you use to patch yourself up|Full Medkit for others, FAKs for yourself"],
    ["#MEDC_ADV_Q_02#","Don't mix those|I did|But that's okay..."],
    ["#MEDC_ADV_Q_03#","Hmm...|Just keep an eye out for each other"],
    /*====== COMM =====*/
    /*Comm - COMM_00*/
    ["#COMM_00_Q_01#","Operation already started|Good luck"],
    ["#COMM_00_Q_02#","There's an active operation going on already|Go join the others|And make it back in one piece"],
    ["#COMM_00_Q_03#","Newcomer?|You know how to fight?|Good"],
    ["#COMM_00_Q_04#","I'm listening"],
    ["#COMM_00_Q_05#","Report, soldier"],
    ["#COMM_00_Q_06#","At ease, soldier"],
    ["#COMM_00_Q_07#","Make it quick"],
    ["#COMM_00_A_01#","Ready to fight, sir"],
    ["#COMM_00_A_02#","Moving out"],
    ["#COMM_00_A_03#","About my support level..."],
    ["#COMM_00_A_04#","Can you explain me something?"],
    ["#COMM_00_A_05#","Any advice"],
    /*Comm - COMM_01*/
    ["#COMM_01_A_02#","I'll be on my way"],
    /*Comm - COMM_LVL*/
    ["#COMM_LVL_Q_01#","Goodspeed, soldier|Here's what we dealing with"],
    ["#COMM_LVL_Q_02#","Here are the options"],
    ["#COMM_LVL_Q_03#","Intelligence hinted on several points"],
    ["#COMM_LVL_A_01#","Show me the map"],
    ["#COMM_LVL_A_02#","Something else first"],
    ["#COMM_LVL_A_03#","Need more time for preparations"],
    ["#COMM_LVLSEL_LVLREQ#","[LOCKED. Required lvl: %1]"],
    ["#COMM_LVLSEL_LOCKED#","[LOCKED. Unlock price: %1]"],
    ["#COMM_LVLSEL#","Level %1"],
    /*Comm - COMM_LVL_REQ_LOCKED*/
    ["#COMM_LVL_REQ_LOCKED_Q_01#","I can not trust you with this one yet|Required level: %1"],
    ["#COMM_LVL_REQ_LOCKED_Q_02#","It's above my confidence in you|Required level: %1"],
    /*Comm - COMM_LVL_UNLOCK_PAY*/
    ["#COMM_LVL_UNLOCK_Q_01#","This will cost you %1|We'll split expenses among your group"],
    ["#COMM_LVL_UNLOCK_Q_02#","This will cost you %1"],
    /*Comm - COMM_LVL_UNLOCKED*/
    ["#COMM_LVL_UNLOCKED_Q_01#","New intel will be delivered any minute now"],
    /*Comm - COMM_LVL_MISSION*/
    ["#COMM_LVL_MISSION_Q_01#","So? Let's take a look?"],
    ["#COMM_LVL_MISSION_Q_02#","You're ready?"],
    ["#COMM_LVL_MISSION_Q_03#","Intel delivered|Want to take a look?"],
    /*Comm - COMM_HELP*/
    ["#COMM_HELP_Q_01#","What is it?"],
    ["#COMM_HELP_Q_02#","Sure, what is it?"],
    /*Comm - COMM_HELP_PLACE*/
    ["#COMM_HELP_PLACE_Q_01#","This is our field operation center|We gather all the information|And make plans on where to go next"],
    /*Comm - COMM_HELP_WHO*/
    ["#COMM_HELP_WHO_Q_01#","You should go see the doctor if you ask questions like that|But all right|You're looking at your field officer in charge|I gather intelligence from our sources|Communicate with local resistance cells|And mark current points of interest|But it is up to you to make a final decision|I just lay out the options"],
    /*Comm - COMM_HELP_TALK*/
    ["#COMM_HELP_TALK_Q_01#","You're making a right choice talking to me right now|Getting your new objective should be a priority|Outside you will find our delivery guy|He can take you closer to the target|There are also an engineer and a medic|Both are part of our task force|Trader there is a hired specialist|You should talk to him when you have something to sell|And the last one is the rookie on the roof|He is watching over supplies and dispatching drones"],
    /*Comm - COMM_HELP_USERFLOW*/
    ["#COMM_HELP_USERFLOW_Q_01#","Plain and simple, soldier|We collect the data on enemy activity in the area|You decide which way to go|Get in. Get as much as you can. Get out|Elimination of hostiles is NOT a priority|But you do that if situation requires|You'll see we range options based on enemy presence|The more there are enemy forces - the harder the work|But likely more you will find there of value|And yes, you pay for the intel|As we didn't get it for freew|Is it fair? Probably not|Is it the only way for us to survive? Yes it is|But based on average data, you'll earn more than that|So that shouldn't be an issue|Now, press 'F3' on your tablet and go to 'Field Support'|You'll see the various support options we can provide|Want to unlock more?|Go earn some and come back - we'll figure it out|And one more thing - pay attention to additional markers|If you see one of our callsigns on the map|That means there is some additional interest in the area|Go talk to whoever's name is mentioned|They might have a request|That's all"],
    /*Comm - COMM_ADV*/
    ["#COMM_ADV_Q_01#","Always communicate and keep your map at hand|Make sure you know where others are|And that they know your position|To avoid friendly fire and provide timely support"],
    ["#COMM_ADV_Q_02#","Keep radio channels busy with info|And free from garbage"],
    ["#COMM_ADV_Q_03#","Don't just rush into the fight|Plan everything beforehand|Make sure you know the number of targets and where they are|Mark routes you will take to approach the target|Prepare the exfil route and backup plan"],
    ["#COMM_ADV_Q_04#","You can smoke out the crew out of the vehicle|By placing a smoke or regular grenade into its vent intakes|But be careful|You will need to get really close to pull this off"],
    ["#COMM_ADV_Q_05#","Your personal descending device|Compact parachute|Should always be with you|You never know when you might need it|'Space' by default while in the air"],
    /*Comm - COMM_PRGB*/
    ["#COMM_PRGB_Q_01#","Yes? What about it?"],
    ["#COMM_PRGB_Q_02#","You have a question, soldier?"],
    /*Comm - COMM_PRGB_HOW_WORK*/
    ["#COMM_PRGB_HOW_WORK_Q_01#","We are short on resources|So we can not just give away our drones and what not|Even if you can pay for it|It's not about the money|It's about trust and limits of it|Prove you're a reliable earner|Complete the raids|Donate to our organization|And we'll give you access to a top notch stuff"],
    /*Comm - COMM_PRGB_CUR_STAT*/
    ["#COMM_PRGB_CUR_STAT_Q_01#","Your available support level is %1|With %2 more to go"],
    /*Comm - COMM_PRGB_LETS_UPG*/
    ["#COMM_PRGB_LETS_UPG_Q_01#","At ease, soldier|You've reached the max support level|I personally salute you|Well done"],
    ["#COMM_PRGB_LETS_UPG_Q_02#","Next support level is available|I'll unlock it in exchange for|%1"],
    /*Comm - COMM_PRGB_LOW*/
    ["#COMM_PRGB_LOW_Q_01#","I'm sure you know how to earn it"],
    ["#COMM_PRGB_LOW_A_01#","Yeah, right..."],
    ["#COMM_PRGB_LOW_A_02#","I'll come back"],
    /*Comm - COMM_PRGB_UPG*/
    ["#COMM_PRGB_UPG_Q_01#","Good|New support options must be available|Check your tablet"],
    /*====== ROOF =====*/
    /*Roof - Logic*/
    ["#ROOF_NO_TERMINALS#","Sorry, seems I don't have any..."],
    ["#ROOF_INV_TERMINAL#","Failed to reflash"],
    /*Roof - ROOF_00*/
    ["#ROOF_00_Q_01#","New guy, eh?"],
    ["#ROOF_00_Q_02#","What's up?"],
    ["#ROOF_00_Q_03#","Yeah?"],
    ["#ROOF_00_Q_04#","You need something?"],
    ["#ROOF_00_Q_05#","Stupid barrels..."],
    ["#ROOF_00_A_00#","Can you reflash this UAV terminal?"],
    ["#ROOF_00_A_01#","What are you doing here?"],
    ["#ROOF_00_A_02#","What else can you tell?"],
    /*Roof - ROOF_01*/
    ["#ROOF_01_Q_01#","You're ain't a busy bee, are you?"],
    ["#ROOF_01_Q_02#","Shouldn't you be somewhere else?"],
    ["#ROOF_01_Q_03#","What?"],
    /*Reflash - terminal selection*/
    ["#ROOF_TS_Q_01#","Which one do you have?"],
    ["#ROOF_TS_Q_02#","Which one?"],
    /*Reflash - not enough money*/
    ["#ROOF_LOW_Q_01#","Well? What are you waiting for then?|Go earn some|Shouldn't be that difficult"],
    ["#ROOF_LOW_Q_02#","Low on cash, eh?|Shit happens"],
    ["#ROOF_LOW_A_01#","Yeah, right..."],
    ["#ROOF_LOW_A_02#","I'll be back"],
    /*Roof - ROOF_WHAT*/
    ["#ROOF_WHAT_Q_01#","Jerking around, isn't that obvious?|No, really, I don't complain but|I would bring more to the table if I was allowed to go out there|But no. Ivan, we need you here|Look for supplies, start them drones|Keep an eye out for the enemy|Yeah, things would go rough without me here, I understand|I'm a valuable asset for this operation|But do you have any idea how heavy those fuel barrels are?|And no one helps me bring them down for that vehicle-headed shmuck"],
    /*Roof - ROOF_NO_TRUST*/
    ["#ROOF_NO_TRUST_Q_01#","Sorry 'bratan'|I don't know you|You don't know me|It is how it is|Come back when people know you"],
    ["#ROOF_NO_TRUST_Q_02#","Mhm...|Maybe later|Not right now, mkay?"],
    ["#ROOF_NO_TRUST_Q_03#","Is there no work for you?|Come back later"],
    ["#ROOF_NO_TRUST_Q_04#","I'm busy|And so should be you|Right?|Why don't you go and do something useful?|I'll be right here if you make it back"],
    ["#ROOF_NO_TRUST_A_01#","That's ok"],
    ["#ROOF_NO_TRUST_A_02#","Ok, bye"],
    /*Roof - ROOF_KNOW*/
    ["#ROOF_KNOW_Q_01#","I know may things|This place's history|Local legends|Some rumors|What is it for you?"],
    ["#ROOF_KNOW_Q_02#","Well, not like I have nothing to do|But why not|Go on|What's you interested in?"],
    ["#ROOF_KNOW_Q_03#","I know a litttle bit of this|A little bit of that|What do you need to know?"],
    ["#ROOF_KNOW_A_01#","History of this place"],
    ["#ROOF_KNOW_A_02#","Local legends"],
    ["#ROOF_KNOW_A_03#","Local rumors"],
    /*Roof - ROOF_HIST00*/
    ["#ROOF_HIST00_Q_01#","A short story or a long one?"],
    ["#ROOF_HIST00_A_01#","Short story"],
    ["#ROOF_HIST00_A_02#","Long story"],
    /*Roof - ROOF_HIST01*/
    ["#ROOF_HIST01_Q_01#","Okay, short story it is|We were mercenaries|New Wild Geese|Doing some jobs for some people, mkay?|But then management got a bit too greedy for 'freedom'|Didn't want to play by them rules, didn't want to share|So we got off the payment list|Lost our finances and access to every asset we had|Lost a bunch of contracts and clients too|Many people left, few stayed|So here we are. Starting from the bottom.|Trying to make a living|By robbing some poor fellas of their stuff,|Filling the black market with our goods|The job is dirty, but we're managing so far"],
    ["#ROOF_HIST01_A_01#","Okay, didn't know that, thanks"],
    ["#ROOF_HIST01_A_02#","Hm. Got that"],
    ["#ROOF_HIST01_A_03#","You're a terrible story teller"],
    /*Roof - ROOF_HIST02*/
    ["#ROOF_HIST02_Q_01#","Oh, boy, prepare for a long story then|So there was the time|When some old folks were in what was called 'RF2'|I don't know much, I wasn't there|But from what I heard|It was a giant unit with a lot of people in it|Then there was some drama between founders and common folk|That's when the first exodus occurred|People left|And established a 'UTF' - peace keeping unit|That I myself joined|Things were pretty simple|We were keeping these islands safe from invaders|Or so we were told|Occasionally dropping some fire on the cities|Doing some damage, blowing up some shit|No big deal|Then the second drama fired|Between 'founders' and 'opposition' on how to manage|Who should establish the rules and who should follow them|'Everyone is equal' and that sort of thing|Not being able to solve their differences|The second exodus happened|That's when our forefathers established a new unit|'New Wild Geese'|A unit of mercenaries to do jobs of any kind for shady people|Most importantly, to do them our way|No complaints from my side, it was fun while it lasted|Now it's a new iteration... probably the last|We scrape the bottom of the barrel, and do what we can|Let's see where it goes"],
    ["#ROOF_HIST02_A_01#","That was entertaining"],
    ["#ROOF_HIST02_A_02#","Hm. So that's what happened"],
    ["#ROOF_HIST02_A_03#","I almost fell asleep, honestly"],
    ["#ROOF_HIST02_A_04#","Dude, that whole story thing sucks"],
    /*Roof - ROOF_LGND00*/
    ["#ROOF_LGND00_Q_01#","It's not like 'legends' legends|Not like 'dwarfs and fairies'|There are guys here who we call local legends|So who do you want to know about?"],
    ["#ROOF_LGND00_Q_02#","Local legendary operators|Who do you want to hear about?"],
    ["#ROOF_LGND00_Q_03#","Yep, local legends they are|Nice guys|Well, most of them|Some of them... it depends, actually"],
    ["#ROOF_LGND00_A_01#","Operator HOPA"],
    ["#ROOF_LGND00_A_02#","Who's Bit... Rayman? Raymon?"],
    ["#ROOF_LGND00_A_03#","Can of RedBull?"],
    ["#ROOF_LGND00_A_04#","What was his name... Hui? Huy? Huiyui?"],
    ["#ROOF_LGND00_A_05#","Asmo"],
    /*Roof - ROOF_LGND01*/
    ["#ROOF_LGND01_Q_01#","Yeah, who?"],
    ["#ROOF_LGND01_Q_02#","Who?"],
    ["#ROOF_LGND01_Q_03#","Oh I know them all right"],
    /*Roof - another legend*/
    ["#ROOF_LGND_A_01#","What about others?"],
    /*Roof - ROOF_LGND_HOPA*/
    ["#ROOF_LGND_HOPA_Q_01#","Fucking genius, that's who he is|That guy could attach anything to anyone|He was building entire systems overnight|All with duct tape, spit, sticks and shit|Legendary engineer"],
    /*Roof - ROOF_LGND_BIT*/
    ["#ROOF_LGND_BIT_Q_01#","No, Rayman is another guy|But that Bit-Ramon?|Fucking lunatic|Would crash his heli into the building|Just to get there a 'Bit' faster|And knife out everyone inside|We thought he and MoshPit were the most badass out there|And were kinda expecting them to meet to settle the score|Turns out|It was all the same guy|Fucking both sides|Just for shit and giggles|Oh, and a fuck load of money of course"],
    /*Roof - ROOF_LGND_BANKA*/
    ["#ROOF_LGND_BANKA_Q_01#","No, 'Banka RedBulla'|A strange name I know|He would spend hours in the arsenal|Trying to match his outfit to some...|1969 Vietnam brigade only he heard about|Quite a passion for history, eh?|Most fun was when he would be put in charge|Everyone were dressing up|No exceptions|People kinda liked it even|He would also tell you much more than I could ever|Walking talking history book"],
    /*Roof - ROOF_LGND_HUI*/
    ["#ROOF_LGND_HUI_Q_01#","Don't look at me|I still have no idea how to spell his name|A legendary pilot who could give you a ride in and out|With ANY airborne vehicle available|Planes, choppers, VTOLs - the guy knew them all|He could land a Mohawk on a Satan's dick if he wanted to|Oh, and he once had a faulty cellphone connection|We don't know how|But he fried all the electronics on the base with it|That was fun"],
    /*Roof - ROOF_LGND_ASMO*/
    ["#ROOF_LGND_ASMO_Q_01#","Who the fuck is Asmo?"],
    /*Roof - ROOF_RUMR*/
    ["#ROOF_RUMR_Q_01#","Have you seen the bones yet?|People are saying|There are places where bones are scattered around|The worst part|Different people are pointing to different sites|So that shit may be widespread|And we have no idea who does that and why"],
    ["#ROOF_RUMR_Q_02#","Some locals caught some...|Sort of flu or smallpox|But now they are quarantined at military guarded camps|I don't know what it is, but that's no good news|That's for sure"],
    ["#ROOF_RUMR_Q_03#","Let's see...|We do have a problem with some maniac who kills people|And strips their meat from bones|And puts their skulls on display|How about that kind of rumor?|Scared?|Don't be|You have a gun|He might have too"],
    ["#ROOF_RUMR_Q_04#","Sorry, nothing comes to mind"],
    ["#ROOF_RUMR_Q_05#","Radio towers|I'm telling you|They emit dangerous radiation|So glad we have none of those here"],
    ["#ROOF_RUMR_Q_06#","Don't drink local water|They put something into it"],
    ["#ROOF_RUMR_Q_07#","There was a shipwreck nearby|A hundred meters off the coast|And no survivors|Can you imagine?|Who... or what killed those people?"],
    ["#ROOF_RUMR_Q_08#","Hey, I won't tell where and what|You WILL know when you see it|Just|Don't look it in the eyes and you'll be fine"],
    ["#ROOF_RUMR_Q_09#","We do have some occult shit happening here|Not sure what it is|Not sure if we have to worry"],
    ["#ROOF_RUMR_Q_10#","There is a secret cave somwhere on this island|What?|Yeah, I'm telling that no matter the island|There is always at least one"],
    ["#ROOF_RUMR_A_01#","Wait? For real?"],
    ["#ROOF_RUMR_A_02#","So they say, huh?"],
    ["#ROOF_RUMR_A_03#","Sounds like bullshit"],
    ["#ROOF_RUMR_A_04#","Any other rumors?"],
    /*Roof - ROOF_HELP*/
    ["#ROOF_HELP_Q_01#","What would you like to know?"],
    ["#ROOF_HELP_Q_02#","Yeah, what is it?"],
    ["#ROOF_HELP_Q_03#","So? Any specific questions?"],
    /*Roof - ROOF_HELP_PLACE*/
    ["#ROOF_HELP_PLACE_Q_01#","Let's see...|This is a shithole|Located in the middle of nowhere|And me and you are on top of it|Smile and enjoy the view|On a serious note,|We get supplies by air|And that roof is used as a landing pad of sorts|No, we don't use the pad downstairs|It's for the vehicle-headed fucker to park his shit|Convenient, huh?|Anyway, yeah|Shit gets dropped and picked up here, I launch the drones,|That's about it"],
    /*Roof - ROOF_HELP_WHO*/
    ["#ROOF_HELP_WHO_Q_01#","I'm your friendly neighbor spider man|What? I forgot my costume on another shitty island"],
    /*Roof - ROOF_HELP_TALK*/
    ["#ROOF_HELP_TALK_Q_01#","Let's see...|There is a smirky fucker,|A vehicle-headed fucker,|Constantly drugged spacing out fucker,|Sarcastic greedy fucker,|And our favorite, field commanding officer,|Who blesses us with his presence and orders to stay behind|That's about it"],
    /*Roof - ROOF_HELP_USERFLOW*/
    ["#ROOF_HELP_USERFLOW_Q_01#","You're asking a wrong guy|All I can tell is if you press that 'F3' button on your tablet|And order a drone support|That would be me to launch it"],
    /*Roof - ROOF_ADV*/
    ["#ROOF_ADV_Q_01#","Do your thing|That's my advice"],
    ["#ROOF_ADV_Q_02#","Different drones offer different capabilities|Try to learn them all"],
    ["#ROOF_ADV_Q_03#","Don't tell anyone you saw me here|Actually, you know what?|Don't tell anyone anything"],
    ["#ROOF_ADV_Q_04#","Did his highness called me a 'rookie'?|That's good. That's awesome. Exactly how it should be|Wait|He won't let me go if he thinks I'm a rookie|Ah damn..."],

    ["",""]
];