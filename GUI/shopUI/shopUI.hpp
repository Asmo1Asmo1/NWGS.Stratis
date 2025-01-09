//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"

//moved to imports.hpp
// import RscListbox;
// import RscText;
// import RscButton;
// import RscCombo;

//--- shopUI IDCs (copy to shopUI.sqf)
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

//--- scale helpers
#define LISTBOX_W (0.385 * X_SCALE)
#define LISTBOX_H (0.75 * Y_SCALE)
#define RIBBON_W (LISTBOX_W)
#define RIBBON_H (0.025 * Y_SCALE)
#define RIBBON_SPACE_X (0.01 * X_SCALE)
#define RIBBON_SPACE_Y (0.01 * Y_SCALE)
#define DROPDOWN_W (0.5 * RIBBON_W)
#define BUTTON_W ((DROPDOWN_W / 3) - RIBBON_SPACE_X)

//--- position helpers
#define L_GROUP_X (FROM_CENTER(1.425 * X_SCALE))
#define R_GROUP_X ((FROM_CENTER(-1.425 * X_SCALE)) - LISTBOX_W)
#define GROUP_Y (FROM_CENTER(0.70 * Y_SCALE))
#define MONEY_RIBBON_Y (GROUP_Y - (2 * RIBBON_H) - (2 * RIBBON_SPACE_Y))
#define BUTTON_RIBBON_Y (GROUP_Y - RIBBON_H - RIBBON_SPACE_Y)

class shopUI {
    idd = 7101;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Difake)
		////////////////////////////////////////////////////////

		class SUI_PlayerList: RscListbox
		{
			idc = 1500;
			x = L_GROUP_X;
			y = GROUP_Y;
			w = LISTBOX_W;
			h = LISTBOX_H;
			shadow = 1;
			rowHeight = 2.0 * RIBBON_H;
		};
		class SUI_ShopList: RscListbox
		{
			idc = 1501;
			x = R_GROUP_X;
			y = GROUP_Y;
			w = LISTBOX_W;
			h = LISTBOX_H;
			shadow = 1;
			rowHeight = 2.0 * RIBBON_H;
		};
		class SUI_PlayerMoneyText: RscText
		{
			idc = 1000;
			text = "$€1,100,100";
			x = L_GROUP_X;
			y = MONEY_RIBBON_Y;
			w = RIBBON_W;
			h = RIBBON_H;
			colorBackground[] = {0,0,0,1};
		};
		class SUI_ShopMoneyText: RscText
		{
			idc = 1001;
			text = "$1.100.100";
			x = R_GROUP_X;
			y = MONEY_RIBBON_Y;
			w = RIBBON_W;
			h = RIBBON_H;
			colorBackground[] = {0,0,0,1};
		};
		class SUI_PlayerDropdown: RscCombo
		{
			idc = 2100;
			x = L_GROUP_X;
			y = BUTTON_RIBBON_Y;
			w = DROPDOWN_W;
			h = RIBBON_H;
		};
		class SUI_ShopDropdown: RscCombo
		{
			idc = 2101;
			x = R_GROUP_X;
			y = BUTTON_RIBBON_Y;
			w = DROPDOWN_W;
			h = RIBBON_H;
		};
		class SUI_PlayerX1Button: RscButton
		{
			idc = 1600;
			text = "x1"; //--- ToDo: Localize;
			x = L_GROUP_X + DROPDOWN_W + RIBBON_SPACE_X;
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		class SUI_PlayerX10Button: RscButton
		{
			idc = 1601;
			text = "x10"; //--- ToDo: Localize;
			x = L_GROUP_X + DROPDOWN_W + BUTTON_W + (2 * RIBBON_SPACE_X);
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		class SUI_PlayerAllButton: RscButton
		{
			idc = 1602;
			text = "All"; //--- ToDo: Localize;
			x = L_GROUP_X + DROPDOWN_W + (2 * BUTTON_W) + (3 * RIBBON_SPACE_X);
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		class SUI_ShopX1Button: RscButton
		{
			idc = 1603;
			text = "x1"; //--- ToDo: Localize;
			x = R_GROUP_X + DROPDOWN_W + RIBBON_SPACE_X;
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		class SUI_ShopX10Button: RscButton
		{
			idc = 1604;
			text = "x10"; //--- ToDo: Localize;
			x = R_GROUP_X + DROPDOWN_W + BUTTON_W + (2 * RIBBON_SPACE_X);
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		class SUI_ShopAllButton: RscButton
		{
			idc = 1605;
			text = "All"; //--- ToDo: Localize;
			x = R_GROUP_X + DROPDOWN_W + (2 * BUTTON_W) + (3 * RIBBON_SPACE_X);
			y = BUTTON_RIBBON_Y;
			w = BUTTON_W;
			h = RIBBON_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////

    }
};

