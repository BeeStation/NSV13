//Weapon modes

#define FIRE_MODE_PDC 1
#define FIRE_MODE_RAILGUN 2
#define FIRE_MODE_TORPEDO 3

//AI behaviour

#define AI_AGGRESSIVE 1
#define AI_PASSIVE 2
#define AI_RETALIATE 3
#define AI_GUARD 4

#define isovermap(A) (istype(A, /obj/structure/overmap))

GLOBAL_LIST_INIT(overmap_objects, list())