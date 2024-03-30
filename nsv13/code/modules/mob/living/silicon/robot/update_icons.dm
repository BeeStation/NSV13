/mob/living/silicon/robot/update_icons()
	. = ..()
	update_altborg_icons()

/mob/living/silicon/robot/proc/update_altborg_icons()
	if(stat == DEAD && (R_TRAIT_UNIQUEWRECK in module.module_features))
		icon_state = "[module.cyborg_base_icon]-wreck"

	update_fire()
