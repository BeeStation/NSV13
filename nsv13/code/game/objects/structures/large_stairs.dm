/**
*
* Stairs that behave like stairs actually should because /tg/ stairs are a pile of ass.
* Just place stairs facing up and down above each other.
* These stairs only go up one level. If you stack a tonne of them you won't have a good time
* Make sure theyre facing the same direction or it'll feel weird traversing them.
* MAPPERS: Please enclose your stairs with walls. Otherwise theyll feel weird.
*
*
*/



/obj/structure/large_stairs
	name = "Stairs"
	icon = 'nsv13/icons/obj/stairs_large.dmi'
	icon_state = "upstairs"
	anchored = TRUE
	density = FALSE
	var/obj/structure/large_stairs/target = null

/obj/structure/large_stairs/Initialize()
	. = ..()
	find_partner()

/obj/structure/large_stairs/proc/find_partner()
	var/obj/structure/large_stairs/upstairs = (locate(/obj/structure/large_stairs) in SSmapping.get_turf_above(get_turf(src)))
	var/obj/structure/large_stairs/downstairs = (locate(/obj/structure/large_stairs) in SSmapping.get_turf_below(get_turf(src)))
	if(upstairs && downstairs)
		message_admins("WARNING: [src] in [get_area(src)] leads to more than one set of stairs. Change this so it only leads to one please!")
		return FALSE
	if(upstairs)
		icon_state = "upstairs"
		target = upstairs
		return TRUE
	if(downstairs)
		icon_state = "downstairs"
		target = downstairs
		return TRUE
	return FALSE

/obj/structure/large_stairs/Crossed(atom/movable/AM)
	. = ..()
	if(!target || target.x != x || target.y != y) //If the target stairs have moved position, or have been destroyed. Return.
		if(!find_partner()) //If we find a partner then great, we've remedied the problem
			to_chat(AM, "<span class='warning'>These stairs don't seem to lead anywhere...</span>")
			target = null //Target has moved. Save a few cycles and null this out so we dont run checks on useless stairs
			return
	if(AM.dir != dir)
		return //Otherwise you can just walk on from the side and jump up.
	if(isliving(AM))
		var/mob/living/L = AM
		var/pulling = L.pulling
		if(pulling)
			L.pulling.forceMove(target)
		L.forceMove(target)
		L.start_pulling(pulling)
	else
		AM.forceMove(target)