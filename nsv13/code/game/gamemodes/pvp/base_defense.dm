/datum/game_mode/pvp/base_defense
	name = "Planetary defense"
	config_tag = "planetary_defense"
	report_type = "planetary_defense"
	false_report_weight = 10
	required_players = 30
	required_enemies = 12
	recommended_enemies = 14
	antag_flag = ROLE_SYNDI_CREW
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "Rumours tell of a hidden Syndicate fortress in the Scorvio system!\n\
	<span class='danger'>Operatives</span>: Defend your base from attack.\n\
	<span class='notice'>Crew</span>: Attack and destroy the Syndicate stronghold."

	title_icon = "nukeops"
	highpop_threshold = 1000 //:))
	standard_ships = list("ice_colony.dmm")
	highpop_ships = null //Update this list if you make a big PVP ship
	operative_antag_datum_type = /datum/antagonist/nukeop/syndi_crew/planetary_defense
	leader_antag_datum_type = /datum/antagonist/nukeop/leader/syndi_crew/planetary_defense
	shipside_antag_datum_type = /datum/antagonist/nukeop/syndi_crew/shipside/planetary_defense
	pilot_antag_datum_type = /datum/antagonist/nukeop/syndi_crew/pilot/planetary_defense

/datum/antagonist/nukeop/syndi_crew/planetary_defense
	name = "Syndicate base staff"
	tips = 'html/antagtips/pvp_planetfall.html'

/datum/antagonist/nukeop/leader/syndi_crew/planetary_defense
	name = "Syndicate base commodore"
	tips = 'html/antagtips/pvp_planetfall.html'

/datum/antagonist/nukeop/syndi_crew/shipside/planetary_defense
	name = "Syndicate base technician"
	tips = 'html/antagtips/pvp_planetfall.html'

/datum/antagonist/nukeop/syndi_crew/pilot/planetary_defense
	tips = 'html/antagtips/pvp_planetfall.html'

/datum/game_mode/pvp/base_defense/generate_report()
	return "We've received intel that there may be a Syndicate outpost in the Scorvio system. Be on the lookout for it."

/obj/machinery/nuclearbomb/selfdestruct/syndicate
	name = "base self-destruct terminal"
	desc = "A terminal which, when provided with an Osterhagen key, can trigger a chain reaction inside its planetary core, completely annihilating its surroundings and scrubbing all evidence of a Syndicate operation."
	r_code = "73556"

/atom/onSyndieBase()
	. = ..()
	var/area/AR = get_area(src)
	if(istype(AR, /area/tartarus) || istype(AR, /area/hammurabi))
		return TRUE

/datum/game_mode/pvp/base_defense/OnNukeExplosion(off_station)
	..()
	nukes_left = 0
	check_win()
//Puce GANG
/obj/item/disk/nuclear/syndicate_base
	name = "Osterhagen key"
	desc = "A disk which can initiate the Osterhagen protocol and scrub its assigned Syndicate base by triggering a series of nuclear warheads to be launched at the planet's core, causing complete annihilation. <b>It has the activation code stamped on it:</b><i>73556</i>"
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	fake = FALSE //Yeah this disk is very, very real.

//The inverse of stationloving. This forces the Syndicate PVP disk to not be on the station or overmap level.

/datum/component/stationloving/stationhating/in_bounds()
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		return TRUE
	var/static/list/allowed_shuttles = typecacheof(list(/area/shuttle/syndicate, /area/tartarus, /area/hammurabi))
	var/static/list/disallowed_centcom_areas = typecacheof(list(/area/abductor_ship, /area/awaymission/errorroom))
	var/turf/T = get_turf(parent)
	if (!T)
		return FALSE
	var/area/A = T.loc
	if (SSmapping.level_trait(T.z, ZTRAIT_OVERMAP))
		return FALSE
	if (is_station_level(T.z))
		return FALSE
	if (is_centcom_level(T.z))
		if (is_type_in_typecache(A, disallowed_centcom_areas))
			return FALSE
		return TRUE
	if (is_reserved_level(T.z))
		if (is_type_in_typecache(A, allowed_shuttles))
			return TRUE

	return FALSE

//Override to plop the disk back to a syndie crew spawn rather than somewhere on the station.

