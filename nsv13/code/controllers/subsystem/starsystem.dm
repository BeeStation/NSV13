//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(star_system)
	name = "star_system"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0 //Last time an AI controlled ship attacked the players
	var/modifier = 0 //Time step modifier for overmap combat - also matches curreny OEH weight
	var/list/systems = list()
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
	for(var/instance in subtypesof(/datum/star_system))
		var/datum/star_system/S = new instance
		if(S.name)
			systems += S
	generate_anomalies()

/datum/controller/subsystem/star_system/proc/generate_anomalies()
	for(var/datum/star_system/S in systems)
		if(S.system_type)
			S.apply_system_effects()
		else
			S.generate_anomaly()

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

/datum/controller/subsystem/star_system/proc/spawn_ship(obj/structure/overmap/OM, datum/star_system/target_sys, center=FALSE)//Select Ship to Spawn and Location via Z-Trait
	if(target_sys.occupying_z)
		message_admins("[OM] successfully spawned in [target_sys]")
		var/turf/destination = null
		if(center)
			destination = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), target_sys.occupying_z)) //Plop them bang in the center of the system as requested. This is usually saved for wormholes.
		else
			destination = get_turf(locate(rand(50, world.maxx), rand(50, world.maxy), target_sys.occupying_z)) //Spawn them somewhere in the system. I don't really care where.
		var/obj/structure/overmap/enemy = new OM(destination)
		target_sys.add_enemy(enemy)
	else
		message_admins("Enqued a [OM] for spawning in [target_sys]")
		target_sys.enemy_queue += OM

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
		current_system = ships[OM]["current_system"]
	for(var/datum/star_system/starsys in systems)
		if(starsys != current_system && !starsys.hidden && starsys.alignment == "unaligned") //Spawn is a safe zone.
			starsys.mission_sector = TRUE //set this sector to be the active mission
			starsys.spawn_asteroids() //refresh asteroids in the system
			for(var/i = 0, i < starsys.difficulty_budget, i++) //number of enemies is set via the star_system vars
				var/enemy_type = pick(enemy_types) //Spawn a random set of enemies.
				spawn_ship(enemy_type, starsys)
			priority_announce("Attention all ships, set condition 1 throughout the fleet. Syndicate incursion detected in: [starsys]. All ships must repel the invasion.", "Naval Command")
			return

/datum/controller/subsystem/star_system/proc/add_ship(obj/structure/overmap/OM)
	ships[OM] = list("ship" = OM, "x" = 0, "y" = 0, "current_system" = system_by_id(OM.starting_system), "last_system" = system_by_id(OM.starting_system), "target_system" = null, "from_time" = 0, "to_time" = 0, "occupying_z" = OM.z)
	ships[OM]["current_system"].add_ship(OM)

//Welcome to bracket hell.

//Updates the position of a given ship on the starmap

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

#define THREAT_LEVEL_NONE 0
#define THREAT_LEVEL_UNSAFE 1
#define THREAT_LEVEL_DANGEROUS 2

/datum/star_system
	var/name = null //Parent type, please ignore
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = null //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them
	var/mission_sector = FALSE
	var/threat_level = THREAT_LEVEL_NONE

	var/x = 0 //Maximum: 1000 for now
	var/y = 0 //Maximum: 1000 for now
	var/alignment = "unaligned"
	var/visited = FALSE
	var/hidden = FALSE //Secret systems
	var/system_type = null //Set this to pre-spawn systems as a specific type.
	var/event_chance = 0
	var/list/possible_events = list()

	var/list/contents_positions = list()
	var/list/system_contents = list()
	var/list/enemy_queue = list()

	var/danger_level = 0
	var/system_traits = NONE
	var/is_capital = FALSE
	var/list/adjacency_list = list() //Which systems are near us, by name
	var/occupying_z = 0 //What Z-level is this  currently stored on? This will always be a number, as Z-levels are "held" by ships.

/datum/star_system/proc/dist(datum/star_system/other)
	var/dx = other.x - x
	var/dy = other.y - y
	return sqrt((dx * dx) + (dy * dy))

/datum/star_system/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/spawn_asteroids), 30 SECONDS)

