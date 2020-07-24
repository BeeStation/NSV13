GLOBAL_VAR_INIT(crew_transfer_risa, FALSE)

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
	var/patrols_left = 3 //Around 1 hour : 15 minutes
	var/times_cleared = 0
	var/systems_cleared = 0

/datum/controller/subsystem/star_system/fire() //Overmap combat events control system, adds weight to combat events over time spent out of combat
	if(SSmapping.config.patrol_type == "passive")
		priority_announce("[station_name()], you have been assigned to reconnaissance and exploration this shift. Scans indicate that besides a decent number of straggling Syndicate vessels, there will be little threat to your operations. You are granted permission to proceed at your own pace.", "[capitalize(SSmapping.config.faction)] Naval Command")
		for(var/datum/star_system/SS in systems)
			if(SS.name == "Risa Station")
				SS.hidden = FALSE
		can_fire = FALSE //And leave it at that.
		return FALSE //Don't karmic people if this roundtype is set to passive mode.
	if(last_combat_enter + (5000 + (1000 * modifier)) < world.time) //Checking the last time we started combat with the current time
		var/datum/round_event_control/_overmap_event_handler/OEH = locate(/datum/round_event_control/_overmap_event_handler) in SSevents.control
		modifier ++ //Increment time step
		if(modifier == 13 && patrols_left > 0) // 30 minutes
			var/message = pick(	"This is Centcomm to all vessels assigned to patrol the Abassi Ridge, please continue on your patrol route", \
								"This is Centcomm to all vessels assigned to patrol the Abassi Ridge, we are not paying you to idle in space during your assigned patrol schedule", \
								"This is Centcomm to the patrol vessel currently assigned to the Abassi Ridge, you are expected to fulfill your assigned mission")
			priority_announce("[message]", "Naval Command") //Warn players for idleing too long
		if(modifier == 18 && patrols_left > 0)
			priority_announce("This is White Rapids command to all vessels assigned to patrol the Abassi Ridge. The Syndicate's agressive expansion efforts have been left unchecked, and they appear to be amassing an invasion force. Destruction of patrolling Syndicate fleets is paramount to avoid an all out assault.", "Deep Space Tracking Installation")
		if(modifier == 20 && patrols_left > 0)
			priority_announce("[station_name()] is no longer responding to commands. Enacting emergency defense conditions. All shipside squads must assist in getting the ship ready for combat by any means necessary.", "WhiteRapids Administration Corps")
			set_security_level(SEC_LEVEL_RED)
		if(modifier == 22 && patrols_left > 0) // 45 minutes of inactivity, or they've ended their official patrol
			var/total_deductions
			for(var/account in SSeconomy.department_accounts)
				var/datum/bank_account/D = SSeconomy.get_dep_account(account)
				total_deductions += D.account_balance / 2
				D.account_balance = D.account_balance / 2
			var/datum/star_system/target = system_by_id("Tau Ceti")
			priority_announce("Attention all ships throughout the fleet, assume DEFCON 1. A Syndicate invasion force has been spotted in [target]. All fleets must return to allied space and assist in the defense.", "White Rapids Fleet Command")
			minor_announce("[station_name()]. Your inactivity has forced us to redirect [total_deductions] from your budget to scramble a defensive force capable of defending Earth and her territories.", "Naval Command")
			var/datum/fleet/F = new /datum/fleet/earthbuster()
			target.fleets += F
			F.current_system = target
			F.assemble(target)

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
		var/turf/destination = null
		if(center)
			destination = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), target_sys.occupying_z)) //Plop them bang in the center of the system as requested. This is usually saved for wormholes.
		else
			destination = get_turf(locate(rand(50, world.maxx), rand(50, world.maxy), target_sys.occupying_z)) //Spawn them somewhere in the system. I don't really care where.
		var/obj/structure/overmap/enemy = new OM(destination)
		target_sys.add_ship(enemy)
	else
		target_sys.enemy_queue += OM

//Specific case for anomalies. They need to be spawned in for research to scan them.

