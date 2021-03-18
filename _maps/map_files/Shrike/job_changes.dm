//Medical Research
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(chemist)
//Ivory Tower Research
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
//Civilian
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(mime)
//Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(brig_phys)
//Munitions
MAP_REMOVE_JOB(deck_tech)
MAP_REMOVE_JOB(flight_leader)
MAP_REMOVE_JOB(fighter_pilot)
MAP_REMOVE_JOB(air_traffic_controller)

/datum/job/bridge/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_ENGINE
	total_positions = 1
	spawn_positions = 1

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3

/datum/job/emt/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/bartender/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

#undef JOB_MODIFICATION_MAP_NAME
