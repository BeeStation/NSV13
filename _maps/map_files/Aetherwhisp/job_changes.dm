
// If you continue to complain that munitechs have nothing to do, then I guess you really have nothing to do now don't you?
// I'm replacing your job with bridge officers who are perfectly capable of pushing a button on lasers 
// MAP_REMOVE_JOB(master_at_arms)
MAP_REMOVE_JOB(munitions_tech)

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 0
	spawn_positions = 0

/datum/job/master_at_arms/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

#undef JOB_MODIFICATION_MAP_NAME
