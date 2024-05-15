class VD_RscEdit {
	type = 2;
	style = 0x00 + 0x40;
	font = "RobotoCondensed";
	shadow = 2;
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorBackground[] = {0, 0, 0, 1};
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	colorText[] = {0.95, 0.95, 0.95, 1};
	colorDisabled[] = {1, 1, 1, 0.25};
	autocomplete = false;
	colorSelection[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", 1};
	canModify = 1;
};

class VD_RscListBox {
	style = 16;
	idc = -1;
	type = 5;
	w = 0.275;
	h = 0.04;
	font = "RobotoCondensed";
	colorSelect[] = {1, 1, 1, 1};
	colorText[] = {1, 1, 1, 1};
	colorBackground[] = {0.28,0.28,0.28,0.28};
	colorSelect2[] = {1, 1, 1, 1};
	colorSelectBackground[] = {0.95, 0.95, 0.95, 0.5};
	colorSelectBackground2[] = {1, 1, 1, 0.5};
	colorScrollbar[] = {0.2, 0.2, 0.2, 1};
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,1};
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	wholeHeight = 0.45;
	rowHeight = 0.04;
	color[] = {0.7, 0.7, 0.7, 1};
	colorActive[] = {0,0,0,1};
	colorDisabled[] = {0,0,0,0.3};
	sizeEx = 0.023;
	soundSelect[] = {"",0.1,1};
	soundExpand[] = {"",0.1,1};
	soundCollapse[] = {"",0.1,1};
	maxHistoryDelay = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	
	class ListScrollBar {
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		shadow = 0;
		scrollSpeed = 0.06;
		width = 0;
		height = 0;
		autoScrollEnabled = 1;
		autoScrollSpeed = -1;
		autoScrollDelay = 5;
		autoScrollRewind = 0;
	}
};

class VD_RscCheckBox {
	access = 0; // Control access (0 - ReadAndWrite, 1 - ReadAndCreate, 2 - ReadOnly, 3 - ReadOnlyVerified)
	idc = -1; // Control identification (without it, the control won't be displayed)
	type = 77; // Type
	style = 0x00 + 0x10; // Style
	default = 0; // Control selected by default (only one within a display can be used)
	blinkingPeriod = 0; // Time in which control will fade out and back in. Use 0 to disable the effect.

