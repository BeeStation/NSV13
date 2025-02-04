/*
	Special objective for PVP
	One system is in Brazil is designated target.
	One of the two main ships being in the system without the other shifts control.
	15 total minutes of control by either side result in victory.
	Destroying / nuking the other ship also results in victory as usual.

	An automated, non-destructible station within the system will provide ranged fire support to whichever side is currently ahead.
	While at less than 3 minutes difference, the station will be neutral and fire on EITHER side.
	Control will only start ticking 25 minutes after roundstart.
*/

#define SYSTEM_CONTROL_CONTROL_TIME (15 MINUTES)
#define SYSTEM_CONTROL_GRACE_PERIOD (25 MINUTES)
#define SYSTEM_CONTROL_STATION_GRACE (3 MINUTES)

/datum/overmap_objective/control_system
	name = "Control System"
	desc = "Secure \[TARGET\] and control it for \[TIME\] minutes."
	brief = "Secure \[TARGET\] and its automated wormhole stabilization station by removing all major presences from the system for \[TIME\] minutes. In-system station may possess some ranged capabilities."
	//Soo basically I am abusing these two variables to track progress of each side instead of trivial tickets :)
	//NT delay
	target = SYSTEM_CONTROL_CONTROL_TIME
	//Syndi delay
	tally = SYSTEM_CONTROL_CONTROL_TIME
	binary = FALSE
	var/datum/star_system/target_system
	var/obj/structure/overmap/anchor_station

	var/next_process = 0
	var/grace_end = 0

	var/nt_threshold = SYSTEM_CONTROL_CONTROL_TIME - (5 MINUTES)
	var/syndie_threshold = SYSTEM_CONTROL_CONTROL_TIME - (5 MINUTES)

/datum/overmap_objective/control_system/New()
	. = ..()
	var/list/candidates = list()
	for(var/datum/star_system/random/possible_brazil in SSstar_system.systems)
		if(possible_brazil.sector != 2)
			continue
		if("Sol" in possible_brazil.wormhole_connections)	//The entire point of the mission is to prevent that.
			continue
		if(locate(/obj/effect/overmap_anomaly/singularity) in possible_brazil.system_contents)
			continue //While I enjoy hazards, this is a bit over the top.
		candidates += possible_brazil
	if(!length(candidates))	//Someone turned off brazil, uh oh, failsafe.
		if(length(SSstar_system.neutral_zone_systems))
			target_system = pick(SSstar_system.neutral_zone_systems)
		else
			message_admins("MISSION ERROR: NO VALID SYSTEM FOR CONTROL. EXPECT MISSION NOT WORKING.")
			return //This is not my problem anymore.
	else
		target_system = pick(candidates)
	if(!target_system)
		message_admins("MISSION ERROR: SOMETHING WENT VERY VERY WRONG!!!!!!!")
		return
	anchor_station = SSstar_system.spawn_anomaly(/obj/structure/overmap/wormhole_anchor_station, target_system, TRUE)
	if(!anchor_station)
		message_admins("Uh oh, we didn't manage to generate an anchor station!")
		return
	target_system.objective_sector = TRUE
	target_system.alignment = "unaligned"
	grace_end = world.time + SYSTEM_CONTROL_GRACE_PERIOD

/datum/overmap_objective/control_system/instance()
	desc = "Secure [target_system] and control it for [(SYSTEM_CONTROL_CONTROL_TIME / 600)] minutes."
	brief = "Secure [target_system] and its automated wormhole stabilization station by removing all major presences from the system for [(SYSTEM_CONTROL_CONTROL_TIME / 600)] minutes. In-system station may possess some ranged capabilities."
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/overmap_objective/control_system/process(delta_time)
	if(next_process > world.time)
		return
	if(grace_end > world.time)
		return
	next_process = world.time + 5 SECONDS //We only check every 5 seconds.

	var/datum/game_mode/pvp/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("System control objective active while the mode is not pvp.")

	var/goodshipfound = FALSE
	var/evilshipfound = FALSE

	for(var/obj/structure/overmap/ship in target_system.system_contents)
		if(ship.faction != "nanotrasen" && ship.faction != "syndicate")
			continue
		if(ship.role != MAIN_OVERMAP && ship.role != MAIN_MINING_SHIP && ship.role != PVP_SHIP)
			continue
		if(ship.faction == "nanotrasen")
			goodshipfound = TRUE
		else if(ship.faction == "syndicate")
			evilshipfound = TRUE
		if(goodshipfound && evilshipfound)
			break

	if((goodshipfound && evilshipfound) || (!goodshipfound && !evilshipfound))
		return

	if(goodshipfound)
		target = max(0, target - (5 SECONDS))
		if(target == 0)
			current_mode.winner = SSstar_system.faction_by_id(FACTION_ID_NT)
			SSticker.force_ending = TRUE
			STOP_PROCESSING(SSprocessing, src)
			return
		else if(target <= nt_threshold)
			minor_announce("Nanotrasen is making progress in configuring the Anchor station to seal the wormhole - [target / 600] minutes remain.", "Mission Status")
			nt_threshold -= 5 MINUTES

	else if(evilshipfound)
		tally = max(0, tally - (5 SECONDS))
		if(tally == 0)
			SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, target_system, FALSE)
			target_system.wormhole_connections |= "Sol"
			target_system.adjacency_list |= "Sol"
			current_mode.winner = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
			SSticker.force_ending = TRUE
			STOP_PROCESSING(SSprocessing, src)
			return
		else if(tally <= syndie_threshold)
			minor_announce("The Syndicate is getting closer to stabilizing its Sol wormhole - [tally / 600] minutes remain.", "Mission Status")
			syndie_threshold -= 5 MINUTES

	var/current_faction = anchor_station.faction

	//Takeover station.
	if(target - tally <= -(SYSTEM_CONTROL_STATION_GRACE))
		anchor_station.faction = "nanotrasen"
	else if(tally - target <= -(SYSTEM_CONTROL_STATION_GRACE))
		anchor_station.faction = "syndicate"
	else
		anchor_station.faction = "anchor station"

	if(anchor_station.faction != current_faction)
		anchor_station.last_target = null
		for(var/obj/structure/overmap/targetswap in anchor_station.enemies)
			targetswap.enemies -= anchor_station
			if(targetswap.last_target == anchor_station)
				targetswap.last_target = null
		anchor_station.enemies = list()
		if(anchor_station.faction == "anchor_station")
			minor_announce("[current_faction] lost control of the Wormhole Anchor station.", "Wormhole Anchor Status Update")
		else
			minor_announce("[anchor_station.faction] gained control of the Wormhole Anchor station.", "Wormhole Anchor Status Update")



