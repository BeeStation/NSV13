/*Mineral turf defines */
/// Surface level lavaland trash rock
#define ROCK_HARDNESS_WEAK 1

/// Caverns rock, needs atleast a drill.
#define ROCK_HARDNESS_NORMAL 2


/*Ore generation defines */

///List of minerals and their rarity
#define MINERAL_RARITY_LIST list(/datum/material/uranium = 5, /datum/material/diamond = 1, /datum/material/gold = 4, /datum/material/silver = 8, /datum/material/plasma = 6, /datum/material/iron = 80, /datum/material/titanium = 10, /datum/material/bluespace = 1)

/// How much material you will find in one dense mineral turf / boulder
#define MINERAL_TURF_AMOUNT 40000

/*Mining machines defines */

///Amount of rocks in a boulder
#define ROCK_COUNT_BOULDER 5

#define MINING_PROCESSOR_RINSING (1<<0)
#define MINING_PROCESSOR_BURNING (1<<1)
#define MINING_PROCESSOR_BEAMING (1<<2)
#define MINING_PROCESSOR_PURIFYING (1<<3)
#define MINING_PROCESSOR_CRUSHING (1<<4)
#define MINING_PROCESSOR_ALCHEMIZING (1<<5)
#define MINING_PROCESSOR_IRONIZING (1<<6)
#define MINING_PROCESSOR_ELECTRIFYING (1<<7)