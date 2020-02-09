//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(starsystem)
	name = "Starsystem"
	wait = 50
	flags = SS_NO_INIT
	var/last_combat_enter = 0
	var/modifier = 0
	var/list/systems = list()
	var/datum/starsystem/hyperspace //The transit level for ships

/datum/controller/subsystem/starsystem/fire()
	if(last_combat_enter + (5000 + (1000 * modifier)) < world.time) //Checking the last time we started combat with the current time
		var/datum/round_event_control/overmap_test_one/OM = locate(/datum/round_event_control/overmap_test_one) in SSevents.control //Overmap combat events
		if(istype(OM))
			OM.weight += 1 //Increment probabilty via SSEvent
			modifier += 1 //Increment time step
			if(modifier == 5)
				priority_announce("PLACEHOLDER") //Warn players for taking too long
			if(OM.weight % 5 == 0)
				message_admins("The ship has been out of combat for [last_combat_enter]. The weight of Overmap Test One is now [OM.weight]")
				log_game("The ship has been out of combat for [last_combat_enter]. The weight of Overmap Test One is now [OM.weight]")

/datum/controller/subsystem/starsystem/proc/event_info() //debugging output
	var/datum/round_event_control/overmap_test_one/OM = locate(/datum/round_event_control/overmap_test_one) in SSevents.control
	message_admins("Current time: [world.time] | Last Combat: [last_combat_enter] | Modifier: [modifier] | [OM.name]: [OM.weight]")

/datum/controller/subsystem/starsystem/proc/find_system(obj/structure/overmap/OM) //Used to determine what system a ship is currently in. Famously used to determine the starter system that you've put the ship in.
	var/datum/starsystem/found
	for(var/datum/starsystem/S in systems)
		for(var/thez in SSmapping.levels_by_trait(S.level_trait))
			if(thez == OM.z)
				found = S
				break
	return found

/datum/controller/subsystem/starsystem/New()
	. = ..()
	instantiate_systems()

/datum/controller/subsystem/starsystem/proc/instantiate_systems()
	set_timer()
	var/datum/starsystem/SS = new
	hyperspace = SS //First system defaults to "hyperspace" AKA transit.
	for(var/instance in subtypesof(/datum/starsystem))
		var/datum/starsystem/S = new instance
		systems += S

/datum/controller/subsystem/starsystem/proc/set_timer()
	addtimer(CALLBACK(src, .proc/spawn_enemies), rand(10 MINUTES, 15 MINUTES)) //Mr Gaeta, start the clock.

/datum/controller/subsystem/starsystem/proc/spawn_enemies() //A very simple way of having a gameplay loop. Every couple of minutes, the Syndicate appear in a system, the ship has to chase them.
	var/datum/starsystem/current_system //Dont spawn enemies where theyre currently at
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(!OM.main_overmap)
			continue
		OM.current_system = find_system(OM) //The ship doesnt start with a system assigned by default
		current_system = OM?.current_system
	for(var/datum/starsystem/SS in systems)
		if(SS == current_system)
			continue
		if(SS.spawn_enemies())
			priority_announce("Attention all ships, set condition 1 throughout the fleet. Syndicate incursion detected in: [SS]. All ships must repel the invasion.", "Naval Command")

/datum/starsystem
	var/name = "Hyperspace"
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = ZTRAIT_HYPERSPACE //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them

/datum/starsystem/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/spawn_asteroids), 30 SECONDS)

/datum/starsystem/proc/spawn_asteroids()
	if(asteroids.len >= 6)
		message_admins("Asteroids failed to spawn in [src] due to over population of asteroids. Tell the ship to do mining or shoot them down.")
		return //Too many asteroids mane
	var/turf/destination = null
	for(var/z in SSmapping.levels_by_trait(level_trait))
		var/turf/exit = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z)) //Plop them bang in the center of the system.
		destination = get_turf(pick(orange(20,exit)))
		if(!destination)
			message_admins("WARNING: The [name] system has no exit point for ships! You probably forgot to set the [level_trait]:1 setting for that Z in your map's JSON file.")
			return
	new /obj/structure/asteroid(get_turf(pick(orange(5, destination)))) //Guaranteed at least some asteroids that they can pull in to start with.
	new /obj/structure/asteroid(get_turf(pick(orange(5, destination))))
	for(var/i = 0, i< rand(3,6), i++)
		var/roid_type = pick(/obj/structure/asteroid, /obj/structure/asteroid/medium, /obj/structure/asteroid/large)
		var/turf/random_dest = get_turf(locate(rand(20,220), rand(20,220), destination.z))
		var/obj/structure/asteroid/roid = new roid_type(random_dest)
		asteroids += roid
		RegisterSignal(roid, COMSIG_PARENT_QDELETING , .proc/remove_asteroid, roid) //Add a listener component to check when a ship is killed, and thus check if the incursion is cleared.

/datum/starsystem/proc/remove_asteroid(obj/structure/asteroid/AS)
	asteroids -= AS

/datum/starsystem/proc/spawn_enemies() //Method for spawning enemies in a random distribution in the center of the system.
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
	return TRUE

/datum/starsystem/proc/remove_enemy(var/obj/structure/overmap/OM) //Method to remove an enemy from the list of active threats in a system
	enemies_in_system -= OM
	check_completion()

/datum/starsystem/proc/check_completion() //Method to check if the ship has completed their active mission or not
	if(!enemies_in_system.len)
		priority_announce("All Syndicate targets in [src] have been dispatched. Return to standard patrol duties. A completion bonus of [reward] credits has been credited to your allowance.", "Naval Command")
		var/split_reward = reward / 2
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		D.adjust_money(split_reward)
		var/datum/bank_account/DD = SSeconomy.get_dep_account(ACCOUNT_MUN)
		DD.adjust_money(split_reward)
		SSstarsystem?.set_timer()
		return TRUE
	else
		return FALSE

/datum/starsystem/astraeus
	name = "Astraeus"
	parallax_property = "nebula" //If you want things to appear in the background when you jump to this system, do this.
	level_trait = ZTRAIT_ASTRAEUS //The Ztrait of the zlevel that this system leads to
	visitable = TRUE

/datum/starsystem/corvi
	name = "Corvi"
	parallax_property = "icefield"
	level_trait = ZTRAIT_CORVI
	visitable = TRUE

/datum/starsystem/proc/transfer_ship(obj/structure/overmap/OM)
	var/turf/destination
	for(var/z in SSmapping.levels_by_trait(level_trait))
		destination = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), z)) //Plop them bang in the center of the system.
	if(!destination)
		message_admins("WARNING: The [name] system has no exit point for ships! You probably forgot to set the [level_trait]:1 setting for that Z in your map's JSON file.")
		return
	OM.forceMove(destination)
	OM.current_system = src