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
#define IDC_TEXT_LEFT 1000
#define IDC_DROPDOWN 2101
#define IDC_LISTBOX 1501

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Kacege)
////////////////////////////////////////////////////////

class UPSWD_TextLeft: RscText
{
	idc = IDC_TEXT_LEFT;
	text = "";
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 12 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPSWD_Dropdown: RscCombo
{
	idc = IDC_DROPDOWN;
	style = 1;//1: align right
	x = 4 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 11 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPSWD_ListBox: RscListbox
{
	idc = IDC_LISTBOX;
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
