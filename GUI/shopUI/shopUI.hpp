//moved to imports.hpp
// import RscListbox;
// import RscText;
// import RscButton;
// import RscCombo;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)


//--- shopUI (copy to shopUI.sqf)
#define IDC_SHOPUI_PLAYERMONEYTEXT	2367
#define IDC_SHOPUI_SHOPMONEYTEXT	2368
#define IDC_SHOPUI_PLAYERLIST	2867
#define IDC_SHOPUI_SHOPLIST	2868
#define IDC_SHOPUI_PLAYERX1BUTTON	2967
#define IDC_SHOPUI_PLAYERX10BUTTON	2968
#define IDC_SHOPUI_PLAYERALLBUTTON	2969
#define IDC_SHOPUI_SHOPX1BUTTON	2970
#define IDC_SHOPUI_SHOPX10BUTTON	2971
#define IDC_SHOPUI_SHOPALLBUTTON	2972
#define IDC_SHOPUI_PLAYERDROPDOWN	3467
#define IDC_SHOPUI_SHOPDROPDONW	3468

class shopUI {
    idd = 7101;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Difake)
		////////////////////////////////////////////////////////

		class PlayerList: RscListbox
		{
			idc = 1500;
			x = -29 * UI_GRID_W + UI_GRID_X;
			y = -15 * UI_GRID_H + UI_GRID_Y;
			w = 16 * UI_GRID_W;
			h = 32 * UI_GRID_H;
		};
		class ShopList: RscListbox
		{
			idc = 1501;
			x = 13 * UI_GRID_W + UI_GRID_X;
			y = -15 * UI_GRID_H + UI_GRID_Y;
			w = 16 * UI_GRID_W;
			h = 32 * UI_GRID_H;
		};
		class PlayerMoneyText: RscText
		{
			idc = 1000;
			text = "$1.100.100";
			x = -29 * UI_GRID_W + UI_GRID_X;
			y = -18 * UI_GRID_H + UI_GRID_Y;
			w = 16 * UI_GRID_W;
			h = 1 * UI_GRID_H;
			colorBackground[] = {0,0,0,1};
		};
		class ShopMoneyText: RscText
		{
			idc = 1001;
			text = "$1.100.100";
			x = 13 * UI_GRID_W + UI_GRID_X;
			y = -18 * UI_GRID_H + UI_GRID_Y;
			w = 16 * UI_GRID_W;
			h = 1 * UI_GRID_H;
			colorBackground[] = {0,0,0,1};
		};
		class PlayerX1Button: RscButton
		{
			idc = 1600;
			text = "x1"; //--- ToDo: Localize;
			x = -20 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class PlayerX10Button: RscButton
		{
			idc = 1601;
			text = "x10"; //--- ToDo: Localize;
			x = -17.5 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class PlayerAllButton: RscButton
		{
			idc = 1602;
			text = "All"; //--- ToDo: Localize;
			x = -15 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class PlayerDropdown: RscCombo
		{
			idc = 2100;
			x = -29 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 8.5 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class ShopDropdonw: RscCombo
		{
			idc = 2101;
			x = 13 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 8.5 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class ShopX1Button: RscButton
		{
			idc = 1603;
			text = "x1"; //--- ToDo: Localize;
			x = 22 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class ShopX10Button: RscButton
		{
			idc = 1604;
			text = "x10"; //--- ToDo: Localize;
			x = 24.5 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		class ShopAllButton: RscButton
		{
			idc = 1605;
			text = "All"; //--- ToDo: Localize;
			x = 27 * UI_GRID_W + UI_GRID_X;
			y = -16.5 * UI_GRID_H + UI_GRID_Y;
			w = 2 * UI_GRID_W;
			h = 1 * UI_GRID_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////

    }
};

