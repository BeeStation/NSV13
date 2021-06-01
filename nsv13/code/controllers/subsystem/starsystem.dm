GLOBAL_VAR_INIT(crew_transfer_risa, FALSE)

#define FACTION_VICTORY_TICKETS 1000
#define COMBAT_CYCLE_INTERVAL 180 SECONDS	//Time between each 'combat cycle' of starsystems. Every combat cycle, every system that has opposing fleets in it gets iterated through, with the fleets firing at eachother.

//Subsystem to control overmap events and the greater gameworld
SUBSYSTEM_DEF(star_system)
	name = "star_system"
	wait = 10
	flags = SS_NO_INIT
	var/last_combat_enter = 0 //Last time an AI controlled ship attacked the players
	var/list/systems = list()
	var/list/traders = list()
	var/bounty_pool = 0 //Bounties pool to be delivered for destroying syndicate ships
	var/list/enemy_types = list()
	var/list/enemy_blacklist = list()
	var/list/ships = list() //2-d array. Format: list("ship" = ship, "x" = 0, "y" = 0, "current_system" = null, "target_system" = null, "transit_time" = 0)
	var/tickets_to_win = FACTION_VICTORY_TICKETS
	//Starmap 2
	var/list/factions = list() //List of all factions in play on this starmap, instantiated on init.
	var/list/neutral_zone_systems = list()
	var/next_nag_time = 0
	var/nag_interval = 30 MINUTES //Get off your asses and do some work idiots
	var/nag_stacks = 0 //How many times have we told you to get a move on?
	var/list/all_missions = list()
	var/admin_boarding_override = FALSE //Used by admins to force disable boarders
	var/time_limit = FALSE //Do we want to end the round after a specific time? Mostly used for galconquest.

	var/enable_npc_combat = TRUE	//If you are running an event and don't want fleets to shoot eachother, set this to false.
	var/next_combat_cycle = 0
	var/list/contested_systems = list()	//A maintained list containing all systems that have fleets of opposing factions in them. Fleets add a system to it if they arrive in a system with a hostile fleet, handle_combat removes a system if there is no more conflict.

/datum/controller/subsystem/star_system/fire() //Overmap combat events control system, adds weight to combat events over time spent out of combat
	if(time_limit && world.time >= time_limit)
		var/datum/faction/winner = get_winner()
		if(istype(SSticker.mode, /datum/game_mode/pvp))
			var/datum/game_mode/pvp/mode = SSticker.mode
			mode.winner = winner //This should allow the mode to finish up by itself
			mode.check_finished()
		else
			SSticker.force_ending = 1
		return

	if(enable_npc_combat)
		if(world.time >= next_combat_cycle)
			for(var/datum/star_system/SS in contested_systems)
				SS.handle_combat()
			next_combat_cycle = world.time + COMBAT_CYCLE_INTERVAL

	if(SSmapping.config.patrol_type == "passive")
		priority_announce("[station_name()], you have been assigned to reconnaissance and exploration this shift. Scans indicate that besides a decent number of straggling Syndicate vessels, there will be little threat to your operations. You are granted permission to proceed at your own pace.", "[capitalize(SSmapping.config.faction)] Naval Command")
		for(var/datum/star_system/SS in systems)
			if(SS.name == "Outpost 45")
				SS.hidden = FALSE
		can_fire = FALSE //And leave it at that.
		return FALSE //Don't karmic people if this roundtype is set to passive mode.
	for(var/datum/faction/F in factions)
		F.send_fleet() //Try send a fleet out from each faction.
	if(world.time >= next_nag_time)
		nag_stacks ++
		nag_interval /= 2
		next_nag_time = world.time + nag_interval
		switch(nag_stacks)
			if(1)
				var/message = pick(	"This is Centcomm to all vessels assigned to explore the Delphic Expanse, please continue on your patrol route", \
									"This is Centcomm to all vessels assigned to explore the Delphic Expanse, we are not paying you to idle in space during your assigned patrol schedule", \
									"This is Centcomm to all vessels assigned to explore the Delphic Expanse, your inactivity has been noted and will not be tolerated.", \
									"This is Centcomm to the explore vessel currently assigned to the Delphic Expanse, you are expected to fulfill your assigned mission")
				priority_announce("[message]", "Naval Command") //Warn players for idleing too long
			if(2)
				priority_announce("[station_name()] is no longer responding to commands. Enacting emergency defense conditions. All shipside squads must assist in getting the ship ready for combat by any means necessary.", "WhiteRapids Administration Corps")
				set_security_level(SEC_LEVEL_RED)
			if(3) //Last straw. 40+ mins of inactivity.
				var/datum/star_system/target = find_main_overmap().current_system //Itttttt's HOT DROP OCLOOOOOOCK
				priority_announce("Attention all ships throughout the fleet, assume DEFCON 1. A Syndicate invasion force has been spotted in [target]. All fleets must return to allied space and assist in the defense.", "White Rapids Fleet Command")
				var/datum/fleet/F = new /datum/fleet/earthbuster()
				target.fleets += F
				F.current_system = target
				F.assemble(target)
				minor_announce("[station_name()]. Your pay has been docked to cover expenses, continued ignorance of your mission will lead to removal by force.", "Naval Command")
				nag_interval = rand(5 MINUTES, 10 MINUTES) //Keep up the nag, but slowly.
				var/total_deductions
				for(var/account in SSeconomy.department_accounts)
					var/datum/bank_account/D = SSeconomy.get_dep_account(account)
					if(account == ACCOUNT_SYN)
						continue //No, just no.
					total_deductions += D.account_balance / 2
					D.account_balance /= 2
			if(4 to INFINITY) //From this point on, you can actively lose the game.
				nag_interval = rand(10 MINUTES, 15 MINUTES) //Keep up the nag, but slowly.
				next_nag_time = world.time + nag_interval
				var/lost_influence = FALSE
				var/influence_to_lose = rand(1,3)
				for(var/datum/star_system/sys in systems)
					if(sys.fleets)
						for(var/datum/fleet/F in sys.fleets)
							if(lost_influence >= influence_to_lose)
								break
							if(F.alignment == "nanotrasen" && !istype(F, /datum/fleet/nanotrasen/earth))
								F.defeat()
								lost_influence ++
				if(!lost_influence)
					var/datum/faction/F = faction_by_id(FACTION_ID_NT)
					F.lose_influence(100)