/datum/controller/subsystem/star_system/proc/spawn_anomaly(anomaly_type, datum/star_system/target_sys, center=FALSE)
	if(target_sys.occupying_z)
		spawn_ship(anomaly_type, target_sys, center)
		return
	var/turf/destination = null
	if(center)
		destination = get_turf(locate(round(world.maxx * 0.5, 1), round(world.maxy * 0.5, 1), 1))
	else
		destination = get_turf(locate(rand(50, world.maxx), rand(50, world.maxy), 1))
	var/obj/effect/overmap_anomaly/anomaly = new anomaly_type(destination)
	target_sys.contents_positions[anomaly] = list("x" = anomaly.x, "y" = anomaly.y) //Cache the ship's position so we can regenerate it later.
	target_sys.system_contents += anomaly
	anomaly.moveToNullspace() //Anything that's an NPC should be stored safely in nullspace until we return.

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
	addtimer(CALLBACK(src, .proc/gameplay_loop), rand(10 MINUTES, 15 MINUTES)) //Cycle the gameplay loop 10 to 15 minutes after the previous sector is made hostile.

//For extremely robust crews who wish to earn cooler medals.
/datum/controller/subsystem/star_system/proc/reset_gameplay_loop()
	patrols_left = initial(patrols_left)
	systems_cleared = 0

/datum/controller/subsystem/star_system/proc/check_completion()
	if(patrols_left <= 0 && systems_cleared >= initial(patrols_left))
		var/medal_type = null //Reward good players.
		switch(times_cleared)
			if(0)
				priority_announce("Attention [station_name()]. You have completed your assigned patrol and are now eligible for a crew transfer. \
				Your navigational computers have been programmed with the coordinates of the nearest starbase where you may claim your allotted shore leave. \
				You are under no obligation to remain in this sector, and you have been taken off of active patrol status. If you wish to continue with exploratory missions or other activities you are free to do so.", "Naval Command")
				medal_type = MEDAL_CREW_COMPETENT
			if(1)
				priority_announce("Crew of [station_name()]. Your dedication to your mission is admirable, we commend you for your continued participation in combat.\
				We remind you that you are still free to return to Risa Station for a crew transfer, and that your continued combat is not necessary.", "Naval Command")
				medal_type = MEDAL_CREW_VERYCOMPETENT
			if(2) //Ok..this is kinda impressive
				priority_announce("Attention [station_name()]. You have proven yourselves extremely competant in the battlefield, and you are all to be commended for this.\
				Your efforts have severely weakened the Syndicate's presence in this sector and we are mobilising strike force tsunami to clear the rest of the sector. \
				You can leave the rest to us. Enjoy your shore leave, you've earned it.", "White Rapids Security Council")
				medal_type = MEDAL_CREW_EXTREMELYCOMPETENT
			if(3) //By now they've cleared. 20(!) systems.
				priority_announce("[station_name()]... We are...not quite sure how you're still alive. However, the Syndicate are struggling to mobilise any more ships and we're presented with a unique opportunity to strike at their heartland.\
				You are ordered to return to home base immediately for re-arming, repair and a crew briefing", "The assembled Nanotrasen Admiralty")
				medal_type = MEDAL_CREW_HYPERCOMPETENT
		for(var/client/C in GLOB.clients)
			if(!C.mob || !SSmapping.level_trait(C.mob.z, ZTRAIT_BOARDABLE))
				continue
			SSmedals.UnlockMedal(medal_type,C)
		last_combat_enter = world.time
		for(var/datum/star_system/SS in systems)
			if(SS.name == "Risa Station")
				SS.hidden = FALSE
			SS.difficulty_budget *= 2 //Double the difficulty if the crew choose to stay.
		times_cleared ++
		addtimer(CALLBACK(src, .proc/reset_gameplay_loop), rand(15 MINUTES, 20 MINUTES)) //Give them plenty of time to go home before we give them any more missions.
		return TRUE