/datum/overmap_objective/control_system/check_completion()
	var/datum/game_mode/pvp/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("System control objective active while the mode is not pvp.")
	if(target <= 0)
		current_mode.winner = SSstar_system.faction_by_id(FACTION_ID_NT)
		SSticker.force_ending = TRUE
	else if(tally <= 0)
		current_mode.winner = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
		SSticker.force_ending = TRUE




/datum/overmap_objective/control_system/Destroy(force, ...)
	target_system = null
	anchor_station = null
	return ..()

/obj/structure/overmap/wormhole_anchor_station
	name = "Wormhole Anchor Station"
	desc = "An automated station currently stabilizing a proto-wormhole. What you are here for."
	icon_state = "syndie"
	icon = 'nsv13/icons/overmap/neutralstation.dmi'
	faction = "anchor station" //Automated defense systems will fire on anything unless one of the sides starts to gain control.
	bound_width = 224
	bound_height = 224
	essential = TRUE
	ai_controlled = TRUE
	ai_flags = AI_FLAG_STATIONARY
	brakes = TRUE
	mass = MASS_IMMOBILE //Sir, this is a station.
	obj_integrity = 10000 //May aswell. See: essential
	max_integrity = 10000
	max_tracking_range = 70 //Sees a good chunk of the system.
	max_weapon_range = 70
	sensor_profile = 255 //Yeah you can see this.
	torpedoes = 10
	shots_left = 1000 //Good luck running their close-range PDC dry.
	torpedo_type = /obj/item/projectile/guided_munition/torpedo/siege
	var/rearm_completion = 0
	var/rearm_duration = 1 MINUTES

/obj/structure/overmap/wormhole_anchor_station/ai_process()
	. = ..()
	//Integrated ammunition forges.
	if(torpedoes == 0)
		if(!rearm_completion)
			rearm_completion = world.time + rearm_duration
		else if(world.time >= rearm_completion)
			torpedoes = initial(torpedoes)
			shots_left = initial(shots_left)
			rearm_completion = 0



/obj/structure/overmap/wormhole_anchor_station/apply_weapons()
	weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher/siege(src)
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/aa_guns/shredder(src)



/datum/ship_weapon/torpedo_launcher/siege
	name = "Siege Torpedo Launcher"
	fire_delay = 10 SECONDS
	ai_fire_delay = 0 //No bonus delay.
	default_projectile_type = /obj/item/projectile/guided_munition/torpedo/siege
	range_modifier = 300 //This is a siege weapon.

/datum/ship_weapon/aa_guns/shredder
	name = "Shredder Point Defense Array"
	fire_delay = 4 SECONDS
	ai_fire_delay = 0 //No additional delay.
	burst_size = 10
	burst_fire_delay = 2
	range_modifier = 12 //Close range Defense.


/datum/ship_weapon/aa_guns/shredder/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check)
	. = ..()
	if(!.)
		return
	if(overmap_dist(source, target) > range_modifier)
		return FALSE

/obj/item/projectile/guided_munition/torpedo/siege
	icon_state = "torpedo_siege"
	name = "siege torpedo"
	desc = "This is a large torpedo with an oversized warhead meant as deterrant or anti-station armament. Very slow. Very dangerous."
	damage = 600
	armour_penetration = 50
	flag = "overmap_medium"
	obj_integrity = 90
	max_integrity = 90
	speed = 5
	homing_turn_speed = 10
	range = 700
	valid_angle = 360

/obj/item/projectile/guided_munition/torpedo/siege/detonate(atom/target)
	explosion(target, 4, 8, flash_range = 8, flame_range = 8)





#undef SYSTEM_CONTROL_CONTROL_TIME
#undef SYSTEM_CONTROL_GRACE_PERIOD
#undef SYSTEM_CONTROL_STATION_GRACE