/datum/controller/subsystem/star_system/New()
	. = ..()
	next_nag_time = world.time + nag_interval
	instantiate_systems()
	enemy_types = subtypesof(/obj/structure/overmap/syndicate/ai)
	for(var/type in enemy_blacklist)
		enemy_types -= type
	for(var/instance in subtypesof(/datum/faction))
		var/datum/faction/F = new instance
		factions += F
	for(var/datum/faction/F in factions)
		F.setup_relationships() //Set up faction relationships AFTER they're all initialised to avoid errors.
	for(var/datum/star_system/S in systems)	//Setup the neutral zone for easier access - Bit of overhead but better than having to search for sector 2 systems everytime we want a new neutral zone occupier)
		if(S.sector != 2)	//Magic numbers bad I know, but there is no sector defines.
			continue
		neutral_zone_systems += S

/**
Returns a faction datum by its name (case insensitive!)
*/
/datum/controller/subsystem/star_system/proc/faction_by_id(id)
	RETURN_TYPE(/datum/faction)
	if(!id)
		return //Stop wasting my time.
	for(var/datum/faction/F in factions)
		if(F.id == id)
			return F


/datum/controller/subsystem/star_system/proc/add_blacklist(what)
	enemy_blacklist += what
	if(locate(what) in enemy_types)
		enemy_types -= what

/datum/controller/subsystem/star_system/proc/instantiate_systems()
	for(var/instance in subtypesof(/datum/star_system))
		var/datum/star_system/S = new instance
		if(S.name)
			systems += S

/client/proc/cmd_admin_boarding_override()
	set category = "Adminbus"
	set name = "Toggle Antag Boarding Parties"

	if(!check_rights(R_ADMIN))
		return

	if(SSstar_system.admin_boarding_override)
		SSstar_system.admin_boarding_override = FALSE
		message_admins("[key_name_admin(usr)] has ENABLED overmap antag boarding parties.")
	else if(!SSstar_system.admin_boarding_override)
		SSstar_system.admin_boarding_override = TRUE
		message_admins("[key_name_admin(usr)] has DISABLED overmap antag boarding parties.")

///////SPAWN SYSTEM///////

/datum/controller/subsystem/star_system/proc/find_main_overmap() //Find the main ship
	RETURN_TYPE(/obj/structure/overmap)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role == MAIN_OVERMAP)
			return OM