/datum/star_system/proc/create_wormhole()
	for(var/datum/star_system/S in SSstar_system.systems)
		if(LAZYFIND(adjacency_list, S)) //We're already linked to that one. Skip it.
			continue
		adjacency_list += S.name
		SSstar_system.spawn_ship(/obj/effect/overmap_anomaly/wormhole, src, center=TRUE)
		var/oneway = "One-way"
		if(!LAZYFIND(S.adjacency_list, src) && prob(30)) //Two-directional wormholes, AKA valid hyperlanes, are exceedingly rare.
			S.adjacency_list += name
			oneway = "Two-way"
			SSstar_system.spawn_ship(/obj/effect/overmap_anomaly/wormhole, S, center=TRUE) //Wormholes are cool.
		message_admins("[oneway] wormhole created between [S] and [src]")
		break

//Anomalies


/datum/round_event_control/radiation_storm/deadly
	max_occurrences = 1000

/obj/effect/overmap_anomaly
	name = "Placeholder"
	var/research_points = 0

/obj/effect/overmap_anomaly/wormhole
	name = "Wormhole"
	desc = "A huge tear in the fabric of space-time that can fling you to faraway places. I wonder where it leads?"
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/tearhuge.dmi'
	icon_state = "tear"
	research_points = 5000 //These things are really valuable.

/obj/effect/overmap_anomaly/singularity
	name = "Black hole"
	desc = "A peek into the void between worlds. These stellar demons consume everything in their path. Including you."
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/blackhole.dmi'
	icon_state = "blackhole"
	research_points = 3000 //These things are pretty damn valuable, for their risk of course.
	pixel_x = -64
	pixel_y = -64
	var/list/affecting = list()
	var/list/cached_colours = list()
	var/event_horizon_range = 15 //Point of no return. Getting this close will require an emergency FTL jump or shuttle call.
	var/redshift_range = 30
	var/influence_range = 40
	var/base_pull_strength = 0.10

/obj/effect/overmap_anomaly/singularity/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/overmap_anomaly/singularity/process()
	if(!z) //Not in nullspace
		return
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(LAZYFIND(affecting, OM))
			continue
		if(get_dist(src, OM) <= influence_range)
			affecting += OM
			cached_colours[OM] = OM.color //So that say, a yellow fighter doesnt get its paint cleared by redshifting
			OM.relay(sound='nsv13/sound/effects/ship/falling.ogg', message="<span class='warning'>You feel weighed down.</span>", loop=TRUE, channel=CHANNEL_HEARTBEAT)
	for(var/obj/structure/overmap/OM in affecting)
		if(get_dist(src, OM) > influence_range)
			OM.stop_relay(CHANNEL_HEARTBEAT)
			affecting -= OM
			OM.color = cached_colours[OM]
			cached_colours[OM] = null
			for(var/mob/M in OM.mobs_in_ship)
				var/client/C = M.client
				C.color = null
			continue
		var/incidence = get_dir(OM, src)
		var/dist = get_dist(src, OM)
		if(dist <= redshift_range)
			var/redshift ="#[num2hex(130-dist,2)][num2hex(0,2)][num2hex(0,2)]"
			OM.color = redshift
			for(var/mob/M in OM.mobs_in_ship)
				var/client/C = M.client
				C.color = redshift
		if(dist <= 2)
			affecting -= OM
			OM.Destroy()
		dist = (dist > 0) ? dist : 1
		var/pull_strength = (dist > event_horizon_range) ? 0.003 : base_pull_strength
		var/succ_impulse = pull_strength/dist*dist
		if(incidence & NORTH)
			OM.velocity.y += succ_impulse
		if(incidence & SOUTH)
			OM.velocity.y -= succ_impulse
		if(incidence & EAST)
			OM.velocity.x += succ_impulse
		if(incidence & WEST)
			OM.velocity.x -= succ_impulse

/obj/effect/overmap_anomaly/wormhole/Initialize()
	. = ..()
	icon = pick('nsv13/goonstation/icons/effects/overmap_anomalies/tearhuge.dmi', 'nsv13/goonstation/icons/effects/overmap_anomalies/tearmed.dmi', 'nsv13/goonstation/icons/effects/overmap_anomalies/tearsmall.dmi')

/obj/effect/overmap_anomaly/safe
	name = "Placeholder"

/obj/effect/overmap_anomaly/safe/sun
	name = "Star"
	desc = "A huge ball of burning hydrogen that lights up space around it. Don't get too close...."
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/stellarbodies.dmi'
	icon_state = "sun"

/obj/effect/overmap_anomaly/safe/sun/red_giant
	name = "Red Giant"
	desc = "A large star that is nearing the end of its life. Burns extremely hot."
	icon_state = "redgiant"

