//Weapon modes

#define FIRE_MODE_ANTI_AIR 1
#define FIRE_MODE_TORPEDO 2

//Revision 2.
#define FIRE_MODE_AMS_LASER 3 // Laser AMS should be fired before expensive missiles are fired, so this is prioritized first
#define FIRE_MODE_AMS 4 //You don't get to physically fire this one.
#define FIRE_MODE_MAC 5
#define FIRE_MODE_RAILGUN 6
#define FIRE_MODE_GAUSS 7
#define FIRE_MODE_PDC 8



//Deprecated / legacy weapons.


#define FIRE_MODE_FLAK 9
#define FIRE_MODE_MISSILE 10
#define FIRE_MODE_FIGHTER_SLOT_ONE 11
#define FIRE_MODE_FIGHTER_SLOT_TWO 12

//Special cases

#define FIRE_MODE_RED_LASER 13
#define FIRE_MODE_BLUE_LASER 14
#define FIRE_MODE_HYBRID_RAIL 15

#define MAX_POSSIBLE_FIREMODE 15 //This should relate to the maximum number of weapons a ship can ever have. Keep this up to date please!


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
#define isasteroid(A) (istype(A, /obj/structure/overmap/asteroid))

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

#define SENSOR_RANGE_DEFAULT 40
#define SENSOR_RANGE_FIGHTER 30 //Fighters have crappier sensors. Coordinate with the ATC!

#define CLOAK_TEMPORARY_LOSS 2 //Cloak handling. When you fire a weapon, you temporarily lose your cloak, and AIs can target you.

GLOBAL_LIST_INIT(overmap_objects, list())
GLOBAL_LIST_INIT(overmap_impact_sounds, list('nsv13/sound/effects/ship/freespace2/impacts/boom_1.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_4.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/damage/consolehit.ogg','nsv13/sound/effects/ship/damage/consolehit2.ogg','nsv13/sound/effects/ship/damage/consolehit3.ogg','nsv13/sound/effects/ship/damage/consolehit4.ogg','nsv13/sound/effects/ship/damage/shiphit.ogg','nsv13/sound/effects/ship/damage/shiphit2.ogg','nsv13/sound/effects/ship/damage/shiphit3.ogg','nsv13/sound/effects/ship/damage/shiphit4.ogg','nsv13/sound/effects/ship/damage/torpedo_hit.ogg','nsv13/sound/effects/ship/damage/explosionfar_2.ogg','nsv13/sound/effects/ship/damage/explosionfar_3.ogg','nsv13/sound/effects/ship/damage/explosionfar_4.ogg','nsv13/sound/effects/ship/damage/explosionfar_5.ogg','nsv13/sound/effects/ship/damage/explosionfar_6.ogg'))

//Unique identifiers for each faction. Keep this updated when you make a new faction.
#define FACTION_ID_UNALIGNED 0
#define FACTION_ID_NT 1
#define FACTION_ID_SYNDICATE 2
#define FACTION_ID_SOLGOV 3
#define FACTION_ID_UNATHI 4
#define FACTION_ID_PIRATES 5

#define NO_INTERIOR 0
#define INTERIOR_EXCLUSIVE 1 // Only one of them at a time, occupies a whole Z level
#define INTERIOR_DYNAMIC 2 // Can have more than one, reserves space on the reserved Z

#define INTERIOR_NOT_LOADED 0
#define INTERIOR_LOADING 1
#define INTERIOR_READY 2
#define INTERIOR_DELETING 3
#define INTERIOR_DELETED 4
