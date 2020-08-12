/*
 *
 * Pegasus job changes, AKA munitions techs RULE. This may or may not even work honk :O)
 *
 */


/datum/job/fighter_pilot/New()
	..()
	MAP_JOB_CHECK
	addtimer(VARSET_CALLBACK(src, total_positions, 3), 10 SECONDS)
	addtimer(VARSET_CALLBACK(src, spawn_positions, 3), 10 SECONDS)

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	addtimer(VARSET_CALLBACK(src, total_positions, 12), 10 SECONDS)
	addtimer(VARSET_CALLBACK(src, spawn_positions, 12), 10 SECONDS)

#undef JOB_MODIFICATION_MAP_NAME
