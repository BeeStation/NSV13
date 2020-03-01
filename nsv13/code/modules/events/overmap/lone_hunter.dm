//OVERMAP Event - This will alter the state of the OVERMAP Z-LEVELS
//This event will spawn a single syndicate cruiser on the same overmap z-level as the main "hero" ship
//This event should only fire through the overmap handler

/datum/round_event_control/lone_hunter
	name = "OVERMAP: Lone Hunter"
	typepath = /datum/round_event/lone_hunter
	weight = 0
	max_occurrences = 0
	min_players = 5

/datum/round_event/lone_hunter

/datum/round_event/lone_hunter/start()
	var/opponent = /obj/structure/overmap/syndicate/ai //generic bad guy
	var/target = SSstarsystem.find_main_overmap() //find the "hero" ship
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
	minor_announce("Bluespace Signature Detected", "DRADIS Uplink") //Hot Drop
	sleep(rand(30, 60)) // 3 to 6 seconds to spill your coffee all over the weapons console
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
