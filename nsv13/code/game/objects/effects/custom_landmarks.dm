//Plutonium sludge

#define PLUTONIUM_SLUDGE_RANGE 5
#define PLUTONIUM_SLUDGE_RANGE_STRONG 10
#define PLUTONIUM_SLUDGE_RANGE_WEAK 3

#define PLUTONIUM_SLUDGE_CHANCE 35


/obj/effect/landmark/nuclear_waste_spawner //Clean way of spawning nuclear gunk after a reactor core meltdown.
	name = "nuclear waste spawner"
	var/range = PLUTONIUM_SLUDGE_RANGE //tile radius to spawn goop
	var/center_sludge = TRUE // Whether or not the center turf should spawn sludge or not.
	var/list/avoid_objs = list( // List of objs that the waste does not spawn on
		/obj/structure/stairs, // Sludge is hidden below stairs
		/obj/structure/ladder, // Going down the ladder directly on sludge bad
		/obj/effect/decal/nuclear_waste, // No stacked sludge
		)

/obj/effect/landmark/nuclear_waste_spawner/proc/fire()
	playsound(loc, 'sound/effects/gib_step.ogg', 100)

	if(center_sludge)
		place_sludge(get_turf(src), TRUE)

	for(var/turf/open/floor in orange(range, get_turf(src)))
		place_sludge(floor, FALSE)

	qdel(src)

/// Tries to place plutonium sludge on 'floor'. Returns TRUE if the turf has been successfully processed, FALSE otherwise.
/obj/effect/landmark/nuclear_waste_spawner/proc/place_sludge(turf/open/floor, epicenter = FALSE)
	if(!floor)
		return FALSE

	if(epicenter)
		for(var/obj/effect/decal/nuclear_waste/waste in floor) //Replace nuclear waste with the stronger version
			qdel(waste)
		new /obj/effect/decal/nuclear_waste/epicenter (floor)
		return TRUE

	if(!prob(PLUTONIUM_SLUDGE_CHANCE)) //Scatter the sludge, don't smear it everywhere
		return TRUE


	for(var/obj/O in floor)
		if(O.density && O.anchored) // Dense and anchored objects block sludge (ex. machines, windows) while others (ex. canisters, cell chargers) do not.
			return TRUE
		for(var/blacklisted in avoid_objs)
			if(ispath(O.type, blacklisted))
				return TRUE

	new /obj/effect/decal/nuclear_waste (floor)
	return TRUE

/obj/effect/landmark/nuclear_waste_spawner/strong
	range = PLUTONIUM_SLUDGE_RANGE_STRONG

/obj/effect/landmark/nuclear_waste_spawner/weak
	range = PLUTONIUM_SLUDGE_RANGE_WEAK
	center_sludge = FALSE

#undef PLUTONIUM_SLUDGE_RANGE
#undef PLUTONIUM_SLUDGE_RANGE_STRONG
#undef PLUTONIUM_SLUDGE_RANGE_WEAK
#undef PLUTONIUM_SLUDGE_CHANCE
