//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(starsystem)
	name = "Starsystem"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0 //Last time an AI controlled ship attacked the players
	var/modifier = 0 //Time step modifier for overmap combat - also matches curreny OEH weight
	var/list/systems = list()
	var/datum/starsystem/hyperspace //The transit level for ships
	var/bounty_pool = 0 //Bounties pool to be delivered for destroying syndicate ships
	var/list/enemy_types = list()
	var/list/enemy_blacklist = list()

/datum/controller/subsystem/starsystem/fire() //Overmap combat events control system, adds weight to combat events over time spent out of combat
	if(last_combat_enter + (5000 + (1000 * modifier)) < world.time) //Checking the last time we started combat with the current time
		var/datum/round_event_control/_overmap_event_handler/OEH = locate(/datum/round_event_control/_overmap_event_handler) in SSevents.control
		modifier ++ //Increment time step
		if(modifier == 13) // 30 minutes
			var/message = pick(	"This is Centcomm to all vessels assigned to patrol the Astraeus-Corvi routes, please continue on your patrol route", \
								"This is Centcomm to all vessels assigned to patrol the Astraeus-Corvi routes, we are not paying you to idle in space during your assigned patrol schedule", \
								"This is Centcomm to the patrol vessel currently assigned to the Astraeus-Corvi route, you are expected to fulfill your assigned mission")
			priority_announce("[message]", "Naval Command") //Warn players for idleing too long
		if(modifier == 22) // 45 minutes
			var/total_deductions
			for(var/account in SSeconomy.department_accounts)
				var/datum/bank_account/D = SSeconomy.get_dep_account(account)
				total_deductions += D.account_balance / 2
				D.account_balance = D.account_balance / 2
			priority_announce("Significant damage has been caused to NanoTrasen assets due to the inactivity of your vessel. [total_deductions] credits have been deducted across all departmental budgets to cover expenses.", "Naval Command")
		if(istype(OEH))
			OEH.weight ++ //Increment probabilty via SSEvent

/datum/controller/subsystem/starsystem/New()
	. = ..()
	instantiate_systems()
	enemy_types = subtypesof(/obj/structure/overmap/syndicate/ai)
	for(var/type in enemy_blacklist)
		enemy_types -= type


/datum/controller/subsystem/starsystem/proc/add_blacklist(what)
	enemy_blacklist += what
	if(locate(what) in enemy_types)
		enemy_types -= what

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
		if(OM.role == MAIN_OVERMAP)
			return OM

/datum/controller/subsystem/starsystem/proc/find_main_miner() //Find the mining ship
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role == MAIN_MINING_SHIP)
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
		if(OM.role != MAIN_OVERMAP)
			continue
		OM.current_system = find_system(OM) //The ship doesnt start with a system assigned by default
		current_system = OM?.current_system
	for(var/datum/starsystem/starsys in systems)
		if(starsys != current_system)
			starsys.mission_sector = TRUE //set this sector to be the active mission
			starsys.spawn_asteroids() //refresh asteroids in the system
			for(var/i = 0, i < starsys.difficulty_budget, i++) //number of enemies is set via the starsystem vars
				var/enemy_type = pick(enemy_types) //Spawn a random set of enemies.
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
	new /obj/structure/overmap/asteroid(get_turf(pick(orange(5, destination)))) //Guaranteed at least some asteroids that they can pull in to start with.
	new /obj/structure/overmap/asteroid(get_turf(pick(orange(5, destination))))
	for(var/i = 0, i< rand(3,6), i++)
		var/roid_type = pick(/obj/structure/overmap/asteroid, /obj/structure/overmap/asteroid/medium, /obj/structure/overmap/asteroid/large)
		var/turf/random_dest = get_turf(locate(rand(20,220), rand(20,220), destination.z))
		var/obj/structure/overmap/asteroid/roid = new roid_type(random_dest)
		asteroids += roid
		RegisterSignal(roid, COMSIG_PARENT_QDELETING , .proc/remove_asteroid, roid) //Add a listener component to check when a ship is killed, and thus check if the incursion is cleared.

/datum/starsystem/proc/remove_asteroid(obj/structure/overmap/asteroid/AS)
	asteroids -= AS

/datum/starsystem/proc/add_enemy(obj/structure/overmap/OM)
	enemies_in_system += OM
	RegisterSignal(OM, COMSIG_PARENT_QDELETING , .proc/remove_enemy, OM)

/datum/starsystem/proc/remove_enemy(var/obj/structure/overmap/OM) //Method to remove an enemy from the list of active threats in a system
	enemies_in_system -= OM
	check_completion()

/datum/starsystem/proc/check_completion() //Method to check if the ship has completed their active mission or not
	if(!enemies_in_system.len)
		set_security_level("blue")
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