	x = 0;
	y = 0;
	w = 1 * (((safezoneW / safezoneH) min 1.2) / 40); // Width
	h = 1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25); // Height

	//Colors
	color[] = { 1, 1, 1, 0.7 }; // Texture color
	colorFocused[] = { 1, 1, 1, 1 }; // Focused texture color
	colorHover[] = { 1, 1, 1, 1 }; // Mouse over texture color
	colorPressed[] = { 1, 1, 1, 1 }; // Mouse pressed texture color
	colorDisabled[] = { 1, 1, 1, 0.2 }; // Disabled texture color

	//Background colors
	colorBackground[] = { 0, 0, 0, 0 }; // Fill color
	colorBackgroundFocused[] = { 0, 0, 0, 0 }; // Focused fill color
	colorBackgroundHover[] = { 0, 0, 0, 0 }; // Mouse hover fill color
	colorBackgroundPressed[] = { 0, 0, 0, 0 }; // Mouse pressed fill color
	colorBackgroundDisabled[] = { 0, 0, 0, 0 }; // Disabled fill color

	//Textures
	textureChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";		//Texture of checked CheckBox.
	textureUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";		//Texture of unchecked CheckBox.
	textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";	//Texture of checked focused CheckBox (Could be used for showing different texture when focused).
	textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";	//Texture of unchecked focused CheckBox.
	textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";

	tooltip = ""; // Tooltip text
	tooltipColorShade[] = { 0, 0, 0, 1 }; // Tooltip background color
	tooltipColorText[] = { 1, 1, 1, 1 }; // Tooltip text color
	tooltipColorBox[] = { 1, 1, 1, 1 }; // Tooltip frame color

	//Sounds
	soundClick[] = { "\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1 }; // Sound played after control is activated in format {file, volume, pitch}
	soundEnter[] = { "\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1 }; // Sound played when mouse cursor enters the control
	soundPush[] = { "\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1 }; // Sound played when the control is pushed down
	soundEscape[] = { "\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1 }; // Sound played when the control is released after pushing down
};

class VD_RscXSliderH {
	style = 1024;
	type = 43;
	shadow = 2;
	x = 0;
	y = 0;
	h = 0.029412;
	w = 0.400000;
	color[] = {
			1, 1, 1, 0.7
	};
	colorActive[] = {
			1, 1, 1, 1
	};
	colorDisabled[] = {
			1, 1, 1, 0.500000
	};
	arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
	thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
};

class VD_RscText {
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	type = 0;
	style = 0;
	shadow = 1;
	colorShadow[] = {0, 0, 0, 0.5};
	font = "RobotoCondensed";
	SizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	text = "";
	colorText[] = {1, 1, 1, 1.0};
	colorBackground[] = {0, 0, 0, 0};
	linespacing = 1;
};

class VD_RscTitle:VD_RscText {
	style = 0;
	shadow = 0;
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorText[] = {0.95, 0.95, 0.95, 1};
};

class VD_RscShortcutButton {
	idc = -1;
	style = 0;
	default = 0;
	shadow = 1;
	w = 0.183825;
	h = "(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20)";
	color[] = {1,1,1,1.0};
	colorFocused[] = {1,1,1,1.0};
	color2[] = {0.95,0.95,0.95,1};
	colorDisabled[] = {1,1,1,0.25};
	colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])",1};
	colorBackgroundFocused[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])",1};
	colorBackground2[] = {1,1,1,1};
	animTextureDefault = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureNormal = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureDisabled = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureOver = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\over_ca.paa";
	animTextureFocused = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\focus_ca.paa";
	animTexturePressed = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\down_ca.paa";
	periodFocus = 1.2;
	periodOver = 0.8;
	class HitZone
	{
		left = 0.0;
		top = 0.0;
		right = 0.0;
		bottom = 0.0;
	};
	class ShortcutPos
	{
		left = 0;
		top = "(			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		w = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4)";
		h = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class TextPos
	{
		left = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4)";
		top = "(			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		right = 0.005;
		bottom = 0.0;
	};
	period = 0.4;
	font = "RobotoCondensed";
	size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	text = "";
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	action = "";
	class Attributes
	{
		font = "RobotoCondensed";
		color = "#E5E5E5";
		align = "left";
		shadow = "true";
	};
	class AttributesImage
	{
		font = "RobotoCondensed";
		color = "#E5E5E5";
		align = "left";
	};	
};

class VD_RscControlsGroup {
	type = 15;
	idc = -1;
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	shadow = 0;
	style = 16;

	class ScrollBar {
		color[] = {1, 1, 1, 0.6};
		colorActive[] = {1, 1, 1, 1};
		colorDisabled[] = {1, 1, 1, 0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		shadow = 0;
		scrollSpeed = 0.05;
	};
	
	class VScrollbar:ScrollBar {
		width = 0.021;
		autoScrollSpeed = -1;
		autoScrollDelay = 5;
		autoScrollRewind = 0;
		shadow = 0;
		color[] = {1, 1, 1, 0.6};
	};
	
	class HScrollbar:ScrollBar {
		height = 0.028;
		shadow = 0;
		color[] = {1, 1, 1, 0.6};
	};
	
	//class ListScrollBar : ScrollBar {};
	
	class Controls {};
};

class VD_RscControlsGroupNoScrollbars : VD_RscControlsGroup {
	class VScrollbar : VScrollbar {
		width = 0;
	};
	
