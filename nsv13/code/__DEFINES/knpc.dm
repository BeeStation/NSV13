//Knpc pathfinding return values
#define KNPC_PATHFIND_SUCCESS 0 //Path successfully generated
#define KNPC_PATHFIND_SKIP 1 //Regenerating of path isn't needed, incapable of moving, etc
#define KNPC_PATHFIND_TIMEOUT 2 //Pathfinding is currently in timeout due to having failed previously.
#define KNPC_PATHFIND_FAIL 3 //No path found

//Knpc pathfinding timeout defines
#define KNPC_TIMEOUT_BASE (3 SECONDS) //The base timeout applied if an knpc's pathfinding fails.
#define KNPC_TIMEOUT_STACK_CAP 9 //Every consecutive pathfinding fail adds a stacks; Timeout applied uses them as multiplier up to a cap of this value.
