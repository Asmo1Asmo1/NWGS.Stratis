import RscText;
import RscButton;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

class inventoryUI {
    idd = 7200;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Vyratu)
		////////////////////////////////////////////////////////

		class TextWeight: RscText
		{
			idc = 1000;
			x = 11 * UI_GRID_W + UI_GRID_X;
			y = -13 * UI_GRID_H + UI_GRID_Y;
			w = 3.5 * UI_GRID_W;
			h = 1.5 * UI_GRID_H;
		};
		class ButtonLoot: RscButton
		{
			idc = 1600;
			x = -20 * UI_GRID_W + UI_GRID_X;
			y = -9 * UI_GRID_H + UI_GRID_Y;
			w = 2.9325 * UI_GRID_W;
			h = 2.2 * UI_GRID_H;
		};
		class ButtonWeaponSwitch: RscButton
		{
			idc = 1601;
			x = 16.5 * UI_GRID_W + UI_GRID_X;
			y = -4.5 * UI_GRID_H + UI_GRID_Y;
			w = 2.9325 * UI_GRID_W;
			h = 2.2 * UI_GRID_H;
		};
		class ButtonUniform: RscButton
		{
			idc = 1602;
			x = -20 * UI_GRID_W + UI_GRID_X;
			y = -6 * UI_GRID_H + UI_GRID_Y;
			w = 2.9325 * UI_GRID_W;
			h = 2.2 * UI_GRID_H;
		};
		class ButtonMagRepack: RscButton
		{
			idc = 1603;
			x = -20 * UI_GRID_W + UI_GRID_X;
			y = -3 * UI_GRID_H + UI_GRID_Y;
			w = 2.9325 * UI_GRID_W;
			h = 2.2 * UI_GRID_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////

    }
};