/datum/controller/subsystem/star_system/proc/find_main_miner() //Find the mining ship
	RETURN_TYPE(/obj/structure/overmap)
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.role == MAIN_MINING_SHIP)
			return OM

/datum/controller/subsystem/star_system/proc/system_by_id(id)
	RETURN_TYPE(/datum/star_system)
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
	RETURN_TYPE(/obj/structure/overmap)
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
	return anomaly

///////BOUNTIES//////

/datum/controller/subsystem/star_system/proc/bounty_payout()
	if(!bounty_pool) //No need to spam when there is no cashola payout
		return
	minor_announce("Bounty Payment Of [bounty_pool] Credits Processed", "Naval Command")
	var/split_bounty = bounty_pool / 2 //Split between our two accounts
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	D.adjust_money(split_bounty)
	var/datum/bank_account/DD = SSeconomy.get_dep_account(ACCOUNT_MUN)
	DD.adjust_money(split_bounty)
	bounty_pool = 0

/datum/controller/subsystem/star_system/proc/check_completion()
	for(var/X in factions)
		var/datum/faction/F = X
		if(F.tickets >= tickets_to_win)
			F.victory()
			return TRUE
	return FALSE

/datum/controller/subsystem/star_system/proc/get_winner()
	var/highestTickets = 0
	var/datum/faction/winner = null
	for(var/X in factions)
		var/datum/faction/F = X
		if(F.tickets > highestTickets)
			winner = F
			highestTickets = F.tickets
	return winner

	/* Deprecated.
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
				We remind you that you are still free to return to Outpost 45 for a crew transfer, and that your continued combat is not necessary.", "Naval Command")
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
			if(SS.name == "Outpost 45")
				SS.hidden = FALSE
			SS.difficulty_budget *= 2 //Double the difficulty if the crew choose to stay.
		times_cleared ++
		addtimer(CALLBACK(src, .proc/reset_gameplay_loop), rand(15 MINUTES, 20 MINUTES)) //Give them plenty of time to go home before we give them any more missions.
		return TRUE
	*/

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
	var/desc = null
	var/parallax_property = null //If you want things to appear in the background when you jump to this system, do this.
	var/level_trait = null //The Ztrait of the zlevel that this system leads to
	var/visitable = FALSE //Can you directly travel to this system? (You shouldnt be able to jump directly into hyperspace)
	var/list/enemies_in_system = list() //For mission completion.
	var/reward = 5000 //Small cash bonus when you clear a system, allows you to buy more ammo
	var/difficulty_budget = 2
	var/list/asteroids = list() //Keep track of how many asteroids are in system. Don't want to spam the system full of them
	var/mission_sector = FALSE
	var/objective_sector = FALSE
	var/threat_level = THREAT_LEVEL_NONE

	var/x = 0 //Maximum: 1000 for now
	var/y = 0 //Maximum: 1000 for now
	var/alignment = "unaligned"
	var/visited = FALSE
	var/hidden = FALSE //Secret systems
	var/system_type = null //Set this to pre-spawn systems as a specific type.
	var/event_chance = 0
	var/list/possible_events = list()
	var/list/active_missions = list()

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
	var/sector = 1 //What sector of space is this in?
	var/is_hypergate = FALSE //Used to clearly mark sector jump points on the map
	var/preset_trader = null
	var/datum/trader/trader = null
	var/list/audio_cues = null //if you want music to queue on system entry. Format: list of youtube or media URLS.

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
		fleet.assemble(src)
	if(preset_trader)
		trader = new preset_trader
		//We need to instantiate the trader's shop now and give it info, so unfortunately these'll always load in.
		var/obj/structure/overmap/trader/station13 = SSstar_system.spawn_anomaly(trader.station_type, src, TRUE)
		station13.starting_system = name
		station13.current_system = src
		station13.set_trader(trader)
		trader.generate_missions()
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

//Inheritance man, inheritance.
/datum/round_event_control/radiation_storm/deadly
	weight = 0
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