/datum/controller/subsystem/star_system/proc/gameplay_loop() //A very simple way of having a gameplay loop. Every couple of minutes, the Syndicate appear in a system, the ship has to destroy them.
	if(check_completion())
		return
	var/datum/star_system/current_system //Dont spawn enemies where theyre currently at
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects) //The ship doesnt start with a system assigned by default
		if(OM.role != MAIN_OVERMAP)
			continue
		current_system = ships[OM]["current_system"]
	cycle_gameplay_loop()
	var/list/possible_spawns = list()
	for(var/datum/star_system/starsys in systems)
		if(starsys != current_system && !starsys.hidden && !starsys.mission_sector && starsys.alignment != "nanotrasen" && starsys.alignment != "uncharted" && starsys.alignment != "syndicate") //Spawn is a safe zone. Uncharted systems are dangerous enough and don't need more murder.
			possible_spawns += starsys
	if(patrols_left <= 0) //They've had enough missions for one day.
		return
	if(!possible_spawns.len)
		message_admins("Failed to spawn an overmap mission as all sectors were occupied. Tell the crew to get a move on...")
		return
	var/datum/star_system/starsys = pick(possible_spawns)
	starsys.mission_sector = TRUE //set this sector to be the active mission
	starsys.spawn_asteroids() //refresh asteroids in the system
	var/fleet_type = pick(/datum/fleet/neutral, /datum/fleet/boarding, /datum/fleet/wolfpack, /datum/fleet/nuclear)
	var/datum/fleet/F = new fleet_type
	F.current_system = starsys
	starsys.fleets += F
	F.assemble(starsys)
	minor_announce("WARNING: Multiple typhoon drive signatures detected in [starsys]. Syndicate incursion underway.", "White Rapids Early Warning System")
	patrols_left --
	return

/datum/controller/subsystem/star_system/proc/add_ship(obj/structure/overmap/OM)
	ships[OM] = list("ship" = OM, "x" = 0, "y" = 0, "current_system" = system_by_id(OM.starting_system), "last_system" = system_by_id(OM.starting_system), "target_system" = null, "from_time" = 0, "to_time" = 0, "occupying_z" = OM.z)
	var/datum/star_system/curr = ships[OM]["current_system"]
	curr.add_ship(OM)

//Welcome to bracket hell.

//Updates the position of a given ship on the starmap

/datum/controller/subsystem/star_system/proc/update_pos(obj/structure/overmap/OM)
	if(!ships[OM])
		return FALSE
	var/datum/star_system/curr = ships[OM]["current_system"]
	var/datum/star_system/last = ships[OM]["last_system"]
	var/datum/star_system/targ = ships[OM]["target_system"]
	ships[OM]["x"] = (curr) ? curr.x : last.lerp_x(targ, get_transit_progress(OM))
	ships[OM]["y"] = (curr) ? curr.y : last.lerp_y(targ, get_transit_progress(OM))

/datum/controller/subsystem/star_system/proc/get_transit_progress(obj/structure/overmap/OM)
	var/list/info = ships[OM]
	if(info["current_system"])
		return FALSE
	return (world.time - info["from_time"])/(info["to_time"] - info["from_time"])

//////star_system DATUM///////

#define THREAT_LEVEL_NONE 0
#define THREAT_LEVEL_UNSAFE 2
#define THREAT_LEVEL_DANGEROUS 4

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
	var/list/wormhole_connections = list() //Where did we dun go do the wormhole to honk
	var/fleet_type = null //Wanna start this system with a fleet in it?
	var/list/fleets = list() //Fleets that are stationed here.

/datum/star_system/proc/dist(datum/star_system/other)
	var/dx = other.x - x
	var/dy = other.y - y
	return sqrt((dx * dx) + (dy * dy))

/datum/star_system/New()
	. = ..()
	if(fleet_type)
		var/datum/fleet/fleet = new fleet_type(src)
		fleet.current_system = src
		fleets += fleet
	addtimer(CALLBACK(src, .proc/spawn_asteroids), 15 SECONDS)
	addtimer(CALLBACK(src, .proc/generate_anomaly), 15 SECONDS)

/datum/star_system/proc/create_wormhole()
	var/datum/star_system/S = pick((SSstar_system.systems - src)) //Pick a random system to put the wormhole in. Make sure that's not us.
	if(!(LAZYFIND(adjacency_list, S))) //Makes sure we're not already linked.
		adjacency_list += S.name
		wormhole_connections += S.name
		SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, src, center=TRUE)
		var/oneway = "One-way"
		if(!(LAZYFIND(S.adjacency_list, src)) && prob(30)) //Two-directional wormholes, AKA valid hyperlanes, are exceedingly rare.
			S.adjacency_list += name
			S.wormhole_connections += name
			oneway = "Two-way"
			SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, S, center=TRUE) //Wormholes are cool. Like Fezzes. Fezzes are cool.
		message_admins("[oneway] wormhole created between [S] and [src]")

//Anomalies

