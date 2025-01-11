//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"
// #include "planshet.hpp"

//moved to imports.hpp
// import RscText;
// import RscActivePictureKeepAspect;

//--- userPlanshetMainMenu IDCs
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001

#define IDC_BUTTON_01 1200
#define IDC_BUTTON_02 1201
#define IDC_BUTTON_03 1202
#define IDC_BUTTON_04 1203
#define IDC_BUTTON_05 1204
#define IDC_BUTTON_06 1205

//--- scale helpers
#define BUTTON_W (0.085 * X_SCALE)
#define BUTTON_H (0.085 * Y_SCALE)

//--- position helpers
#define BUTTON_COLUMN_1 ((BACKGROUND_X + (2 * (BACKGROUND_W / 8))) - (BUTTON_W / 2))
#define BUTTON_COLUMN_2 ((BACKGROUND_X + (4 * (BACKGROUND_W / 8))) - (BUTTON_W / 2))
#define BUTTON_COLUMN_3 ((BACKGROUND_X + (6 * (BACKGROUND_W / 8))) - (BUTTON_W / 2))
#define BUTTON_ROW_1 ((BACKGROUND_Y + (1 * (BACKGROUND_H / 3))) - (BUTTON_H / 2))
#define BUTTON_ROW_2 ((BACKGROUND_Y + (2 * (BACKGROUND_H / 3))) - (BUTTON_H / 2))


////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Wytoco)
////////////////////////////////////////////////////////

class UPMM_TextLeft: RscText
{
	idc = IDC_TEXT_LEFT;
	text = "";
	x = TEXT_LEFT_X;
	y = TEXT_Y;
	w = TEXT_W;
	h = TEXT_H;
};
class UPMM_TextRight: RscText
{
	idc = IDC_TEXT_RIGHT;
	style = 1;//1: align right
	text = "";
	x = TEXT_RIGHT_X;
	y = TEXT_Y;
	w = TEXT_W;
	h = TEXT_H;
};
class UPMM_ButtonCommon: RscActivePictureKeepAspect
{
	w = BUTTON_W;
	h = BUTTON_H;
};
class UPMM_Button01: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_01;
	x = BUTTON_COLUMN_1;
	y = BUTTON_ROW_1;
};
class UPMM_Button02: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_02;
	x = BUTTON_COLUMN_2;
	y = BUTTON_ROW_1;
};
class UPMM_Button03: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_03;
	x = BUTTON_COLUMN_3;
	y = BUTTON_ROW_1;
};
class UPMM_Button04: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_04;
	x = BUTTON_COLUMN_1;
	y = BUTTON_ROW_2;
};
class UPMM_Button05: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_05;
	x = BUTTON_COLUMN_2;
	y = BUTTON_ROW_2;
};
class UPMM_Button06: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_06;
	x = BUTTON_COLUMN_3;
	y = BUTTON_ROW_2;
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