/datum/star_system/proc/add_mission(datum/nsv_mission/mission)
	if(!mission)
		return FALSE
	active_missions += mission
	objective_sector = TRUE

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
		/* Handled with boarders - replace me with something else
		if("pirate")
			possible_events = list(/datum/round_event_control/pirates) //Well what did you think was gonna happen when you jumped into a pirate system?
		*/
		if("radioactive")
			parallax_property = "radiation_cloud" //All credit goes to https://www.filterforge.com/filters/11427.html
			possible_events = list(/datum/round_event_control/radiation_storm/deadly)
			event_chance = 100 //Radioactive systems are just that: Radioactive
		if("nebula")
			parallax_property = "nebula-thick" //All credit goes to https://www.filterforge.com/filters/11427.html
		if("quasar")
			parallax_property = "quasar"
			possible_events = list(/datum/round_event_control/grey_tide, /datum/round_event_control/ion_storm, /datum/round_event_control/communications_blackout)
			event_chance = 100 //Quasars are screwy.
		if("accretiondisk")
			parallax_property = "accretiondisk_planet"
			possible_events = list(/datum/round_event_control/grey_tide, /datum/round_event_control/ion_storm, /datum/round_event_control/communications_blackout)
			event_chance = 70 //Black holes can fuck with you
		if("debris")
			parallax_property = "rocks"
			event_chance = 60 //Space rocks!
			possible_events = list(/datum/round_event_control/space_dust, /datum/round_event_control/meteor_wave)
		if("icefield")
			parallax_property = "icefield"
		if("demonstar")
			parallax_property = "demonstar_planet"
		if("supernova")
			parallax_property = "supernova_planet"
		if("gas")
			parallax_property = "gas"
		if("planet_earth")
			parallax_property = "planet_earth"
		if("ice_planet")
			parallax_property = "ice_planet"
		if("graveyard")
			parallax_property = "graveyard"
		if("blackhole")
			anomaly_type = /obj/effect/overmap_anomaly/singularity
			parallax_property = "pitchblack"
		if("blacksite") //this a special one!
			adjacency_list += "Outpost 45" //you're going to risa, dammit.
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
/datum/star_system/sol
	name = "Sol"
	is_capital = TRUE
	x = 70
	y = 50
	fleet_type = /datum/fleet/nanotrasen/earth
	alignment = "nanotrasen"
	system_type = "planet_earth"
	adjacency_list = list("Alpha Centauri", "Outpost 45", "Ross 154")
	var/solar_siege_cycles_needed = 10	//See the starsystem controller for how many minutes is one cycle. Currently 3 minutes.
	var/solar_siege_cycles_left = 10

/datum/star_system/ross
	name = "Ross 154" //Hi mate my name's ross how's it going
	x = 80
	y = 45
	alignment = "nanotrasen"
	threat_level = THREAT_LEVEL_NONE
	adjacency_list = list("Sol", "Barnard's Star", "Alpha Centauri")

/datum/star_system/barnie
	name = "Barnard's Star"
	x = 75
	y = 60
	alignment = "nanotrasen"
	system_type = "supernova"
	threat_level = THREAT_LEVEL_NONE
	adjacency_list = list("Ross 154", "Sol")

/datum/star_system/acentauri
	name = "Alpha Centauri"
	x = 68
	y = 46
	alignment = "nanotrasen"
	threat_level = THREAT_LEVEL_NONE
	adjacency_list = list("Ross 154", "Sol", "Sirius")

/datum/star_system/sirius
	name = "Sirius"
	x = 50
	y = 35
	alignment = "nanotrasen"
	threat_level = THREAT_LEVEL_NONE
	adjacency_list = list("Alpha Centauri", "Wolf 359", "Sol")
	preset_trader = /datum/trader/minsky

/datum/star_system/wolf359
	name = "Wolf 359"
	x = 25
	y = 65
	alignment = "nanotrasen"
	adjacency_list = list("Sirius","Sol", "Wolf 359", "Lalande 21185")

//Sector translation point. Using the power of a demon star, the ship is able to enhance its effective FTL range.
/datum/star_system/lalande21185
	name = "Lalande 21185"
	x = 25
	y = 80
	system_type = "demonstar"
	alignment = "nanotrasen"
	fleet_type = /datum/fleet/nanotrasen/border
	adjacency_list = list("Wolf 359", "Feliciana", "Outpost 45")
	is_hypergate = TRUE

/datum/star_system/outpost
	name = "Outpost 45"
	hidden = TRUE //Initially hidden, unlocked when the players complete their patrol.
	mission_sector = TRUE
	x = 40
	y = 80
	alignment = "nanotrasen"
	adjacency_list = list("Lalande 21185")

