//auto includes by description.ext
// #include "GUI\ui_toolkit.hpp"

//moved to imports.hpp
// import RscListbox;

//--- dialogueUI IDCs
#define IDC_QLISTBOX 1500
#define IDC_ALISTBOX 1501
#define IDC_TEXT_LEFT 1000
#define IDC_TEXT_RIGHT 1001
#define IDC_TEXT_NPC 1002

//--- font
#define FONT_NAME "EtelkaMonospacePro"

//--- scale helpers
#define LISTBOX_W  (0.875 * X_SCALE)
#define QLISTBOX_H (0.5 * Y_SCALE)
#define ALISTBOX_H (0.2 * Y_SCALE)
#define TEXT_W (0.21 * X_SCALE)
#define TEXT_H (0.03 * Y_SCALE)

//--- position helpers
#define LISTBOX_X FROM_CENTER(LISTBOX_W)
#define QLISTBOX_Y (FROM_CENTER(0.70 * Y_SCALE))
#define ALISTBOX_Y (FROM_CENTER(-0.40 * Y_SCALE))
#define TEXT_LEFT_X   (FROM_CENTER(1.0 * LISTBOX_W))
#define TEXT_RIGHT_X  (FROM_CENTER(-1.0 * LISTBOX_W) - TEXT_W)
#define TEXT_TOP_Y    (QLISTBOX_Y - TEXT_H)
#define TEXT_BOTTOM_Y (ALISTBOX_Y - TEXT_H)

class dialogueUI {
    idd = 7103;

    class controls {
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT START (by Asmo, v1.063, #Muwoxy)
        ////////////////////////////////////////////////////////

        class DUI_QListbox: RscListbox
        {
            idc = IDC_QLISTBOX;
            x = LISTBOX_X;
            y = QLISTBOX_Y;
            w = LISTBOX_W;
            h = QLISTBOX_H;
            shadow = 1;
            font = FONT_NAME;
            colorBackground[] = {0,0,0,0.5};
        };
        class DUI_AListbox: RscListbox
        {
            idc = IDC_ALISTBOX;
            x = LISTBOX_X;
            y = ALISTBOX_Y;
            w = LISTBOX_W;
            h = ALISTBOX_H;
            shadow = 1;
            font = FONT_NAME;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextLeft: RscText
        {
            idc = IDC_TEXT_LEFT;
            x = TEXT_LEFT_X;
            y = TEXT_BOTTOM_Y;
            w = TEXT_W;
            h = TEXT_H;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextRight: RscText
        {
            idc = IDC_TEXT_RIGHT;
            style = 1;//1: align right
            x = TEXT_RIGHT_X;
            y = TEXT_BOTTOM_Y;
            w = TEXT_W;
            h = TEXT_H;
            colorBackground[] = {0,0,0,0.55};
        };
        class DUI_TextNPC: RscText
        {
            idc = IDC_TEXT_NPC;
            style = 1;//1: align right
            x = TEXT_RIGHT_X;
            y = TEXT_TOP_Y;
            w = TEXT_W;
            h = TEXT_H;
            colorBackground[] = {0,0,0,0.5};
        };
        ////////////////////////////////////////////////////////
        // GUI EDITOR OUTPUT END
        ////////////////////////////////////////////////////////

    }
};
