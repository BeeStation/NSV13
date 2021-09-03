/datum/overmap_objective/board_ship
	name = "Board Ship"
	desc = "Find and board a ship"
	brief = "Capture the syndicate vessel CALLANADMIN by boarding it, defeating the enemies therein, and modifying its IFF codes."
	var/datum/star_system/target_system = null
	var/obj/structure/overmap/target_ship = null

/datum/overmap_objective/board_ship/New()
	. = ..()

/datum/overmap_objective/board_ship/instance()
	. = ..()
	// make a ship
	var/ship_type = pick(BOARDABLE_SHIP_TYPES)
	target_ship = instance_overmap(ship_type)
	RegisterSignal(target_ship, COMSIG_SHIP_BOARDED, .proc/check_completion, target_ship)
	target_ship.ai_load_interior(SSstar_system.find_main_overmap())
	// give it a name
	var/ship_name = generate_ship_name()
	target_ship.name = ship_name
	target_system.add_ship(target_ship)
	brief = "Capture the syndicate vessel [target_ship.name] in [target_system.name] by boarding it, defeating the enemies therein, and modifying its IFF codes."
	// give it a home
	var/list/candidates = list()
	for(var/datum/star_system/S in SSstar_system.systems)
		if(istype(S, /datum/star_system/random))
			candidates += S
	target_system = pick(candidates)
	target_system.enemies_in_system += target_ship
	// give it a friend :)
	var/datum/faction/S = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	S.send_fleet(target_system, null, TRUE)
	var/datum/fleet/F = pick(target_system.fleets)
	F.fleet_trait = FLEET_TRAIT_DEFENSE
	F.add_ship(target_ship)

/datum/overmap_objective/board_ship/check_completion()
	if (target_ship.faction == SSovermap_mode.mode.starting_faction)
		status = 1
		UnregisterSignal(target_ship, COMSIG_SHIP_BOARDED)
