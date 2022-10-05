
/datum/job/pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 7
	spawn_positions = 7

/datum/job/staffjudgeadvocate/New() //big ship needs much oversight
    ..()
    MAP_JOB_CHECK
    total_positions = 2
    spawn_positions = 2


#undef JOB_MODIFICATION_MAP_NAME