/datum/star_system/proc/get_info()
	var/list/anomalies = list()
	for(var/obj/effect/overmap_anomaly/OA in system_contents)
		if(istype(OA))
			var/list/anomaly_info = list()
			anomaly_info["name"] = OA.name
			anomaly_info["desc"] = OA.desc
			anomaly_info["points"] = OA.research_points
			anomaly_info["scannable"] = !OA.scanned
			anomaly_info["anomaly_id"] = "\ref[OA]"
			anomalies[++anomalies.len] = anomaly_info
	return anomalies

/datum/round_event_control/radiation_storm/deadly
	max_occurrences = 1000

/obj/effect/overmap_anomaly
	name = "Placeholder"
	desc = "You shouldn't see this."
	bound_width = 64
	bound_height = 64
	var/research_points = 0
	var/scanned = FALSE
	var/specialist_research_type = null //Special techweb node unlocking.

/obj/effect/overmap_anomaly/Crossed(atom/movable/AM)
	if(istype(AM, /obj/item/projectile/bullet/torpedo/probe))
		SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, research_points)
		if(specialist_research_type)
			SSresearch.science_tech.add_point_type(specialist_research_type, research_points)
		research_points = 0
		scanned = TRUE
		minor_announce("Successfully received probe telemetry. Full astrological survey of [name] complete.", "WAYFARER subsystem")
		for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
			if(OM && OM.z == z)
				OM.relay('nsv13/sound/effects/ship/FTL.ogg')
		qdel(AM)

/obj/effect/overmap_anomaly/wormhole
	name = "Wormhole"
	desc = "A huge tear in the fabric of space-time that can fling you to faraway places. A scan of this anomaly could advance the field of space-travel by years!"
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/tearhuge.dmi'
	icon_state = "tear"
	research_points = 15000 //These things are really valuable and give you upgraded jumpdrive tech.
	bound_width = 64
	bound_height = 64
	pixel_x = -64
	pixel_y = -64
	specialist_research_type = TECHWEB_POINT_TYPE_WORMHOLE

/obj/effect/overmap_anomaly/singularity
	name = "Black hole"
	desc = "A peek into the void between worlds. These stellar demons consume everything in their path. Including you. Scanning this singularity could lead to groundbreaking discoveries in the field of quantum physics!"
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/blackhole.dmi'
	icon_state = "blackhole"
	research_points = 20000 //These things are pretty damn valuable, for their risk of course.
	pixel_x = -64
	pixel_y = -64
	var/list/affecting = list()
	var/list/cached_colours = list()
	var/event_horizon_range = 15 //Point of no return. Getting this close will require an emergency FTL jump or shuttle call.
	var/redshift_range = 30
	var/influence_range = 100
	var/base_pull_strength = 0.10

/obj/effect/overmap_anomaly/singularity/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/overmap_anomaly/singularity/process()
	if(!z) //Not in nullspace
		if(affecting && affecting.len)
			for(var/obj/structure/overmap/OM in affecting)
				stop_affecting(OM)
		return
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(LAZYFIND(affecting, OM))
			continue
		if(get_dist(src, OM) <= influence_range && OM.z == z)
			affecting += OM
			cached_colours[OM] = OM.color //So that say, a yellow fighter doesnt get its paint cleared by redshifting
			OM.relay(sound='nsv13/sound/effects/ship/falling.ogg', message="<span class='warning'>You feel weighed down.</span>", loop=TRUE, channel=CHANNEL_HEARTBEAT)
	for(var/obj/structure/overmap/OM in affecting)
		if(get_dist(src, OM) > influence_range || !z || OM.z != z)
			stop_affecting(OM)
			continue
		var/incidence = get_dir(OM, src)
		var/dist = get_dist(src, OM)
		if(dist <= redshift_range)
			var/redshift ="#[num2hex(130-dist,2)][num2hex(0,2)][num2hex(0,2)]"
			OM.color = redshift
			for(var/mob/M in OM.mobs_in_ship)
				M?.client?.color = redshift
		if(dist <= 2)
			affecting -= OM
			OM.current_system?.remove_ship(OM)
			qdel(OM)
		dist = (dist > 0) ? dist : 1
		var/pull_strength = (dist > event_horizon_range) ? 0.005 : base_pull_strength
		var/succ_impulse = (!OM.brakes) ? pull_strength/dist*dist : (OM.forward_maxthrust / 10) + (pull_strength/dist*dist) //STOP RESISTING THE SUCC
		if(incidence & NORTH)
			OM.velocity.y += succ_impulse
		if(incidence & SOUTH)
			OM.velocity.y -= succ_impulse
		if(incidence & EAST)
			OM.velocity.x += succ_impulse
		if(incidence & WEST)
			OM.velocity.x -= succ_impulse

