//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"
// #include "planshet.hpp"

//moved to imports.hpp
// import RscText;
// import RscListbox;

//--- userPlanshetUIBase IDCs
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001
#define IDC_LISTBOX	1501

//--- scale helpers
#define LISTBOX_W (BACKGROUND_W - (2 * OFFSET_X))
#define LISTBOX_H (BACKGROUND_H - TEXT_H - (2 * OFFSET_Y))

//--- position helpers
#define LISTBOX_X (BACKGROUND_X + OFFSET_X)
#define LISTBOX_Y (TEXT_Y + TEXT_H + OFFSET_Y)

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Kacege)
////////////////////////////////////////////////////////

class UPSM_TextLeft: RscText
{
	idc = IDC_TEXT_LEFT;
	text = "";
	x = TEXT_LEFT_X;
	y = TEXT_Y;
	w = TEXT_W;
	h = TEXT_H;
};
class UPSM_TextRight: RscText
{
	idc = IDC_TEXT_RIGHT;
	style = 1;//1: align right
	text = "";
	x = TEXT_RIGHT_X;
	y = TEXT_Y;
	w = TEXT_W;
	h = TEXT_H;
};
class UPSM_ListBox: RscListbox
{
	idc = IDC_LISTBOX;
	x = LISTBOX_X;
	y = LISTBOX_Y;
	w = LISTBOX_W;
	h = LISTBOX_H;
	rowHeight = TEXT_H;
	colorBackground[] = {0,0,0,0.1};
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
