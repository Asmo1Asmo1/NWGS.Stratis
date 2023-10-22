
#define GRID_X	(0)
#define GRID_Y	(0)
#define GRID_W	(0.025)
#define GRID_H	(0.04)

class MRO_Base
{
	access = 0;
	type = 0;
	idc = -1;
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	font = "PuristaMedium";
	text = "";
};
class MRO_RscText : MRO_Base
{
	fixedWidth = 0;
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	style = 0;
	shadow = 1;
	colorShadow[] = {0,0,0,0.5};
	SizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	linespacing = 1;
};
class MRO_RscStructuredText : MRO_RscText
{
	type = 13;
	h = 0.035;
	w = 0.1;
	size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	class Attributes
	{
		font = "PuristaMedium";
		color = "#ffffff";
		align = "left";
		shadow = 1;
	};
};
class MRO_RscPicture : MRO_Base
{
	style = 48;
	font = "TahomaB";
	sizeEx = 0;
	lineSpacing = 0;
	fixedWidth = 0;
	shadow = 0;
	x = 0;
	y = 0;
	w = 0.2;
	h = 0.15;
};
class MRO_RscListBox : MRO_Base
{
	type = 5;
	w = 0.4;
	h = 0.4;
	rowHeight = 0;
	colorDisabled[] = {1,1,1,0.25};
	colorScrollbar[] = {1,0,0,0};
	colorSelect[] = {0,0,0,1};
	colorSelect2[] = {0,0,0,1};
	colorSelectBackground[] = {0.95,0.95,0.95,1};
	colorSelectBackground2[] = {1,1,1,0.5};
	soundSelect[] = 
	{
		"\A3\ui_f\data\sound\RscListbox\soundSelect",
		0.09,
		1
	};
	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
	class ListScrollBar
	{
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
	style = 16;
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	shadow = 0;
	colorShadow[] = {0,0,0,0.5};
	color[] = {1,1,1,1};
	period = 1.2;
	maxHistoryDelay = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
};
class MRO_RscActiveText : MRO_Base
{
	type = 11;
	color[] = {1,1,1,0.7};
	colorActive[] = {1,1,1,1};
	colorText[] = {1,1,1,0.7};
	soundClick[] = {"",0.1,1};
	soundEnter[] = {"",0.1,1};
	soundEscape[] = {"",0.1,1};
	soundPush[] = {"",0.1,1};
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};
class MRO_IGUIBack : MRO_Base
{
	idc = 124;
	style = 128;
	colorText[] = {0,0,0,0};
	sizeEx = 0;
	shadow = 0;
	x = 0.1;
	y = 0.1;
	w = 0.1;
	h = 0.1;
	colorbackground[] = 
	{
		"(profilenamespace getvariable ['IGUI_BCG_RGB_R',0])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_G',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_B',1])",
		"(profilenamespace getvariable ['IGUI_BCG_RGB_A',0.8])"
	};
};
class MRO_RscButtonMenu : MRO_Base
{
	type = 16;
	style = "0x02 + 0xC0";
	default = 0;
	shadow = 0;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
	animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureOver = "#(argb,8,8,3)color(1,1,1,0.5)";
	animTextureFocused = "#(argb,8,8,3)color(0,0,0,0.8)";
	animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDefault = "#(argb,8,8,3)color(0,0,0,0.8)";
	class HitZone
	{
		left = 0;
		top = 0;
		right = 0;
		bottom = 0;
	};
	colorFocused[] = {1,1,1,0.5};
	colorBackgroundFocused[] = {0,0,0,0.8};
	colorBackground[] = {0,0,0,0.8};
	colorBackground2[] = {1,1,1,0.5};
	color[] = {1,1,1,1};
	color2[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.25};
	period = 1.2;
	periodFocus = 1.2;
	periodOver = 1.2;
	size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	class TextPos
	{
		left = "0.25 * (((safezoneW / safezoneH) min 1.2) / 40)";
		top = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		right = 0.005;
		bottom = 0;
	};
	class Attributes
	{
		font = "PuristaLight";
		color = "#E5E5E5";
		align = "left";
		shadow = "false";
	};
	class ShortcutPos
	{
		left = "(6.25 * (((safezoneW / safezoneH) min 1.2) / 40)) - 0.0225 - 0.005";
		top = 0.005;
		w = 0.0225;
		h = 0.03;
	};
	soundEnter[] = 
	{
		"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",
		0.09,
		1
	};
	soundPush[] = 
	{
		"\A3\ui_f\data\sound\RscButtonMenu\soundPush",
		0.09,
		1
	};
	soundClick[] = 
	{
		"\A3\ui_f\data\sound\RscButtonMenu\soundClick",
		0.09,
		1
	};
	soundEscape[] = 
	{
		"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",
		0.09,
		1
	};
};
class MRO_RscControlsGroup
{
	class VScrollbar
	{
		color[] = {1,1,1,0};
		width = 0;
		autoScrollSpeed = -1;
		autoScrollDelay = 5;
		autoScrollRewind = 0;
		shadow = 0;
	};
	class HScrollbar
	{
		color[] = {1,1,1,0};
		height = 0;
		shadow = 0;
	};
	class ScrollBar
	{
		color[] = {1,1,1,0};
		colorActive[] = {1,1,1,0};
		colorDisabled[] = {1,1,1,0};
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
	type = 15;
	idc = -1;
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	shadow = 0;
	style = 16;
};
class MRO_RscCombo : MRO_Base
{
	type = 4;
	colorSelect[] = {0,0,0,1};
	colorBackground[] = {0,0,0,1};
	colorScrollbar[] = {1,0,0,1};
	soundSelect[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundSelect",
		0.1,
		1
	};
	soundExpand[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundExpand",
		0.1,
		1
	};
	soundCollapse[] = 
	{
		"\A3\ui_f\data\sound\RscCombo\soundCollapse",
		0.1,
		1
	};
	maxHistoryDelay = 1;
	class ComboScrollBar
	{
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
	style = "0x10 + 0x200";
	x = 0;
	y = 0;
	w = 0.12;
	h = 0.035;
	shadow = 0;
	colorSelectBackground[] = {1,1,1,0.7};
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	wholeHeight = 0.45;
	color[] = {1,1,1,1};
	colorActive[] = {1,0,0,1};
	colorDisabled[] = {1,1,1,0.25};
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};



class MagRepack_Dialog_Main
{
	idd = -1;
	movingenable = false;
	onLoad = "uiNamespace setVariable ['MRO_Dialog_Main', (_this#0)]";
	onUnload = "call MRO_OnDialogDestroy";
	onMouseButtonUp = "call MRO_OnMouseButtonUp";
	
