
//Time between each 'combat cycle' of starsystems. Every combat cycle, every system that has opposing fleets in it gets iterated through, with the fleets firing at eachother.
#define COMBAT_CYCLE_INTERVAL 180 SECONDS

//Threat level of star systems
#define THREAT_LEVEL_NONE 0
#define THREAT_LEVEL_UNSAFE 2
#define THREAT_LEVEL_DANGEROUS 4

//The different sectors, keep this updated
#define ALL_STARMAP_SECTORS 1,2,3

#define SECTOR_SOL 1
#define SECTOR_NEUTRAL 2
#define SECTOR_SYNDICATE 3
