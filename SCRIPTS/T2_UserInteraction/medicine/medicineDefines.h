/*Wounded sub-state enum*/
#define SUBSTATE_NONE 0
#define SUBSTATE_RAGD 1
#define SUBSTATE_INVH 2
#define SUBSTATE_DOWN 3
#define SUBSTATE_CRWL 4
#define SUBSTATE_HEAL 5
#define SUBSTATE_DRAG 6
#define SUBSTATE_CARR 7

/*Blame 'enum'*/
#define BLAME_VEH_KO 0
#define BLAME_WOUND 1
#define BLAME_KILL 2

/*Actions 'enum'*/
#define ACTION_PATCH 0
#define ACTION_HEAL_SUCCESS 1
#define ACTION_HEAL_PARTIAL 2
#define ACTION_HEAL_FAILURE 3
#define ACTION_DRAG 4
#define ACTION_CARRY 5