/datum/star_system/proc/apply_system_effects()
	event_chance = 10 //Very low chance of an event happening
	var/anomaly_type = null
	switch(system_type)
		if("safe")
			possible_events = list(/datum/round_event_control/aurora_caelus)
		if("hazardous") //TODO: Make better anomalies spawn in hazardous systems scaling with threat level.
			possible_events = list(/datum/round_event_control/carp_migration, /datum/round_event_control/electrical_storm, /datum/round_event_control/belt_rats, /datum/round_event_control/lone_hunter)
		if("wormhole")
			possible_events = list(/datum/round_event_control/wormholes, /datum/round_event/anomaly) //Wormhole systems are unstable in bluespace
			event_chance = 50 //Highly unstable region of space.
			create_wormhole()
			return
		if("pirate")
			possible_events = list(/datum/round_event_control/pirates) //Well what did you think was gonna happen when you jumped into a pirate system?
		if("radioactive")
			parallax_property = "radiation_cloud" //All credit goes to https://www.filterforge.com/filters/11427.html
			possible_events = list(/datum/round_event_control/radiation_storm/deadly)
			event_chance = 100 //Radioactive systems are just that: Radioactive
		if("nebula")
			parallax_property = "nebula-thick" //All credit goes to https://www.filterforge.com/filters/11427.html
		if("quasar")
			parallax_property = "quasar" //All credit goes to https://www.filterforge.com/filters/11427.html
			possible_events = list(/datum/round_event_control/grey_tide, /datum/round_event_control/ion_storm, /datum/round_event_control/communications_blackout)
			event_chance = 100 //Quasars are screwy.
		if("debris")
			parallax_property = "rocks"
			possible_events = list(/datum/round_event_control/space_dust, /datum/round_event_control/meteor_wave)
		if("icefield")
			parallax_property = "icefield"
		if("gas")
			parallax_property = "gas"
		if("ice_planet")
			parallax_property = "ice_planet"
		if("blackhole")
			anomaly_type = /obj/effect/overmap_anomaly/singularity
			parallax_property = "pitchblack"

	if(!anomaly_type)
		anomaly_type = pick(subtypesof(/obj/effect/overmap_anomaly/safe))
	SSstar_system.spawn_ship(anomaly_type, src)

/datum/star_system/proc/generate_anomaly()
	if(prob(15)) //Low chance of spawning a wormhole twixt us and another system.
		create_wormhole()
	switch(threat_level)
		if(THREAT_LEVEL_NONE)
			system_type = pick("safe", "nebula", "gas", "icefield", "ice_planet") //Threat level 0 denotes starter systems, so they just have "fluff" anomalies like gas clouds and whatever.
		if(THREAT_LEVEL_UNSAFE) //Unaligned and Syndicate systems have a chance to spawn threats. But nothing major.
			system_type = pick("debris", "pirate", "nebula", "hazardous")
		if(THREAT_LEVEL_DANGEROUS) //Extreme threat level. Time to break out the most round destroying anomalies.
			system_type = pick("quasar", "radioactive", "blackhole")
	message_admins("[src] was selected as a [system_type] system.")
	apply_system_effects()

/datum/star_system/proc/spawn_asteroids()
	for(var/I = 0; I < rand(2, 6); I++)
	var/roid_type = pick(/obj/structure/overmap/asteroid, /obj/structure/overmap/asteroid/medium, /obj/structure/overmap/asteroid/large)
	SSstar_system.spawn_ship(roid_type, src)

/datum/star_system/proc/add_enemy(obj/structure/overmap/OM)
	if(istype(OM, /obj/structure/overmap) && OM.ai_controlled)
		enemies_in_system += OM
		RegisterSignal(OM, COMSIG_PARENT_QDELETING , .proc/remove_enemy, OM)
	add_ship(OM)

/datum/star_system/proc/remove_enemy(var/obj/structure/overmap/OM) //Method to remove an enemy from the list of active threats in a system
	if(LAZYFIND(enemies_in_system, OM))
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

//////star_system LIST (order of appearance)///////
/datum/star_system/sol
	name = "Sol"
	is_capital = TRUE
	x = 0
	y = 10
	alignment = "nanotrasen"
	adjacency_list = list("Alpha Centauri")

/datum/star_system/alpha_centauri
	name = "Alpha Centauri"
	x = 20
	y = 15
	alignment = "nanotrasen"
	adjacency_list = list("Sol","Wolf 359")

