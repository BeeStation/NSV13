/datum/parsed_map/proc/initParsedTemplateBounds(init_atmos = TRUE) //NSV13 this allows parsed maps to load. Required for /proc/instance_overmap
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/movable/movables = list()
	var/list/area/areas = list()

	var/list/turfs = block(locate(1,1,bounds[MAP_MINZ]),locate(world.maxx,world.maxy,bounds[MAP_MAXZ])) //It's done this way in order to properly initialize space
	for(var/turf/current_turf as anything in turfs)
		var/area/current_turfs_area = current_turf.loc
		areas |= current_turfs_area
		if(!SSatoms.initialized)
			continue

		for(var/movable_in_turf in current_turf)
			movables += movable_in_turf
			if(istype(movable_in_turf, /obj/structure/cable))
				cables += movable_in_turf
				continue
			if(istype(movable_in_turf, /obj/machinery/atmospherics))
				atmos_machines += movable_in_turf

	// Not sure if there is some importance here to make sure the area is in z
	// first or not.  Its defined In Initialize yet its run first in templates
	// BEFORE so... hummm
	SSmapping.reg_in_areas_in_z(areas)
	if(!SSatoms.initialized)
		return

	SSatoms.InitializeAtoms(areas + turfs + movables)

	// NOTE, now that Initialize and LateInitialize run correctly, do we really
	// need these two below?
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	if(init_atmos)
		//calculate all turfs inside the border
		var/list/template_and_bordering_turfs = block(
			locate(
				max(bounds[MAP_MINX]-1, 1),
				max(bounds[MAP_MINY]-1, 1),
				bounds[MAP_MINZ]
				),
			locate(
				min(bounds[MAP_MAXX]+1, world.maxx),
				min(bounds[MAP_MAXY]+1, world.maxy),
				bounds[MAP_MAXZ]
				)
		)
		for(var/turf/affected_turf as anything in template_and_bordering_turfs)
			affected_turf.air_update_turf(TRUE)
			affected_turf.levelupdate()