/obj/effect/overmap_anomaly/singularity/proc/stop_affecting(obj/structure/overmap/OM = null)
	if(OM)
		affecting -= OM
		OM.stop_relay(CHANNEL_HEARTBEAT)
		OM.color = cached_colours[OM]
		cached_colours[OM] = null
		for(var/mob/M in OM.mobs_in_ship)
			M?.client?.color = null

/obj/effect/overmap_anomaly/wormhole/Initialize()
	. = ..()
	icon = pick('nsv13/goonstation/icons/effects/overmap_anomalies/tearhuge.dmi', 'nsv13/goonstation/icons/effects/overmap_anomalies/tearmed.dmi', 'nsv13/goonstation/icons/effects/overmap_anomalies/tearsmall.dmi')

/obj/effect/overmap_anomaly/safe
	name = "Placeholder"

/obj/effect/overmap_anomaly/safe/sun
	name = "Star"
	desc = "A huge ball of burning hydrogen that lights up space around it. Scanning its corona could yield useful information."
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/stellarbodies.dmi'
	icon_state = "sun"
	research_points = 3000 //Pretty meagre, but a sustainable source of points.

/obj/effect/overmap_anomaly/safe/sun/red_giant
	name = "Red Giant"
	desc = "A large star that is nearing the end of its life. A scan of its stellar core could lead to useful conclusions."
	icon_state = "redgiant"
	research_points = 4000 //Somewhat more interesting than a sun.

/datum/star_system/proc/apply_system_effects()
	event_chance = 15 //Very low chance of an event happening
	var/anomaly_type = null
	difficulty_budget = threat_level
	switch(system_type)
		if("safe")
			possible_events = list(/datum/round_event_control/aurora_caelus)
		if("hazardous") //TODO: Make better anomalies spawn in hazardous systems scaling with threat level.
			possible_events = list(/datum/round_event_control/carp_migration, /datum/round_event_control/electrical_storm, /datum/round_event_control/belt_rats, /datum/round_event_control/lone_hunter)
		if("wormhole")
			possible_events = list(/datum/round_event_control/wormholes, /datum/round_event/anomaly) //Wormhole systems are unstable in bluespace
			event_chance = 70 //Highly unstable region of space.
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
			event_chance = 60 //Space rocks!
			possible_events = list(/datum/round_event_control/space_dust, /datum/round_event_control/meteor_wave)
		if("icefield")
			parallax_property = "icefield"
		if("gas")
			parallax_property = "gas"
		if("planet_earth")
			parallax_property = "planet_earth"
		if("ice_planet")
			parallax_property = "ice_planet"
		if("blackhole")
			anomaly_type = /obj/effect/overmap_anomaly/singularity
			parallax_property = "pitchblack"
		if("blacksite") //this a special one!
			adjacency_list += "Risa Station" //you're going to risa, dammit.
			SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, src, center=TRUE)
	if(alignment == "syndicate")
		spawn_enemies() //Syndicate systems are even more dangerous, and come pre-loaded with some guaranteed Syndiships.
	if(!anomaly_type)
		anomaly_type = pick(subtypesof(/obj/effect/overmap_anomaly/safe))
	SSstar_system.spawn_anomaly(anomaly_type, src)

/datum/star_system/proc/generate_anomaly()
	if(prob(15)) //Low chance of spawning a wormhole twixt us and another system.
		create_wormhole()
	if(system_type) //Already have a preset system type. Apply its effects.
		apply_system_effects()
		return
	switch(threat_level)
		if(THREAT_LEVEL_NONE)
			system_type = pick("safe", "nebula", "gas", "icefield", "ice_planet") //Threat level 0 denotes starter systems, so they just have "fluff" anomalies like gas clouds and whatever.
		if(THREAT_LEVEL_UNSAFE) //Unaligned and Syndicate systems have a chance to spawn threats. But nothing major.
			system_type = pick("debris", "pirate", "nebula", "hazardous")
		if(THREAT_LEVEL_DANGEROUS) //Extreme threat level. Time to break out the most round destroying anomalies.
			system_type = pick("quasar", "radioactive", "blackhole")
	apply_system_effects()

