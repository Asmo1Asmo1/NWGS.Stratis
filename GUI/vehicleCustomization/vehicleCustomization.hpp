//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"

//moved to imports.hpp
// import RscListbox;

//--- scale helpers
#define LISTBOX_W (0.385 * X_SCALE)
#define LISTBOX_H (0.82 * Y_SCALE)
// #define RIBBON_W (LISTBOX_W)
#define RIBBON_H (0.025 * Y_SCALE)
// #define RIBBON_SPACE_X (0.01 * X_SCALE)
// #define RIBBON_SPACE_Y (0.01 * Y_SCALE)
// #define DROPDOWN_W (0.5 * RIBBON_W)
// #define BUTTON_W ((DROPDOWN_W / 3) - RIBBON_SPACE_X)

//--- position helpers
#define L_GROUP_X (FROM_CENTER(1.425 * X_SCALE))
#define R_GROUP_X ((FROM_CENTER(-1.425 * X_SCALE)) - LISTBOX_W)
#define GROUP_Y (FROM_CENTER(0.77 * Y_SCALE))
// #define MONEY_RIBBON_Y (GROUP_Y - (2 * RIBBON_H) - (2 * RIBBON_SPACE_Y))
// #define BUTTON_RIBBON_Y (GROUP_Y - RIBBON_H - RIBBON_SPACE_Y)


class vehicleCustomization {
    idd = 7100;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Rifoga)
		////////////////////////////////////////////////////////

		class VCUI_LeftBox: RscListbox
		{
			idc = 1500;
			x = L_GROUP_X;
			y = GROUP_Y;
			w = LISTBOX_W;
			h = LISTBOX_H;
			shadow = 1;
			rowHeight = 2.5 * RIBBON_H;
		};
		class VCUI_RightBox: RscListbox
		{
			idc = 1501;
			x = R_GROUP_X;
			y = GROUP_Y;
			w = LISTBOX_W;
			h = LISTBOX_H;
			shadow = 1;
			rowHeight = 2.5 * RIBBON_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
    }
};