/datum/star_system/outpost/after_enter(obj/structure/overmap/OM)
	if(OM.role == MAIN_OVERMAP)
		priority_announce("[station_name()] has successfully returned to [src] for resupply and crew transfer, excellent work crew.", "Naval Command")
		GLOB.crew_transfer_risa = TRUE
		SSticker.mode.check_finished()
	return

//Sector 2: Neutral Zone.
/*
<summary>
Welcome to the neutral zone! Non corporate sanctioned traders with better gear and missions, but be wary of pirates!
</summary>
*/

//It's BACK
/datum/star_system/Feliciana
	name = "Feliciana"
	x = 10
	y = 70
	system_type = "demonstar"
	alignment = "nanotrasen"
	adjacency_list = list("Lalande 21185", "Corvi")
	sector = 2
	is_hypergate = TRUE

/datum/star_system/sector2
	name = "Corvi"
	parallax_property = "icefield"
	x = 10
	y = 60
	alignment = "unaligned"
	sector = 2
	adjacency_list = list("Feliciana", "Argo")

/datum/star_system/sector2/argo
	name = "Argo"
	x = 15
	y = 55
	alignment = "nanotrasen"
	adjacency_list = list("Corvi", "Ariel", "Ida")
	preset_trader = /datum/trader/czanekcorp

/datum/star_system/sector2/ariel
	name = "Ariel"
	x = 8
	y = 45
	alignment = "nanotrasen"
	adjacency_list = list("Corvi", "Argo", "Ida")

/datum/star_system/sector2/ida
	name = "Ida"
	x = 20
	y = 50
	alignment = "nanotrasen"
	adjacency_list = list("Ariel", "Argo", "Foothold")

/datum/star_system/sector2/foothold //The last bastion of civilisation.
	name = "Foothold"
	x = 30
	y = 40
	alignment = "nanotrasen"
	fleet_type = /datum/fleet/nanotrasen/border/defense //The foothold in the darkness
	adjacency_list = list("Ariel", "Argo", "The Badlands", "Ida", "Sion")
	preset_trader = /datum/trader/armsdealer
	audio_cues = list("https://www.youtube.com/watch?v=1pHbQ87NcCY", "https://www.youtube.com/watch?v=PSmUokZSbBs", "https://www.youtube.com/watch?v=bCxHzIQ9-Fs")
	desc = "The last bastion of civilisation before the endless uncharted wastes beyond."

/datum/star_system/sector2/sion
	name = "Sion"
	x = 27
	y = 25
	threat_level = THREAT_LEVEL_UNSAFE
	alignment = "unaligned"
	adjacency_list = list("Foothold", "Muir", "Beylix", "Sebacien")
	desc = "The inroad to several independent colonies long abandoned by SolGov. The Sion cluster houses criminals and opportunists alike."

/datum/star_system/sector2/muir
	name = "Muir"
	x = 25
	y = 30
	threat_level = THREAT_LEVEL_UNSAFE
	alignment = "unaligned"
	adjacency_list = list("Sion", "Sebacien")

/datum/star_system/sector2/beylix
	name = "Beylix"
	x = 34
	y = 22
	threat_level = THREAT_LEVEL_UNSAFE
	alignment = "unaligned"
	adjacency_list = list("Sion", "Muir", "Sebacien")

/datum/star_system/sector2/sebacien
	name = "Sebacien"
	x = 35
	y = 28
	threat_level = THREAT_LEVEL_UNSAFE
	alignment = "unaligned"
	adjacency_list = list("Sion", "Muir", "Beylix")

/datum/star_system/sector2/tortuga
	name = "Tortuga"
	x = 10
	y = 30
	alignment = "unaligned"
	system_type = "pirate" //Guranteed piratical action!
	threat_level = THREAT_LEVEL_UNSAFE
	wormhole_connections = list("Feliciana")
	adjacency_list = list()
	fleet_type = /datum/fleet/pirate/tortuga

/datum/star_system/sector2/rubicon
	name = "Rubicon"
	x = 140
	y = 60
	alignment = "syndicate"
	system_type = "demonstar"
	is_hypergate = TRUE
	threat_level = THREAT_LEVEL_UNSAFE
	fleet_type = /datum/fleet/rubicon
	adjacency_list = list("Romulus")
	desc = "Many have attempted to cross the Rubicon, many have failed. This system bridges many different sectors together, and is an inroad for the largely unknown Abassi ridge nebula."

