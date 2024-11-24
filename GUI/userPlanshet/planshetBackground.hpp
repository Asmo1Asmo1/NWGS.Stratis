//moved to imports.hpp
// import RscPicture;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

//--- userPlanshetBackground
#define IDC_PLANSHET_BACKGROUND 7102
#define BACKGROUND_DIALOGUE_NAME "planshetBackground"

class UPBG_BaseRuggedCorner : RscPicture
{
    text = "#(argb,8,8,3)color(0.05,0.05,0.05,1)";
    w = 4 * UI_GRID_W;
    h = 4 * UI_GRID_H;
};

class planshetBackground {
    idd = 7102;

    class controls {
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT START (by Asmo, v1.063, #Somige)
		////////////////////////////////////////////////////////

		class UPBG_RscPicture_1200: UPBG_BaseRuggedCorner
		{
			idc = 1200;
			x = -19.5 * UI_GRID_W + UI_GRID_X;
			y = -13.5 * UI_GRID_H + UI_GRID_Y;
		};
		class UPBG_RscPicture_1201: UPBG_BaseRuggedCorner
		{
			idc = 1201;
			x = 15.5 * UI_GRID_W + UI_GRID_X;
			y = -13.5 * UI_GRID_H + UI_GRID_Y;
		};
		class UPBG_RscPicture_1202: UPBG_BaseRuggedCorner
		{
			idc = 1202;
			x = -19.5 * UI_GRID_W + UI_GRID_X;
			y = 9.5 * UI_GRID_H + UI_GRID_Y;
		};
		class UPBG_RscPicture_1203: UPBG_BaseRuggedCorner
		{
			idc = 1203;
			x = 15.5 * UI_GRID_W + UI_GRID_X;
			y = 9.5 * UI_GRID_H + UI_GRID_Y;
		};
		class UPBG_RscPicture_1204: RscPicture
		{
			idc = 1204;
			text = "#(argb,8,8,3)color(0.10,0.10,0.15,1)";
			x = -16 * UI_GRID_W + UI_GRID_X;
			y = -10 * UI_GRID_H + UI_GRID_Y;
			w = 32 * UI_GRID_W;
			h = 20 * UI_GRID_H;
		};
		class UPBG_RscPicture_1205: RscPicture
		{
			idc = 1205;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_left_co.paa";
			x = -19 * UI_GRID_W + UI_GRID_X;
			y = -10 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 20 * UI_GRID_H;
		};
		class UPBG_RscPicture_1206: RscPicture
		{
			idc = 1206;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_right_co.paa";
			x = 16 * UI_GRID_W + UI_GRID_X;
			y = -10 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 20 * UI_GRID_H;
		};
		class UPBG_RscPicture_1207: RscPicture
		{
			idc = 1207;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_top_co.paa";
			x = -16 * UI_GRID_W + UI_GRID_X;
			y = -13 * UI_GRID_H + UI_GRID_Y;
			w = 32 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1208: RscPicture
		{
			idc = 1208;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottom_co.paa";
			x = -16 * UI_GRID_W + UI_GRID_X;
			y = 10 * UI_GRID_H + UI_GRID_Y;
			w = 32 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1209: RscPicture
		{
			idc = 1209;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_topleftcorner_co.paa";
			x = -19 * UI_GRID_W + UI_GRID_X;
			y = -13 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1210: RscPicture
		{
			idc = 1210;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_toprightcorner_co.paa";
			x = 16 * UI_GRID_W + UI_GRID_X;
			y = -13 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1211: RscPicture
		{
			idc = 1211;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottomleftcorner_co.paa";
			x = -19 * UI_GRID_W + UI_GRID_X;
			y = 10 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1212: RscPicture
		{
			idc = 1212;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_bottomrightcorner_co.paa";
			x = 16 * UI_GRID_W + UI_GRID_X;
			y = 10 * UI_GRID_H + UI_GRID_Y;
			w = 3 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		class UPBG_RscPicture_1213: RscPicture
		{
			idc = 1213;
			text = "a3\missions_f_exp\data\img\lobby\ui_campaign_lobby_background_tablet_buttonbar_co.paa";
			x = -3 * UI_GRID_W + UI_GRID_X;
			y = -11.5 * UI_GRID_H + UI_GRID_Y;
			w = 6 * UI_GRID_W;
			h = 3 * UI_GRID_H;
		};
		////////////////////////////////////////////////////////
		// GUI EDITOR OUTPUT END
		////////////////////////////////////////////////////////
    };
};
