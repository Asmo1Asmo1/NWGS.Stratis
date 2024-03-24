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
/*Used internally during placement:*/
#define BP_BUILDINGID 8

//Object payload
#define OBJ_SIMPLE 0
#define OBJ_STATIC 1
#define OBJ_INTERACTABLE 2

//Group rules
#define GRP_RULES_SIDE 0
#define GRP_RULES_DYNASIM 1
#define GRP_RULES_TRYSHUFFLE 2

//Fractal rules
#define FRACTAL_STEP_1 0
#define FRACTAL_STEP_2 1
#define FRACTAL_STEP_3 2

#define FRACTAL_RULE_PAGENAME 0
#define FRACTAL_RULE_BPNAME 1
#define FRACTAL_RULE_CHANCES 2
#define FRACTAL_RULE_BPPOS_OR_ROOT 3

//Result structure
#define UKREP_RESULT_BLDGS 0
#define UKREP_RESULT_FURNS 1
#define UKREP_RESULT_DECOS 2
#define UKREP_RESULT_UNITS 3
#define UKREP_RESULT_VEHCS 4
#define UKREP_RESULT_TRRTS 5
#define UKREP_RESULT_MINES 6