/datum/star_system/wolf359
	name = "Wolf 359"
	x = 40
	y = 20
	alignment = "nanotrasen"
	adjacency_list = list("Alpha Centauri", "Lalande 21185","Tau Ceti")

/datum/star_system/lalande21185
	name = "Lalande 21185"
	x = 25
	y = 25
	system_type = "icefield"
	alignment = "nanotrasen"
	adjacency_list = list("Tau Ceti", "Wolf 359")

/datum/star_system/tau_ceti
	name = "Tau Ceti"
	x = 60
	y = 30
	system_type = "ice_planet"
	alignment = "nanotrasen"
	adjacency_list = list("Canis Minoris", "Canis Majoris","Lalande 21185","Wolf 359", "Eridani")

/datum/star_system/canis_majoris
	name = "Canis Majoris"
	x = 50
	y = 35
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Tau Ceti","Scorvio")

/datum/star_system/scorvio
	name = "Scorvio"
	x = 55
	y = 40
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Canis Majoris", "Cygni")

/datum/star_system/cygni
	name = "Cygni"
	x = 80
	y = 45
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Eridani","Scorvio", "Antares")

/datum/star_system/eridani
	name = "Eridani"
	x = 70
	y = 50
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Rubicon", "Theta Hydri","Tau Ceti", "Cygni")

/datum/star_system/theta_hydri
	name = "Theta Hydri"
	x = 85
	y = 55
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Eridani", "Cygni")

/datum/star_system/canis_minoris
	name = "Canis Minoris"
	x = 80
	y = 30
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Tau Ceti","Antares")

/datum/star_system/antares
	name = "Antares"
	x = 100
	y = 45
	alignment = "unaligned"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Cygni", "Canis Minoris", "Tortuga")

/datum/star_system/tortuga
	name = "Tortuga"
	x = 110
	y = 45
	alignment = "syndicate"
	system_type = "pirate" //Guranteed piratical action!
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("P9X-334", "Antares")

/datum/star_system/p9x334
	name = "P9X-334"
	x = 105
	y = 50
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("P7X-294", "Tortuga")

/datum/star_system/p7x294
	name = "P7X-294"
	x = 120
	y = 70
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("P9X-334", "N64-775")

/datum/star_system/n64775
	name = "N64-775"
	x = 135
	y = 80
	system_type = "nebula"
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("P7X-294")

/datum/star_system/rubicon
	name = "Rubicon"
	x = 80
	y = 60
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Eridani", "Theta Hydri", "Vorash")

/datum/star_system/vorash
	name = "Vorash"
	x = 70
	y = 63
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Rubicon", "Solaris A","Solaris B", "Solaris C")

/datum/star_system/solarisA
	name = "Solaris A"
	x = 50
	y = 55
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Solaris B", "Solaris C", "Vorash")

/datum/star_system/solarisB
	name = "Solaris B"
	x = 55
	y = 50
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Solaris A", "Solaris C", "Vorash", "P3X-754")

/datum/star_system/p3x754
	name = "P3X-754"
	x = 40
	y = 50
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Solaris B","P59-723")

/datum/star_system/solarisC
	name = "Solaris C"
	x = 60
	y = 45
	alignment = "syndicate"
	threat_level = THREAT_LEVEL_UNSAFE
	adjacency_list = list("Solaris A", "Solaris B", "Vorash", "Scorvio")

/datum/star_system/p59723
	name = "P59-723"
	x = 40
	y = 60
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("N94-19X", "P3X-754")

/datum/star_system/n9419x
	name = "N94-19X"
	x = 70
	y = 70
	system_type = "nebula"
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("P59-723", "P32-901", "Dolos", "DATA EXPUNGED") //Links to dolos, only unlocks on special occasions.)

/datum/star_system/p32901
	name = "P32-901"
	x = 100
	y = 60
	system_type = "blackhole"
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("N94-19X")

/datum/star_system/blacksite
	name = "DATA EXPUNGED"
	x = 150
	y = 100
	alignment = "uncharted"
	system_type = "wormhole" //here's your guaranteed wormhole boyos. Expect chaos
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("N94-19X")

/datum/star_system/dolos
	name = "Dolos"
	x = 60
	y = 80
	alignment = "syndicate"
	adjacency_list = list("Abassi") //No going back from here...
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE

/datum/star_system/abassi
	name = "Abassi"
	is_capital = TRUE
	x = 40
	y = 100
	alignment = "syndicate"
	adjacency_list = list("Dolos")
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE

/*

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

*/