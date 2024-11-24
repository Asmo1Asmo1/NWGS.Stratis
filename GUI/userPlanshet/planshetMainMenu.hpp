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
#define IDC_TEXT_MONEY 20470
#define IDC_TEXT_INFO 20471
#define IDC_BUTTON_MOBLSHOP 20675
#define IDC_BUTTON_MTRANSFR 20670
#define IDC_BUTTON_GROUPMNG 20676
#define IDC_BUTTON_DOCMENTS 20672
#define IDC_BUTTON_PLR_INFO 20671
#define IDC_BUTTON_SETTINGS 20673


////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Wytoco)
////////////////////////////////////////////////////////

class UPMM_PlayerMoneyText: RscText
{
	idc = IDC_TEXT_MONEY;
	text = "";
	x = -15 * UI_GRID_W + UI_GRID_X;
	y = -9.5 * UI_GRID_H + UI_GRID_Y;
	w = 12 * UI_GRID_W;
	h = 1 * UI_GRID_H;
};
class UPMM_PlayerInfoText: RscText
{
	idc = IDC_TEXT_INFO;
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
class UPMM_MobileShopButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_MOBLSHOP;
	x = -9.5 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_MoneyTransferButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_MTRANSFR;
	x = -2 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_GroupManagementButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_GROUPMNG;
	x = 5.5 * UI_GRID_W + UI_GRID_X;
	y = -5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_DocumentsButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_DOCMENTS;
	x = -9.5 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_InfoButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_PLR_INFO;
	x = -2 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
class UPMM_SettingsButton: UPMM_ButtonCommon
{
	idc = IDC_BUTTON_SETTINGS;
	x = 5.5 * UI_GRID_W + UI_GRID_X;
	y = 2.5 * UI_GRID_H + UI_GRID_Y;
};
////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
