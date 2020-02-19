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
	var/datum/starsystem/current_sys = SSstarsystem.find_system(target)
	var/list/levels = SSmapping.levels_by_trait(current_sys.level_trait)
	if(levels?.len == 1)
		var/datum/space_level/target_z = SSmapping.get_level(levels[1])
		if(ZTRAIT_HYPERSPACE in target_z.traits)
			addtimer(CALLBACK(src, .proc/start, 2 MINUTES))
			message_admins("Lone Hunter delayed for 2 minutes due to the target currently being in Hyperspace")
			return
	else if(levels?.len > 1)
		message_admins("More than one level found for [current_sys]!")
		return
	minor_announce("Bluespace Signature Detected", "DRADIS Uplink")
	sleep(rand(30, 60))
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	SSstarsystem.modifier = 0 //Reset spawn modifier
	SSstarsystem.weighting_reset() //Resets all weightings