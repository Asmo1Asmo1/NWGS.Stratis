//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"

//moved to imports.hpp
// import RscText;
// import RscActivePictureKeepAspect;

#define IUI_RIGHT_X -0.85
#define IUI_RIGHT_Y 0.274
#define IUI_LEFT_X 0.95
#define IUI_LEFT_Y 0.5
#define IUI_LEFT_Y_BETWEEN -0.125

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Tyheki)
////////////////////////////////////////////////////////
class IUI_ButtonCommon: RscActivePictureKeepAspect
{
	w = 0.05 * X_SCALE;
	h = 0.05 * Y_SCALE;
};

class IUI_ButtonWeaponSwitch: IUI_ButtonCommon
{
	idc = 1600;
	x = CENTER(1,(IUI_RIGHT_X * X_SCALE));
	y = CENTER(1,(IUI_RIGHT_Y * Y_SCALE));
};
class IUI_ButtonLoot: IUI_ButtonCommon
{
	idc = 1601;
	x = CENTER(1,(IUI_LEFT_X * X_SCALE));
	y = CENTER(1,(IUI_LEFT_Y * Y_SCALE));
};
class IUI_ButtonUniform: IUI_ButtonCommon
{
	idc = 1602;
	x = CENTER(1,(IUI_LEFT_X * X_SCALE));
	y = (CENTER(1,(IUI_LEFT_Y * Y_SCALE))) - (IUI_LEFT_Y_BETWEEN);
};
class IUI_ButtonMagRepack: IUI_ButtonCommon
{
	idc = 1603;
	x = CENTER(1,(IUI_LEFT_X * X_SCALE));
	y = (CENTER(1,(IUI_LEFT_Y * Y_SCALE))) - (2 * IUI_LEFT_Y_BETWEEN);
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////