/datum/star_system/random
	name = "Unknown Sector"
	x = 0
	y = 0
	hidden = TRUE
	alignment = "uncharted"

//The badlands generates a rat run of random systems around it, so keep it well clear of civilisation
/datum/star_system/brasil
	name = "The Badlands"
	alignment = "uncharted"
	x = 50
	y = 30
	sector = 2
	adjacency_list = list("Foothold")
	audio_cues = list("https://www.youtube.com/watch?v=HIdNZlBKrTA")
	desc = "The beginning of a sector of uncharted space known as the Delphic expanse. Ships from many opposing factions all vye for control over this new territory."

/datum/star_system/brasil/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/generate_badlands), 10 SECONDS)

#define NONRELAXATION_PENALTY 1.2 //Encourages the badlands generator to use jump line relaxation even if a + b >= c. Set this lower if you want Brazil's jumplines to be more direct, high values might be very wacky. 1.0 will give all of the systems a direct jumpline to rubiconnector. Values below 1 might be very wacky.
#define MAX_RANDOM_CONNECTION_LENGTH 30 //How long the random jump lines generated by this can be. Use higher values if there is few systems, or the sector may be very desolate of jump lines.
#define MIN_RANDOM_CONNECTION_LENGTH 0	//Same as above, but minimum instead. Default is 0, set it higher if you want more interconnectedness instead of it. Works well together with a high maximum.
#define RNGSYSTEM_MAX_CONNECTIONS 4 //A system has to have less than this amount of connections to gain new random jumplines. Note that this does not affect the tree-phase of the algorytm.
#define RANDOM_CONNECTION_BASE_CHANCE 40	//How high the probability for a system to gain a random jumpline is, provided it is valid and has valid partners. In percent.
#define RANDOM_CONNECTION_REPEAT_PENALTY 20	//By how much this probability decreases per random jump line added to the system. In percent.

