/mob/dead/observer/Move(NewLoc, direct)
	. = ..()
	update_overmap()
