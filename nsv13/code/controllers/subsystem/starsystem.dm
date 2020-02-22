//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(starsystem)
	name = "Starsystem"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0 //Last time an AI controlled ship attacked the players
	var/modifier = 0 //Time step modifier for overmap combat
	var/list/systems = list()
	var/datum/starsystem/hyperspace //The transit level for ships
	var/bounty_pool = 0 //Bounties pool to be delivered for destroying syndicate ships

/datum/controller/subsystem/starsystem/fire() //Overmap combat events control system, adds weight to combat events over time spent out of combat
	if(last_combat_enter + (5000 + (1000 * modifier)) < world.time) //Checking the last time we started combat with the current time
		var/datum/round_event_control/lone_hunter/LH = locate(/datum/round_event_control/lone_hunter) in SSevents.control
		var/datum/round_event_control/belt_rats/BR = locate(/datum/round_event_control/belt_rats) in SSevents.control
		modifier += 1 //Increment time step
		if(modifier == 13) // 30 minutes
			var/message = pick(	"This is Centcomm to all vessels assigned to patrol the Astraeus-Corvi routes, please continue on your patrol route", \
								"This is Centcomm to all vessels assigned to patrol the Astraeus-Corvi routes, we are not paying you to idle in space during your assigned patrol schedule", \
								"This is Centcomm to the patrol vessel currently assigned to the Astraeus-Corvi route, you are expected to fulfill your assigned mission")
			priority_announce("[message]", "Naval Command") //Warn players for idleing too long
		if(modifier == 22) // 45 minutes
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			D.adjust_money(-D)
			priority_announce("Significant damage has been caused to NanoTrasen assets due to the inactivity of your vessel. Funds have been deducted from the cargo budget to cover expenses.")
		if(istype(LH))
			LH.weight += 1 //Increment probabilty via SSEvent
			if(LH.weight % 5 == 0)
				message_admins("The ship has been out of combat for [last_combat_enter]. The weight of [LH.name] is now [LH.weight]")
				log_game("The ship has been out of combat for [last_combat_enter]. The weight of [LH.name] is now [LH.weight]")
		if(istype(BR))
			BR.weight += 1 //Increment probabilty via SSEvent
			if(BR.weight % 5 == 0)
				message_admins("The ship has been out of combat for [last_combat_enter]. The weight of [BR.name] is now [BR.weight]")
				log_game("The ship has been out of combat for [last_combat_enter]. The weight of [BR.name] is now [BR.weight]")

/datum/controller/subsystem/starsystem/proc/event_info() //Admin command for debugging output
	var/datum/round_event_control/lone_hunter/LH = locate(/datum/round_event_control/lone_hunter) in SSevents.control
	var/datum/round_event_control/belt_rats/BR = locate(/datum/round_event_control/belt_rats) in SSevents.control
	message_admins("Current time: [world.time] | Last Combat: [last_combat_enter] | Modifier: [modifier] | [LH.name]: [LH.weight] | [BR.name]: [BR.weight]")

/datum/controller/subsystem/starsystem/proc/weighting_reset() //All overmap combat events need to be populated in this proc - this is used to reset the weight of every combat encounter once an encounter is spawned
	var/datum/round_event_control/lone_hunter/LH = locate(/datum/round_event_control/lone_hunter) in SSevents.control
	var/datum/round_event_control/belt_rats/BR = locate(/datum/round_event_control/belt_rats) in SSevents.control
	LH.weight = 0
	BR.weight = 0

/datum/controller/subsystem/starsystem/New()
	. = ..()
	instantiate_systems()

/datum/controller/subsystem/starsystem/proc/instantiate_systems()
	cycle_gameplay_loop() //Start the gameplay loop
	cycle_bounty_timer() //Start the bounty timers
	var/datum/starsystem/SS = new
	hyperspace = SS //First system defaults to "hyperspace" AKA transit.
	for(var/instance in subtypesof(/datum/starsystem))
		var/datum/starsystem/S = new instance
		systems += S

///////SPAWN SYSTEM///////

/datum/controller/subsystem/starsystem/proc/find_main_overmap() //Find the main ship
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.main_overmap)
			return OM

/datum/controller/subsystem/starsystem/proc/find_main_miner() //Find the mining ship
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.main_miner)
			return OM

