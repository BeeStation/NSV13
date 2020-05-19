#define JOB_MODIFICATION_MAP_NAME "NSV Jeppison"

/datum/job/pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/deck-tech/new()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2