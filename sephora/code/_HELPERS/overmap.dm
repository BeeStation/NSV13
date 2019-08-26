/atom/proc/get_overmap() //Helper proc to get the overmap ship representing a given area.
	var/area/AR = get_area(src)
	if(AR.linked_overmap)
		return AR.linked_overmap
	else
		return FALSE