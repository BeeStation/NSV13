/mob/living/carbon/alien/humanoid/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, bypass_strip_delay_other = TRUE)//NSV13
	. = ..()
	if(!. || !I)
		return