/datum/star_system/brasil/proc/generate_badlands()

	var/list/generated = list()
	var/amount = rand(50, 70)
	var/toocloseconflict = 0
	message_admins("Generating Brazil with [amount] systems.")
	var/start_timeofday = REALTIMEOFDAY
	var/datum/star_system/rubicon = SSstar_system.system_by_id("Rubicon")
	if(!rubicon)
		message_admins("Error setting up Brazil - No Rubicon found!") //This should never happen unless admins do bad things.
		return

	for(var/I=0;I<amount,I++){
		var/datum/star_system/random/randy = new /datum/star_system/random()
		randy.system_type = pick("radioactive", 0.5;"blackhole", "quasar", 0.75;"accretiondisk", "nebula", "supernova", "debris")
		randy.apply_system_effects()
		randy.name = (randy.system_type != "nebula") ? "S-[rand(0,10000)]" : "N-[rand(0,10000)]"
		var/randy_valid = FALSE

		while(!randy_valid)
			randy.x = (rand(1, 10)/10)+rand(1, 200)+20 // Buffer space for readability
			randy.y = (rand(1, 10)/10)+rand(1, 100)+30 // Offset vertically for viewing 'pleasure'
			var/syscheck_pass = TRUE
			for(var/datum/star_system/S in (generated + rubicon + src))
				if(!syscheck_pass)
					break
				if(S.dist(randy) < 5)// Maybe this is enough?
					syscheck_pass = FALSE
					continue
				if(S.name == "Rubicon" && (S.dist(randy) < 7)) //Rubicon's text is too fat.
					syscheck_pass = FALSE
					continue
			if(syscheck_pass)
				randy_valid = TRUE
			else
				toocloseconflict++

		randy.sector = sector //Yeah do I even need to explain this?
		randy.hidden = FALSE
		generated += randy
		if(prob(10))
			//10 percent of systems have a trader for resupply.
			var/x = pick(typesof(/datum/trader)-/datum/trader)
			var/datum/trader/randytrader = new x
			var/obj/structure/overmap/trader/randystation = SSstar_system.spawn_anomaly(randytrader.station_type, randy)
			randystation.starting_system = randy.name
			randystation.current_system = randy
			randystation.set_trader(randytrader)
			randy.trader = randytrader
			randytrader.generate_missions()


		else if(prob(10))
			var/x = pick(/datum/fleet/wolfpack, /datum/fleet/neutral, /datum/fleet/pirate/raiding, /datum/fleet/boarding, /datum/fleet/nanotrasen/light)
			var/datum/fleet/randyfleet = new x
			randyfleet.current_system = randy
			randyfleet.hide_movements = TRUE //Prevent the shot of spam this caused to R1497.
			randy.fleets += randyfleet
			randy.alignment = randyfleet.alignment
			randyfleet.assemble(randy)



		SSstar_system.systems += randy
	}
	var/lowest_dist = 1000
	//Finally, let's play this drunken game of connect the dots.

	//First, we use the system closest to rubicon as a connector to it
	var/datum/star_system/rubiconnector = null
	for(var/datum/star_system/S in generated)
		if(S.dist(rubicon) < lowest_dist)
			lowest_dist = S.dist(rubicon)
			rubiconnector = S
	rubiconnector.adjacency_list += rubicon.name
	rubicon.adjacency_list += rubiconnector.name

	//We did it, we connected Rubicon. Now for the fun part: Connecting all of the systems, in a not-as-bad way. We'll use a tree for this, and then add some random connections to make it not as linear.
	generated += src //We want to get to rubicon from here!
	var/relax = 0	//Just a nice stat var
	var/random_jumpline_count = 0 //Another nice stat var
	var/systems[generated.len]
	var/distances[generated.len]
	var/parents[generated.len]	//This is what we will use later
	for(var/i = 1; i <= generated.len; i++)
		systems[i] = generated[i]
		parents[i] = rubiconnector
		if(generated[i] != rubiconnector)
			distances[i] = INFINITY
		else
			distances[i] = 0

	//Setup: Done. Dijkstra time.
	while(generated.len > 0) //we have to go through this n times
		var/closest = null
		var/mindist = INFINITY
		for(var/datum/star_system/S in generated)	//Find the system with the smallest value in distances[].
			var/thisdist = distances[systems.Find(S)]
			if(!closest || mindist > thisdist)
				closest = systems.Find(S)
				mindist = thisdist //This is always the source node (rubiconnector) in the first run
		generated -= systems[closest]	//Remove it from the list.

		for(var/datum/star_system/S in generated)	//Try relaxing all other systems still in the list via it.
			var/datum/star_system/close = systems[closest]
			var/alternative = distances[closest] + close.dist(S)
			var/adj = systems.Find(S)
			if(alternative < distances[adj] * NONRELAXATION_PENALTY)	//Apply penalty to make the map more interconnected instead of all jump lines just going directly to the rubiconnector
				distances[adj] = alternative
				parents[adj] = systems[closest]
				relax++

	//Dijkstra: Done. We got parents for everyone, time to actually stitch them together.
	for(var/i = 1; i <= systems.len; i++)
		var/datum/star_system/S = systems[i]
		if(S == rubiconnector)
			continue	//Rubiconnector is the home node and would fuck with us if we did stuff with it here.
		var/datum/star_system/Connected = parents[i]
		S.adjacency_list += Connected.name
		Connected.adjacency_list += S.name

	//We got a nice tree! But this is looking far too clean, time to Brazilify this.
	for(var/datum/star_system/S in systems)
		var/bonus = 0
		var/list/valids = list()
		for(var/datum/star_system/candidate in systems)
			if(S == candidate)
				continue
			if(candidate.adjacency_list.Find(S.name) || S.adjacency_list.Find(candidate.name))
				continue
			if(S.dist(candidate) > MAX_RANDOM_CONNECTION_LENGTH || candidate.dist(S) < MIN_RANDOM_CONNECTION_LENGTH)
				continue
			if(candidate.adjacency_list.len >= RNGSYSTEM_MAX_CONNECTIONS)
				continue
			valids += candidate
		while(!prob(100 - RANDOM_CONNECTION_BASE_CHANCE + (bonus * RANDOM_CONNECTION_REPEAT_PENALTY))) //Lets not flood the map with random jumplanes, buuut create a good chunk of them
			if(!valids.len)
				break
			if(S.adjacency_list.len >= RNGSYSTEM_MAX_CONNECTIONS)
				break
			var/datum/star_system/newconnection = pick(valids)
			newconnection.adjacency_list += S.name
			S.adjacency_list += newconnection.name
			valids -= newconnection
			random_jumpline_count++

	//Pick a random entrypoint system
	var/datum/star_system/inroute
	var/ir_rub = 0
	var/ir_othershit = 0
	while (!inroute)
		var/datum/star_system/picked = pick(systems)
		if(rubiconnector.name in picked.adjacency_list)
			ir_rub++
			continue // Skip
		if(picked.trader || picked.fleets.len)
			ir_othershit++
			continue
		var/datum/star_system/sol/solsys = SSstar_system.system_by_id("Sol")
		solsys.adjacency_list += picked.name
		picked.adjacency_list += solsys.name
		inroute = picked
		inroute.is_hypergate = TRUE

	var/time = (REALTIMEOFDAY - start_timeofday) / 10
	//There we go.
	message_admins("Brazil has been generated. T:[time]s CFS:[toocloseconflict]|[ir_rub]|[ir_othershit] Rubiconnector: [rubiconnector], Inroute system is [inroute]. Fun fact, jump lanes have been relaxed [relax] times by the algorithm and [random_jumpline_count] random connections have been created!")