/datum/star_system/proc/spawn_asteroids()
	for(var/I = 0; I <= rand(3, 6); I++){
		var/roid_type = pick(/obj/structure/overmap/asteroid, /obj/structure/overmap/asteroid/medium, /obj/structure/overmap/asteroid/large)
		SSstar_system.spawn_ship(roid_type, src)
	}

/datum/star_system/proc/spawn_enemies(enemy_type, amount)
	if(!amount)
		amount = difficulty_budget
	for(var/i = 0, i < amount, i++){ //number of enemies is set via the star_system vars
		if(!enemy_type){
			enemy_type = pick(SSstar_system.enemy_types) //Spawn a random set of enemies.
		}
		SSstar_system.spawn_ship(enemy_type, src)
	}

/datum/star_system/proc/lerp_x(datum/star_system/other, t)
	return x + (t * (other.x - x))

/datum/star_system/proc/lerp_y(datum/star_system/other, t)
	return y + (t * (other.y - y))

//////star_system LIST (order of appearance)///////

/datum/star_system/risa
	name = "Risa Station"
	hidden = TRUE //Initially hidden, unlocked when the players complete their patrol.
	mission_sector = TRUE
	x = 5
	y = 30
	alignment = "nanotrasen"
	adjacency_list = list("Sol")

/datum/star_system/risa/after_enter(obj/structure/overmap/OM)
	if(OM.role == MAIN_OVERMAP)
		priority_announce("[station_name()] has successfully returned to [src] for resupply and crew transfer, excellent work crew.", "Naval Command")
		GLOB.crew_transfer_risa = TRUE
		SSticker.mode.check_finished()
	return

/datum/star_system/sol
	name = "Sol"
	is_capital = TRUE
	x = 4
	y = 10
	fleet_type = /datum/fleet/nanotrasen/earth
	alignment = "nanotrasen"
	system_type = "planet_earth"
	adjacency_list = list("Alpha Centauri", "Risa Station")

/datum/star_system/alpha_centauri
	name = "Alpha Centauri"
	x = 20
	y = 15
	alignment = "nanotrasen"
	adjacency_list = list("Sol","Wolf 359", "Unknown Signal")

//Event system, remove me when done!
/datum/star_system/unknown_signal
	name = "Unknown Signal"
	x = 60
	y = 10
	hidden = TRUE
	system_type = "radioactive"
	alignment = "uncharted"
	adjacency_list = list("Alpha Centauri")

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
	fleet_type = /datum/fleet/nanotrasen/border
	adjacency_list = list("Tau Ceti", "Wolf 359")

/datum/star_system/tau_ceti
	name = "Tau Ceti"
	x = 60
	y = 30
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
	adjacency_list = list("Eridani","Scorvio", "Antares", "Eridani")

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
	fleet_type = /datum/fleet/tortuga

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
	fleet_type = /datum/fleet/rubicon

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
	fleet_type = /datum/fleet/border
	adjacency_list = list("Solaris A", "Solaris C", "Vorash", "P3X-754")

/datum/star_system/p3x754
	name = "P3X-754"
	x = 40
	y = 50
	alignment = "uncharted"
	threat_level = THREAT_LEVEL_DANGEROUS
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
	hidden = TRUE
	alignment = "uncharted"
	system_type = "blacksite" //needs to be specified because we're going FROM blacksite TO risa as a guarantee
	threat_level = THREAT_LEVEL_DANGEROUS
	adjacency_list = list("N94-19X")

/datum/star_system/dolos
	name = "Dolos"
	x = 60
	y = 80
	alignment = "syndicate"
	system_type = "radioactive"
	adjacency_list = list("Abassi") //No going back from here...
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE
	fleet_type = /datum/fleet/dolos //You're insane to attempt this.

/datum/star_system/abassi
	name = "Abassi"
	is_capital = TRUE
	x = 40
	y = 100
	alignment = "syndicate"
	system_type = "quasar"
	adjacency_list = list("Dolos")
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE
	fleet_type = /datum/fleet/abassi //You're dead if you attempt this.

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
