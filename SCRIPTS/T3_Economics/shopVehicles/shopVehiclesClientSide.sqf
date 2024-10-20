#include "..\..\globalDefines.h"

//================================================================================================================
//================================================================================================================
//Defines
//--- shopUI (copy to shopUI.sqf)
#define SHOP_UI_DIALOGUE_NAME "shopUI"
#define IDC_SHOPUI_DIALOGUE 7101
#define IDC_SHOPUI_PLAYERMONEYTEXT 1000
#define IDC_SHOPUI_SHOPMONEYTEXT 1001
#define IDC_SHOPUI_PLAYERLIST 1500
#define IDC_SHOPUI_SHOPLIST 1501
#define IDC_SHOPUI_PLAYERX1BUTTON 1600
#define IDC_SHOPUI_PLAYERX10BUTTON 1601
#define IDC_SHOPUI_PLAYERALLBUTTON 1602
#define IDC_SHOPUI_SHOPX1BUTTON 1603
#define IDC_SHOPUI_SHOPX10BUTTON 1604
#define IDC_SHOPUI_SHOPALLBUTTON 1605
#define IDC_SHOPUI_PLAYERDROPDOWN 2100
#define IDC_SHOPUI_SHOPDROPDOWN 2101

//Additional vehicle type
#define LOOT_VEHC_TYPE_ALL "ALL"

//Shop types
#define SHOP_TYPE_PLATFM "PLATFM"
#define SHOP_TYPE_MOBILE "MOBILE"

//================================================================================================================
//================================================================================================================
//Settings
NWG_VSHOP_CLI_Settings = createHashMapFromArray [
	["PRICE_SELL_TO_PLAYER_MULTIPLIER",1.3],
	["PRICE_BUY_FROM_PLAYER_MULTIPLIER",0.7],
	["PRICE_REDUCE_BY_DAMAGE",true],//If true, price will be reduced by damage of the vehicle

	["GROUP_LEADER_MANAGES_ALL_VEHICLES",true],//If true, group leader will be able to sell all vehicles of the group (also splits money between group members)

	["PLAYER_MONEY_BLINK_COLOR_ON_ERROR",[1,0,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_ON_SUCCESS",[0,1,0,1]],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_ON",0.3],
	["PLAYER_MONEY_BLINK_COLOR_INTERVAL_OFF",0.2],

	["ITEM_LIST_NAME_LIMIT",30],//Max number of letters for the item name
	["ITEM_LIST_TEMPLATE_W_DAMAGE","%1 [x%2] (%3)"],//Item list format string
	["ITEM_LIST_TEMPLATE_W_NO_DAMAGE","%1 (%2)"],//Item list format string

	["",0]
];

//================================================================================================================
//================================================================================================================
//Shop
NWG_VSHOP_CLI_shopType = SHOP_TYPE_PLATFM;
NWG_VSHOP_CLI_OpenPlatformShop = {
	//Get owned vehicles
	private _ownedVehicles = player call NWG_fnc_lsGetPlayerLoot;
	//Send request to server
	player remoteExec ["NWG_fnc_ishopShopValuesRequest",2];
	//The rest will be done once server responds
};

//================================================================================================================
//================================================================================================================
//Vehicle ownership utils
//Tries to convert vehicle classname to unified (BLUFOR) to avoid duplicates
NWG_VSHOP_CLI_GetUnifiedClassname = {
	// private _classname = _this;

	//Get base classname for the vehicle and disassemble it for analysis
	private _classname =_this call NWG_fnc_vcatGetBaseVehicle;
	private _classnameParts = _classname splitString "_";
	if ((count _classnameParts) < 2) exitWith {
		(format ["NWG_VSHOP_CLI_GetUnifiedClassname: Invalid classname '%1'",_classname]) call NWG_fnc_logError;
		_classname
	};

	//Get variables for further analysis
	private _prefix1 = _classnameParts#0;
	private _prefix2 = _classnameParts#1;
	private _doublePrefix = (count _prefix2) == 1;
	private _body = if (_doublePrefix)
		then {_classnameParts select [2]} /*select [2:]*/
		else {_classnameParts select [1]};/*select [1:]*/

	//Check if we have BLUFOR prefix already
	if (_prefix1 isEqualTo "B" && !_doublePrefix) exitWith {_classname};

	//Try converting to BLUFOR
	private _newClassname = (["B"] + _body) joinString "_";
	if (isClass (configFile >> "CfgVehicles" >> _newClassname)) exitWith {_newClassname};

	//Try converting to BLUFOR guerilla
	_newClassname = (["B","G"] + _body) joinString "_";
	if (isClass (configFile >> "CfgVehicles" >> _newClassname)) exitWith {_newClassname};

	//Return original if all else fails
	_classname
};