/datum/round_event_control/belt_rats
	name = "OVERMAP: 'Belt 'Rats"
	typepath = /datum/round_event/belt_rats
	weight = 0
	max_occurrences = 5
	min_players = 5

/datum/round_event/belt_rats


/datum/round_event/belt_rats/start()
	var/opponent = /obj/structure/overmap/fighter/ai/syndicate //Lone Syndie Fighter
	var/target = SSstarsystem.find_main_miner() //Find the Mining Cruiser
	message_admins("target = [target]")
	var/current_sys = SSstarsystem.find_system(target)
	message_admins("current_sys = [current_sys]")
	for(var/datum/starsystem/S in SSstarsystem.systems)
		for(current_sys in SSmapping.levels_by_trait(S.level_trait))
			if(current_sys == "ZTRAIT_HYPERSPACE") //Delay spawn if MC is in hyperspace
				addtimer(CALLBACK(src, .proc/start, 2 MINUTES))
				message_admins("'belt 'rats delayed for 2 minutes due to the target currently being in Hyperspace")
				return
	SSstarsystem.modular_spawn_enemies(opponent, current_sys)
	if(prob(20))
		SSstarsystem.modular_spawn_enemies(opponent, current_sys) //20% prob to spawn a second
	SSstarsystem.modifier = 0 //Reset spawn modifier
	SSstarsystem.weighting_reset() //Resets all weightings