/datum/component/stationloving/stationhating/relocate()
	var/targetturf = get_turf(pick(GLOB.syndi_crew_spawns)) //Fuck you for making me do this.
	var/atom/movable/AM = parent
	AM.forceMove(targetturf)
	to_chat(get(parent, /mob), "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
	return targetturf

/obj/item/disk/nuclear/syndicate_base/ComponentInitialize()
	AddComponent(/datum/component/stationloving/stationhating)

//Syndie PVP ship

/area/tartarus
	name = "Tartarus"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	noteleport = TRUE
	icon_state = "syndie-ship"
	has_gravity = TRUE

/area/tartarus/underground
	name = "Tartarus caverns"
	icon_state = "space"
	requires_power = FALSE

/area/tartarus/exterior
	name = "Tartarus surface"
	looping_ambience = 'sound/weather/ashstorm/outside/active_mid1.ogg'
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED //Bet.
	requires_power = FALSE

/area/tartarus/exterior/hangar
	name = "Planetary defense hangar"
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	icon_state = "shuttlered"

/area/tartarus/exterior/surfacebase
	name = "Bowie base 2 access"
	looping_ambience = 'sound/weather/ashstorm/inside/active_mid1.ogg'

/area/tartarus/interrogation
	name = "Bowie base 2 interrogation"
	looping_ambience = 'nsv13/sound/ambience/medbay.ogg'
	icon_state = "medbay"

/area/tartarus/base
	name = "Bowie base 2"

/area/tartarus/tcomms
	name = "Bowie base 2 TE/LE/COMM core"
	looping_ambience = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "tcomsatcham"

/area/tartarus/commodore
	name = "Bowie base 2 commodore's office"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "syndie-control"

/area/tartarus/briefing
	name = "Bowie base 2 briefing room"
	looping_ambience = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "syndie-control"

/area/tartarus/armoury
	name = "Bowie base 2 armoury"
	icon_state = "syndie-elite"

/area/tartarus/maintenance
	name = "Bowie base 2 maintenance ducts"
	looping_ambience = 'nsv13/sound/ambience/maintenance.ogg'
	icon_state = "maintcentral"

/area/tartarus/lounge
	name = "Bowie base 2 lounge"

/area/tartarus/meeting
	name = "Bowie base 2 meeting room"

/area/tartarus/cryostasis
	name = "Bowie base 2 cryostasis"

/area/tartarus/engineering
	name = "Bowie base 2 reactor core"

/obj/structure/overmap/planet/pvp
	name = "Tartarus"
	desc = "A desolate frozen wasteland that seems resistant to surface scans..."
	icon = 'nsv13/icons/overmap/stellarbodies/planets.dmi'
	icon_state = "planet_cloud"
	mass = MASS_IMMOBILE
	damage_states = FALSE
	collision_positions = list(new /datum/vector2d(-7,110), new /datum/vector2d(-44,98), new /datum/vector2d(-76,67), new /datum/vector2d(-94,26), new /datum/vector2d(-89,-19), new /datum/vector2d(-69,-59), new /datum/vector2d(-33,-86), new /datum/vector2d(-6,-95), new /datum/vector2d(42,-92), new /datum/vector2d(82,-63), new /datum/vector2d(99,-28), new /datum/vector2d(105,3), new /datum/vector2d(91,57), new /datum/vector2d(62,91), new /datum/vector2d(29,104))
	starting_system = "Scorvio"
	obj_integrity = INFINITY
	max_integrity = INFINITY //Yeah. Because. Planets don't just...up and die...or go into SS crit. Y'know?
	armor = list("overmap_light" = 100, "overmap_heavy" = 80) //Good luck with war-criming a planet Czanek.
	pixel_z = -128
	pixel_w = -128
	faction = "syndicate"
	ai_controlled = FALSE
	role = PVP_SHIP

/obj/structure/overmap/planet/pvp/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new/datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = null

//Overridable method which spawns in the ship we want to use.
/datum/game_mode/pvp/base_defense/generate_ship(ship_type, map_file)
	ship_type = /obj/structure/overmap/planet/pvp //Yes. I'm a hack. Sue me Fran.
	return instance_overmap(_path=ship_type, folder= "map_files/PVP" ,interior_map_files = map_file, traits=list(list(ZTRAIT_UP=1, ZTRAIT_LINKAGE = SELFLOOPING, ZTRAIT_BOARDABLE = 1, ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid/basalt),list(ZTRAIT_DOWN = -1, ZTRAIT_LINKAGE = SELFLOOPING, ZTRAIT_BOARDABLE = 1, ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid/snow/atmosphere)))

/turf/open/floor/plating/asteroid/snow/atmosphere/tartarus
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/floor/plating/snowed/smoothed/tartarus
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS