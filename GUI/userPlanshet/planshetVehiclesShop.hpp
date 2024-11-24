/*
    Unholy combination of planshetSecondaryMenu.hpp and shopUI.hpp
*/
//moved to imports.hpp
// import RscText;
// import RscListbox;
// import RscCombo;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

//--- userPlanshetUIBase
#define IDC_SHOPUI_PLAYERMONEYTEXT 1000
#define IDC_SHOPUI_SHOPDROPDOWN 2101
#define IDC_SHOPUI_SHOPLIST 1501

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Kacege)
////////////////////////////////////////////////////////

class UPVS_PlayerMoneyText: RscText
{
	idc = IDC_SHOPUI_PLAYERMONEYTEXT;
	text = "";
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 12 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPVS_ShopDropdown: RscCombo
{
	idc = IDC_SHOPUI_SHOPDROPDOWN;
	style = 1;//1: align right
	x = 4 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 11 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPVS_ShopList: RscListbox
{
	idc = IDC_SHOPUI_SHOPLIST;
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -8 * UI_GRID_H + UI_GRID_Y;
	w = 30 * UI_GRID_W;
	h = 17 * UI_GRID_H;
	rowHeight = 2.0 * UI_GRID_H;
	colorBackground[] = {0,0,0,0.1};
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
