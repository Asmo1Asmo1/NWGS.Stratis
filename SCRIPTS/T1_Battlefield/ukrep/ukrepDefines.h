//Ukrep blueprint structure

// UkrepType	UkrepName	ABSPos	[0,0,0]	Radius	0	Payload	Inside
#define BP_TITLE_TYPE 0
#define BP_TITLE_NAME 1
#define BP_TITLE_POS 2
#define BP_TITLE_UNUSED1 3
#define BP_TITLE_RADIUS 4
#define BP_TITLE_UNUSED2 5
#define BP_TITLE_PAYLOAD 6
#define BP_TITLE_INSIDE 7

// ObjType	ClassName	Position	PosOffset	Direction	DirOffset	Payload	Inside
#define BP_OBJTYPE 0
#define BP_CLASSNAME 1
#define BP_POS 2
#define BP_POSOFFSET 3
#define BP_DIR 4
#define BP_DIROFFSET 5
#define BP_PAYLOAD 6
#define BP_INSIDE 7

//Payloads
#define P_OBJ_CAN_SIMPLE 0
#define P_OBJ_IS_SIMPLE 1
#define P_OBJ_IS_SIM_ON 2
#define P_OBJ_IS_DYNASIM_ON 3
#define P_OBJ_IS_DMG_ALLOWED 4
#define P_OBJ_IS_INTERACTABLE 5

//Group rules
#define GRP_RULES_SIDE 0
#define GRP_RULES_DYNASIM 1