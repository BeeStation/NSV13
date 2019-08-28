/atom/proc/get_overmap() //Helper proc to get the overmap ship representing a given area.
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		return AR.linked_overmap
	else
		return FALSE

/proc/shares_overmap(atom/source, atom/target)
	var/obj/structure/overmap/OM = source.get_overmap()
	var/obj/structure/overmap/S = target.get_overmap()
	if(OM == S)
		return TRUE
	else
		return FALSE