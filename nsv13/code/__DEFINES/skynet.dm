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


//Threat elevation defines - basically, the longer you take and the more you annoy them, the more annoyed they are going to be. Interact with the above fleet difficulty defines.
//TE_POINTS_PER_FLEET_SIZE points is equivalent to 1 fleet size point - not the same due to the possibility of using these for other things too.
#define TE_REINFORCEMENT_DELAY 15 MINUTES   //A fleet needs to not be currently on a loaded z aswell as not have been in player combat for this long to reinforce up to TE mandated strength. For NPC combat, it simply has to not be in a contested system.
#define TE_INITIAL_DELAY 25 MINUTES         //Let's say the crew needs about 25 minutes usually to get things setup enough to be considered working.
#define TE_THREAT_PER_HOUR 100              //How much threat is passively generated per hour?
#define TE_OBJECTIVE_THREAT_NEGATION 50     //How much threat do we lose per completed objective (cannot go below 0 threat) - can be further modified in the overmap objectives themselves - set to 0 to disable
#define TE_FLEET_THREAT_DYNAMIC TRUE        //If true, the fleet kill threat below is modified by base fleet strength. If not, it is simply applied the same for every fleet.
#define TE_FLEET_KILL_THREAT 10             //If Dynamic mode is enabled, this many points of threat will be added per base strength point of the destroyed fleet. If it is not, this point value is simply applied flat on kill.
#define TE_SYNDISHOP_PENALTY 20             //Buying things at a Syndicate outpost when a warship is incredibly suspicious and will raise threat for every object purchased.
#define TE_POINTS_PER_FLEET_SIZE 100        //How many points does one fleet size point cost?

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