/datum/controller/subsystem/starsystem/proc/find_system(obj/structure/overmap/OM) //Used to determine what system a ship is currently in. Famously used to determine the starter system that you've put the ship in.
	var/datum/starsystem/found
	for(var/datum/starsystem/S in systems)
		for(var/thez in SSmapping.levels_by_trait(S.level_trait))
			if(thez == OM.z)
				found = S
				break
	return found

/datum/controller/subsystem/starsystem/proc/modular_spawn_enemies(obj/structure/overmap/OM, datum/starsystem/target_sys)//Select Ship to Spawn and Location via Z-Trait
	var/list/levels = SSmapping.levels_by_trait(target_sys.level_trait)
	if(levels?.len == 1)
		var/turf/exit = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), levels[1])) //Plop them bang in the center of the system.
		var/turf/destination = get_turf(pick(orange(20,exit)))
		var/obj/structure/overmap/enemy = new OM(destination)
		target_sys.add_enemy(enemy)
	else if(levels?.len > 1)
		message_admins("More than one level found for [target_sys]!")
		return
	else
		message_admins("No levels forund for [target_sys]!")
		return

///////BOUNTIES//////

/datum/controller/subsystem/starsystem/proc/bounty_payout()
	cycle_bounty_timer()
	if(!bounty_pool) //No need to spam when there is no cashola payout
		return
	minor_announce("Bounty Payment Of [bounty_pool] Credits Processed", "Naval Command")
	var/split_bounty = bounty_pool / 2 //Split between our two accounts
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	D.adjust_money(split_bounty)
	var/datum/bank_account/DD = SSeconomy.get_dep_account(ACCOUNT_MUN)
	DD.adjust_money(split_bounty)
	bounty_pool = 0

/datum/controller/subsystem/starsystem/proc/cycle_bounty_timer()
	addtimer(CALLBACK(src, .proc/bounty_payout), 15 MINUTES) //Cycle bounty payments every 15 minutes

//////GAMEPLAY LOOP///////

/datum/controller/subsystem/starsystem/proc/cycle_gameplay_loop()
	addtimer(CALLBACK(src, .proc/gameplay_loop), rand(10 MINUTES, 15 MINUTES)) //Cycle the gameplay loop 10 to 15 minutes after the previous sector is cleared

/datum/controller/subsystem/starsystem/proc/gameplay_loop() //A very simple way of having a gameplay loop. Every couple of minutes, the Syndicate appear in a system, the ship has to destroy them.
	var/datum/starsystem/current_system //Dont spawn enemies where theyre currently at
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //The ship doesnt start with a system assigned by default
		if(!OM.main_overmap)
			continue
		OM.current_system = find_system(OM) //The ship doesnt start with a system assigned by default
		current_system = OM?.current_system
	for(var/datum/starsystem/starsys in systems)
		if(starsys != current_system)
			starsys.mission_sector = TRUE //set this sector to be the active mission
			starsys.spawn_asteroids() //refresh asteroids in the system
			for(var/i = 0, i < starsys.difficulty_budget, i++) //number of enemies is set via the starsystem vars
				var/enemy_type = pick(subtypesof(/obj/structure/overmap/syndicate)) //Spawn a random set of enemies.
				modular_spawn_enemies(enemy_type, starsys)
			priority_announce("Attention all ships, set condition 1 throughout the fleet. Syndicate incursion detected in: [starsys]. All ships must repel the invasion.", "Naval Command")

//////STARSYSTEM DATUM///////

/datum/starsystem
	var/name = "Hyperspace"
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = ZTRAIT_HYPERSPACE //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them
	var/mission_sector = FALSE
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

/datum/starsystem/proc/add_enemy(obj/structure/overmap/OM)
	enemies_in_system += OM
	RegisterSignal(OM, COMSIG_PARENT_QDELETING , .proc/remove_enemy, OM)

/datum/starsystem/proc/remove_enemy(var/obj/structure/overmap/OM) //Method to remove an enemy from the list of active threats in a system
	enemies_in_system -= OM
	check_completion()

/datum/starsystem/proc/check_completion() //Method to check if the ship has completed their active mission or not
	if(!enemies_in_system.len)
		priority_announce("All Syndicate targets in [src] have been dispatched. Return to standard patrol duties.", "Naval Command")
		if(mission_sector == TRUE)
			SSstarsystem?.cycle_gameplay_loop()
			mission_sector = FALSE
		return TRUE
	else
		return FALSE

//////STARSYSTEM LIST///////

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