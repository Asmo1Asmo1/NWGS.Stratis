//moved to imports.hpp
// import RscListbox;

#define UI_GRID_X	(0.5)
#define UI_GRID_Y	(0.5)
#define UI_GRID_W	(2.5 * pixelW * pixelGrid)
#define UI_GRID_H	(2.5 * pixelH * pixelGrid)
#define UI_GRID_WAbs	(0)
#define UI_GRID_HAbs	(0)

//--- dialogueUI
#define IDC_QLISTBOX 1500
#define IDC_ALISTBOX 1501
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001
#define IDC_TEXT_NPC 1002

#define FONT_NAME "EtelkaMonospacePro"

class dialogueUI {
    idd = 7103;

    class controls {
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT START (by Asmo, v1.063, #Muwoxy)
        ////////////////////////////////////////////////////////

        class DUI_QListbox: RscListbox
        {
            idc = IDC_QLISTBOX;
            x = -20 * UI_GRID_W + UI_GRID_X;
            y = -13 * UI_GRID_H + UI_GRID_Y;
            w = 40 * UI_GRID_W;
            h = 18 * UI_GRID_H;
            shadow = 1;
            font = FONT_NAME;
            colorBackground[] = {0,0,0,0.5};
        };
        class DUI_AListbox: RscListbox
        {
            idc = IDC_ALISTBOX;
            x = -20 * UI_GRID_W + UI_GRID_X;
            y = 7 * UI_GRID_H + UI_GRID_Y;
            w = 40 * UI_GRID_W;
            h = 8 * UI_GRID_H;
            shadow = 1;
            font = FONT_NAME;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextLeft: RscText
        {
            idc = IDC_TEXT_LEFT;
            x = -20 * UI_GRID_W + UI_GRID_X;
            y = 6 * UI_GRID_H + UI_GRID_Y;
            w = 8 * UI_GRID_W;
            h = 1 * UI_GRID_H;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextRight: RscText
        {
            idc = IDC_TEXT_RIGHT;
            style = 1;//1: align right
            x = 12 * UI_GRID_W + UI_GRID_X;
            y = 6 * UI_GRID_H + UI_GRID_Y;
            w = 8 * UI_GRID_W;
            h = 1 * UI_GRID_H;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextNPC: RscText
        {
            idc = IDC_TEXT_NPC;
            style = 1;//1: align right
            x = 12 * UI_GRID_W + UI_GRID_X;
            y = -14 * UI_GRID_H + UI_GRID_Y;
            w = 8 * UI_GRID_W;
            h = 1 * UI_GRID_H;
            colorBackground[] = {0,0,0,0.5};
        };
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT END
        ////////////////////////////////////////////////////////

    }
};
