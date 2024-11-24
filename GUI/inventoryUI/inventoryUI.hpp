//moved to imports.hpp
// import RscText;
// import RscActivePictureKeepAspect;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Synixy)
////////////////////////////////////////////////////////

class IUI_TextWeight: RscText
{
	idc = 1000;
	text = "17kg"; //--- ToDo: Localize;
	style = 1;
	x = 12.75 * UI_GRID_W + UI_GRID_X;
	y = 8.5 * UI_GRID_H + UI_GRID_Y;
	w = 3.5 * UI_GRID_W;
	h = 1.5 * UI_GRID_H;
};
class IUI_ButtonCommon: RscActivePictureKeepAspect
{
	w = 2.5 * UI_GRID_W;
	h = 2.5 * UI_GRID_H;
};
class IUI_ButtonWeaponSwitch: IUI_ButtonCommon
{
	idc = 1600;
	x = 17.2 * UI_GRID_W + UI_GRID_X;
	y = -5.7 * UI_GRID_H + UI_GRID_Y;
};
class IUI_ButtonLoot: IUI_ButtonCommon
{
	idc = 1601;
	x = -20.5 * UI_GRID_W + UI_GRID_X;
	y = -10.1 * UI_GRID_H + UI_GRID_Y;
};
class IUI_ButtonUniform: IUI_ButtonCommon
{
	idc = 1602;
	x = -20.5 * UI_GRID_W + UI_GRID_X;
	y = -7.1 * UI_GRID_H + UI_GRID_Y;
};
class IUI_ButtonMagRepack: IUI_ButtonCommon
{
	idc = 1603;
	x = -20.5 * UI_GRID_W + UI_GRID_X;
	y = -4.1 * UI_GRID_H + UI_GRID_Y;
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
