/mob //I don't like overriding this. This should be more performant than searching a long list of mobs every move though
	var/obj/structure/overmap/last_overmap = null

/mob/Move(atom/newloc, direct=0)
	. = ..()
	find_overmap()
