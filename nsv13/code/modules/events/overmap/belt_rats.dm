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
	var/target = SSstar_system.find_main_miner() //Find the Mining Cruiser
	var/datum/star_system/current_sys = SSstar_system.find_system(target)
	SSstar_system.spawn_ship(opponent, current_sys)
	if(prob(20))
		SSstar_system.spawn_ship(opponent, current_sys) //20% prob to spawn a second fighter - no officer mods drops