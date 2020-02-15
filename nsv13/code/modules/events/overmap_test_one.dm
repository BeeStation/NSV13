/datum/round_event_control/overmap_test_one
	name = "Overmap Test One"
	typepath = /datum/round_event/overmap_test_one
	weight = 0
	max_occurrences = 1
	min_players = 5

/datum/round_event/overmap_test_one


/datum/round_event/overmap_test_one/start()
	var/opponent = /obj/structure/overmap/syndicate/ai
	var/target = SSstarsystem.find_main_overmap()
	var/current_sys = SSstarsystem.find_system(target)
	for(var/datum/starsystem/S in SSstarsystem.systems)
		for(current_sys in SSmapping.levels_by_trait(S.level_trait))
			if(current_sys == "ZTRAIT_HYPERSPACE")
				addtimer(CALLBACK(src, .proc/start, 2 MINUTES))
				message_admins("Overmap Test One delayed for 2 minutes due to the target currently being in Hyperspace")
				return
	priority_announce("Bluespace Signature Detected")
	sleep(rand(30, 60))
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	SSstarsystem.modifier = 0
	var/datum/round_event_control/overmap_test_one/OTO = locate(/datum/round_event_control/overmap_test_one) in SSevents.control //Overmap combat events
	OTO.weight = 0