	class HScrollbar : HScrollbar {
		height = 0;
	};
};

class VD_RscButtonMenu:VD_RscShortcutButton {
	idc = -1;
	type = 16;
	style = "0x02 + 0xC0";
	default = 0;
	shadow = 0;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
	animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
	animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
	colorBackground[] = {0,0,0,0.8};
	colorBackgroundFocused[] = {1,1,1,1};
	colorBackground2[] = {0.75,0.75,0.75,1};
	color[] = {1,1,1,1};
	colorFocused[] = {0,0,0,1};
	color2[] = {0,0,0,1};
	colorText[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.25};
	period = 1.2;
	periodFocus = 1.2;
	periodOver = 1.2;
	size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	class TextPos
	{
		left = "0.25 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
		top = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		right = 0.005;
		bottom = 0.0;
	};
	class Attributes
	{
		font = "RobotoCondensed";
		color = "#E5E5E5";
		align = "left";
		shadow = "false";
	};
	class ShortcutPos
	{
		left = "(6.25 * 			(			((safezoneW / safezoneH) min 1.2) / 40)) - 0.0225 - 0.005";
		top = 0.005;
		w = 0.0225;
		h = 0.03;
	};
	soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
	textureNoShortcut = "";
};

class TAW_VDMenu {
	idd = 2900;
	name = "TAW_VDMenu";
	movingEnabled = 0;
	enableSimulation = 1;
	
	onLoad = "((_this select 0) displayCtrl 2999) ctrlSetFade 1; ((_this select 0) displayCtrl 2999) ctrlCommit 0;";
	onUnload = "call NWG_VD_OnMenuClose";

	class controlsBackground {
		class TitleBackground : VD_RscText {
			colorBackground[] = { "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])" };
			idc = -1;
			x = .3;
			y = .2;
			w = .5;
			h = (1 / 25);
		};

		class MainBackground : VD_RscText {
			colorBackground[] = { 0, 0, 0, .7 };
			idc = -1;
			x = .3;
			y = .2 + (11 / 250);
			w = .5;
			h = .615 - (22 / 250);
		};
		
		class Title : VD_RscTitle {
			colorBackround[] = { 0, 0, 0, 0 };
			idc = 1001;
			text = "Distance view settings";
			x = .3;
			y = .2;
			w = .8;
			h = (1 / 25);
		};

		class OnFootText : VD_RscText {
			idc = 1002;
			text = "Infantry:";
			x = .32;
			y = .258;
			w = .275;
			h = .04;
		};

		class inCarText : OnFootText {
			idc = 1003;
			text = "Ground:";
			y = .306;
		};

		class inAirText : OnFootText {
			idc = 1004;
			text = "Air:";
			y = .357;
		};

		class ObjectText : OnFootText {
			idc = 1005;
			text = "Object:";
			y = .707;
		};
		
		class DroneText : OnFootText {
			idc = 1006;
			text = "Drone:";
			y = .407;
		};

		class TerrainBackground : TitleBackground {
			idc = 1007;
			text = "Grass Settings";
			shadow = 0;
			y = .51;
		};

		class ObjectBackground : TitleBackground {
			idc = 1008;
			text = "Object Settings";
			y = .60;
		};

		class ButtonClose : VD_RscButtonMenu {
			idc = 1009;
			text = "Close";
			onButtonClick = "closeDialog 0";
			x = 0.3;
			y = 0.82 - (1 / 25);
			w = (6.25 / 40);
			h = (1 / 25);
		};
		
		class SaveManagerBtn:ButtonClose {
			idc = 1010;
			text = "Saves";
			onButtonClick = "call NWG_VD_OpenSaveManager";
			x = .465;
		};
	};

	class controls {

		//Sliders
		class VD_onFoot_slider : VD_RscXSliderH {
			idc = 2901;
			text = "";
			onSliderPosChanged = "[0,(_this#1)] call NWG_VD_OnSliderChange";
			toolTip = "View Distance while on foot";
			x = .42;
			y = .30 - (1 / 25);
			w = "9 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "1 * 			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};

		class VD_inCar_slider : VD_onFoot_slider {
			idc = 2911;
			toolTip = "View distance while in a ground vehicle";
			onSliderPosChanged = "[1,(_this#1)] call NWG_VD_OnSliderChange";
			y = .35 - (1 / 25);
		};

