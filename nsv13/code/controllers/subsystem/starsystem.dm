//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(star_system)
	name = "star_system"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0 //Last time an AI controlled ship attacked the players
	var/modifier = 0 //Time step modifier for overmap combat - also matches curreny OEH weight
	var/list/systems = list()
	var/datum/star_system/hyperspace //The transit level for ships
	var/bounty_pool = 0 //Bounties pool to be delivered for destroying syndicate ships
	var/list/enemy_types = list()
	var/list/enemy_blacklist = list()
	var/list/ships = list() //2-d array. Format: list("ship" = ship, "x" = 0, "y" = 0, "current_system" = null, "target_system" = null, "transit_time" = 0)

/datum/controller/subsystem/star_system/fire() //Overmap combat events control system, adds weight to combat events over time spent out of combat
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

/datum/controller/subsystem/star_system/New()
	. = ..()
	instantiate_systems()
	enemy_types = subtypesof(/obj/structure/overmap/syndicate/ai)
	for(var/type in enemy_blacklist)
		enemy_types -= type


/datum/controller/subsystem/star_system/proc/add_blacklist(what)
	enemy_blacklist += what
	if(locate(what) in enemy_types)
		enemy_types -= what

/datum/controller/subsystem/star_system/proc/instantiate_systems()
	cycle_gameplay_loop() //Start the gameplay loop
	cycle_bounty_timer() //Start the bounty timers
	var/datum/star_system/SS = new
	hyperspace = SS //First system defaults to "hyperspace" AKA transit.
	SS.hidden = TRUE
	for(var/instance in subtypesof(/datum/star_system))
		var/datum/star_system/S = new instance
		systems += S

///////SPAWN SYSTEM///////

/datum/controller/subsystem/star_system/proc/find_main_overmap() //Find the main ship
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role == MAIN_OVERMAP)
			return OM

/datum/controller/subsystem/star_system/proc/find_main_miner() //Find the mining ship
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role == MAIN_MINING_SHIP)
			return OM

/datum/controller/subsystem/star_system/proc/system_by_id(id)
	for(var/datum/star_system/sys in systems)
		if(sys.name == id)
			return sys

/datum/controller/subsystem/star_system/proc/find_system(obj/structure/overmap/OM) //Used to determine what system a ship is currently in. Famously used to determine the starter system that you've put the ship in.
	if(!ships[OM])
		return
	var/datum/star_system/system = system_by_id(OM.starting_system)
	ships[OM]["current_system"] = system
	return system

/datum/controller/subsystem/star_system/proc/modular_spawn_enemies(obj/structure/overmap/OM, datum/star_system/target_sys)//Select Ship to Spawn and Location via Z-Trait
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

/datum/controller/subsystem/star_system/proc/bounty_payout()
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

/datum/controller/subsystem/star_system/proc/cycle_bounty_timer()
	addtimer(CALLBACK(src, .proc/bounty_payout), 15 MINUTES) //Cycle bounty payments every 15 minutes

//////GAMEPLAY LOOP///////

/datum/controller/subsystem/star_system/proc/cycle_gameplay_loop()
	addtimer(CALLBACK(src, .proc/gameplay_loop), rand(10 MINUTES, 15 MINUTES)) //Cycle the gameplay loop 10 to 15 minutes after the previous sector is cleared

/datum/controller/subsystem/star_system/proc/gameplay_loop() //A very simple way of having a gameplay loop. Every couple of minutes, the Syndicate appear in a system, the ship has to destroy them.
	var/datum/star_system/current_system //Dont spawn enemies where theyre currently at
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //The ship doesnt start with a system assigned by default
		if(OM.role != MAIN_OVERMAP)
			continue
		OM.current_system = find_system(OM) //The ship doesnt start with a system assigned by default
		current_system = OM?.current_system
	for(var/datum/star_system/starsys in systems)
		if(starsys != current_system)
			starsys.mission_sector = TRUE //set this sector to be the active mission
			starsys.spawn_asteroids() //refresh asteroids in the system
			for(var/i = 0, i < starsys.difficulty_budget, i++) //number of enemies is set via the star_system vars
				var/enemy_type = pick(enemy_types) //Spawn a random set of enemies.
				modular_spawn_enemies(enemy_type, starsys)
			priority_announce("Attention all ships, set condition 1 throughout the fleet. Syndicate incursion detected in: [starsys]. All ships must repel the invasion.", "Naval Command")

