//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"
// #include "planshet.hpp"

//moved to imports.hpp
// import RscPicture;

//--- userPlanshetBackground IDCs
#define IDC_PLANSHET_BACKGROUND 7102
#define BACKGROUND_DIALOGUE_NAME "planshetBackground"

//--- scale helpers
#define RUGGED_CORNER_W (0.16 * X_SCALE)
#define RUGGED_CORNER_H (0.16 * Y_SCALE)
#define FRAME_W (0.065 * X_SCALE)
#define FRAME_H (0.065 * Y_SCALE)
#define FANCY_BAR_W (0.2 * BACKGROUND_W)
#define FANCY_BAR_H (0.05 * Y_SCALE)

//--- position helpers
#define RUGGED_LEFT_X   (BACKGROUND_X - (0.5 * RUGGED_CORNER_W))
#define RUGGED_RIGHT_X  (BACKGROUND_X + BACKGROUND_W - (0.5 * RUGGED_CORNER_W))
#define RUGGED_TOP_Y    (BACKGROUND_Y - (0.5 * RUGGED_CORNER_H))
#define RUGGED_BOTTOM_Y (BACKGROUND_Y + BACKGROUND_H - (0.5 * RUGGED_CORNER_H))

class UPBG_BaseRuggedCorner : RscPicture
{
    text = "#(argb,8,8,3)color(0.05,0.05,0.05,1)";
    w = RUGGED_CORNER_W;
    h = RUGGED_CORNER_H;
};

class planshetBackground {
    idd = 7102;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Somige)
		////////////////////////////////////////////////////////

		//Rugged corners (must be first to be rendered to appear behind everything else)
		class UPBG_RscPicture_1200: UPBG_BaseRuggedCorner
		{
			idc = 1200;
			x = RUGGED_LEFT_X;
			y = RUGGED_TOP_Y;
		};
		class UPBG_RscPicture_1201: UPBG_BaseRuggedCorner
		{
			idc = 1201;
			x = RUGGED_RIGHT_X;
			y = RUGGED_TOP_Y;
		};
		class UPBG_RscPicture_1202: UPBG_BaseRuggedCorner
		{
			idc = 1202;
			x = RUGGED_LEFT_X;
			y = RUGGED_BOTTOM_Y;
		};
		class UPBG_RscPicture_1203: UPBG_BaseRuggedCorner
		{
			idc = 1203;
			x = RUGGED_RIGHT_X;
			y = RUGGED_BOTTOM_Y;
		};

		//Display a.k.a background
		class UPBG_Background: RscPicture
		{
			idc = 1204;
			text = "#(argb,8,8,3)color(0.10,0.10,0.15,1)";
			x = BACKGROUND_X;
			y = BACKGROUND_Y;
			w = BACKGROUND_W;
			h = BACKGROUND_H;
		};

		//Planshet frame
		/*Left frame*/
		class UPBG_RscPicture_1205: RscPicture
		{
			idc = 1205;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_left_co.paa";
			x = (BACKGROUND_X - FRAME_W);
			y = BACKGROUND_Y;
			w = FRAME_W;
			h = BACKGROUND_H;
		};
		/*Right frame*/
		class UPBG_RscPicture_1206: RscPicture
		{
			idc = 1206;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_right_co.paa";
			x = (BACKGROUND_X + BACKGROUND_W);
			y = BACKGROUND_Y;
			w = FRAME_W;
			h = BACKGROUND_H;
		};
		/*Top frame*/
		class UPBG_RscPicture_1207: RscPicture
		{
			idc = 1207;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_top_co.paa";
			x = BACKGROUND_X;
			y = (BACKGROUND_Y - FRAME_H);
			w = BACKGROUND_W;
			h = FRAME_H;
		};
		/*Bottom frame*/
		class UPBG_RscPicture_1208: RscPicture
		{
			idc = 1208;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottom_co.paa";
			x = BACKGROUND_X;
			y = (BACKGROUND_Y + BACKGROUND_H);
			w = BACKGROUND_W;
			h = FRAME_H;
		};
		/*Top left corner*/
		class UPBG_RscPicture_1209: RscPicture
		{
			idc = 1209;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_topleftcorner_co.paa";
			x = (BACKGROUND_X - FRAME_W);
			y = (BACKGROUND_Y - FRAME_H);
			w = FRAME_W;
			h = FRAME_H;
		};
		/*Top right corner*/
		class UPBG_RscPicture_1210: RscPicture
		{
			idc = 1210;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_toprightcorner_co.paa";
			x = (BACKGROUND_X + BACKGROUND_W);
			y = (BACKGROUND_Y - FRAME_H);
			w = FRAME_W;
			h = FRAME_H;
		};
		/*Bottom left corner*/
		class UPBG_RscPicture_1211: RscPicture
		{
			idc = 1211;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottomleftcorner_co.paa";
			x = (BACKGROUND_X - FRAME_W);
			y = (BACKGROUND_Y + BACKGROUND_H);
			w = FRAME_W;
			h = FRAME_H;
		};
		/*Bottom right corner*/
		class UPBG_RscPicture_1212: RscPicture
		{
			idc = 1212;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottomrightcorner_co.paa";
			x = (BACKGROUND_X + BACKGROUND_W);
			y = (BACKGROUND_Y + BACKGROUND_H);
			w = FRAME_W;
			h = FRAME_H;
		};
		/*Top black bar (just for fancy)*/
		class UPBG_RscPicture_1213: RscPicture
		{
			idc = 1213;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_buttonbar_co.paa";
			x = FROM_CENTER(FANCY_BAR_W);
			y = (BACKGROUND_Y - (0.33 * FANCY_BAR_H));
			w = FANCY_BAR_W;
			h = FANCY_BAR_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
    };
};
