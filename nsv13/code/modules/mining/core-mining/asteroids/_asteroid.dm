/datum/map_template/asteroid
	var/list/core_composition = list(/datum/material/plasma = 5, /datum/material/bluespace = 1)

/datum/map_template/asteroid/New(path = null, rename = null, cache = FALSE, var/list/core_comp)
	. = ..()
	if(core_comp)
		core_composition = core_comp
	else
		core_composition = list(/datum/material/iron = 25, /datum/material/titanium = 3)

/datum/map_template/asteroid/load(turf/T, centered = FALSE) ///Add in vein if applicable.
	. = ..()
	message_admins("gay3")
	if(!core_composition) //No core composition? you a normie asteroid.
		return
	var/list/potential_core_turfs = list()
	for(var/x in get_affected_turfs(T, centered))
		var/turf/pot_turf = x
		if(istype(pot_turf, /turf/closed/mineral/dense))
			potential_core_turfs += pot_turf
	var/turf/target_turf = pick(potential_core_turfs)
	var/turf/closed/mineral/dense/vein/C = target_turf.ChangeTurf(/turf/closed/mineral/dense/vein) //Make the core itself
	C.setup_composition(core_composition) //Set it's composition
	C.create_vein() //Create the vein and spread it