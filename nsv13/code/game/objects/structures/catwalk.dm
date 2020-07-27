/obj/structure/lattice/catwalk/over/ship
	name = "plated catwalk"
	desc = "A catwalk used decoratively to expose floor sections in hallways. It has a <b>maintenance hatch</b> which can be opened with a crowbar to access anything below it."
	icon = 'nsv13/icons/obj/smooth_structures/catwalk_plated.dmi'
	color = "#545c68" //Curse you baystation
	icon_state = "catwalk"
	layer = CATWALK_LAYER
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	obj_flags = CAN_BE_HIT | BLOCK_Z_FALL
	var/hatch_open = FALSE //To easily access wiring

/obj/structure/lattice/catwalk/over/ship/dark
 	color = "#4c535b" //Curse you baystation

/obj/structure/lattice/catwalk/over/ship/crowbar_act(mob/living/user, obj/item/I)
	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/openspace)) //So you can't just fuck people's day up and force wires etc. to fall down a deck.
		for(var/obj/O in T.contents)
			if(O == src)
				continue
			if(!O.anchored)
				to_chat(user, "<span class='warning'>[O] refuses to budge! You'll have to un-anchor it before you can open [src]...</span>")
				break
	if(I.use_tool(src, user, 0.5 SECONDS, volume=50))
		user.visible_message("[user] flips [hatch_open ? "closed" : "open"] [src]'s maintenance hatch.",
			"<span class='notice'>you flip [hatch_open ? "closed" : "open"] [src]'s maintenance hatch.</span>")
		hatch_open = !hatch_open
		update_icon()
	return TRUE

/obj/structure/lattice/catwalk/over/ship/update_icon()
	. = ..()
	if(hatch_open)
		icon_state = "catwalk_hatch_open"
		obj_flags &= ~BLOCK_Z_FALL //Minecraft trap door.
		smooth = SMOOTH_FALSE
		clear_smooth_overlays()
	else
		icon_state = initial(icon_state)
		obj_flags |= BLOCK_Z_FALL
		smooth = SMOOTH_TRUE
		queue_smooth(src)