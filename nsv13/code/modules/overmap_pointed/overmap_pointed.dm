// heads can mark overmap targets (by chichmuch)

/obj/effect/temp_visual/overmap_order
	icon = 'icons/effects/aiming.dmi'
	icon_state = "perp_alert"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER


/mob/living/carbon/human/pointed(atom/A as mob|obj|turf in view())
	if(!SSmapping.level_trait(A.z, ZTRAIT_OVERMAP))
		return ..()

	if(!src || !isturf(src.loc))
		return FALSE

	var/turf/tile = get_turf(A)
	if (!tile)
		return FALSE

	var/obj/item/card/id/I = get_idcard(TRUE)
	if(!I)
		return FALSE
	var/list/access = I.GetAccess()

	if(!(ACCESS_HEADS in access))
		return FALSE

	if(istype(A, /obj/structure/overmap) && !A.filter_data)
		A.add_filter("target_outline", 1, list(type="outline", size=2, color=COLOR_RED_LIGHT))
		addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/structure/overmap, remove_target_outline)), 15 SECONDS)
	else
		new /obj/effect/temp_visual/overmap_order(tile, invisibility)

	SEND_SIGNAL(src, COMSIG_MOB_POINTED, A)
	return TRUE


/obj/structure/overmap/proc/remove_target_outline()
	remove_filter("target_outline")
