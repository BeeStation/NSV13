/datum/round_event_control/lone_hunter
	name = "OVERMAP: Lone Hunter"
	typepath = /datum/round_event/lone_hunter
	weight = 0
	max_occurrences = 5
	min_players = 10

/datum/round_event/lone_hunter


/datum/round_event/lone_hunter/start()
	var/opponent = /obj/structure/overmap/syndicate/ai
	var/target = SSstarsystem.find_main_overmap()
	message_admins("target = [target]")
	var/current_sys = SSstarsystem.find_system(target)
	message_admins("current_sys = [current_sys]")
	for(var/datum/starsystem/S in SSstarsystem.systems)
		for(current_sys in SSmapping.levels_by_trait(S.level_trait))
			if(current_sys == "ZTRAIT_HYPERSPACE")
				addtimer(CALLBACK(src, .proc/start, 2 MINUTES))
				message_admins("Overmap Test One delayed for 2 minutes due to the target currently being in Hyperspace")
				return
	priority_announce("Bluespace Signature Detected", "DRADIS Uplink")
	sleep(rand(30, 60))
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	SSstarsystem.modifier = 0 //Reset spawn modifier
	SSstarsystem.weighting_reset() //Resets all weightings