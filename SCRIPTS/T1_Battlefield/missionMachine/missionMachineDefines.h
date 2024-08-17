// Exempt defines from ukrepDefines.h
//It is not a good practice, but they are not that widespread to move them to globalDefines.h
//Here we rely on the fact that we'll see those in Search'n'Replace if ever need to make changes (hopefully not)
// UkrepType	UkrepName	ABSPos	[0,0,0]	Radius	0	Payload	Blueprint
#define BPCONTAINER_TYPE 0
#define BPCONTAINER_NAME 1
#define BPCONTAINER_POS 2
#define BPCONTAINER_UNUSED1 3
#define BPCONTAINER_RADIUS 4
#define BPCONTAINER_UNUSED2 5
#define BPCONTAINER_PAYLOAD 6
#define BPCONTAINER_BLUEPRINT 7

#define UKREP_RESULT_BLDGS 0
#define UKREP_RESULT_FURNS 1
#define UKREP_RESULT_DECOS 2
#define UKREP_RESULT_UNITS 3
#define UKREP_RESULT_VEHCS 4
#define UKREP_RESULT_TRRTS 5
#define UKREP_RESULT_MINES 6

//Selection element structure
#define SELECTION_NAME 0
#define SELECTION_POS 1
/*Server side*/
#define SELECTION_RAD 2
#define SELECTION_BLUEPRINT 3
#define SELECTION_SETTINGS 4
/*Client side*/
#define SELECTION_DIFFICULTY 2
#define SELECTION_MARKER 3
#define SELECTION_COLOR 4
#define SELECTION_MARKER_SIZE 5
#define SELECTION_OUTLINE_ALPHA 6
#define SELECTION_OUTLINE_RADIUS 7