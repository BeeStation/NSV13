/*
 *
 * Pegasus job changes, AKA munitions techs RULE. This may or may not even work honk :O)
 *
 */


/datum/job/fighter_pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 12
	spawn_positions = 12


#undef JOB_MODIFICATION_MAP_NAME
