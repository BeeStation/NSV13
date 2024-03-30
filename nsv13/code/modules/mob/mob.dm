/mob //I don't like overriding this. This should be more performant than searching a long list of mobs every move though
	var/obj/structure/overmap/last_overmap = null

/mob/Move(atom/newloc, direct=0)
	. = ..()
	update_overmap()

// There's so many edge cases for player overmap escapes that it's just cleaner to universally check mob forcemoves.
// use doMove if you must get around this for whatever reason
/mob/living/forceMove(atom/destination)
	destination = GetSafeLoc(destination)
	. = ..()
	update_overmap()
