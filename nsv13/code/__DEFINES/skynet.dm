//AI score defines
#define AI_SCORE_MAXIMUM 1000 //No goal combination should ever exceed this.
#define AI_SCORE_SUPERCRITICAL 500
#define AI_SCORE_CRITICAL 100
#define AI_SCORE_SUPERPRIORITY 75
#define AI_SCORE_HIGH_PRIORITY 60
#define AI_SCORE_PRIORITY 50
#define AI_SCORE_DEFAULT 25
#define AI_SCORE_LOW_PRIORITY 15
#define AI_SCORE_VERY_LOW_PRIORITY 5 //Very low priority, acts as a failsafe to ensure that the AI always picks _something_ to do.

//AI PDC range
#define AI_PDC_RANGE 12

//Fleet generation & Difficulty Defines
#define FLEET_DIFFICULTY_EASY 2 //if things end up being too hard, this is a safe number for a fight you _should_ always win.
#define FLEET_DIFFICULTY_MEDIUM 5
#define FLEET_DIFFICULTY_HARD 8
#define FLEET_DIFFICULTY_VERY_HARD 10
#define FLEET_DIFFICULTY_INSANE 15 //If you try to take on the rubicon ;)
#define FLEET_DIFFICULTY_WHAT_ARE_YOU_DOING 25
#define FLEET_DIFFICULTY_DEATH 30 //Suicide run

#define SCALE_FLEETS_WITH_POP TRUE //Change this to false if you want fleet size to be static. Fleets will be scaled down if the game detects underpopulation, however it can also scale them up to be more of a challenge.

//Fleet behaviour. Border patrol fleets will stick to patrolling their home space only. Invasion fleets ignore home space and fly around. If the fleet has a goal system or is a interdictor, this gets mostly ignored, but stays as fallback.
#define FLEET_TRAIT_BORDER_PATROL 1
#define FLEET_TRAIT_INVASION 2
#define FLEET_TRAIT_NEUTRAL_ZONE 3
#define FLEET_TRAIT_DEFENSE 4

GLOBAL_LIST_EMPTY(ai_goals)

/*
!!AI flags are located in the base bitfield defines (flags.dm)
They are:
AI_FLAG_SUPPLY
AI_FLAG_BATTLESHIP
AI_FLAG_DESTROYER
AI_FLAG_ANTI_FIGHTER
AI_FLAG_BOARDER
AI_FLAG_SWARMER
AI_FLAG_ELITE
AI_FLAG_STATIONARY
*/
