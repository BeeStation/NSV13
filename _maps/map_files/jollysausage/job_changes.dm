/*
 *
 * Jolly Sausage job changes. Namely count reductions or strict removal.
 *
 */

/*
/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_CREMATORIUM
	*/

MAP_REMOVE_JOB(brig_phys)	//No room for them, Redundant at this pop level.
MAP_REMOVE_JOB(atmos)		//Similar reason. Redundant at all pop levels, really.
MAP_REMOVE_JOB(clown)		//Rest in peace child.
MAP_REMOVE_JOB(mime)		//But know that hell does not take you alone.
MAP_REMOVE_JOB(emt)			//Redundant
MAP_REMOVE_JOB(flight_leader)//Redundant
MAP_REMOVE_JOB(curator)		//Redundant even in a standard round
MAP_REMOVE_JOB(qm)			//Easily made redundant
//Tentatively leaving in Robotics...
MAP_REMOVE_JOB(virologist)	//Redundant

/datum/job/engineer/New() //Yeet atmos, give them atmos access full time.
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_ATMOSPHERICS //Atmos alarms.

/datum/job/lawyer/New() //Single position, shares closet with Detective.
	..()
	MAP_JOB_CHECK
//	access += ACCESS_FORENSICS_LOCKERS //Doing this at the map access level instead.
//	minimal_access += ACCESS_FORENSICS_LOCKERS
	total_positions = 1
	spawn_positions = 1

/datum/job/cargo_tech/New()
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_QM //Make redundant QM

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	minimal_access += ACCESS_VIROLOGY

/datum/job/janitor/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1

/datum/job/cook/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1

/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/job/fighter_pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 1

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 2

/datum/uplink_item/explosives/syndicate_bomb/New()
	. = ..()
	
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	limited_stock = 0 //This ship is way too small for this shit.
	cant_discount = TRUE
	surplus = 0

#undef JOB_MODIFICATION_MAP_NAME