/datum/controller/subsystem/star_system/proc/add_ship(obj/structure/overmap/OM)
	ships[OM] = list("ship" = OM, "x" = 0, "y" = 0, "current_system" = system_by_id(OM.starting_system), "last_system" = system_by_id(OM.starting_system), "target_system" = null, "from_time" = 0, "to_time" = 0)

//Welcome to bracket hell.

//Updates the position of a given ship

/datum/controller/subsystem/star_system/proc/update_pos(obj/structure/overmap/OM)
	if(!ships[OM])
		return FALSE
	ships[OM]["x"] = (ships[OM]["current_system"]) ? ships[OM]["current_system"].x : ships[OM]["last_system"].lerp_x(ships[OM]["target_system"], get_transit_progress(OM))
	ships[OM]["y"] = (ships[OM]["current_system"]) ? ships[OM]["current_system"].y : ships[OM]["last_system"].lerp_y(ships[OM]["target_system"], get_transit_progress(OM))

/datum/controller/subsystem/star_system/proc/get_transit_progress(obj/structure/overmap/OM)
	var/list/info = ships[OM]
	if(info["current_system"])
		return 0
	return (world.time - info["from_time"])/(info["to_time"] - info["from_time"])

//////star_system DATUM///////

/datum/star_system
	var/name = "Hyperspace"
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = ZTRAIT_HYPERSPACE //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them
	var/mission_sector = FALSE


	var/x = 0 //Maximum: 1000 for now
	var/y = 0 //Maximum: 1000 for now
	var/alignment = "unaligned"
	var/visited = FALSE
	var/hidden = FALSE //Secret systems

	var/list/ships = list()

	var/danger_level = 0
	var/system_traits = NONE
	var/is_capital = FALSE
	var/list/adjacency_list = list() //Which systems are near us, by name

/datum/star_system/proc/dist(datum/star_system/other)
	var/dx = other.x - x
	var/dy = other.y - y
	return sqrt((dx * dx) + (dy * dy))

/datum/star_system/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/spawn_asteroids), 30 SECONDS)

/datum/star_system/proc/spawn_asteroids()
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

/datum/star_system/proc/remove_asteroid(obj/structure/overmap/asteroid/AS)
	asteroids -= AS

/datum/star_system/proc/add_enemy(obj/structure/overmap/OM)
	enemies_in_system += OM
	RegisterSignal(OM, COMSIG_PARENT_QDELETING , .proc/remove_enemy, OM)

/datum/star_system/proc/remove_enemy(var/obj/structure/overmap/OM) //Method to remove an enemy from the list of active threats in a system
	enemies_in_system -= OM
	check_completion()

/datum/star_system/proc/check_completion() //Method to check if the ship has completed their active mission or not
	if(!enemies_in_system.len)
		set_security_level("blue")
		priority_announce("All Syndicate targets in [src] have been dispatched. Return to standard patrol duties.", "Naval Command")
		if(mission_sector == TRUE)
			SSstar_system?.cycle_gameplay_loop()
			mission_sector = FALSE
		return TRUE
	else
		return FALSE

/datum/star_system/proc/lerp_x(datum/star_system/other, t)
	return x + (t * (other.x - x))

/datum/star_system/proc/lerp_y(datum/star_system/other, t)
	return y + (t * (other.y - y))

//////star_system LIST///////
/datum/star_system/sol
	name = "Sol"
	is_capital = TRUE
	x = 70
	y = 45
	alignment = "nanotrasen"
	adjacency_list = list("Astraeus","Corvi")

/datum/star_system/capital/syndicate
	name = "Dolos"
	is_capital = TRUE
	x = 28
	y = 70
	alignment = "syndicate"

/datum/star_system/astraeus
	name = "Astraeus"
	parallax_property = "nebula" //If you want things to appear in the background when you jump to this system, do this.
	level_trait = ZTRAIT_ASTRAEUS //The Ztrait of the zlevel that this system leads to
	visitable = TRUE
	x = 40 //Maximum: 1000 for now
	y = 30 //Maximum: 1000 for now
	alignment = "unaligned"
	adjacency_list = list("Sol")

/datum/star_system/corvi
	name = "Corvi"
	parallax_property = "icefield"
	level_trait = ZTRAIT_CORVI
	visitable = TRUE
	x = 10 //Maximum: 1000 for now
	y = 100 //Maximum: 1000 for now
	alignment = "unaligned"
	adjacency_list = list("Dolos")