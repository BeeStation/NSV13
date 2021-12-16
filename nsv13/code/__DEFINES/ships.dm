#define MASS_TINY 1 //1 Player - Fighters
#define MASS_SMALL 2 //2-5 Players - FoB/Mining Ship
#define MASS_MEDIUM 3 //10-20 Players - Small Capital Ships
#define MASS_MEDIUM_LARGE 5 //10-20 Players - Small Capital Ships
#define MASS_LARGE 7 //20-40 Players - Medium Capital Ships
#define MASS_TITAN 150 //40+ Players - Large Capital Ships
#define MASS_IMMOBILE 200 //Things that should not be moving. See: stations

#define BOARDABLE_SHIP_TYPES list(/obj/structure/overmap/syndicate/ai, /obj/structure/overmap/syndicate/ai/mako_carrier, /obj/structure/overmap/syndicate/ai/nuclear, /obj/structure/overmap/syndicate/ai/destroyer)
// FIXME: the KNPC path nodes on this one are busted
//  /obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate
