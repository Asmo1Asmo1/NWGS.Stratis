//moved to imports.hpp
// import RscListbox;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

class vehicleCustomization {
    idd = 7100;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Rifoga)
		////////////////////////////////////////////////////////

		class VCUI_LeftBox: RscListbox
		{
			idc = 1500;
			x = -29 * UI_GRID_W + UI_GRID_X;
			y = -17 * UI_GRID_H + UI_GRID_Y;
			w = 13 * UI_GRID_W;
			h = 34 * UI_GRID_H;
			rowHeight = 2.5 * UI_GRID_H;
		};
		class VCUI_RightBox: RscListbox
		{
			idc = 1501;
			x = 16 * UI_GRID_W + UI_GRID_X;
			y = -17 * UI_GRID_H + UI_GRID_Y;
			w = 13 * UI_GRID_W;
			h = 34 * UI_GRID_H;
			rowHeight = 2.5 * UI_GRID_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
    }
};