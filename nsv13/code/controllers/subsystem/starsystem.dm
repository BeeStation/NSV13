//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(starsystem)
	name = "starsystem"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0

/datum/controller/subsystem/starsystem/PreInit()
	last_combat_enter = world.time
	return ..()

/datum/controller/subsystem/starsystem/fire()
	if(last_combat_enter < world.time + 5000)
		var/datum/round_event_control/overmap_test_one/OM = locate(/datum/round_event_control/overmap_test_one) in SSevents.control
		if(istype(OM))
			OM.weight += 1
			if(OM.weight % 5 == 0)
				message_admins("The ship has been out of combat for [last_combat_enter]. The weight of Overmap Test One is now [OM.weight]")
				log_game("The ship has been out of combat for [last_combat_enter]. The weight of Overmap Test One is now [OM.weight]")
