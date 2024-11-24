//moved to imports.hpp
// import RscText;
// import RscActivePictureKeepAspect;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

//--- userPlanshetMainMenu
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001

#define IDC_BUTTON_01 1200
#define IDC_BUTTON_02 1201
#define IDC_BUTTON_03 1202
#define IDC_BUTTON_04 1203
#define IDC_BUTTON_05 1204
#define IDC_BUTTON_06 1205


////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Wytoco)
////////////////////////////////////////////////////////

class UPMM_TextLeft: RscText
{
	idc = IDC_TEXT_LEFT;
	text = "";
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 12 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPMM_TextRight: RscText
{
	idc = IDC_TEXT_RIGHT;
	style = 1;//1: align right
	text = "";
	x = 3.5 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 11.5 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPMM_ButtonCommon: RscActivePictureKeepAspect
{
	w = 4 * UI_GRID_W;
	h = 4 * UI_GRID_H;
};
class UPMM_Button01: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_01;
	x = -9.5 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_Button02: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_02;
	x = -2 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_Button03: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_03;
	x = 5.5 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_Button04: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_04;
	x = -9.5 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_Button05: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_05;
	x = -2 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_Button06: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_06;
	x = 5.5 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
