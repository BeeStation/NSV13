/datum/round_event_control/overmap_test_one
	name = "Overmap Test One"
	typepath = /datum/round_event/overmap_test_one
	weight = 0
	max_occurrences = 1
	min_players = 5

/datum/round_event/overmap_test_one
/*
/datum/round_event/overmap_test_one/start()
	for(var/z in SSmapping.levels_by_trait(level_trait))
		var/turf/exit = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z)) //Plop them bang in the center of the system.
		var/turf/destination = get_turf(pick(orange(20,exit)))
		if(!destination)
			message_admins("WARNING: The [name] system has no exit point for ships! You probably forgot to set the [level_trait]:1 setting for that Z in your map's JSON file.")
			return
		var/obj/structure/overmap/enemy = new /obj/structure/overmap/fighter/ai/syndicate(destination)
		enemies_in_system += enemy

*/


///obj/structure/overmap/nanotrasen/mining_cruiser/

/*
	enemies_in_system = list()
	spawn_asteroids()
	for(var/i = 0, i< rand(1,difficulty_budget), i++)
		var/enemy_type = pick(subtypesof(/obj/structure/overmap/syndicate)) //Spawn a random set of enemies.
		for(var/z in SSmapping.levels_by_trait(level_trait))
			var/turf/exit = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z)) //Plop them bang in the center of the system.
			var/turf/destination = get_turf(pick(orange(20,exit)))
			if(!destination)
				message_admins("WARNING: The [name] system has no exit point for ships! You probably forgot to set the [level_trait]:1 setting for that Z in your map's JSON file.")
				return
			var/obj/structure/overmap/enemy = new enemy_type(destination)
			enemies_in_system += enemy
			RegisterSignal(enemy, COMSIG_PARENT_QDELETING , .proc/remove_enemy, enemy) //Add a listener component to check when a ship is killed, and thus check if the incursion is cleared.
*/