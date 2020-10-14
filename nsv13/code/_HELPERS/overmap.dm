/datum/space_level
	var/obj/structure/overmap/linked_overmap = null

/atom/proc/get_overmap() //Helper proc to get the overmap ship representing a given area.
	RETURN_TYPE(/obj/structure/overmap)
	if(!z || loc == null)
		return FALSE
	for(var/datum/space_level/SL in SSmapping.z_list)
		if(SL.z_value == z)
			return SL.linked_overmap
	return FALSE

/proc/shares_overmap(atom/source, atom/target)
	var/obj/structure/overmap/OM = source.get_overmap()
	var/obj/structure/overmap/S = target.get_overmap()
	if(OM == S)
		return TRUE
	else
		return FALSE

/mob //I don't like overriding this. This should be more performant than searching a long list of mobs every move though
	var/obj/structure/overmap/last_overmap = null


/mob/dead/observer/Move(NewLoc, direct)
	. = ..()
	find_overmap()

/mob/Move(atom/newloc, direct=0)
	. = ..()
	find_overmap()

/**
Helper method to get what ship an observer belongs to for stuff like parallax.
*/

/mob/proc/find_overmap()
	var/obj/structure/overmap/OM = loc.get_overmap() //Accounts for things like fighters
	if(!OM) //We're on the overmap Z-level itself, thus we don't belong to any ship
		if(last_overmap)
			last_overmap.mobs_in_ship -= src
		return
	if(last_overmap)
		last_overmap.mobs_in_ship -= src
	last_overmap = OM
	OM.mobs_in_ship += src
