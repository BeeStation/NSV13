//modular OVERRIDE
/obj/item/hand_tele/try_dispel_portal(atom/target, mob/user, delay = 30)
	var/datum/beam/B = user.Beam(target, icon_state = "rped_upgrade", maxdistance = 50)
	if(is_parent_of_portal(target))
		. = TRUE
		if((delay && !do_after(user, delay, target = target)))
			qdel(B)
			return
		qdel(target)
		to_chat(user, "<span class='notice'>You dispel [target] with \the [src]!</span>")
		qdel(B)
		return
	qdel(B)
	return FALSE