	class Controls
	{
		class MR_BG_ListBox: MRO_IGUIBack
		{
			idc = 2200;
			
			x = 4.25 * GRID_W + GRID_X;
			y = 2.5 * GRID_H + GRID_Y;
			w = 14 * GRID_W;
			h = 15.75 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_BG_Main: MRO_IGUIBack
		{
			idc = 2201;

			x = 18.5 * GRID_W + GRID_X;
			y = 2 * GRID_H + GRID_Y;
			w = 18 * GRID_W;
			h = 14.5 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_BG_LeftBorder: MRO_IGUIBack
		{
			idc = 2955;

			x = 3.7 * GRID_W + GRID_X;
			y = 2.75 * GRID_H + GRID_Y;
			w = 0.25 * GRID_W;
			h = 15.25 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_BG_BottomBorder: MRO_IGUIBack
		{
			idc = 2956;

			x = 8.5 * GRID_W + GRID_X;
			y = 18.5 * GRID_H + GRID_Y;
			w = 8.5 * GRID_W;
			h = 0.25 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_MainTitle: MRO_RscStructuredText
		{
			idc = 1001;

			x = 19 * GRID_W + GRID_X;
			y = 0.75 * GRID_H + GRID_Y;
			w = 12.5 * GRID_W;
			h = 1 * GRID_H;
			colorBackground[] = {0,0,0,1};
		};
		class MR_MagListTitle: MRO_RscStructuredText
		{
			idc = 1000;

			x = 7.75 * GRID_W + GRID_X;
			y = 1.25 * GRID_H + GRID_Y;
			w = 10 * GRID_W;
			h = 1 * GRID_H;
			colorBackground[] = {0,0,0,1};
			
			class Attributes
			{
				align = "right";
			};
		};
		class MR_SourceBox: MRO_IGUIBack
		{
			idc = 2208;

			x = 19 * GRID_W + GRID_X;
			y = 3.5 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 4 * GRID_H;
			colorBackground[] = {1,1,1,0.1};
		};
		class MR_FG_Source: MRO_RscPicture
		{
			idc = 2210;

			x = 19.5 * GRID_W + GRID_X;
			y = 4 * GRID_H + GRID_Y;
			w = 16 * GRID_W;
			h = 3 * GRID_H;
		};
		class MR_TargetBox: MRO_IGUIBack
		{
			idc = 2214;

			x = 19 * GRID_W + GRID_X;
			y = 8 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 4 * GRID_H;
			colorBackground[] = {1,1,1,0.1};
		};
		class MR_FG_Target: MRO_RscPicture
		{
			idc = 2211;

			x = 19.5 * GRID_W + GRID_X;
			y = 8.5 * GRID_H + GRID_Y;
			w = 16 * GRID_W;
			h = 3 * GRID_H;
		};
		class MR_BG_SourceText: MRO_RscText
		{
			idc = 1005;
			style = 1;

			x = 19 * GRID_W + GRID_X;
			y = 3 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 0.5 * GRID_H;
			colorBackground[] = {0,0,0,1};
			sizeEx = 0.8 * GRID_H;
		};
		class MR_SourceText: MRO_RscText
		{
			idc = 1002;
			style = 0;

			x = 19 * GRID_W + GRID_X;
			y = 2.8125 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 0.75 * GRID_H;
			colorBackground[] = {0,0,0,0};
			sizeEx = 0.75 * GRID_H;
		};
		class MR_BG_TargetText: MRO_RscText
		{
			idc = 1003;
			style = 1;

			x = 19 * GRID_W + GRID_X;
			y = 12 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 0.5 * GRID_H;
			colorBackground[] = {0,0,0,1};
			sizeEx = 0.8 * GRID_H;
		};
		class MR_TargetText: MRO_RscText
		{
			idc = 1004;
			style = 1;

			x = 19 * GRID_W + GRID_X;
			y = 11.8125 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 0.75 * GRID_H;
			colorBackground[] = {0,0,0,0};
			sizeEx = 0.75 * GRID_H;
		};
		class MR_SourcePic: MRO_RscPicture
		{
			idc = 1201;

			x = 20 * GRID_W + GRID_X;
			y = 4 * GRID_H + GRID_Y;
			w = 3.5 * GRID_W;
			h = 3 * GRID_H;
		};
		class MR_SourceInfo: MRO_RscStructuredText
		{
			idc = 1100;

			x = 23 * GRID_W + GRID_X;
			y = 4.25 * GRID_H + GRID_Y;
			w = 12.5 * GRID_W;
			h = 2.5 * GRID_H;
			sizeEx = 0.65 * GRID_H;
		};
		class MR_TargetPic: MRO_RscPicture
		{
			idc = 1203;

			x = 31.5 * GRID_W + GRID_X;
			y = 8.5 * GRID_H + GRID_Y;
			w = 3.5 * GRID_W;
			h = 3 * GRID_H;
		};
		class MR_TargetInfo: MRO_RscStructuredText
		{
			idc = 1101;
	
			x = 19.5 * GRID_W + GRID_X;
			y = 8.75 * GRID_H + GRID_Y;
			w = 12.5 * GRID_W;
			h = 2.5 * GRID_H;
			sizeEx = 0.65 * GRID_H;
		};
		class MR_SourceListBox: MRO_RscListBox
		{
			idc = 1501;
			canDrag = 1;
			rowHeight = 3 * GRID_H;
			onLBDrag = "(_this + ['source']) call MRO_OnDrag";
			onMouseButtonClick = "if ((_this#1) == 1) then {'source' call MRO_OnRmbClick}";//Clear on RMB click
			
			x = 19.5 * GRID_W + GRID_X;
			y = 4 * GRID_H + GRID_Y;
			w = 16 * GRID_W;
			h = 3 * GRID_H;
			sizeEx = 0.65 * GRID_H;
			
			colorText[] = {0,0,0,0};
			colorDisabled[] = {0,0,0,0};
			colorScrollbar[] = {0,0,0,0};
			colorSelect[] = {0,0,0,0};
			colorSelect2[] = {0,0,0,0};
			colorSelectBackground[] = {0,0,0,0};
			colorSelectBackground2[] = {0,0,0,0};
			colorBackground[] = {0,0,0,0};
		};
		class MR_TargetListBox: MRO_RscListBox
		{
			idc = 1502;
			canDrag = 1;
			rowHeight = 3 * GRID_H;
			onLBDrag = "(_this + ['target']) call MRO_OnDrag";
			onMouseButtonClick = "if ((_this#1) == 1) then {'target' call MRO_OnRmbClick}";//Clear on RMB click
			
			x = 19.5 * GRID_W + GRID_X;
			y = 8.5 * GRID_H + GRID_Y;
			w = 16 * GRID_W;
			h = 3 * GRID_H;
			sizeEx = 0.65 * GRID_H;
			
			colorText[] = {0,0,0,0};
			colorDisabled[] = {0,0,0,0};
			colorScrollbar[] = {0,0,0,0};
			colorSelect[] = {0,0,0,0};
			colorSelect2[] = {0,0,0,0};
			colorSelectBackground[] = {0,0,0,0};
			colorSelectBackground2[] = {0,0,0,0};
			colorBackground[] = {0,0,0,0};
		};
		class MR_SourceArea: MRO_IGUIBack
		{
			idc = 2215;
			onLBDrop = "(_this + ['source']) call MRO_OnDrop; true";
			
			x = 19 * GRID_W + GRID_X;
			y = 3.5 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 4 * GRID_H;
			colorBackground[] = {0,0,0,0};
			tooltipColorBox[] = {0,0,0,0};
		};
		class MR_TargetArea: MRO_IGUIBack
		{
			idc = 2216;
			onLBDrop = "(_this + ['target']) call MRO_OnDrop; true";

			x = 19 * GRID_W + GRID_X;
			y = 8 * GRID_H + GRID_Y;
			w = 17 * GRID_W;
			h = 4 * GRID_H;
			colorBackground[] = {0,0,0,0};
			tooltipColorBox[] = {0,0,0,0};
		};
		class MR_BG_ComboBox: MRO_IGUIBack
		{
			idc = 15000;
			
			x = 4.75 * GRID_W + GRID_X;
			y = 3.8 * GRID_H + GRID_Y;
			w = 13.5 * GRID_W;
			h = 13.95 * GRID_H;
			colorBackground[] = {0,0,0,0.35};
		};
		class MR_MagListBox: MRO_RscListBox
		{
			idc = 1500;
			type = 5; // Type 102 (ListNbox) is not draggable in 1.48 - GiPPO
			canDrag = 1;
			columns[] = {0.12,-0.01,0.006,0.83};
			rowHeight = 1.45 * GRID_H;
			drawSideArrows = 0;
			idcLeft = -1;
			idcRight = -1;
			onLBDrag = "(_this + ['list']) call MRO_OnDrag";
			
			x = 4.75 * GRID_W + GRID_X;
			y = 4 * GRID_H + GRID_Y;
			w = 13 * GRID_W;
			h = 13.6 * GRID_H;
			sizeEx = 0.7 * GRID_H;
		};
		class MR_MagListBoxArea: MRO_IGUIBack
		{
			idc = 2217;
			onLBDrop = "(_this + ['list']) call MRO_OnDrop; true";
			
			x = 4.75 * GRID_W + GRID_X;
			y = 3.8 * GRID_H + GRID_Y;
			w = 13.5 * GRID_W;
			h = 13.95 * GRID_H;
			colorBackground[] = {0,0,0,0};
		};
		class MR_MagListCombo: MRO_RscCombo
		{
			idc = 22170;
			onLBSelChanged = "_this call MRO_OnSelectionChange";
			
			x = 4.75 * GRID_W + GRID_X;
			y = 3 * GRID_H + GRID_Y;
			w = 13.5 * GRID_W;
			h = 0.8 * GRID_H;
			
			sizeEx = 0.75 * GRID_H;
		};
		class MR_PB_SourceAmmo: MRO_RscControlsGroup
		{
			idc = 2218;
			x = 19.5 * GRID_W + GRID_X;
			y = 4 * GRID_H + GRID_Y;
			w = 0.5 * GRID_W;
			h = 3 * GRID_H;
			
			class Controls
			{
				class MR_SourceAmmo: MRO_IGUIBack
				{
					idc = 22180;
					x = 0 * GRID_W + GRID_X;
					y = 3 * GRID_H + GRID_Y;
					w = 0.5 * GRID_W;
					h = 3 * GRID_H;
					colorBackground[] = {1,1,1,1};
				};
			};
		};
		class MR_PB_TargetAmmo: MRO_RscControlsGroup
		{
			idc = 2219;
			x = 35 * GRID_W + GRID_X;
			y = 8.5 * GRID_H + GRID_Y;
			w = 0.5 * GRID_W;
			h = 3 * GRID_H;
			
			class Controls
			{
				class MR_TargetAmmo: MRO_IGUIBack
				{
					idc = 22190;
					x = 0 * GRID_W + GRID_X;
					y = 3 * GRID_H + GRID_Y;
					w = 0.5 * GRID_W;
					h = 3 * GRID_H;
					colorBackground[] = {1,1,1,1};
				};
			};
		};
		class MR_BG_RepackProgress: MRO_IGUIBack
		{
			idc = 10005;
			
			x = 20.875 * GRID_W + GRID_X;
			y = 13.875 * GRID_H + GRID_Y;
			w = 13.3125 * GRID_W;
			h = 1.25 * GRID_H;
			colorBackground[] = {0,0,0,0.9};
		};
		class MR_PB_Repack: MRO_RscControlsGroup
		{
			idc = 10000;
			
			x = 21 * GRID_W + GRID_X;
			y = 14 * GRID_H + GRID_Y;
			w = 13 * GRID_W;
			h = 1 * GRID_H;
			
			class Controls
			{
				class MR_BG_RepackProgress: MRO_IGUIBack
				{
					idc = 10001;
					
					x = 0 * GRID_W + GRID_X;
					y = 0 * GRID_H + GRID_Y;
					w = 13 * GRID_W;
					h = 1 * GRID_H;
					colorBackground[] = {1,1,1,0.2};
				};
				class MR_RepackProgress: MRO_IGUIBack
				{
					idc = 10002;
					
					x = -13 * GRID_W + GRID_X;
					y = 0 * GRID_H + GRID_Y;
					w = 13 * GRID_W;
					h = 1 * GRID_H;
					colorBackground[] = {1,1,1,0.275};
				};
			};
		};
		class MR_RepackingText: MRO_RscText
		{
			idc = 1008;
			x = 25 * GRID_W + GRID_X;
			y = 14 * GRID_H + GRID_Y;
			w = 7 * GRID_W;
			h = 1 * GRID_H;
		};
		class MR_ButtonClose: MRO_RscActiveText
		{
			idc = 2499;
			style = 48;
			text = "\A3\Ui_f\data\GUI\Rsc\RscDisplayArcadeMap\icon_exit_cross_ca.paa";
			tooltip = "Close";
			action = "closeDialog 0";
			colorDisabled[] = {0,0,0,0};
			
			x = 35.625 * GRID_W + GRID_X;
			y = 2.125 * GRID_H + GRID_Y;
			w = 0.76 * GRID_W;
			h = 0.75 * GRID_H;
			
			default = false;
		};
		class MR_ButtonOptions: MRO_RscButtonMenu
		{
			idc = 2400;
			
			action = "call MRO_OnToggleFullMags";
			x = 18.5 * GRID_W + GRID_X;
			y = 16.75 * GRID_H + GRID_Y;
			w = 6.5 * GRID_W;
			h = 1 * GRID_H;
		};
		class MR_Options_Border_Top: MRO_IGUIBack
		{
			idc = 8997;

			x = 36.75 * GRID_W + GRID_X;
			y = 5.75 * GRID_H + GRID_Y;
			w = 0.25 * GRID_W;
			h = 3 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_Options_Border_Bottom: MRO_IGUIBack
		{
			idc = 8998;

			x = 36.75 * GRID_W + GRID_X;
			y = 13.25 * GRID_H + GRID_Y;
			w = 0.25 * GRID_W;
			h = 1.5 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
		class MR_Options_Border: MRO_IGUIBack
		{
			idc = 8999;

			x = 36.75 * GRID_W + GRID_X;
			y = 8.75 * GRID_H + GRID_Y;
			w = 0.25 * GRID_W;
			h = 4.5 * GRID_H;
			colorBackground[] = {0,0,0,0.75};
		};
	};
};