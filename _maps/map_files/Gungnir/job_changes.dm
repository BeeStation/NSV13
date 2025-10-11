//Removed Jobs
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(virologist)

//ATC bridge Access
/datum/job/air_traffic_controller
    minimal_access = list(ACCESS_MUNITIONS, ACCESS_HANGAR, ACCESS_HEADS)

//Munitions Job Changes
/datum/job/fighter_pilot/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 3
    spawn_positions = 3

/datum/job/munitions_tech/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 9
    spawn_positions = 9

//Service Job Changes
/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/botanist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/janitor/New()
    ..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
