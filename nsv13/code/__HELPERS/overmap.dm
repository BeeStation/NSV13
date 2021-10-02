/atom/proc/get_overmap() //Helper proc to get the overmap ship representing a given area.
	RETURN_TYPE(/obj/structure/overmap)
	if(!z || loc == null)
		return FALSE
	for(var/datum/space_level/SL in SSmapping.z_list)
		if(SL.z_value == z)
			return SL.linked_overmap
	return FALSE

/**
Helper method to get what ship an observer belongs to for stuff like parallax.
*/

/mob/proc/find_overmap()
	var/obj/structure/overmap/OM = loc?.get_overmap() //Accounts for things like fighters and for being in nullspace because having no loc is bad.
	if(!OM) //We're on the overmap Z-level itself, thus we don't belong to any ship
		if(last_overmap)
			last_overmap.mobs_in_ship -= src
		return
	if(last_overmap)
		last_overmap.mobs_in_ship -= src
	last_overmap = OM
	OM.mobs_in_ship += src

/// Finds a turf outside of the overmap
/proc/GetSafeTurf(atom/A)
	if(!SSmapping.level_trait(A.z, ZTRAIT_OVERMAP))
		return get_turf(A)

	var/max = world.maxx - TRANSITIONEDGE
	var/min = TRANSITIONEDGE + 1
	var/list/possible_transitions = list()
	for(var/datum/space_level/D as() in SSmapping.z_list)
		if(!D.traits[ZTRAIT_OVERMAP])
			possible_transitions += D.z_value
	if(!length(possible_transitions)) //Just in case there is no space z level
		possible_transitions = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/_z = pick(possible_transitions)
	var/_x
	var/_y
	switch(A.dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min
	return locate(_x, _y, _z) //Where are we putting you
