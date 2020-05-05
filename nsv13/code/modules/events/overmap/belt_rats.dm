//OVERMAP Event - This will alter the state of the OVERMAP Z-LEVELS
//This event will spawn 1 to 2 syndicate fighters on the same overmap z-level as the mining ship
//This event should only fire through the overmap handler

/datum/round_event_control/belt_rats
	name = "OVERMAP: 'Belt 'Rats"
	typepath = /datum/round_event/belt_rats
	weight = 0
	max_occurrences = 0
	min_players = 5

/datum/round_event/belt_rats

/datum/round_event/belt_rats/start()
	var/opponent = /obj/structure/overmap/syndicate/ai/fighter //Lone Syndie Fighter
	var/target = SSstarsystem.find_main_miner() //Find the Mining Cruiser
	var/datum/starsystem/current_sys = SSstarsystem.find_system(target)
	var/list/levels = SSmapping.levels_by_trait(current_sys.level_trait)
	if(levels?.len == 1)
		var/datum/space_level/target_z = SSmapping.get_level(levels[1])
		if(ZTRAIT_HYPERSPACE in target_z.traits)
			addtimer(CALLBACK(src, .proc/start, 2 MINUTES))
			message_admins("'Belt 'Rats delayed for 2 minutes due to the target currently being in Hyperspace")
			return
	else if(levels?.len > 1)
		message_admins("More than one level found for [current_sys]!")
		return
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	if(prob(20))
		SSstarsystem.modular_spawn_enemies(opponent, current_sys) //20% prob to spawn a second fighter - no officer mods drops