		class VD_inAir_slider : VD_onFoot_slider {
			idc = 2921;
			toolTip = "View distance while in an aircraft";
			onSliderPosChanged = "[2,(_this#1)] call NWG_VD_OnSliderChange";
			y = .40 - (1 / 25);
		};

		class VD_Object_slider : VD_onFoot_slider {
			idc = 2941;
			toolTip = "Object rendering distance";
			onSliderPosChanged = "[3,(_this#1)] call NWG_VD_OnSliderChange";
			y = .75 - (1 / 25);
		};
		
		class VD_Drone_slider:VD_onFoot_slider {
			idc = 2951;
			toolTip = "View distance while operating a UAV/UGV";
			onSliderPosChanged = "[4,(_this#1)] call NWG_VD_OnSliderChange";
			y = .45 - (1 / 25);
		}

		//Values (RscEdit fields)
		class VD_onFoot_Edit : VD_RscEdit {
			idc = 2902;
			text = "";
			onKeyUp = "[(_this#0),'ground'] call NWG_VD_OnFieldEdit";

			x = .7;
			y = .258;
			w = .08;
			h = .04;
		};

		class VD_inCar_Edit : VD_onFoot_Edit {
			idc = 2912;
			onKeyUp = "[(_this#0),'vehicle'] call NWG_VD_OnFieldEdit";
			y = .31;
		};

		class VD_inAir_Edit : VD_onFoot_Edit {
			idc = 2922;
			onKeyUp = "[(_this#0),'air'] call NWG_VD_OnFieldEdit";
			y = .36;
		};
		
		class VD_inDrone_Edit:VD_onFoot_Edit {
			idc = 2952;
			onKeyUp = "[(_this#0),'drone'] call NWG_VD_OnFieldEdit";
			y = .41;
		};

		class VD_Object_Edit : VD_onFoot_Edit {
			idc = 2942;
			onKeyUp = "[(_this#0),'object'] call NWG_VD_OnFieldEdit";
			y = .706;
		};

		//Grass Settings
		class VD_terrain_none {
			idc = 2950;
			type = 11;
			style = 0;
			font = "RobotoCondensed";
			color[] = { 1, 1, 1, 1 };
			colorActive[] = { 1, 0.2, 0.2, 1 };
			colorDisabled[] = {0, 0, 0, 1};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
			text = "Low";
			action = "'low' call NWG_VD_OnTerrainChanged;";
			sizeEx = 0.04;

			x = .355; y = .555;
			w = .275; h = .04;
		};

		class VD_terrain_low : VD_terrain_none {
			idc = 1011;
			text = "Normal";
			action = "'norm' call NWG_VD_OnTerrainChanged;";
			x = .44;
		};

		class VD_terrain_normal : VD_terrain_none {
			idc = 1012;
			text = "High";
			action = "'high' call NWG_VD_OnTerrainChanged;";
			x = .57;
		};

		class VD_terrain_high : VD_terrain_none {
			idc = 1013;
			text = "Ultra";
			action = "'ultra' call NWG_VD_OnTerrainChanged;";
			x = .67;
		};

		class ObjectSyncCheckbox : VD_RscCheckBox
		{
			idc = 2931;
			x = .32; y = .65;
			tooltip = "Sync object rendering with view rendering";
			onCheckedChanged = "_this call NWG_VD_OnObjectSyncChanged";
			w = 1 * (((safezoneW / safezoneH) min 1.2) / 40);
			h = 1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25); 
		};

		class ObjectSynctext : VD_RscText {
			idc = 1014;
			text = "Sync with view";
			x = .345; y = .651;
			w = .35; h = .04;
		};

		class TargetFPSCheckbox : VD_RscCheckBox
		{
			idc = 2932;
			x = .32; y = .5 - (1 / 25);
			tooltip = "Will dynamically change view distance to support desired FPS";
			onCheckedChanged = "_this call NWG_VD_OnTargetFPSChkBoxChanged";
			w = 1 * (((safezoneW / safezoneH) min 1.2) / 40);
			h = 1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25); 
		};

