//Ukrep blueprint structure

// UkrepType	UkrepName	ABSPos	[0,0,0]	Radius	0	Payload	Inside
#define BPCONTAINER_TYPE 0
#define BPCONTAINER_NAME 1
#define BPCONTAINER_POS 2
#define BPCONTAINER_UNUSED1 3
#define BPCONTAINER_RADIUS 4
#define BPCONTAINER_UNUSED2 5
#define BPCONTAINER_PAYLOAD 6
#define BPCONTAINER_BLUEPRINT 7

// ObjType	ClassName	Position	PosOffset	Direction	DirOffset	Payload	Inside
#define BP_OBJTYPE 0
#define BP_CLASSNAME 1
#define BP_POS 2
#define BP_POSOFFSET 3
#define BP_DIR 4
#define BP_DIROFFSET 5
#define BP_PAYLOAD 6
#define BP_INSIDE 7
/*Used internally during gathering:*/
#define BP_ORIGOBJECT 8
#define BP_INSIDE_OF 9

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
#define GRP_RULES_TRYSHUFFLE 2