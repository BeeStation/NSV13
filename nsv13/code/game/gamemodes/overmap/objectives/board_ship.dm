/datum/overmap_objective/board_ship
	name = "Board Ship"
	desc = "Find and board a ship"
	brief = "Capture the syndicate vessel CALLANADMIN by boarding it, defeating the enemies therein, and modifying its IFF codes."
	var/datum/star_system/target_system = null
	var/obj/structure/overmap/target_ship = null

/datum/overmap_objective/board_ship/instance()
	. = ..()
	// make a ship
	var/ship_type = pick(GLOB.boardable_ship_types)
	target_ship = instance_overmap(ship_type)
	target_ship.block_deletion = TRUE
	RegisterSignal(target_ship, COMSIG_SHIP_BOARDED, .proc/check_completion, target_ship)
	RegisterSignal(target_ship, COMSIG_SHIP_RELEASE_BOARDING, .proc/release_boarding, target_ship)
	target_ship.ai_load_interior(SSstar_system.find_main_overmap())
	// give it a name
	var/ship_name = generate_ship_name()
	target_ship.name = ship_name
	// give it a home
	var/list/candidates = list()
	for(var/datum/star_system/S in SSstar_system.systems)
		// Is this even in a reasonable location?
		if(S.hidden || (S.sector != 2) || S.get_info()?["Black hole"])
			continue
		// Don't put it where it will immediately get shot
		if((S.alignment != target_ship.faction) && (S.alignment != "unaligned") && (S.alignment != "uncharted"))
			continue
		// This shouldn't be needed with the faction check, but don't put it in the spawn location
		if(S == SSstar_system.system_by_id(SSovermap_mode.mode.starting_system))
			continue
		candidates += S
	target_system = pick(candidates)
	brief = "Capture the syndicate vessel [target_ship] in [target_system] by boarding it, defeating the enemies therein, and modifying its IFF codes."
	target_system.add_ship(target_ship)
	target_system.enemies_in_system += target_ship
	target_system.objective_sector = TRUE
	// give it a friend :)
	var/datum/faction/S = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	S.send_fleet(target_system, null, TRUE)
	var/datum/fleet/F = pick(target_system.fleets)
	F.fleet_trait = FLEET_TRAIT_DEFENSE
	F.add_ship(target_ship, "battleships")

	// How long should this take?
	var/list/fastest_route = find_route(SSstar_system.find_system(SSovermap_mode.mode.starting_system), target_system)
	var/distance = 0
	for(var/i = 2; i < length(fastest_route); i++)
		var/datum/star_system/start = fastest_route[i-1]
		var/datum/star_system/finish = fastest_route[i]
		distance += start.dist(finish)
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	var/travel_time = (distance / (OM.ftl_drive.jump_speed_factor*10)) SECONDS // Time spent flying
	travel_time += 2 MINUTES * length(fastest_route) // Time spent spooling FTL drive
	travel_time *= 1.2 // Time spent lolligagging
	SSovermap_mode.mode.objective_reminder_interval = max((travel_time / 5), SSovermap_mode.mode.objective_reminder_interval)
	message_admins("Reminder interval set to [(SSovermap_mode.mode.objective_reminder_interval) / 600] minutes")

/datum/overmap_objective/board_ship/check_completion()
	if (target_ship.faction == SSovermap_mode.mode.starting_faction)
		status = 1
		target_ship.block_deletion = FALSE
		UnregisterSignal(target_ship, COMSIG_SHIP_BOARDED)
		UnregisterSignal(target_ship, COMSIG_SHIP_RELEASE_BOARDING)

/datum/overmap_objective/board_ship/proc/release_boarding()
	// Don't let them kill the ship if they haven't won yet
	if(status != 1 && status != 3) // complete or admin override
		return COMSIG_SHIP_BLOCKS_RELEASE_BOARDING
	return 0
