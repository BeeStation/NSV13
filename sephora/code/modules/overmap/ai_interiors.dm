/obj/structure/overmap
	var/interior_maps = null //Set this for AI ships. This allows them to be boarded. A random interior is picked on a per-ship basis.

/obj/effect/landmark/ship_interior_spawn
	name = "Ship interior spawn"
	desc = "A spawner which will spawn a ship on demand. Use with caution."
	var/interior_map = null

/obj/effect/landmark/ship_interior_spawn/proc/load()
	var/datum/map_template/template = SSmapping.map_templates[templatename]
	if(template?.load(get_turf(src), centered = FALSE))
		return TRUE
	else
		return FALSE

/datum/map_template/corvette
	name = "Syndicate patrol corvette"
	mappath = "_maps/templates/sephora/Corvette.dmm"
