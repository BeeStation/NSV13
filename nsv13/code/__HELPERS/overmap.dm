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
	var/obj/structure/overmap/OM = loc.get_overmap() //Accounts for things like fighters and for being in nullspace because having no loc is bad.
	if(OM == last_overmap)
		return
	else
		last_overmap?.mobs_in_ship -= src
		last_overmap = OM
		OM?.mobs_in_ship += src
