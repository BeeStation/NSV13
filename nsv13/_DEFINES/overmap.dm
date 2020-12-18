//Weapon modes

#define FIRE_MODE_PDC 1
#define FIRE_MODE_TORPEDO 2
#define FIRE_MODE_MAC 3
#define FIRE_MODE_RAILGUN 4
#define FIRE_MODE_GAUSS 5
#define FIRE_MODE_FLAK 6
#define FIRE_MODE_MISSILE 7
#define FIRE_MODE_FIGHTER_SLOT_ONE 8
#define FIRE_MODE_FIGHTER_SLOT_TWO 9
#define FIRE_MODE_RED_LASER 10
#define FIRE_MODE_BLUE_LASER 11
#define MAX_POSSIBLE_FIREMODE 11 //This should relate to the maximum number of weapons a ship can ever have. Keep this up to date please!

//Weapon classes for AIs
#define WEAPON_CLASS_LIGHT 1
#define WEAPON_CLASS_HEAVY 2

//Northeast, Northwest, Southeast, Southwest
#define ARMOUR_FORWARD_PORT "forward_port"
#define ARMOUR_FORWARD_STARBOARD "forward_starboard"
#define ARMOUR_AFT_PORT "aft_port"
#define ARMOUR_AFT_STARBOARD "aft_starboard"

//AI behaviour

#define AI_AGGRESSIVE 1
#define AI_PASSIVE 2
#define AI_RETALIATE 3
#define AI_GUARD 4

#define isovermap(A) (istype(A, /obj/structure/overmap))

//Assigning player ships goes here

#define NORMAL_OVERMAP 1
#define MAIN_OVERMAP 2
#define MAIN_MINING_SHIP 3
#define PVP_SHIP 4
#define INSTANCED_MIDROUND_SHIP 5

//Sensor resolution

#define SENSOR_VISIBILITY_FULL 1
#define SENSOR_VISIBILITY_TARGETABLE 0.70 //You have to be close up, or not cloaked to be targetable by the ship's gunner.
#define SENSOR_VISIBILITY_FAINT 0.5
#define SENSOR_VISIBILITY_VERYFAINT 0.25
#define SENSOR_VISIBILITY_GHOST 0 //Totally impervious to scans.

#define SENSOR_RANGE_DEFAULT 85
#define SENSOR_RANGE_FIGHTER 75 //Fighters have crappier sensors. Coordinate with the ATC!

#define CLOAK_TEMPORARY_LOSS 2 //Cloak handling. When you fire a weapon, you temporarily lose your cloak, and AIs can target you.

GLOBAL_LIST_INIT(overmap_objects, list())
GLOBAL_LIST_INIT(overmap_impact_sounds, list('nsv13/sound/effects/ship/freespace2/impacts/boom_1.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_4.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/damage/consolehit.ogg','nsv13/sound/effects/ship/damage/consolehit2.ogg','nsv13/sound/effects/ship/damage/consolehit3.ogg','nsv13/sound/effects/ship/damage/consolehit4.ogg','nsv13/sound/effects/ship/damage/shiphit.ogg','nsv13/sound/effects/ship/damage/shiphit2.ogg','nsv13/sound/effects/ship/damage/shiphit3.ogg','nsv13/sound/effects/ship/damage/shiphit4.ogg','nsv13/sound/effects/ship/damage/torpedo_hit.ogg','nsv13/sound/effects/ship/damage/explosionfar_2.ogg','nsv13/sound/effects/ship/damage/explosionfar_3.ogg','nsv13/sound/effects/ship/damage/explosionfar_4.ogg','nsv13/sound/effects/ship/damage/explosionfar_5.ogg','nsv13/sound/effects/ship/damage/explosionfar_6.ogg'))

//Unique identifiers for each faction. Keep this updated when you make a new faction.
#define FACTION_ID_NT 1
#define FACTION_ID_SYNDICATE 2
#define FACTION_ID_SOLGOV 3
#define FACTION_ID_UNATHI 4
#define FACTION_ID_PIRATES 5
