//moved to imports.hpp
// import RscText;
// import RscListbox;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

//--- userPlanshetUIBase
#define IDC_TEXT_MONEY 20470
#define IDC_TEXT_INFO 20471
#define IDC_LISTBOX_SECMENU	16418

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Kacege)
////////////////////////////////////////////////////////

class UPSM_PlayerMoneyText: RscText
{
	idc = IDC_TEXT_MONEY;
	text = "";
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 12 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPSM_PlayerInfoText: RscText
{
	idc = IDC_TEXT_INFO;
	style = 1;//1: align right
	text = "";
	x = 3.5 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 11.5 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPSM_ListBox: RscListbox
{
	idc = IDC_LISTBOX_SECMENU;
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