		class TargetFPStext : VD_RscText {
			idc = 1018;
			text = "Auto";
			x = .345; y = .5 - (1 / 25);
			w = .35; h = .04;
		};

		class TargetFPStext2 : TargetFPStext {
			idc = 1019;
			text = "-";
			x = .534;
		};

		class TargetFPStext3 : TargetFPStext {
			idc = 1020;
			text = "FPS:";
			x = .640;
		};

		class TargetFPSEditFPS : VD_onFoot_Edit {
			idc = 2962;
			onKeyUp = "(_this#0) call NWG_VD_OnTargetFPSFieldEdit";
			y = .5 - (1 / 25);
		};

		class TargetFPSEditMinDist : TargetFPSEditFPS {
			idc = 2963;
			onKeyUp = "(_this#0) call NWG_VD_OnTargetFPSMinDistFieldEdit";
			x = .455;
		};

		class TargetFPSEditMaxDist : TargetFPSEditFPS {
			idc = 2964;
			onKeyUp = "(_this#0) call NWG_VD_OnTargetFPSMaxDistFieldEdit";
			x = .555;
		};

		
		class Manager:VD_RscControlsGroup {
			idc = 2999;
			
			x = -0.21; y = .2;
			w = .5; h = 3;
			class Controls {
				class SaveLoadGroup:VD_RscControlsGroupNoScrollbars {
					idc = 3000;
					
					x = 0;
					y = 0;
					w = .5;
					h = 3;
					
					class Controls {
						class MyTitleBackground:VD_RscText {
							colorBackground[] = { "(profilenamespace getvariable ['GUI_BCG_RGB_R',0.3843])", "(profilenamespace getvariable ['GUI_BCG_RGB_G',0.7019])", "(profilenamespace getvariable ['GUI_BCG_RGB_B',0.8862])", "(profilenamespace getvariable ['GUI_BCG_RGB_A',0.7])" };
							idc = -1;
							x = 0;
							y = 0;
							w = .5;
							h = (1 / 25);
						};
						
						class Title : VD_RscTitle {
							colorBackround[] = { 0, 0, 0, 0 };
							idc = 1015;
							text = "Save Manager";
							x = 0;
							y = 0;
							w = .8;
							h = (1 / 25);
						};
						
						class MainBackground:VD_RscText {
							colorBackground[] = { 0, 0, 0, .7 };
							idc = -1;
							x = 0;
							y = 0 + (11 / 250);
							w = .5;
							h = .57 - (22 / 250);
						};
						
						class SaveList:VD_RscListBox {
							idc = 3001;
							sizeEx = 0.04;
							colorBackground[] = {0.1,0.1,0.1,0.9};
							x = 0; y = 0 + (11 / 250);
							w = .5; h = .49 - (22 / 250);
							
							onLBSelChanged = "_this call NWG_VD_OnSaveSelectionChanged";
						};
						
						class SaveSlotName:VD_onFoot_Edit {
							idc = 3002;
							text = "SAVE NAME";
							colorBackground[] = {0,0,0,0.6};
							onKeyUp = "";
							
							x = .025; y = .42 + (11 / 250);
							w = .45;
						};
						
						class SaveButton:VD_RscButtonMenu {
							idc = 1016;
							text = "Save";
							onButtonClick = "call NWG_VD_OnSaveManagerSave";
							x = 0;
							y = 0.57 - (1 / 25);
							w = (6.25 / 40);
							h = (1 / 25);
						};
						
						class HideButton:VD_RscButtonMenu {
							idc = 1017;
							text = "Hide";
							onButtonClick = "((findDisplay 2900) displayCtrl 2999) ctrlSetFade 1; ((findDisplay 2900) displayCtrl 2999) ctrlCommit 0.3;";
							x = .16;
							y = 0.57 - (1 / 25);
							w = (6.25 / 40);
							h = (1 / 25);
						};
					};
				};
			};
		};
	};
};