#undef NONRELAXATION_PENALTY
#undef MAX_RANDOM_CONNECTION_LENGTH
#undef MIN_RANDOM_CONNECTION_LENGTH
#undef RNGSYSTEM_MAX_CONNECTIONS
#undef RANDOM_CONNECTION_BASE_CHANCE
#undef RANDOM_CONNECTION_REPEAT_PENALTY

/*
<Summary>
Welcome to the endgame. This sector is the hardest you'll encounter in game and holds the Syndicate capital.
</Summary>
*/
/datum/star_system/sector4
	name = "Mediolanum"
	adjacency_list = list("Romulus", "Aeterna Victrix", "Demon's Maw")
	threat_level = THREAT_LEVEL_UNSAFE
	x = 100
	y = 50
	sector = 3

/datum/star_system/sector4/aeterna
	name = "Aeterna Victrix"
	adjacency_list = list("Mediolanum", "Deimos", "Romulus")
	x = 90
	y = 40

/datum/star_system/sector4/demon
	name = "Demon's Maw"
	adjacency_list = list("Aeterna Victrix", "Phobos", "Deimos", "Mediolanum")
	system_type = "accretiondisk"
	alignment = "uncharted"
	x = 100
	y = 60
	preset_trader = /datum/trader/armsdealer/syndicate

/datum/star_system/sector4/phobos
	name = "Phobos"
	system_type = "nebula"
	adjacency_list = list("Demon's Maw", "Deimos", "Dolos Remnants")
	fleet_type = /datum/fleet/border
	x = 120
	y = 70

/datum/star_system/sector4/deimos
	name = "Deimos"
	adjacency_list = list("Demon's Maw", "Dolos Remnants")
	x = 80
	y = 67

/datum/star_system/sector4/dolos
	name = "Dolos Remnants"
	x = 75
	y = 100
	alignment = "syndicate"
	system_type = "graveyard"
	adjacency_list = list("Oasis Fidei", "Deimos", "Phobos") //No going back from here...
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = FALSE
	audio_cues = list("https://www.youtube.com/watch?v=n_aONGBjuLA")
	desc = "A place where giants fell. You feel nothing save for an odd sense of unease and an eerie silence."

/datum/star_system/sector4/abassi
	name = "Abassi"
	x = 85
	y = 120
	is_capital = TRUE
	alignment = "syndicate"
	system_type = "demonstar"
	adjacency_list = list("Dolos Remnants")
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE

/datum/star_system/sector4/laststand
	name = "Oasis Fidei" //oasis of faith
	x = 75
	y = 120
	alignment = "syndicate"
	system_type = "radioactive"
	adjacency_list = list("Abassi") //No going back from here...
	threat_level = THREAT_LEVEL_DANGEROUS
	hidden = TRUE //In time, not now.
	fleet_type = /datum/fleet/remnant

/datum/star_system/romulus
	name = "Romulus"
	sector = 3
	x = 60
	y = 50
	alignment = "syndicate"
	system_type = "demonstar"
	is_hypergate = TRUE
	threat_level = THREAT_LEVEL_UNSAFE
	fleet_type = /datum/fleet/border
	adjacency_list = list("Rubicon", "Aeterna Victrix")

#define ALL_STARMAP_SECTORS 1,2,3 //KEEP THIS UPDATED.
