//Weapon modes

#define FIRE_MODE_PDC 1
#define FIRE_MODE_TORPEDO 2
#define FIRE_MODE_RAILGUN 3

//AI behaviour

#define AI_AGGRESSIVE 1
#define AI_PASSIVE 2
#define AI_RETALIATE 3
#define AI_GUARD 4

#define isovermap(A) (istype(A, /obj/structure/overmap))

GLOBAL_LIST_INIT(overmap_objects, list())
GLOBAL_LIST_INIT(overmap_impact_sounds, list('nsv13/sound/effects/ship/freespace2/impacts/boom_1.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_2.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_3.wav','nsv13/sound/effects/ship/freespace2/impacts/boom_4.wav','nsv13/sound/effects/ship/freespace2/impacts/m_hit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit.wav','nsv13/sound/effects/ship/freespace2/impacts/subhit2.wav','nsv13/sound/effects/ship/damage/consolehit.ogg','nsv13/sound/effects/ship/damage/consolehit2.ogg','nsv13/sound/effects/ship/damage/consolehit3.ogg','nsv13/sound/effects/ship/damage/consolehit4.ogg','nsv13/sound/effects/ship/damage/shiphit.ogg','nsv13/sound/effects/ship/damage/shiphit2.ogg','nsv13/sound/effects/ship/damage/shiphit3.ogg','nsv13/sound/effects/ship/damage/shiphit4.ogg','nsv13/sound/effects/ship/damage/torpedo_hit.ogg','nsv13/sound/effects/ship/damage/explosionfar_2.ogg','nsv13/sound/effects/ship/damage/explosionfar_3.ogg','nsv13/sound/effects/ship/damage/explosionfar_4.ogg','nsv13/sound/effects/ship/damage/explosionfar_5.ogg','nsv13/sound/effects/ship/damage/explosionfar_6.ogg'))
