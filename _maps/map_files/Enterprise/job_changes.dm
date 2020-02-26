#define JOB_MODIFICATION_MAP_NAME "SGC Enterprise"

/datum/job/pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 6
	spawn_positions = 6